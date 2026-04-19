# LANACC — Accounting Engine Upgrade Plan
## Agent Briefing: Double-Entry, PGC Account Mapping & AT-Certified Invoicing

---

## 1. Project Context

**LANACC** (Landco Lodge Accounting) is a property accounting application for a Mozambican lodge
business. It runs as a local Docker stack:

- **PostgreSQL 16** — database (20 tables, schema below)
- **Node/Express API** (`api/server.js`) — auth + generic CRUD
- **React + Vite + shadcn/ui** — frontend (`web/src/`)
- **Nginx** — serves the built React app

The app currently tracks income, expenses, salaries, bank transactions, petty cash, and
shareholder balances — but has **no double-entry ledger, no chart of accounts, and no
AT-compliant invoicing**. This plan upgrades all three.

**Currency:** MZN (Mozambican Metical) primary, USD secondary  
**Tax authority:** AT — Autoridade Tributária de Moçambique  
**Accounting standard:** PGC-NIRF (Plano Geral de Contabilidade, Mozambique)

---

## 2. Current Database Schema (summary)

```
auth.users              — bcrypt login accounts
public.profiles         — display names
public.user_roles       — admin / viewer enum
public.properties       — lodge properties (code, name)
public.shareholders     — owners with % per property
public.bank_accounts    — bank accounts (MZN/USD)
public.expense_categories
public.employees        — payroll master data
public.exchange_rates   — monthly MZN/USD, MZN/ZAR
public.income_transactions    — guest income per property
public.expense_transactions   — expenses per property/shareholder
public.bank_transactions      — bank statement lines
public.petty_cash_transactions
public.salary_runs / salary_lines / salary_advances
public.bim_salary_transfers
public.inss_payments / irps_payments
public.shareholder_balances
public.import_log
```

---

## 3. Upgrade Scope — Three Phases

---

## PHASE 1 — Double-Entry Ledger Engine

### 1.1 New Database Tables

Add these tables to `db/init/01_schema.sql` (or a new migration file
`db/init/04_accounting.sql`):

```sql
-- Chart of Accounts (PGC-NIRF Mozambique)
CREATE TABLE IF NOT EXISTS public.accounts (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  code          text NOT NULL UNIQUE,        -- e.g. '11', '211', '7111'
  name          text NOT NULL,               -- e.g. 'Caixa', 'Clientes'
  account_class integer NOT NULL,            -- 1=Asset,2=Liability,3=Equity,
                                             -- 6=Expense,7=Income
  account_type  text NOT NULL,               -- 'asset','liability','equity',
                                             --  'income','expense'
  normal_side   text NOT NULL CHECK (normal_side IN ('debit','credit')),
  parent_code   text REFERENCES public.accounts(code),
  is_active     boolean NOT NULL DEFAULT true,
  pgc_class     text,                        -- PGC section label
  created_at    timestamptz NOT NULL DEFAULT now()
);

-- Journal (every accounting entry lives here)
CREATE TABLE IF NOT EXISTS public.journal_entries (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  entry_date    date NOT NULL,
  reference     text,                        -- invoice no, payroll ref, etc.
  description   text NOT NULL,
  entry_type    text NOT NULL,               -- 'manual','income','expense',
                                             --  'payroll','bank','petty_cash'
  property_id   uuid REFERENCES public.properties(id),
  posted        boolean NOT NULL DEFAULT false,
  posted_at     timestamptz,
  posted_by     uuid REFERENCES auth.users(id),
  created_by    uuid REFERENCES auth.users(id),
  created_at    timestamptz NOT NULL DEFAULT now()
);

-- Journal Lines (debit/credit pairs — must balance per entry)
CREATE TABLE IF NOT EXISTS public.journal_lines (
  id               uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  journal_entry_id uuid NOT NULL REFERENCES public.journal_entries(id)
                       ON DELETE CASCADE,
  account_id       uuid NOT NULL REFERENCES public.accounts(id),
  debit            numeric NOT NULL DEFAULT 0 CHECK (debit >= 0),
  credit           numeric NOT NULL DEFAULT 0 CHECK (credit >= 0),
  memo             text,
  CHECK (debit = 0 OR credit = 0)           -- only one side per line
);

-- Constraint: journal must balance (enforced via trigger below)

-- Periods (lock closed months from editing)
CREATE TABLE IF NOT EXISTS public.accounting_periods (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  year        integer NOT NULL,
  month       integer NOT NULL,
  is_closed   boolean NOT NULL DEFAULT false,
  closed_at   timestamptz,
  closed_by   uuid REFERENCES auth.users(id),
  UNIQUE (year, month)
);

-- Link existing transactions to journal entries
ALTER TABLE public.income_transactions
  ADD COLUMN IF NOT EXISTS journal_entry_id uuid
    REFERENCES public.journal_entries(id);

ALTER TABLE public.expense_transactions
  ADD COLUMN IF NOT EXISTS journal_entry_id uuid
    REFERENCES public.journal_entries(id);

ALTER TABLE public.bank_transactions
  ADD COLUMN IF NOT EXISTS journal_entry_id uuid
    REFERENCES public.journal_entries(id);

ALTER TABLE public.salary_runs
  ADD COLUMN IF NOT EXISTS journal_entry_id uuid
    REFERENCES public.journal_entries(id);
```

