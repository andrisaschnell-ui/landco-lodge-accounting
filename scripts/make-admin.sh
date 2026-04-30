#!/usr/bin/env bash
# ============================================================
#  LANACC - make-admin (Mac / Linux)
#  Create or promote a local admin user via the running API.
# ============================================================
set -e

API=lanacc-api
docker ps --format '{{.Names}}' | grep -q "^${API}$" || {
  echo "[ERROR] $API not running. Start with: docker compose --env-file .env.local up -d"
  exit 1
}

echo "=== LANACC make-admin ==="
read -rp "Email:    " EMAIL
read -rsp "Password: " PASSWORD; echo
read -rsp "Admin PIN: " PIN; echo

[ -z "$EMAIL" ] && { echo "[ERROR] email required"; exit 1; }
[ -z "$PASSWORD" ] && { echo "[ERROR] password required"; exit 1; }
[ -z "$PIN" ] && { echo "[ERROR] PIN required"; exit 1; }

PAYLOAD=$(printf '{"email":"%s","password":"%s","pin":"%s"}' "$EMAIL" "$PASSWORD" "$PIN")

echo "$PAYLOAD" | docker exec -i "$API" sh -c \
  "cat > /tmp/p.json && wget -qO- --header='Content-Type: application/json' --post-file=/tmp/p.json http://localhost:4000/auth/signup-admin"

echo
echo "Done. Log in at http://localhost:8080/auth as $EMAIL"
