-- ============================================================
-- LANACC — Full Supabase Cloud Schema (fresh project bootstrap)
-- Run this ONCE in the Supabase SQL Editor of a brand-new project.
-- Safe to re-run: drops & recreates the public schema first.
--
-- After running:
--   1. Create your admin user via Supabase Auth (Dashboard > Authentication > Add user).
--   2. INSERT INTO public.user_roles (user_id, role) VALUES ('<that-uuid>', 'admin');
--   3. Use the Sync button in the app to push local data up.
-- ============================================================

-- ---------- 0. Reset public schema ----------
DROP SCHEMA IF EXISTS public CASCADE;
CREATE SCHEMA public;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO anon, authenticated, service_role;

-- ---------- 1. Extensions ----------
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ---------- 2. Enums ----------
DO $$ BEGIN
  CREATE TYPE public.app_role AS ENUM ('admin','viewer');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- ============================================================
-- 3. CORE TABLES
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
  property_code        text,
  ownership_percentage numeric,
  created_at           timestamptz NOT NULL DEFAULT now(),
  updated_at           timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE public.profiles (
  id           uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id      uuid NOT NULL UNIQUE,
  display_name text,
  email        text,
  created_at   timestamptz NOT NULL DEFAULT now(),
  updated_at   timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE public.user_roles (
  id      uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  role    public.app_role NOT NULL,
  UNIQUE (user_id, role)
);

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
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  entry_date  date NOT NULL,
  reference   text,
  description text NOT NULL,
  entry_type  text NOT NULL,
  property_id uuid,
  posted      boolean NOT NULL DEFAULT false,
  posted_at   timestamptz,
  posted_by   uuid,
  created_by  uuid,
  created_at  timestamptz NOT NULL DEFAULT now()
);

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

CREATE SEQUENCE IF NOT EXISTS public.invoice_seq START 1;

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
-- 4. FUNCTIONS & TRIGGERS
-- ============================================================

CREATE OR REPLACE FUNCTION public.has_role(_user_id uuid, _role public.app_role)
RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.user_roles WHERE user_id = _user_id AND role = _role
  )
$$;

CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS trigger LANGUAGE plpgsql SET search_path = public AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
BEGIN
  INSERT INTO public.profiles (user_id, email, display_name)
  VALUES (NEW.id, NEW.email, COALESCE(NEW.raw_user_meta_data->>'display_name', NEW.email));
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ============================================================
-- 5. ROW LEVEL SECURITY
-- ============================================================

-- profiles: user owns their row
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own profile"   ON public.profiles FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own profile" ON public.profiles FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own profile" ON public.profiles FOR UPDATE USING (auth.uid() = user_id);

-- user_roles
ALTER TABLE public.user_roles ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own roles" ON public.user_roles FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Admins can manage roles"  ON public.user_roles FOR ALL USING (public.has_role(auth.uid(), 'admin'));

-- Generic pattern for all business tables: authenticated may SELECT, admins may do everything
DO $$
DECLARE
  t text;
  business_tables text[] := ARRAY[
    'properties','shareholders','accounts','journal_entries','journal_lines',
    'accounting_periods','bank_accounts','bank_opening_balances','bank_transactions',
    'expense_categories','income_transactions','expense_transactions',
    'employees','salary_runs','salary_lines','salary_advances','bim_salary_transfers',
    'inss_payments','irps_payments','exchange_rates','shareholder_balances','import_log',
    'invoices','suppliers','supplier_invoices','petty_cash_transactions',
    'cash_sheets','cash_transactions','cash_allocation_columns','cash_dropdown_options'
  ];
BEGIN
  FOREACH t IN ARRAY business_tables LOOP
    EXECUTE format('ALTER TABLE public.%I ENABLE ROW LEVEL SECURITY', t);
    EXECUTE format('CREATE POLICY "Auth can view %1$s"     ON public.%1$I FOR SELECT TO authenticated USING (true)', t);
    EXECUTE format('CREATE POLICY "Admins can manage %1$s" ON public.%1$I FOR ALL    TO authenticated USING (public.has_role(auth.uid(), ''admin'')) WITH CHECK (public.has_role(auth.uid(), ''admin''))', t);
  END LOOP;
END $$;

-- ============================================================
-- DONE.
-- Next steps in the Supabase Dashboard:
--   1. Authentication > Users > Add user (email + password). Copy the new user UUID.
--   2. SQL Editor:
--        INSERT INTO public.user_roles (user_id, role) VALUES ('<uuid-here>', 'admin');
--   3. Project Settings > API > copy:
--        - Project URL                 -> VITE_SUPABASE_URL / SUPABASE_URL
--        - anon public key             -> VITE_SUPABASE_PUBLISHABLE_KEY
--        - service_role key (secret!)  -> SUPABASE_SERVICE_ROLE_KEY (.env.local only, NEVER commit)
--   4. Update .env.local on the local machine, restart Docker, and use the Sync button (Pull/Push).
-- ============================================================
