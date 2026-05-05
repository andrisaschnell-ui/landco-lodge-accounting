# LANDCO LODGE ACCOUNTING — CODEX IMPLEMENTATION SPEC

**Version:** 1.1 | **Date:** May 2026 | **Stack:** React 18 / TypeScript / Vite / Node.js / Express / PostgreSQL 17 / Docker Desktop (Windows)

\---

## PROJECT CONTEXT

You are implementing repairs and new features for the **LANACC** application — the internal accounting system for Landco Lodge Lda, Vilankulo, Mozambique.

**Project root:** `C:\\Users\\Andrisa\\Documents\\Projects\\Landco`

**Start every session with:**

```
docker compose --env-file .env.local up -d --build
docker exec -it lanacc-db psql -U postgres -d landco\_v2\_db
```

**Do not touch:**

* `.env.local` (secrets)
* `src/integrations/supabase/types.ts` (auto-generated)
* Any file in `db/seed/` unless explicitly instructed

\---

## ARCHITECTURE REFERENCE

|Layer|Tech|Container|Port|
|-|-|-|-|
|Frontend|React 18 + Vite + TypeScript + Tailwind + shadcn/ui|`lanacc-web`|8080|
|API|Node.js + Express|`lanacc-api`|4000|
|Database|PostgreSQL 17 (Alpine)|`lanacc-db`|5432|
|DB Admin|pgAdmin 4|`lanacc-pgadmin`|5050|

**Key files:**

```
src/App.tsx                        — All client routes (add new routes here)
src/components/AppSidebar.tsx      — Left nav (add menu items here)
src/pages/                         — One file per route
src/lib/parsers/                   — Excel import parsers
src/lib/importService.ts           — DB insertion logic for all imports
src/lib/helpContent.ts             — Help popup text (EN + PT required)
src/components/HelpPopover.tsx     — Help popup component
api/server.js                      — Express entry point
api/routes/                        — Route handlers (one per domain)
db/migrations/                     — Incremental SQL migrations
```

\---

## SPREADSHEET DATA PIPELINE

The application ingests data from Excel spreadsheets stored in `Landco\_Accounts\_2026/`. Each monthly folder contains:

|File Pattern|Parser|Target Table|
|-|-|-|
|`NN MONTH END 2026.xlsx` → INCOME tab|`landcoIncomeParser.ts`|`landco\_income`|
|`NN MONTH END 2026.xlsx` → EXPENSES tab|`expenseParser.ts`|`expense\_transactions`|
|`NN Petty Cash 2026.xlsx`|`pettyCashParser.ts`|`petty\_cash\_transactions`|
|`NN BDO Bank Control 2026.xlsx`|`bdoBankParser.ts`|`bank\_transactions`|
|`NN Salary sheet for Landco.xlsx`|`salaryParser.ts`|`salary\_runs`, `salary\_lines`|
|`BIM salary transfer NN.xls`|`bimSalaryParser.ts`|`bim\_salary\_transfers`|

**Parser pattern** (all parsers must follow this interface):

```typescript
// src/lib/parsers/\[name]Parser.ts
import \* as XLSX from 'xlsx';

export interface ParseResult<T> {
  records: T\[];
  errors: string\[];
  warnings: string\[];
  rowCount: number;
}

export async function parse\[Name](
  file: File,
  month: number,
  year: number
): Promise<ParseResult<\[TableType]>> {
  const buffer = await file.arrayBuffer();
  const workbook = XLSX.read(buffer, { type: 'array', cellDates: true });
  // ...
}
```

**Import deduplication check** (run before every import):

```typescript
const existing = await api.get(`/import-log?file\_type=${fileType}\&month=${month}\&year=${year}`);
if (existing.data.length > 0) {
  // Show modal: "Already imported. Clear and re-import / Append / Cancel"
}
```

\---

## PHASE 1 — CRITICAL DATA INTEGRITY (Start here — blocks everything else)

