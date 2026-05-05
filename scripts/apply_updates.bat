@echo off
REM ============================================================
REM LANACC — Apply Releases 1, 2, 4 to local Postgres (Docker)
REM ============================================================
REM Run from the project root (where docker-compose.yml lives).
REM Usage:   scripts\apply_updates.bat
REM ============================================================

setlocal enabledelayedexpansion

set DB_CONTAINER=lanacc-db
set DB_USER=postgres
set DB_NAME=landco_v2_db
set MIG_DIR=db\migrations
set BACKUP_DIR=db\backups

echo.
echo === LANACC schema update — Releases 1, 2, 4 ===
echo.

REM 1. Verify Docker is running and the DB container is up
docker ps --format "{{.Names}}" | findstr /B /C:"%DB_CONTAINER%" >nul
if errorlevel 1 (
  echo [ERROR] Container %DB_CONTAINER% is not running.
  echo         Run scripts\start.bat first.
  exit /b 1
)

REM 2. Take a safety backup BEFORE applying anything
if not exist "%BACKUP_DIR%" mkdir "%BACKUP_DIR%"
for /f "tokens=2 delims==" %%a in ('wmic os get localdatetime /value ^| find "="') do set dt=%%a
set STAMP=%dt:~0,8%_%dt:~8,6%
set BKP=%BACKUP_DIR%\pre_update_%STAMP%.sql
echo [1/5] Taking safety backup -^> %BKP%
docker exec %DB_CONTAINER% pg_dump -U %DB_USER% -d %DB_NAME% --clean --if-exists > "%BKP%"
if errorlevel 1 (
  echo [ERROR] Backup failed. Aborting so nothing is changed.
  exit /b 1
)

REM 3. Apply each migration in order. Each script is idempotent
REM    (uses CREATE TABLE IF NOT EXISTS / DROP TRIGGER IF EXISTS).
echo.
echo [2/5] Applying Release 1 — double-entry engine
docker exec -i %DB_CONTAINER% psql -U %DB_USER% -d %DB_NAME% -v ON_ERROR_STOP=1 < %MIG_DIR%\2026_release1_double_entry.sql
if errorlevel 1 goto :rollback

echo.
echo [3/5] Applying Release 2 — statements ^& budgets
docker exec -i %DB_CONTAINER% psql -U %DB_USER% -d %DB_NAME% -v ON_ERROR_STOP=1 < %MIG_DIR%\2026_release2_statements.sql
if errorlevel 1 goto :rollback

echo.
echo [4/5] Applying Release 4 — assets, inventory, banking, workflow, audit
docker exec -i %DB_CONTAINER% psql -U %DB_USER% -d %DB_NAME% -v ON_ERROR_STOP=1 < %MIG_DIR%\2026_release4_workflow.sql
if errorlevel 1 goto :rollback

REM 4. Sanity check — confirm key new tables exist
echo.
echo [5/5] Verifying new tables ...
docker exec %DB_CONTAINER% psql -U %DB_USER% -d %DB_NAME% -c "SELECT table_name FROM information_schema.tables WHERE table_schema='public' AND table_name IN ('journal_entries','journal_lines','accounting_periods','budgets','fixed_assets','depreciation_schedule','inventory_items','inventory_movements','bank_reconciliations','fx_revaluations','document_attachments','audit_log','company_settings') ORDER BY table_name;"

REM 5. Restart the API container so any cached connection state is reset
echo.
echo Restarting lanacc-api ...
docker restart lanacc-api >nul

echo.
echo === DONE. Local schema is now aligned with Cloud (Releases 1, 2, 4). ===
echo Backup kept at: %BKP%
echo.
echo Next step: open the app -^> Sync -^> "Pull Cloud -^> Local"
echo to bring down any data the Cloud has that the local DB does not.
exit /b 0

:rollback
echo.
echo [ERROR] A migration failed. Restoring from %BKP% ...
docker exec -i %DB_CONTAINER% psql -U %DB_USER% -d %DB_NAME% < "%BKP%"
echo Rolled back. Investigate the error above and re-run when fixed.
exit /b 1
