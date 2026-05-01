#!/usr/bin/env bash
# ============================================================
#  install-new-company.sh
#  One-shot installer for a brand-new company on a NEW computer.
#  Mac / Linux equivalent of install-new-company.bat.
# ============================================================
set -e

cyan()  { printf "\033[1;36m%s\033[0m\n" "$*"; }
green() { printf "\033[1;32m%s\033[0m\n" "$*"; }
red()   { printf "\033[1;31m%s\033[0m\n" "$*"; }
ask()   { local v; read -rp "$1" v; echo "$v"; }
askp()  { local v; read -rsp "$1" v; echo; echo "$v"; }

cyan "============================================================"
cyan "  LANDCO ACCOUNTING - NEW COMPANY INSTALLER"
cyan "============================================================"
echo
echo "Installs a fresh, isolated copy of the accounting app for a"
echo "NEW company on this computer. Each install is independent."
echo
read -rp "Press Enter to begin..."

# --- 1. Pre-flight ------------------------------------------------
echo; cyan "=== [1/8] Checking prerequisites ==="
command -v git >/dev/null    || { red "git not installed";    exit 1; }
command -v docker >/dev/null || { red "docker not installed"; exit 1; }
docker info >/dev/null 2>&1  || { red "Docker is not running"; exit 1; }
echo "OK"

# --- 2. Parameters ------------------------------------------------
echo; cyan "=== [2/8] Installation details ==="
INSTALL_DIR=$(ask "Install folder (e.g. ~/apps/acmebooks): ")
INSTALL_DIR="${INSTALL_DIR/#\~/$HOME}"
APP_NAME=$(ask    "App short name (lowercase, no spaces, e.g. acme): ")
WEBPORT=$(ask     "Web port [8080]: "); WEBPORT=${WEBPORT:-8080}
APIPORT=$(ask     "API port [4000]: "); APIPORT=${APIPORT:-4000}
DBPORT=$(ask      "DB  port [5432]: "); DBPORT=${DBPORT:-5432}

echo; cyan "=== [3/8] Company identity ==="
COMPANY_NAME=$(ask "Company legal name: ")
COMPANY_NUIT=$(ask "NUIT (Mozambique tax number): ")
COMPANY_ADDR=$(ask "Street address (city, Mozambique): ")
COMPANY_TEL=$(ask  "Telephone: ")

echo; cyan "=== [4/8] Admin users ==="
ADMIN1_EMAIL=$(ask  "Admin #1 email: ")
ADMIN1_PASS=$(askp  "Admin #1 password: ")
ADMIN1_NAME=$(ask   "Admin #1 display name: ")
ADMIN2_EMAIL=$(ask  "Admin #2 email: ")
ADMIN2_PASS=$(askp  "Admin #2 password: ")
ADMIN2_NAME=$(ask   "Admin #2 display name: ")

LOAD_DEMO=$(ask "Load demo data? [Y/n]: "); LOAD_DEMO=${LOAD_DEMO:-Y}
REPO_URL=${LANACC_REPO_URL:-$(ask "GitHub repo URL: ")}

echo
echo "Folder=$INSTALL_DIR  app=$APP_NAME  ports=$WEBPORT/$APIPORT/$DBPORT"
echo "Company=$COMPANY_NAME  NUIT=$COMPANY_NUIT  Tel=$COMPANY_TEL"
read -rp "Proceed? [Y/n]: " OK; [[ "$OK" =~ ^[Nn] ]] && exit 0

