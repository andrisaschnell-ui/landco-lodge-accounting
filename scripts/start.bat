@echo off
REM Build and start the full LANACC stack
docker compose up -d --build
echo.
echo ============================================
echo   LANACC stack started
echo   Web      : http://localhost:8080
echo   API      : http://localhost:4000/health
echo   pgAdmin  : http://localhost:5050
echo   Postgres : localhost:5432  (user: lanacc)
echo ============================================