### Task 1.1 — Fix Backend Connection Mode

**Problem:** Frontend calls Supabase Cloud (`neakxehuonsrlvjrxhnd.supabase.co`); API calls local PostgreSQL. Data bifurcation.

**Decision:** Use **local PostgreSQL only**. Remove all Supabase `.from()` queries from React components.

**Steps:**

1. Audit all files in `src/` for `supabase.from(` — list every occurrence
2. For each occurrence, replace with a `fetch` call to the local Express API:

```typescript
   // Before (Supabase)
   const { data } = await supabase.from('exchange\_rates').select('\*');
   
   // After (local API)
   const res = await fetch('http://localhost:4000/api/exchange-rates');
   const data = await res.json();
   ```

3. Add missing API routes in `api/routes/` for any endpoint that doesn't exist yet
4. Verify the switch with:

```bash
   docker exec lanacc-db psql -U postgres -d landco\_v2\_db -c "SELECT COUNT(\*) FROM income\_transactions;"
   ```

5. Keep `src/integrations/supabase/client.ts` in place (used by Auth only) — do not delete

**Success check:** No `supabase.from(` in any non-auth component file.

\---

### Task 1.2 — Run Journal Entry Backfill

```bash
docker exec -it lanacc-api node /app/scripts/backfill-journal.mjs
```

**Verify:**

```sql
SELECT COUNT(\*) FROM journal\_entries;
-- Must equal: (SELECT COUNT(\*) FROM income\_transactions)
--           + (SELECT COUNT(\*) FROM expense\_transactions)
--           + (SELECT COUNT(\*) FROM bank\_transactions)
--           + (SELECT COUNT(\*) FROM petty\_cash\_transactions)

-- Find unmapped PGC codes:
SELECT DISTINCT category\_id FROM expense\_transactions
WHERE journal\_entry\_id IS NULL;
```

Fix any unmapped codes via the Account Mapping page, then re-run the backfill.

\---

### Task 1.3 — Make Exchange Rate Editable

**Migration:**

```sql
-- Verify table exists first:
SELECT column\_name FROM information\_schema.columns
WHERE table\_name = 'exchange\_rates';
-- Expected columns: id, month, year, mzn\_per\_usd, mzn\_per\_zar, created\_at
```

**API route** — add to `api/routes/exchangeRates.js`:

```javascript
// GET /api/exchange-rates?year=2026\&month=5
// POST /api/exchange-rates  { month, year, mzn\_per\_usd, mzn\_per\_zar }
// PUT /api/exchange-rates/:id
// DELETE /api/exchange-rates/:id
```

**Frontend — `src/pages/Dashboard.tsx`:**

* Replace static exchange rate display with a query to `GET /api/exchange-rates?year=currentYear`
* Show most recent rate. Add inline edit button (admin role check)
* On save, call `PUT /api/exchange-rates/:id`

**Frontend — `src/pages/Settings.tsx`:**

* Add an "Exchange Rates" section listing all year/month rows
* Full CRUD: Add, Edit, Delete (admin only)

**Everywhere USD amounts display:** Replace hardcoded constants with:

```typescript
const rate = exchangeRates.find(r => r.month === txMonth \&\& r.year === txYear)?.mzn\_per\_usd ?? 1;
```

\---

### Task 1.4 — Verify Import Data (Jan–Apr 2026)

For each month 1–4, run this verification query set:

```sql
-- Income totals per property
SELECT property\_id, SUM(amount\_mzn) FROM income\_transactions
WHERE month = :m AND year = 2026 GROUP BY property\_id;

-- Expense totals per category
SELECT category\_id, SUM(amount\_mzn) FROM expense\_transactions
WHERE month = :m AND year = 2026 GROUP BY category\_id;

-- Petty cash closing balance
SELECT balance FROM petty\_cash\_transactions
WHERE month = :m AND year = 2026 ORDER BY transaction\_date DESC LIMIT 1;
```