# --- 5. Clone -----------------------------------------------------
echo; cyan "=== [5/8] Cloning branch v5 ==="
mkdir -p "$INSTALL_DIR"
git clone --branch v5 --single-branch "$REPO_URL" "$INSTALL_DIR/_src"
shopt -s dotglob
mv "$INSTALL_DIR"/_src/* "$INSTALL_DIR"/
rmdir "$INSTALL_DIR/_src"
cd "$INSTALL_DIR"

# --- 6. Configuration --------------------------------------------
echo; cyan "=== [6/8] Generating configuration ==="
PG_PWD=$(openssl rand -base64 24)
JWT_SEC=$(openssl rand -base64 32)
AT_KEY=$(openssl rand -base64 32)

cat > .env.local <<EOF
# Auto-generated - DO NOT COMMIT
COMPANY_NAME=$APP_NAME
POSTGRES_DB=${APP_NAME}_db
POSTGRES_USER=postgres
POSTGRES_PASSWORD=$PG_PWD
JWT_SECRET=$JWT_SEC
AT_SIGNING_KEY=$AT_KEY
ADMIN_SIGNUP_PIN=
SUPABASE_SERVICE_ROLE_KEY=
WEB_PORT=$WEBPORT
API_PORT=$APIPORT
DB_PORT=$DBPORT
EOF

cat > docker-compose.override.yml <<EOF
services:
  db:
    container_name: ${APP_NAME}-db
    environment:
      POSTGRES_DB: ${APP_NAME}_db
    ports:
      - "${DBPORT}:5432"
    volumes:
      - ${APP_NAME}-pgdata:/var/lib/postgresql/data
      - ./db/init:/docker-entrypoint-initdb.d
  api:
    container_name: ${APP_NAME}-api
    environment:
      - DATABASE_URL=postgres://postgres:${PG_PWD}@db:5432/${APP_NAME}_db
      - COMPANY_NAME=${COMPANY_NAME}
      - COMPANY_NUIT=${COMPANY_NUIT}
      - COMPANY_ADDRESS=${COMPANY_ADDR}
    ports:
      - "${APIPORT}:4000"
  web:
    container_name: ${APP_NAME}-web
    ports:
      - "${WEBPORT}:8080"
volumes:
  ${APP_NAME}-pgdata:
    name: ${APP_NAME}-pgdata
EOF

# --- 7. Build & start --------------------------------------------
echo; cyan "=== [7/8] Building and starting containers ==="
docker compose --env-file .env.local up -d --build

echo "Waiting for database..."
for i in $(seq 1 60); do
  if docker exec "${APP_NAME}-db" pg_isready -U postgres -d "${APP_NAME}_db" >/dev/null 2>&1; then
    green "DB ready"; break
  fi
  sleep 2
done

# --- 8. Seed admins + identity -----------------------------------
echo; cyan "=== [8/8] Seeding admins and company identity ==="
H1=$(docker exec "${APP_NAME}-api" node -e "console.log(require('bcryptjs').hashSync(process.argv[1],10))" "$ADMIN1_PASS")
H2=$(docker exec "${APP_NAME}-api" node -e "console.log(require('bcryptjs').hashSync(process.argv[1],10))" "$ADMIN2_PASS")

cat > /tmp/install_seed.sql <<EOF
CREATE SCHEMA IF NOT EXISTS auth;
CREATE TABLE IF NOT EXISTS auth.users (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  email text UNIQUE NOT NULL,
  password_hash text NOT NULL,
  display_name text,
  created_at timestamptz DEFAULT now()
);

INSERT INTO auth.users (email, password_hash, display_name)
VALUES ('$ADMIN1_EMAIL', '$H1', '$ADMIN1_NAME')
ON CONFLICT (email) DO UPDATE SET password_hash = EXCLUDED.password_hash, display_name = EXCLUDED.display_name;

INSERT INTO auth.users (email, password_hash, display_name)
VALUES ('$ADMIN2_EMAIL', '$H2', '$ADMIN2_NAME')
ON CONFLICT (email) DO UPDATE SET password_hash = EXCLUDED.password_hash, display_name = EXCLUDED.display_name;

INSERT INTO public.user_roles (user_id, role)
SELECT id, 'admin'::app_role FROM auth.users
WHERE email IN ('$ADMIN1_EMAIL', '$ADMIN2_EMAIL')
ON CONFLICT (user_id, role) DO NOTHING;

UPDATE public.company_settings
SET name = '$COMPANY_NAME',
    nuit = NULLIF('$COMPANY_NUIT', ''),
    address = NULLIF('$COMPANY_ADDR', ''),
    telephone = NULLIF('$COMPANY_TEL', '');
EOF

docker cp /tmp/install_seed.sql "${APP_NAME}-db":/tmp/install_seed.sql
docker exec "${APP_NAME}-db" psql -U postgres -d "${APP_NAME}_db" -v ON_ERROR_STOP=1 -f /tmp/install_seed.sql
rm -f /tmp/install_seed.sql

if [[ "$LOAD_DEMO" =~ ^[Yy] ]] && [[ -f db/seed/demo_data.sql ]]; then
  echo "Loading demo data..."
  docker cp db/seed/demo_data.sql "${APP_NAME}-db":/tmp/demo_data.sql
  docker exec "${APP_NAME}-db" psql -U postgres -d "${APP_NAME}_db" -f /tmp/demo_data.sql || true
fi

echo
green "============================================================"
green "  INSTALL COMPLETE - $COMPANY_NAME"
green "============================================================"
echo "  Open: http://localhost:$WEBPORT"
echo "  Sign in: $ADMIN1_EMAIL  /  $ADMIN2_EMAIL"
echo "  Folder:  $INSTALL_DIR"
echo "  Stop:    cd $INSTALL_DIR && docker compose stop"
echo "  Start:   cd $INSTALL_DIR && docker compose --env-file .env.local up -d"
green "============================================================"
