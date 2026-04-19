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

-- Balance-Check Trigger
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

-- PGC Account Mapping columns
ALTER TABLE public.expense_categories
  ADD COLUMN IF NOT EXISTS pgc_account_code text
    REFERENCES public.accounts(code);

ALTER TABLE public.bank_accounts
  ADD COLUMN IF NOT EXISTS pgc_account_code text
    REFERENCES public.accounts(code);

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
