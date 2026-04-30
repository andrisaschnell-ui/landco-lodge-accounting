# LANACC — Release 1: Double-Entry Engine Activated

## What changed

Release 1 turns LANACC into a **real double-entry accounting system**. Every income, expense, bank, petty-cash and payroll entry now automatically produces a balanced journal entry in the General Ledger, and you can produce a Trial Balance at any time.

---

## 1. Database changes

### New columns
- `journal_entries.source_table` (text) — e.g. `expense_transactions`
- `journal_entries.source_id` (uuid) — id of the source row that produced this entry

### New triggers
- **`trg_journal_lines_balance_check`** — every journal entry must have `sum(debit) = sum(credit)` (rounded to 0.01 MZN). Unbalanced inserts/updates/deletes are rejected.
- **`trg_journal_entries_period_lock`** — writes to dates inside a closed `accounting_periods` row are rejected for everyone (admins included). Reopen the period from Settings → Periods first.
- **`trg_auto_post_income / _expense / _bank / _petty_cash / _payroll`** — `BEFORE INSERT` triggers that automatically create a balanced JE the moment a source row is added, using the PGC mapping on `expense_categories.pgc_account_code` and `bank_accounts.pgc_account_code`. Unmapped accounts fall through to suspense **2999**.

### Cloud
Already applied via Lovable Cloud.

### Local Postgres (existing installs)
```bash
docker exec -i lanacc-postgres psql -U landco -d landco \
  < db/migrations/2026_release1_double_entry.sql
```
Fresh installs get everything from `db/init/01_schema_full.sql` automatically.

---

## 2. Backfill existing rows

Any rows added **before** the auto-post triggers existed don't yet have a journal entry. Run the backfill script once:

### Cloud
```bash
SUPABASE_DB_URL='postgres://...' node scripts/backfill-journal.mjs
```
Get the `SUPABASE_DB_URL` value from Lovable Cloud secrets.

### Local
```bash
docker exec -it lanacc-api node /app/scripts/backfill-journal.mjs
```

The script is **idempotent** — only rows with `journal_entry_id IS NULL` are touched. Failed rows usually mean an unmapped PGC code; check Suspense Review and finish the mapping in Account Mapping, then re-run.

---

## 3. New UI pages

| Page | Path | Purpose |
|---|---|---|
| Account Ledger | `/accounting/ledger` | Drill-down: pick any account, see every posted line with running balance |
| Trial Balance | `/accounting/trial-balance` | Sum of debits / credits / balance per account, with "Balanced ✓" banner |
| Periods | `/accounting/periods` | Open / close monthly periods (admin) |
| Chart of Accounts | `/accounting/accounts` | Now editable — admins can add new PGC accounts |

The legacy "Post all to Journal" button on `/accounting/journal` becomes a no-op once backfill is done — auto-posting handles new rows.

---

## 4. Daily workflow

1. User enters an income/expense/bank/petty-cash/payroll row as usual.
2. The DB trigger creates the matching journal entry in the same transaction. If the trigger fails (e.g. `accounts` is empty, or the period is closed) the original insert also fails — the books stay in lock-step with source data.
3. Open **Trial Balance** any time — debits and credits should match. If they don't, that means a manual journal entry is unbalanced (the balance trigger should make this impossible, but the page surfaces it for safety).
4. At month end: review Suspense (account 2999), reclassify anything mis-mapped, then **Periods → Close** for the month.

---

## 5. What's NOT in Release 1 (planned for Release 2)

- Manual multi-line journal entry form (UI). For now, manual JEs go via SQL or imports.
- Bank reconciliation workflow.
- Statutory Mozambique tax exports (SAF-T MZ, IVA returns).
- Fixed-asset register with auto-depreciation.

See `professional_accounting_roadmap.docx` for the full roadmap.
