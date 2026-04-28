@echo off
REM Build and start the full LANACC stack with secrets from .env.local
setlocal
cd /d "%~dp0\.."

if not exist .env.local (
  echo.
  echo [ERROR] .env.local not found at %CD%\.env.local
  echo.
  echo Copy .env.example to .env.local and fill in real values:
  echo     copy .env.example .env.local
  echo     notepad .env.local
  echo.
  echo See INSTALL.md for full instructions.
  exit /b 1
)

docker compose --env-file .env.local up -d --build
if errorlevel 1 (
  echo [ERROR] docker compose failed. Check that all required vars are set in .env.local.
  exit /b 1
)

echo.
echo ============================================
echo   LANACC stack started
echo   Web      : http://localhost:8080
echo   API      : http://localhost:4000/health
echo   Sync chk : http://localhost:4000/api/sync/status
echo   pgAdmin  : http://localhost:5050
echo   Postgres : localhost:5432  (user: postgres)
echo ============================================
echo.
echo Verify cloud sync is loaded:
curl -s http://localhost:4000/api/sync/status
echo.
endlocal