### 1.2 Balance-Check Trigger

```sql
CREATE OR REPLACE FUNCTION public.check_journal_balance()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
DECLARE
  v_debit  numeric;
  v_credit numeric;
BEGIN
  SELECT COALESCE(SUM(debit),0), COALESCE(SUM(credit),0)
    INTO v_debit, v_credit
    FROM public.journal_lines
   WHERE journal_entry_id = NEW.journal_entry_id;

  IF v_debit <> v_credit THEN
    RAISE EXCEPTION 'Journal entry % is unbalanced: debit=% credit=%',
      NEW.journal_entry_id, v_debit, v_credit;
  END IF;
  RETURN NEW;
END $$;

-- Fire after each line insert/update
CREATE CONSTRAINT TRIGGER trg_journal_balance
  AFTER INSERT OR UPDATE ON public.journal_lines
  DEFERRABLE INITIALLY DEFERRED
  FOR EACH ROW EXECUTE FUNCTION public.check_journal_balance();
```

### 1.3 PGC Chart of Accounts Seed Data

Create `db/init/05_chart_of_accounts.sql` with the core PGC-NIRF accounts
for a Mozambican lodge:

```sql
INSERT INTO public.accounts (code, name, account_class, account_type, normal_side, pgc_class) VALUES
-- Class 1: Meios Financeiros
('11',   'Caixa',                          1,'asset','debit','Classe 1'),
('12',   'Depósitos à Ordem',              1,'asset','debit','Classe 1'),
('121',  'BCI — Conta MZN',               1,'asset','debit','Classe 1'),
('122',  'BIM — Conta MZN',               1,'asset','debit','Classe 1'),
('123',  'BCI — Conta USD',               1,'asset','debit','Classe 1'),
-- Class 2: Terceiros
('211',  'Clientes',                       2,'asset','debit','Classe 2'),
('221',  'Fornecedores',                   2,'liability','credit','Classe 2'),
('231',  'Pessoal — Remunerações a Pagar', 2,'liability','credit','Classe 2'),
('241',  'Estado — INSS a Pagar',          2,'liability','credit','Classe 2'),
('242',  'Estado — IRPS a Pagar',          2,'liability','credit','Classe 2'),
('243',  'Estado — IVA a Pagar',           2,'liability','credit','Classe 2'),
-- Class 3: Inventários (minimal for lodge)
('31',   'Mercadorias',                    3,'asset','debit','Classe 3'),
-- Class 5: Capital Próprio
('51',   'Capital Social',                 5,'equity','credit','Classe 5'),
('56',   'Resultados Transitados',         5,'equity','credit','Classe 5'),
-- Class 6: Gastos
('611',  'Gastos c/ Pessoal — Salários',   6,'expense','debit','Classe 6'),
('612',  'Gastos c/ Pessoal — INSS Entidade', 6,'expense','debit','Classe 6'),
('621',  'Fornecimentos e Serviços Externos', 6,'expense','debit','Classe 6'),
('622',  'Electricidade e Água',           6,'expense','debit','Classe 6'),
('623',  'Combustíveis',                   6,'expense','debit','Classe 6'),
('624',  'Manutenção e Reparações',        6,'expense','debit','Classe 6'),
('625',  'Comunicações',                   6,'expense','debit','Classe 6'),
('626',  'Seguros',                        6,'expense','debit','Classe 6'),
('631',  'Impostos e Taxas',               6,'expense','debit','Classe 6'),
-- Class 7: Rendimentos
('711',  'Vendas — Alojamento',            7,'income','credit','Classe 7'),
('712',  'Vendas — Restauração',           7,'income','credit','Classe 7'),
('713',  'Vendas — Actividades',           7,'income','credit','Classe 7'),
('714',  'Outros Rendimentos',             7,'income','credit','Classe 7')
ON CONFLICT (code) DO NOTHING;
```