Compare each result to the physical Excel file. Log discrepancies. Fix the relevant parser in `src/lib/parsers/`. Clear and re-import affected months.

**Mark verified:**

```sql
UPDATE import\_log SET notes = 'verified' WHERE month = :m AND year = 2026;
```

\---

## PHASE 2 — REAL INCOME IMPLEMENTATION

### Task 2.1 — Create `landco\_income` Table

**Migration file:** `db/migrations/007\_landco\_income.sql`

```sql
CREATE TABLE IF NOT EXISTS landco\_income (
  id                    UUID PRIMARY KEY DEFAULT gen\_random\_uuid(),
  period\_month          INTEGER NOT NULL CHECK (period\_month BETWEEN 1 AND 12),
  period\_year           INTEGER NOT NULL,
  property\_code         TEXT NOT NULL CHECK (property\_code IN ('H1','H2','H3','H4','Com','Negu')),
  description           TEXT,
  amount\_mzn            NUMERIC(15,2) NOT NULL DEFAULT 0,
  amount\_usd            NUMERIC(15,2) DEFAULT 0,
  exchange\_rate\_used    NUMERIC(10,4),
  amount\_mzn\_equivalent NUMERIC(15,2),
  source                TEXT,            -- 'Cash Deposit' | 'Bank Transfer' | 'USD Black Market'
  deposit\_date          DATE,
  notes                 TEXT,
  journal\_entry\_id      UUID REFERENCES journal\_entries(id),
  created\_at            TIMESTAMPTZ DEFAULT NOW(),
  created\_by            UUID REFERENCES profiles(id)
);

CREATE INDEX idx\_landco\_income\_period ON landco\_income(period\_year, period\_month);
CREATE INDEX idx\_landco\_income\_property ON landco\_income(property\_code);

-- Auto-post journal entry on INSERT
CREATE OR REPLACE FUNCTION trg\_fn\_auto\_post\_landco\_income()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  -- Insert debit (Cash/Bank) + credit (Owner Capital) journal entry
  -- Use account codes from chart\_of\_accounts for property\_code
  -- Populate NEW.journal\_entry\_id with the resulting journal\_entries.id
  RETURN NEW;
END;
$$;

CREATE TRIGGER trg\_auto\_post\_landco\_income
AFTER INSERT ON landco\_income
FOR EACH ROW EXECUTE FUNCTION trg\_fn\_auto\_post\_landco\_income();
```

**Run:**

```bash
docker exec -i lanacc-db psql -U postgres -d landco\_v2\_db < db/migrations/007\_landco\_income.sql
```

\---

### Task 2.2 — Build `landcoIncomeParser.ts`

**File:** `src/lib/parsers/landcoIncomeParser.ts`

The INCOME sheet in each MONTH END file has:

* Row 1: Merged heading row (skip)
* Rows 2+: One deposit event per row

  * Col A: Date
  * Col B: Description
  * Cols C–F: Amounts for H1, H2, H3, H4 (MZN)
  * Col G (optional): USD amount
  * Col H (optional): Source type

```typescript
export async function parseLandcoIncome(
  file: File,
  month: number,
  year: number
): Promise<ParseResult<LandcoIncomeRecord>> {
  const buffer = await file.arrayBuffer();
  const wb = XLSX.read(buffer, { type: 'array', cellDates: true });
  const sheet = wb.Sheets\['INCOME'];
  if (!sheet) throw new Error('INCOME sheet not found');
  
  const rows = XLSX.utils.sheet\_to\_json(sheet, { header: 1, defval: null });
  const records: LandcoIncomeRecord\[] = \[];
  const errors: string\[] = \[];
  
  const propertyColumns: Record<string, number> = { H1: 2, H2: 3, H3: 4, H4: 5 };
  
  for (let i = 1; i < rows.length; i++) {
    const row = rows\[i] as any\[];
    if (!row\[0]) continue; // skip empty rows
    
    for (const \[code, colIdx] of Object.entries(propertyColumns)) {
      const amount = parseFloat(row\[colIdx]);
      if (!isNaN(amount) \&\& amount !== 0) {
        records.push({
          period\_month: month,
          period\_year: year,
          property\_code: code,
          deposit\_date: row\[0],
          description: row\[1] ?? '',
          amount\_mzn: amount,
          amount\_usd: parseFloat(row\[6]) || 0,
          source: row\[7] ?? 'Cash Deposit',
        });
      }
    }
  }
  
  return { records, errors, warnings: \[], rowCount: rows.length - 1 };
}
```

