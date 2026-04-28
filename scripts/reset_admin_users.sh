#!/usr/bin/env bash
# ============================================================
#  LANACC - Reset / recreate the two admin users (Mac / Linux)
# ============================================================
set -e

API=lanacc-api
DB=lanacc-db
DBNAME=landco_v2_db
DBUSER=postgres

docker ps --format '{{.Names}}' | grep -q "^${API}$" || { echo "[ERROR] $API not running"; exit 1; }
docker ps --format '{{.Names}}' | grep -q "^${DB}$"  || { echo "[ERROR] $DB not running";  exit 1; }

HASH1=$(docker exec "$API" node -e "console.log(require('bcryptjs').hashSync('Abcd7654\$',10))")
HASH2=$(docker exec "$API" node -e "console.log(require('bcryptjs').hashSync('Abcd7654#',10))")

SQL=$(cat <<EOF
CREATE SCHEMA IF NOT EXISTS auth;
CREATE TABLE IF NOT EXISTS auth.users (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  email text UNIQUE NOT NULL,
  password_hash text NOT NULL,
  display_name text,
  created_at timestamptz DEFAULT now()
);

INSERT INTO auth.users (email, password_hash, display_name)
VALUES ('cwschnell@gmail.com', '${HASH1}', 'CW Schnell')
ON CONFLICT (email) DO UPDATE SET password_hash = EXCLUDED.password_hash;

INSERT INTO auth.users (email, password_hash, display_name)
VALUES ('andrisa.schnell@gmail.com', '${HASH2}', 'Andrisa Schnell')
ON CONFLICT (email) DO UPDATE SET password_hash = EXCLUDED.password_hash;

INSERT INTO public.user_roles (user_id, role)
SELECT id, 'admin'::app_role FROM auth.users
WHERE email IN ('cwschnell@gmail.com', 'andrisa.schnell@gmail.com')
ON CONFLICT DO NOTHING;

SELECT u.email, u.display_name, r.role
FROM auth.users u LEFT JOIN public.user_roles r ON r.user_id = u.id
WHERE u.email IN ('cwschnell@gmail.com', 'andrisa.schnell@gmail.com');
EOF
)

echo "$SQL" | docker exec -i "$DB" psql -U "$DBUSER" -d "$DBNAME" -v ON_ERROR_STOP=1
echo
echo "Done. Log in at http://localhost:8080/auth"