### 1.4 Auto-Journal on Transaction Insert (API layer)

In `api/server.js`, add a `postTransaction()` helper that wraps every
income/expense insert in a journal entry. Example for income:

```javascript
// Called after inserting into income_transactions
async function createIncomeJournal(client, tx, exchangeRate) {
  const amountMZN = tx.accommodation_amount_mzn;

  // 1. Create journal header
  const { rows: [entry] } = await client.query(`
    INSERT INTO public.journal_entries
      (entry_date, reference, description, entry_type, property_id, posted)
    VALUES ($1, $2, $3, 'income', $4, true)
    RETURNING id`,
    [tx.date, tx.id, `Income: ${tx.guest_name}`, tx.property_id]
  );

  // 2. Debit Clientes (211), Credit Alojamento (711)
  await client.query(`
    INSERT INTO public.journal_lines
      (journal_entry_id, account_id, debit, credit)
    VALUES
      ($1, (SELECT id FROM public.accounts WHERE code='211'), $2, 0),
      ($1, (SELECT id FROM public.accounts WHERE code='711'), 0, $2)`,
    [entry.id, amountMZN]
  );

  // 3. Link back
  await client.query(
    `UPDATE public.income_transactions
        SET journal_entry_id = $1 WHERE id = $2`,
    [entry.id, tx.id]
  );
}
```

Apply the same pattern for:
- **Expenses** → Debit expense account (6xx), Credit bank/cash (11/12)
- **Payroll** → Debit Salários (611), Credit Remunerações a Pagar (231),
  Credit INSS (241), Credit IRPS (242)
- **Bank payments** → Debit liability account, Credit bank (12x)

### 1.5 New API Endpoints to add to `api/server.js`

```
GET  /api/accounts                    — list chart of accounts
POST /api/accounts                    — create account (admin)
GET  /api/journal                     — list journal entries (paginated)
POST /api/journal                     — create manual journal entry with lines
GET  /api/journal/:id/lines           — get lines for one entry
GET  /api/ledger/:accountCode         — account ledger (running balance)
GET  /api/trial-balance?year=&month=  — trial balance at period end
GET  /api/periods                     — list accounting periods
POST /api/periods/:id/close           — close a period (admin only)
```

### 1.6 New React Pages/Components

Add to `web/src/pages/`:

- `ChartOfAccounts.tsx` — table of all accounts with code/name/type/balance
- `JournalEntries.tsx` — list + create manual journal entries
- `Ledger.tsx` — account ledger with running balance per account
- `TrialBalance.tsx` — month/year selector, debit/credit columns, totals row

---

## PHASE 2 — PGC Account Mapping

### 2.1 Map Existing Categories to PGC Accounts

Add a mapping column to existing tables:

```sql
ALTER TABLE public.expense_categories
  ADD COLUMN IF NOT EXISTS pgc_account_code text
    REFERENCES public.accounts(code);

ALTER TABLE public.bank_accounts
  ADD COLUMN IF NOT EXISTS pgc_account_code text
    REFERENCES public.accounts(code);
```

### 2.2 Mapping UI

Add to `web/src/pages/Settings.tsx` (or a new `AccountMapping.tsx`):

- A table showing each `expense_category` with a dropdown to pick its PGC account (6xx)
- A table showing each `bank_account` with a dropdown to pick its PGC account (12x)
- A "Save Mappings" button that patches via API

