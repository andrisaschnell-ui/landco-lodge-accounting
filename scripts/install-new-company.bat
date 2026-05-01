@echo off
REM ============================================================
REM  install-new-company.bat
REM  One-shot installer for a brand-new company on a NEW computer.
REM
REM  This is a wrapper around the existing scripts:
REM    - git clone (branch v5)
REM    - .env.local generation (random passwords)
REM    - docker-compose.override.yml (unique container/volume names + ports)
REM    - docker compose up -d --build
REM    - admin user creation (two admins, prompted)
REM    - company_settings UPDATE (name, NUIT, address, telephone)
REM    - optional demo data seed
REM
REM  Prereqs on the target machine:
REM    - Docker Desktop installed AND RUNNING
REM    - Git for Windows installed
REM    - Internet access (to clone the repo and pull base images)
REM
REM  Usage (from any folder):
REM    install-new-company.bat
REM ============================================================

setlocal ENABLEDELAYEDEXPANSION
title Landco Accounting - New Company Installer
color 0B

echo.
echo ============================================================
echo   LANDCO ACCOUNTING - NEW COMPANY INSTALLER
echo ============================================================
echo.
echo  This wizard installs a fresh, isolated copy of the
echo  accounting app for a NEW company on this computer.
echo.
echo  It will ask you for:
echo    - A folder to install into
echo    - The new application name (used for containers/DB)
echo    - Your company name, NUIT, address, telephone
echo    - Two admin user emails + passwords
echo.
echo  Nothing on this computer will be touched outside the
echo  folder you choose. Each installation is fully isolated.
echo ============================================================
echo.
pause

REM ---------------------------------------------------------------
REM  Step 1 — Pre-flight checks
REM ---------------------------------------------------------------
echo.
echo === [1/8] Checking prerequisites ===

where git >nul 2>&1
if errorlevel 1 (
  echo [ERROR] Git is not installed or not in PATH.
  echo         Install from: https://git-scm.com/download/win
  pause & exit /b 1
)

where docker >nul 2>&1
if errorlevel 1 (
  echo [ERROR] Docker is not installed or not in PATH.
  echo         Install Docker Desktop from: https://www.docker.com/products/docker-desktop
  pause & exit /b 1
)

docker info >nul 2>&1
if errorlevel 1 (
  echo [ERROR] Docker Desktop is not running. Start it and try again.
  pause & exit /b 1
)
echo OK - git, docker found and Docker is running.

REM ---------------------------------------------------------------
REM  Step 2 — Collect installation parameters
REM ---------------------------------------------------------------
echo.
echo === [2/8] Installation details ===
echo.
set /p INSTALL_DIR="Install folder (e.g. C:\Apps\AcmeBooks): "
if "%INSTALL_DIR%"=="" ( echo [ERROR] folder required & pause & exit /b 1 )

set /p APP_NAME="New application short name (lowercase, no spaces, e.g. acme): "
if "%APP_NAME%"=="" ( echo [ERROR] app name required & pause & exit /b 1 )

set /p WEBPORT="Web port (default 8080, use 8081/8082 if 8080 is taken): "
set /p APIPORT="API port (default 4000): "
set /p DBPORT="DB  port (default 5432): "
if "%WEBPORT%"=="" set WEBPORT=8080
if "%APIPORT%"=="" set APIPORT=4000
if "%DBPORT%"=="" set DBPORT=5432

echo.
echo === [3/8] Company identity ===
echo.
set /p COMPANY_NAME="Company legal name (e.g. Acme Lda): "
set /p COMPANY_NUIT="NUIT (Mozambique tax number): "
set /p COMPANY_ADDR="Street address (city, Mozambique): "
set /p COMPANY_TEL="Telephone (e.g. +258 84 123 4567): "
if "%COMPANY_NAME%"=="" ( echo [ERROR] company name required & pause & exit /b 1 )

