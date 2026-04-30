# Release 2 — Statements & Analysis

This release builds **financial reporting** on top of the Release 1 double-entry engine.

## What's new

### 1. Financial Statements page (`/accounting/statements`)
Three statements in one tabbed view, each with consolidated and per-property modes plus optional prior-year comparison:

- **Profit & Loss** — Revenues, Expenses, Net Income.
- **Balance Sheet** — Assets vs Liabilities + Equity (period net income flows into equity automatically).
- **Cash Flow (indirect)** — Net Income + working-capital changes → Operating cash; cash account movement reported separately.

Filters:
- Single month / Year-to-date / Full year
- Property: Consolidated or any single property
- Compare prior year toggle

Both **PDF and Excel** export buttons on every tab.

### 2. Budgets page (`/accounting/budgets`)
- **Budget Entry** — full annual matrix (12 months × all revenue/expense accounts) with bulk-save.
- **Budget vs Actual** — variance, % over/under, MTD or YTD, with PDF/Excel export. Expenses over budget are red, revenues under budget are red.

### 3. Customer & Supplier Ledgers (`/accounting/party-ledgers`)
- Aging buckets: Current / 1-30 / 31-60 / 61-90 / 90+ days.
- Click any party row to drill into individual outstanding invoices.
- PDF/Excel export of aging summary.

## Database changes

One new table + column extensions only — **no triggers added or modified**.

```sql
-- New table
CREATE TABLE public.budgets (
  account_id uuid REFERENCES accounts(id),
  year int, month int, amount numeric,
  property_id uuid REFERENCES properties(id) NULL, ...
);

-- Aging support
ALTER TABLE supplier_invoices ADD COLUMN due_date date,
                              ADD COLUMN paid_amount numeric DEFAULT 0,
                              ADD COLUMN status text DEFAULT 'open';
ALTER TABLE invoices          ADD COLUMN paid_amount numeric DEFAULT 0;
```

RLS: admins manage `budgets`, all authenticated users can read.

## Local install — apply the migration

After pulling the latest code on a local machine:

```bash
docker exec -i lanacc-postgres psql -U landco -d landco \
  < db/migrations/2026_release2_statements.sql
```

No backfill script needed. As soon as you record a `due_date` on supplier/customer invoices and a `paid_amount` when payments come in, the aging report fills itself.

## How statements derive their numbers

All three statements are **read-only aggregations of `journal_lines`** for posted entries in the chosen date range. Because Release 1 auto-posts everything to the journal, the statements are always in sync with the underlying transactions — no separate "close the books" step needed beyond locking the period.

- P&L revenue = sum(credit − debit) for accounts of type `revenue`
- P&L expense = sum(debit − credit) for accounts of type `expense`
- Balance Sheet asset = sum(debit − credit), liability/equity = sum(credit − debit)
- Cash Flow operating = Net Income + Σ(Δ liabilities) − Σ(Δ non-cash assets)

## Files added/changed

**Created**
- `src/pages/FinancialStatements.tsx`
- `src/pages/Budgets.tsx`
- `src/pages/PartyLedgers.tsx`
- `src/lib/statements.ts`
- `src/lib/exportUtils.ts`
- `db/migrations/2026_release2_statements.sql`

**Edited**
- `src/App.tsx` — three new routes
- `src/components/AppSidebar.tsx` — three new accounting menu items
- `db/init/01_schema_full.sql` — appended Release 2 objects for fresh installs