**Register in `src/pages/UploadData.tsx`:**

```typescript
// Add to FILE\_TYPES array:
{ id: 'landco\_income', label: 'Landco Income (Month End — INCOME sheet)', parser: parseLandcoIncome }

// Add case to handleImport switch:
case 'landco\_income':
  await importService.importLandcoIncome(records, month, year);
  break;
```

\---

### Task 2.3 — Create `LandcoIncome.tsx` Page

**File:** `src/pages/LandcoIncome.tsx` | **Route:** `/landco-income`

Page layout:

```
\[Month Selector] \[Year Selector]          \[Add Row Button]
\[Exchange Rate for period: 1 USD = XX MZN]

Table:
| Date | Property | Description | Amount MZN | Amount USD | Ex Rate | MZN Equiv | Source | Notes | \[Edit] \[Delete] |

Footer totals row

Summary cards per property:
| H1 Total | H2 Total | H3 Total | H4 Total |
```

Edit mode: clicking Edit on a row converts it to inline inputs (all fields editable). Save/Cancel buttons appear. On Save, call `PUT /api/landco-income/:id`.

**Add to `src/App.tsx`:**

```tsx
<Route path="/landco-income" element={<LandcoIncome />} />
```

**Add to `src/components/AppSidebar.tsx`:**

```tsx
{ label: 'Landco Income', icon: TrendingUp, href: '/landco-income' }
```

\---

### Task 2.4 — Remove Dummy Invoices from Financial Calculations

**Files to update:**

`src/pages/FinancialStatements.tsx`:

```typescript
// Replace:
const revenue = await fetch('/api/income-transactions/total?...');
// With:
const revenue = await fetch('/api/landco-income/total?month=\&year=');
```

`src/pages/Dashboard.tsx`:

* All income KPI cards → source from `landco\_income`

`src/pages/ShareholderReports.tsx`:

* Per-owner income → `landco\_income` filtered by `property\_code`

`src/pages/Transactions.tsx` (Income tab):

* Keep displaying `income\_transactions` (dummy invoices needed for BDO view)
* Add clear label: **"Official Invoices (BDO Reporting Only)"**

**New PGC account** (add via Account Mapping page or migration):

```sql
INSERT INTO accounts (code, name, type) VALUES ('7100', 'Owner Capital Contributions', 'equity');
```

\---

### Task 2.5 — Invoice vs Real Income Comparison Widget

Add to `src/pages/LandcoIncome.tsx` (or Dashboard):

```typescript
// Fetch both totals for the selected period
const \[invoiceTotal, realTotal] = await Promise.all(\[
  fetch(`/api/income-transactions/total?month=${m}\&year=${y}`).then(r => r.json()),
  fetch(`/api/landco-income/total?month=${m}\&year=${y}`).then(r => r.json()),
]);
const difference = realTotal - invoiceTotal;
```

Display:

```
Invoice Income (BDO):   MZN XX,XXX
Real Owner Income:      MZN XX,XXX
Difference:             MZN 0          \[GREEN ✓] / \[RED ✗ XX,XXX]
```

\---

## PHASE 3 — EXPENSE PAYMENTS PAGE UPGRADE

### Task 3.1 — Field Label Fix

`src/pages/ExpensePayments.tsx`:

```tsx
// Change:
<Label>Amount (MZN)</Label>
// To:
<Label>Amount</Label>
```

