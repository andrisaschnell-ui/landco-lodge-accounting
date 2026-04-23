-- ============================================================
-- LANACC — Local schema alignment with cloud
-- Adds columns/tables that exist in the cloud but were missing
-- from the local init scripts. Safe to run multiple times.
-- ============================================================

-- expense_categories: missing translation + type columns
ALTER TABLE public.expense_categories
  ADD COLUMN IF NOT EXISTS name_en       text,
  ADD COLUMN IF NOT EXISTS name_pt       text,
  ADD COLUMN IF NOT EXISTS category_type text;

-- petty_cash_transactions: recovery + journal link columns
ALTER TABLE public.petty_cash_transactions
  ADD COLUMN IF NOT EXISTS reference        text,
  ADD COLUMN IF NOT EXISTS supplier         text,
  ADD COLUMN IF NOT EXISTS allocation       text,
  ADD COLUMN IF NOT EXISTS vat_amount       numeric DEFAULT 0,
  ADD COLUMN IF NOT EXISTS net_amount       numeric DEFAULT 0,
  ADD COLUMN IF NOT EXISTS source_file      text,
  ADD COLUMN IF NOT EXISTS journal_entry_id uuid REFERENCES public.journal_entries(id);

-- salary_lines: guardas allowance + category
ALTER TABLE public.salary_lines
  ADD COLUMN IF NOT EXISTS guardas_25 numeric DEFAULT 0,
  ADD COLUMN IF NOT EXISTS category   text;

-- suppliers + supplier_invoices: missing tables
CREATE TABLE IF NOT EXISTS public.suppliers (
  id         uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name       text NOT NULL,
  created_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.supplier_invoices (
  id               uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  supplier_id      uuid REFERENCES public.suppliers(id),
  invoice_number   text,
  invoice_date     date,
  description      text,
  allocation       text,
  amount_excl      numeric DEFAULT 0,
  vat_amount       numeric DEFAULT 0,
  total_amount     numeric DEFAULT 0,
  journal_entry_id uuid REFERENCES public.journal_entries(id),
  created_at       timestamptz DEFAULT now()
);
