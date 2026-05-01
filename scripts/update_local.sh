#!/usr/bin/env bash
# ============================================================
#  LANACC - Update local Docker stack from GitHub branch v5
#  Mac / Linux equivalent of update_local.bat
# ============================================================
set -u
cd "$(dirname "$0")/.."

LOG="update_local.log"
: > "$LOG"
log()  { echo "$*"   | tee -a "$LOG"; }
fail() { echo "[ERROR] $*" | tee -a "$LOG"; exit 1; }

log "============================================================"
log "  LANACC LOCAL UPDATE  -  $(date)"
log "============================================================"

command -v docker >/dev/null || fail "Docker not installed."
command -v git    >/dev/null || fail "Git not installed."
docker info >/dev/null 2>&1  || fail "Docker daemon not running."
[ -f .env.local ]            || fail ".env.local missing - copy from .env.example."

# 1. Pre-update backup
log ""; log "--- Step 1/7: Pre-update database backup ---"
if docker ps --format '{{.Names}}' | grep -q '^lanacc-db$'; then
  mkdir -p db/backups
  BKP="db/backups/pre_update_$(date +%Y%m%d_%H%M%S).sql"
  if docker exec lanacc-db pg_dump -U postgres -d landco_v2_db --clean --if-exists > "$BKP" 2>>"$LOG"; then
    log "Backup OK: $BKP"
  else
    log "[WARN] Backup failed - continuing."
  fi
else
  log "lanacc-db not running - skipping backup."
fi

# 2. Pull v5
log ""; log "--- Step 2/7: git fetch + checkout v5 + pull ---"
git fetch origin                  >>"$LOG" 2>&1 || fail "git fetch failed"
git checkout v5                   >>"$LOG" 2>&1 || fail "git checkout v5 failed - commit/stash local changes"
OLD_SHA=$(git rev-parse HEAD)
git pull --ff-only origin v5      >>"$LOG" 2>&1 || fail "git pull not fast-forward"
NEW_SHA=$(git rev-parse HEAD)
log "Updated: $OLD_SHA -> $NEW_SHA"

# 3. New migrations
log ""; log "--- Step 3/7: Detecting new SQL migrations ---"
mapfile -t NEW_MIGRATIONS < <(git diff --name-only "$OLD_SHA" "$NEW_SHA" -- 'supabase/migrations/*.sql' 'db/migrations/*.sql' 2>/dev/null)
if [ ${#NEW_MIGRATIONS[@]} -eq 0 ]; then
  log "  (no new migration files)"
else
  for f in "${NEW_MIGRATIONS[@]}"; do log "  + $f"; done
fi

# 4. Rebuild
log ""; log "--- Step 4/7: docker compose up -d --build ---"
docker compose --env-file .env.local up -d --build >>"$LOG" 2>&1 || fail "docker compose build failed"

# 5. Wait for DB
log ""; log "--- Step 5/7: Waiting for Postgres ---"
for i in $(seq 1 30); do
  if docker exec lanacc-db pg_isready -U postgres -d landco_v2_db >/dev/null 2>&1; then
    log "Postgres ready."; break
  fi
  sleep 2
  [ "$i" = "30" ] && fail "Postgres not ready in 60s"
done

# 6. Apply migrations
log ""; log "--- Step 6/7: Applying new migrations ---"
for f in "${NEW_MIGRATIONS[@]}"; do
  [ -f "$f" ] || continue
  log "Running $f ..."
  if docker exec -i lanacc-db psql -U postgres -d landco_v2_db -v ON_ERROR_STOP=1 < "$f" >>"$LOG" 2>&1; then
    log "  OK"
  else
    log "  [WARN] failed/already applied"
  fi
done

# 7. Smoke test
log ""; log "--- Step 7/7: Smoke test ---"
OK=1
check() { if curl -fs -o /dev/null "$1"; then log "  [OK]  $2"; else log "  [FAIL] $2"; OK=0; fi; }
check http://localhost:4000/health           "API  /health"
check http://localhost:4000/api/sync/status  "API  /api/sync/status"
check http://localhost:8080                  "Web  http://localhost:8080"
if docker exec lanacc-db psql -U postgres -d landco_v2_db -tAc \
   "select count(*) from information_schema.tables where table_schema='public';" >/dev/null 2>&1; then
  log "  [OK]  DB   public schema reachable"
else
  log "  [FAIL] DB query failed"; OK=0
fi

log ""
log "============================================================"
if [ "$OK" = "1" ]; then
  log "  UPDATE SUCCESSFUL  - open http://localhost:8080"
else
  log "  UPDATE COMPLETED WITH WARNINGS - see $LOG"
  log "  Rollback: scripts/restore.bat <pre_update_*.sql>"
fi
log "============================================================"