Ensure `amount\_mzn` column still stores 2 decimal places (no change to DB).

\---

### Task 3.2 — Add `expense\_target` Field

**Migration:**

```sql
ALTER TABLE expense\_transactions
ADD COLUMN IF NOT EXISTS expense\_target TEXT
  CHECK (expense\_target IN ('H1','H2','H3','H4','Com','Negu'));
```

**Form field:**

```tsx
<Select name="expense\_target" required>
  <SelectItem value="H1">H1 — Casa Luz</SelectItem>
  <SelectItem value="H2">H2 — Casa Aurora</SelectItem>
  <SelectItem value="H3">H3 — Casa Caju</SelectItem>
  <SelectItem value="H4">H4 — Casa Coco</SelectItem>
  <SelectItem value="Com">Com — Communal</SelectItem>
  <SelectItem value="Negu">Negu — Boat</SelectItem>
</Select>
```

\---

### Task 3.3 — Add `payment\_source` Field

**Migration:**

```sql
ALTER TABLE expense\_transactions
ADD COLUMN IF NOT EXISTS payment\_source TEXT
  CHECK (payment\_source IN (
    'Petty Cash Formal',
    'Petty Cash Informal',
    'MZN Cheque Account',
    'MZN Debit Card',
    'USD Cheque Account'
  ));
```

**Form dropdown:** 5 options matching valid values above.

\---

### Task 3.4 — Add `supplier` Field

**Migration:**

```sql
ALTER TABLE expense\_transactions
ADD COLUMN IF NOT EXISTS supplier TEXT;
```

**Form:** Single-line text input between Description and Reference. No validation required.

\---

### Task 3.5 — Update Recent Expenses List

Replace the existing Recent Expense Payments table with:

**Columns (in order):** Date | Supplier | Description | Reference | Expense Category | Source | Amount

**Period filter:**

```tsx
<Select defaultValue="1">
  <SelectItem value="1">Last 1 month</SelectItem>
  <SelectItem value="2">Last 2 months</SelectItem>
  <SelectItem value="3">Last 3 months</SelectItem>
</Select>
```

**Totals row:** Sticky footer row summing the Amount column.

\---

### Task 3.6 — Update Help Content (EN + PT)

**File:** `src/lib/helpContent.ts`

Add entries for every field added in Phase 3:

```typescript
expense\_target: {
  en: "Identifies which owner's account this expense is charged to. Select H1–H4 for a specific house, 'Com' for a shared communal expense, or 'Negu' for the shared boat.",
  pt: "Identifica a conta do proprietário a que esta despesa é imputada. Seleccione H1–H4 para uma casa específica, 'Com' para despesas comunais partilhadas, ou 'Negu' para o barco partilhado."
},
payment\_source: {
  en: "The fund or account used to pay this expense. Must match the actual source so that account balances in the Sources dashboard reconcile correctly.",
  pt: "O fundo ou conta utilizado para pagar esta despesa. Deve corresponder à fonte real, de modo a que os saldos das contas no painel Fontes sejam correctamente reconciliados."
},
supplier: {
  en: "Name of the supplier or payee. Free text — enter as it appears on the invoice or receipt.",
  pt: "Nome do fornecedor ou beneficiário. Texto livre — introduza tal como aparece na factura ou recibo."
}
```

\---

## PHASE 4 — SOURCES DASHBOARD

### Task 4.1 — Create Sources Tables

**Migration:** `db/migrations/008\_sources\_accounts.sql`