### 2.3 Mapping Validation Endpoint

```
GET /api/mapping-status   — returns list of categories/bank accounts missing PGC mapping
```

The API should block journal auto-creation if the mapping is missing, returning a
`400` error with a helpful message like:
`"Expense category 'Electricity' has no PGC account mapped. Go to Settings > Account Mapping."`

### 2.4 Property-Level Accounts

For multi-property reporting, add a `property_id` dimension to the ledger query:

```sql
-- View: ledger balance per account per property
CREATE OR REPLACE VIEW public.v_account_balances AS
SELECT
  a.code,
  a.name,
  a.account_type,
  a.normal_side,
  je.property_id,
  SUM(jl.debit)  AS total_debit,
  SUM(jl.credit) AS total_credit,
  CASE a.normal_side
    WHEN 'debit'  THEN SUM(jl.debit)  - SUM(jl.credit)
    WHEN 'credit' THEN SUM(jl.credit) - SUM(jl.debit)
  END AS balance
FROM public.accounts a
JOIN public.journal_lines jl ON jl.account_id = a.id
JOIN public.journal_entries je ON je.id = jl.journal_entry_id
WHERE je.posted = true
GROUP BY a.id, a.code, a.name, a.account_type, a.normal_side, je.property_id;
```

---

## PHASE 3 — AT-Certified Invoice Reporting

### 3.1 Invoices Table

```sql
CREATE TABLE IF NOT EXISTS public.invoices (
  id               uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  invoice_number   text NOT NULL UNIQUE,       -- sequential: FT 2026/001
  invoice_series   text NOT NULL DEFAULT 'FT', -- FT=Fatura, FR=Fatura-Recibo
  invoice_date     date NOT NULL,
  due_date         date,
  property_id      uuid REFERENCES public.properties(id),
  client_name      text NOT NULL,
  client_nuit      text,                       -- Tax ID of client
  client_address   text,
  line_items       jsonb NOT NULL DEFAULT '[]',-- [{desc, qty, unit, vat_rate, amount}]
  subtotal_mzn     numeric NOT NULL DEFAULT 0,
  vat_amount_mzn   numeric NOT NULL DEFAULT 0, -- IVA
  total_mzn        numeric NOT NULL DEFAULT 0,
  currency         text NOT NULL DEFAULT 'MZN',
  exchange_rate    numeric DEFAULT 1,
  status           text NOT NULL DEFAULT 'draft', -- draft, issued, paid, cancelled
  at_hash          text,                       -- AT validation hash (see 3.3)
  at_qr_code       text,                       -- QR code string for AT
  journal_entry_id uuid REFERENCES public.journal_entries(id),
  income_tx_id     uuid REFERENCES public.income_transactions(id),
  issued_by        uuid REFERENCES auth.users(id),
  created_at       timestamptz NOT NULL DEFAULT now(),
  updated_at       timestamptz NOT NULL DEFAULT now()
);

-- Sequential invoice number generator
CREATE SEQUENCE IF NOT EXISTS invoice_seq START 1;

CREATE OR REPLACE FUNCTION public.next_invoice_number(series text, yr integer)
RETURNS text LANGUAGE sql AS $$
  SELECT series || ' ' || yr || '/' || LPAD(nextval('invoice_seq')::text, 3, '0')
$$;
```

### 3.2 Invoice Line Items Structure (jsonb)

Each item in `line_items`:
```json
{
  "description": "Accommodation — 3 nights",
  "quantity": 3,
  "unit_price": 5000.00,
  "vat_rate": 0.17,
  "vat_amount": 2550.00,
  "line_total": 17550.00
}
```

IVA rates for Mozambique: **17%** standard, **5%** reduced (tourism), **0%** exempt.

### 3.3 AT Hash & QR Code (Mozambique AT Compliance)

AT (Autoridade Tributária) requires each invoice to carry a validation hash
and a QR code. The hash is computed as:

