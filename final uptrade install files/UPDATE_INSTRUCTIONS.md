# LANACC — Update Local Docker Stack to Releases 1, 2 & 4

This bundle brings an existing local install up to the same schema as
Lovable Cloud so the **Sync** button (Push / Pull) works for every new
table introduced by Releases 1, 2 and 4.

## What it changes

| Release | Adds |
|---|---|
| **1** | `journal_entries`, `journal_lines`, `accounting_periods`, auto-post triggers, suspense account 2999, period-lock guard |
| **2** | `budgets`, plus aging columns on `invoices` + `supplier_invoices` (`due_date`, `paid_amount`, `status`) |
| **4** | `fixed_assets`, `depreciation_schedule`, `inventory_items`, `inventory_movements`, `bank_reconciliations`, `fx_revaluations`, `document_attachments`, `audit_log`, `company_settings`, approval columns on expenses + supplier invoices, audit triggers on 23 tables |

All scripts use `CREATE TABLE IF NOT EXISTS` / `DROP TRIGGER IF EXISTS`
so they are **safe to re-run**.

---

## Files in this bundle

```
UPDATE_INSTRUCTIONS.md          ← this file
migrations/
  2026_release1_double_entry.sql
  2026_release2_statements.sql
  2026_release4_workflow.sql
scripts/
  apply_updates.bat             ← Windows one-shot
  apply_updates.sh              ← Mac/Linux one-shot
```

---

## How to install

### 1. Drop the files into your repo

From the bundle root, copy:

- `migrations/*.sql`  →  `<repo>/db/migrations/`
- `scripts/apply_updates.bat` and `apply_updates.sh`  →  `<repo>/scripts/`

(If you pulled `v5` from GitHub recently you already have the migrations —
this bundle is for machines that are behind.)

### 2. Make sure the stack is running

```bat
scripts\start.bat
```

(or `docker compose --env-file .env.local up -d` on Mac/Linux)

### 3. Run the updater

**Windows (from project root):**
```bat
scripts\apply_updates.bat
```

**Mac / Linux:**
```bash
bash scripts/apply_updates.sh
```

The script will:

1. Take a **timestamped safety backup** to `db/backups/pre_update_*.sql`.
2. Apply Release 1, then 2, then 4 in order, each inside `ON_ERROR_STOP=1`.
3. **Auto-rollback** to the safety backup if any migration fails.
4. List the new tables to confirm they exist.
5. Restart `lanacc-api` so cached connections see the new columns.

Expected runtime: 10–30 seconds.

### 4. Pull the Cloud rows that are new

Open the app → **Sync** button → **Pull Cloud → Local**.

This copies any rows present in Cloud but missing locally
(Cloud is the source of truth for new-feature data such as
`accounts`, `accounting_periods`, `company_settings`).

> Conflict policy is unchanged: **Local wins** when the same `id`
> exists in both. Pull is purely additive for IDs you do not have.

### 5. Done

Verify in the app:

- **Trial Balance** loads with no error.
- **Financial Statements → P&L** loads.
- **Approvals** menu appears in the sidebar (admin only).
- **Audit Log** menu appears.

---

## Troubleshooting

| Symptom | Fix |
|---|---|
| `Container lanacc-db is not running` | Run `scripts\start.bat` first. |
| Migration aborts with `relation "..." already exists` | Bundle handled this — re-run the script; it is idempotent. If it still fails, paste the error and the rollback already restored your DB. |
| Sync still shows 0 rows after the update | Service-role key not loaded. See `FIX_SYNC.md` in the repo. |
| Need to roll back manually | `docker exec -i lanacc-db psql -U postgres -d landco_v2_db < db\backups\pre_update_<stamp>.sql` |

---

## What the updater does NOT do

- It does **not** edit `.env.local`, `docker-compose.yml`, or any code.
- It does **not** push anything to Cloud. Cloud already has these
  schemas (Lovable applied them via the migration tool).
- It does **not** seed sample data — only the schema is touched.

After this runs, the **Sync** button can move data both ways for every
table the new features use.