```sql
CREATE TABLE IF NOT EXISTS cash\_box\_transactions (
  id               UUID PRIMARY KEY DEFAULT gen\_random\_uuid(),
  account\_owner    TEXT NOT NULL CHECK (account\_owner IN ('H1','H2','H3','H4','Com','Negu')),
  reference\_no     TEXT,
  description      TEXT,
  category\_id      UUID REFERENCES expense\_categories(id),
  deposited\_amount NUMERIC(15,2) DEFAULT 0,
  deposit\_method   TEXT CHECK (deposit\_method IN ('cash','transfer','exchange')),
  withdrawn\_amount NUMERIC(15,2) DEFAULT 0,
  balance          NUMERIC(15,2),
  transaction\_date DATE,
  notes            TEXT,
  created\_at       TIMESTAMPTZ DEFAULT NOW()
);

-- Repeat pattern for:
CREATE TABLE IF NOT EXISTS cheque\_account\_mzn\_transactions ( /\* same columns \*/ );
CREATE TABLE IF NOT EXISTS cheque\_account\_usd\_transactions ( /\* same columns \*/ );
CREATE TABLE IF NOT EXISTS debit\_card\_mzn\_transactions    ( /\* same columns \*/ );
```

\---

### Task 4.2 — Create Sources Pages

**Files to create:**

* `src/pages/sources/CashBox.tsx` → `/sources/cash-box`
* `src/pages/sources/ChequeAccountMZN.tsx` → `/sources/cheque-mzn`
* `src/pages/sources/ChequeAccountUSD.tsx` → `/sources/cheque-usd`
* `src/pages/sources/DebitCardMZN.tsx` → `/sources/debit-mzn`

**Each page must include:**

```tsx
// Columns: Account Owner | Ref No | Description | Category | Deposited | Method | Withdrawn | Balance
// Running balance: each row = previous balance + deposited - withdrawn
// Filters: Account Owner dropdown + Date range picker
// Footer: Total Deposited | Total Withdrawn | Current Balance
// Row actions: Edit | Delete (admin only)
// Add button: opens modal form
```

\---

### Task 4.3 — Create Sources Hub Page

**File:** `src/pages/Sources.tsx` | **Route:** `/sources`

Four summary cards:

```
\[Cash Box]             \[Cheque Account MZN]
Current Balance: XX    Current Balance: XX
Deposits this month    Deposits this month
Withdrawals this month Withdrawals this month

\[Cheque Account USD]   \[Debit Card MZN]
...                    ...
```

Clicking a card navigates to the detail page.

**Sidebar entry** (`AppSidebar.tsx`):

```tsx
{
  label: 'Sources',
  icon: Wallet,
  href: '/sources',
  children: \[
    { label: 'Cash Box', href: '/sources/cash-box' },
    { label: 'Cheque Account (MZN)', href: '/sources/cheque-mzn' },
    { label: 'Cheque Account (USD)', href: '/sources/cheque-usd' },
    { label: 'Debit Card (MZN)', href: '/sources/debit-mzn' },
  ]
}
```

\---

### Task 4.4 — Link Expense Payment to Sources Account

In the API route handling `POST /api/expense-transactions`:

```javascript
// After inserting expense record, auto-create withdrawal in source account:
const sourceTableMap = {
  'Petty Cash Formal':   'cash\_box\_transactions',
  'Petty Cash Informal': 'cash\_box\_transactions',
  'MZN Cheque Account':  'cheque\_account\_mzn\_transactions',
  'MZN Debit Card':      'debit\_card\_mzn\_transactions',
  'USD Cheque Account':  'cheque\_account\_usd\_transactions',
};
const targetTable = sourceTableMap\[body.payment\_source];
if (targetTable) {
  await db.query(`INSERT INTO ${targetTable} 
    (account\_owner, description, withdrawn\_amount, transaction\_date)
    VALUES ($1, $2, $3, $4)`,
    \[body.expense\_target, body.description, body.amount\_mzn, body.date]
  );
}
```

\---

## PHASE 5 — CRUD ACROSS ALL TRANSACTION TABLES

**Pattern to apply to every transaction table:**

```tsx
// Row action buttons (admin only):
<Button variant="ghost" size="sm" onClick={() => setEditRow(row.id)}>Edit</Button>
<Button variant="ghost" size="sm" onClick={() => confirmDelete(row.id)}>Delete</Button>

// Edit state: render inline inputs for all fields
// Delete: show confirmation dialog → call DELETE /api/\[table]/:id
// New: "Add" button → modal form → POST /api/\[table]

// After any mutation:
await queryClient.invalidateQueries(\[tableName]);
```