```javascript
// api/server.js — AT hash generation
import crypto from 'crypto';

function generateATHash(invoice) {
  // Fields required by AT for hash: date, systemDate, invoiceNumber, grossTotal, previousHash
  const fields = [
    invoice.invoice_date,          // document date
    invoice.created_at,            // system date
    invoice.invoice_number,        // invoice number
    invoice.total_mzn.toFixed(2),  // gross total
    invoice.previous_hash || ''    // hash of previous invoice (chain)
  ].join(';');

  return crypto
    .createHmac('sha256', process.env.AT_SIGNING_KEY || 'default-key')
    .update(fields)
    .digest('base64')
    .slice(0, 8);                  // AT uses first 8 chars
}

function generateQRString(invoice, companyNUIT) {
  // AT QR format (simplified — confirm exact spec with AT portal)
  return [
    `A:${companyNUIT}`,           // emitter NUIT
    `B:${invoice.client_nuit || '999999999'}`,
    `C:MZ`,                        // country
    `D:${invoice.invoice_series}`, // doc type
    `E:N`,                         // document status
    `F:${invoice.invoice_date.replace(/-/g,'')}`,
    `G:${invoice.invoice_number}`,
    `H:${invoice.at_hash}`,
    `I1:MZ`,
    `N:${invoice.vat_amount_mzn.toFixed(2)}`,
    `O:${invoice.total_mzn.toFixed(2)}`,
    `Q:${invoice.at_hash}`
  ].join('*');
}
```

Add to `.env`:
```env
AT_SIGNING_KEY=your-at-private-key-from-at-portal
COMPANY_NUIT=123456789
COMPANY_NAME=Landco Lodge Lda
COMPANY_ADDRESS=Vilankulo, Inhambane, Moçambique
```

### 3.4 New Invoice API Endpoints

```
GET    /api/invoices                  — list invoices (filter by status, date, property)
POST   /api/invoices                  — create draft invoice
GET    /api/invoices/:id              — get one invoice with lines
PATCH  /api/invoices/:id/issue        — issue invoice (assigns number, hash, QR, posts journal)
PATCH  /api/invoices/:id/cancel       — cancel invoice (posts reversal journal)
GET    /api/invoices/:id/pdf          — generate PDF (see 3.5)
GET    /api/invoices/next-number      — preview next invoice number
```

### 3.5 PDF Invoice Generation

Use **pdfkit** in the API to generate AT-compliant PDF invoices:

```bash
# Add to api/package.json dependencies:
npm install pdfkit qrcode
```

PDF must include (AT requirements):
- Company name, NUIT, address
- Invoice number and series
- Invoice date and due date
- Client name, NUIT, address
- Line items table (description, qty, unit price, VAT rate, VAT amount, total)
- Subtotal, IVA total, Grand Total
- AT hash (printed as text: "Hash: XXXX")
- QR code (generated from QR string above)
- Legal footer: *"Processado por programa certificado n.º XXXX/AT"*

```javascript
// api/routes/invoices.js
import PDFDocument from 'pdfkit';
import QRCode from 'qrcode';

app.get('/api/invoices/:id/pdf', requireAuth, async (req, res) => {
  const invoice = await getInvoiceById(req.params.id);
  const doc = new PDFDocument({ margin: 50 });

  res.setHeader('Content-Type', 'application/pdf');
  res.setHeader('Content-Disposition',
    `attachment; filename="${invoice.invoice_number.replace('/','_')}.pdf"`);
  doc.pipe(res);

  // Header
  doc.fontSize(20).text(process.env.COMPANY_NAME, { align: 'left' });
  doc.fontSize(10).text(`NUIT: ${process.env.COMPANY_NUIT}`);
  doc.text(process.env.COMPANY_ADDRESS);
  doc.moveDown();

  // Invoice title
  doc.fontSize(16).text(`FATURA — ${invoice.invoice_number}`, { align: 'right' });
  doc.fontSize(10).text(`Data: ${invoice.invoice_date}`, { align: 'right' });

  // ... line items table, totals, QR code, hash, footer
  // (agent to implement full layout)

  doc.end();
});
```

### 3.6 New React Pages for Invoicing

Add to `web/src/pages/`:

- `Invoices.tsx` — list with status badges, filter by property/month
- `InvoiceForm.tsx` — create/edit draft invoice with line item rows
- `InvoiceView.tsx` — read-only view with "Issue", "Cancel", "Download PDF" buttons
- `InvoiceSettings.tsx` — company NUIT, address, AT key configuration

