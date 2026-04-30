-- ============================================================
-- LANACC — Complete Local Schema (single-file)
-- Run this ONCE in pgAdmin against the empty `landco_v2_db` database.
-- After it completes successfully, run db/init/09_data_snapshot.sql
-- to load the 2,456 data rows.
--
-- This file is idempotent: it drops the public schema first.
-- ============================================================

-- 0. Wipe and recreate the public schema (clean slate)
DROP SCHEMA IF EXISTS public CASCADE;
CREATE SCHEMA public;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO public;

-- 1. Extensions
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 2. Mock Supabase roles + auth schema (so column defaults / refs resolve)
DO $$ BEGIN
  IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'authenticated') THEN CREATE ROLE authenticated; END IF;
  IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'anon')          THEN CREATE ROLE anon;          END IF;
  IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'service_role')  THEN CREATE ROLE service_role;  END IF;
END $$;

CREATE SCHEMA IF NOT EXISTS auth;

CREATE TABLE IF NOT EXISTS auth.users (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  email         text UNIQUE NOT NULL,
  password_hash text NOT NULL,
  display_name  text,
  created_at    timestamptz NOT NULL DEFAULT now(),
  updated_at    timestamptz NOT NULL DEFAULT now()
);

CREATE OR REPLACE FUNCTION auth.uid() RETURNS uuid LANGUAGE sql STABLE AS $$ SELECT NULL::uuid $$;

-- 3. Enums
DO $$ BEGIN
  CREATE TYPE public.app_role AS ENUM ('admin','viewer');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- ============================================================
-- 4. CORE TABLES
-- ============================================================

