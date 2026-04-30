@echo off
REM ============================================================
REM  LANACC - make-admin: create or promote a local admin user
REM ------------------------------------------------------------
REM  Works on any computer running the LANACC Docker stack.
REM  Prompts for email, password, and the admin PIN. If the PIN
REM  matches ADMIN_SIGNUP_PIN (.env.local), the user is created
REM  in auth.users (or password reset if existing) and granted
REM  the 'admin' role in public.user_roles.
REM
REM  This is the LOCAL equivalent of the in-app Admin Sign Up.
REM  For cloud (Supabase) accounts, use the Auth page instead.
REM ============================================================
setlocal ENABLEDELAYEDEXPANSION

set API=lanacc-api

docker ps --format "{{.Names}}" | findstr /B /C:"%API%" >nul
if errorlevel 1 (
  echo [ERROR] Container %API% is not running. Start the stack first:
  echo         docker compose --env-file .env.local up -d
  exit /b 1
)

echo.
echo === LANACC make-admin ===
set /p EMAIL=Email:    
set /p PASSWORD=Password: 
set /p PIN=Admin PIN: 

if "%EMAIL%"=="" ( echo [ERROR] email required & exit /b 1 )
if "%PASSWORD%"=="" ( echo [ERROR] password required & exit /b 1 )
if "%PIN%"=="" ( echo [ERROR] PIN required & exit /b 1 )

REM Build JSON safely (no quoting fun) and post to the running API container
> "%TEMP%\lanacc_admin.json" (
  echo {"email":"%EMAIL%","password":"%PASSWORD%","pin":"%PIN%"}
)

docker cp "%TEMP%\lanacc_admin.json" %API%:/tmp/lanacc_admin.json >nul
docker exec %API% sh -c "wget -qO- --header='Content-Type: application/json' --post-file=/tmp/lanacc_admin.json http://localhost:4000/auth/signup-admin"
set RC=%ERRORLEVEL%
del "%TEMP%\lanacc_admin.json" >nul 2>&1

echo.
if %RC% NEQ 0 (
  echo [ERROR] Request failed. Check the API output above.
  exit /b %RC%
)
echo.
echo ============================================================
echo  Done. Log in at http://localhost:8080/auth as %EMAIL%.
echo ============================================================
endlocal
