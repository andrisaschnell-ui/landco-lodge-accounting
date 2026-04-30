# RELEASE 4 — Inventory, Assets, Banking & Workflow

## What's included

| Module | Tables / functions | UI page |
|---|---|---|
| **Fixed Assets** | `fixed_assets`, `depreciation_schedule`, `fn_generate_depreciation_schedule()`, `fn_post_depreciation_month()` | `/accounting/fixed-assets` |
| **Inventory (WAC)** | `inventory_items`, `inventory_movements` (auto-posts JE on insert) | `/accounting/inventory` |
| **Bank Reconciliation** | `bank_reconciliations`, `bank_transactions.reconciled` | `/accounting/bank-reconciliation` |
| **FX Revaluation** | `fx_revaluations` | `/accounting/fx-revaluation` |
| **Document attachments + OCR** | `document_attachments`, `attachments` storage bucket, `ocr-attachment` edge function | `<AttachmentManager>` component |
| **Approval workflow** | `expense_transactions.approval_status`, `fn_approve_expense()`, `fn_reject_expense()`, `company_settings.approval_threshold_mzn` (default 50,000 MZN) | `/accounting/approvals` |
| **Audit log** | `audit_log` table, `fn_audit_row()` triggers on 23 financial tables, `fn_audit_event()` for app-level events | `/accounting/audit-log` (admin only) |

## How auto-depreciation works
1. Create an asset with cost, salvage, useful life (months), and PGC account codes.
2. The schedule is auto-generated (straight-line) on save.
3. Each month-end, click "Post depreciation" → all unposted lines for that month are posted as balanced JEs (debit expense, credit accumulated depreciation).

## How inventory WAC works
- **In** movement: `new_avg = (old_qty * old_avg + new_qty * new_cost) / (old_qty + new_qty)`. Posts: Dr Inventory / Cr Cash.
- **Out** movement: uses current `avg_cost`, `avg_cost` unchanged. Posts: Dr COGS / Cr Inventory.
- All maintained by trigger `trg_inventory_movement_post`.

## How approval works
- Expenses with `amount_mzn >= company_settings.approval_threshold_mzn` (default **50,000 MZN**) are inserted with `approval_status = 'pending'` and **do not auto-post**.
- An admin opens `/accounting/approvals`, clicks Approve → `fn_approve_expense()` posts the JE and marks the expense approved.
- Rejecting just sets `approval_status = 'rejected'` — no JE created.

## How the audit log works
- A generic `fn_audit_row()` AFTER trigger is attached to 23 financial tables.
- Each INSERT/UPDATE/DELETE writes one row to `audit_log` with: who (`actor_id`, `actor_email`), when, table, row id, and full `old_data`/`new_data` JSON snapshots.
- For non-DB events (login, logout, sensitive read), call `supabase.rpc('fn_audit_event', { _action, _table_name, _row_id, _details })` from app code.
- **Only admins can read** `audit_log` (RLS).
- The table grows fast — plan to archive monthly after a year.

### Local mode caveat
In Cloud mode the trigger uses `auth.uid()` (Supabase JWT). In local mode, set the user id at the start of each request:
```js
await client.query(`SELECT set_config('app.user_id', $1, true)`, [req.user.sub]);
```
You can wire this into `api/server.js` later — for now local writes log with `actor_id = NULL`.

## OCR
- Files uploaded via `<AttachmentManager>` go to the private `attachments` Supabase Storage bucket.
- The `ocr-attachment` edge function downloads the file, sends it to Lovable AI Gateway (`google/gemini-2.5-flash`, multimodal), and saves the extracted text in `document_attachments.ocr_text`.
- Re-run with the ✨ button if needed. PDFs and images supported; other types are marked `skipped`.

## Local install

```bash
docker exec -i lanacc-postgres psql -U landco -d landco < db/migrations/2026_release4_workflow.sql
```

## What was deliberately deferred
- **2FA for admins** — per project decision, deferred to a later release. When ready, enable with Supabase native MFA (TOTP) for cloud and `otplib` + a `user_mfa` table for local.
- **Per-user OAuth, multi-step approval, asset disposal flow, inventory transfers between properties, bank statement import to feed reconciliation** — easy follow-ons.