**Apply to:**

* `src/pages/Transactions.tsx` — Income tab (Task 5.1)
* `src/pages/Transactions.tsx` — Expenses tab (Task 5.2)
* `src/pages/Transactions.tsx` — Bank tab (Task 5.3)
* `src/pages/Transactions.tsx` — Petty Cash tab (Task 5.4)
* `src/pages/Employees.tsx` — soft delete with `is\_active = false` (Task 5.5)
* `src/pages/Payroll.tsx` — salary runs + lines (Task 5.6)

**Duplicate import detection** (Task 5.7) — `src/pages/UploadData.tsx`:

```tsx
const existing = await fetch(`/api/import-log?file\_type=${type}\&month=${m}\&year=${y}`);
if (existing.count > 0) {
  showModal('Already imported', \[
    { label: 'Cancel', action: 'cancel' },
    { label: 'Clear and Re-import', action: 'replace' },
    { label: 'Append', action: 'append' },
  ]);
}
```

\---

## PHASE 6 — REPORTING AND OWNER STATEMENTS

### Task 6.1 — Fix Shareholder Balance Calculations

**DB function:**

```sql
CREATE OR REPLACE FUNCTION fn\_calculate\_shareholder\_balance(
  p\_property\_code TEXT,
  p\_month INTEGER,
  p\_year INTEGER
) RETURNS TABLE(opening NUMERIC, income NUMERIC, expenses NUMERIC, closing NUMERIC)
LANGUAGE plpgsql AS $$
DECLARE
  v\_opening NUMERIC;
  v\_income  NUMERIC;
  v\_expenses NUMERIC;
BEGIN
  -- Get opening balance from previous month
  SELECT COALESCE(closing\_balance, 0) INTO v\_opening
  FROM shareholder\_balances
  WHERE property\_code = p\_property\_code
    AND year = CASE WHEN p\_month = 1 THEN p\_year - 1 ELSE p\_year END
    AND month = CASE WHEN p\_month = 1 THEN 12 ELSE p\_month - 1 END;

  -- Sum real income
  SELECT COALESCE(SUM(amount\_mzn\_equivalent), 0) INTO v\_income
  FROM landco\_income
  WHERE property\_code = p\_property\_code
    AND period\_month = p\_month AND period\_year = p\_year;

  -- Sum attributed expenses + 25% of communal
  SELECT COALESCE(SUM(amount\_mzn), 0) INTO v\_expenses
  FROM expense\_transactions
  WHERE (expense\_target = p\_property\_code
     OR (expense\_target = 'Com'))  -- weight communal at 0.25 in application layer
    AND month = p\_month AND year = p\_year;

  RETURN QUERY SELECT v\_opening, v\_income, v\_expenses, (v\_opening + v\_income - v\_expenses);
END;
$$;
```

Add "Recalculate Balances" button to `src/pages/Shareholders.tsx` (admin only).

\---

### Task 6.2 — Owner Monthly Statement

`src/pages/ShareholderReports.tsx` — statement sections:

```
\[Owner Name]  \[House]          Period: \[Month] \[Year]
─────────────────────────────────────────────────────
Opening Balance:                           MZN XX,XXX

INCOME
Date        Description          MZN        USD
──────────────────────────────────────────────────
\[rows from landco\_income where property\_code = H?]
Total Income:                              MZN XX,XXX

EXPENSES (Personal)
Date   Supplier  Description  Category  Source    Amount
────────────────────────────────────────────────────────
\[rows from expense\_transactions where expense\_target = H?]

EXPENSES (Communal — 25% share)
\[rows from expense\_transactions where expense\_target = 'Com', amount × 0.25]

Total Expenses:                            MZN XX,XXX
─────────────────────────────────────────────────────
Closing Balance:                           MZN XX,XXX

\[Print / Export PDF button]
```

