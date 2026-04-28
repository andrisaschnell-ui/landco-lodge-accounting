@echo off
REM ============================================================
REM  Register Windows Task Scheduler entry to run daily_backup.bat
REM  every day at 22:00.
REM
REM  Run this ONCE, as Administrator, after the stack is working.
REM  Re-run anytime to overwrite the existing task.
REM ============================================================
setlocal
cd /d "%~dp0\.."

set TASK_NAME=LANACC Daily Backup
set SCRIPT="%CD%\scripts\daily_backup.bat"

echo Registering scheduled task "%TASK_NAME%" -^> daily 22:00
echo Script: %SCRIPT%
echo.

schtasks /Create /F /SC DAILY /ST 22:00 /TN "%TASK_NAME%" /TR %SCRIPT% /RL HIGHEST
if errorlevel 1 (
  echo.
  echo [ERROR] Could not register the task. Run this script "As Administrator".
  exit /b 1
)

echo.
echo Done. Verify with:  schtasks /Query /TN "%TASK_NAME%"
echo Run it now with:     schtasks /Run  /TN "%TASK_NAME%"
endlocal