echo.
echo === [4/8] Admin users ===
echo.
echo You'll create TWO admin users now. They can sign in
echo immediately after the install finishes.
echo.
set /p ADMIN1_EMAIL="Admin #1 email: "
set /p ADMIN1_PASS="Admin #1 password (min 8 chars): "
set /p ADMIN1_NAME="Admin #1 display name: "
echo.
set /p ADMIN2_EMAIL="Admin #2 email: "
set /p ADMIN2_PASS="Admin #2 password (min 8 chars): "
set /p ADMIN2_NAME="Admin #2 display name: "

if "%ADMIN1_EMAIL%"=="" ( echo [ERROR] admin 1 email required & pause & exit /b 1 )
if "%ADMIN2_EMAIL%"=="" ( echo [ERROR] admin 2 email required & pause & exit /b 1 )

echo.
set /p LOAD_DEMO="Load demo placeholder data (chart of accounts, sample property)? [Y/n]: "
if "%LOAD_DEMO%"=="" set LOAD_DEMO=Y

echo.
echo ------------------------------------------------------------
echo  Review:
echo    Folder    : %INSTALL_DIR%
echo    App name  : %APP_NAME%
echo    Ports     : web=%WEBPORT% api=%APIPORT% db=%DBPORT%
echo    Company   : %COMPANY_NAME% (NUIT %COMPANY_NUIT%)
echo    Address   : %COMPANY_ADDR%
echo    Telephone : %COMPANY_TEL%
echo    Admin 1   : %ADMIN1_EMAIL%
echo    Admin 2   : %ADMIN2_EMAIL%
echo    Demo data : %LOAD_DEMO%
echo ------------------------------------------------------------
set /p CONFIRM="Proceed with install? [Y/n]: "
if /I not "%CONFIRM%"=="Y" if not "%CONFIRM%"=="" ( echo Cancelled. & exit /b 0 )

REM ---------------------------------------------------------------
REM  Step 5 — Clone repository (branch v5)
REM ---------------------------------------------------------------
echo.
echo === [5/8] Cloning application from GitHub (branch v5) ===
if exist "%INSTALL_DIR%" (
  echo [WARN] Folder already exists. Files will be added inside it.
) else (
  mkdir "%INSTALL_DIR%"
)

REM The repo URL is set by the user-side wrapper or you can hardcode it here.
if "%LANACC_REPO_URL%"=="" (
  set /p LANACC_REPO_URL="GitHub repo URL (https://github.com/.../landco.git): "
)
if "%LANACC_REPO_URL%"=="" ( echo [ERROR] repo URL required & pause & exit /b 1 )

git clone --branch v5 --single-branch "%LANACC_REPO_URL%" "%INSTALL_DIR%\src"
if errorlevel 1 ( echo [ERROR] git clone failed & pause & exit /b 1 )

REM Move clone contents up one level (so install dir IS the project root)
xcopy "%INSTALL_DIR%\src\*" "%INSTALL_DIR%\" /E /I /H /Y >nul
rmdir /S /Q "%INSTALL_DIR%\src"

REM ---------------------------------------------------------------
REM  Step 6 — Generate .env.local + override file
REM ---------------------------------------------------------------
echo.
echo === [6/8] Generating configuration ===
cd /d "%INSTALL_DIR%"

REM Generate random passwords/secrets via PowerShell (always present on Win10+)
for /f "delims=" %%P in ('powershell -NoProfile -Command "[Convert]::ToBase64String([Security.Cryptography.RandomNumberGenerator]::GetBytes(24))"') do set PG_PWD=%%P
for /f "delims=" %%P in ('powershell -NoProfile -Command "[Convert]::ToBase64String([Security.Cryptography.RandomNumberGenerator]::GetBytes(32))"') do set JWT_SEC=%%P
for /f "delims=" %%P in ('powershell -NoProfile -Command "[Convert]::ToBase64String([Security.Cryptography.RandomNumberGenerator]::GetBytes(32))"') do set AT_KEY=%%P