\---

### Task 6.3 — BDO Export Report

**File:** `src/pages/reports/BDOExport.tsx` | **Route:** `/reports/bdo-export`

Sections:

1. **Invoice Income** — from `income\_transactions` (dummy invoices, BDO-facing)
2. **Official Expenses** — from `expense\_transactions` where supplier invoice exists
3. **Payroll Summary** — gross, IRPS, INSS from `salary\_runs` + `salary\_lines`
4. **Bank Movements** — from `bank\_transactions` for BDO MZN and BDO USD accounts

Export button: generates `.xlsx` using `SheetJS` (`XLSX.utils.json\_to\_sheet`).

\---

### Task 6.4 — Cash Control Report Enhancement

`src/pages/CashControlReports.tsx`:

* Cash Box balance → reconcile with `cash\_box\_transactions`
* Petty Cash totals → reconcile with `petty\_cash\_transactions`
* Add monthly cash flow summary: all movements grouped by source account

\---

## PHASE 7 — POLISH (after Phases 1–6 are stable)

|Task|Priority|
|-|-|
|Update all `helpContent.ts` entries for Phases 2–6 (EN + PT)|High|
|Complete April 2026 data import once source files finalised|High|
|Month-end close workflow (Suspense review → Period close)|Medium|
|Verify `fn\_post\_depreciation\_month()` for fixed assets|Medium|
|Test bank reconciliation page against actual BDO statements|Medium|
|FX revaluation for USD balances|Medium|
|Wire `actor\_id` in `api/server.js` for audit log attribution|Medium|
|Test approval workflow for expenses above threshold|Low|
|PDF export stylesheets for all report pages|Low|

\---

## SUCCESS CRITERIA CHECKLIST

Before marking the implementation complete, verify all of the following:

* \[ ] Exchange rate on Dashboard is editable; value used in all currency conversions
* \[ ] `landco\_income` table exists and contains Jan–Apr 2026 data from INCOME sheets
* \[ ] Landco Income page (`/landco-income`) is accessible, shows per-property totals, rows are editable
* \[ ] P\&L, Dashboard income KPIs, and Shareholder Reports all source from `landco\_income`
* \[ ] Invoice vs Real Income widget shows ≤ MZN 1 difference per completed month
* \[ ] Expense Payments form includes: Expense Target, Payment Source, Supplier fields
* \[ ] Recent Expenses list has correct 7 columns + totals row + period filter
* \[ ] Sources dashboard exists at `/sources` with 4 working sub-pages and correct running balances
* \[ ] Add/Edit/Delete works on: Income, Expenses, Bank, Petty Cash, Employees tables
* \[ ] Shareholder monthly statements generate correctly for H1–H4
* \[ ] BDO export produces downloadable `.xlsx` for any completed month
* \[ ] Trial Balance shows debits = credits for all completed periods
* \[ ] All new fields have help popups in both English and Portuguese
* \[ ] No `supabase.from(` calls outside of auth-related files
* \[ ] `import\_log` correctly blocks duplicate imports with user confirmation

\---

## DOCKER QUICK REFERENCE

```bash
# Start / rebuild
docker compose --env-file .env.local up -d --build

# Stop
docker compose down

# Logs
docker logs lanacc-web -f
docker logs lanacc-api -f
docker logs lanacc-db -f

# DB shell
docker exec -it lanacc-db psql -U postgres -d landco\_v2\_db

# Run migration
docker exec -i lanacc-db psql -U postgres -d landco\_v2\_db < db/migrations/00N\_name.sql

# Run backfill
docker exec -it lanacc-api node /app/scripts/backfill-journal.mjs
```

**App URLs:**

* Frontend: http://localhost:8080
* API: http://localhost:4000
* pgAdmin: http://localhost:5050

\---

*Landco Lodge Accounting — Codex Implementation Spec — v1.1 — May 2026*

