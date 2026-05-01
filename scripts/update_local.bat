@echo off
REM ============================================================
REM  LANACC - Update local Docker stack from GitHub branch v5
REM ------------------------------------------------------------
REM  Pulls latest code, applies pending DB migrations, rebuilds
REM  containers, and runs a smoke test. Safe to re-run.
REM
REM  Usage (from project root):
REM      scripts\update_local.bat
REM ============================================================
setlocal EnableDelayedExpansion
cd /d "%~dp0\.."

set "LOG=update_local.log"
echo. > "%LOG%"
call :log "============================================================"
call :log "  LANACC LOCAL UPDATE  -  %DATE% %TIME%"
call :log "============================================================"

REM ---- 0. Pre-flight ----------------------------------------------------
where docker >nul 2>&1 || (call :fail "Docker CLI not found. Start Docker Desktop." && exit /b 1)
where git    >nul 2>&1 || (call :fail "Git not found in PATH." && exit /b 1)
docker info >nul 2>&1 || (call :fail "Docker Desktop is not running." && exit /b 1)

if not exist .env.local (
  call :fail ".env.local missing. Copy .env.example to .env.local and fill in secrets first."
  exit /b 1
)

REM ---- 1. Safety backup BEFORE pulling ---------------------------------
call :log ""
call :log "--- Step 1/7: Pre-update database backup ---"
docker ps --format "{{.Names}}" | findstr /B /C:"lanacc-db" >nul
if not errorlevel 1 (
  if not exist db\backups mkdir db\backups
  set "STAMP=%DATE:/=-%_%TIME::=-%"
  set "STAMP=!STAMP: =0!"
  set "STAMP=!STAMP:,=.!"
  set "BKP=db\backups\pre_update_!STAMP!.sql"
  call :log "Dumping to !BKP! ..."
  docker exec lanacc-db pg_dump -U postgres -d landco_v2_db --clean --if-exists > "!BKP!" 2>>"%LOG%"
  if errorlevel 1 (
    call :log "[WARN] Backup failed. Continuing anyway (db may be empty)."
  ) else (
    call :log "Backup OK: !BKP!"
  )
) else (
  call :log "lanacc-db not running - skipping pre-update backup."
)

REM ---- 2. Pull latest code from v5 -------------------------------------
call :log ""
call :log "--- Step 2/7: git fetch + checkout v5 + pull ---"
git fetch origin                          >>"%LOG%" 2>&1 || (call :fail "git fetch failed" && exit /b 1)
git checkout v5                           >>"%LOG%" 2>&1 || (call :fail "git checkout v5 failed - commit/stash local changes first" && exit /b 1)

REM Capture commit BEFORE pull, then track new migrations introduced
for /f %%i in ('git rev-parse HEAD') do set "OLD_SHA=%%i"
git pull --ff-only origin v5              >>"%LOG%" 2>&1 || (call :fail "git pull failed (non-fast-forward). Resolve manually." && exit /b 1)
for /f %%i in ('git rev-parse HEAD') do set "NEW_SHA=%%i"
call :log "Updated: %OLD_SHA% -> %NEW_SHA%"

REM ---- 3. Detect new SQL migrations ------------------------------------
call :log ""
call :log "--- Step 3/7: Detecting new SQL migrations ---"
set "NEW_MIGRATIONS="
for /f "delims=" %%f in ('git diff --name-only %OLD_SHA% %NEW_SHA% -- "supabase/migrations/*.sql" "db/migrations/*.sql" 2^>nul') do (
  set "NEW_MIGRATIONS=!NEW_MIGRATIONS! %%f"
  call :log "  + %%f"
)
if "!NEW_MIGRATIONS!"=="" call :log "  (no new migration files)"

REM ---- 4. Rebuild containers -------------------------------------------
call :log ""
call :log "--- Step 4/7: docker compose up -d --build ---"
docker compose --env-file .env.local up -d --build >>"%LOG%" 2>&1
if errorlevel 1 (call :fail "docker compose build failed - see %LOG%" && exit /b 1)

REM ---- 5. Wait for DB readiness ----------------------------------------
call :log ""
call :log "--- Step 5/7: Waiting for Postgres to accept connections ---"
set /a tries=0
:waitdb
set /a tries+=1
docker exec lanacc-db pg_isready -U postgres -d landco_v2_db >nul 2>&1
if not errorlevel 1 goto dbready
if %tries% GEQ 30 (call :fail "Postgres did not become ready in 60s" && exit /b 1)
timeout /t 2 /nobreak >nul
goto waitdb
:dbready
call :log "Postgres ready."

REM ---- 6. Apply new migrations -----------------------------------------
call :log ""
call :log "--- Step 6/7: Applying new migrations (idempotent) ---"
if not "!NEW_MIGRATIONS!"=="" (
  for %%f in (!NEW_MIGRATIONS!) do (
    if exist "%%f" (
      call :log "Running %%f ..."
      docker exec -i lanacc-db psql -U postgres -d landco_v2_db -v ON_ERROR_STOP=1 < "%%f" >>"%LOG%" 2>&1
      if errorlevel 1 (
        call :log "[WARN] %%f failed or already applied - check %LOG%"
      ) else (
        call :log "  OK"
      )
    )
  )
) else (
  call :log "No migrations to apply."
)

REM ---- 7. Smoke test ---------------------------------------------------
call :log ""
call :log "--- Step 7/7: Smoke test ---"
set "OK=1"

REM API health
curl -fs -o nul http://localhost:4000/health   && (call :log "  [OK]  API  /health"        ) || (call :log "  [FAIL] API  /health"        & set "OK=0")
curl -fs -o nul http://localhost:4000/api/sync/status && (call :log "  [OK]  API  /api/sync/status") || (call :log "  [FAIL] API  /api/sync/status" & set "OK=0")
curl -fs -o nul http://localhost:8080          && (call :log "  [OK]  Web  http://localhost:8080") || (call :log "  [FAIL] Web  http://localhost:8080" & set "OK=0")

REM DB query
docker exec lanacc-db psql -U postgres -d landco_v2_db -tAc "select count(*) from information_schema.tables where table_schema='public';" >nul 2>&1
if not errorlevel 1 (call :log "  [OK]  DB   public schema reachable") else (call :log "  [FAIL] DB   query failed" & set "OK=0")

call :log ""
call :log "============================================================"
if "%OK%"=="1" (
  call :log "  UPDATE SUCCESSFUL"
  call :log "  Open: http://localhost:8080"
) else (
  call :log "  UPDATE COMPLETED WITH WARNINGS - inspect %LOG%"
  call :log "  Rollback: scripts\restore.bat <pre_update_*.sql>"
)
call :log "============================================================"
type "%LOG%"
endlocal
exit /b 0

:log
echo %~1
echo %~1>> "%LOG%"
exit /b 0

:fail
echo [ERROR] %~1
echo [ERROR] %~1>> "%LOG%"
exit /b 0