CREATE TABLE public.properties (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  code        text NOT NULL,
  name        text NOT NULL,
  description text,
  created_at  timestamptz NOT NULL DEFAULT now(),
  updated_at  timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE public.shareholders (
  id                   uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name                 text NOT NULL,
  email                text,
  property_code        text REFERENCES public.properties(code),
  ownership_percentage numeric,
  created_at           timestamptz NOT NULL DEFAULT now(),
  updated_at           timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE public.profiles (
  id           uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id      uuid NOT NULL,
  display_name text,
  email        text,
  created_at   timestamptz NOT NULL DEFAULT now(),
  updated_at   timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE public.user_roles (
  id      uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  role    public.app_role NOT NULL
);

-- Chart of Accounts
CREATE TABLE public.accounts (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  code          text NOT NULL UNIQUE,
  name          text NOT NULL,
  account_class integer NOT NULL,
  account_type  text NOT NULL,
  normal_side   text NOT NULL CHECK (normal_side IN ('debit','credit')),
  parent_code   text,
  is_active     boolean NOT NULL DEFAULT true,
  pgc_class     text,
  created_at    timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE public.journal_entries (
  id           uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  entry_date   date NOT NULL,
  reference    text,
  description  text NOT NULL,
  entry_type   text NOT NULL,
  property_id  uuid REFERENCES public.properties(id),
  source_table text,
  source_id    uuid,
  posted       boolean NOT NULL DEFAULT false,
  posted_at    timestamptz,
  posted_by    uuid,
  created_by   uuid,
  created_at   timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX idx_journal_entries_source ON public.journal_entries (source_table, source_id);

CREATE TABLE public.journal_lines (
  id               uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  journal_entry_id uuid NOT NULL REFERENCES public.journal_entries(id) ON DELETE CASCADE,
  account_id       uuid NOT NULL REFERENCES public.accounts(id),
  debit            numeric NOT NULL DEFAULT 0 CHECK (debit  >= 0),
  credit           numeric NOT NULL DEFAULT 0 CHECK (credit >= 0),
  memo             text,
  CHECK (debit = 0 OR credit = 0)
);

CREATE TABLE public.accounting_periods (
  id        uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  year      integer NOT NULL,
  month     integer NOT NULL,
  is_closed boolean NOT NULL DEFAULT false,
  closed_at timestamptz,
  closed_by uuid,
  UNIQUE (year, month)
);

-- Bank
CREATE TABLE public.bank_accounts (
  id               uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name             text NOT NULL,
  bank_name        text NOT NULL,
  account_number   text,
  currency         text NOT NULL DEFAULT 'MZN',
  pgc_account_code text,
  created_at       timestamptz NOT NULL DEFAULT now(),
  updated_at       timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE public.bank_opening_balances (
  id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  bank_account_id uuid NOT NULL REFERENCES public.bank_accounts(id),
  year            integer NOT NULL,
  month           integer NOT NULL,
  opening_balance numeric NOT NULL DEFAULT 0,
  source_file     text,
  created_at      timestamptz NOT NULL DEFAULT now(),
  updated_at      timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE public.bank_transactions (
  id               uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  bank_account_id  uuid REFERENCES public.bank_accounts(id),
  date             date,
  description      text NOT NULL,
  reference        text,
  debit            numeric DEFAULT 0,
  credit           numeric DEFAULT 0,
  balance          numeric DEFAULT 0,
  year             integer NOT NULL,
  month            integer NOT NULL,
  journal_entry_id uuid REFERENCES public.journal_entries(id),
  created_at       timestamptz NOT NULL DEFAULT now()
);

-- Income / Expense
CREATE TABLE public.expense_categories (
  id               uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name             text NOT NULL,
  name_en          text,
  name_pt          text,
  category_type    text,
  parent_id        uuid REFERENCES public.expense_categories(id),
  is_shared        boolean NOT NULL DEFAULT true,
  pgc_account_code text,
  created_at       timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE public.income_transactions (
  id                       uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  date                     date NOT NULL,
  guest_name               text,
  description              text,
  accommodation_amount_mzn numeric NOT NULL DEFAULT 0,
  amount_usd               numeric DEFAULT 0,
  year                     integer NOT NULL,
  month                    integer NOT NULL,
  property_id              uuid REFERENCES public.properties(id),
  journal_entry_id         uuid REFERENCES public.journal_entries(id),
  created_at               timestamptz NOT NULL DEFAULT now(),
  updated_at               timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE public.expense_transactions (
  id               uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  date             date,
  description      text NOT NULL,
  amount_mzn       numeric NOT NULL DEFAULT 0,
  category_id      uuid REFERENCES public.expense_categories(id),
  property_id      uuid REFERENCES public.properties(id),
  shareholder_id   uuid REFERENCES public.shareholders(id),
  is_shared        boolean NOT NULL DEFAULT true,
  year             integer NOT NULL,
  month            integer NOT NULL,
  journal_entry_id uuid REFERENCES public.journal_entries(id),
  created_at       timestamptz NOT NULL DEFAULT now(),
  updated_at       timestamptz NOT NULL DEFAULT now()
);

-- Employees / Payroll
CREATE TABLE public.employees (
  id               uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name             text NOT NULL,
  category         text,
  nuit             text,
  nib              text,
  base_salary      numeric NOT NULL DEFAULT 0,
  food_allowance   numeric DEFAULT 0,
  house_assignment text,
  is_active        boolean NOT NULL DEFAULT true,
  created_at       timestamptz NOT NULL DEFAULT now(),
  updated_at       timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE public.salary_runs (
  id                   uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  year                 integer NOT NULL,
  month                integer NOT NULL,
  status               text NOT NULL DEFAULT 'draft',
  total_gross          numeric DEFAULT 0,
  total_net            numeric DEFAULT 0,
  total_inss_employee  numeric DEFAULT 0,
  total_inss_employer  numeric DEFAULT 0,
  total_irps           numeric DEFAULT 0,
  journal_entry_id     uuid REFERENCES public.journal_entries(id),
  created_at           timestamptz NOT NULL DEFAULT now(),
  updated_at           timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE public.salary_lines (
  id                   uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  salary_run_id        uuid NOT NULL REFERENCES public.salary_runs(id) ON DELETE CASCADE,
  employee_id          uuid NOT NULL REFERENCES public.employees(id),
  category             text,
  nib                  text,
  days_worked          integer DEFAULT 30,
  base_salary          numeric DEFAULT 0,
  monthly_salary       numeric DEFAULT 0,
  food_allowance       numeric DEFAULT 0,
  back_payment         numeric DEFAULT 0,
  holiday_days         integer DEFAULT 0,
  holiday_amount       numeric DEFAULT 0,
  gratification        numeric DEFAULT 0,
  overtime_15x_hours   numeric DEFAULT 0,
  overtime_15x_amount  numeric DEFAULT 0,
  overtime_2x_hours    numeric DEFAULT 0,
  overtime_2x_amount   numeric DEFAULT 0,
  overtime_25_percent  numeric DEFAULT 0,
  guardas_25           numeric DEFAULT 0,
  nightshift_hours     numeric DEFAULT 0,
  gross_total          numeric DEFAULT 0,
  irps                 numeric DEFAULT 0,
  inss_employee        numeric DEFAULT 0,
  sind                 numeric DEFAULT 0,
  advance              numeric DEFAULT 0,
  debt                 numeric DEFAULT 0,
  total_deductions     numeric DEFAULT 0,
  net_salary           numeric DEFAULT 0,
  created_at           timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE public.salary_advances (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  employee_id uuid NOT NULL REFERENCES public.employees(id),
  date        date NOT NULL,
  amount      numeric NOT NULL,
  description text,
  year        integer NOT NULL,
  month       integer NOT NULL,
  created_at  timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE public.bim_salary_transfers (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  salary_run_id uuid REFERENCES public.salary_runs(id),
  employee_id   uuid REFERENCES public.employees(id),
  name          text NOT NULL,
  nib           text,
  amount        numeric NOT NULL,
  description   text,
  year          integer NOT NULL,
  month         integer NOT NULL,
  created_at    timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE public.inss_payments (
  id           uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  year         integer NOT NULL,
  month        integer NOT NULL,
  amount       numeric NOT NULL,
  payment_date date,
  reference    text,
  created_at   timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE public.irps_payments (
  id           uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  year         integer NOT NULL,
  month        integer NOT NULL,
  amount       numeric NOT NULL,
  payment_date date,
  reference    text,
  created_at   timestamptz NOT NULL DEFAULT now()
);

-- Misc accounting
CREATE TABLE public.exchange_rates (
  id           uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  year         integer NOT NULL,
  month        integer NOT NULL,
  mzn_per_usd  numeric NOT NULL,
  mzn_per_zar  numeric,
  created_at   timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE public.shareholder_balances (
  id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  shareholder_id  uuid NOT NULL REFERENCES public.shareholders(id),
  property_id     uuid NOT NULL REFERENCES public.properties(id),
  year            integer NOT NULL,
  month           integer NOT NULL,
  opening_balance numeric DEFAULT 0,
  income          numeric DEFAULT 0,
  expenses        numeric DEFAULT 0,
  closing_balance numeric DEFAULT 0,
  created_at      timestamptz NOT NULL DEFAULT now(),
  updated_at      timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE public.import_log (
  id               uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  filename         text NOT NULL,
  file_type        text NOT NULL,
  status           text NOT NULL DEFAULT 'pending',
  records_imported integer DEFAULT 0,
  year             integer,
  month            integer,
  error_details    text,
  imported_by      uuid,
  created_at       timestamptz NOT NULL DEFAULT now()
);

-- Invoices
CREATE TABLE public.invoices (
  id               uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  invoice_number   text NOT NULL UNIQUE,
  invoice_series   text NOT NULL DEFAULT 'FT',
  invoice_date     date NOT NULL,
  due_date         date,
  property_id      uuid REFERENCES public.properties(id),
  client_name      text NOT NULL,
  client_nuit      text,
  client_address   text,
  line_items       jsonb NOT NULL DEFAULT '[]'::jsonb,
  subtotal_mzn     numeric NOT NULL DEFAULT 0,
  vat_amount_mzn   numeric NOT NULL DEFAULT 0,
  total_mzn        numeric NOT NULL DEFAULT 0,
  currency         text NOT NULL DEFAULT 'MZN',
  exchange_rate    numeric DEFAULT 1,
  status           text NOT NULL DEFAULT 'draft',
  at_hash          text,
  at_qr_code       text,
  journal_entry_id uuid REFERENCES public.journal_entries(id),
  income_tx_id     uuid REFERENCES public.income_transactions(id),
  issued_by        uuid,
  created_at       timestamptz NOT NULL DEFAULT now(),
  updated_at       timestamptz NOT NULL DEFAULT now()
);

CREATE SEQUENCE IF NOT EXISTS invoice_seq START 1;

-- Suppliers
CREATE TABLE public.suppliers (
  id         uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name       text NOT NULL,
  created_at timestamptz DEFAULT now()
);

CREATE TABLE public.supplier_invoices (
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

-- Petty cash
CREATE TABLE public.petty_cash_transactions (
  id               uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  date             date,
  description      text NOT NULL,
  reference        text,
  supplier         text,
  allocation       text,
  debit            numeric DEFAULT 0,
  credit           numeric DEFAULT 0,
  vat_amount       numeric DEFAULT 0,
  net_amount       numeric DEFAULT 0,
  balance          numeric DEFAULT 0,
  year             integer NOT NULL,
  month            integer NOT NULL,
  source_file      text,
  journal_entry_id uuid REFERENCES public.journal_entries(id),
  created_at       timestamptz NOT NULL DEFAULT now()
);

-- Cash control sheets (BDO / Petty / etc.)
CREATE TABLE public.cash_sheets (
  id                  uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  sheet_type          text NOT NULL,
  year                integer NOT NULL,
  month               integer,
  opening_balance     numeric NOT NULL DEFAULT 0,
  opening_description text,
  source_file         text,
  created_at          timestamptz NOT NULL DEFAULT now(),
  updated_at          timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE public.cash_transactions (
  id                uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  sheet_id          uuid REFERENCES public.cash_sheets(id) ON DELETE CASCADE,
  sheet_type        text NOT NULL,
  row_no            integer,
  tx_date           date,
  year              integer NOT NULL,
  month             integer NOT NULL,
  description       text,
  funder            text,
  receiver          text,
  cell_no           text,
  cheque_no         text,
  company           text,
  entrada           numeric DEFAULT 0,
  saida             numeric DEFAULT 0,
  bank_charges      numeric DEFAULT 0,
  balance           numeric,
  allocation_column text,
  allocation_amount numeric DEFAULT 0,
  allocations       jsonb NOT NULL DEFAULT '{}'::jsonb,
  source_file       text,
  created_at        timestamptz NOT NULL DEFAULT now(),
  updated_at        timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE public.cash_allocation_columns (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  sheet_type  text NOT NULL,
  column_name text NOT NULL,
  sort_order  integer NOT NULL DEFAULT 0,
  created_at  timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE public.cash_dropdown_options (
  id         uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  sheet_type text NOT NULL,
  column_key text NOT NULL,
  value      text NOT NULL,
  sort_order integer NOT NULL DEFAULT 0,
  created_at timestamptz NOT NULL DEFAULT now()
);

-- ============================================================
-- 5. Helper function used by app code
-- ============================================================
CREATE OR REPLACE FUNCTION public.has_role(_user_id uuid, _role public.app_role)
RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $$
  SELECT EXISTS (SELECT 1 FROM public.user_roles WHERE user_id = _user_id AND role = _role)
$$;

-- ============================================================
-- 6. Double-entry integrity triggers (Release 1)
-- ============================================================

-- Balance-check: every journal entry must have sum(debit) = sum(credit).
CREATE OR REPLACE FUNCTION public.fn_journal_lines_balance_check()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE
  v_entry_id uuid;
  v_debit numeric; v_credit numeric; v_count integer;
BEGIN
  v_entry_id := COALESCE(NEW.journal_entry_id, OLD.journal_entry_id);
  SELECT COALESCE(SUM(debit),0), COALESCE(SUM(credit),0), COUNT(*)
    INTO v_debit, v_credit, v_count
    FROM public.journal_lines WHERE journal_entry_id = v_entry_id;
  IF v_count = 0 THEN RETURN COALESCE(NEW, OLD); END IF;
  IF ROUND(v_debit, 2) <> ROUND(v_credit, 2) THEN
    RAISE EXCEPTION 'Journal entry % is unbalanced: debit=% credit=% (difference=%)',
      v_entry_id, v_debit, v_credit, ROUND(v_debit - v_credit, 2);
  END IF;
  RETURN COALESCE(NEW, OLD);
END $$;

DROP TRIGGER IF EXISTS trg_journal_lines_balance_check ON public.journal_lines;
CREATE CONSTRAINT TRIGGER trg_journal_lines_balance_check
  AFTER INSERT OR UPDATE OR DELETE ON public.journal_lines
  DEFERRABLE INITIALLY DEFERRED
  FOR EACH ROW EXECUTE FUNCTION public.fn_journal_lines_balance_check();

-- Period-lock: hard block writes to closed accounting_periods.
CREATE OR REPLACE FUNCTION public.fn_journal_entries_period_lock()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE v_date date; v_closed boolean;
BEGIN
  v_date := COALESCE(NEW.entry_date, OLD.entry_date);
  IF v_date IS NULL THEN RETURN COALESCE(NEW, OLD); END IF;
  SELECT is_closed INTO v_closed FROM public.accounting_periods
   WHERE year = EXTRACT(YEAR FROM v_date)::int
     AND month = EXTRACT(MONTH FROM v_date)::int;
  IF v_closed IS TRUE THEN
    RAISE EXCEPTION 'Accounting period %-% is closed. Reopen it in Settings before posting.',
      EXTRACT(YEAR FROM v_date)::int, EXTRACT(MONTH FROM v_date)::int;
  END IF;
  RETURN COALESCE(NEW, OLD);
END $$;

DROP TRIGGER IF EXISTS trg_journal_entries_period_lock ON public.journal_entries;
CREATE TRIGGER trg_journal_entries_period_lock
  BEFORE INSERT OR UPDATE OR DELETE ON public.journal_entries
  FOR EACH ROW EXECUTE FUNCTION public.fn_journal_entries_period_lock();

-- ============================================================
-- 7. Auto-post triggers (Release 1, Step 3)
-- ============================================================

CREATE OR REPLACE FUNCTION public.fn_account_or_suspense(_code text)
RETURNS uuid LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $$
  SELECT COALESCE(
    (SELECT id FROM public.accounts WHERE code = _code LIMIT 1),
    (SELECT id FROM public.accounts WHERE code = '2999' LIMIT 1)
  )
$$;

-- INCOME
CREATE OR REPLACE FUNCTION public.fn_auto_post_income()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE v_entry_id uuid; v_total numeric; v_cash uuid; v_rev uuid;
BEGIN
  IF NEW.journal_entry_id IS NOT NULL THEN RETURN NEW; END IF;
  v_total := COALESCE(NEW.accommodation_amount_mzn, 0);
  IF v_total = 0 THEN RETURN NEW; END IF;
  v_cash := public.fn_account_or_suspense('1111');
  v_rev  := public.fn_account_or_suspense('7111');
  INSERT INTO public.journal_entries
    (entry_date, description, entry_type, reference, property_id,
     source_table, source_id, posted, posted_at)
  VALUES (NEW.date, COALESCE(NEW.description, 'Income: ' || COALESCE(NEW.guest_name,'Guest')),
          'income', NEW.id::text, NEW.property_id, 'income_transactions', NEW.id, true, now())
  RETURNING id INTO v_entry_id;
  INSERT INTO public.journal_lines (journal_entry_id, account_id, debit, credit, memo) VALUES
    (v_entry_id, v_cash, v_total, 0,       'Cash received'),
    (v_entry_id, v_rev,  0,       v_total, 'Accommodation income');
  NEW.journal_entry_id := v_entry_id;
  RETURN NEW;
END $$;
DROP TRIGGER IF EXISTS trg_auto_post_income ON public.income_transactions;
CREATE TRIGGER trg_auto_post_income BEFORE INSERT ON public.income_transactions
  FOR EACH ROW EXECUTE FUNCTION public.fn_auto_post_income();

-- EXPENSE
CREATE OR REPLACE FUNCTION public.fn_auto_post_expense()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE v_entry_id uuid; v_total numeric; v_exp uuid; v_cash uuid; v_code text;
BEGIN
  IF NEW.journal_entry_id IS NOT NULL THEN RETURN NEW; END IF;
  v_total := COALESCE(NEW.amount_mzn, 0);
  IF v_total = 0 THEN RETURN NEW; END IF;
  IF NEW.category_id IS NOT NULL THEN
    SELECT pgc_account_code INTO v_code FROM public.expense_categories WHERE id = NEW.category_id;
  END IF;
  v_exp  := public.fn_account_or_suspense(v_code);
  v_cash := public.fn_account_or_suspense('1111');
  INSERT INTO public.journal_entries
    (entry_date, description, entry_type, reference, property_id,
     source_table, source_id, posted, posted_at)
  VALUES (NEW.date, NEW.description, 'expense', NEW.id::text, NEW.property_id,
          'expense_transactions', NEW.id, true, now())
  RETURNING id INTO v_entry_id;
  INSERT INTO public.journal_lines (journal_entry_id, account_id, debit, credit, memo) VALUES
    (v_entry_id, v_exp,  v_total, 0,       NEW.description),
    (v_entry_id, v_cash, 0,       v_total, 'Paid');
  NEW.journal_entry_id := v_entry_id;
  RETURN NEW;
END $$;
DROP TRIGGER IF EXISTS trg_auto_post_expense ON public.expense_transactions;
CREATE TRIGGER trg_auto_post_expense BEFORE INSERT ON public.expense_transactions
  FOR EACH ROW EXECUTE FUNCTION public.fn_auto_post_expense();

-- BANK
CREATE OR REPLACE FUNCTION public.fn_auto_post_bank()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE v_entry_id uuid; v_amt numeric; v_bank uuid; v_susp uuid; v_code text;
BEGIN
  IF NEW.journal_entry_id IS NOT NULL THEN RETURN NEW; END IF;
  v_amt := GREATEST(COALESCE(NEW.debit,0), COALESCE(NEW.credit,0));
  IF v_amt = 0 THEN RETURN NEW; END IF;
  IF NEW.bank_account_id IS NOT NULL THEN
    SELECT pgc_account_code INTO v_code FROM public.bank_accounts WHERE id = NEW.bank_account_id;
  END IF;
  v_bank := public.fn_account_or_suspense(v_code);
  v_susp := public.fn_account_or_suspense('2999');
  INSERT INTO public.journal_entries
    (entry_date, description, entry_type, reference,
     source_table, source_id, posted, posted_at)
  VALUES (NEW.date, NEW.description, 'bank', COALESCE(NEW.reference, NEW.id::text),
          'bank_transactions', NEW.id, true, now())
  RETURNING id INTO v_entry_id;
  IF COALESCE(NEW.debit,0) > 0 THEN
    INSERT INTO public.journal_lines (journal_entry_id, account_id, debit, credit, memo) VALUES
      (v_entry_id, v_bank, v_amt, 0,     NEW.description),
      (v_entry_id, v_susp, 0,     v_amt, NEW.description);
  ELSE
    INSERT INTO public.journal_lines (journal_entry_id, account_id, debit, credit, memo) VALUES
      (v_entry_id, v_susp, v_amt, 0,     NEW.description),
      (v_entry_id, v_bank, 0,     v_amt, NEW.description);
  END IF;
  NEW.journal_entry_id := v_entry_id;
  RETURN NEW;
END $$;
DROP TRIGGER IF EXISTS trg_auto_post_bank ON public.bank_transactions;
CREATE TRIGGER trg_auto_post_bank BEFORE INSERT ON public.bank_transactions
  FOR EACH ROW EXECUTE FUNCTION public.fn_auto_post_bank();

-- PETTY CASH
CREATE OR REPLACE FUNCTION public.fn_auto_post_petty_cash()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE v_entry_id uuid; v_amt numeric; v_cash uuid; v_susp uuid;
BEGIN
  IF NEW.journal_entry_id IS NOT NULL THEN RETURN NEW; END IF;
  v_amt := GREATEST(COALESCE(NEW.debit,0), COALESCE(NEW.credit,0));
  IF v_amt = 0 THEN RETURN NEW; END IF;
  v_cash := public.fn_account_or_suspense('1111');
  v_susp := public.fn_account_or_suspense('2999');
  INSERT INTO public.journal_entries
    (entry_date, description, entry_type, reference,
     source_table, source_id, posted, posted_at)
  VALUES (NEW.date, NEW.description, 'petty_cash', COALESCE(NEW.reference, NEW.id::text),
          'petty_cash_transactions', NEW.id, true, now())
  RETURNING id INTO v_entry_id;
  IF COALESCE(NEW.debit,0) > 0 THEN
    INSERT INTO public.journal_lines (journal_entry_id, account_id, debit, credit, memo) VALUES
      (v_entry_id, v_cash, v_amt, 0,     NEW.description),
      (v_entry_id, v_susp, 0,     v_amt, NEW.description);
  ELSE
    INSERT INTO public.journal_lines (journal_entry_id, account_id, debit, credit, memo) VALUES
      (v_entry_id, v_susp, v_amt, 0,     NEW.description),
      (v_entry_id, v_cash, 0,     v_amt, NEW.description);
  END IF;
  NEW.journal_entry_id := v_entry_id;
  RETURN NEW;
END $$;
DROP TRIGGER IF EXISTS trg_auto_post_petty_cash ON public.petty_cash_transactions;
CREATE TRIGGER trg_auto_post_petty_cash BEFORE INSERT ON public.petty_cash_transactions
  FOR EACH ROW EXECUTE FUNCTION public.fn_auto_post_petty_cash();

-- PAYROLL
CREATE OR REPLACE FUNCTION public.fn_auto_post_payroll()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE v_entry_id uuid;
  v_gross numeric; v_net numeric; v_inssE numeric; v_inssR numeric; v_irps numeric;
  v_salaryExp uuid; v_inssExp uuid; v_netPay uuid; v_inssPay uuid; v_irpsPay uuid; v_date date;
BEGIN
  IF NEW.journal_entry_id IS NOT NULL THEN RETURN NEW; END IF;
  v_gross := COALESCE(NEW.total_gross, 0);
  v_net   := COALESCE(NEW.total_net,   0);
  v_inssE := COALESCE(NEW.total_inss_employee, 0);
  v_inssR := COALESCE(NEW.total_inss_employer, 0);
  v_irps  := COALESCE(NEW.total_irps,  0);
  IF v_gross = 0 AND v_net = 0 THEN RETURN NEW; END IF;
  v_salaryExp := public.fn_account_or_suspense('6311');
  v_inssExp   := public.fn_account_or_suspense('6312');
  v_netPay    := public.fn_account_or_suspense('2511');
  v_inssPay   := public.fn_account_or_suspense('2451');
  v_irpsPay   := public.fn_account_or_suspense('2452');
  v_date := MAKE_DATE(NEW.year, NEW.month, 28);
  INSERT INTO public.journal_entries
    (entry_date, description, entry_type, reference,
     source_table, source_id, posted, posted_at)
  VALUES (v_date, 'Payroll ' || NEW.year || '-' || LPAD(NEW.month::text, 2, '0'),
          'payroll', NEW.id::text, 'salary_runs', NEW.id, true, now())
  RETURNING id INTO v_entry_id;
  INSERT INTO public.journal_lines (journal_entry_id, account_id, debit, credit, memo) VALUES
    (v_entry_id, v_salaryExp, v_gross, 0,                'Salaries gross'),
    (v_entry_id, v_inssExp,   v_inssR, 0,                'INSS employer 4%'),
    (v_entry_id, v_netPay,    0,       v_net,            'Net pay payable'),
    (v_entry_id, v_inssPay,   0,       v_inssE+v_inssR,  'INSS payable'),
    (v_entry_id, v_irpsPay,   0,       v_irps,           'IRPS payable');
  NEW.journal_entry_id := v_entry_id;
  RETURN NEW;
END $$;
DROP TRIGGER IF EXISTS trg_auto_post_payroll ON public.salary_runs;
CREATE TRIGGER trg_auto_post_payroll BEFORE INSERT ON public.salary_runs
  FOR EACH ROW EXECUTE FUNCTION public.fn_auto_post_payroll();

-- ============================================================
-- DONE.  Now run db/init/09_data_snapshot.sql to load the data.
-- ============================================================

-- =====================================================================
-- Release 2 — Budgets & aging (added 2026-04-30)
-- =====================================================================
CREATE TABLE IF NOT EXISTS public.budgets (
  id uuid NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  account_id uuid NOT NULL REFERENCES public.accounts(id) ON DELETE CASCADE,
  year integer NOT NULL,
  month integer NOT NULL CHECK (month BETWEEN 1 AND 12),
  amount numeric NOT NULL DEFAULT 0,
  property_id uuid REFERENCES public.properties(id) ON DELETE SET NULL,
  note text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  created_by uuid
);
CREATE UNIQUE INDEX IF NOT EXISTS budgets_unique_idx
  ON public.budgets (account_id, year, month, COALESCE(property_id, '00000000-0000-0000-0000-000000000000'::uuid));
CREATE INDEX IF NOT EXISTS budgets_year_month_idx ON public.budgets(year, month);

ALTER TABLE public.supplier_invoices
  ADD COLUMN IF NOT EXISTS due_date date,
  ADD COLUMN IF NOT EXISTS paid_amount numeric NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS status text NOT NULL DEFAULT 'open';

ALTER TABLE public.invoices
  ADD COLUMN IF NOT EXISTS paid_amount numeric NOT NULL DEFAULT 0;
