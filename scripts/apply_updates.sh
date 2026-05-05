#!/usr/bin/env bash
# ============================================================
# LANACC — Apply Releases 1, 2, 4 to local Postgres (Docker)
# Run from the project root.  Usage:  bash scripts/apply_updates.sh
# ============================================================
set -euo pipefail

DB_CONTAINER="lanacc-db"
DB_USER="postgres"
DB_NAME="landco_v2_db"
MIG_DIR="db/migrations"
BACKUP_DIR="db/backups"

echo
echo "=== LANACC schema update — Releases 1, 2, 4 ==="
echo

if ! docker ps --format '{{.Names}}' | grep -q "^${DB_CONTAINER}$"; then
  echo "[ERROR] Container ${DB_CONTAINER} is not running."
  echo "        Start the stack first: docker compose --env-file .env.local up -d"
  exit 1
fi

mkdir -p "${BACKUP_DIR}"
STAMP="$(date +%Y%m%d_%H%M%S)"
BKP="${BACKUP_DIR}/pre_update_${STAMP}.sql"

echo "[1/5] Taking safety backup -> ${BKP}"
docker exec "${DB_CONTAINER}" pg_dump -U "${DB_USER}" -d "${DB_NAME}" --clean --if-exists > "${BKP}"

apply() {
  local label="$1" file="$2"
  echo
  echo "[${label}] Applying $(basename "${file}")"
  if ! docker exec -i "${DB_CONTAINER}" psql -U "${DB_USER}" -d "${DB_NAME}" -v ON_ERROR_STOP=1 < "${file}"; then
    echo "[ERROR] Migration failed. Restoring from ${BKP} ..."
    docker exec -i "${DB_CONTAINER}" psql -U "${DB_USER}" -d "${DB_NAME}" < "${BKP}"
    echo "Rolled back. Investigate the error above and re-run when fixed."
    exit 1
  fi
}

apply "2/5" "${MIG_DIR}/2026_release1_double_entry.sql"
apply "3/5" "${MIG_DIR}/2026_release2_statements.sql"
apply "4/5" "${MIG_DIR}/2026_release4_workflow.sql"

echo
echo "[5/5] Verifying new tables ..."
docker exec "${DB_CONTAINER}" psql -U "${DB_USER}" -d "${DB_NAME}" -c "
  SELECT table_name FROM information_schema.tables
  WHERE table_schema='public' AND table_name IN (
    'journal_entries','journal_lines','accounting_periods','budgets',
    'fixed_assets','depreciation_schedule','inventory_items','inventory_movements',
    'bank_reconciliations','fx_revaluations','document_attachments','audit_log',
    'company_settings')
  ORDER BY table_name;"

echo
echo "Restarting lanacc-api ..."
docker restart lanacc-api >/dev/null

echo
echo "=== DONE. Local schema is now aligned with Cloud (Releases 1, 2, 4). ==="
echo "Backup kept at: ${BKP}"
echo
echo "Next step: open the app -> Sync -> 'Pull Cloud -> Local' to bring down"
echo "any rows present in Cloud but missing locally."
