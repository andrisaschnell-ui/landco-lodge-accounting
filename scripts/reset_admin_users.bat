@echo off
REM ============================================================
REM  LANACC - Reset / recreate the two admin users
REM ------------------------------------------------------------
REM  Run this any time you cannot log in as:
REM     cwschnell@gmail.com        (password: Abcd7654$)
REM     andrisa.schnell@gmail.com  (password: Abcd7654#)
REM
REM  It will:
REM    1. Generate fresh bcrypt hashes inside the API container
REM    2. UPSERT both users into auth.users with those hashes
REM    3. Grant them the 'admin' role in public.user_roles
REM    4. Verify they can be found
REM
REM  Requirements: docker compose stack must be running
REM     (containers: lanacc-api, lanacc-db)
REM ============================================================

setlocal ENABLEDELAYEDEXPANSION

set API=lanacc-api
set DB=lanacc-db
set DBNAME=landco_v2_db
set DBUSER=postgres

echo.
echo === Step 1: checking containers ===
docker ps --format "{{.Names}}" | findstr /B /C:"%API%" >nul
if errorlevel 1 (
  echo [ERROR] Container %API% is not running. Start the stack with: docker compose up -d
  exit /b 1
)
docker ps --format "{{.Names}}" | findstr /B /C:"%DB%" >nul
if errorlevel 1 (
  echo [ERROR] Container %DB% is not running. Start the stack with: docker compose up -d
  exit /b 1
)

echo.
echo === Step 2: generating bcrypt hashes ===
for /f "delims=" %%H in ('docker exec %API% node -e "console.log(require('bcryptjs').hashSync('Abcd7654$',10))"') do set HASH1=%%H
for /f "delims=" %%H in ('docker exec %API% node -e "console.log(require('bcryptjs').hashSync('Abcd7654#',10))"') do set HASH2=%%H

if "!HASH1!"=="" (
  echo [ERROR] Failed to generate hash for user 1
  exit /b 1
)
if "!HASH2!"=="" (
  echo [ERROR] Failed to generate hash for user 2
  exit /b 1
)
echo Hashes generated successfully.

echo.
echo === Step 3: upserting users + granting admin ===

REM Build a temporary SQL file inside the db container
(
  echo -- Make sure the auth schema + users table exist with required columns
  echo CREATE SCHEMA IF NOT EXISTS auth;
  echo CREATE TABLE IF NOT EXISTS auth.users ^(
  echo   id uuid PRIMARY KEY DEFAULT gen_random_uuid^(^),
  echo   email text UNIQUE NOT NULL,
  echo   password_hash text NOT NULL,
  echo   display_name text,
  echo   created_at timestamptz DEFAULT now^(^)
  echo ^);
  echo.
  echo -- User 1: cwschnell@gmail.com
  echo INSERT INTO auth.users ^(email, password_hash, display_name^)
  echo VALUES ^('cwschnell@gmail.com', '!HASH1!', 'CW Schnell'^)
  echo ON CONFLICT ^(email^) DO UPDATE SET password_hash = EXCLUDED.password_hash;
  echo.
  echo -- User 2: andrisa.schnell@gmail.com
  echo INSERT INTO auth.users ^(email, password_hash, display_name^)
  echo VALUES ^('andrisa.schnell@gmail.com', '!HASH2!', 'Andrisa Schnell'^)
  echo ON CONFLICT ^(email^) DO UPDATE SET password_hash = EXCLUDED.password_hash;
  echo.
  echo -- Grant admin role to both ^(idempotent^)
  echo INSERT INTO public.user_roles ^(user_id, role^)
  echo SELECT id, 'admin'::app_role FROM auth.users
  echo WHERE email IN ^('cwschnell@gmail.com', 'andrisa.schnell@gmail.com'^)
  echo ON CONFLICT ^(user_id, role^) DO NOTHING;
  echo.
  echo -- Show result
  echo SELECT u.email, u.display_name, r.role
  echo FROM auth.users u LEFT JOIN public.user_roles r ON r.user_id = u.id
  echo WHERE u.email IN ^('cwschnell@gmail.com', 'andrisa.schnell@gmail.com'^);
) > "%TEMP%\lanacc_reset_users.sql"

docker cp "%TEMP%\lanacc_reset_users.sql" %DB%:/tmp/lanacc_reset_users.sql >nul
docker exec %DB% psql -U %DBUSER% -d %DBNAME% -v ON_ERROR_STOP=1 -f /tmp/lanacc_reset_users.sql
if errorlevel 1 (
  echo.
  echo [ERROR] SQL execution failed. Check the output above.
  del "%TEMP%\lanacc_reset_users.sql" >nul 2>&1
  exit /b 1
)

del "%TEMP%\lanacc_reset_users.sql" >nul 2>&1

echo.
echo ============================================================
echo  DONE. You can now log in at http://localhost:8080/auth with:
echo     cwschnell@gmail.com / Abcd7654$
echo     andrisa.schnell@gmail.com / Abcd7654#
echo ============================================================
endlocal