(
  echo # Auto-generated by install-new-company.bat - DO NOT COMMIT
  echo COMPANY_NAME=%APP_NAME%
  echo POSTGRES_DB=%APP_NAME%_db
  echo POSTGRES_USER=postgres
  echo POSTGRES_PASSWORD=%PG_PWD%
  echo JWT_SECRET=%JWT_SEC%
  echo AT_SIGNING_KEY=%AT_KEY%
  echo ADMIN_SIGNUP_PIN=
  echo SUPABASE_SERVICE_ROLE_KEY=
  echo WEB_PORT=%WEBPORT%
  echo API_PORT=%APIPORT%
  echo DB_PORT=%DBPORT%
) > .env.local

(
  echo services:
  echo   db:
  echo     container_name: %APP_NAME%-db
  echo     environment:
  echo       POSTGRES_DB: %APP_NAME%_db
  echo     ports:
  echo       - "%DBPORT%:5432"
  echo     volumes:
  echo       - %APP_NAME%-pgdata:/var/lib/postgresql/data
  echo       - ./db/init:/docker-entrypoint-initdb.d
  echo   api:
  echo     container_name: %APP_NAME%-api
  echo     environment:
  echo       - DATABASE_URL=postgres://postgres:%PG_PWD%@db:5432/%APP_NAME%_db
  echo       - COMPANY_NAME=%COMPANY_NAME%
  echo       - COMPANY_NUIT=%COMPANY_NUIT%
  echo       - COMPANY_ADDRESS=%COMPANY_ADDR%
  echo     ports:
  echo       - "%APIPORT%:4000"
  echo   web:
  echo     container_name: %APP_NAME%-web
  echo     ports:
  echo       - "%WEBPORT%:8080"
  echo volumes:
  echo   %APP_NAME%-pgdata:
  echo     name: %APP_NAME%-pgdata
) > docker-compose.override.yml

echo Wrote .env.local and docker-compose.override.yml

REM ---------------------------------------------------------------
REM  Step 7 — Build + start containers
REM ---------------------------------------------------------------
echo.
echo === [7/8] Building and starting containers (this may take 5-10 min) ===
docker compose --env-file .env.local up -d --build
if errorlevel 1 ( echo [ERROR] docker compose failed & pause & exit /b 1 )

echo Waiting for database to become ready...
set TRIES=0
:waitdb
set /a TRIES+=1
docker exec %APP_NAME%-db pg_isready -U postgres -d %APP_NAME%_db >nul 2>&1
if not errorlevel 1 goto dbready
if %TRIES% GEQ 60 (
  echo [ERROR] Database not ready after 2 minutes. Check: docker logs %APP_NAME%-db
  pause & exit /b 1
)
timeout /t 2 /nobreak >nul
goto waitdb
:dbready
echo Database is ready.

REM ---------------------------------------------------------------
REM  Step 8 — Seed admins, identity, demo data
REM ---------------------------------------------------------------
echo.
echo === [8/8] Creating admin users and saving company identity ===

for /f "delims=" %%H in ('docker exec %APP_NAME%-api node -e "console.log(require('bcryptjs').hashSync(process.argv[1],10))" "%ADMIN1_PASS%"') do set H1=%%H
for /f "delims=" %%H in ('docker exec %APP_NAME%-api node -e "console.log(require('bcryptjs').hashSync(process.argv[1],10))" "%ADMIN2_PASS%"') do set H2=%%H