---

## 4. File Change Summary for the Agent

### PostgreSQL (`db/init/`)
| File | Action |
|------|--------|
| `04_accounting.sql` | CREATE: accounts, journal_entries, journal_lines, accounting_periods + ALTER existing tables + balance trigger |
| `05_chart_of_accounts.sql` | INSERT: full PGC-NIRF account seed data |
| `06_invoices.sql` | CREATE: invoices table, invoice_seq, next_invoice_number() |

### API (`api/`)
| File | Action |
|------|--------|
| `server.js` | ADD: accounts, journal, ledger, trial-balance, periods, invoices endpoints |
| `package.json` | ADD: `pdfkit`, `qrcode` dependencies |
| `routes/journal.js` | NEW: journal CRUD + auto-journal helpers |
| `routes/invoices.js` | NEW: invoice CRUD + PDF generation + AT hash |
| `lib/atHash.js` | NEW: AT hash + QR string generators |

### React (`web/src/`)
| File | Action |
|------|--------|
| `pages/ChartOfAccounts.tsx` | NEW |
| `pages/JournalEntries.tsx` | NEW |
| `pages/Ledger.tsx` | NEW |
| `pages/TrialBalance.tsx` | NEW |
| `pages/Invoices.tsx` | NEW |
| `pages/InvoiceForm.tsx` | NEW |
| `pages/InvoiceView.tsx` | NEW |
| `pages/AccountMapping.tsx` | NEW |
| `App.tsx` | ADD: routes for all new pages |
| `components/Sidebar.tsx` | ADD: Accounting and Invoicing nav sections |

---

## 5. Implementation Order for the Agent

Follow this sequence to avoid breaking existing functionality:

```
1. db: 04_accounting.sql          — adds tables, does not touch existing data
2. db: 05_chart_of_accounts.sql   — seeds accounts
3. db: 06_invoices.sql            — adds invoices table
4. api: lib/atHash.js             — utility, no side effects
5. api: routes/journal.js         — new endpoints only
6. api: routes/invoices.js        — new endpoints only
7. api: server.js                 — import new routes, add to TABLES set
8. web: ChartOfAccounts.tsx       — read-only, safe first
9. web: JournalEntries.tsx
10. web: Ledger.tsx + TrialBalance.tsx
11. web: AccountMapping.tsx
12. web: Invoices + InvoiceForm + InvoiceView
13. web: App.tsx + Sidebar.tsx    — wire up routes last
```

After each DB migration, rebuild with:
```cmd
docker compose down -v
scripts\start.bat
```

After API/web changes, rebuild containers:
```cmd
docker compose up -d --build api web
```

---

## 6. Key Business Rules to Enforce

- Every posted journal entry MUST have `SUM(debit) = SUM(credit)` — enforced by DB trigger
- A closed accounting period (`accounting_periods.is_closed = true`) must reject any new journal lines for that period
- Invoice numbers are **sequential and immutable** once issued — never reuse or skip
- A cancelled invoice must post a **full reversal** journal entry (same amounts, sides flipped)
- IVA (VAT) at 17% must be calculated and stored separately from the base amount
- AT hash must be generated server-side using the signing key — never client-side
- `COMPANY_NUIT` and `AT_SIGNING_KEY` must come from `.env`, never hardcoded

---

## 7. Testing Checklist for the Agent

- [ ] Insert an income transaction → verify a balanced journal entry is auto-created
- [ ] Insert an expense transaction → verify correct debit to expense account, credit to bank/cash
- [ ] Run a salary run → verify Salários (611), INSS (241), IRPS (242) lines created
- [ ] Trial balance for any month sums to zero (debits = credits)
- [ ] Create and issue an invoice → verify AT hash is present and QR string is valid
- [ ] Cancel an invoice → verify reversal journal entry posted
- [ ] Attempt to post journal with unbalanced lines → verify DB trigger rejects it
- [ ] Attempt to post to a closed period → verify API returns 400
- [ ] Download PDF → verify NUIT, hash, QR code, legal footer all present
