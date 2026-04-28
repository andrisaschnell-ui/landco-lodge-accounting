@echo off
REM ============================================================
REM  LANACC — daily backup to E:\landco_daily_backup
REM  Runs pg_dump from inside the lanacc-db container, writes a
REM  timestamped .sql to the USB drive, then prunes files older
REM  than 30 days.
REM
REM  Scheduled by scripts\install_scheduled_task.bat to run 22:00.
REM ============================================================
setlocal EnableDelayedExpansion

set BACKUP_DIR=E:\landco_daily_backup
set RETENTION_DAYS=30
set LOG=%BACKUP_DIR%\backup.log

if not exist "%BACKUP_DIR%" (
  echo [%DATE% %TIME%] ERROR: %BACKUP_DIR% not found. Plug in the Lexar USB drive.
  exit /b 1
)

REM Build a YYYYMMDD_HHMMSS stamp independent of locale
for /f "tokens=2 delims==" %%I in ('wmic os get localdatetime /value ^| find "="') do set DT=%%I
set STAMP=%DT:~0,8%_%DT:~8,6%
set FILE=lanacc_%STAMP%.sql

echo. >> "%LOG%"
echo [%DATE% %TIME%] Starting backup -^> %BACKUP_DIR%\%FILE% >> "%LOG%"

docker exec lanacc-db pg_dump -U postgres -d landco_v2_db --clean --if-exists > "%BACKUP_DIR%\%FILE%" 2>> "%LOG%"
if errorlevel 1 (
  echo [%DATE% %TIME%] ERROR: pg_dump failed. Is Docker running? >> "%LOG%"
  del "%BACKUP_DIR%\%FILE%" 2>nul
  exit /b 1
)

REM Verify dump is non-trivial (>10 KB)
for %%A in ("%BACKUP_DIR%\%FILE%") do set SIZE=%%~zA
if %SIZE% LSS 10240 (
  echo [%DATE% %TIME%] ERROR: dump too small (%SIZE% bytes). Removing. >> "%LOG%"
  del "%BACKUP_DIR%\%FILE%"
  exit /b 1
)

echo [%DATE% %TIME%] OK %FILE% (%SIZE% bytes) >> "%LOG%"

REM Prune dumps older than RETENTION_DAYS
forfiles /p "%BACKUP_DIR%" /m lanacc_*.sql /d -%RETENTION_DAYS% /c "cmd /c del @path && echo [%DATE% %TIME%] Pruned @file >> %LOG%" 2>nul

endlocal