(
  echo CREATE SCHEMA IF NOT EXISTS auth;
  echo CREATE TABLE IF NOT EXISTS auth.users ^(
  echo   id uuid PRIMARY KEY DEFAULT gen_random_uuid^(^),
  echo   email text UNIQUE NOT NULL,
  echo   password_hash text NOT NULL,
  echo   display_name text,
  echo   created_at timestamptz DEFAULT now^(^)
  echo ^);
  echo.
  echo INSERT INTO auth.users ^(email, password_hash, display_name^)
  echo VALUES ^('%ADMIN1_EMAIL%', '!H1!', '%ADMIN1_NAME%'^)
  echo ON CONFLICT ^(email^) DO UPDATE SET password_hash = EXCLUDED.password_hash, display_name = EXCLUDED.display_name;
  echo.
  echo INSERT INTO auth.users ^(email, password_hash, display_name^)
  echo VALUES ^('%ADMIN2_EMAIL%', '!H2!', '%ADMIN2_NAME%'^)
  echo ON CONFLICT ^(email^) DO UPDATE SET password_hash = EXCLUDED.password_hash, display_name = EXCLUDED.display_name;
  echo.
  echo INSERT INTO public.user_roles ^(user_id, role^)
  echo SELECT id, 'admin'::app_role FROM auth.users
  echo WHERE email IN ^('%ADMIN1_EMAIL%', '%ADMIN2_EMAIL%'^)
  echo ON CONFLICT ^(user_id, role^) DO NOTHING;
  echo.
  echo UPDATE public.company_settings
  echo SET name = '%COMPANY_NAME%',
  echo     nuit = NULLIF^('%COMPANY_NUIT%', ''^),
  echo     address = NULLIF^('%COMPANY_ADDR%', ''^),
  echo     telephone = NULLIF^('%COMPANY_TEL%', ''^);
  echo.
  echo SELECT u.email, u.display_name, r.role FROM auth.users u
  echo LEFT JOIN public.user_roles r ON r.user_id = u.id
  echo WHERE u.email IN ^('%ADMIN1_EMAIL%', '%ADMIN2_EMAIL%'^);
) > "%TEMP%\install_seed.sql"

docker cp "%TEMP%\install_seed.sql" %APP_NAME%-db:/tmp/install_seed.sql >nul
docker exec %APP_NAME%-db psql -U postgres -d %APP_NAME%_db -v ON_ERROR_STOP=1 -f /tmp/install_seed.sql
set RC=%ERRORLEVEL%
del "%TEMP%\install_seed.sql" >nul 2>&1
if %RC% NEQ 0 ( echo [ERROR] Seed SQL failed & pause & exit /b %RC% )

if /I "%LOAD_DEMO%"=="Y" (
  echo Loading demo data...
  if exist "db\seed\demo_data.sql" (
    docker cp "db\seed\demo_data.sql" %APP_NAME%-db:/tmp/demo_data.sql >nul
    docker exec %APP_NAME%-db psql -U postgres -d %APP_NAME%_db -f /tmp/demo_data.sql
  ) else (
    echo [WARN] db\seed\demo_data.sql not found - skipping
  )
)

REM ---------------------------------------------------------------
REM  Done
REM ---------------------------------------------------------------
echo.
color 0A
echo ============================================================
echo   INSTALL COMPLETE - %COMPANY_NAME%
echo ============================================================
echo.
echo   Open the app:    http://localhost:%WEBPORT%
echo.
echo   Sign in as:
echo      %ADMIN1_EMAIL%  (the password you just chose)
echo      %ADMIN2_EMAIL%  (the password you just chose)
echo.
echo   Installation folder:  %INSTALL_DIR%
echo   Containers:           %APP_NAME%-web, %APP_NAME%-api, %APP_NAME%-db
echo   Database name:        %APP_NAME%_db
echo.
echo   Next steps:
echo     1. Sign in and go to Settings -^> Identity to upload a logo.
echo     2. Set up a daily backup folder under Settings -^> Operational.
echo     3. To stop the app:    cd "%INSTALL_DIR%" ^&^& docker compose stop
echo     4. To start again:     cd "%INSTALL_DIR%" ^&^& docker compose --env-file .env.local up -d
echo ============================================================
echo.
pause
endlocal
