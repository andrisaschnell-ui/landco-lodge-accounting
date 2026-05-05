--
-- PostgreSQL database dump
--

\restrict f173P5RhBKT8YzKcLcKg1iCWLVwWkZcOAZUBy2dKR92HJreNJ8IjjZjiFiByjIl

-- Dumped from database version 17.9
-- Dumped by pg_dump version 17.9

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

DROP POLICY IF EXISTS "Users can view own roles" ON public.user_roles;
DROP POLICY IF EXISTS "Users can view own profile" ON public.profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON public.profiles;
DROP POLICY IF EXISTS "Users can insert own profile" ON public.profiles;
DROP POLICY IF EXISTS "Auth can view suppliers" ON public.suppliers;
DROP POLICY IF EXISTS "Auth can view supplier_invoices" ON public.supplier_invoices;
DROP POLICY IF EXISTS "Auth can view shareholders" ON public.shareholders;
DROP POLICY IF EXISTS "Auth can view salary_runs" ON public.salary_runs;
DROP POLICY IF EXISTS "Auth can view salary_lines" ON public.salary_lines;
DROP POLICY IF EXISTS "Auth can view salary_advances" ON public.salary_advances;
DROP POLICY IF EXISTS "Auth can view rates" ON public.exchange_rates;
DROP POLICY IF EXISTS "Auth can view properties" ON public.properties;
DROP POLICY IF EXISTS "Auth can view petty_cash" ON public.petty_cash_transactions;
DROP POLICY IF EXISTS "Auth can view journal_lines" ON public.journal_lines;
DROP POLICY IF EXISTS "Auth can view journal_entries" ON public.journal_entries;
DROP POLICY IF EXISTS "Auth can view irps" ON public.irps_payments;
DROP POLICY IF EXISTS "Auth can view invoices" ON public.invoices;
DROP POLICY IF EXISTS "Auth can view inss" ON public.inss_payments;
DROP POLICY IF EXISTS "Auth can view income" ON public.income_transactions;
DROP POLICY IF EXISTS "Auth can view imports" ON public.import_log;
DROP POLICY IF EXISTS "Auth can view expenses" ON public.expense_transactions;
DROP POLICY IF EXISTS "Auth can view expense_categories" ON public.expense_categories;
DROP POLICY IF EXISTS "Auth can view employees" ON public.employees;
DROP POLICY IF EXISTS "Auth can view cash_tx" ON public.cash_transactions;
DROP POLICY IF EXISTS "Auth can view cash_sheets" ON public.cash_sheets;
DROP POLICY IF EXISTS "Auth can view cash_dropdown" ON public.cash_dropdown_options;
DROP POLICY IF EXISTS "Auth can view cash_alloc_cols" ON public.cash_allocation_columns;
DROP POLICY IF EXISTS "Auth can view bim_transfers" ON public.bim_salary_transfers;
DROP POLICY IF EXISTS "Auth can view bank_tx" ON public.bank_transactions;
DROP POLICY IF EXISTS "Auth can view bank_opening_balances" ON public.bank_opening_balances;
DROP POLICY IF EXISTS "Auth can view bank_accounts" ON public.bank_accounts;
DROP POLICY IF EXISTS "Auth can view balances" ON public.shareholder_balances;
DROP POLICY IF EXISTS "Auth can view accounts" ON public.accounts;
DROP POLICY IF EXISTS "Auth can view accounting_periods" ON public.accounting_periods;
DROP POLICY IF EXISTS "Admins can manage suppliers" ON public.suppliers;
DROP POLICY IF EXISTS "Admins can manage supplier_invoices" ON public.supplier_invoices;
DROP POLICY IF EXISTS "Admins can manage shareholders" ON public.shareholders;
DROP POLICY IF EXISTS "Admins can manage salary_runs" ON public.salary_runs;
DROP POLICY IF EXISTS "Admins can manage salary_lines" ON public.salary_lines;
DROP POLICY IF EXISTS "Admins can manage salary_advances" ON public.salary_advances;
DROP POLICY IF EXISTS "Admins can manage roles" ON public.user_roles;
DROP POLICY IF EXISTS "Admins can manage rates" ON public.exchange_rates;
DROP POLICY IF EXISTS "Admins can manage properties" ON public.properties;
DROP POLICY IF EXISTS "Admins can manage petty_cash" ON public.petty_cash_transactions;
DROP POLICY IF EXISTS "Admins can manage journal_lines" ON public.journal_lines;
DROP POLICY IF EXISTS "Admins can manage journal_entries" ON public.journal_entries;
DROP POLICY IF EXISTS "Admins can manage irps" ON public.irps_payments;
DROP POLICY IF EXISTS "Admins can manage invoices" ON public.invoices;
DROP POLICY IF EXISTS "Admins can manage inss" ON public.inss_payments;
DROP POLICY IF EXISTS "Admins can manage income" ON public.income_transactions;
DROP POLICY IF EXISTS "Admins can manage imports" ON public.import_log;
DROP POLICY IF EXISTS "Admins can manage expenses" ON public.expense_transactions;
DROP POLICY IF EXISTS "Admins can manage expense_categories" ON public.expense_categories;
DROP POLICY IF EXISTS "Admins can manage employees" ON public.employees;
DROP POLICY IF EXISTS "Admins can manage cash_tx" ON public.cash_transactions;
DROP POLICY IF EXISTS "Admins can manage cash_sheets" ON public.cash_sheets;
DROP POLICY IF EXISTS "Admins can manage cash_dropdown" ON public.cash_dropdown_options;
DROP POLICY IF EXISTS "Admins can manage cash_alloc_cols" ON public.cash_allocation_columns;
DROP POLICY IF EXISTS "Admins can manage bim_transfers" ON public.bim_salary_transfers;
DROP POLICY IF EXISTS "Admins can manage bank_tx" ON public.bank_transactions;
DROP POLICY IF EXISTS "Admins can manage bank_opening_balances" ON public.bank_opening_balances;
DROP POLICY IF EXISTS "Admins can manage bank_accounts" ON public.bank_accounts;
DROP POLICY IF EXISTS "Admins can manage balances" ON public.shareholder_balances;
DROP POLICY IF EXISTS "Admins can manage accounts" ON public.accounts;
DROP POLICY IF EXISTS "Admins can manage accounting_periods" ON public.accounting_periods;
ALTER TABLE IF EXISTS ONLY public.supplier_invoices DROP CONSTRAINT IF EXISTS supplier_invoices_supplier_id_fkey;
ALTER TABLE IF EXISTS ONLY public.supplier_invoices DROP CONSTRAINT IF EXISTS supplier_invoices_journal_entry_id_fkey;
ALTER TABLE IF EXISTS ONLY public.shareholders DROP CONSTRAINT IF EXISTS shareholders_property_code_fkey;
ALTER TABLE IF EXISTS ONLY public.shareholder_balances DROP CONSTRAINT IF EXISTS shareholder_balances_shareholder_id_fkey;
ALTER TABLE IF EXISTS ONLY public.shareholder_balances DROP CONSTRAINT IF EXISTS shareholder_balances_property_id_fkey;
ALTER TABLE IF EXISTS ONLY public.salary_runs DROP CONSTRAINT IF EXISTS salary_runs_journal_entry_id_fkey;
ALTER TABLE IF EXISTS ONLY public.salary_lines DROP CONSTRAINT IF EXISTS salary_lines_salary_run_id_fkey;
ALTER TABLE IF EXISTS ONLY public.salary_lines DROP CONSTRAINT IF EXISTS salary_lines_employee_id_fkey;
ALTER TABLE IF EXISTS ONLY public.salary_advances DROP CONSTRAINT IF EXISTS salary_advances_employee_id_fkey;
ALTER TABLE IF EXISTS ONLY public.petty_cash_transactions DROP CONSTRAINT IF EXISTS petty_cash_transactions_journal_entry_id_fkey;
ALTER TABLE IF EXISTS ONLY public.journal_lines DROP CONSTRAINT IF EXISTS journal_lines_journal_entry_id_fkey;
ALTER TABLE IF EXISTS ONLY public.journal_lines DROP CONSTRAINT IF EXISTS journal_lines_account_id_fkey;
ALTER TABLE IF EXISTS ONLY public.invoices DROP CONSTRAINT IF EXISTS invoices_journal_entry_id_fkey;
ALTER TABLE IF EXISTS ONLY public.income_transactions DROP CONSTRAINT IF EXISTS income_transactions_property_id_fkey;
ALTER TABLE IF EXISTS ONLY public.income_transactions DROP CONSTRAINT IF EXISTS income_transactions_journal_entry_id_fkey;
ALTER TABLE IF EXISTS ONLY public.import_log DROP CONSTRAINT IF EXISTS import_log_imported_by_fkey;
ALTER TABLE IF EXISTS ONLY public.expense_transactions DROP CONSTRAINT IF EXISTS expense_transactions_shareholder_id_fkey;
ALTER TABLE IF EXISTS ONLY public.expense_transactions DROP CONSTRAINT IF EXISTS expense_transactions_property_id_fkey;
ALTER TABLE IF EXISTS ONLY public.expense_transactions DROP CONSTRAINT IF EXISTS expense_transactions_journal_entry_id_fkey;
ALTER TABLE IF EXISTS ONLY public.expense_transactions DROP CONSTRAINT IF EXISTS expense_transactions_category_id_fkey;
ALTER TABLE IF EXISTS ONLY public.expense_categories DROP CONSTRAINT IF EXISTS expense_categories_parent_id_fkey;
ALTER TABLE IF EXISTS ONLY public.cash_transactions DROP CONSTRAINT IF EXISTS cash_transactions_sheet_id_fkey;
ALTER TABLE IF EXISTS ONLY public.bim_salary_transfers DROP CONSTRAINT IF EXISTS bim_salary_transfers_salary_run_id_fkey;
ALTER TABLE IF EXISTS ONLY public.bim_salary_transfers DROP CONSTRAINT IF EXISTS bim_salary_transfers_employee_id_fkey;
ALTER TABLE IF EXISTS ONLY public.bank_transactions DROP CONSTRAINT IF EXISTS bank_transactions_journal_entry_id_fkey;
ALTER TABLE IF EXISTS ONLY public.bank_transactions DROP CONSTRAINT IF EXISTS bank_transactions_bank_account_id_fkey;
ALTER TABLE IF EXISTS ONLY public.bank_opening_balances DROP CONSTRAINT IF EXISTS bank_opening_balances_bank_account_id_fkey;
DROP TRIGGER IF EXISTS update_shareholders_updated_at ON public.shareholders;
DROP TRIGGER IF EXISTS update_properties_updated_at ON public.properties;
DROP TRIGGER IF EXISTS update_profiles_updated_at ON public.profiles;
DROP TRIGGER IF EXISTS update_employees_updated_at ON public.employees;
DROP TRIGGER IF EXISTS update_bank_opening_balances_updated_at ON public.bank_opening_balances;
DROP TRIGGER IF EXISTS trg_invoices_updated_at ON public.invoices;
DROP TRIGGER IF EXISTS trg_cash_tx_updated ON public.cash_transactions;
DROP TRIGGER IF EXISTS trg_cash_sheets_updated ON public.cash_sheets;
DROP INDEX IF EXISTS public.idx_cash_tx_sheet;
DROP INDEX IF EXISTS public.idx_cash_tx_receiver;
DROP INDEX IF EXISTS public.idx_cash_tx_funder;
DROP INDEX IF EXISTS public.idx_cash_dropdown_lookup;
ALTER TABLE IF EXISTS ONLY public.user_roles DROP CONSTRAINT IF EXISTS user_roles_user_id_role_key;
ALTER TABLE IF EXISTS ONLY public.user_roles DROP CONSTRAINT IF EXISTS user_roles_pkey;
ALTER TABLE IF EXISTS ONLY public.suppliers DROP CONSTRAINT IF EXISTS suppliers_pkey;
ALTER TABLE IF EXISTS ONLY public.supplier_invoices DROP CONSTRAINT IF EXISTS supplier_invoices_pkey;
ALTER TABLE IF EXISTS ONLY public.shareholders DROP CONSTRAINT IF EXISTS shareholders_pkey;
ALTER TABLE IF EXISTS ONLY public.shareholder_balances DROP CONSTRAINT IF EXISTS shareholder_balances_shareholder_id_property_id_month_year_key;
ALTER TABLE IF EXISTS ONLY public.shareholder_balances DROP CONSTRAINT IF EXISTS shareholder_balances_pkey;
ALTER TABLE IF EXISTS ONLY public.salary_runs DROP CONSTRAINT IF EXISTS salary_runs_pkey;
ALTER TABLE IF EXISTS ONLY public.salary_runs DROP CONSTRAINT IF EXISTS salary_runs_month_year_key;
ALTER TABLE IF EXISTS ONLY public.salary_lines DROP CONSTRAINT IF EXISTS salary_lines_pkey;
ALTER TABLE IF EXISTS ONLY public.salary_advances DROP CONSTRAINT IF EXISTS salary_advances_pkey;
ALTER TABLE IF EXISTS ONLY public.properties DROP CONSTRAINT IF EXISTS properties_pkey;
ALTER TABLE IF EXISTS ONLY public.properties DROP CONSTRAINT IF EXISTS properties_code_key;
ALTER TABLE IF EXISTS ONLY public.profiles DROP CONSTRAINT IF EXISTS profiles_user_id_key;
ALTER TABLE IF EXISTS ONLY public.profiles DROP CONSTRAINT IF EXISTS profiles_pkey;
ALTER TABLE IF EXISTS ONLY public.petty_cash_transactions DROP CONSTRAINT IF EXISTS petty_cash_transactions_pkey;
ALTER TABLE IF EXISTS ONLY public.journal_lines DROP CONSTRAINT IF EXISTS journal_lines_pkey;
ALTER TABLE IF EXISTS ONLY public.journal_entries DROP CONSTRAINT IF EXISTS journal_entries_pkey;
ALTER TABLE IF EXISTS ONLY public.irps_payments DROP CONSTRAINT IF EXISTS irps_payments_pkey;
ALTER TABLE IF EXISTS ONLY public.invoices DROP CONSTRAINT IF EXISTS invoices_pkey;
ALTER TABLE IF EXISTS ONLY public.inss_payments DROP CONSTRAINT IF EXISTS inss_payments_pkey;
ALTER TABLE IF EXISTS ONLY public.income_transactions DROP CONSTRAINT IF EXISTS income_transactions_pkey;
ALTER TABLE IF EXISTS ONLY public.import_log DROP CONSTRAINT IF EXISTS import_log_pkey;
ALTER TABLE IF EXISTS ONLY public.expense_transactions DROP CONSTRAINT IF EXISTS expense_transactions_pkey;
ALTER TABLE IF EXISTS ONLY public.expense_categories DROP CONSTRAINT IF EXISTS expense_categories_pkey;
ALTER TABLE IF EXISTS ONLY public.expense_categories DROP CONSTRAINT IF EXISTS expense_categories_name_key;
ALTER TABLE IF EXISTS ONLY public.exchange_rates DROP CONSTRAINT IF EXISTS exchange_rates_pkey;
ALTER TABLE IF EXISTS ONLY public.exchange_rates DROP CONSTRAINT IF EXISTS exchange_rates_month_year_key;
ALTER TABLE IF EXISTS ONLY public.employees DROP CONSTRAINT IF EXISTS employees_pkey;
ALTER TABLE IF EXISTS ONLY public.cash_transactions DROP CONSTRAINT IF EXISTS cash_transactions_pkey;
ALTER TABLE IF EXISTS ONLY public.cash_sheets DROP CONSTRAINT IF EXISTS cash_sheets_sheet_type_month_year_key;
ALTER TABLE IF EXISTS ONLY public.cash_sheets DROP CONSTRAINT IF EXISTS cash_sheets_pkey;
ALTER TABLE IF EXISTS ONLY public.cash_dropdown_options DROP CONSTRAINT IF EXISTS cash_dropdown_options_sheet_type_column_key_value_key;
ALTER TABLE IF EXISTS ONLY public.cash_dropdown_options DROP CONSTRAINT IF EXISTS cash_dropdown_options_pkey;
ALTER TABLE IF EXISTS ONLY public.cash_allocation_columns DROP CONSTRAINT IF EXISTS cash_allocation_columns_sheet_type_column_name_key;
ALTER TABLE IF EXISTS ONLY public.cash_allocation_columns DROP CONSTRAINT IF EXISTS cash_allocation_columns_pkey;
ALTER TABLE IF EXISTS ONLY public.bim_salary_transfers DROP CONSTRAINT IF EXISTS bim_salary_transfers_pkey;
ALTER TABLE IF EXISTS ONLY public.bank_transactions DROP CONSTRAINT IF EXISTS bank_transactions_pkey;
ALTER TABLE IF EXISTS ONLY public.bank_opening_balances DROP CONSTRAINT IF EXISTS bank_opening_balances_pkey;
ALTER TABLE IF EXISTS ONLY public.bank_opening_balances DROP CONSTRAINT IF EXISTS bank_opening_balances_bank_account_id_month_year_key;
ALTER TABLE IF EXISTS ONLY public.bank_accounts DROP CONSTRAINT IF EXISTS bank_accounts_pkey;
ALTER TABLE IF EXISTS ONLY public.accounts DROP CONSTRAINT IF EXISTS accounts_pkey;
ALTER TABLE IF EXISTS ONLY public.accounts DROP CONSTRAINT IF EXISTS accounts_code_key;
ALTER TABLE IF EXISTS ONLY public.accounting_periods DROP CONSTRAINT IF EXISTS accounting_periods_year_month_key;
ALTER TABLE IF EXISTS ONLY public.accounting_periods DROP CONSTRAINT IF EXISTS accounting_periods_pkey;
ALTER TABLE IF EXISTS ONLY auth.users DROP CONSTRAINT IF EXISTS users_pkey;
ALTER TABLE IF EXISTS ONLY auth.users DROP CONSTRAINT IF EXISTS users_email_key;
DROP TABLE IF EXISTS public.user_roles;
DROP TABLE IF EXISTS public.suppliers;
DROP TABLE IF EXISTS public.supplier_invoices;
DROP TABLE IF EXISTS public.shareholders;
DROP TABLE IF EXISTS public.shareholder_balances;
DROP TABLE IF EXISTS public.salary_runs;
DROP TABLE IF EXISTS public.salary_lines;
DROP TABLE IF EXISTS public.salary_advances;
DROP TABLE IF EXISTS public.properties;
DROP TABLE IF EXISTS public.profiles;
DROP TABLE IF EXISTS public.petty_cash_transactions;
DROP TABLE IF EXISTS public.journal_lines;
DROP TABLE IF EXISTS public.journal_entries;
DROP TABLE IF EXISTS public.irps_payments;
DROP TABLE IF EXISTS public.invoices;
DROP SEQUENCE IF EXISTS public.invoice_seq;
DROP TABLE IF EXISTS public.inss_payments;
DROP TABLE IF EXISTS public.income_transactions;
DROP TABLE IF EXISTS public.import_log;
DROP TABLE IF EXISTS public.expense_transactions;
DROP TABLE IF EXISTS public.expense_categories;
DROP TABLE IF EXISTS public.exchange_rates;
DROP TABLE IF EXISTS public.employees;
DROP TABLE IF EXISTS public.cash_transactions;
DROP TABLE IF EXISTS public.cash_sheets;
DROP TABLE IF EXISTS public.cash_dropdown_options;
DROP TABLE IF EXISTS public.cash_allocation_columns;
DROP TABLE IF EXISTS public.bim_salary_transfers;
DROP TABLE IF EXISTS public.bank_transactions;
DROP TABLE IF EXISTS public.bank_opening_balances;
DROP TABLE IF EXISTS public.bank_accounts;
DROP TABLE IF EXISTS public.accounts;
DROP TABLE IF EXISTS public.accounting_periods;
DROP TABLE IF EXISTS auth.users;
DROP FUNCTION IF EXISTS public.update_updated_at_column();
DROP FUNCTION IF EXISTS public.has_role(_user_id uuid, _role public.app_role);
DROP FUNCTION IF EXISTS public.handle_new_user();
DROP FUNCTION IF EXISTS auth.uid();
DROP TYPE IF EXISTS public.app_role;
-- *not* dropping schema, since initdb creates it
DROP SCHEMA IF EXISTS auth;
--
-- Name: auth; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA auth;


ALTER SCHEMA auth OWNER TO postgres;

--
-- Name: public; Type: SCHEMA; Schema: -; Owner: postgres
--

-- *not* creating schema, since initdb creates it


ALTER SCHEMA public OWNER TO postgres;

--
-- Name: app_role; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.app_role AS ENUM (
    'admin',
    'viewer'
);


ALTER TYPE public.app_role OWNER TO postgres;

--
-- Name: uid(); Type: FUNCTION; Schema: auth; Owner: postgres
--

CREATE FUNCTION auth.uid() RETURNS uuid
    LANGUAGE sql STABLE
    AS $$ SELECT NULL::uuid $$;


ALTER FUNCTION auth.uid() OWNER TO postgres;

--
-- Name: handle_new_user(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.handle_new_user() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
BEGIN
  INSERT INTO public.profiles (user_id, email, display_name)
  VALUES (NEW.id, NEW.email, COALESCE(NEW.raw_user_meta_data->>'display_name', NEW.email));
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.handle_new_user() OWNER TO postgres;

--
-- Name: has_role(uuid, public.app_role); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.has_role(_user_id uuid, _role public.app_role) RETURNS boolean
    LANGUAGE sql STABLE SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.user_roles
    WHERE user_id = _user_id AND role = _role
  )
$$;


ALTER FUNCTION public.has_role(_user_id uuid, _role public.app_role) OWNER TO postgres;

--
-- Name: update_updated_at_column(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_updated_at_column() RETURNS trigger
    LANGUAGE plpgsql
    SET search_path TO 'public'
    AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_updated_at_column() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: users; Type: TABLE; Schema: auth; Owner: postgres
--

CREATE TABLE auth.users (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    email text NOT NULL,
    password_hash text NOT NULL,
    display_name text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE auth.users OWNER TO postgres;

--
-- Name: accounting_periods; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.accounting_periods (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    year integer NOT NULL,
    month integer NOT NULL,
    is_closed boolean DEFAULT false NOT NULL,
    closed_at timestamp with time zone,
    closed_by uuid
);


ALTER TABLE public.accounting_periods OWNER TO postgres;

--
-- Name: accounts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.accounts (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    code text NOT NULL,
    name text NOT NULL,
    account_class integer NOT NULL,
    account_type text NOT NULL,
    normal_side text NOT NULL,
    parent_code text,
    is_active boolean DEFAULT true NOT NULL,
    pgc_class text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT accounts_normal_side_check CHECK ((normal_side = ANY (ARRAY['debit'::text, 'credit'::text])))
);


ALTER TABLE public.accounts OWNER TO postgres;

--
-- Name: bank_accounts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.bank_accounts (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name text NOT NULL,
    bank_name text NOT NULL,
    account_number text,
    currency text DEFAULT 'MZN'::text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    pgc_account_code text
);


ALTER TABLE public.bank_accounts OWNER TO postgres;

--
-- Name: bank_opening_balances; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.bank_opening_balances (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    bank_account_id uuid NOT NULL,
    month integer NOT NULL,
    year integer NOT NULL,
    opening_balance numeric DEFAULT 0 NOT NULL,
    source_file text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.bank_opening_balances OWNER TO postgres;

--
-- Name: bank_transactions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.bank_transactions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    date date,
    bank_account_id uuid,
    description text NOT NULL,
    debit numeric(14,2) DEFAULT 0,
    credit numeric(14,2) DEFAULT 0,
    balance numeric(14,2) DEFAULT 0,
    reference text,
    month integer NOT NULL,
    year integer NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    journal_entry_id uuid,
    CONSTRAINT bank_transactions_month_check CHECK (((month >= 1) AND (month <= 12)))
);


ALTER TABLE public.bank_transactions OWNER TO postgres;

--
-- Name: bim_salary_transfers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.bim_salary_transfers (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    salary_run_id uuid,
    employee_id uuid,
    nib text,
    name text NOT NULL,
    amount numeric(12,2) NOT NULL,
    description text,
    month integer NOT NULL,
    year integer NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT bim_salary_transfers_month_check CHECK (((month >= 1) AND (month <= 12)))
);


ALTER TABLE public.bim_salary_transfers OWNER TO postgres;

--
-- Name: cash_allocation_columns; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cash_allocation_columns (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    sheet_type text NOT NULL,
    column_name text NOT NULL,
    sort_order integer DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT cash_allocation_columns_sheet_type_check CHECK ((sheet_type = ANY (ARRAY['petty_cash'::text, 'emola'::text, 'mpesa'::text])))
);


ALTER TABLE public.cash_allocation_columns OWNER TO postgres;

--
-- Name: cash_dropdown_options; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cash_dropdown_options (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    sheet_type text NOT NULL,
    column_key text NOT NULL,
    value text NOT NULL,
    sort_order integer DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT cash_dropdown_options_sheet_type_check CHECK ((sheet_type = ANY (ARRAY['petty_cash'::text, 'emola'::text, 'mpesa'::text, 'all'::text])))
);


ALTER TABLE public.cash_dropdown_options OWNER TO postgres;

--
-- Name: cash_sheets; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cash_sheets (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    sheet_type text NOT NULL,
    month integer,
    year integer NOT NULL,
    opening_balance numeric DEFAULT 0 NOT NULL,
    opening_description text,
    source_file text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT cash_sheets_sheet_type_check CHECK ((sheet_type = ANY (ARRAY['petty_cash'::text, 'emola'::text, 'mpesa'::text])))
);


ALTER TABLE public.cash_sheets OWNER TO postgres;

--
-- Name: cash_transactions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cash_transactions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    sheet_type text NOT NULL,
    sheet_id uuid,
    row_no integer,
    tx_date date,
    month integer NOT NULL,
    year integer NOT NULL,
    description text,
    funder text,
    receiver text,
    cell_no text,
    cheque_no text,
    company text,
    entrada numeric DEFAULT 0,
    saida numeric DEFAULT 0,
    bank_charges numeric DEFAULT 0,
    balance numeric,
    allocation_column text,
    allocation_amount numeric DEFAULT 0,
    allocations jsonb DEFAULT '{}'::jsonb NOT NULL,
    source_file text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT cash_transactions_sheet_type_check CHECK ((sheet_type = ANY (ARRAY['petty_cash'::text, 'emola'::text, 'mpesa'::text])))
);


ALTER TABLE public.cash_transactions OWNER TO postgres;

--
-- Name: employees; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.employees (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name text NOT NULL,
    category text,
    nib text,
    nuit text,
    base_salary numeric(12,2) DEFAULT 0 NOT NULL,
    food_allowance numeric(12,2) DEFAULT 0,
    house_assignment text,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.employees OWNER TO postgres;

--
-- Name: exchange_rates; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.exchange_rates (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    month integer NOT NULL,
    year integer NOT NULL,
    mzn_per_usd numeric(10,4) NOT NULL,
    mzn_per_zar numeric(10,4),
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT exchange_rates_month_check CHECK (((month >= 1) AND (month <= 12)))
);


ALTER TABLE public.exchange_rates OWNER TO postgres;

--
-- Name: expense_categories; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.expense_categories (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name text NOT NULL,
    is_shared boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    pgc_account_code text,
    name_en text,
    name_pt text,
    category_type text,
    parent_id uuid
);


ALTER TABLE public.expense_categories OWNER TO postgres;

--
-- Name: expense_transactions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.expense_transactions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    date date,
    property_id uuid,
    shareholder_id uuid,
    category_id uuid,
    description text NOT NULL,
    amount_mzn numeric(14,2) DEFAULT 0 NOT NULL,
    is_shared boolean DEFAULT true NOT NULL,
    month integer NOT NULL,
    year integer NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    journal_entry_id uuid,
    CONSTRAINT expense_transactions_month_check CHECK (((month >= 1) AND (month <= 12)))
);


ALTER TABLE public.expense_transactions OWNER TO postgres;

--
-- Name: import_log; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.import_log (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    filename text NOT NULL,
    file_type text NOT NULL,
    month integer,
    year integer,
    records_imported integer DEFAULT 0,
    status text DEFAULT 'pending'::text NOT NULL,
    imported_by uuid,
    error_details text,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.import_log OWNER TO postgres;

--
-- Name: income_transactions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.income_transactions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    date date NOT NULL,
    property_id uuid,
    guest_name text,
    description text,
    accommodation_amount_mzn numeric(14,2) DEFAULT 0 NOT NULL,
    amount_usd numeric(14,2) DEFAULT 0,
    month integer NOT NULL,
    year integer NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    journal_entry_id uuid,
    CONSTRAINT income_transactions_month_check CHECK (((month >= 1) AND (month <= 12)))
);


ALTER TABLE public.income_transactions OWNER TO postgres;

--
-- Name: inss_payments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.inss_payments (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    month integer NOT NULL,
    year integer NOT NULL,
    amount numeric(14,2) NOT NULL,
    payment_date date,
    reference text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT inss_payments_month_check CHECK (((month >= 1) AND (month <= 12)))
);


ALTER TABLE public.inss_payments OWNER TO postgres;

--
-- Name: invoice_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.invoice_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.invoice_seq OWNER TO postgres;

--
-- Name: invoices; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.invoices (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    invoice_number text NOT NULL,
    invoice_series text DEFAULT 'FT'::text NOT NULL,
    invoice_date date NOT NULL,
    due_date date,
    property_id uuid,
    client_name text NOT NULL,
    client_nuit text,
    client_address text,
    line_items jsonb DEFAULT '[]'::jsonb NOT NULL,
    subtotal_mzn numeric DEFAULT 0 NOT NULL,
    vat_amount_mzn numeric DEFAULT 0 NOT NULL,
    total_mzn numeric DEFAULT 0 NOT NULL,
    currency text DEFAULT 'MZN'::text NOT NULL,
    exchange_rate numeric DEFAULT 1,
    status text DEFAULT 'draft'::text NOT NULL,
    at_hash text,
    at_qr_code text,
    journal_entry_id uuid,
    income_tx_id uuid,
    issued_by uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.invoices OWNER TO postgres;

--
-- Name: irps_payments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.irps_payments (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    month integer NOT NULL,
    year integer NOT NULL,
    amount numeric(14,2) NOT NULL,
    payment_date date,
    reference text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT irps_payments_month_check CHECK (((month >= 1) AND (month <= 12)))
);


ALTER TABLE public.irps_payments OWNER TO postgres;

--
-- Name: journal_entries; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.journal_entries (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    entry_date date NOT NULL,
    reference text,
    description text NOT NULL,
    entry_type text NOT NULL,
    property_id uuid,
    posted boolean DEFAULT false NOT NULL,
    posted_at timestamp with time zone,
    posted_by uuid,
    created_by uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.journal_entries OWNER TO postgres;

--
-- Name: journal_lines; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.journal_lines (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    journal_entry_id uuid NOT NULL,
    account_id uuid NOT NULL,
    debit numeric DEFAULT 0 NOT NULL,
    credit numeric DEFAULT 0 NOT NULL,
    memo text,
    CONSTRAINT journal_lines_check CHECK (((debit = (0)::numeric) OR (credit = (0)::numeric))),
    CONSTRAINT journal_lines_credit_check CHECK ((credit >= (0)::numeric)),
    CONSTRAINT journal_lines_debit_check CHECK ((debit >= (0)::numeric))
);


ALTER TABLE public.journal_lines OWNER TO postgres;

--
-- Name: petty_cash_transactions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.petty_cash_transactions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    date date,
    description text NOT NULL,
    credit numeric(14,2) DEFAULT 0,
    debit numeric(14,2) DEFAULT 0,
    balance numeric(14,2) DEFAULT 0,
    month integer NOT NULL,
    year integer NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    reference text,
    supplier text,
    allocation text,
    vat_amount numeric DEFAULT 0,
    net_amount numeric DEFAULT 0,
    source_file text,
    journal_entry_id uuid,
    CONSTRAINT petty_cash_transactions_month_check CHECK (((month >= 1) AND (month <= 12)))
);


ALTER TABLE public.petty_cash_transactions OWNER TO postgres;

--
-- Name: profiles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.profiles (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    display_name text,
    email text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.profiles OWNER TO postgres;

--
-- Name: properties; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.properties (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name text NOT NULL,
    code text NOT NULL,
    description text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.properties OWNER TO postgres;

--
-- Name: salary_advances; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.salary_advances (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    employee_id uuid NOT NULL,
    amount numeric(12,2) NOT NULL,
    date date NOT NULL,
    description text,
    month integer NOT NULL,
    year integer NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT salary_advances_month_check CHECK (((month >= 1) AND (month <= 12)))
);


ALTER TABLE public.salary_advances OWNER TO postgres;

--
-- Name: salary_lines; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.salary_lines (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    salary_run_id uuid NOT NULL,
    employee_id uuid NOT NULL,
    base_salary numeric(12,2) DEFAULT 0,
    food_allowance numeric(12,2) DEFAULT 0,
    back_payment numeric(12,2) DEFAULT 0,
    days_worked integer DEFAULT 30,
    monthly_salary numeric(12,2) DEFAULT 0,
    nightshift_hours numeric(8,2) DEFAULT 0,
    overtime_25_percent numeric(12,2) DEFAULT 0,
    overtime_15x_hours numeric(8,2) DEFAULT 0,
    overtime_15x_amount numeric(12,2) DEFAULT 0,
    overtime_2x_hours numeric(8,2) DEFAULT 0,
    overtime_2x_amount numeric(12,2) DEFAULT 0,
    gratification numeric(12,2) DEFAULT 0,
    holiday_days integer DEFAULT 0,
    holiday_amount numeric(12,2) DEFAULT 0,
    gross_total numeric(12,2) DEFAULT 0,
    advance numeric(12,2) DEFAULT 0,
    irps numeric(12,2) DEFAULT 0,
    debt numeric(12,2) DEFAULT 0,
    inss_employee numeric(12,2) DEFAULT 0,
    sind numeric(12,2) DEFAULT 0,
    total_deductions numeric(12,2) DEFAULT 0,
    net_salary numeric(12,2) DEFAULT 0,
    nib text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    guardas_25 numeric DEFAULT 0,
    category text
);


ALTER TABLE public.salary_lines OWNER TO postgres;

--
-- Name: salary_runs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.salary_runs (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    month integer NOT NULL,
    year integer NOT NULL,
    total_gross numeric(14,2) DEFAULT 0,
    total_net numeric(14,2) DEFAULT 0,
    total_inss_employee numeric(14,2) DEFAULT 0,
    total_inss_employer numeric(14,2) DEFAULT 0,
    total_irps numeric(14,2) DEFAULT 0,
    status text DEFAULT 'draft'::text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    journal_entry_id uuid,
    CONSTRAINT salary_runs_month_check CHECK (((month >= 1) AND (month <= 12)))
);


ALTER TABLE public.salary_runs OWNER TO postgres;

--
-- Name: shareholder_balances; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.shareholder_balances (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    shareholder_id uuid NOT NULL,
    property_id uuid NOT NULL,
    month integer NOT NULL,
    year integer NOT NULL,
    opening_balance numeric(14,2) DEFAULT 0,
    income numeric(14,2) DEFAULT 0,
    expenses numeric(14,2) DEFAULT 0,
    closing_balance numeric(14,2) DEFAULT 0,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT shareholder_balances_month_check CHECK (((month >= 1) AND (month <= 12)))
);


ALTER TABLE public.shareholder_balances OWNER TO postgres;

--
-- Name: shareholders; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.shareholders (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name text NOT NULL,
    email text,
    property_code text,
    ownership_percentage numeric(5,2),
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.shareholders OWNER TO postgres;

--
-- Name: supplier_invoices; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.supplier_invoices (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    supplier_id uuid,
    invoice_number text,
    invoice_date date,
    description text,
    allocation text,
    amount_excl numeric DEFAULT 0,
    vat_amount numeric DEFAULT 0,
    total_amount numeric DEFAULT 0,
    journal_entry_id uuid,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.supplier_invoices OWNER TO postgres;

--
-- Name: suppliers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.suppliers (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name text NOT NULL,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.suppliers OWNER TO postgres;

--
-- Name: user_roles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_roles (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    role public.app_role NOT NULL
);


ALTER TABLE public.user_roles OWNER TO postgres;

--
-- Data for Name: users; Type: TABLE DATA; Schema: auth; Owner: postgres
--

COPY auth.users (id, email, password_hash, display_name, created_at, updated_at) FROM stdin;
65607621-db72-4d57-9900-6cb4a77e0828	cwschnell@gmail.com	$2a$10$BSkYe0U44VHVr44byPb0ve2.advq1cYb28PRnf6Ej7Ve9jkgynqzG	CW Schnell	2026-04-27 14:22:56.705275+00	2026-04-27 14:22:56.705275+00
f382f145-118b-4b82-b510-b88c634efd0e	andrisa.schnell@gmail.com	$2a$10$0oG9s3U1ztD0fozyForiY.R2fV/hkUFqLLh9EFqS7nb/hMQqT.5Lu	Andrisa Schnell	2026-04-27 14:22:56.727464+00	2026-04-27 14:22:56.727464+00
\.


--
-- Data for Name: accounting_periods; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.accounting_periods (id, year, month, is_closed, closed_at, closed_by) FROM stdin;
\.


--
-- Data for Name: accounts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.accounts (id, code, name, account_class, account_type, normal_side, parent_code, is_active, pgc_class, created_at) FROM stdin;
b67e88f5-4e1c-45b3-9e1a-52d922be3470	11	Caixa	1	asset	debit	\N	t	Classe 1	2026-04-19 10:25:34.274027+00
b22da86d-a963-4cba-916c-af63a51491d0	12	Dep??sitos ?? Ordem	1	asset	debit	\N	t	Classe 1	2026-04-19 10:25:34.274027+00
f3b439e2-ff15-4d85-84aa-ad1e497ad352	121	BCI ??? Conta MZN	1	asset	debit	\N	t	Classe 1	2026-04-19 10:25:34.274027+00
c096aa8f-fd2f-4a1f-8c61-7b9dee4df4ab	122	BIM ??? Conta MZN	1	asset	debit	\N	t	Classe 1	2026-04-19 10:25:34.274027+00
08c402de-5d47-45c0-906b-c54959e9bc42	123	BCI ??? Conta USD	1	asset	debit	\N	t	Classe 1	2026-04-19 10:25:34.274027+00
c31a0335-c51a-4e4e-a6a0-031f0ab068c0	211	Clientes	2	asset	debit	\N	t	Classe 2	2026-04-19 10:25:34.274027+00
4f036481-e176-460a-8cf6-557ce9308c49	221	Fornecedores	2	liability	credit	\N	t	Classe 2	2026-04-19 10:25:34.274027+00
a3ddd31e-dbae-4391-996e-455d87e1366d	231	Pessoal ??? Remunera????es a Pagar	2	liability	credit	\N	t	Classe 2	2026-04-19 10:25:34.274027+00
c25a64c7-4195-424b-a979-89beef8adff3	241	Estado ??? INSS a Pagar	2	liability	credit	\N	t	Classe 2	2026-04-19 10:25:34.274027+00
ef528b32-cbc8-4257-807e-317c7a587654	242	Estado ??? IRPS a Pagar	2	liability	credit	\N	t	Classe 2	2026-04-19 10:25:34.274027+00
fbce077f-9236-4c37-8a27-aa02fa20fa16	243	Estado ??? IVA a Pagar	2	liability	credit	\N	t	Classe 2	2026-04-19 10:25:34.274027+00
80429275-21c9-4b2a-9fd1-c8b626c0ccb7	31	Mercadorias	3	asset	debit	\N	t	Classe 3	2026-04-19 10:25:34.274027+00
831219f9-e9dc-4c44-9efa-c850286cb0ac	51	Capital Social	5	equity	credit	\N	t	Classe 5	2026-04-19 10:25:34.274027+00
4a9f842e-08a6-4dcb-b88b-73f161549c3b	56	Resultados Transitados	5	equity	credit	\N	t	Classe 5	2026-04-19 10:25:34.274027+00
988f2b65-0bc5-4c01-9b44-0ae2c07bed16	611	Gastos c/ Pessoal ??? Sal??rios	6	expense	debit	\N	t	Classe 6	2026-04-19 10:25:34.274027+00
e62399f0-638b-4806-aaf5-eaaf4f6c8273	612	Gastos c/ Pessoal ??? INSS Entidade	6	expense	debit	\N	t	Classe 6	2026-04-19 10:25:34.274027+00
97048dbc-5f9d-4ac4-961a-76ea11ae416a	621	Fornecimentos e Servi??os Externos	6	expense	debit	\N	t	Classe 6	2026-04-19 10:25:34.274027+00
f03cb5f4-a93b-4014-a4e5-d9c291b66325	622	Electricidade e ??gua	6	expense	debit	\N	t	Classe 6	2026-04-19 10:25:34.274027+00
0adfa175-71f7-4373-83e9-98fffef6b92d	623	Combust??veis	6	expense	debit	\N	t	Classe 6	2026-04-19 10:25:34.274027+00
c3c7f4d7-5688-4b04-b79e-6bcb06fc621f	624	Manuten????o e Repara????es	6	expense	debit	\N	t	Classe 6	2026-04-19 10:25:34.274027+00
2ae914c6-ba8c-4387-86c2-76e387c64eba	625	Comunica????es	6	expense	debit	\N	t	Classe 6	2026-04-19 10:25:34.274027+00
5fe74161-6045-4c6b-95b0-b3d1a5caea04	626	Seguros	6	expense	debit	\N	t	Classe 6	2026-04-19 10:25:34.274027+00
4d329d98-68bb-4636-8f5b-0602eedd3eaa	631	Impostos e Taxas	6	expense	debit	\N	t	Classe 6	2026-04-19 10:25:34.274027+00
1222da46-5238-4e7f-a4a6-ceef448e178a	711	Vendas ??? Alojamento	7	income	credit	\N	t	Classe 7	2026-04-19 10:25:34.274027+00
0071e24d-20a6-47a3-b991-5c1bb758dc81	712	Vendas ??? Restaura????o	7	income	credit	\N	t	Classe 7	2026-04-19 10:25:34.274027+00
23f43d89-9237-4174-a2c1-9890324e6de4	713	Vendas ??? Actividades	7	income	credit	\N	t	Classe 7	2026-04-19 10:25:34.274027+00
9a902f0e-956c-481e-b85f-b5d78fe008c2	714	Outros Rendimentos	7	income	credit	\N	t	Classe 7	2026-04-19 10:25:34.274027+00
87fb5009-8839-4d72-9029-d60089264222	6111	Sal??rios ??? Pessoal Comum (LC)	6	expense	debit	611	t	61	2026-04-21 16:47:16.345995+00
6b8b2920-50ae-4223-8a0f-1cab882ee142	6112	Sal??rios ??? Trabalho Casual	6	expense	debit	611	t	61	2026-04-21 16:47:16.345995+00
d1b3d196-3608-4ab9-a2f3-b0a7845c524b	6211	Servi??os ??? Office & Bank Charges	6	expense	debit	621	t	62	2026-04-21 16:47:16.345995+00
187fe3a6-3f3f-4f8c-a570-70ae06e907ca	6212	Servi??os ??? Admin Charges (BDO/Andrisa)	6	expense	debit	621	t	62	2026-04-21 16:47:16.345995+00
8b0b5f3d-dc15-46cd-8515-3193543e89cf	6213	Servi??os ??? Comunidade	6	expense	debit	621	t	62	2026-04-21 16:47:16.345995+00
50fb02f6-a453-4017-a9be-ec814c86db70	6214	Servi??os ??? House Keeping	6	expense	debit	621	t	62	2026-04-21 16:47:16.345995+00
70b46831-94b4-4d9b-85d3-9ac5a24c375b	6221	Electricidade e G??s	6	expense	debit	622	t	62	2026-04-21 16:47:16.345995+00
81e2a489-220c-4c3b-a529-e2f08c60b4be	6231	Combust??veis ??? Diesel & Petrol	6	expense	debit	623	t	62	2026-04-21 16:47:16.345995+00
f4316599-685b-4fc2-b68d-f04179abe57a	6241	Manuten????o ??? Geral	6	expense	debit	624	t	62	2026-04-21 16:47:16.345995+00
0a0cd0b7-9663-488d-a06e-5d87d353ea93	6242	Manuten????o ??? Jardim & Piscina	6	expense	debit	624	t	62	2026-04-21 16:47:16.345995+00
ffb2a881-9436-4b2e-97ac-ee966588077c	6243	Manuten????o ??? Ve??culos	6	expense	debit	624	t	62	2026-04-21 16:47:16.345995+00
7edf176d-a617-41f9-afbd-3579ec77372c	6244	Pequenas Ferramentas	6	expense	debit	624	t	62	2026-04-21 16:47:16.345995+00
3c7a15a9-6e3e-43ce-b7d6-944f2b9741cc	6245	Equipamento	6	expense	debit	624	t	62	2026-04-21 16:47:16.345995+00
02bb5911-fe97-49bd-87dc-67e8873049f8	6311	Impostos Municipais & Mar??timos (IPRA/TAE)	6	expense	debit	631	t	63	2026-04-21 16:47:16.345995+00
f2e2debb-22fa-4a16-85ab-a07383ed6aad	6411	Despesas Casa Luz (H1)	6	expense	debit	\N	t	64	2026-04-21 16:47:16.345995+00
28313434-8859-4a01-9892-7d359ab212fd	6412	Despesas Casa Aurora (H2)	6	expense	debit	\N	t	64	2026-04-21 16:47:16.345995+00
07bb7fe0-e3a9-4ef0-bcf5-769379b58e22	6413	Despesas Casa Caju (H3)	6	expense	debit	\N	t	64	2026-04-21 16:47:16.345995+00
ec75b33a-b32c-47a7-ac2b-1ca610c87b0c	6414	Despesas Casa Coco (H4)	6	expense	debit	\N	t	64	2026-04-21 16:47:16.345995+00
874b7069-fafa-46ab-b6f4-b8b3781ac18d	262	Conta Suspensa (Suspense)	2	asset	debit	\N	t	26	2026-04-21 16:47:16.345995+00
\.


--
-- Data for Name: bank_accounts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.bank_accounts (id, name, bank_name, account_number, currency, created_at, updated_at, pgc_account_code) FROM stdin;
a4c61f06-107c-4b11-a8f3-a70803b7cf83	BDO MZN	BDO	\N	MZN	2026-04-12 06:03:10.130395+00	2026-04-12 06:03:10.130395+00	\N
5fe44863-18d1-4e13-bff5-4d19bdb28de3	BIM MZN	BIM	93881257	MZN	2026-04-12 06:03:10.130395+00	2026-04-12 06:03:10.130395+00	\N
185790da-0ac4-4e0c-a3dd-f64d51c52ce2	BDO USD	BDO	\N	USD	2026-04-12 06:03:10.130395+00	2026-04-12 06:03:10.130395+00	\N
910cb26e-afbe-4672-a46f-52ec15cd9735	BIM MZN	BIM - Vilanculos	93881257	MZN	2026-04-22 05:54:45.207886+00	2026-04-22 05:54:45.207886+00	1211
e02ba8ca-75c6-48e3-9a87-486f1ad01984	BIM USD	BIM - Vilanculos	93880869	USD	2026-04-22 05:54:45.207886+00	2026-04-22 05:54:45.207886+00	1212
\.


--
-- Data for Name: bank_opening_balances; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.bank_opening_balances (id, bank_account_id, month, year, opening_balance, source_file, created_at, updated_at) FROM stdin;
d2649640-b7a6-454d-85bd-a7c2bb63fd04	910cb26e-afbe-4672-a46f-52ec15cd9735	1	2026	183825.44	01 BDO Bank Control 2026.xlsx	2026-04-22 06:09:42.227558+00	2026-04-22 06:12:25.687431+00
823840bd-2cb0-4571-a7aa-7c24cd800723	e02ba8ca-75c6-48e3-9a87-486f1ad01984	1	2026	10791.97	01 BDO Bank Control 2026.xlsx	2026-04-22 06:09:42.282949+00	2026-04-22 06:12:25.743286+00
e6425a76-cdc3-4a46-881b-547bd15ee80b	910cb26e-afbe-4672-a46f-52ec15cd9735	2	2026	738401.56	02 BDO Bank Control 2026.xlsx	2026-04-22 06:09:44.004654+00	2026-04-22 06:12:27.785224+00
48308cf4-97fc-4faf-a23a-f4a56157cb4e	e02ba8ca-75c6-48e3-9a87-486f1ad01984	2	2026	6591.97	02 BDO Bank Control 2026.xlsx	2026-04-22 06:09:44.051452+00	2026-04-22 06:12:27.828682+00
bfef5e39-5bd4-405b-88a5-cdbd946abf6a	910cb26e-afbe-4672-a46f-52ec15cd9735	3	2026	258025.81	03 BDO Bank Control 2026.xlsx	2026-04-22 06:09:45.672632+00	2026-04-22 06:12:29.865912+00
535c4802-7dda-4966-8a64-d7a802590628	e02ba8ca-75c6-48e3-9a87-486f1ad01984	3	2026	3591.97	03 BDO Bank Control 2026.xlsx	2026-04-22 06:09:45.726951+00	2026-04-22 06:12:29.912634+00
\.


--
-- Data for Name: bank_transactions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.bank_transactions (id, date, bank_account_id, description, debit, credit, balance, reference, month, year, created_at, journal_entry_id) FROM stdin;
0ba392ff-9607-4fdd-b8e8-8aaa1f001cb3	2026-01-03	910cb26e-afbe-4672-a46f-52ec15cd9735	ENH DECEMBER	6426.95	0.00	177398.49	5001016048	1	2026	2026-04-22 06:12:25.633057+00	\N
68b0cd50-4154-4f5f-b83b-d8a9005ddb90	2026-01-03	910cb26e-afbe-4672-a46f-52ec15cd9735	TRANSFER FROM DOLLAR ACCOUNT	0.00	265650.00	443048.49	TRF	1	2026	2026-04-22 06:12:25.633057+00	\N
052ff11e-0f0c-42fb-b4db-0bb840e8efa0	2026-01-06	910cb26e-afbe-4672-a46f-52ec15cd9735	PAINT STEEL	1420.24	0.00	441628.25	569405	1	2026	2026-04-22 06:12:25.633057+00	\N
194d0df1-62b5-494a-a161-8ac4bd1ee036	2026-01-09	910cb26e-afbe-4672-a46f-52ec15cd9735	WARREN STEAD	0.00	232000.00	673628.25	DEP	1	2026	2026-04-22 06:12:25.633057+00	\N
4b74814e-df46-4879-a20a-3059f9d6d9ef	2026-01-09	910cb26e-afbe-4672-a46f-52ec15cd9735	WARREN STEAD	0.00	281750.00	955378.25	DEP	1	2026	2026-04-22 06:12:25.633057+00	\N
31440e09-f5d2-42aa-b891-b26dc7442e0e	2026-01-09	910cb26e-afbe-4672-a46f-52ec15cd9735	WARREN STEAD	0.00	435000.00	1390378.25	DEP	1	2026	2026-04-22 06:12:25.633057+00	\N
998e5b32-1303-4d4b-b0a6-4596e08dcb4b	2026-01-11	910cb26e-afbe-4672-a46f-52ec15cd9735	FELIX ADVANCE	2500.00	0.00	1387878.25	TRF	1	2026	2026-04-22 06:12:25.633057+00	\N
ef3c222e-9ae8-4b81-8fee-724c119e5a7b	2026-01-11	910cb26e-afbe-4672-a46f-52ec15cd9735	TRANSFER FEE	7.00	0.00	1387871.25	TRF	1	2026	2026-04-22 06:12:25.633057+00	\N
97fac676-8f63-4aeb-896a-0f86c294c737	2026-01-11	910cb26e-afbe-4672-a46f-52ec15cd9735	ADMIN FEE	146740.00	0.00	1241131.25	TRF	1	2026	2026-04-22 06:12:25.633057+00	\N
b3699f18-45ce-4c49-91b2-3e6cabd6730d	2026-01-11	910cb26e-afbe-4672-a46f-52ec15cd9735	TRANSFER FEE	7.00	0.00	1241124.25	TRF	1	2026	2026-04-22 06:12:25.633057+00	\N
c1377584-73d1-4625-99d0-9554b70b7a7f	2026-01-11	910cb26e-afbe-4672-a46f-52ec15cd9735	ELECTRICITY DECEMBER	77851.16	0.00	1163273.09	57037750173	1	2026	2026-04-22 06:12:25.633057+00	\N
7a5d8ae4-f20d-4cb9-8ce7-da1d118579fe	2026-01-11	910cb26e-afbe-4672-a46f-52ec15cd9735	TRANSFER FEE	7.00	0.00	1163266.09	TRF	1	2026	2026-04-22 06:12:25.633057+00	\N
530684e9-aefb-4889-b263-8b32bc4a479c	2026-01-12	910cb26e-afbe-4672-a46f-52ec15cd9735	FELIX ADVANCE	3000.00	0.00	1160266.09	TRF	1	2026	2026-04-22 06:12:25.633057+00	\N
71212c90-fc4f-4fac-8b47-47127862f6ee	2026-01-12	910cb26e-afbe-4672-a46f-52ec15cd9735	TRANSFER FEE	7.00	0.00	1160259.09	TRF	1	2026	2026-04-22 06:12:25.633057+00	\N
878133de-396d-4d59-bb38-0131d3897d82	2026-01-16	910cb26e-afbe-4672-a46f-52ec15cd9735	ADVANCE JELSON	1500.00	0.00	1158759.09	TRF	1	2026	2026-04-22 06:12:25.633057+00	\N
47a8622d-3bd5-4b21-8fb8-de7495499c6a	2026-01-16	910cb26e-afbe-4672-a46f-52ec15cd9735	TRANSFER FEE	7.00	0.00	1158752.09	TRF	1	2026	2026-04-22 06:12:25.633057+00	\N
83f4699b-11d8-4673-a215-dbda29b77ca5	2026-01-20	910cb26e-afbe-4672-a46f-52ec15cd9735	ACCOUNTING FEE JANUARY	37385.80	0.00	1121366.29	38316	1	2026	2026-04-22 06:12:25.633057+00	\N
c51135c0-1605-40ca-b439-e40b1fed52c7	2026-01-20	910cb26e-afbe-4672-a46f-52ec15cd9735	TRANSFER FEE	7.00	0.00	1121359.29	TRF	1	2026	2026-04-22 06:12:25.633057+00	\N
ca38d28e-3f24-4394-80ab-0979eb64fd75	2026-01-22	910cb26e-afbe-4672-a46f-52ec15cd9735	FILES	1500.00	0.00	1119859.29	2723	1	2026	2026-04-22 06:12:25.633057+00	\N
7d47b3a3-0903-453b-b548-6d392bf9ad52	2026-01-22	910cb26e-afbe-4672-a46f-52ec15cd9735	TRANSFER FEE	7.00	0.00	1119852.29	TRF	1	2026	2026-04-22 06:12:25.633057+00	\N
e6f8b52f-4d8c-45dd-a1fd-e3aebac7df7c	2026-01-23	910cb26e-afbe-4672-a46f-52ec15cd9735	COTOVELO PVC	1037.39	0.00	1118814.90	7240	1	2026	2026-04-22 06:12:25.633057+00	\N
b9d4a6d9-3996-4b4e-bdf7-2e2bd583d037	2026-01-22	910cb26e-afbe-4672-a46f-52ec15cd9735	TRANSFER TO PETTY CASH	10000.00	0.00	1108814.90	877824	1	2026	2026-04-22 06:12:25.633057+00	\N
89877ad3-4f26-448b-8624-61d11dc8ccb5	2026-01-23	910cb26e-afbe-4672-a46f-52ec15cd9735	SALARIES JANUARY	315176.58	0.00	793638.32	TRF	1	2026	2026-04-22 06:12:25.633057+00	\N
b2420b91-6f44-41e6-8742-218d9978d2c2	2026-01-23	910cb26e-afbe-4672-a46f-52ec15cd9735	BANK CHARGES	257.00	0.00	793381.32	TRF	1	2026	2026-04-22 06:12:25.633057+00	\N
c3116cef-f957-4afd-a961-4ee8ae616df3	2026-01-23	910cb26e-afbe-4672-a46f-52ec15cd9735	BREAD	12000.00	0.00	781381.32	877825	1	2026	2026-04-22 06:12:25.633057+00	\N
150486da-f1b2-4fb3-9f1b-f3425e63054b	2026-01-26	910cb26e-afbe-4672-a46f-52ec15cd9735	IRPS	10437.50	0.00	770943.82	FINANCE	1	2026	2026-04-22 06:12:25.633057+00	\N
d16d7ffd-e951-4eb7-8f2d-b9a61fa53dda	2026-01-26	910cb26e-afbe-4672-a46f-52ec15cd9735	INSS	24253.11	0.00	746690.71		1	2026	2026-04-22 06:12:25.633057+00	\N
be250b97-c52d-45a4-92e9-31f818028f77	2026-01-28	910cb26e-afbe-4672-a46f-52ec15cd9735	DILUENTE ESMALTE QD 750ML	524.00	0.00	746166.71	7227	1	2026	2026-04-22 06:12:25.633057+00	\N
66f3db9a-8aea-48f6-9b32-18715f519a8c	2026-01-29	910cb26e-afbe-4672-a46f-52ec15cd9735	GAS JANUARY	4833.15	0.00	741333.56	5001017192	1	2026	2026-04-22 06:12:25.633057+00	\N
df851051-9f82-40d1-b1a1-cdd727291e43	2026-01-29	910cb26e-afbe-4672-a46f-52ec15cd9735	TRANSFER FEE	7.00	0.00	741326.56	TRF	1	2026	2026-04-22 06:12:25.633057+00	\N
15c1d04a-c392-4499-b28a-f932e09f2546	2026-01-29	910cb26e-afbe-4672-a46f-52ec15cd9735	LESCO - CX PROVA DE AGUA 4X4	2025.00	0.00	739301.56	214671	1	2026	2026-04-22 06:12:25.633057+00	\N
31921ecb-60b5-4bdc-9e4d-43cf997e3d80	2026-01-29	910cb26e-afbe-4672-a46f-52ec15cd9735	2 TOMADA SA E 2 CX 4X4	900.00	0.00	738401.56	17056	1	2026	2026-04-22 06:12:25.633057+00	\N
f9167671-4a1a-48b9-b4c1-c1f72fe81d19	\N	910cb26e-afbe-4672-a46f-52ec15cd9735		659823.88	1398225.44	738401.56		1	2026	2026-04-22 06:12:25.633057+00	\N
23b4764f-e249-4ed0-a144-1156cb89d7a1	\N	910cb26e-afbe-4672-a46f-52ec15cd9735		659823.88	1214400.00	0.00		1	2026	2026-04-22 06:12:25.633057+00	\N
9bc58c73-0255-45d6-8522-18d040900003	2026-01-09	e02ba8ca-75c6-48e3-9a87-486f1ad01984	DOLLAR TO METICAIS	4200.00	0.00	6591.97	TRF	1	2026	2026-04-22 06:12:25.633057+00	\N
d1245118-4aef-4f36-8056-f1aff657cc48	\N	e02ba8ca-75c6-48e3-9a87-486f1ad01984		4200.00	10791.97	6591.97		1	2026	2026-04-22 06:12:25.633057+00	\N
099f2733-b26d-4228-9f2f-6e11215d3ea4	2026-02-02	910cb26e-afbe-4672-a46f-52ec15cd9735	Leave	10987.20	0.00	727414.36	TRF	2	2026	2026-04-22 06:12:27.738565+00	\N
6eec42a6-6470-4c97-a05c-d0534bdf2594	2026-02-02	910cb26e-afbe-4672-a46f-52ec15cd9735	Bank Charges	7.00	0.00	727407.36	TRF	2	2026	2026-04-22 06:12:27.738565+00	\N
649dc1b3-e33e-468a-9086-638d06b204a0	2026-02-02	910cb26e-afbe-4672-a46f-52ec15cd9735	Quimical swimming pools	905.00	0.00	726502.36	214	2	2026	2026-04-22 06:12:27.738565+00	\N
a96dd154-5d08-4076-9933-8fa628cd0c4f	2026-02-02	910cb26e-afbe-4672-a46f-52ec15cd9735	Quimical swimming pools	1519.60	0.00	724982.76	879	2	2026	2026-04-22 06:12:27.738565+00	\N
5eb0c6ae-4bfa-4200-989b-e62024e5609e	2026-02-02	910cb26e-afbe-4672-a46f-52ec15cd9735	Bank Charges	7.00	0.00	724975.76	TRF	2	2026	2026-04-22 06:12:27.738565+00	\N
e2293b77-0e7d-4158-a8d0-d57f4fbf643c	2026-02-02	910cb26e-afbe-4672-a46f-52ec15cd9735	Advance	1000.00	0.00	723975.76	TRF	2	2026	2026-04-22 06:12:27.738565+00	\N
7df6a621-3987-40d8-9926-952a7e7bafab	2026-02-02	910cb26e-afbe-4672-a46f-52ec15cd9735	Bank Charges	7.00	0.00	723968.76	TRF	2	2026	2026-04-22 06:12:27.738565+00	\N
53b5dfdd-8162-4336-af72-7f4dd5bc48f8	2026-02-04	910cb26e-afbe-4672-a46f-52ec15cd9735	Union Fee	3464.73	0.00	720504.03	TRF	2	2026	2026-04-22 06:12:27.738565+00	\N
d6e5e799-6338-48d2-be43-8faf44cf0e71	2026-02-04	910cb26e-afbe-4672-a46f-52ec15cd9735	Bank Charges	7.00	0.00	720497.03	TRF	2	2026	2026-04-22 06:12:27.738565+00	\N
2116be52-5618-4479-81c0-885dd9045764	2026-02-09	910cb26e-afbe-4672-a46f-52ec15cd9735	Advance	3500.00	0.00	716997.03	TRF	2	2026	2026-04-22 06:12:27.738565+00	\N
516351ec-890b-421f-b645-d879f7048337	2026-02-09	910cb26e-afbe-4672-a46f-52ec15cd9735	Bank Charges	7.00	0.00	716990.03	TRF	2	2026	2026-04-22 06:12:27.738565+00	\N
ff144807-dc89-4592-95d8-44a6f0dc743d	2026-02-10	910cb26e-afbe-4672-a46f-52ec15cd9735	Electrisity	58424.49	0.00	658565.54	57037750285	2	2026	2026-04-22 06:12:27.738565+00	\N
2c1ff582-44d1-4b92-a446-903f8293cbdd	2026-02-10	910cb26e-afbe-4672-a46f-52ec15cd9735	Bank Charges	7.00	0.00	658558.54	TRF	2	2026	2026-04-22 06:12:27.738565+00	\N
cf3e5e71-c430-4708-ba07-18f5ca2b0154	2026-02-14	910cb26e-afbe-4672-a46f-52ec15cd9735	Diesel Generator	4263.00	0.00	654295.54	11752	2	2026	2026-04-22 06:12:27.738565+00	\N
7f4dd4f3-eed0-464d-8432-f9ce9f913322	2026-02-18	910cb26e-afbe-4672-a46f-52ec15cd9735	Advance	500.00	0.00	653795.54	TRF	2	2026	2026-04-22 06:12:27.738565+00	\N
9376ca74-f871-428b-a94a-90bd8f95f320	2026-02-18	910cb26e-afbe-4672-a46f-52ec15cd9735	Bank Charges	7.00	0.00	653788.54	TRF	2	2026	2026-04-22 06:12:27.738565+00	\N
749c6aee-e30a-42c8-85f3-cbe712db6ddc	2026-02-18	910cb26e-afbe-4672-a46f-52ec15cd9735	Accounting	37386.80	0.00	616401.74	38484	2	2026	2026-04-22 06:12:27.738565+00	\N
19d23766-3314-4ad2-aa50-24a34d499f89	2026-02-18	910cb26e-afbe-4672-a46f-52ec15cd9735	Bank Charges	7.00	0.00	616394.74	TRF	2	2026	2026-04-22 06:12:27.738565+00	\N
f330b15b-45b6-433d-8989-80f93e230237	2026-02-19	910cb26e-afbe-4672-a46f-52ec15cd9735	Admin Fee	146740.00	0.00	469654.74	429	2	2026	2026-04-22 06:12:27.738565+00	\N
2c4c0c5f-855f-483c-bfea-3f0de74f57b2	2026-02-19	910cb26e-afbe-4672-a46f-52ec15cd9735	Bank Charges	7.00	0.00	469647.74	TRF	2	2026	2026-04-22 06:12:27.738565+00	\N
90aabf88-7dcc-4c97-910b-7535a8c59ea5	2026-02-23	910cb26e-afbe-4672-a46f-52ec15cd9735	Gas Jan	4470.61	0.00	465177.13	1400001604	2	2026	2026-04-22 06:12:27.738565+00	\N
e9460108-5a4f-4cc8-8f42-b06a99cadeaa	2026-02-23	910cb26e-afbe-4672-a46f-52ec15cd9735	Bank Charges	7.00	0.00	465170.13	Trf	2	2026	2026-04-22 06:12:27.738565+00	\N
b86204b8-dcb6-4e08-bc09-16976bbcb017	2026-02-23	910cb26e-afbe-4672-a46f-52ec15cd9735	House Kepping Towel Duck	20787.20	0.00	444382.93	1930	2	2026	2026-04-22 06:12:27.738565+00	\N
31d5e86a-7da7-42ce-a7cb-93258fa1ab6d	2026-02-23	910cb26e-afbe-4672-a46f-52ec15cd9735	Bank Charges	120.00	0.00	444262.93	TRF	2	2026	2026-04-22 06:12:27.738565+00	\N
6da15821-daba-495b-bc99-c59898df6397	2026-02-23	910cb26e-afbe-4672-a46f-52ec15cd9735	SIM R SEG	1409.68	0.00	442853.25	TRF	2	2026	2026-04-22 06:12:27.738565+00	\N
22d94dd9-4d3e-45b1-a384-7382c8e5b848	2026-02-23	910cb26e-afbe-4672-a46f-52ec15cd9735	Revisao de Extintores	21558.60	0.00	421294.65	2627	2	2026	2026-04-22 06:12:27.738565+00	\N
72070800-a4b1-4abb-acaa-f899f458cc47	2026-02-23	910cb26e-afbe-4672-a46f-52ec15cd9735	Bank Charges	7.00	0.00	421287.65	TRF	2	2026	2026-04-22 06:12:27.738565+00	\N
eebe1ceb-070e-43b4-b026-41b3fc8df036	2026-02-25	910cb26e-afbe-4672-a46f-52ec15cd9735	Dolar to Mets	0.00	189750.00	611037.65	TRF	2	2026	2026-04-22 06:12:27.738565+00	\N
62d4f71b-c699-4533-bf95-6f2b8dffe423	2026-02-25	910cb26e-afbe-4672-a46f-52ec15cd9735	Salario Feb	310752.26	0.00	300285.39	TRF	2	2026	2026-04-22 06:12:27.738565+00	\N
64c1cd93-f71d-43ca-b9cf-85016c1e99dc	2026-02-25	910cb26e-afbe-4672-a46f-52ec15cd9735	Bank Charges	254.00	0.00	300031.39	TRF	2	2026	2026-04-22 06:12:27.738565+00	\N
a6267835-b34c-4b3c-8d53-a6be8628bb61	2026-02-26	910cb26e-afbe-4672-a46f-52ec15cd9735	Cleaning supplies	755.00	0.00	299276.39	7823	2	2026	2026-04-22 06:12:27.738565+00	\N
e33dc59c-f8e2-432e-89fd-294c412b8fe0	2026-02-26	910cb26e-afbe-4672-a46f-52ec15cd9735	Eletrical material	1465.00	0.00	297811.39	15928/911376	2	2026	2026-04-22 06:12:27.738565+00	\N
e94ee03d-2051-40c8-a82d-4e18cba8475e	2026-02-27	910cb26e-afbe-4672-a46f-52ec15cd9735	Lampadas	1250.00	0.00	296561.39	1/215423	2	2026	2026-04-22 06:12:27.738565+00	\N
b4058366-a932-46e8-a6f4-6fe7041fafe0	\N	910cb26e-afbe-4672-a46f-52ec15cd9735	SINDICATO FEB	3512.26	0.00	293049.13		2	2026	2026-04-22 06:12:27.738565+00	\N
7f177ddf-4b16-41a0-942f-9ec511986f36	\N	910cb26e-afbe-4672-a46f-52ec15cd9735	INSS FEB	24585.82	0.00	268463.31		2	2026	2026-04-22 06:12:27.738565+00	\N
829f274f-ba67-4870-8957-2a55c3c2c602	\N	910cb26e-afbe-4672-a46f-52ec15cd9735	IRPS FEB	10437.50	0.00	258025.81		2	2026	2026-04-22 06:12:27.738565+00	\N
53c3203f-4b69-47c6-b4dc-c7540387e4f8	\N	910cb26e-afbe-4672-a46f-52ec15cd9735		670125.75	928151.56	258025.81		2	2026	2026-04-22 06:12:27.738565+00	\N
c8c5881e-c7c5-4ccf-8658-20d858fef59d	\N	910cb26e-afbe-4672-a46f-52ec15cd9735		670125.75	189750.00	0.00		2	2026	2026-04-22 06:12:27.738565+00	\N
3098798e-2803-47bd-8aee-3024fe1f254d	2026-02-25	e02ba8ca-75c6-48e3-9a87-486f1ad01984	TRANSFER TO METICAIS	3000.00	0.00	3591.97	TRF	2	2026	2026-04-22 06:12:27.738565+00	\N
a8bb0dcf-778e-4c73-aac1-5f8e29ac1ca8	\N	e02ba8ca-75c6-48e3-9a87-486f1ad01984		3000.00	6591.97	3591.97		2	2026	2026-04-22 06:12:27.738565+00	\N
e69d4832-050b-484b-8413-f405512dd2a9	2026-03-02	910cb26e-afbe-4672-a46f-52ec15cd9735	JELSON	5000.00	0.00	253025.81	TRF	3	2026	2026-04-22 06:12:29.820486+00	\N
98b1dbf9-bd95-4482-bcb6-36a35f961dca	2026-03-02	910cb26e-afbe-4672-a46f-52ec15cd9735	BANK CHARGES	7.00	0.00	253018.81	TRF	3	2026	2026-04-22 06:12:29.820486+00	\N
da84a88f-9122-4e2e-bc4c-4322dc1993b2	2026-03-05	910cb26e-afbe-4672-a46f-52ec15cd9735	EMILIO ADVANCE	2300.00	0.00	250718.81	TRF	3	2026	2026-04-22 06:12:29.820486+00	\N
a436ac13-0243-47c9-b267-6a7674b9d0d1	2026-03-05	910cb26e-afbe-4672-a46f-52ec15cd9735	BANK CHARGES	7.00	0.00	250711.81	TRF	3	2026	2026-04-22 06:12:29.820486+00	\N
d929a840-76b5-4414-85ac-9c81d246e3ff	2026-03-05	910cb26e-afbe-4672-a46f-52ec15cd9735	TAFY ACCOMMODATION	0.00	88044.00	338755.81	DEP	3	2026	2026-04-22 06:12:29.820486+00	\N
3df8092c-f1d5-4ab3-b5fa-01d6f1c048e4	2026-03-05	910cb26e-afbe-4672-a46f-52ec15cd9735	CALDERON ADVANCE	1500.00	0.00	337255.81	TRF	3	2026	2026-04-22 06:12:29.820486+00	\N
b7dee9b2-9ff1-4822-baba-331bbc9ec249	2026-03-05	910cb26e-afbe-4672-a46f-52ec15cd9735	BANK CHARGES	120.00	0.00	337135.81	TRF	3	2026	2026-04-22 06:12:29.820486+00	\N
8aaa1280-9504-41f1-85af-3f0519a4696d	2026-03-09	910cb26e-afbe-4672-a46f-52ec15cd9735	VARNISH	3328.00	0.00	333807.81	6961	3	2026	2026-04-22 06:12:29.820486+00	\N
8146ccda-96ab-4003-9609-795aebc5586c	2026-03-09	910cb26e-afbe-4672-a46f-52ec15cd9735	DIESEL MMR0998	7384.37	0.00	326423.44	57438	3	2026	2026-04-22 06:12:29.820486+00	\N
b6ca237c-d9d9-4c32-a4dd-feb576fe8d52	2026-03-09	910cb26e-afbe-4672-a46f-52ec15cd9735	TOILET PAPER	5245.00	0.00	321178.44	D/C	3	2026	2026-04-22 06:12:29.820486+00	\N
2f6c359b-bd4e-4e8e-a4dc-009551ac5e4d	2026-03-09	910cb26e-afbe-4672-a46f-52ec15cd9735	BANK CHARGES	7.00	0.00	321171.44	TRF	3	2026	2026-04-22 06:12:29.820486+00	\N
5a3dd530-43fe-4348-82d2-7bb162d8e9ce	2026-03-11	910cb26e-afbe-4672-a46f-52ec15cd9735	ELECTRICITY	51111.88	0.00	270059.56	TRF	3	2026	2026-04-22 06:12:29.820486+00	\N
a2a65687-b191-431e-a375-6b558da143e4	2026-03-11	910cb26e-afbe-4672-a46f-52ec15cd9735	BANK CHARGES	7.00	0.00	270052.56	TRF	3	2026	2026-04-22 06:12:29.820486+00	\N
7ad8436d-3cd3-4ff2-b4b6-f60a451b078c	2026-03-11	910cb26e-afbe-4672-a46f-52ec15cd9735	IRPS	129.49	0.00	269923.07	TRF	3	2026	2026-04-22 06:12:29.820486+00	\N
b645c6d6-9e93-4308-9f71-2492bb96bc3f	2026-03-16	910cb26e-afbe-4672-a46f-52ec15cd9735	CHLOOR	8710.00	0.00	261213.07	425/2026	3	2026	2026-04-22 06:12:29.820486+00	\N
c1f0c80f-78ab-40d5-a20a-da0d8c0be368	2026-03-16	910cb26e-afbe-4672-a46f-52ec15cd9735	PLASTIC DE LUXO	1290.00	0.00	259923.07	94962	3	2026	2026-04-22 06:12:29.820486+00	\N
a00481a9-60d4-4372-b008-b3759aded61e	2026-03-17	910cb26e-afbe-4672-a46f-52ec15cd9735	CARTO DEBITO	600.00	0.00	259323.07	TRF	3	2026	2026-04-22 06:12:29.820486+00	\N
e8102a0a-67ff-4eeb-a2f5-b363b8b37570	2026-03-18	910cb26e-afbe-4672-a46f-52ec15cd9735	ACCOUNTING	37386.00	0.00	221937.07	38632	3	2026	2026-04-22 06:12:29.820486+00	\N
016ec88e-d1f5-4cbb-9892-df3bc74e58b0	2026-03-18	910cb26e-afbe-4672-a46f-52ec15cd9735	BANK CHARGES	7.00	0.00	221930.07	TRF	3	2026	2026-04-22 06:12:29.820486+00	\N
2de6ab0f-d457-4f82-a12e-cff12b557d57	2026-03-18	910cb26e-afbe-4672-a46f-52ec15cd9735	INSURANCE	1409.68	0.00	220520.39	TRF	3	2026	2026-04-22 06:12:29.820486+00	\N
81d33b41-ae30-4030-b4b1-0c1c59dac032	2026-03-18	910cb26e-afbe-4672-a46f-52ec15cd9735	INSURANCE	1409.68	0.00	219110.71	TRF	3	2026	2026-04-22 06:12:29.820486+00	\N
1af9a14c-97ef-4aeb-b8b0-8f5d3c19301c	2026-03-19	910cb26e-afbe-4672-a46f-52ec15cd9735	BALDE PARA CONSTRUTOR	788.00	0.00	218322.71	7231	3	2026	2026-04-22 06:12:29.820486+00	\N
ea5015cb-e673-4ffe-9089-afc55e0cd70d	2026-03-19	910cb26e-afbe-4672-a46f-52ec15cd9735	CLEANING MATERIAL	3330.00	0.00	214992.71	1745	3	2026	2026-04-22 06:12:29.820486+00	\N
849d6f18-a159-4c7f-a9cd-26254fcd7804	2026-03-19	910cb26e-afbe-4672-a46f-52ec15cd9735	BATTERY PRADO H4	10500.00	0.00	204492.71	1/402	3	2026	2026-04-22 06:12:29.820486+00	\N
df7ac512-6149-4fc0-9ccd-7576a0a29360	2026-03-19	910cb26e-afbe-4672-a46f-52ec15cd9735	SEALER H3	5688.00	0.00	198804.71	1/215927	3	2026	2026-04-22 06:12:29.820486+00	\N
7a33bd76-7000-46c6-bfe6-8cb008097b76	2026-03-19	910cb26e-afbe-4672-a46f-52ec15cd9735	BANK CHARGES	7.00	0.00	198797.71	TRF	3	2026	2026-04-22 06:12:29.820486+00	\N
50e540e8-fd54-4e33-960d-f1a1ba8fd27f	2026-03-24	910cb26e-afbe-4672-a46f-52ec15cd9735	TRANSFER DOLLARS TO METICAIS	0.00	316250.00	515047.71	TRF	3	2026	2026-04-22 06:12:29.820486+00	\N
9af3917a-daad-40f8-b5bb-438f9751ec14	2026-03-23	910cb26e-afbe-4672-a46f-52ec15cd9735	PETTY CASH	18889.39	0.00	496158.32	8777827	3	2026	2026-04-22 06:12:29.820486+00	\N
8c2c84a6-0a7b-4b76-87a3-01dc5cac0a0c	2026-03-25	910cb26e-afbe-4672-a46f-52ec15cd9735	SALARY MARCH	305089.85	0.00	191068.47	TRF	3	2026	2026-04-22 06:12:29.820486+00	\N
f6f91eff-84b0-4f3d-9da0-cfd9e2ee117c	2026-03-25	910cb26e-afbe-4672-a46f-52ec15cd9735	BANK CHARGES	257.00	0.00	190811.47	TRF	3	2026	2026-04-22 06:12:29.820486+00	\N
9f4b13a2-88ac-4b24-884a-1393b138f669	2026-03-25	910cb26e-afbe-4672-a46f-52ec15cd9735	ADMIN FEE	146740.00	0.00	44071.47	431	3	2026	2026-04-22 06:12:29.820486+00	\N
b5edef40-68a4-4bd8-8d6f-1868ba1242d0	2026-03-25	910cb26e-afbe-4672-a46f-52ec15cd9735	ACCOMMODATION ADVANCE APRIL	0.00	38400.00	82471.47	F98	3	2026	2026-04-22 06:12:29.820486+00	\N
22a233ea-6be3-4351-aa06-2d8d221c6321	2026-03-26	910cb26e-afbe-4672-a46f-52ec15cd9735	LIGHTS OUTSIDE	1440.00	0.00	81031.47	24198	3	2026	2026-04-22 06:12:29.820486+00	\N
2a086130-eb74-4b08-b9bd-a1adf7029c37	2026-03-26	910cb26e-afbe-4672-a46f-52ec15cd9735	SINDICATO	3379.76	0.00	77651.71	I/N	3	2026	2026-04-22 06:12:29.820486+00	\N
149edd1f-892f-40b3-8141-8061a6d5c5ae	2026-03-27	910cb26e-afbe-4672-a46f-52ec15cd9735	SOAP, JAVEL	5430.00	0.00	72221.71	1765	3	2026	2026-04-22 06:12:29.820486+00	\N
adb9b526-e9b0-420a-b55b-6b321d53ce2e	2026-03-27	910cb26e-afbe-4672-a46f-52ec15cd9735	TRANSFER DOLLARS TO METICAIS	0.00	316250.00	388471.71	TRF	3	2026	2026-04-22 06:12:29.820486+00	\N
d5df5711-db00-4406-b136-28789c6b5bd5	2026-03-27	910cb26e-afbe-4672-a46f-52ec15cd9735	IPRA 2026	52850.00	0.00	335621.71	TRF	3	2026	2026-04-22 06:12:29.820486+00	\N
770c8981-590d-4645-b9c6-c7f063efc931	2026-03-27	910cb26e-afbe-4672-a46f-52ec15cd9735	TAE	10300.00	0.00	325321.71	TRF	3	2026	2026-04-22 06:12:29.820486+00	\N
d1dcc0a0-95c4-4194-beb6-55c47ac8bec2	2026-03-27	910cb26e-afbe-4672-a46f-52ec15cd9735	DIESEL GENERATOR	12280.00	0.00	313041.71	12801	3	2026	2026-04-22 06:12:29.820486+00	\N
672fe1b8-cf4b-488c-bb0e-40a77a808a93	2026-03-27	910cb26e-afbe-4672-a46f-52ec15cd9735	Q20 OIL ANTI RUST	1160.00	0.00	311881.71	1/4101	3	2026	2026-04-22 06:12:29.820486+00	\N
1dd238a3-dcc2-4b27-8fc4-85b596818bb8	2026-03-30	910cb26e-afbe-4672-a46f-52ec15cd9735	DIESEL TOYOTA AKL491MP	5385.02	0.00	306496.69	6192	3	2026	2026-04-22 06:12:29.820486+00	\N
c9d3e537-e640-4ac0-9158-f54675b6e793	2026-03-27	910cb26e-afbe-4672-a46f-52ec15cd9735	DIESEL PRADO HOUSE 4	3292.74	0.00	303203.95	6196	3	2026	2026-04-22 06:12:29.820486+00	\N
4a0bb351-e309-467b-b992-1a404db7853e	2026-03-30	910cb26e-afbe-4672-a46f-52ec15cd9735	INSS	23658.31	0.00	279545.64	TRF	3	2026	2026-04-22 06:12:29.820486+00	\N
ed28b3af-7adc-42eb-abd4-2be3d37308f5	2026-03-30	910cb26e-afbe-4672-a46f-52ec15cd9735	TRANSFER DOLLARS TO METICAIS	0.00	316250.00	595795.64	TRF	3	2026	2026-04-22 06:12:29.820486+00	\N
9305ba44-0eb7-44ac-88d3-abac0a92b539	2026-03-30	910cb26e-afbe-4672-a46f-52ec15cd9735	INSURANCE VEHICLES	277172.71	0.00	318622.93	TRF	3	2026	2026-04-22 06:12:29.820486+00	\N
233d5123-dbaa-464c-91dc-19d4d72e09c7	2026-03-30	910cb26e-afbe-4672-a46f-52ec15cd9735	BANK CHARGES	120.00	0.00	318502.93	TRF	3	2026	2026-04-22 06:12:29.820486+00	\N
a3c0bcc7-c919-4338-9871-d5731f5c4f76	2026-03-30	910cb26e-afbe-4672-a46f-52ec15cd9735	WORKMENS COMPENSATIO	30417.98	0.00	288084.95	TRF	3	2026	2026-04-22 06:12:29.820486+00	\N
971d10f5-37cd-4ff0-ac24-75b809483464	2026-03-30	910cb26e-afbe-4672-a46f-52ec15cd9735	BANK CHARGES	120.00	0.00	287964.95	TRF	3	2026	2026-04-22 06:12:29.820486+00	\N
b2ab1570-d165-4562-ae7b-47a69e4aa448	2026-03-31	910cb26e-afbe-4672-a46f-52ec15cd9735	GAS FEBRUARY	3800.61	0.00	284164.34	5001021475	3	2026	2026-04-22 06:12:29.820486+00	\N
4b99d917-75d2-4af3-b510-ae1112fd634e	2026-03-31	910cb26e-afbe-4672-a46f-52ec15cd9735	GLOBES	1235.00	0.00	282929.34	96253	3	2026	2026-04-22 06:12:29.820486+00	\N
26a29383-3485-4101-9c80-c7fd6814234a	2026-03-31	910cb26e-afbe-4672-a46f-52ec15cd9735	IRPS	10437.50	0.00	272491.84	TRF	3	2026	2026-04-22 06:12:29.820486+00	\N
12584b0c-dc7a-4620-b257-39e1c5dcb988	\N	910cb26e-afbe-4672-a46f-52ec15cd9735		1060727.97	1333219.81	272491.84		3	2026	2026-04-22 06:12:29.820486+00	\N
ccc93903-39a0-4c82-9bb0-958c5a39ea20	\N	910cb26e-afbe-4672-a46f-52ec15cd9735		1049199.38	1075194.00	0.00		3	2026	2026-04-22 06:12:29.820486+00	\N
66507013-46d3-4875-9158-424f519b4ec5	2026-03-17	e02ba8ca-75c6-48e3-9a87-486f1ad01984	TRANSFER FEE	9.27	0.00	3582.70	TRF	3	2026	2026-04-22 06:12:29.820486+00	\N
eaadfbc9-cf6c-4777-b2b5-e0a6848a455d	2026-03-17	e02ba8ca-75c6-48e3-9a87-486f1ad01984	SHAREHOLDERS CORTRIBUTION	0.00	21000.00	24582.70	TRF	3	2026	2026-04-22 06:12:29.820486+00	\N
fd1b629d-87dd-43ce-9a13-699cbc3ccc19	2026-03-24	e02ba8ca-75c6-48e3-9a87-486f1ad01984	TRANSFER DOLLARS TO METICAIS	5000.00	0.00	19582.70	TRF	3	2026	2026-04-22 06:12:29.820486+00	\N
c0915503-a30b-45eb-b377-05a010bdf411	2026-03-27	e02ba8ca-75c6-48e3-9a87-486f1ad01984	TRANSFER DOLLARS TO METICAIS	5000.00	0.00	14582.70	TRF	3	2026	2026-04-22 06:12:29.820486+00	\N
e205297d-a91b-4eb9-a647-b31129a4ba50	2026-03-30	e02ba8ca-75c6-48e3-9a87-486f1ad01984	TRANSFER DOLLARS TO METICAIS	5000.00	0.00	9582.70	TRF	3	2026	2026-04-22 06:12:29.820486+00	\N
be09aa39-7cb8-41e7-af9b-d611d9a3a422	\N	e02ba8ca-75c6-48e3-9a87-486f1ad01984		15009.27	24591.97	9582.70		3	2026	2026-04-22 06:12:29.820486+00	\N
\.


--
-- Data for Name: bim_salary_transfers; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.bim_salary_transfers (id, salary_run_id, employee_id, nib, name, amount, description, month, year, created_at) FROM stdin;
3b213cc1-aab8-4da1-b410-8dd14609e502	\N	f3da8412-3dae-45b0-b4df-23da5df5dbca	304762846	MARCO BEBE GIMO	67322.50	SALARIO 01/2026	1	2026	2026-04-13 09:06:45.315839+00
ab4cf4a5-11ea-4c22-aa45-89bd3a06c824	\N	20c0e869-ee8c-464c-99b8-5df806753cd0	312688813	ARMINDO QUETANE HOU	16777.28	SALARIO 01/2026	1	2026	2026-04-13 09:06:45.315839+00
19e1d1c3-465b-4e57-b6e9-fa36ee2d6aea	\N	8c597645-cf92-4003-84af-a781c51f69d1	88904090	CONSTANTINO JOSE PENGA	17230.72	SALARIO 01/2026	1	2026	2026-04-13 09:06:45.315839+00
a6b10934-4683-4f16-b531-e2415a8ad6cf	\N	8540a557-d3a3-45ed-99c1-a96007dc63de	311846368	ANSELMO LUCAS HUO	13603.20	SALARIO 01/2026	1	2026	2026-04-13 09:06:45.315839+00
c376400c-4e23-488d-90c6-3336c907b7f9	\N	a35d12c2-81fe-42bc-b195-38e9e713be34	465121888	CISTORA JOAO TANGUNE	10464.00	SALARIO 01/2026	1	2026	2026-04-13 09:06:45.315839+00
6b12a947-aece-4557-8deb-b8901753f712	\N	a591d7ff-6607-4406-b1bb-99fea46605e4	465126932	EMILIO GELSON ZIBANE	10987.20	SALARIO 01/2026	1	2026	2026-04-13 09:06:45.315839+00
bbf41030-d130-4d3a-b68b-620092503b30	\N	69627fba-2984-43c4-800e-c592fd1a18d0	784781120	ALMEIDA ANTONIO VILANCULO	10464.00	SALARIO 01/2026	1	2026	2026-04-13 09:06:45.315839+00
cfcce592-fb56-492b-b37b-06ed09e97b01	\N	b2db1ad4-a7d5-4551-8f47-edbf98149a8d	1236577535	FELIX CARLOS MASSUANGANHE	4964.00	SALARIO 01/2026	1	2026	2026-04-13 09:06:45.315839+00
7a9118e1-40f7-48a8-ac28-82c2293ffe05	\N	8aa3936d-1f8c-48f6-982a-2f9b58d2ec64	312354163	GILDA DALARIO FALACO MUABASA	10516.80	SALARIO 01/2026	1	2026	2026-04-13 09:06:45.315839+00
627293c1-3fc2-439a-89ea-219ebc1c2894	\N	25ef4bf1-4d69-4bea-b060-1d46a50248e8	426758485	SERGIO FRANCISCO TANGUNE	14231.04	SALARIO 01/2026	1	2026	2026-04-13 09:06:45.315839+00
ac4a0dcc-14f2-44be-82e9-b147b756878f	\N	6b858a35-05f5-4de9-9c69-15c80fde978e	000800007745713610195	AMINOSSE ARNALDO TANGUNE	13603.20	SALARIO 01/2026	1	2026	2026-04-13 09:06:45.315839+00
3cb9f43b-f919-42c3-bb3f-48eb16db7c8f	\N	c4ab3503-9e29-4c60-a8de-53dcca2b4225	311712702	SERGIO FRANCISCO TANGUNE ZITO	14283.84	SALARIO 01/2026	1	2026	2026-04-13 09:06:45.315839+00
a68075db-7940-4eb2-a373-a00ac4ed8caf	\N	b21601cf-206c-4a78-9cb7-73045874f36e	98059241	VITORIA FRANCISCO ZIBANE	10516.80	SALARIO 01/2026	1	2026	2026-04-13 09:06:45.315839+00
d111215c-749d-4608-86ae-371905f09c15	\N	7fcc5c4b-e6fe-4bb4-a459-d2481d7e7cf1	411440730	INACIO FABIAO TIMBE	15696.00	SALARIO 01/2026	1	2026	2026-04-13 09:06:45.315839+00
908e0c4a-9880-4e87-8a5c-aaa49e5f3fce	\N	ffd04fc1-9c18-4182-8998-4c1d7a09dc30	000800004412814610113	CALDERONE AGOSTINHO CHIVALE	15696.00	SALARIO 01/2026	1	2026	2026-04-13 09:06:45.315839+00
b6cf9ba7-4082-42b9-921d-805ffff8b4dd	\N	58ee18f4-5296-4864-9cf6-5dc79c29cfa5	393221511	PEDRO SEBASTIAO NHAMIRE	10987.20	SALARIO 01/2026	1	2026	2026-04-13 09:06:45.315839+00
1baac946-13b4-4393-b920-c3cde0abac4a	\N	1914c017-1c20-4db2-b712-413a6ac194dd	313333863	ROCINA CAHIWANE TIMBE	10516.80	SALARIO 01/2026	1	2026	2026-04-13 09:06:45.315839+00
37bf6e27-d199-484e-91f0-445304675001	\N	b609a704-c683-4b18-b1a5-6c62e382afde	305745068	ALEXANDRE LUCAS MASSUANGANHE	13656.00	SALARIO 01/2026	1	2026	2026-04-13 09:06:45.315839+00
4a98e119-0f46-4cca-9fc9-23b24b0616c4	\N	e7a713f6-7914-45d8-ac51-839247b3d641	311818141	JELSON QUALDADE ZIVANE	9487.20	SALARIO 01/2026	1	2026	2026-04-13 09:06:45.315839+00
5c128669-98d1-45ff-9896-41c12ed70811	\N	7a0ff3cb-1b78-48af-b980-681e55f09980	169475394	MONIS TSANZIUANE CHIVALE	13656.00	SALARIO 01/2026	1	2026	2026-04-13 09:06:45.315839+00
1d7ad9d9-dc32-469f-a4a7-d04f64148948	\N	0b1c761f-1e1d-4025-a4d4-1f6cfa312118	257804370	EVELIN NELSON BERNARDO	10516.80	SALARIO 01/2026	1	2026	2026-04-13 09:06:45.315839+00
99ba6d9c-c054-48cd-9200-359fd7d17c85	\N	f3da8412-3dae-45b0-b4df-23da5df5dbca	304762846	MARCO BEBE GIMO	67322.50	SALARIO 02/2026	2	2026	2026-04-13 09:06:45.534666+00
032d4bb4-0591-46c7-913c-06d00de8b2d5	\N	20c0e869-ee8c-464c-99b8-5df806753cd0	312688813	ARMINDO QUETANE HOU	14056.64	SALARIO 02/2026	2	2026	2026-04-13 09:06:45.534666+00
ebec91bb-2a2c-43ed-9371-84ed9dbce926	\N	8c597645-cf92-4003-84af-a781c51f69d1	88904090	CONSTANTINO JOSE PENGA	13603.20	SALARIO 02/2026	2	2026	2026-04-13 09:06:45.534666+00
71040976-72b3-4be7-9bd9-ea4bcfe252ee	\N	8540a557-d3a3-45ed-99c1-a96007dc63de	311846368	ANSELMO LUCAS HUO	14056.64	SALARIO 02/2026	2	2026	2026-04-13 09:06:45.534666+00
19e05c1c-91ed-4b75-8aad-23558f55f22b	\N	a35d12c2-81fe-42bc-b195-38e9e713be34	465121888	CISTORA JOAO TANGUNE	10464.00	SALARIO 02/2026	2	2026	2026-04-13 09:06:45.534666+00
85bff32e-9b2c-4f30-b01b-340c0da74962	\N	a591d7ff-6607-4406-b1bb-99fea46605e4	465126932	EMILIO GELSON ZIBANE	9487.20	SALARIO 02/2026	2	2026	2026-04-13 09:06:45.534666+00
db2f528f-79f4-4195-adfa-d2c81bb87909	\N	69627fba-2984-43c4-800e-c592fd1a18d0	784781120	ALMEIDA ANTONIO VILANCULO	10464.00	SALARIO 02/2026	2	2026	2026-04-13 09:06:45.534666+00
452cd1f5-3d28-4c1d-bd40-49f1c2a81c8d	\N	b2db1ad4-a7d5-4551-8f47-edbf98149a8d	1236577535	FELIX CARLOS MASSUANGANHE	10914.00	SALARIO 02/2026	2	2026	2026-04-13 09:06:45.534666+00
b25b6eab-37ac-420c-9217-320c144abf89	\N	8aa3936d-1f8c-48f6-982a-2f9b58d2ec64	312354163	GILDA DALARIO FALACO MUABASA	10516.80	SALARIO 02/2026	2	2026	2026-04-13 09:06:45.534666+00
da458cb6-96a2-4a2e-962d-e9a82526182b	\N	25ef4bf1-4d69-4bea-b060-1d46a50248e8	426758485	SERGIO FRANCISCO TANGUNE	15824.96	SALARIO 02/2026	2	2026	2026-04-13 09:06:45.534666+00
cc43b218-7698-4f78-9e05-6ee4e4af6826	\N	6b858a35-05f5-4de9-9c69-15c80fde978e	000800007745713610195	AMINOSSE ARNALDO TANGUNE	13603.20	SALARIO 02/2026	2	2026	2026-04-13 09:06:45.534666+00
24a91668-4d70-429f-8d62-9feee651a0cc	\N	c4ab3503-9e29-4c60-a8de-53dcca2b4225	311712702	SERGIO FRANCISCO TANGUNE ZITO	20683.12	SALARIO 02/2026	2	2026	2026-04-13 09:06:45.534666+00
bfbee2b2-0a0a-4566-9347-0715a4bb576c	\N	b21601cf-206c-4a78-9cb7-73045874f36e	98059241	VITORIA FRANCISCO ZIBANE	10516.80	SALARIO 02/2026	2	2026	2026-04-13 09:06:45.534666+00
19d11e1a-c335-4d45-bcd6-34d9f86eadbc	\N	7fcc5c4b-e6fe-4bb4-a459-d2481d7e7cf1	411440730	INACIO FABIAO TIMBE	15696.00	SALARIO 02/2026	2	2026	2026-04-13 09:06:45.534666+00
7235beb8-f06d-4524-bbb6-05c273a53b4a	\N	ffd04fc1-9c18-4182-8998-4c1d7a09dc30	000800004412814610113	CALDERONE AGOSTINHO CHIVALE	15696.00	SALARIO 02/2026	2	2026	2026-04-13 09:06:45.534666+00
c1036a8a-2fb3-4cce-a08f-03556144e5ca	\N	58ee18f4-5296-4864-9cf6-5dc79c29cfa5	393221511	PEDRO SEBASTIAO NHAMIRE	10987.20	SALARIO 02/2026	2	2026	2026-04-13 09:06:45.534666+00
1c815afb-c62d-4152-9c8d-bcb3606648da	\N	1914c017-1c20-4db2-b712-413a6ac194dd	313333863	ROCINA CAHIWANE TIMBE	11393.20	SALARIO 02/2026	2	2026	2026-04-13 09:06:45.534666+00
6c619d93-0d96-4ac5-9540-0ad067b2f50f	\N	b609a704-c683-4b18-b1a5-6c62e382afde	305745068	ALEXANDRE LUCAS MASSUANGANHE	11294.00	SALARIO 02/2026	2	2026	2026-04-13 09:06:45.534666+00
4d6b5316-2964-43d7-bd75-646da283b29c	\N	7a0ff3cb-1b78-48af-b980-681e55f09980	169475394	MONIS TSANZIUANE CHIVALE	13656.00	SALARIO 02/2026	2	2026	2026-04-13 09:06:45.534666+00
7e3e3455-f103-4500-b480-8ac8165b1707	\N	0b1c761f-1e1d-4025-a4d4-1f6cfa312118	257804370	EVELIN NELSON BERNARDO	10516.80	SALARIO 02/2026	2	2026	2026-04-13 09:06:45.534666+00
6e06bf5d-581b-4454-a119-1688202dbba4	\N	f3da8412-3dae-45b0-b4df-23da5df5dbca	304762846	MARCO BEBE GIMO	67322.50	SALARIO 03/2026	3	2026	2026-04-13 09:06:45.756569+00
6fd4a829-2483-4c16-99a6-df5c5196775a	\N	20c0e869-ee8c-464c-99b8-5df806753cd0	312688813	ARMINDO QUETANE HOU	12696.32	SALARIO 03/2026	3	2026	2026-04-13 09:06:45.756569+00
d2f4a5c4-125c-469c-aa2a-ba432a85c02b	\N	8c597645-cf92-4003-84af-a781c51f69d1	88904090	CONSTANTINO JOSE PENGA	12696.32	SALARIO 03/2026	3	2026	2026-04-13 09:06:45.756569+00
b99cd22a-1aaa-4239-8a37-620fa5bbb354	\N	8540a557-d3a3-45ed-99c1-a96007dc63de	311846368	ANSELMO LUCAS HUO	12696.32	SALARIO 03/2026	3	2026	2026-04-13 09:06:45.756569+00
e8f0573b-38f5-42aa-a22f-91be366b7337	\N	a35d12c2-81fe-42bc-b195-38e9e713be34	465121888	CISTORA JOAO TANGUNE	10464.00	SALARIO 03/2026	3	2026	2026-04-13 09:06:45.756569+00
bbc114be-425c-4a70-a221-9c2762bbb924	\N	a591d7ff-6607-4406-b1bb-99fea46605e4	465126932	EMILIO GELSON ZIBANE	8687.20	SALARIO 03/2026	3	2026	2026-04-13 09:06:45.756569+00
2403f1a2-c348-4f00-bab0-a907cf370f6d	\N	69627fba-2984-43c4-800e-c592fd1a18d0	784781120	ALMEIDA ANTONIO VILANCULO	10464.00	SALARIO 03/2026	3	2026	2026-04-13 09:06:45.756569+00
06234249-883e-470e-9636-c73befac6d1f	\N	b2db1ad4-a7d5-4551-8f47-edbf98149a8d	1236577535	FELIX CARLOS MASSUANGANHE	10464.00	SALARIO 03/2026	3	2026	2026-04-13 09:06:45.756569+00
40e7d9bf-d438-4e1a-a3a8-592df3384f1b	\N	8aa3936d-1f8c-48f6-982a-2f9b58d2ec64	312354163	GILDA DALARIO FALACO MUABASA	10516.80	SALARIO 03/2026	3	2026	2026-04-13 09:06:45.756569+00
01e8d039-4593-41aa-9282-9673f7167445	\N	25ef4bf1-4d69-4bea-b060-1d46a50248e8	426758485	SERGIO FRANCISCO TANGUNE	14231.04	SALARIO 03/2026	3	2026	2026-04-13 09:06:45.756569+00
dbb7983f-91f1-4738-ab25-bb5428e18e3d	\N	6b858a35-05f5-4de9-9c69-15c80fde978e	000800007745713610195	AMINOSSE ARNALDO TANGUNE	14968.20	SALARIO 03/2026	3	2026	2026-04-13 09:06:45.756569+00
84db3981-e602-4828-b770-e835a0faa675	\N	c4ab3503-9e29-4c60-a8de-53dcca2b4225	311712702	SERGIO FRANCISCO TANGUNE ZITO	14154.35	SALARIO 03/2026	3	2026	2026-04-13 09:06:45.756569+00
b3aa717d-4575-423e-b439-62536c90e019	\N	b21601cf-206c-4a78-9cb7-73045874f36e	98059241	VITORIA FRANCISCO ZIBANE	10516.80	SALARIO 03/2026	3	2026	2026-04-13 09:06:45.756569+00
006a762f-6e66-4324-8cfc-ec7b43b65521	\N	7fcc5c4b-e6fe-4bb4-a459-d2481d7e7cf1	411440730	INACIO FABIAO TIMBE	15696.00	SALARIO 03/2026	3	2026	2026-04-13 09:06:45.756569+00
71d2e77d-2aae-4194-b61a-c947710230c7	\N	ffd04fc1-9c18-4182-8998-4c1d7a09dc30	000800004412814610113	CALDERONE AGOSTINHO CHIVALE	14196.00	SALARIO 03/2026	3	2026	2026-04-13 09:06:45.756569+00
28f64606-f55c-4ac0-a543-c13ef2643065	\N	58ee18f4-5296-4864-9cf6-5dc79c29cfa5	393221511	PEDRO SEBASTIAO NHAMIRE	10987.20	SALARIO 03/2026	3	2026	2026-04-13 09:06:45.756569+00
aed8fcb3-c42c-496c-941d-7994bc6ac8e7	\N	1914c017-1c20-4db2-b712-413a6ac194dd	313333863	ROCINA CAHIWANE TIMBE	10516.80	SALARIO 03/2026	3	2026	2026-04-13 09:06:45.756569+00
0caecc13-47c4-48f0-af76-7d62faa06116	\N	b609a704-c683-4b18-b1a5-6c62e382afde	305745068	ALEXANDRE LUCAS MASSUANGANHE	13656.00	SALARIO 03/2026	3	2026	2026-04-13 09:06:45.756569+00
a51dadc6-05cf-4b5b-909f-35d3ac750407	\N	e7a713f6-7914-45d8-ac51-839247b3d641	311818141	JELSON QUALDADE ZIVANE	5987.20	SALARIO 03/2026	3	2026	2026-04-13 09:06:45.756569+00
cdda0480-ffe2-4d4e-ae7a-1d3203eaf394	\N	7a0ff3cb-1b78-48af-b980-681e55f09980	169475394	MONIS TSANZIUANE CHIVALE	13656.00	SALARIO 03/2026	3	2026	2026-04-13 09:06:45.756569+00
dd4bdee9-9ef8-4b64-8dda-28a0f51b0c8c	\N	0b1c761f-1e1d-4025-a4d4-1f6cfa312118	257804370	EVELIN NELSON BERNARDO	10516.80	SALARIO 03/2026	3	2026	2026-04-13 09:06:45.756569+00
\.


--
-- Data for Name: cash_allocation_columns; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.cash_allocation_columns (id, sheet_type, column_name, sort_order, created_at) FROM stdin;
3430ec2b-826e-492b-a665-a07326c86b7a	petty_cash	Saldo	0	2026-04-22 14:24:56.792347+00
ca64785c-f83a-4205-8f0a-fe7eb87570f1	petty_cash	Income	1	2026-04-22 14:24:56.818445+00
3577d6dc-d480-49f5-9430-966ffdaae7b5	petty_cash	IVA output tax	2	2026-04-22 14:24:56.844092+00
bc4a9f9b-9f8d-4c64-ba2a-05349ad198ac	petty_cash	Diesel/Petrol	3	2026-04-22 14:24:56.86989+00
823725f4-7740-40f2-869b-36a5ce2ca3f2	petty_cash	GAS / ELECTRICITY	4	2026-04-22 14:24:56.895745+00
4708f170-10cd-438d-a3ea-fc82b616cd68	petty_cash	POOLS/Maintanance Garden	5	2026-04-22 14:24:56.921158+00
ad838da2-c9d2-4b97-88ae-d8190cddb2d3	petty_cash	Maintanance General	6	2026-04-22 14:24:56.946668+00
1344041d-044d-4767-b09a-813e9aee6e16	petty_cash	Small Equipement	7	2026-04-22 14:24:56.972449+00
3da78a16-5408-4570-b4ab-c0ccd083fd6d	petty_cash	HOUSEKEEPING	8	2026-04-22 14:24:56.998153+00
4470d798-c3fc-4e3f-bb29-4f361fbc74d9	petty_cash	OFFICE/ ADMIN	9	2026-04-22 14:24:57.023804+00
e16d1cc7-5e52-4d74-bd3d-96b0f8ebc705	petty_cash	Commission	10	2026-04-22 14:24:57.049474+00
16696e0d-f09a-4210-bdc1-5d9c6ec1de4e	petty_cash	Salaries	11	2026-04-22 14:24:57.075353+00
579e3ac9-5093-42a4-819e-9bf7fa1b341d	petty_cash	INSS	12	2026-04-22 14:24:57.101905+00
59172859-b5a9-40aa-a7a6-850f3684a03c	petty_cash	ACCOUNTANT	13	2026-04-22 14:24:57.127635+00
949668bf-01df-4bc5-85c5-6dfe8862a78a	petty_cash	IRPC/IVA Import	14	2026-04-22 14:24:57.153251+00
859cb2c5-23e7-4aea-8f3d-aaabebcb359b	petty_cash	EB Fishing Charters	15	2026-04-22 14:24:57.178853+00
e6d08e5d-dc31-4f44-b905-987ffc5546c1	petty_cash	Suspence Account Expenses previous Month CC	16	2026-04-22 14:24:57.204728+00
f8ac8d46-d58b-4853-a0d9-ff2a31bf743d	petty_cash	Workers Kitchen	17	2026-04-22 14:24:57.230686+00
5d08c264-c0ba-4474-a871-d72b7699fd36	emola	Building	0	2026-04-22 14:24:57.256412+00
51687939-da13-4c49-a1ff-215ccf14a120	emola	Plumber	1	2026-04-22 14:24:57.282683+00
fe28ab24-0ea5-45a0-beca-05bc77d54840	emola	Painter	2	2026-04-22 14:24:57.308411+00
f2f53d07-e7e1-4a59-83c0-ff7772f504b0	emola	Transport	3	2026-04-22 14:24:57.334988+00
6e9c404f-36a7-4f79-a98e-fe617e2c5dfe	emola	Anselmo	4	2026-04-22 14:24:57.360764+00
94e6e25e-9c0f-4d46-814f-b5d1a590032a	emola	Ebony	5	2026-04-22 14:24:57.386622+00
2588b2d0-61f6-494a-935c-08b2142db31c	emola	Self	6	2026-04-22 14:24:57.412824+00
9b6a37dc-857a-489c-b545-daa96129c42e	mpesa	Landco	0	2026-04-22 14:24:57.438396+00
a4bf4e60-3c57-4a42-93f2-f4b2253a24e4	mpesa	Ebony	1	2026-04-22 14:24:57.464308+00
56683abc-534a-4808-b085-d792fe56661c	mpesa	Marbar	2	2026-04-22 14:24:57.490033+00
32a91373-aaa5-4a50-8b8e-16af895c82f1	mpesa	Andrisa	3	2026-04-22 14:24:57.515976+00
9fa73b75-fc75-4be6-abd9-e580098095d8	mpesa	Bernard	4	2026-04-22 14:24:57.541762+00
ab051119-51c7-45e5-b044-8f9d253a53fb	mpesa	Claudio	5	2026-04-22 14:24:57.567621+00
\.


--
-- Data for Name: cash_dropdown_options; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.cash_dropdown_options (id, sheet_type, column_key, value, sort_order, created_at) FROM stdin;
9c12333d-8415-4436-8902-a56da3d6592d	petty_cash	allocation	Saldo	0	2026-04-22 14:24:57.593562+00
b94a42e8-46bf-4d18-9eb8-23dfbe994fb3	petty_cash	allocation	Income	1	2026-04-22 14:24:57.620297+00
b1ece606-2a6d-4db7-9c88-6582da4c58c0	petty_cash	allocation	IVA output tax	2	2026-04-22 14:24:57.646255+00
cd6044b6-5f85-4a9e-92db-e64dc13df97f	petty_cash	allocation	Diesel/Petrol	3	2026-04-22 14:24:57.672176+00
506396ef-340c-4835-9837-58d23c475f6e	petty_cash	allocation	GAS / ELECTRICITY	4	2026-04-22 14:24:57.699189+00
b8b36d75-6662-4ed7-ac9d-adab56890597	petty_cash	allocation	POOLS/Maintanance Garden	5	2026-04-22 14:24:57.724815+00
14342e6b-2332-43fc-a1a5-35be2a3ccc8e	petty_cash	allocation	Maintanance General	6	2026-04-22 14:24:57.750513+00
27e67fd2-15f9-4791-ad51-d03540a5d492	petty_cash	allocation	Small Equipement	7	2026-04-22 14:24:57.776105+00
2a675b6a-a7ff-4642-8e08-91a9e3f08f77	petty_cash	allocation	HOUSEKEEPING	8	2026-04-22 14:24:57.801778+00
0b291fcb-174b-4408-92df-969e3f1dc781	petty_cash	allocation	OFFICE/ ADMIN	9	2026-04-22 14:24:57.828054+00
bd36f37f-f541-4a39-a0bc-6996d719ceee	petty_cash	allocation	Commission	10	2026-04-22 14:24:57.854144+00
2b2d62ac-9914-438f-8d99-b09860467ae4	petty_cash	allocation	Salaries	11	2026-04-22 14:24:57.879995+00
9f2ae1c6-dc57-4c74-aa17-cf9e7c0b559d	petty_cash	allocation	INSS	12	2026-04-22 14:24:57.90592+00
c6753cf9-db2c-4399-a5bb-c12104a36826	petty_cash	allocation	ACCOUNTANT	13	2026-04-22 14:24:57.931792+00
e7edce67-93f6-4a95-894f-3229a6048f51	petty_cash	allocation	IRPC/IVA Import	14	2026-04-22 14:24:57.957388+00
bafe7da0-3e8b-4354-8eb6-02d4e05ec851	petty_cash	allocation	EB Fishing Charters	15	2026-04-22 14:24:57.983925+00
a88342ff-4317-46f8-ada2-03a3434e3910	petty_cash	allocation	Suspence Account Expenses previous Month CC	16	2026-04-22 14:24:58.009453+00
e88d0079-a673-4546-98ed-7f57a109b751	petty_cash	allocation	Workers Kitchen	17	2026-04-22 14:24:58.035316+00
e654fbf0-18e1-4991-8a01-14479fca91fe	petty_cash	company	EBFC	0	2026-04-22 14:24:58.063097+00
9a3e9afe-2b69-4f18-b59b-b0ce2f73b284	petty_cash	company	Dom	1	2026-04-22 14:24:58.088935+00
8be33347-32db-4653-b6ff-4d7ccd565f31	petty_cash	company	Ebony	2	2026-04-22 14:24:58.114433+00
c4a0ba79-bea4-4618-9e98-cf0b892503a0	petty_cash	company	Advance payment	3	2026-04-22 14:24:58.140269+00
2cad2c68-43f4-4404-97d2-6bcad84866d5	petty_cash	company	Received Jen	4	2026-04-22 14:24:58.165783+00
7d153526-9a01-4c11-9792-b600da5a8018	petty_cash	company	Andrisa	5	2026-04-22 14:24:58.19362+00
11d59976-b187-4be3-97e8-3434b5569476	petty_cash	company	Bank Account	6	2026-04-22 14:24:58.220185+00
e245793e-4091-4cc3-8e69-3d14b57b2c74	petty_cash	company	BYRON	7	2026-04-22 14:24:58.245999+00
49e1d9c7-4976-4717-9f06-b0f8edad740e	petty_cash	company	Chris	8	2026-04-22 14:24:58.271824+00
15ab80cc-6e27-4176-b47e-dfb5d834dff4	petty_cash	company	Geraldo	9	2026-04-22 14:24:58.298518+00
6f152444-fb52-4b00-828a-30eb422079d0	petty_cash	company	Abdul	10	2026-04-22 14:24:58.326427+00
9f58ccc1-0232-4655-ba57-03f311038887	petty_cash	company	Chinees shop	11	2026-04-22 14:24:58.352208+00
95e9f3be-a3cc-4530-a868-6a5505f840db	petty_cash	company	Jelson	12	2026-04-22 14:24:58.378036+00
7c4a2999-3b6a-40fe-a01a-235808e91bb1	petty_cash	company	Aron	13	2026-04-22 14:24:58.404546+00
9b320259-d99b-48af-b9f4-b91bd9cd60e0	petty_cash	company	GERALDO	14	2026-04-22 14:24:58.430522+00
b3386e6d-1a68-47f2-85ea-2aeb0c681d30	petty_cash	company	Hortencia sister	15	2026-04-22 14:24:58.45627+00
e210febe-9f5c-41a1-a2af-5dad2dcd4257	petty_cash	company	Diesel Cruiser	16	2026-04-22 14:24:58.481874+00
b3614276-beb0-44e3-b592-c2c9427300a3	petty_cash	company	Julio	17	2026-04-22 14:24:58.507903+00
54e1242e-b602-47e7-be35-4e5251fe26ff	petty_cash	company	Municipal	18	2026-04-22 14:24:58.533804+00
bb7d325e-4521-448f-922c-f8c1f586c605	petty_cash	company	Horse Safari	19	2026-04-22 14:24:58.561605+00
fec9762c-7569-4ede-ba35-1f3d4e2c9182	petty_cash	company	Overtime Good Friday	20	2026-04-22 14:24:58.588043+00
edd5c0f2-77b6-4d79-a031-52b98eff026a	petty_cash	company	Pedro	21	2026-04-22 14:24:58.613648+00
800541b4-5e85-4778-99e1-9ebf558f49e7	petty_cash	company	Hortensia sister	22	2026-04-22 14:24:58.640225+00
7c172398-3763-40fa-85c7-62455fa3e3f2	petty_cash	company	Aderito	23	2026-04-22 14:24:58.665893+00
13419d12-74d4-4966-b6a4-bf04f01295b5	petty_cash	company	Felix	24	2026-04-22 14:24:58.691527+00
bf22c7cc-3b84-4fb8-aeb9-a2c18fb13dad	petty_cash	company	Bonze	25	2026-04-22 14:24:58.717255+00
4caeb2b0-113c-4fa0-aa2a-4a31cd06aba0	petty_cash	company	Audencia	26	2026-04-22 14:24:58.742958+00
18cdec7e-5f56-4228-975a-1122e32721ed	petty_cash	company	Road shop	27	2026-04-22 14:24:58.777281+00
c135de49-f006-469d-aa29-e41edd1d9f0a	petty_cash	cheque_type	332924	0	2026-04-22 14:24:58.803361+00
1e51fe1f-5d23-47d2-96dc-762625661759	petty_cash	cheque_type	1734	1	2026-04-22 14:24:58.829431+00
0b33dcb3-4615-4fd6-a08d-5c971adc19aa	petty_cash	cheque_type	428	2	2026-04-22 14:24:58.855827+00
2a656c24-8f95-4f26-bf1e-c7c953fedfbf	petty_cash	cheque_type	Arlindo	3	2026-04-22 14:24:58.881469+00
94409ff9-f64d-43e8-83ca-0f3f9bd1fecd	petty_cash	cheque_type	Adelino Salary	4	2026-04-22 14:24:58.907304+00
a9124f40-d117-415d-bef4-5da4bb470d5e	petty_cash	cheque_type	DEP	5	2026-04-22 14:24:58.933164+00
bf67a7b0-6069-421c-814c-f948cb0ebae2	petty_cash	cheque_type	Cash	6	2026-04-22 14:24:58.958952+00
ab8d8a6b-77ef-457e-a1d9-834a17ebd62d	petty_cash	cheque_type	Mpesa	7	2026-04-22 14:24:58.985164+00
76489f31-a7f6-4cf5-ad54-9b4ee98cef5b	petty_cash	cheque_type	Emola	8	2026-04-22 14:24:59.011887+00
5d6cbf05-efa9-4243-b454-3575777696d0	emola	allocation	Building	0	2026-04-22 14:24:59.03773+00
cad63ae4-e622-4439-98a6-32f9d10ee1eb	emola	allocation	Plumber	1	2026-04-22 14:24:59.063425+00
d9b361bc-2873-42c3-863e-e4d29e0891c1	emola	allocation	Painter	2	2026-04-22 14:24:59.089824+00
cb7893d2-71b5-4b8c-a323-705978d8a9bc	emola	allocation	Transport	3	2026-04-22 14:24:59.116488+00
3192839b-5853-4e51-859f-98f75532cc8c	emola	allocation	Anselmo	4	2026-04-22 14:24:59.143521+00
a17e3539-888b-41ab-836d-933a756b8495	emola	allocation	Ebony	5	2026-04-22 14:24:59.169445+00
1d8e687c-1c95-41d6-a7c8-323e415ad15f	emola	allocation	Self	6	2026-04-22 14:24:59.195288+00
c80f4589-8538-4ffe-a75f-842625440c6a	mpesa	allocation	Landco	0	2026-04-22 14:24:59.221279+00
4ba391c6-b483-407d-80cc-e096f1447cee	mpesa	allocation	Ebony	1	2026-04-22 14:24:59.247902+00
b2c9842d-e912-4b39-b49e-9a5b4763769e	mpesa	allocation	Marbar	2	2026-04-22 14:24:59.274882+00
b12c8d8d-6a37-4c67-8415-042a7bd138e4	mpesa	allocation	Andrisa	3	2026-04-22 14:24:59.300806+00
6236fae7-1f9f-4360-a85c-ffda7d4c83d3	mpesa	allocation	Bernard	4	2026-04-22 14:24:59.326347+00
336e3c21-c072-4a94-b567-4472f0492c57	mpesa	allocation	Claudio	5	2026-04-22 14:24:59.352091+00
76c4ba74-645e-4549-bbe5-b0034cc56df3	emola	funder	Landco	0	2026-04-23 11:38:29.994624+00
47031e0c-9d01-49b2-8534-ae3ae724c54b	emola	receiver	Bones	0	2026-04-23 11:39:03.592997+00
55dd1b87-fc77-4cb1-9d12-2dc8be8c16af	emola	funder	Byron	0	2026-04-23 12:23:26.051247+00
5610474c-65d2-4546-8861-e72a9fbfd7bf	emola	funder	Anrisa	0	2026-04-23 12:23:46.771555+00
4e91b4f2-5577-4800-866d-fbbd47de238b	emola	funder	Chris	0	2026-04-23 12:24:34.91476+00
881b9811-4577-4b3a-936e-6e00dc235000	emola	funder	LC	0	2026-04-24 08:32:56.077434+00
948d4fb2-d361-4277-bdaf-86ee44a3c97a	emola	funder	Ebony	0	2026-04-24 08:33:08.086751+00
\.


--
-- Data for Name: cash_sheets; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.cash_sheets (id, sheet_type, month, year, opening_balance, opening_description, source_file, created_at, updated_at) FROM stdin;
b6724b98-560e-48b9-a6ea-0f792db6f37b	petty_cash	1	2026	23903.27	BALANCE B/F	Money Box.xlsx	2026-04-22 14:24:56.597976+00	2026-04-22 14:24:56.597976+00
6abdefbd-00ff-45aa-8f1c-fb2e9441e3c7	petty_cash	2	2026	10903.27	BALANCE B/F	Money Box.xlsx	2026-04-22 14:24:56.629277+00	2026-04-22 14:24:56.629277+00
924ab446-b357-4b2c-bae6-8dbcd9716306	petty_cash	3	2026	-7678.52	BALANCE B/F	Money Box.xlsx	2026-04-22 14:24:56.656262+00	2026-04-22 14:24:56.656262+00
b1e1cc24-4d42-4ebb-b678-a3a0176f1a74	petty_cash	4	2026	-950.12	BALANCE B/F	Money Box.xlsx	2026-04-22 14:24:56.686648+00	2026-04-22 14:24:56.686648+00
388a9c8a-30e4-49b2-b91a-b1813b61e0f5	emola	\N	2026	3320.0	Balance	Emola.xlsx	2026-04-22 14:24:56.716838+00	2026-04-22 14:24:56.716838+00
b820cbed-2378-4b87-a711-dd4615c774c8	mpesa	\N	2026	22777.570000000007	Balance end Dec	Mpesa.xlsx	2026-04-22 14:24:56.754661+00	2026-04-22 14:24:56.754661+00
\.


--
-- Data for Name: cash_transactions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.cash_transactions (id, sheet_type, sheet_id, row_no, tx_date, month, year, description, funder, receiver, cell_no, cheque_no, company, entrada, saida, bank_charges, balance, allocation_column, allocation_amount, allocations, source_file, created_at, updated_at) FROM stdin;
7ce8b51a-5341-451e-b57d-35c23baad148	petty_cash	b6724b98-560e-48b9-a6ea-0f792db6f37b	1	2026-01-24	1	2026	Loan	\N	\N	\N	\N	EBFC	0	1500.0	0	\N	Saldo	22403.27	{"Saldo": 22403.27, "EB Fishing Charters": 1500.0}	Money Box.xlsx	2026-04-22 14:24:56.597976+00	2026-04-22 14:24:56.597976+00
f6e70d05-6c4b-42ab-8dc0-57fb7103b708	petty_cash	b6724b98-560e-48b9-a6ea-0f792db6f37b	2	2026-01-24	1	2026	Loan deduct from salary 9500+7661,73 frpm CTC	\N	\N	\N	332924	EBFC	0	9500.0	0	\N	Saldo	12903.27	{"Saldo": 12903.27, "EB Fishing Charters": 9500.0}	Money Box.xlsx	2026-04-22 14:24:56.597976+00	2026-04-22 14:24:56.597976+00
d4842498-28be-4512-aac8-7a04e5427f12	petty_cash	b6724b98-560e-48b9-a6ea-0f792db6f37b	3	2026-01-26	1	2026	Boat to Xibaha	\N	\N	\N	1734	EBFC	0	1000.0	0	\N	Saldo	11903.27	{"Saldo": 11903.27, "EB Fishing Charters": 1000.0}	Money Box.xlsx	2026-04-22 14:24:56.597976+00	2026-04-22 14:24:56.597976+00
428ab82e-6964-45dc-b760-603b615f2b68	petty_cash	b6724b98-560e-48b9-a6ea-0f792db6f37b	4	2026-01-26	1	2026	Boat to Xibaha	\N	\N	\N	428	Dom	0	1000.0	0	\N	Saldo	10903.27	{"Saldo": 10903.27, "EB Fishing Charters": 1000.0}	Money Box.xlsx	2026-04-22 14:24:56.597976+00	2026-04-22 14:24:56.597976+00
86a631ed-7ebe-4a5d-8fb0-375d12fd268a	petty_cash	b6724b98-560e-48b9-a6ea-0f792db6f37b	\N	\N	1	2026		\N	\N	\N	\N	\N	23903.27	13000.0	0	\N	Saldo	10903.27	{"Saldo": 10903.27, "EB Fishing Charters": 13000.0}	Money Box.xlsx	2026-04-22 14:24:56.597976+00	2026-04-22 14:24:56.597976+00
fadaf752-76ac-4337-b48a-258a65ab8904	petty_cash	6abdefbd-00ff-45aa-8f1c-fb2e9441e3c7	1	2026-02-12	2	2026	Work Cyclone	\N	\N	\N	Arlindo	Ebony	0	1000.0	0	\N	Saldo	9903.27	{"Saldo": 9903.27, "EB Fishing Charters": 1000.0}	Money Box.xlsx	2026-04-22 14:24:56.629277+00	2026-04-22 14:24:56.629277+00
136ab3f7-a451-41f4-b734-f81c11e656fc	petty_cash	6abdefbd-00ff-45aa-8f1c-fb2e9441e3c7	2	2026-02-12	2	2026	Work Cyclone Food and data	\N	\N	\N	Arlindo	Ebony	0	400.0	0	\N	Saldo	9503.27	{"Saldo": 9503.27, "EB Fishing Charters": 400.0}	Money Box.xlsx	2026-04-22 14:24:56.629277+00	2026-04-22 14:24:56.629277+00
c17b4e1f-0372-4ed0-bb38-328f7797465e	petty_cash	6abdefbd-00ff-45aa-8f1c-fb2e9441e3c7	3	2026-02-25	2	2026	Salary Feb BIM	\N	\N	\N	Adelino Salary	EBFC	0	17181.79	0	\N	Saldo	-7678.52	{"Saldo": -7678.52, "EB Fishing Charters": 17181.79}	Money Box.xlsx	2026-04-22 14:24:56.629277+00	2026-04-22 14:24:56.629277+00
567df368-94dc-4348-9a8c-9e0f7223e870	petty_cash	6abdefbd-00ff-45aa-8f1c-fb2e9441e3c7	\N	\N	2	2026		\N	\N	\N	\N	\N	10903.27	18581.79	0	\N	Saldo	-7678.52	{"Saldo": -7678.52, "EB Fishing Charters": 18581.79}	Money Box.xlsx	2026-04-22 14:24:56.629277+00	2026-04-22 14:24:56.629277+00
4f9b7e6f-74ff-4d4b-9bc0-b71c3baa0d8e	petty_cash	924ab446-b357-4b2c-bae6-8dbcd9716306	1	2026-03-05	3	2026	Jen Accommodation for March old price rate 64@2600	\N	\N	\N	DEP	Advance payment	174080.0	0	0	\N	Saldo	166401.48	{"Saldo": 166401.48}	Money Box.xlsx	2026-04-22 14:24:56.656262+00	2026-04-22 14:24:56.656262+00
07c985c0-82f9-4c5c-9871-25276a94c360	petty_cash	924ab446-b357-4b2c-bae6-8dbcd9716306	2	2026-03-05	3	2026	Jen Accommodation one day for son $120 @64	\N	\N	\N	DEP	Received Jen	7680.0	0	0	\N	Saldo	174081.48	{"Saldo": 174081.48}	Money Box.xlsx	2026-04-22 14:24:56.656262+00	2026-04-22 14:24:56.656262+00
79a682dd-d340-4eda-8b50-50747c7a94ba	petty_cash	924ab446-b357-4b2c-bae6-8dbcd9716306	3	2026-03-05	3	2026	Commission 7%	\N	\N	\N	\N	Andrisa	0	12185.6	0	\N	Saldo	161895.88	{"Saldo": 161895.88, "EB Fishing Charters": 12185.6}	Money Box.xlsx	2026-04-22 14:24:56.656262+00	2026-04-22 14:24:56.656262+00
2da119f4-a6d1-408f-823b-c3d25a721af1	petty_cash	924ab446-b357-4b2c-bae6-8dbcd9716306	4	2026-03-05	3	2026	Deposit to bank plus advance Dec 40 000	\N	\N	\N	\N	Bank Account	0	150000.0	0	\N	Saldo	11895.880000000005	{"Saldo": 11895.880000000005, "EB Fishing Charters": 150000.0}	Money Box.xlsx	2026-04-22 14:24:56.656262+00	2026-04-22 14:24:56.656262+00
523f4b23-096c-4f2c-8340-00dc0615ea75	petty_cash	924ab446-b357-4b2c-bae6-8dbcd9716306	5	2026-03-11	3	2026	Crewbase paid to Crewbase R48876 @ 4,0	\N	\N	\N	\N	BYRON	195504.0	0	0	\N	Saldo	207399.88	{"Saldo": 207399.88}	Money Box.xlsx	2026-04-22 14:24:56.656262+00	2026-04-22 14:24:56.656262+00
463d3b87-7b95-40ae-ba0b-2b8bd0490e1f	petty_cash	924ab446-b357-4b2c-bae6-8dbcd9716306	6	2026-03-12	3	2026	Payment for Deck	\N	\N	\N	\N	Chris	0	58970.0	0	\N	Saldo	148429.88	{"Saldo": 148429.88}	Money Box.xlsx	2026-04-22 14:24:56.656262+00	2026-04-22 14:24:56.656262+00
2bcf3642-f646-4af8-bf32-f20a060d6c83	petty_cash	924ab446-b357-4b2c-bae6-8dbcd9716306	7	2026-03-12	3	2026	DIRE contribution R26700*4	\N	\N	\N	\N	Andrisa	0	106800.0	0	\N	Saldo	41629.880000000005	{"Saldo": 41629.880000000005}	Money Box.xlsx	2026-04-22 14:24:56.656262+00	2026-04-22 14:24:56.656262+00
ca20696b-9d95-4958-8547-ab2635b00675	petty_cash	924ab446-b357-4b2c-bae6-8dbcd9716306	8	2026-03-12	3	2026	Rubish removal	\N	\N	\N	\N	Geraldo	0	2500.0	0	\N	Saldo	39129.880000000005	{"Saldo": 39129.880000000005}	Money Box.xlsx	2026-04-22 14:24:56.656262+00	2026-04-22 14:24:56.656262+00
26112e59-65cb-44f8-b3f3-52a908b25bb9	petty_cash	924ab446-b357-4b2c-bae6-8dbcd9716306	9	2026-03-12	3	2026	Plants BH3 + one Pedro	\N	\N	\N	\N	Abdul	0	1160.0	0	\N	Saldo	37969.880000000005	{"Saldo": 37969.880000000005}	Money Box.xlsx	2026-04-22 14:24:56.656262+00	2026-04-22 14:24:56.656262+00
fc41a0ff-9b68-4e49-8a94-c8815562ec8b	petty_cash	924ab446-b357-4b2c-bae6-8dbcd9716306	10	2026-03-12	3	2026	Soap Workers	\N	\N	\N	\N	Chinees shop	0	1320.0	0	\N	Saldo	36649.880000000005	{"Saldo": 36649.880000000005}	Money Box.xlsx	2026-04-22 14:24:56.656262+00	2026-04-22 14:24:56.656262+00
025eb5c3-57f7-4c54-862f-10dea24ce33e	petty_cash	924ab446-b357-4b2c-bae6-8dbcd9716306	11	2026-03-13	3	2026	Plants BH3	\N	\N	\N	\N	Jelson	0	200.0	0	\N	Saldo	36449.880000000005	{"Saldo": 36449.880000000005}	Money Box.xlsx	2026-04-22 14:24:56.656262+00	2026-04-22 14:24:56.656262+00
d803650b-259e-4015-a340-e39879225740	petty_cash	924ab446-b357-4b2c-bae6-8dbcd9716306	12	2026-03-15	3	2026	Thatch leak roofs of H1 H2 H3 plus Jegga	\N	\N	\N	\N	Aron	0	21000.0	0	\N	Saldo	15449.880000000005	{"Saldo": 15449.880000000005}	Money Box.xlsx	2026-04-22 14:24:56.656262+00	2026-04-22 14:24:56.656262+00
d442d987-86b9-4e8c-b64c-5560a5767d4c	petty_cash	924ab446-b357-4b2c-bae6-8dbcd9716306	13	2026-03-27	3	2026	Rubish removal	\N	\N	\N	\N	GERALDO	0	1500.0	0	\N	Saldo	13949.880000000005	{"Saldo": 13949.880000000005}	Money Box.xlsx	2026-04-22 14:24:56.656262+00	2026-04-22 14:24:56.656262+00
fe4d0e35-ad2a-4507-8f81-a8d89d075ae6	petty_cash	924ab446-b357-4b2c-bae6-8dbcd9716306	14	2026-03-28	3	2026	Casual work  5  days to clean house after deck	\N	\N	\N	\N	Hortencia sister	0	1750.0	0	\N	Saldo	12199.880000000005	{"Saldo": 12199.880000000005}	Money Box.xlsx	2026-04-22 14:24:56.656262+00	2026-04-22 14:24:56.656262+00
6cf25f37-b870-4d44-936d-97ce1634ed2c	petty_cash	924ab446-b357-4b2c-bae6-8dbcd9716306	15	2026-03-29	3	2026	Yussuf and Aisha	\N	\N	\N	\N	Diesel Cruiser	0	5000.0	0	\N	Saldo	7199.880000000005	{"Saldo": 7199.880000000005}	Money Box.xlsx	2026-04-22 14:24:56.656262+00	2026-04-22 14:24:56.656262+00
8eada187-154b-46cc-b1fa-6e1e2029e304	petty_cash	924ab446-b357-4b2c-bae6-8dbcd9716306	16	2026-03-30	3	2026	Transport Blocs and Cement plus concrete stone	\N	\N	\N	\N	Julio	0	5200.0	0	\N	Saldo	1999.8800000000047	{"Saldo": 1999.8800000000047}	Money Box.xlsx	2026-04-22 14:24:56.656262+00	2026-04-22 14:24:56.656262+00
e83117d7-c679-494d-b35e-0bba796e70cb	petty_cash	924ab446-b357-4b2c-bae6-8dbcd9716306	17	2026-03-31	3	2026	White sand	\N	\N	\N	\N	Julio	0	1700.0	0	\N	Saldo	299.88000000000466	{"Saldo": 299.88000000000466}	Money Box.xlsx	2026-04-22 14:24:56.656262+00	2026-04-22 14:24:56.656262+00
fcf99381-6523-41c8-be2b-107f986cd5e0	petty_cash	924ab446-b357-4b2c-bae6-8dbcd9716306	18	2026-03-31	3	2026	Radio and Vehicle license	\N	\N	\N	\N	Municipal	0	1250.0	0	\N	Saldo	-950.1199999999953	{"Saldo": -950.1199999999953}	Money Box.xlsx	2026-04-22 14:24:56.656262+00	2026-04-22 14:24:56.656262+00
a88b55b7-86a7-448b-8a06-7cc7a495ecfe	petty_cash	924ab446-b357-4b2c-bae6-8dbcd9716306	\N	\N	3	2026		\N	\N	\N	\N	\N	369585.48	370535.6	0	\N	Saldo	-950.1199999999953	{"Saldo": -950.1199999999953, "EB Fishing Charters": 162185.6}	Money Box.xlsx	2026-04-22 14:24:56.656262+00	2026-04-22 14:24:56.656262+00
91110759-cd61-479d-95cc-324f4c77dd54	petty_cash	b1e1cc24-4d42-4ebb-b678-a3a0176f1a74	1	2026-04-02	4	2026	Accommodation 4 days No Invoice	\N	\N	\N	Cash	Horse Safari	76800.0	0	0	\N	Saldo	75849.88	{"Saldo": 75849.88}	Money Box.xlsx	2026-04-22 14:24:56.686648+00	2026-04-22 14:24:56.686648+00
f49275ea-f4c4-4454-bea7-45542d9f249e	petty_cash	b1e1cc24-4d42-4ebb-b678-a3a0176f1a74	2	2026-04-02	4	2026	Commission 7%	\N	\N	\N	Cash	Andrisa	0	5376.000000000001	0	\N	Saldo	70473.88	{"Saldo": 70473.88, "Commission": 5376.000000000001, "EB Fishing Charters": 5376.000000000001}	Money Box.xlsx	2026-04-22 14:24:56.686648+00	2026-04-22 14:24:56.686648+00
e4388c7b-70b6-460d-87df-e7c4c6d31d74	petty_cash	b1e1cc24-4d42-4ebb-b678-a3a0176f1a74	3	2026-04-03	4	2026	Jaime, Meccia, Arlindo, Hortencia, Abdul	\N	\N	\N	Cash	Overtime Good Friday	0	2500.0	0	\N	Saldo	67973.88	{"Saldo": 67973.88, "Salaries": 2500.0, "EB Fishing Charters": 2500.0}	Money Box.xlsx	2026-04-22 14:24:56.686648+00	2026-04-22 14:24:56.686648+00
58cdcd72-f756-478b-8cf3-709f99277514	petty_cash	b1e1cc24-4d42-4ebb-b678-a3a0176f1a74	4	2026-04-04	4	2026	Load of rubish removed	\N	\N	\N	Mpesa	Geraldo	0	1500.0	0	\N	Saldo	66473.88	{"Saldo": 66473.88, "HOUSEKEEPING": 1500.0, "EB Fishing Charters": 1500.0}	Money Box.xlsx	2026-04-22 14:24:56.686648+00	2026-04-22 14:24:56.686648+00
8e3fd882-3b73-4ad3-a5d3-61e455edb923	petty_cash	b1e1cc24-4d42-4ebb-b678-a3a0176f1a74	5	2026-04-07	4	2026	Guests to Airport on Sunday	\N	\N	\N	Cash	Pedro	0	500.0	0	\N	Saldo	65973.88	{"Saldo": 65973.88, "Salaries": 500.0}	Money Box.xlsx	2026-04-22 14:24:56.686648+00	2026-04-22 14:24:56.686648+00
718531e1-c9af-4959-a4a7-aeb46ddc4485	petty_cash	b1e1cc24-4d42-4ebb-b678-a3a0176f1a74	6	2026-04-07	4	2026	3 days @ 350 Casa Vista	\N	\N	\N	Cash	Hortensia sister	0	1050.0	0	\N	Saldo	64923.880000000005	{"Saldo": 64923.880000000005, "Salaries": 1050.0}	Money Box.xlsx	2026-04-22 14:24:56.686648+00	2026-04-22 14:24:56.686648+00
98c70dd8-1157-4e40-bfd6-719bf8d97e56	petty_cash	b1e1cc24-4d42-4ebb-b678-a3a0176f1a74	7	2026-04-10	4	2026	One load Stone	\N	\N	\N	Mpesa	Aderito	0	3000.0	0	\N	Saldo	61923.880000000005	{"Saldo": 61923.880000000005, "Workers Kitchen": 3000.0}	Money Box.xlsx	2026-04-22 14:24:56.686648+00	2026-04-22 14:24:56.686648+00
ec0a1bb2-621c-4aab-a5cf-0eb1a4b1d98b	petty_cash	b1e1cc24-4d42-4ebb-b678-a3a0176f1a74	8	2026-04-13	4	2026	Building of Pilars at Casa Vista	\N	\N	\N	Cash	Felix	0	8000.0	0	\N	Saldo	53923.880000000005	{"Saldo": 53923.880000000005, "Workers Kitchen": 8000.0}	Money Box.xlsx	2026-04-22 14:24:56.686648+00	2026-04-22 14:24:56.686648+00
e80a4c9e-7fdc-4a3a-af68-6760d3f92245	petty_cash	b1e1cc24-4d42-4ebb-b678-a3a0176f1a74	12	2026-04-14	4	2026	Labour Workers Kitchen	\N	\N	\N	Emola	Bonze	0	500.0	0	\N	Saldo	49573.880000000005	{"Saldo": 49573.880000000005, "Workers Kitchen": 500.0}	Money Box.xlsx	2026-04-22 14:24:56.686648+00	2026-04-22 14:24:56.686648+00
4b431284-70d8-4888-9dc9-966ba7f5f4a2	petty_cash	b1e1cc24-4d42-4ebb-b678-a3a0176f1a74	13	2026-04-17	4	2026	Labour Workers Kitchen	\N	\N	\N	Emola	Bonze	0	2500.0	0	\N	Saldo	47073.880000000005	{"Saldo": 47073.880000000005, "Workers Kitchen": 2500.0}	Money Box.xlsx	2026-04-22 14:24:56.686648+00	2026-04-22 14:24:56.686648+00
da9d76e3-ee52-4c6d-aa6e-f6d3ac5cca13	petty_cash	b1e1cc24-4d42-4ebb-b678-a3a0176f1a74	9	2026-04-17	4	2026	One loads of white sand for workers kitchen	\N	\N	\N	Mpesa	Julio	0	1700.0	0	\N	Saldo	52223.880000000005	{"Saldo": 52223.880000000005, "Workers Kitchen": 1700.0}	Money Box.xlsx	2026-04-22 14:24:56.686648+00	2026-04-22 14:24:56.686648+00
1885dfb3-3d6d-4346-a616-ad8fa664342c	petty_cash	b1e1cc24-4d42-4ebb-b678-a3a0176f1a74	10	2026-04-20	4	2026	1 Day Casa Vista	\N	\N	\N	Mpesa	Audencia	0	500.0	0	\N	Saldo	51723.880000000005	{"Saldo": 51723.880000000005, "Salaries": 500.0}	Money Box.xlsx	2026-04-22 14:24:56.686648+00	2026-04-22 14:24:56.686648+00
fad69bf6-db6d-4831-b81b-207380a2b8c5	petty_cash	b1e1cc24-4d42-4ebb-b678-a3a0176f1a74	11	2026-04-21	4	2026	3 Bags Cement road shop	\N	\N	\N	Cash	Road shop	0	1650.0	0	\N	Saldo	50073.880000000005	{"Saldo": 50073.880000000005, "Workers Kitchen": 1650.0}	Money Box.xlsx	2026-04-22 14:24:56.686648+00	2026-04-22 14:24:56.686648+00
4c0e02c3-8459-4342-aa0a-7e7e93e48a20	petty_cash	b1e1cc24-4d42-4ebb-b678-a3a0176f1a74	\N	\N	4	2026		\N	\N	\N	\N	\N	75849.88	28776.0	0	\N	Saldo	47073.880000000005	{"Saldo": 47073.880000000005, "Salaries": 4550.0, "Commission": 5376.000000000001, "HOUSEKEEPING": 1500.0, "Workers Kitchen": 17350.0, "EB Fishing Charters": 9376.0}	Money Box.xlsx	2026-04-22 14:24:56.686648+00	2026-04-22 14:24:56.686648+00
ab802e64-a34f-47ae-a745-183aa4d76dbd	emola	388a9c8a-30e4-49b2-b91a-b1813b61e0f5	\N	2025-09-04	9	2026	Paulo Transport	\N	\N	871010806	\N	\N	0	0	0	17320.0	Transport	5000.0	{"Transport": 5000.0}	Emola.xlsx	2026-04-22 14:24:56.716838+00	2026-04-22 14:24:56.716838+00
57e3e6da-7be2-4efc-a15f-367e4dd29739	emola	388a9c8a-30e4-49b2-b91a-b1813b61e0f5	\N	2025-09-06	9	2026	Paulo Transport	\N	\N	\N	\N	\N	0	0	0	15820.0	Transport	1500.0	{"Transport": 1500.0}	Emola.xlsx	2026-04-22 14:24:56.716838+00	2026-04-22 14:24:56.716838+00
b2fa55c4-ffc4-4381-85fe-8440d3acc894	emola	388a9c8a-30e4-49b2-b91a-b1813b61e0f5	\N	2025-09-17	9	2026	Recharge	\N	\N	\N	\N	\N	0	0	0	15620.0	\N	0	{}	Emola.xlsx	2026-04-22 14:24:56.716838+00	2026-04-22 14:24:56.716838+00
de0f878d-0237-4c8a-b576-f624551eaf34	emola	388a9c8a-30e4-49b2-b91a-b1813b61e0f5	\N	2025-09-19	9	2026	Hamilton Massuaganhe Plumber	\N	\N	865897307	\N	\N	0	0	0	6620.0	Plumber	9000.0	{"Plumber": 9000.0}	Emola.xlsx	2026-04-22 14:24:56.716838+00	2026-04-22 14:24:56.716838+00
40bb1ac0-e0d5-4865-9b77-a03c12166f78	emola	388a9c8a-30e4-49b2-b91a-b1813b61e0f5	\N	2025-10-10	10	2026	Received Lee-Ann Ebony	\N	\N	\N	\N	\N	100000.0	0	0	106620.0	\N	0	{}	Emola.xlsx	2026-04-22 14:24:56.716838+00	2026-04-22 14:24:56.716838+00
e81fa966-c0b4-42b3-bf9c-0a165e028539	emola	388a9c8a-30e4-49b2-b91a-b1813b61e0f5	\N	2025-10-10	10	2026	87 078 2288. Casimiro Beira Chris	\N	\N	870782288	\N	\N	0	0	0	104420.0	\N	0	{}	Emola.xlsx	2026-04-22 14:24:56.716838+00	2026-04-22 14:24:56.716838+00
1501fe13-5a89-4044-8b7b-b0dade0f1fd5	emola	388a9c8a-30e4-49b2-b91a-b1813b61e0f5	\N	2025-10-15	10	2026	Solar Sept Ebony	\N	\N	870360233	\N	\N	0	0	0	94420.0	\N	0	{}	Emola.xlsx	2026-04-22 14:24:56.716838+00	2026-04-22 14:24:56.716838+00
81bbd819-17f7-4194-bb2c-8a6a7a4797a3	emola	388a9c8a-30e4-49b2-b91a-b1813b61e0f5	\N	2025-10-16	10	2026	Agostinho Garden	\N	\N	865066648	\N	\N	0	0	0	94120.0	\N	0	{}	Emola.xlsx	2026-04-22 14:24:56.716838+00	2026-04-22 14:24:56.716838+00
0b792313-accb-4016-9bf8-7dce1c6aba3a	emola	388a9c8a-30e4-49b2-b91a-b1813b61e0f5	\N	2025-10-26	10	2026	Received Bernard	\N	\N	\N	\N	\N	10295.0	0	0	104415.0	\N	0	{}	Emola.xlsx	2026-04-22 14:24:56.716838+00	2026-04-22 14:24:56.716838+00
c6a20dae-b44d-48db-85ab-fea759d6ac67	emola	388a9c8a-30e4-49b2-b91a-b1813b61e0f5	\N	2025-10-31	10	2026	Jaime Transport	\N	\N	878711441	\N	\N	0	0	0	104215.0	\N	0	{}	Emola.xlsx	2026-04-22 14:24:56.716838+00	2026-04-22 14:24:56.716838+00
7683ac52-b523-4841-8b6a-2701e23f04bc	emola	388a9c8a-30e4-49b2-b91a-b1813b61e0f5	\N	2025-11-02	11	2026	Nelson Skipper Alex	\N	\N	874755153	\N	\N	0	0	0	89215.0	\N	0	{}	Emola.xlsx	2026-04-22 14:24:56.716838+00	2026-04-22 14:24:56.716838+00
93af6707-e812-4d91-b04c-d06df7b84c51	emola	388a9c8a-30e4-49b2-b91a-b1813b61e0f5	\N	2025-11-02	11	2026	Anselmo Bernard registration	\N	\N	870463435	\N	\N	0	0	0	79215.0	Anselmo	10000.0	{"Anselmo": 10000.0}	Emola.xlsx	2026-04-22 14:24:56.716838+00	2026-04-22 14:24:56.716838+00
f93d58b7-bc3c-44a5-801e-a367fd9b908e	emola	388a9c8a-30e4-49b2-b91a-b1813b61e0f5	\N	2025-11-10	11	2026	Anselmo Cruiser road certificate	\N	\N	870463435	\N	\N	0	0	0	76215.0	Anselmo	3000.0	{"Anselmo": 3000.0}	Emola.xlsx	2026-04-22 14:24:56.716838+00	2026-04-22 14:24:56.716838+00
144b89bc-0377-43c8-a322-520684b92e11	emola	388a9c8a-30e4-49b2-b91a-b1813b61e0f5	\N	2025-11-10	11	2026	Abilio Painter	\N	\N	877330599	\N	\N	0	0	0	73215.0	Painter	3000.0	{"Painter": 3000.0}	Emola.xlsx	2026-04-22 14:24:56.716838+00	2026-04-22 14:24:56.716838+00
b604635c-73e0-4b94-932a-a86db1797e4e	emola	388a9c8a-30e4-49b2-b91a-b1813b61e0f5	\N	2025-11-10	11	2026	Euzebio (Hamilton)	\N	\N	865897307	\N	\N	0	0	0	63215.0	Plumber	10000.0	{"Plumber": 10000.0}	Emola.xlsx	2026-04-22 14:24:56.716838+00	2026-04-22 14:24:56.716838+00
11008963-0988-4d74-8171-57a2512adfff	emola	388a9c8a-30e4-49b2-b91a-b1813b61e0f5	\N	2025-11-11	11	2026	Anselmo work contract	\N	\N	870463435	\N	\N	0	0	0	49215.0	Anselmo	14000.0	{"Anselmo": 14000.0}	Emola.xlsx	2026-04-22 14:24:56.716838+00	2026-04-22 14:24:56.716838+00
065b04ed-6531-4d78-bfa3-8233a90c43bd	emola	388a9c8a-30e4-49b2-b91a-b1813b61e0f5	\N	2025-11-11	11	2026	Abilio Painter	\N	\N	877330599	\N	\N	0	0	0	46215.0	Painter	3000.0	{"Painter": 3000.0}	Emola.xlsx	2026-04-22 14:24:56.716838+00	2026-04-22 14:24:56.716838+00
6adc7bc4-6941-443b-9bb2-93ca67afee3e	emola	388a9c8a-30e4-49b2-b91a-b1813b61e0f5	\N	2025-11-12	11	2026	Chris wood Ebony 12000 self 3000	\N	\N	870360233	\N	\N	0	0	0	31215.0	Ebony	12000.0	{"Self": 3000.0, "Ebony": 12000.0}	Emola.xlsx	2026-04-22 14:24:56.716838+00	2026-04-22 14:24:56.716838+00
0b5859d2-a1c7-4c11-8ff0-56abed86c77a	emola	388a9c8a-30e4-49b2-b91a-b1813b61e0f5	\N	2025-11-13	11	2026	Euzebio (Hamilton)	\N	\N	865897307	\N	\N	0	0	0	25215.0	Plumber	6000.0	{"Plumber": 6000.0}	Emola.xlsx	2026-04-22 14:24:56.716838+00	2026-04-22 14:24:56.716838+00
4a3d87da-e329-45ad-b45c-ac28bb58b687	emola	388a9c8a-30e4-49b2-b91a-b1813b61e0f5	\N	2025-11-19	11	2026	Received Alex TACKEL ROOM	\N	\N	\N	\N	\N	43350.0	0	0	68565.0	\N	0	{}	Emola.xlsx	2026-04-22 14:24:56.716838+00	2026-04-22 14:24:56.716838+00
fd78f924-dd1f-44c3-93c5-9f81d5158bd1	emola	388a9c8a-30e4-49b2-b91a-b1813b61e0f5	\N	2025-11-23	11	2026	Bebe Alex door and frame market	\N	\N	877999071	\N	\N	0	0	0	58565.0	\N	0	{}	Emola.xlsx	2026-04-22 14:24:56.716838+00	2026-04-22 14:24:56.716838+00
6d47d027-c15a-4c01-a843-15de11bef656	emola	388a9c8a-30e4-49b2-b91a-b1813b61e0f5	\N	2025-11-26	11	2026	Bebe Food for Builders	\N	\N	877999071	\N	\N	0	0	0	55565.0	\N	0	{}	Emola.xlsx	2026-04-22 14:24:56.716838+00	2026-04-22 14:24:56.716838+00
5a016e78-857a-49d3-bc4d-0ed2908dcccf	emola	388a9c8a-30e4-49b2-b91a-b1813b61e0f5	\N	2025-11-27	11	2026	Jose Building plans	\N	\N	874710102	\N	\N	0	0	0	47565.0	Building	8000.0	{"Building": 8000.0}	Emola.xlsx	2026-04-22 14:24:56.716838+00	2026-04-22 14:24:56.716838+00
5d272349-6db2-41a5-a41a-10b5ee507ef9	emola	388a9c8a-30e4-49b2-b91a-b1813b61e0f5	\N	2025-11-29	11	2026	Anselmo Bernard registration	\N	\N	870463435	\N	\N	0	0	0	31565.0	\N	0	{}	Emola.xlsx	2026-04-22 14:24:56.716838+00	2026-04-22 14:24:56.716838+00
6cfab096-58cf-49fe-8484-25879ed3eeb4	emola	388a9c8a-30e4-49b2-b91a-b1813b61e0f5	\N	2025-11-28	11	2026	Electricient Amblution Cristiano Kuda	\N	\N	876115287	\N	\N	0	0	0	26565.0	Building	5000.0	{"Building": 5000.0}	Emola.xlsx	2026-04-22 14:24:56.716838+00	2026-04-22 14:24:56.716838+00
2c048f56-016f-407f-aef6-37142d465cc6	emola	388a9c8a-30e4-49b2-b91a-b1813b61e0f5	\N	2025-12-09	12	2026	Amina Malate Prawns	\N	\N	877699340	\N	\N	0	0	0	24815.0	\N	0	{}	Emola.xlsx	2026-04-22 14:24:56.716838+00	2026-04-22 14:24:56.716838+00
f8f35814-5704-4c9d-a4f4-175597bc9155	emola	388a9c8a-30e4-49b2-b91a-b1813b61e0f5	\N	2025-12-09	12	2026	Abilio Painter	\N	\N	877330599	\N	\N	0	0	0	19315.0	\N	0	{}	Emola.xlsx	2026-04-22 14:24:56.716838+00	2026-04-22 14:24:56.716838+00
75dd1665-3b41-42de-a9e8-97f89f57d810	emola	388a9c8a-30e4-49b2-b91a-b1813b61e0f5	\N	2025-12-16	12	2026	Richard weld  RSD an CTC	\N	\N	860220999	\N	\N	0	0	0	17565.0	\N	0	{}	Emola.xlsx	2026-04-22 14:24:56.716838+00	2026-04-22 14:24:56.716838+00
978bf5db-a69e-407c-9437-8117e728c0c1	emola	388a9c8a-30e4-49b2-b91a-b1813b61e0f5	\N	2025-09-01	9	2026	Ablution Block	Landco	Bones	\N	\N	\N	8000.0	0	0	11320.0	\N	0	{}	Emola.xlsx	2026-04-22 14:24:56.716838+00	2026-04-23 12:29:03.386308+00
4a479ae1-6dfa-4a1b-928e-cb7350a5a591	emola	388a9c8a-30e4-49b2-b91a-b1813b61e0f5	\N	2025-12-18	12	2026	Kuda electricien	\N	\N	876115287	\N	\N	0	0	0	13065.0	\N	0	{}	Emola.xlsx	2026-04-22 14:24:56.716838+00	2026-04-22 14:24:56.716838+00
942ad497-fbea-400a-bdc5-8f1270fc7c1d	emola	388a9c8a-30e4-49b2-b91a-b1813b61e0f5	\N	2025-12-23	12	2026	Bebe food workers	\N	\N	877999071	\N	\N	0	0	0	2065.0	\N	0	{}	Emola.xlsx	2026-04-22 14:24:56.716838+00	2026-04-22 14:24:56.716838+00
330e77d1-6d40-4dbe-bd6c-1e18dcc73041	emola	388a9c8a-30e4-49b2-b91a-b1813b61e0f5	\N	2025-12-26	12	2026	Landco Fatima	\N	\N	\N	\N	\N	20000.0	0	0	22065.0	\N	0	{}	Emola.xlsx	2026-04-22 14:24:56.716838+00	2026-04-22 14:24:56.716838+00
f9e96b28-8feb-434f-a0c8-ee67fd64455a	emola	388a9c8a-30e4-49b2-b91a-b1813b61e0f5	\N	2025-12-26	12	2026	Lee-Ann Bernard 19500, Alex 23400, CTC 7100	\N	\N	\N	\N	\N	50000.0	0	0	72065.0	\N	0	{}	Emola.xlsx	2026-04-22 14:24:56.716838+00	2026-04-22 14:24:56.716838+00
85744fc5-946e-4a0c-b14c-13d895201ab0	emola	388a9c8a-30e4-49b2-b91a-b1813b61e0f5	\N	2025-12-26	12	2026	Lee-Ann  CTC	\N	\N	\N	\N	\N	20460.0	0	0	92525.0	\N	0	{}	Emola.xlsx	2026-04-22 14:24:56.716838+00	2026-04-22 14:24:56.716838+00
a057808a-0506-445a-b339-059076d1579b	emola	388a9c8a-30e4-49b2-b91a-b1813b61e0f5	\N	2025-12-28	12	2026	Chris Airtime	\N	\N	870630223	\N	\N	0	0	0	91825.0	\N	0	{}	Emola.xlsx	2026-04-22 14:24:56.716838+00	2026-04-22 14:24:56.716838+00
ed531d0f-5792-4bdc-93ec-896e2a2d628b	emola	388a9c8a-30e4-49b2-b91a-b1813b61e0f5	\N	2025-12-31	12	2026	Jose Municipal Plans	\N	\N	874710102	\N	\N	0	0	0	89825.0	\N	0	{}	Emola.xlsx	2026-04-22 14:24:56.716838+00	2026-04-22 14:24:56.716838+00
6428fc60-3ca2-4ec4-bcaf-0d32d45ea92d	emola	388a9c8a-30e4-49b2-b91a-b1813b61e0f5	\N	2026-01-05	1	2026	Narciso Zaqeu steel transport Alex	\N	\N	879217082	\N	\N	0	0	0	88825.0	\N	0	{}	Emola.xlsx	2026-04-22 14:24:56.716838+00	2026-04-22 14:24:56.716838+00
48e79767-6f11-4f35-b4ec-5d1d399a6bdf	emola	388a9c8a-30e4-49b2-b91a-b1813b61e0f5	\N	2026-01-06	1	2026	Portador Documents Maputo Amade	\N	\N	861208120	\N	\N	0	0	0	88175.0	\N	0	{}	Emola.xlsx	2026-04-22 14:24:56.716838+00	2026-04-22 14:24:56.716838+00
4db08753-3e38-49e1-bb53-efa6151861df	emola	388a9c8a-30e4-49b2-b91a-b1813b61e0f5	\N	2026-01-08	1	2026	Luis Jordan Singo Ebony rubish	\N	\N	877330599	\N	\N	0	0	0	86675.0	\N	0	{}	Emola.xlsx	2026-04-22 14:24:56.716838+00	2026-04-22 14:24:56.716838+00
9a6f6ee2-a2cb-4f43-b831-222a9a34c720	emola	388a9c8a-30e4-49b2-b91a-b1813b61e0f5	\N	2026-01-08	1	2026	Abilio Painter Alex room	\N	\N	\N	\N	\N	0	0	0	81175.0	\N	0	{}	Emola.xlsx	2026-04-22 14:24:56.716838+00	2026-04-22 14:24:56.716838+00
dffdfbba-958b-4049-bf81-3e463340b90a	emola	388a9c8a-30e4-49b2-b91a-b1813b61e0f5	\N	2026-01-14	1	2026	Received from Alex for Parks	\N	\N	\N	\N	\N	5000.0	0	0	86175.0	\N	0	{}	Emola.xlsx	2026-04-22 14:24:56.716838+00	2026-04-22 14:24:56.716838+00
705b3051-f295-48d8-bd16-0d5c0039fd89	emola	388a9c8a-30e4-49b2-b91a-b1813b61e0f5	\N	2026-01-15	1	2026	GB welder windows and door burglar bar Alex	\N	\N	\N	\N	\N	0	0	0	81675.0	\N	0	{}	Emola.xlsx	2026-04-22 14:24:56.716838+00	2026-04-22 14:24:56.716838+00
6c191c70-443d-492e-bb3d-762054e5a23e	emola	388a9c8a-30e4-49b2-b91a-b1813b61e0f5	\N	2026-01-15	1	2026	Aminosse skipper Robin	\N	\N	866429715	\N	\N	0	0	0	79675.0	\N	0	{}	Emola.xlsx	2026-04-22 14:24:56.716838+00	2026-04-22 14:24:56.716838+00
f9e79021-d903-4443-b6ad-e07d70a31ba4	emola	388a9c8a-30e4-49b2-b91a-b1813b61e0f5	\N	2026-01-16	1	2026	Hortencia Loan 6000 for Cell repay cash 2000 a month	\N	\N	879738133	\N	\N	0	0	0	73675.0	\N	0	{}	Emola.xlsx	2026-04-22 14:24:56.716838+00	2026-04-22 14:24:56.716838+00
a777d3e3-d727-4e19-aabc-03dac98789ef	emola	388a9c8a-30e4-49b2-b91a-b1813b61e0f5	\N	2026-01-16	1	2026	Pedro work on boat for Warren Cohen 2 days	\N	\N	862265991	\N	\N	0	0	0	73175.0	\N	0	{}	Emola.xlsx	2026-04-22 14:24:56.716838+00	2026-04-22 14:24:56.716838+00
28d60163-c840-4062-9938-c8b3913cc9fb	emola	388a9c8a-30e4-49b2-b91a-b1813b61e0f5	\N	2026-01-16	1	2026	Bebe shortfall on Ronny money from Warren	\N	\N	877999071	\N	\N	0	0	0	70955.0	\N	0	{}	Emola.xlsx	2026-04-22 14:24:56.716838+00	2026-04-22 14:24:56.716838+00
7812795a-6fb3-4b64-baf7-ee6611777511	emola	388a9c8a-30e4-49b2-b91a-b1813b61e0f5	\N	2026-01-17	1	2026	Repair washing machine Santos	\N	\N	877497138	\N	\N	0	0	0	63955.0	\N	0	{}	Emola.xlsx	2026-04-22 14:24:56.716838+00	2026-04-22 14:24:56.716838+00
9e45775e-f226-4d15-909a-877f7f9619ec	emola	388a9c8a-30e4-49b2-b91a-b1813b61e0f5	\N	2026-01-22	1	2026	Ercelina santos chongo Adelino cashews	\N	\N	878686276	\N	\N	0	0	0	62455.0	\N	0	{}	Emola.xlsx	2026-04-22 14:24:56.716838+00	2026-04-22 14:24:56.716838+00
13e46ed5-8fd2-4c28-a8bd-f44e44b06cd4	emola	388a9c8a-30e4-49b2-b91a-b1813b61e0f5	\N	2026-01-30	1	2026	Raymoundo accommodation welder	\N	\N	864638638	\N	\N	0	0	0	53455.0	\N	0	{}	Emola.xlsx	2026-04-22 14:24:56.716838+00	2026-04-22 14:24:56.716838+00
6511a71b-38c6-4882-b118-6824c1aacaa1	emola	388a9c8a-30e4-49b2-b91a-b1813b61e0f5	\N	2026-02-09	2	2026	Adelino Emprestimo to Marcelino account	\N	\N	871889040	\N	\N	0	0	0	51455.0	\N	0	{}	Emola.xlsx	2026-04-22 14:24:56.716838+00	2026-04-22 14:24:56.716838+00
578323a1-e70d-4f61-8904-446b088478b9	emola	388a9c8a-30e4-49b2-b91a-b1813b61e0f5	\N	2026-02-13	2	2026	Alfredo Immigration	\N	\N	877145045	\N	\N	0	0	0	51355.0	\N	0	{}	Emola.xlsx	2026-04-22 14:24:56.716838+00	2026-04-22 14:24:56.716838+00
49cab7fa-d9c0-4118-a43c-53d1397f904c	emola	388a9c8a-30e4-49b2-b91a-b1813b61e0f5	\N	2026-02-17	2	2026	Alex for Budgie Food Budgie paid in SA	\N	\N	\N	\N	\N	0	0	0	46355.0	\N	0	{}	Emola.xlsx	2026-04-22 14:24:56.716838+00	2026-04-22 14:24:56.716838+00
5ab5a51e-55a9-4e44-b1c4-ddea18e31d25	emola	388a9c8a-30e4-49b2-b91a-b1813b61e0f5	\N	2026-02-24	2	2026	Ana Immigration	\N	\N	873881016	\N	\N	0	0	0	16355.0	\N	0	{}	Emola.xlsx	2026-04-22 14:24:56.716838+00	2026-04-22 14:24:56.716838+00
db4dbd85-0546-45e6-b56f-1bd5c3403b3e	emola	388a9c8a-30e4-49b2-b91a-b1813b61e0f5	\N	2026-03-04	3	2026	Alfredo Macaucau Immigration	\N	\N	877145045	\N	\N	0	0	0	13855.0	\N	0	{}	Emola.xlsx	2026-04-22 14:24:56.716838+00	2026-04-22 14:24:56.716838+00
334be54e-e738-461e-bea5-ca19cf92491b	emola	388a9c8a-30e4-49b2-b91a-b1813b61e0f5	\N	2026-03-16	3	2026	Agnaldo Casa Caju Internet cable Alex	\N	\N	861750394	\N	\N	0	0	0	8855.0	\N	0	{}	Emola.xlsx	2026-04-22 14:24:56.716838+00	2026-04-22 14:24:56.716838+00
5d9d5bd7-9c18-44db-bc64-27ce78cb1eb1	emola	388a9c8a-30e4-49b2-b91a-b1813b61e0f5	\N	2026-03-23	3	2026	Pedro Stepping stones and plants Landco	\N	\N	873078848	\N	\N	0	0	0	7055.0	\N	0	{}	Emola.xlsx	2026-04-22 14:24:56.716838+00	2026-04-22 14:24:56.716838+00
e483e446-1329-4208-8781-a5fdc9ed431e	emola	388a9c8a-30e4-49b2-b91a-b1813b61e0f5	\N	2026-04-08	4	2026	Portador Documents Maputo Amade	\N	\N	860128118	\N	\N	0	0	0	7405.0	\N	0	{}	Emola.xlsx	2026-04-22 14:24:56.716838+00	2026-04-22 14:24:56.716838+00
8f891b9c-632b-4382-b72f-a3f348c805cd	emola	388a9c8a-30e4-49b2-b91a-b1813b61e0f5	\N	2026-04-14	4	2026	Rita Mahilene Bonze advance	\N	\N	860059383	\N	\N	0	0	0	6905.0	\N	0	{}	Emola.xlsx	2026-04-22 14:24:56.716838+00	2026-04-22 14:24:56.716838+00
b390acbb-b08f-444a-8b37-c1efe8ce2908	emola	388a9c8a-30e4-49b2-b91a-b1813b61e0f5	\N	2026-04-17	4	2026	Rita Mahilene Bonze advance	\N	\N	860059383	\N	\N	0	0	0	4405.0	\N	0	{}	Emola.xlsx	2026-04-22 14:24:56.716838+00	2026-04-22 14:24:56.716838+00
09337741-d0d5-42e0-96e3-9cb6b016caaf	mpesa	b820cbed-2378-4b87-a711-dd4615c774c8	\N	2026-01-04	1	2026	Macarata overtime Marbar 2 days	\N	\N	848412766	\N	\N	0	1000.0	0	21777.570000000007	Marbar	1000.0	{"Marbar": 1000.0}	Mpesa.xlsx	2026-04-22 14:24:56.754661+00	2026-04-22 14:24:56.754661+00
18627842-b841-4636-a615-b6556977eeed	mpesa	b820cbed-2378-4b87-a711-dd4615c774c8	\N	2026-01-05	1	2026	Pedro tip Fanie	\N	\N	842349360	\N	\N	0	1500.0	0	20277.570000000007	\N	0	{}	Mpesa.xlsx	2026-04-22 14:24:56.754661+00	2026-04-22 14:24:56.754661+00
da242a29-5556-4803-8821-d916e24c5a7d	mpesa	b820cbed-2378-4b87-a711-dd4615c774c8	\N	2026-01-06	1	2026	Asif for Euzebio	\N	\N	\N	\N	\N	3000.0	0	0	23277.570000000007	\N	0	{}	Mpesa.xlsx	2026-04-22 14:24:56.754661+00	2026-04-22 14:24:56.754661+00
88715483-e1c2-45f5-9099-81c6c8c085c8	mpesa	b820cbed-2378-4b87-a711-dd4615c774c8	\N	2026-01-06	1	2026	Matias Landco Guarde CLAIM IN DEC	\N	\N	847309643	\N	\N	0	4000.0	0	19277.570000000007	\N	0	{}	Mpesa.xlsx	2026-04-22 14:24:56.754661+00	2026-04-22 14:24:56.754661+00
54a68953-1c07-4625-8635-30d4392deabe	mpesa	b820cbed-2378-4b87-a711-dd4615c774c8	\N	2026-01-06	1	2026	Archipelogo	\N	\N	\N	\N	\N	3200.0	0	0	22477.570000000007	\N	0	{}	Mpesa.xlsx	2026-04-22 14:24:56.754661+00	2026-04-22 14:24:56.754661+00
6a0638c7-aa8c-4cfb-a37b-4234083c53ed	mpesa	b820cbed-2378-4b87-a711-dd4615c774c8	\N	2026-01-06	1	2026	JB	\N	\N	\N	\N	\N	1000.0	0	0	23477.570000000007	\N	0	{}	Mpesa.xlsx	2026-04-22 14:24:56.754661+00	2026-04-22 14:24:56.754661+00
2aef630f-7b0c-4c06-bcde-404122db23b9	mpesa	b820cbed-2378-4b87-a711-dd4615c774c8	\N	2026-01-06	1	2026	Mandy Euzebio hospital refund from others	\N	\N	\N	\N	\N	0	10200.0	0	13277.570000000007	\N	0	{}	Mpesa.xlsx	2026-04-22 14:24:56.754661+00	2026-04-22 14:24:56.754661+00
073eb49a-bd8e-47c5-9a6d-f3079faf56a1	mpesa	b820cbed-2378-4b87-a711-dd4615c774c8	\N	2026-01-07	1	2026	Macarata Agostinho child funeral	\N	\N	848412766	\N	\N	0	2000.0	0	11277.570000000007	\N	0	{}	Mpesa.xlsx	2026-04-22 14:24:56.754661+00	2026-04-22 14:24:56.754661+00
8b7dee5a-cc4c-4bee-8844-bab1823c1117	mpesa	b820cbed-2378-4b87-a711-dd4615c774c8	\N	2026-01-12	1	2026	Matias Landco Guarde	\N	\N	847309643	\N	\N	0	7000.0	0	4277.570000000007	\N	0	{}	Mpesa.xlsx	2026-04-22 14:24:56.754661+00	2026-04-22 14:24:56.754661+00
fe9833f4-601f-4886-84bf-224ca3d0b2c5	mpesa	b820cbed-2378-4b87-a711-dd4615c774c8	\N	2026-01-12	1	2026	Macarata overtime Marbar 2 days 10+11JAN AGOSTINHO	\N	\N	848412766	\N	\N	0	1000.0	0	3277.570000000007	\N	0	{}	Mpesa.xlsx	2026-04-22 14:24:56.754661+00	2026-04-22 14:24:56.754661+00
d7f3548f-23b6-4bf7-b4e3-bd1183903339	mpesa	b820cbed-2378-4b87-a711-dd4615c774c8	\N	2026-01-12	1	2026	Alex Parks board	\N	\N	\N	\N	\N	17300.0	0	0	20577.570000000007	\N	0	{}	Mpesa.xlsx	2026-04-22 14:24:56.754661+00	2026-04-22 14:24:56.754661+00
d0206375-875a-4222-b3f2-c2a177c6e7a4	mpesa	b820cbed-2378-4b87-a711-dd4615c774c8	\N	2026-01-12	1	2026	Alex  Starlink	\N	\N	\N	\N	\N	0	3000.0	0	17577.570000000007	\N	0	{}	Mpesa.xlsx	2026-04-22 14:24:56.754661+00	2026-04-22 14:24:56.754661+00
371c6f80-fbec-44a6-a275-98c889cbf6bc	mpesa	b820cbed-2378-4b87-a711-dd4615c774c8	\N	2026-01-13	1	2026	Geraldo Ebony Rubish removal	\N	\N	842614232	\N	\N	0	1000.0	0	16577.570000000007	\N	0	{}	Mpesa.xlsx	2026-04-22 14:24:56.754661+00	2026-04-22 14:24:56.754661+00
c4452ebb-2364-40a1-8281-d45c6e2c997a	mpesa	b820cbed-2378-4b87-a711-dd4615c774c8	\N	2026-01-15	1	2026	Airtime Ursula	\N	\N	856549065	\N	\N	0	200.0	0	16377.570000000007	\N	0	{}	Mpesa.xlsx	2026-04-22 14:24:56.754661+00	2026-04-22 14:24:56.754661+00
02c7149e-824a-42f1-ac14-ad92818bab01	mpesa	b820cbed-2378-4b87-a711-dd4615c774c8	\N	2026-01-15	1	2026	Emilio	\N	\N	848756564	\N	\N	0	2000.0	0	14377.570000000007	\N	0	{}	Mpesa.xlsx	2026-04-22 14:24:56.754661+00	2026-04-22 14:24:56.754661+00
05d970f1-b6a2-486a-a010-0beffa1e0946	mpesa	b820cbed-2378-4b87-a711-dd4615c774c8	\N	2026-01-16	1	2026	Adelino Loan	\N	\N	844970141	\N	\N	0	1500.0	0	12877.570000000007	\N	0	{}	Mpesa.xlsx	2026-04-22 14:24:56.754661+00	2026-04-22 14:24:56.754661+00
06a4bc61-ff49-416f-9b0d-e30440af2e69	mpesa	b820cbed-2378-4b87-a711-dd4615c774c8	\N	2026-01-17	1	2026	Florda overtime December	\N	\N	845754632	\N	\N	0	2000.0	0	10877.570000000007	\N	0	{}	Mpesa.xlsx	2026-04-22 14:24:56.754661+00	2026-04-22 14:24:56.754661+00
39ce1e31-b6fe-4fa6-9f05-516ac3bdd51c	mpesa	b820cbed-2378-4b87-a711-dd4615c774c8	\N	2026-01-17	1	2026	Elton Carpenter Advance	\N	\N	846482824	\N	\N	0	1000.0	0	9877.570000000007	\N	0	{}	Mpesa.xlsx	2026-04-22 14:24:56.754661+00	2026-04-22 14:24:56.754661+00
e7a085b0-ef21-4029-87ef-878fd9375266	mpesa	b820cbed-2378-4b87-a711-dd4615c774c8	\N	2026-01-19	1	2026	Adelino Advance	\N	\N	844970141	\N	\N	0	8000.0	0	1877.570000000007	\N	0	{}	Mpesa.xlsx	2026-04-22 14:24:56.754661+00	2026-04-22 14:24:56.754661+00
e66ae560-51ea-4b16-a3c8-79fadab81bb5	mpesa	b820cbed-2378-4b87-a711-dd4615c774c8	\N	2026-01-21	1	2026	Bundels Andrisa	\N	\N	847250140	\N	\N	0	1000.0	0	877.570000000007	\N	0	{}	Mpesa.xlsx	2026-04-22 14:24:56.754661+00	2026-04-22 14:24:56.754661+00
bc1c8837-cd72-4429-8598-a437ec162192	mpesa	b820cbed-2378-4b87-a711-dd4615c774c8	\N	2026-01-22	1	2026	Claudio Data for Jan	\N	\N	842718852	\N	\N	0	200.0	0	677.570000000007	\N	0	{}	Mpesa.xlsx	2026-04-22 14:24:56.754661+00	2026-04-22 14:24:56.754661+00
3cf6dbdb-42d3-4575-88e0-92901126111e	mpesa	b820cbed-2378-4b87-a711-dd4615c774c8	\N	2026-01-22	1	2026	Received Claidio for data	\N	\N	\N	\N	\N	2402.0	0	0	3079.570000000007	Claudio	-2402.0	{"Claudio": -2402.0}	Mpesa.xlsx	2026-04-22 14:24:56.754661+00	2026-04-22 14:24:56.754661+00
837442c2-cadf-4213-932b-c429d398b774	mpesa	b820cbed-2378-4b87-a711-dd4615c774c8	\N	2026-01-24	1	2026	Geraldo Ebony Rubish removal 2 loads	\N	\N	842614232	\N	\N	0	2000.0	0	1079.570000000007	\N	0	{}	Mpesa.xlsx	2026-04-22 14:24:56.754661+00	2026-04-22 14:24:56.754661+00
8e80f9ee-3081-4504-896f-32781f3110b6	mpesa	b820cbed-2378-4b87-a711-dd4615c774c8	\N	2026-01-27	1	2026	Received Lee-Ann	\N	\N	\N	\N	\N	12000.0	0	0	13079.570000000007	\N	0	{}	Mpesa.xlsx	2026-04-22 14:24:56.754661+00	2026-04-22 14:24:56.754661+00
79a3518a-8341-472d-90b0-059347e35d4d	mpesa	b820cbed-2378-4b87-a711-dd4615c774c8	\N	2026-01-30	1	2026	Oscar Mangalisse	\N	\N	\N	\N	\N	0	8160.0	0	4919.570000000007	\N	0	{}	Mpesa.xlsx	2026-04-22 14:24:56.754661+00	2026-04-22 14:24:56.754661+00
45eeb061-6726-423d-91e4-0c75b5bc9e7e	mpesa	b820cbed-2378-4b87-a711-dd4615c774c8	\N	2026-01-30	1	2026	Marcelino Mangalisse	\N	\N	\N	\N	\N	0	1360.0	0	3459.570000000007	\N	0	{}	Mpesa.xlsx	2026-04-22 14:24:56.754661+00	2026-04-22 14:24:56.754661+00
eca8ddaa-a807-4e75-b157-bc65eb08417b	mpesa	b820cbed-2378-4b87-a711-dd4615c774c8	\N	\N	1	2026	Airtime Andrisa	\N	\N	\N	\N	\N	0	100.0	0	4819.570000000007	\N	0	{}	Mpesa.xlsx	2026-04-22 14:24:56.754661+00	2026-04-22 14:24:56.754661+00
87279378-84c6-4ad5-b44e-6c28f2ca574d	mpesa	b820cbed-2378-4b87-a711-dd4615c774c8	\N	2026-02-06	2	2026	Abdul Loan CTC	\N	\N	842230835	\N	\N	0	3000.0	0	459.570000000007	\N	0	{}	Mpesa.xlsx	2026-04-22 14:24:56.754661+00	2026-04-22 14:24:56.754661+00
4988ca94-4e57-49b5-a28c-0ac6a4f54055	mpesa	b820cbed-2378-4b87-a711-dd4615c774c8	\N	2026-02-12	2	2026	Andrisa Deposito	\N	\N	\N	\N	\N	5000.0	0	0	5459.570000000007	\N	0	{}	Mpesa.xlsx	2026-04-22 14:24:56.754661+00	2026-04-22 14:24:56.754661+00
b636b61f-7375-4c67-b5c9-868a113bf4a4	mpesa	b820cbed-2378-4b87-a711-dd4615c774c8	\N	2026-02-12	2	2026	Manu Move boat to Xibaha	\N	\N	845561287	\N	\N	0	1000.0	0	4459.570000000007	\N	0	{}	Mpesa.xlsx	2026-04-22 14:24:56.754661+00	2026-04-22 14:24:56.754661+00
301593cd-95d7-4d2b-8bcf-ff5af71d2352	mpesa	b820cbed-2378-4b87-a711-dd4615c774c8	\N	2026-02-12	2	2026	Arlindo data	\N	\N	845072720	\N	\N	0	200.0	0	4259.570000000007	\N	0	{}	Mpesa.xlsx	2026-04-22 14:24:56.754661+00	2026-04-22 14:24:56.754661+00
3fddd32a-718c-4a31-81f9-db87acb9f4e9	mpesa	b820cbed-2378-4b87-a711-dd4615c774c8	\N	2026-02-12	2	2026	Arlindo Food	\N	\N	845072720	\N	\N	0	200.0	0	4059.570000000007	\N	0	{}	Mpesa.xlsx	2026-04-22 14:24:56.754661+00	2026-04-22 14:24:56.754661+00
4bfee397-f2f0-4d4f-8a37-e9ee26a833d7	mpesa	b820cbed-2378-4b87-a711-dd4615c774c8	\N	2026-02-12	2	2026	Arlindo Cyclone work	\N	\N	845072720	\N	\N	0	1000.0	0	3059.570000000007	\N	0	{}	Mpesa.xlsx	2026-04-22 14:24:56.754661+00	2026-04-22 14:24:56.754661+00
59905a6a-98fc-4a6a-9b0f-1d2b3757b2d1	mpesa	b820cbed-2378-4b87-a711-dd4615c774c8	\N	2026-02-14	2	2026	Anselmo Data	\N	\N	844634350	\N	\N	0	300.0	0	2759.570000000007	\N	0	{}	Mpesa.xlsx	2026-04-22 14:24:56.754661+00	2026-04-22 14:24:56.754661+00
a03ec969-650f-41ab-96fc-35423550b304	mpesa	b820cbed-2378-4b87-a711-dd4615c774c8	\N	2026-02-20	2	2026	Received Alex refund for cash to Darian Boat Chris gave Darian cash for fixing lights on trailer	\N	\N	\N	\N	\N	13000.0	0	0	15759.570000000007	\N	0	{}	Mpesa.xlsx	2026-04-22 14:24:56.754661+00	2026-04-22 14:24:56.754661+00
cea0e228-f1e1-42b7-aff3-16a68f1374fb	mpesa	b820cbed-2378-4b87-a711-dd4615c774c8	\N	2026-02-20	2	2026	Alex Starlink	\N	\N	855920893	\N	\N	0	3000.0	0	12759.570000000007	\N	0	{}	Mpesa.xlsx	2026-04-22 14:24:56.754661+00	2026-04-22 14:24:56.754661+00
1fb816e8-5434-476e-9fe8-90d605b013e2	mpesa	b820cbed-2378-4b87-a711-dd4615c774c8	\N	2026-02-23	2	2026	Claudio Data for Feb	\N	\N	842718852	\N	\N	0	200.0	0	12559.570000000007	\N	0	{}	Mpesa.xlsx	2026-04-22 14:24:56.754661+00	2026-04-22 14:24:56.754661+00
0d5c166f-41d0-4974-a05b-9eef02dd1ba9	mpesa	b820cbed-2378-4b87-a711-dd4615c774c8	\N	2026-02-28	2	2026	Ann-Lee Deposit	\N	\N	\N	\N	\N	12299.999999999998	0	0	24859.570000000007	\N	0	{}	Mpesa.xlsx	2026-04-22 14:24:56.754661+00	2026-04-22 14:24:56.754661+00
f0a002a3-325a-47d6-baf0-49fade09f24e	mpesa	b820cbed-2378-4b87-a711-dd4615c774c8	\N	2026-03-03	3	2026	Oscar Mangalisse	\N	\N	848875539	\N	\N	0	8160.0	0	16699.570000000007	\N	0	{}	Mpesa.xlsx	2026-04-22 14:24:56.754661+00	2026-04-22 14:24:56.754661+00
cc097caa-ae53-476d-ac19-b7319ed6b3a1	mpesa	b820cbed-2378-4b87-a711-dd4615c774c8	\N	2026-03-03	3	2026	Marcelino Mangalisse	\N	\N	842421644	\N	\N	0	1360.0	0	15339.570000000007	\N	0	{}	Mpesa.xlsx	2026-04-22 14:24:56.754661+00	2026-04-22 14:24:56.754661+00
4aa16db5-8a0c-49c5-8268-192a26cb2a0a	mpesa	b820cbed-2378-4b87-a711-dd4615c774c8	\N	2026-03-04	3	2026	Data Andrisa	\N	\N	\N	\N	\N	0	500.0	0	14839.570000000007	\N	0	{}	Mpesa.xlsx	2026-04-22 14:24:56.754661+00	2026-04-22 14:24:56.754661+00
d8afbb63-349f-4f9d-92df-d06ca90b378d	mpesa	b820cbed-2378-4b87-a711-dd4615c774c8	\N	2026-03-07	3	2026	Rosa Massage	\N	\N	847896811	\N	\N	0	3500.0	0	11339.570000000007	\N	0	{}	Mpesa.xlsx	2026-04-22 14:24:56.754661+00	2026-04-22 14:24:56.754661+00
c9526b56-c1cf-4d34-a0ed-359500f4d959	mpesa	b820cbed-2378-4b87-a711-dd4615c774c8	\N	2026-03-11	3	2026	Geraldo rubish Ebony	\N	\N	842614232	\N	\N	0	3000.0	0	8339.570000000007	\N	0	{}	Mpesa.xlsx	2026-04-22 14:24:56.754661+00	2026-04-22 14:24:56.754661+00
e543dfee-8968-498a-ad11-d18a41c83d3e	mpesa	b820cbed-2378-4b87-a711-dd4615c774c8	\N	2026-03-12	3	2026	Abdul Plants back of cottage	\N	\N	\N	\N	\N	0	960.0	0	7379.570000000007	\N	0	{}	Mpesa.xlsx	2026-04-22 14:24:56.754661+00	2026-04-22 14:24:56.754661+00
6dcb8a47-4aea-4941-bf7e-5c84263cbbb2	mpesa	b820cbed-2378-4b87-a711-dd4615c774c8	\N	2026-03-12	3	2026	Deposit Ebony	\N	\N	\N	\N	\N	10000.0	0	0	17379.570000000007	\N	0	{}	Mpesa.xlsx	2026-04-22 14:24:56.754661+00	2026-04-22 14:24:56.754661+00
ac96e33f-9270-42ae-819e-a255ae4823dd	mpesa	b820cbed-2378-4b87-a711-dd4615c774c8	\N	2026-03-12	3	2026	Geraldo rubish Landco	\N	\N	842614232	\N	\N	0	2500.0	0	14879.570000000007	\N	0	{}	Mpesa.xlsx	2026-04-22 14:24:56.754661+00	2026-04-22 14:24:56.754661+00
e4e66a8d-2a3c-44dc-8263-01d9655b6f32	mpesa	b820cbed-2378-4b87-a711-dd4615c774c8	\N	2026-03-15	3	2026	Aron Thatch Ebony	\N	\N	847811441	\N	\N	0	13000.0	0	1879.570000000007	\N	0	{}	Mpesa.xlsx	2026-04-22 14:24:56.754661+00	2026-04-22 14:24:56.754661+00
5a7304a2-ce7b-48a8-94d0-195c987ed78d	mpesa	b820cbed-2378-4b87-a711-dd4615c774c8	\N	2026-03-17	3	2026	Neto Loan	\N	\N	852437490	\N	\N	0	500.0	0	1379.570000000007	\N	0	{}	Mpesa.xlsx	2026-04-22 14:24:56.754661+00	2026-04-22 14:24:56.754661+00
953bf186-4aca-4e8b-abec-8b3bf04540b9	mpesa	b820cbed-2378-4b87-a711-dd4615c774c8	\N	2026-03-19	3	2026	Bundels Andrisa	\N	\N	847250140	\N	\N	0	500.0	0	879.570000000007	\N	0	{}	Mpesa.xlsx	2026-04-22 14:24:56.754661+00	2026-04-22 14:24:56.754661+00
f0eeb65b-42ab-405f-84e0-eea9ce23602b	mpesa	b820cbed-2378-4b87-a711-dd4615c774c8	\N	2026-03-23	3	2026	Macarata pump fix Marbar	\N	\N	848412766	\N	\N	0	250.0	0	629.570000000007	\N	0	{}	Mpesa.xlsx	2026-04-22 14:24:56.754661+00	2026-04-22 14:24:56.754661+00
8bf9aa9c-cd7b-4214-a181-68aca4ae3a2a	mpesa	b820cbed-2378-4b87-a711-dd4615c774c8	\N	2026-03-24	3	2026	Pedro airtime	\N	\N	\N	\N	\N	0	100.0	0	529.570000000007	\N	0	{}	Mpesa.xlsx	2026-04-22 14:24:56.754661+00	2026-04-22 14:24:56.754661+00
267cea8b-9284-445f-97d2-352a2196bb38	mpesa	b820cbed-2378-4b87-a711-dd4615c774c8	\N	2026-03-27	3	2026	Ann-Lee Deposit	\N	\N	\N	\N	\N	12000.0	0	0	12529.570000000007	\N	0	{}	Mpesa.xlsx	2026-04-22 14:24:56.754661+00	2026-04-22 14:24:56.754661+00
72472bb6-0a96-4b76-908f-10d45347ef54	mpesa	b820cbed-2378-4b87-a711-dd4615c774c8	\N	2026-03-27	3	2026	Basilio Maritimo Inspection fee NEGU & RSD	\N	\N	847254893	\N	\N	0	7200.0	0	5329.570000000007	\N	0	{}	Mpesa.xlsx	2026-04-22 14:24:56.754661+00	2026-04-22 14:24:56.754661+00
1827628d-83a5-45e8-bc8e-5b3e2197b2bf	mpesa	b820cbed-2378-4b87-a711-dd4615c774c8	\N	2026-03-27	3	2026	Geraldo rubish Ebony	\N	\N	842614232	\N	\N	0	1500.0	0	3829.570000000007	\N	0	{}	Mpesa.xlsx	2026-04-22 14:24:56.754661+00	2026-04-22 14:24:56.754661+00
e2df3884-fcf4-4c2c-92b2-231e7dab1e6a	mpesa	b820cbed-2378-4b87-a711-dd4615c774c8	\N	2026-03-28	3	2026	Marcelino Mangalisse	\N	\N	842421644	\N	\N	0	1360.0	0	2469.570000000007	\N	0	{}	Mpesa.xlsx	2026-04-22 14:24:56.754661+00	2026-04-22 14:24:56.754661+00
f15c9a87-7cf0-4c26-94c4-c1f19d759158	mpesa	b820cbed-2378-4b87-a711-dd4615c774c8	\N	2026-03-30	3	2026	Claudio Data for Feb	\N	\N	842718852	\N	\N	0	200.0	0	2269.570000000007	\N	0	{}	Mpesa.xlsx	2026-04-22 14:24:56.754661+00	2026-04-22 14:24:56.754661+00
3edf474e-b537-489d-87ab-6aac9577b47a	mpesa	b820cbed-2378-4b87-a711-dd4615c774c8	\N	2026-03-31	3	2026	Andrisa Deposito	\N	\N	\N	\N	\N	20000.0	0	0	22269.570000000007	\N	0	{}	Mpesa.xlsx	2026-04-22 14:24:56.754661+00	2026-04-22 14:24:56.754661+00
c662359c-b5ce-466f-8d11-e76b14e2d5bc	mpesa	b820cbed-2378-4b87-a711-dd4615c774c8	\N	2026-03-31	3	2026	Julio transport stone cement and bricks	\N	\N	842595754	\N	\N	0	3000.0	0	19269.570000000007	\N	0	{}	Mpesa.xlsx	2026-04-22 14:24:56.754661+00	2026-04-22 14:24:56.754661+00
3f4373a8-fda0-4e40-8325-a027b41969ec	mpesa	b820cbed-2378-4b87-a711-dd4615c774c8	\N	2026-03-31	3	2026	Julio load white sand	\N	\N	842595754	\N	\N	0	1700.0	0	17569.570000000007	\N	0	{}	Mpesa.xlsx	2026-04-22 14:24:56.754661+00	2026-04-22 14:24:56.754661+00
8ee44f0f-ea77-44d2-8c50-7004edc61f5b	mpesa	b820cbed-2378-4b87-a711-dd4615c774c8	\N	2026-04-04	4	2026	Geraldo rubish Ebony	\N	\N	842614232	\N	\N	0	1500.0	0	16069.570000000007	\N	0	{}	Mpesa.xlsx	2026-04-22 14:24:56.754661+00	2026-04-22 14:24:56.754661+00
bc8dcea0-5e47-4967-9f0f-246ff12e28a0	mpesa	b820cbed-2378-4b87-a711-dd4615c774c8	\N	2026-04-08	4	2026	Basilio Maritimo Inspection fee KRAKEN	\N	\N	847254893	\N	\N	0	3600.0	0	12469.570000000007	\N	0	{}	Mpesa.xlsx	2026-04-22 14:24:56.754661+00	2026-04-22 14:24:56.754661+00
ac31b20f-0259-41e2-9ff0-1d3ce10a59f4	mpesa	b820cbed-2378-4b87-a711-dd4615c774c8	\N	2026-04-10	4	2026	Anderto Load of Stone Ebony	\N	\N	847631912	\N	\N	0	3000.0	0	9469.570000000007	\N	0	{}	Mpesa.xlsx	2026-04-22 14:24:56.754661+00	2026-04-22 14:24:56.754661+00
e2f004da-e76c-4322-8622-f1b8a362ab44	mpesa	b820cbed-2378-4b87-a711-dd4615c774c8	\N	2026-04-12	4	2026	Credilec Marbar	\N	\N	\N	\N	\N	0	2000.0	0	7469.570000000007	\N	0	{}	Mpesa.xlsx	2026-04-22 14:24:56.754661+00	2026-04-22 14:24:56.754661+00
56ef09be-65ad-476f-a432-8dfc1c3a52b5	mpesa	b820cbed-2378-4b87-a711-dd4615c774c8	\N	2026-04-14	4	2026	Alex Grupo Sea Short on invoice	\N	\N	847600060	\N	\N	0	100.0	0	7369.570000000007	\N	0	{}	Mpesa.xlsx	2026-04-22 14:24:56.754661+00	2026-04-22 14:24:56.754661+00
643ae31d-c84c-4a88-bdfe-fb86458f0018	mpesa	b820cbed-2378-4b87-a711-dd4615c774c8	\N	2026-04-17	4	2026	Pedro Bundles	\N	\N	\N	\N	\N	0	200.0	0	7169.570000000007	\N	0	{}	Mpesa.xlsx	2026-04-22 14:24:56.754661+00	2026-04-22 14:24:56.754661+00
79704aa0-e42e-474c-a3c0-766c0f5cea27	mpesa	b820cbed-2378-4b87-a711-dd4615c774c8	\N	2026-04-17	4	2026	Julio load white sand	\N	\N	842595754	\N	\N	0	1700.0	0	5469.570000000007	\N	0	{}	Mpesa.xlsx	2026-04-22 14:24:56.754661+00	2026-04-22 14:24:56.754661+00
458664ee-d9c3-4727-bcee-d0a6385fb9ee	mpesa	b820cbed-2378-4b87-a711-dd4615c774c8	\N	2026-04-20	4	2026	Airtime Andrisa	\N	\N	847250140	\N	\N	0	500.0	0	4969.570000000007	\N	0	{}	Mpesa.xlsx	2026-04-22 14:24:56.754661+00	2026-04-22 14:24:56.754661+00
3c6c5c2d-e0e4-47dc-8c74-59ffcae69f74	mpesa	b820cbed-2378-4b87-a711-dd4615c774c8	\N	2026-04-20	4	2026	Audencia	\N	\N	857735818	\N	\N	0	500.0	0	4469.570000000007	\N	0	{}	Mpesa.xlsx	2026-04-22 14:24:56.754661+00	2026-04-22 14:24:56.754661+00
dde3701c-0beb-4c0d-bb01-c745f8dbbd2d	emola	388a9c8a-30e4-49b2-b91a-b1813b61e0f5	1	\N	1	2026		\N	\N	\N	\N	\N	0	0	0	\N	\N	0	{}	\N	2026-04-24 08:27:13.642161+00	2026-04-24 08:27:13.642161+00
7d87833a-f9d8-4708-b566-daa74bc2d14a	emola	388a9c8a-30e4-49b2-b91a-b1813b61e0f5	\N	2026-04-24	1	2026	Workers Kitchen	Byron	Bones	\N	\N	\N	\N	30000	0	8155.0	\N	0	{}	Emola.xlsx	2026-04-22 14:24:56.716838+00	2026-04-24 08:36:29.92635+00
d1cc73eb-0622-48d8-a93b-1b9a365071f8	emola	388a9c8a-30e4-49b2-b91a-b1813b61e0f5	\N	2025-09-02	9	2026	Ablution Block	Landco	Bones	\N	\N	\N	11000.0	0	0	22320.0	\N	0	{}	Emola.xlsx	2026-04-22 14:24:56.716838+00	2026-04-25 04:59:10.714793+00
\.


--
-- Data for Name: employees; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.employees (id, name, category, nib, nuit, base_salary, food_allowance, house_assignment, is_active, created_at, updated_at) FROM stdin;
f3da8412-3dae-45b0-b4df-23da5df5dbca	MARCO BEBE GIMO	GERENTE	304762846	\N	73000.00	8000.00	AM	t	2026-04-12 06:03:10.130395+00	2026-04-12 06:03:10.130395+00
20c0e869-ee8c-464c-99b8-5df806753cd0	ARMINDO QUETANE HOU	GUARDA	312688813	\N	11336.00	0.00	AM	t	2026-04-12 06:03:10.130395+00	2026-04-12 06:03:10.130395+00
8c597645-cf92-4003-84af-a781c51f69d1	CONSTANTINO JOSE PENGA	GUARDA	88904090	\N	11336.00	0.00	AM	t	2026-04-12 06:03:10.130395+00	2026-04-12 06:03:10.130395+00
8540a557-d3a3-45ed-99c1-a96007dc63de	ANSELMO LUCAS HUO	GUARDA	311846368	\N	11336.00	0.00	AM	t	2026-04-12 06:03:10.130395+00	2026-04-12 06:03:10.130395+00
a35d12c2-81fe-42bc-b195-38e9e713be34	CISTORA JOAO TANGUNE	EMPREGADA	465121888	\N	10900.00	0.00	AM	t	2026-04-12 06:03:10.130395+00	2026-04-12 06:03:10.130395+00
a591d7ff-6607-4406-b1bb-99fea46605e4	EMILIO GELSON ZIBANE	JARDINERO	465126932	\N	11445.00	0.00	AM	t	2026-04-12 06:03:10.130395+00	2026-04-12 06:03:10.130395+00
69627fba-2984-43c4-800e-c592fd1a18d0	ALMEIDA ANTONIO VILANCULO	JARDINERO	784781120	\N	10900.00	0.00	AM	t	2026-04-12 06:03:10.130395+00	2026-04-12 06:03:10.130395+00
b2db1ad4-a7d5-4551-8f47-edbf98149a8d	FELIX CARLOS MASSUANGANHE	JARDINERO	1236577535	\N	10900.00	0.00	AM	t	2026-04-12 06:03:10.130395+00	2026-04-12 06:03:10.130395+00
8aa3936d-1f8c-48f6-982a-2f9b58d2ec64	GILDA DALARIO FALACO MUABASA	EMPREGADA	312354163	\N	10955.00	0.00	H1	t	2026-04-12 06:03:10.130395+00	2026-04-12 06:03:10.130395+00
25ef4bf1-4d69-4bea-b060-1d46a50248e8	SERGIO FENIASSE BUANE	COZINHEIRA	426758485	\N	14824.00	0.00	H1	t	2026-04-12 06:03:10.130395+00	2026-04-12 06:03:10.130395+00
6b858a35-05f5-4de9-9c69-15c80fde978e	AMINOSSE ARNALDO TANGUNE	CAPIT??O DE BARCO	000800007745713610195	\N	14170.00	0.00	H1/H4	t	2026-04-12 06:03:10.130395+00	2026-04-12 06:03:10.130395+00
c4ab3503-9e29-4c60-a8de-53dcca2b4225	SERGIO FRANCISCO TANGUNE ZITO	GHILLIE	311712702	\N	14879.00	0.00	H2	t	2026-04-12 06:03:10.130395+00	2026-04-12 06:03:10.130395+00
b21601cf-206c-4a78-9cb7-73045874f36e	VITORIA FRANCISCO ZIBANE	EMPREGADA	98059241	\N	10955.00	0.00	H2	t	2026-04-12 06:03:10.130395+00	2026-04-12 06:03:10.130395+00
7fcc5c4b-e6fe-4bb4-a459-d2481d7e7cf1	INACIO FABIAO TIMBE	CAPIT??O DE BARCO	411440730	\N	16350.00	0.00	H2	t	2026-04-12 06:03:10.130395+00	2026-04-12 06:03:10.130395+00
ffd04fc1-9c18-4182-8998-4c1d7a09dc30	CALDERONE AGOSTINHO CHIVALE	COZINHEIRA	000800004412814610113	\N	16350.00	0.00	H2	t	2026-04-12 06:03:10.130395+00	2026-04-12 06:03:10.130395+00
58ee18f4-5296-4864-9cf6-5dc79c29cfa5	PEDRO SEBASTIAO NHAMIRE	JARDINERO/GHILLIE	393221511	\N	11445.00	0.00	H3	t	2026-04-12 06:03:10.130395+00	2026-04-12 06:03:10.130395+00
1914c017-1c20-4db2-b712-413a6ac194dd	ROCINA CAHIWANE TIMBE	EMPREGADA	313333863	\N	10955.00	0.00	H3	t	2026-04-12 06:03:10.130395+00	2026-04-12 06:03:10.130395+00
b609a704-c683-4b18-b1a5-6c62e382afde	ALEXANDRE LUCAS MASSUANGANHE	COZINHEIRA	305745068	\N	14225.00	0.00	H3	t	2026-04-12 06:03:10.130395+00	2026-04-12 06:03:10.130395+00
e7a713f6-7914-45d8-ac51-839247b3d641	JELSON QUALDADE ZIVANE	JARDINERO/COZINHA	311818141	\N	11445.00	0.00	H4	t	2026-04-12 06:03:10.130395+00	2026-04-12 06:03:10.130395+00
7a0ff3cb-1b78-48af-b980-681e55f09980	MONIS TSANZIUANE CHIVALE	COZINHEIRA	169475394	\N	14225.00	0.00	H4	t	2026-04-12 06:03:10.130395+00	2026-04-12 06:03:10.130395+00
0b1c761f-1e1d-4025-a4d4-1f6cfa312118	EVELIN NELSON BERNARDO	EMPREGADA	257804370	\N	10955.00	0.00	H4	t	2026-04-12 06:03:10.130395+00	2026-04-12 06:03:10.130395+00
\.


--
-- Data for Name: exchange_rates; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.exchange_rates (id, month, year, mzn_per_usd, mzn_per_zar, created_at) FROM stdin;
f873a91f-3dab-48f5-a4f1-c7b443815d38	1	2026	63.2500	3.5000	2026-04-12 06:03:10.130395+00
\.


--
-- Data for Name: expense_categories; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.expense_categories (id, name, is_shared, created_at, pgc_account_code, name_en, name_pt, category_type, parent_id) FROM stdin;
a83882c7-3982-4812-a27a-0f859ae0c26c	ELECTRICAL UPGRADE	t	2026-04-12 06:03:10.130395+00	\N	\N	\N	main	\N
2ea14067-c2ed-497c-bd65-5caa453bec6f	WORKERS TOILET BUILDING PLANS	t	2026-04-12 06:03:10.130395+00	\N	\N	\N	main	\N
133b1460-ab9b-4aa9-bc68-521055f45d5c	IST PAYMENT IRPC	t	2026-04-12 06:03:10.130395+00	\N	\N	\N	main	\N
7b9f70e9-32de-4bab-b48e-1a8342c475d6	HOUSE STAFF SALARIES	f	2026-04-12 06:03:10.130395+00	\N	\N	\N	main	\N
f0ee785b-21ac-458b-8bb6-288c938a9b42	CLEANING	f	2026-04-12 06:03:10.130395+00	\N	\N	\N	main	\N
ef53b42a-b89e-442a-8ff0-f54b51a30a50	FOOD & PROVISIONS	f	2026-04-12 06:03:10.130395+00	\N	\N	\N	main	\N
dafc56c1-115e-49b2-ac76-9159880e3396	EQUIPMENT	t	2026-04-21 16:47:16.345995+00	6245	Equipment	EQUIPAMENTO	main	\N
a899ce0c-e15f-4843-84da-66be66bffca2	EXPENSES LUZ	f	2026-04-21 16:47:16.345995+00	6411	Luz House Expenses	DESPESAS LUZ	main	\N
9e205d02-03ec-4b83-a6d5-e31f74d021be	EXPENSES AURORA	f	2026-04-21 16:47:16.345995+00	6412	Aurora House Expenses	DESPESAS AURORA	main	\N
1b643d33-14d8-43a5-9beb-2dafaf6b401c	EXPENSES CAJU	f	2026-04-21 16:47:16.345995+00	6413	Caju House Expenses	DESPESAS CAJU	main	\N
dbb4f40d-c363-4c95-9bec-e51a8a17afab	EXPENSES COCO	f	2026-04-21 16:47:16.345995+00	6414	Coco House Expenses	DESPESAS COCO	main	\N
cb6468ec-0bb8-48e6-95fe-14570f93873f	SUSPENSE	t	2026-04-21 16:47:16.345995+00	262	Suspense Account	CONTA SUSPENSA	main	\N
9b767233-4660-448b-9fd9-bf3f6201873c	SALARIES & WAGES	t	2026-04-12 06:03:10.130395+00	6111	\N	\N	main	\N
7277bf7f-0a2f-4363-ad96-cf34e30d4819	CASUAL WORKERS AND FOOD ALLOWANCE	t	2026-04-12 06:03:10.130395+00	6112	\N	\N	main	\N
8350e17d-9aaf-4477-9889-f23ffd2cf8ea	OFFICE AND BANK CHARGES	t	2026-04-12 06:03:10.130395+00	6211	\N	\N	main	\N
e03b9332-c067-4f05-abb0-ded1930718de	ADMIN CHARGES (BDO & ANDRISA)	t	2026-04-12 06:03:10.130395+00	6212	\N	\N	main	\N
9f670eb3-575e-4e33-ac37-5871a9a1f16e	COMMUNITY	t	2026-04-12 06:03:10.130395+00	6213	\N	\N	main	\N
3d0a295c-1808-4390-bea7-50d9bd3d0faf	HOUSE KEEPING	t	2026-04-12 06:03:10.130395+00	6214	\N	\N	main	\N
ded401ee-a44a-429f-8847-507555d690e9	GAS AND ELECTRICITY	t	2026-04-12 06:03:10.130395+00	6221	\N	\N	main	\N
a26e6c21-d0ec-4dad-8eea-b209b4bc5cd7	DIESEL AND PETROL	t	2026-04-12 06:03:10.130395+00	6231	\N	\N	main	\N
fe7ecebd-073a-4d4c-9bc7-1a8d3112b93d	MAINTENANCE GENERAL	t	2026-04-12 06:03:10.130395+00	6241	\N	\N	main	\N
8d1dbf26-84f1-494d-bd35-562efef6eb77	MAINTENANCE GARDEN & POOL	t	2026-04-12 06:03:10.130395+00	6242	\N	\N	main	\N
4ca0190a-1665-432b-afb8-f65adc52586a	MAINTENANCE VEHICLES	t	2026-04-12 06:03:10.130395+00	6243	\N	\N	main	\N
ee6696ff-5ca9-462f-aad3-26c3264b98e2	SMALL TOOLS	t	2026-04-12 06:03:10.130395+00	6244	\N	\N	main	\N
dfdd89ae-2650-4bde-ab3e-cdf272e1129f	MARITIME & MUNICIPAL TAXES IPRA & TAE	t	2026-04-12 06:03:10.130395+00	6311	\N	\N	main	\N
cd3a4860-e203-4611-8359-dd41f7e7f89b	INSURANCE & LICENSE	t	2026-04-12 06:03:10.130395+00	626	\N	\N	main	\N
\.


--
-- Data for Name: expense_transactions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.expense_transactions (id, date, property_id, shareholder_id, category_id, description, amount_mzn, is_shared, month, year, created_at, updated_at, journal_entry_id) FROM stdin;
265473ae-d49e-4fe1-9424-4b973a5affaa	2026-01-03	\N	\N	ded401ee-a44a-429f-8847-507555d690e9	ENH DECEMBER ??? GAS DECEMBER	6426.95	t	1	2026	2026-04-21 17:11:00.951558+00	2026-04-21 17:11:00.951558+00	83a6fb82-d8b9-4827-adc8-e71eb1256eaf
d08031fd-514a-448b-9cc3-4c926300963a	2026-01-11	\N	\N	e03b9332-c067-4f05-abb0-ded1930718de	ADMIN FEE ??? ADMIN AND ACCOUNTING	146740.00	t	1	2026	2026-04-21 17:11:01.536967+00	2026-04-21 17:11:01.536967+00	c55e90aa-685f-4975-b5ce-3e7bb3b246bc
795e2b65-1acc-43b4-a5e5-45a17170db62	2026-01-16	\N	\N	8350e17d-9aaf-4477-9889-f23ffd2cf8ea	TRANSFER FEE ??? BANK CHARGES OFFICE EXPENSES	7.00	t	1	2026	2026-04-21 17:11:02.114644+00	2026-04-21 17:11:02.114644+00	89ddfb17-f5d5-47f5-9d6f-894fad670df7
d0389860-86b6-46c4-a7cf-1560a1d11a9a	2026-01-22	\N	\N	8350e17d-9aaf-4477-9889-f23ffd2cf8ea	FILES ??? STATIONARY	1500.00	t	1	2026	2026-04-21 17:11:02.683975+00	2026-04-21 17:11:02.683975+00	41e7ff5a-d37d-4270-acd4-d0ff351358a1
f34476a6-4039-435b-ba62-9bbe7a8ce20c	2026-01-22	\N	\N	cb6468ec-0bb8-48e6-95fe-14570f93873f	TRANSFER TO PETTY CASH ??? SUSPENCE	10000.00	t	1	2026	2026-04-21 17:11:03.262349+00	2026-04-21 17:11:03.262349+00	4ac70d05-8898-485d-8baf-978f6a9ee47f
43e0c7bb-cb58-4c24-bd2b-7b1f2d2c638b	2026-01-23	\N	\N	7277bf7f-0a2f-4363-ad96-cf34e30d4819	BREAD ??? WORKERS FOOD ALOWANCE	12000.00	t	1	2026	2026-04-21 17:11:03.86204+00	2026-04-21 17:11:03.86204+00	5d8a32a0-73c6-4bc5-8739-cc348ae8f173
302f2edf-7f1a-4319-9fc5-fbaca2783f16	2026-01-29	\N	\N	ded401ee-a44a-429f-8847-507555d690e9	GAS JANUARY ??? GAS & ELECTRISITY	4833.15	t	1	2026	2026-04-21 17:11:04.461936+00	2026-04-21 17:11:04.461936+00	d84c5a1d-4510-47e6-9085-7b755ddbbb7e
f2a5dede-01fb-48dd-80a4-5006495d59c4	2026-01-29	\N	\N	fe7ecebd-073a-4d4c-9bc7-1a8d3112b93d	2 TOMADA SA E 2 CX 4X4 ??? GENERAL MAINTENANCE	900.00	t	1	2026	2026-04-21 17:11:05.022307+00	2026-04-21 17:11:05.022307+00	d3d9a7fe-8f58-4d0e-867d-da921c035dd5
a9cd95ab-4352-459a-ae3e-a31f5a4324d7	2026-01-14	\N	\N	8350e17d-9aaf-4477-9889-f23ffd2cf8ea	FINE ON LATE PY OF 2023 ??? FINES	1462.56	t	1	2026	2026-04-21 17:11:05.602755+00	2026-04-21 17:11:05.602755+00	422cea12-835c-4ce1-a924-c2d48d12bf4e
61d0437f-6650-459b-a204-41f6453976c8	2026-01-07	\N	\N	fe7ecebd-073a-4d4c-9bc7-1a8d3112b93d	SAND PAPER & LUBRICATE SPRAY ??? GENERAL MAITENANCE	8329.00	t	1	2026	2026-04-21 17:11:06.193757+00	2026-04-21 17:11:06.193757+00	38a6efb2-c9ae-4977-8118-717f4208d60c
bec3fdc1-29d8-4119-8d9b-bf57f67b8543	2026-01-01	\N	\N	8350e17d-9aaf-4477-9889-f23ffd2cf8ea	ALEX ??? STARLINK FOR JAN	3000.00	t	1	2026	2026-04-21 17:11:06.818183+00	2026-04-21 17:11:06.818183+00	08426640-7d4f-4075-bbe4-51769a845d3e
b8480c17-09e9-48ee-aa77-a47202b1aeb8	2026-01-21	\N	\N	7277bf7f-0a2f-4363-ad96-cf34e30d4819	BEBE ??? FOOD FOR WORKERS	21000.00	t	1	2026	2026-04-21 17:11:07.384179+00	2026-04-21 17:11:07.384179+00	09e26dc1-2e4c-4923-b999-8cf2fbd413b8
c07279ee-f175-43bf-b98f-b486b7379b54	2026-01-31	bf17ad40-c04f-4438-8456-1bb96ebcecc7	\N	9e205d02-03ec-4b83-a6d5-e31f74d021be	WARREN ??? Shortfall on Ronny money from Warren	2220.00	f	1	2026	2026-04-21 17:11:07.936654+00	2026-04-21 17:11:07.936654+00	101f3ddf-6f52-4595-ad92-f0e28ff9f5bc
6013d109-426d-47a7-84c3-45cba9125b8e	2026-02-04	\N	\N	8350e17d-9aaf-4477-9889-f23ffd2cf8ea	Bank Charges ??? Office expenses	7.00	t	2	2026	2026-04-21 17:11:09.510239+00	2026-04-21 17:11:09.510239+00	9123593a-5a0a-4e08-a00e-f7f94a5c2834
827a6807-e3f2-4fa9-b239-fb5fc8b23263	2026-02-10	\N	\N	8350e17d-9aaf-4477-9889-f23ffd2cf8ea	Bank Charges ??? Office expenses	7.00	t	2	2026	2026-04-21 17:11:10.095125+00	2026-04-21 17:11:10.095125+00	a0990117-2e10-4337-97ce-1bc4d4a253c3
a12a5f55-0d69-4624-8ebf-ad9f0b19f473	2026-02-18	\N	\N	e03b9332-c067-4f05-abb0-ded1930718de	Accounting ??? Accounting fee Feb	37386.80	t	2	2026	2026-04-21 17:11:10.662563+00	2026-04-21 17:11:10.662563+00	3ccb8873-50fa-4c76-b90b-3389c162170e
6d3c14c3-0c19-4c10-a873-68bf3a46a946	2026-02-23	\N	\N	ded401ee-a44a-429f-8847-507555d690e9	Gas Jan ??? Gas& Eletrisity	4470.61	t	2	2026	2026-04-21 17:11:11.246459+00	2026-04-21 17:11:11.246459+00	a44a8505-6f69-4f3d-b3ba-c7379a2fe151
b6e2d7e2-25f5-49ee-b109-66bf2f6d2bf8	2026-02-23	\N	\N	cd3a4860-e203-4611-8359-dd41f7e7f89b	SIM R SEG ??? INSURANCE JET SKI AND TRAILER	1409.68	t	2	2026	2026-04-21 17:11:11.809503+00	2026-04-21 17:11:11.809503+00	4a92ba63-57f8-415f-97fa-421662784440
b15bebc7-41be-4667-bd17-118a172cf3cc	2026-02-25	\N	\N	8350e17d-9aaf-4477-9889-f23ffd2cf8ea	Bank Charges ??? Office expenses	254.00	t	2	2026	2026-04-21 17:11:12.399405+00	2026-04-21 17:11:12.399405+00	e26b6f3a-e7f5-473b-a653-a9330df61afa
80daebd2-16e7-4f28-a918-db492af3317c	2026-02-27	\N	\N	fe7ecebd-073a-4d4c-9bc7-1a8d3112b93d	Lampadas ??? General Maintenance	1250.00	t	2	2026	2026-04-21 17:11:12.943512+00	2026-04-21 17:11:12.943512+00	88c35807-ef27-4641-91db-8f5bbf36d490
8d8eb3c7-ad9a-4f4a-bd49-1669b50e77e2	2026-02-09	6214c344-b5f9-4d17-b539-e367889ffa9c	\N	dbb4f40d-c363-4c95-9bec-e51a8a17afab	FISH  BODYBOARD ??? HOUSE 4	10068.80	f	2	2026	2026-04-21 17:11:13.517936+00	2026-04-21 17:11:13.517936+00	e60e8788-385c-473f-b58a-1dcc9dc0f511
119aef1b-362c-4196-9c5c-00120cb1aace	2026-02-11	ea35b0ac-a1c4-4269-ac14-c52e1de9d514	\N	a899ce0c-e15f-4843-84da-66be66bffca2	SOAP ??? HOUSE KEEPING HOUSE 1	1030.00	f	2	2026	2026-04-21 17:11:14.089877+00	2026-04-21 17:11:14.089877+00	8b1b885c-402e-4498-bada-6e7644272a32
cf070c0b-5d3a-4321-b75d-246e17cd8122	2026-02-12	\N	\N	3d0a295c-1808-4390-bea7-50d9bd3d0faf	TECNO 40 X 2 ??? CELL FOR GUARDS SECURITY	10500.00	t	2	2026	2026-04-21 17:11:14.661467+00	2026-04-21 17:11:14.661467+00	9cd81326-24e4-49dd-9b23-2f37738ba1c6
bddf5851-0bbe-4fa4-9ac7-ff0eb174e52d	2026-03-02	\N	\N	8350e17d-9aaf-4477-9889-f23ffd2cf8ea	BANK CHARGES ??? BANK CHARGES	7.00	t	3	2026	2026-04-21 17:11:15.521635+00	2026-04-21 17:11:15.521635+00	64bdb517-2370-45d2-82f5-0d26cc9a97d2
47d9cdcb-d5ad-4d1b-af62-02fd255a2974	2026-03-09	\N	\N	a26e6c21-d0ec-4dad-8eea-b209b4bc5cd7	DIESEL MMR0998 ??? MOTOR VEHICLE LANDCO	7384.37	t	3	2026	2026-04-21 17:11:16.103242+00	2026-04-21 17:11:16.103242+00	f5d6b151-a579-486e-aa8d-6a4d7b242ef4
af313133-522a-4fa3-b812-64426d5ce45e	2026-03-11	\N	\N	8350e17d-9aaf-4477-9889-f23ffd2cf8ea	BANK CHARGES ??? BANK CHARGES	7.00	t	3	2026	2026-04-21 17:11:16.689346+00	2026-04-21 17:11:16.689346+00	b63e52f7-2566-4e83-b643-f432f5f38501
11ae31ba-67f9-4531-b626-12276a391f09	2026-03-17	\N	\N	8350e17d-9aaf-4477-9889-f23ffd2cf8ea	CARTO DEBITO ??? BANK CHARGES	600.00	t	3	2026	2026-04-21 17:11:17.230561+00	2026-04-21 17:11:17.230561+00	08af3a5a-5054-463b-9849-69f9516fab4d
144b1e91-55a1-4b21-a86e-9f216c013518	2026-03-18	\N	\N	cd3a4860-e203-4611-8359-dd41f7e7f89b	IMPRA ??? INSURANCE JETSKI	1409.68	t	3	2026	2026-04-21 17:11:17.786833+00	2026-04-21 17:11:17.786833+00	66dae584-41ba-4780-8003-cb4d173da95c
5b328a63-96ed-45e7-832f-9eccbe211104	2026-03-18	\N	\N	cd3a4860-e203-4611-8359-dd41f7e7f89b	IMPRA ??? INSURANCE TRAILER	1409.68	t	3	2026	2026-04-21 17:11:17.786833+00	2026-04-21 17:11:17.786833+00	66dae584-41ba-4780-8003-cb4d173da95c
dee8281d-ce6c-4dff-af58-867c15deba81	2026-03-19	6214c344-b5f9-4d17-b539-e367889ffa9c	\N	dbb4f40d-c363-4c95-9bec-e51a8a17afab	BATTERY PRADO H4 ??? MOTOR VEHICLES EXPENSES	10500.00	f	3	2026	2026-04-21 17:11:18.356416+00	2026-04-21 17:11:18.356416+00	1cb99578-4d38-4d77-bdff-3540e48e9880
63e98b2d-44e7-494d-8dde-73754221e3c6	2026-03-23	\N	\N	cb6468ec-0bb8-48e6-95fe-14570f93873f	PETTY CASH ??? SUSPENSE	18889.39	t	3	2026	2026-04-21 17:11:18.96811+00	2026-04-21 17:11:18.96811+00	aab75988-68fb-4634-97b7-c9cfe0de6ea5
a8efde9c-15fb-4afd-9102-84ffa1563be2	2026-03-25	\N	\N	e03b9332-c067-4f05-abb0-ded1930718de	ADMIN FEE ??? ACCOUNTING AND ADMIN	146740.00	t	3	2026	2026-04-21 17:11:19.52818+00	2026-04-21 17:11:19.52818+00	a64976d7-0b33-4889-9ea1-63ae172fe546
605f2862-91d1-44ea-b9dc-144f63f18494	2026-03-27	\N	\N	dfdd89ae-2650-4bde-ab3e-cdf272e1129f	IPRA 2026 ??? LAND TAX	52850.00	t	3	2026	2026-04-21 17:11:20.094701+00	2026-04-21 17:11:20.094701+00	c7e89fa9-d9a9-45cc-8c29-6a0673a7d9ab
0813c3d7-f0bd-42de-b28f-23742d8fe995	2026-03-27	\N	\N	fe7ecebd-073a-4d4c-9bc7-1a8d3112b93d	Q20 OIL ANTI RUST ??? GENERAL MAINTRENANCE	1160.00	t	3	2026	2026-04-21 17:11:20.665791+00	2026-04-21 17:11:20.665791+00	2f5e4be7-3504-4e0b-ac21-27c42a0419ec
242b3c85-f63a-41cd-b6b1-37fabea854c4	2026-03-30	\N	\N	9b767233-4660-448b-9fd9-bf3f6201873c	INSS ??? SALARIES & WAGES	6592.84	t	3	2026	2026-04-21 17:11:21.24355+00	2026-04-21 17:11:21.24355+00	766b41b6-beea-4245-825f-6405f709d467
35fb49a6-5180-4596-a063-cda43a926de0	2026-03-30	ea35b0ac-a1c4-4269-ac14-c52e1de9d514	\N	a899ce0c-e15f-4843-84da-66be66bffca2	INSS ??? SALARIES & WAGES	1394.84	f	3	2026	2026-04-21 17:11:21.24355+00	2026-04-21 17:11:21.24355+00	766b41b6-beea-4245-825f-6405f709d467
9dc583cd-6d2b-4bb5-89a1-a00ee805c40e	2026-03-30	bf17ad40-c04f-4438-8456-1bb96ebcecc7	\N	9e205d02-03ec-4b83-a6d5-e31f74d021be	INSS ??? SALARIES & WAGES	2341.36	f	3	2026	2026-04-21 17:11:21.24355+00	2026-04-21 17:11:21.24355+00	766b41b6-beea-4245-825f-6405f709d467
34508f6c-c401-4d96-83a8-8fb3856c8197	2026-03-30	b0e3af81-86f7-4e03-8742-a859303b62a6	\N	1b643d33-14d8-43a5-9beb-2dafaf6b401c	INSS ??? SALARIES & WAGES	1465.00	f	3	2026	2026-04-21 17:11:21.24355+00	2026-04-21 17:11:21.24355+00	766b41b6-beea-4245-825f-6405f709d467
1471c6b3-7b69-4b72-b362-3b41ef027d3a	2026-03-30	6214c344-b5f9-4d17-b539-e367889ffa9c	\N	dbb4f40d-c363-4c95-9bec-e51a8a17afab	INSS ??? SALARIES & WAGES	1725.00	f	3	2026	2026-04-21 17:11:21.24355+00	2026-04-21 17:11:21.24355+00	766b41b6-beea-4245-825f-6405f709d467
379ad978-563f-4b87-a0be-25775a7d3a37	2026-03-30	\N	\N	cd3a4860-e203-4611-8359-dd41f7e7f89b	WORKMENS COMPENSATIO ??? INSURANCE	30417.98	t	3	2026	2026-04-21 17:11:21.782091+00	2026-04-21 17:11:21.782091+00	42d826ae-c937-4ce5-94a8-83e4d2a01290
acc929ea-2636-44c4-8f53-2a9aca46eab7	2026-03-01	\N	\N	8350e17d-9aaf-4477-9889-f23ffd2cf8ea	STARLINK FOR FEB	3000.00	t	3	2026	2026-04-21 17:11:22.356171+00	2026-04-21 17:11:22.356171+00	ffd70777-be09-418c-9519-11635d62f689
33d365dd-091e-4cd9-b498-1da96172787a	2026-03-01	\N	\N	7277bf7f-0a2f-4363-ad96-cf34e30d4819	COLLECT BUDGIE AT AIRPORT 25 FEB	500.00	t	3	2026	2026-04-21 17:11:22.356171+00	2026-04-21 17:11:22.356171+00	ffd70777-be09-418c-9519-11635d62f689
98206935-5c53-483f-99d4-c54eaaa0e68e	2026-03-01	\N	\N	3d0a295c-1808-4390-bea7-50d9bd3d0faf	PETTY CASH	2000.00	t	3	2026	2026-04-21 17:11:22.356171+00	2026-04-21 17:11:22.356171+00	ffd70777-be09-418c-9519-11635d62f689
4765b859-71ad-45a9-99dc-5d92033ddd27	2026-03-01	bf17ad40-c04f-4438-8456-1bb96ebcecc7	\N	9e205d02-03ec-4b83-a6d5-e31f74d021be	PETTY CASH	1500.00	f	3	2026	2026-04-21 17:11:22.356171+00	2026-04-21 17:11:22.356171+00	ffd70777-be09-418c-9519-11635d62f689
b951ac15-caaa-4a9c-8304-be359735bd20	2026-03-01	b0e3af81-86f7-4e03-8742-a859303b62a6	\N	1b643d33-14d8-43a5-9beb-2dafaf6b401c	PETTY CASH	1500.00	f	3	2026	2026-04-21 17:11:22.356171+00	2026-04-21 17:11:22.356171+00	ffd70777-be09-418c-9519-11635d62f689
2b8e0428-eb72-4a9c-a85b-fbc989fbfe10	2026-03-01	\N	\N	3d0a295c-1808-4390-bea7-50d9bd3d0faf	HANDY ANDY, SUNLIGHT DOVE SOAP GUEST	720.00	t	3	2026	2026-04-21 17:11:22.356171+00	2026-04-21 17:11:22.356171+00	ffd70777-be09-418c-9519-11635d62f689
3115ca2b-02f4-4c58-a99e-4072c8d1c77b	2026-03-01	b0e3af81-86f7-4e03-8742-a859303b62a6	\N	1b643d33-14d8-43a5-9beb-2dafaf6b401c	FIX INTERNET OF CASA CAJU	5000.00	f	3	2026	2026-04-21 17:11:22.356171+00	2026-04-21 17:11:22.356171+00	ffd70777-be09-418c-9519-11635d62f689
1d7eb23b-875e-4b27-8507-a374742e477b	2026-03-01	\N	\N	3d0a295c-1808-4390-bea7-50d9bd3d0faf	Geraldo rubish Landco	2500.00	t	3	2026	2026-04-21 17:11:22.356171+00	2026-04-21 17:11:22.356171+00	ffd70777-be09-418c-9519-11635d62f689
746e2006-c400-408d-ae34-2d0fce40edbd	2026-03-01	\N	\N	dfdd89ae-2650-4bde-ab3e-cdf272e1129f	2 X ROAD CERTIFICATES @ 3000 EACH	6000.00	t	3	2026	2026-04-21 17:11:22.356171+00	2026-04-21 17:11:22.356171+00	ffd70777-be09-418c-9519-11635d62f689
e06e4aff-f0cb-46c1-9280-5bf633db33b3	2026-03-01	b0e3af81-86f7-4e03-8742-a859303b62a6	\N	1b643d33-14d8-43a5-9beb-2dafaf6b401c	2 X ROAD CERTIFICATES @ 3000 EACH	3000.00	f	3	2026	2026-04-21 17:11:22.356171+00	2026-04-21 17:11:22.356171+00	ffd70777-be09-418c-9519-11635d62f689
0efee69b-6a8f-4ada-a936-4f25e39a4181	2026-03-01	6214c344-b5f9-4d17-b539-e367889ffa9c	\N	dbb4f40d-c363-4c95-9bec-e51a8a17afab	2 X ROAD CERTIFICATES @ 3000 EACH	3000.00	f	3	2026	2026-04-21 17:11:22.356171+00	2026-04-21 17:11:22.356171+00	ffd70777-be09-418c-9519-11635d62f689
91f963c8-f14b-4e8a-bc65-401b23a579e4	2026-03-01	\N	\N	7277bf7f-0a2f-4363-ad96-cf34e30d4819	FOOD WORKERS	21000.00	t	3	2026	2026-04-21 17:11:22.356171+00	2026-04-21 17:11:22.356171+00	ffd70777-be09-418c-9519-11635d62f689
e0d8c20d-9065-4e54-8ce3-d262d686410e	2026-01-06	\N	\N	fe7ecebd-073a-4d4c-9bc7-1a8d3112b93d	PAINT STEEL ??? GENERAL MAINENANCE	1420.24	t	1	2026	2026-04-21 17:11:01.163481+00	2026-04-21 17:11:01.163481+00	c50729ec-109b-4981-b0ce-048a2991afe5
9b27825c-e062-456c-9c00-6c1af912fc4c	2026-01-11	\N	\N	ded401ee-a44a-429f-8847-507555d690e9	ELECTRICITY DECEMBER ??? GAS & ELECTRISITY	77851.16	t	1	2026	2026-04-21 17:11:01.73757+00	2026-04-21 17:11:01.73757+00	903ab038-9096-40de-8b85-b8e88ee7ad90
b50e198d-b193-4a70-a912-8279ff921e5a	2026-01-20	\N	\N	e03b9332-c067-4f05-abb0-ded1930718de	ACCOUNTING FEE JANUARY ??? ACCOUNTING FEE	37385.80	t	1	2026	2026-04-21 17:11:02.306836+00	2026-04-21 17:11:02.306836+00	d52e8430-d0e4-4e5a-8118-6015df6ec0c3
66180d66-f9e8-4d3b-a911-2f0768ac6d81	2026-01-22	\N	\N	8350e17d-9aaf-4477-9889-f23ffd2cf8ea	TRANSFER FEE ??? BANK CHARGES OFFICE EXPENSES	7.00	t	1	2026	2026-04-21 17:11:02.87666+00	2026-04-21 17:11:02.87666+00	8a10746b-08e3-4821-807e-fcd472263cc4
e2713e6e-fcd7-48a9-abbb-948a1c3bbfab	2026-01-23	\N	\N	9b767233-4660-448b-9fd9-bf3f6201873c	SALARIES JANUARY ??? SALARIES & WAGES	174740.00	t	1	2026	2026-04-21 17:11:03.455054+00	2026-04-21 17:11:03.455054+00	51b73b94-6be3-4e8a-8457-0b8482d8dee3
9eaabdca-aca8-4e6a-9115-fabdad837dce	2026-01-23	ea35b0ac-a1c4-4269-ac14-c52e1de9d514	\N	a899ce0c-e15f-4843-84da-66be66bffca2	SALARIES JANUARY ??? SALARIES & WAGES	33449.00	f	1	2026	2026-04-21 17:11:03.455054+00	2026-04-21 17:11:03.455054+00	51b73b94-6be3-4e8a-8457-0b8482d8dee3
e90d6551-160f-4b77-9802-74ec05dc9df3	2026-01-23	bf17ad40-c04f-4438-8456-1bb96ebcecc7	\N	9e205d02-03ec-4b83-a6d5-e31f74d021be	SALARIES JANUARY ??? SALARIES & WAGES	58534.00	f	1	2026	2026-04-21 17:11:03.455054+00	2026-04-21 17:11:03.455054+00	51b73b94-6be3-4e8a-8457-0b8482d8dee3
8a9ec9f7-7aa8-4964-9582-420f7b4dcb3f	2026-01-23	b0e3af81-86f7-4e03-8742-a859303b62a6	\N	1b643d33-14d8-43a5-9beb-2dafaf6b401c	SALARIES JANUARY ??? SALARIES & WAGES	36625.00	f	1	2026	2026-04-21 17:11:03.455054+00	2026-04-21 17:11:03.455054+00	51b73b94-6be3-4e8a-8457-0b8482d8dee3
9a3b058a-3643-4682-a15b-0af5aeeef2a4	2026-01-23	6214c344-b5f9-4d17-b539-e367889ffa9c	\N	dbb4f40d-c363-4c95-9bec-e51a8a17afab	SALARIES JANUARY ??? SALARIES & WAGES	43125.00	f	1	2026	2026-04-21 17:11:03.455054+00	2026-04-21 17:11:03.455054+00	51b73b94-6be3-4e8a-8457-0b8482d8dee3
6b70970e-92f8-45bb-b56b-2d60dacf9b55	2026-01-26	\N	\N	9b767233-4660-448b-9fd9-bf3f6201873c	INSS ??? SALARIES$ WAGES	6989.60	t	1	2026	2026-04-21 17:11:04.068222+00	2026-04-21 17:11:04.068222+00	43b5c163-357c-4eaf-ab87-1f00105aff62
075e1e86-aec7-44e2-a67a-b7d436576a44	2026-01-26	ea35b0ac-a1c4-4269-ac14-c52e1de9d514	\N	a899ce0c-e15f-4843-84da-66be66bffca2	INSS ??? SALARIES$ WAGES	1337.96	f	1	2026	2026-04-21 17:11:04.068222+00	2026-04-21 17:11:04.068222+00	43b5c163-357c-4eaf-ab87-1f00105aff62
39f04521-6f97-4c1f-9828-603c1f67dc61	2026-01-26	bf17ad40-c04f-4438-8456-1bb96ebcecc7	\N	9e205d02-03ec-4b83-a6d5-e31f74d021be	INSS ??? SALARIES$ WAGES	2341.36	f	1	2026	2026-04-21 17:11:04.068222+00	2026-04-21 17:11:04.068222+00	43b5c163-357c-4eaf-ab87-1f00105aff62
65966a36-eab9-46df-8310-5524ac779158	2026-01-26	b0e3af81-86f7-4e03-8742-a859303b62a6	\N	1b643d33-14d8-43a5-9beb-2dafaf6b401c	INSS ??? SALARIES$ WAGES	1465.00	f	1	2026	2026-04-21 17:11:04.068222+00	2026-04-21 17:11:04.068222+00	43b5c163-357c-4eaf-ab87-1f00105aff62
6ac86470-7cac-4030-94cc-03b239be3876	2026-01-26	6214c344-b5f9-4d17-b539-e367889ffa9c	\N	dbb4f40d-c363-4c95-9bec-e51a8a17afab	INSS ??? SALARIES$ WAGES	1725.00	f	1	2026	2026-04-21 17:11:04.068222+00	2026-04-21 17:11:04.068222+00	43b5c163-357c-4eaf-ab87-1f00105aff62
e0ca3a27-ce12-4893-b3a2-1aa4f9834b23	2026-01-29	\N	\N	8350e17d-9aaf-4477-9889-f23ffd2cf8ea	TRANSFER FEE ??? BANKCHARGES OFFICE EXPENSES	7.00	t	1	2026	2026-04-21 17:11:04.645314+00	2026-04-21 17:11:04.645314+00	deceee25-3803-4fca-a562-0d240cfa77c9
1ad79278-bb14-4fce-ba83-750c276079d5	2026-01-06	\N	\N	8350e17d-9aaf-4477-9889-f23ffd2cf8ea	DOCUMENTS TO MAPUTO ??? OFFICE & BANK CHARGES	575.00	t	1	2026	2026-04-21 17:11:05.209277+00	2026-04-21 17:11:05.209277+00	28f1a09f-fecf-48ba-b1f6-939df1708942
4ece17af-558b-4eb7-b15a-6f0d6db900a5	2026-01-22	\N	\N	cb6468ec-0bb8-48e6-95fe-14570f93873f	TRANSFER FROM CHEQUE ACCOUNT ??? SUSPENCE	-10000.00	t	1	2026	2026-04-21 17:11:05.791855+00	2026-04-21 17:11:05.791855+00	7b2765a3-4712-4cec-a269-5ca9d3f57d5a
46cb888b-7ae5-4859-b738-232905425634	2026-01-23	b0e3af81-86f7-4e03-8742-a859303b62a6	\N	1b643d33-14d8-43a5-9beb-2dafaf6b401c	STEEL FOR SECURITY DOOR ??? NEW BUILDING	10208.00	f	1	2026	2026-04-21 17:11:06.412682+00	2026-04-21 17:11:06.412682+00	e202902a-cc37-4098-9907-0d24efd1c24c
2018558d-0156-4098-a3d0-5d51bac0b2d4	2026-01-03	\N	\N	9f670eb3-575e-4e33-ac37-5871a9a1f16e	EUZEBIO ??? MONEY FOR OPERATION	3000.00	t	1	2026	2026-04-21 17:11:07.002596+00	2026-04-21 17:11:07.002596+00	e6e26b0e-f7a7-4236-8251-166c368d9ab6
44c2c3bb-d854-4e87-adb5-24bb5aefde34	2026-01-30	\N	\N	7277bf7f-0a2f-4363-ad96-cf34e30d4819	WELDER ??? RAYMONDO FOR ACCOMMODATION 9 DAY @1500	9000.00	t	1	2026	2026-04-21 17:11:07.560444+00	2026-04-21 17:11:07.560444+00	d188ef75-2204-43e0-878a-bb6f0d01add1
e9b5e98b-e211-41d5-81ca-aa0bcfe2b54f	2026-01-31	\N	\N	9b767233-4660-448b-9fd9-bf3f6201873c	BEBE ??? BEBE LEAVE ONE WEEK DOUG	21440.00	t	1	2026	2026-04-21 17:11:08.1289+00	2026-04-21 17:11:08.1289+00	3090a957-25f8-4b24-a2c4-6bc505154216
4a4e8f2a-7435-4d4a-b5ab-18567153329e	2026-02-11	\N	\N	3d0a295c-1808-4390-bea7-50d9bd3d0faf	SUNLIGHT ??? HOUSE KEEPING	570.00	t	2	2026	2026-04-21 17:11:13.901638+00	2026-04-21 17:11:13.901638+00	d0af4c12-13e7-48f4-98f8-ed5aa5ed8bb9
60536919-d5e4-4c21-b836-b69b6c8716ab	2026-02-11	\N	\N	cd3a4860-e203-4611-8359-dd41f7e7f89b	TAX RADIO LICENSE ??? TAX RADIO LICENSE	1296.00	t	2	2026	2026-04-21 17:11:14.462756+00	2026-04-21 17:11:14.462756+00	c6ef3c34-26b4-4379-a979-15bf0f48df71
592ff7d0-19af-4efb-8dbe-6b4b14cf9eef	2026-03-05	\N	\N	8350e17d-9aaf-4477-9889-f23ffd2cf8ea	BANK CHARGES ??? BANK CHARGES	7.00	t	3	2026	2026-04-21 17:11:15.725842+00	2026-04-21 17:11:15.725842+00	060ee2e9-e3e4-4a5a-a517-472f03358b89
76b2b2f1-55e1-4dac-b63b-48e5cc96d739	2026-03-05	\N	\N	8350e17d-9aaf-4477-9889-f23ffd2cf8ea	BANK CHARGES ??? BANK CHARGES	120.00	t	3	2026	2026-04-21 17:11:15.725842+00	2026-04-21 17:11:15.725842+00	060ee2e9-e3e4-4a5a-a517-472f03358b89
7de014b4-d4ea-4bba-b511-73015060ec34	2026-03-09	\N	\N	3d0a295c-1808-4390-bea7-50d9bd3d0faf	TOILET PAPER ??? HOUSE KEEPING	5245.00	t	3	2026	2026-04-21 17:11:16.294033+00	2026-04-21 17:11:16.294033+00	d6073f74-fbdf-401c-ba06-811e27b70b91
5d8f75c5-3acc-4cd1-840a-11fd554af181	2026-03-16	\N	\N	8d1dbf26-84f1-494d-bd35-562efef6eb77	CHLOOR ??? SWIMMING POOL CHEMICALS	8710.00	t	3	2026	2026-04-21 17:11:16.866779+00	2026-04-21 17:11:16.866779+00	cad757fa-1fbf-4f44-b1b8-4eed2323eace
0b4e55b0-a047-4b3d-bd29-a8713578317a	2026-03-18	\N	\N	e03b9332-c067-4f05-abb0-ded1930718de	ACCOUNTING ??? ADMIN AND ACCOUNTING	37386.00	t	3	2026	2026-04-21 17:11:17.41527+00	2026-04-21 17:11:17.41527+00	d0d84e82-3b1d-4736-8314-c2146d304b1e
f7c6b46d-c06b-4e31-8ec9-d184a9f930b4	2026-03-19	\N	\N	fe7ecebd-073a-4d4c-9bc7-1a8d3112b93d	BALDE PARA CONSTRUTOR ??? GENERAL EXPENSES	788.00	t	3	2026	2026-04-21 17:11:17.982326+00	2026-04-21 17:11:17.982326+00	12b7484a-9f99-4ef7-99b5-52568b17bd51
81e71baf-455c-4557-9d0d-fdfd38407f39	2026-03-19	b0e3af81-86f7-4e03-8742-a859303b62a6	\N	1b643d33-14d8-43a5-9beb-2dafaf6b401c	SEALER H3 ??? GENERAL EXPENSES	5688.00	f	3	2026	2026-04-21 17:11:18.55829+00	2026-04-21 17:11:18.55829+00	6a995698-36ae-4f74-b00e-dc91e3a13b5f
a837004c-4827-4207-8aaa-35eadfe500d8	2026-03-25	\N	\N	9b767233-4660-448b-9fd9-bf3f6201873c	SALARY MARCH ??? SALARIES & WAGES	164821.00	t	3	2026	2026-04-21 17:11:19.15413+00	2026-04-21 17:11:19.15413+00	387d60f6-d031-4ab0-b420-cc1ba73bc5a8
5fc3645d-dd4b-4160-8cf6-a2e3b45bf220	2026-03-25	ea35b0ac-a1c4-4269-ac14-c52e1de9d514	\N	a899ce0c-e15f-4843-84da-66be66bffca2	SALARY MARCH ??? SALARIES & WAGES	34870.88	f	3	2026	2026-04-21 17:11:19.15413+00	2026-04-21 17:11:19.15413+00	387d60f6-d031-4ab0-b420-cc1ba73bc5a8
81f3db58-18d5-422d-9a0c-148b482ce56e	2026-03-25	bf17ad40-c04f-4438-8456-1bb96ebcecc7	\N	9e205d02-03ec-4b83-a6d5-e31f74d021be	SALARY MARCH ??? SALARIES & WAGES	58534.00	f	3	2026	2026-04-21 17:11:19.15413+00	2026-04-21 17:11:19.15413+00	387d60f6-d031-4ab0-b420-cc1ba73bc5a8
6cd93d19-2e4c-4e87-9308-72f8779b4bed	2026-03-25	b0e3af81-86f7-4e03-8742-a859303b62a6	\N	1b643d33-14d8-43a5-9beb-2dafaf6b401c	SALARY MARCH ??? SALARIES & WAGES	36625.00	f	3	2026	2026-04-21 17:11:19.15413+00	2026-04-21 17:11:19.15413+00	387d60f6-d031-4ab0-b420-cc1ba73bc5a8
1650074e-edcb-49d5-941a-cfe022a436c0	2026-03-25	6214c344-b5f9-4d17-b539-e367889ffa9c	\N	dbb4f40d-c363-4c95-9bec-e51a8a17afab	SALARY MARCH ??? SALARIES & WAGES	43125.00	f	3	2026	2026-04-21 17:11:19.15413+00	2026-04-21 17:11:19.15413+00	387d60f6-d031-4ab0-b420-cc1ba73bc5a8
a7f22a90-a363-48f3-b402-71acc3e06b5b	2026-03-26	\N	\N	fe7ecebd-073a-4d4c-9bc7-1a8d3112b93d	LIGHTS OUTSIDE ??? GENERAL MAITENANCE	1440.00	t	3	2026	2026-04-21 17:11:19.709871+00	2026-04-21 17:11:19.709871+00	65a1e181-cd13-4ab6-9f4a-99badc3afa6e
619a3908-969b-4198-8f99-24d6e50fae4d	2026-03-27	\N	\N	dfdd89ae-2650-4bde-ab3e-cdf272e1129f	TAE ??? LAND TAX	10300.00	t	3	2026	2026-04-21 17:11:20.291653+00	2026-04-21 17:11:20.291653+00	d2b9f3f8-ea34-4825-8ec8-3559a8ecf194
85ba701c-29d8-42fb-aef0-e0b73fe9322e	2026-03-30	\N	\N	a26e6c21-d0ec-4dad-8eea-b209b4bc5cd7	DIESEL TOYOTA AKL491MP ??? MOTOR VEHICLES EXPENSES	5385.02	t	3	2026	2026-04-21 17:11:20.856714+00	2026-04-21 17:11:20.856714+00	f1655b41-b117-4a2a-b1ff-aabaf33aaa3d
6f09e3ec-c50a-4a7a-a5a9-38ea9c04d18f	2026-03-30	\N	\N	cd3a4860-e203-4611-8359-dd41f7e7f89b	INSURANCE VEHICLES ??? INSURANCE	277172.71	t	3	2026	2026-04-21 17:11:21.422974+00	2026-04-21 17:11:21.422974+00	f856d264-214f-4fd0-9d02-86c40199bdb0
33e82138-38ed-4ea3-bc1c-46d8399de44a	2026-03-31	\N	\N	ded401ee-a44a-429f-8847-507555d690e9	GAS FEBRUARY ??? GAS & ELECTRISITY	3800.61	t	3	2026	2026-04-21 17:11:21.969794+00	2026-04-21 17:11:21.969794+00	1d69d281-e4f4-40ba-8d74-63a26b1ed986
9459a6a7-e5cd-433a-a316-2686c8acbe2a	2026-01-11	\N	\N	8350e17d-9aaf-4477-9889-f23ffd2cf8ea	TRANSFER FEE ??? BANKCHARGES OFFICE EXPENSES	7.00	t	1	2026	2026-04-21 17:11:01.354443+00	2026-04-21 17:11:01.354443+00	7e05dad7-7a50-46ba-8719-edf0779184ca
a6c5f36d-e04b-40a6-a151-8fdd95e9acd1	2026-01-11	\N	\N	8350e17d-9aaf-4477-9889-f23ffd2cf8ea	TRANSFER FEE ??? BANKCHARGES OFFICE EXPENSES	7.00	t	1	2026	2026-04-21 17:11:01.354443+00	2026-04-21 17:11:01.354443+00	7e05dad7-7a50-46ba-8719-edf0779184ca
9c7f41ca-45fa-425b-8ef2-e251f5ffc16e	2026-01-11	\N	\N	8350e17d-9aaf-4477-9889-f23ffd2cf8ea	TRANSFER FEE ??? BANKCHARGES OFFICE EXPENSES	7.00	t	1	2026	2026-04-21 17:11:01.354443+00	2026-04-21 17:11:01.354443+00	7e05dad7-7a50-46ba-8719-edf0779184ca
41a38956-ac5d-474f-a1bb-8b180e3a1a58	2026-01-12	\N	\N	8350e17d-9aaf-4477-9889-f23ffd2cf8ea	TRANSFER FEE ??? BANKCHARGES OFFICE EXPENSES	7.00	t	1	2026	2026-04-21 17:11:01.927501+00	2026-04-21 17:11:01.927501+00	b39b2d3a-6860-4c6a-a12e-f7263effc15b
7b2c4023-e336-4f4a-a8c6-af4e03e8813b	2026-01-20	\N	\N	8350e17d-9aaf-4477-9889-f23ffd2cf8ea	TRANSFER FEE ??? BANK CHARGES OFFICE EXPENSES	7.00	t	1	2026	2026-04-21 17:11:02.499785+00	2026-04-21 17:11:02.499785+00	7a4e4cc8-2e5a-4d92-9de4-f56c2038cef6
8b5009e8-844a-4cf6-b59f-020763cf1a97	2026-01-23	\N	\N	fe7ecebd-073a-4d4c-9bc7-1a8d3112b93d	COTOVELO PVC ??? GENERAL MAITENANCE	1037.39	t	1	2026	2026-04-21 17:11:03.077288+00	2026-04-21 17:11:03.077288+00	fa272459-f525-49fb-927e-859f21f5951e
f0150879-dbf4-443f-9aab-03fe896d610a	2026-01-23	\N	\N	8350e17d-9aaf-4477-9889-f23ffd2cf8ea	BANK CHARGES ??? OFFICE EXPENSES	257.00	t	1	2026	2026-04-21 17:11:03.650022+00	2026-04-21 17:11:03.650022+00	a1e4bf57-2b0a-484d-b572-f68fb58c8557
18d13ae7-8200-4810-9620-08d3eae53d38	2026-01-28	\N	\N	fe7ecebd-073a-4d4c-9bc7-1a8d3112b93d	DILUENTE ESMALTE QD 750ML ??? GENERAL MAINTENANCE	524.00	t	1	2026	2026-04-21 17:11:04.258963+00	2026-04-21 17:11:04.258963+00	d47bdc0c-eb31-40fb-9431-68539d099079
0f33ece0-b052-46d2-9f95-0ef320d29b7b	2026-01-29	\N	\N	fe7ecebd-073a-4d4c-9bc7-1a8d3112b93d	LESCO - CX PROVA DE AGUA 4X4 ??? GENERAL MAINTENANCE	2025.00	t	1	2026	2026-04-21 17:11:04.835615+00	2026-04-21 17:11:04.835615+00	e64b14a4-1449-4484-8256-c7fdfdb5f382
87595400-a6a6-4433-8a52-abcd11127a25	2026-01-06	\N	\N	fe7ecebd-073a-4d4c-9bc7-1a8d3112b93d	BEBE ??? PETTY CSH	10000.00	t	1	2026	2026-04-21 17:11:05.402077+00	2026-04-21 17:11:05.402077+00	c0c4721b-387c-408c-b60a-c10ab2559e37
e7da19d1-e1d6-47e7-a6e8-eb13d3b50de8	2026-01-23	\N	\N	cb6468ec-0bb8-48e6-95fe-14570f93873f	TRANSFER TO PRE-PAID ??? SUSPENSE	88.00	t	1	2026	2026-04-21 17:11:05.993825+00	2026-04-21 17:11:05.993825+00	4a8c839e-b13a-4623-be10-ad485968d37f
da96816f-5932-4368-aa11-5751fc1a6e13	2026-01-23	\N	\N	cb6468ec-0bb8-48e6-95fe-14570f93873f	TRANSFER ??? SUSPENSE	-88.00	t	1	2026	2026-04-21 17:11:06.597089+00	2026-04-21 17:11:06.597089+00	2bdc2163-568c-4a39-89a0-84648a0f29e4
c5739241-6c20-4238-893b-9e9508ddf757	2026-01-12	\N	\N	7277bf7f-0a2f-4363-ad96-cf34e30d4819	MATIAS ??? CASUAL GUARD FOR JANUARY	7000.00	t	1	2026	2026-04-21 17:11:07.188403+00	2026-04-21 17:11:07.188403+00	109e24b2-2122-42ec-8e8c-eb57bef982fd
e2eedd16-2e2e-445e-8bd2-f09d0c9c2238	2026-01-31	\N	\N	9b767233-4660-448b-9fd9-bf3f6201873c	CHRIS ??? CHRIS MONTHLY JANUARY	35000.00	t	1	2026	2026-04-21 17:11:07.738911+00	2026-04-21 17:11:07.738911+00	c50dde20-2d91-4f8e-b2b2-582bf222eb2c
0e3f2041-e977-4323-959d-9502bfbf8dfd	2026-03-09	\N	\N	fe7ecebd-073a-4d4c-9bc7-1a8d3112b93d	VARNISH ??? GENERAL EXPENSES	3328.00	t	3	2026	2026-04-21 17:11:15.915074+00	2026-04-21 17:11:15.915074+00	1c425d00-f1cf-4d3a-8f85-654509498fa1
0e67010d-941f-4069-bfa0-5b0f0a9511c9	2026-03-09	\N	\N	8350e17d-9aaf-4477-9889-f23ffd2cf8ea	BANK CHARGES ??? BANK CHARGES SINDICATO BEB	7.00	t	3	2026	2026-04-21 17:11:16.504021+00	2026-04-21 17:11:16.504021+00	af28dd0c-0020-40df-8d1d-9fae46b401e7
5a3be273-0197-4589-8a3c-28c5bf699d69	2026-03-16	\N	\N	3d0a295c-1808-4390-bea7-50d9bd3d0faf	PLASTIC DE LUXO ??? HOUSE KEEPING	1290.00	t	3	2026	2026-04-21 17:11:17.045013+00	2026-04-21 17:11:17.045013+00	1d137822-619d-440e-bac3-3e5a7edbecaa
2863fa71-29e0-42b6-b22c-eb02b7369340	2026-03-18	\N	\N	8350e17d-9aaf-4477-9889-f23ffd2cf8ea	BANK CHARGES ??? BANK CHARGES	7.00	t	3	2026	2026-04-21 17:11:17.593213+00	2026-04-21 17:11:17.593213+00	2383350e-7a15-4b49-b9ac-ab7c33b9f49a
68261bf7-14a7-4c60-8996-a098de7424ca	2026-03-19	\N	\N	3d0a295c-1808-4390-bea7-50d9bd3d0faf	CLEANING MATERIAL ??? HOUSE KEEPING	3330.00	t	3	2026	2026-04-21 17:11:18.174549+00	2026-04-21 17:11:18.174549+00	e75a86ee-42c9-466e-9978-bdf0f1bc8ff9
1ca6d45b-5006-4e2b-b494-5c983115590c	2026-03-19	\N	\N	8350e17d-9aaf-4477-9889-f23ffd2cf8ea	BANK CHARGES ??? BANK CHARGES	7.00	t	3	2026	2026-04-21 17:11:18.769751+00	2026-04-21 17:11:18.769751+00	6665feb8-ec43-41e8-a8e6-479fa51c33f3
2d97a74d-6b45-4b31-b037-e8cd8440ebe0	2026-03-25	\N	\N	8350e17d-9aaf-4477-9889-f23ffd2cf8ea	BANK CHARGES ??? BANK CHARGES	257.00	t	3	2026	2026-04-21 17:11:19.335904+00	2026-04-21 17:11:19.335904+00	ef789ae0-f38c-4012-bff0-e6b7ce7bc81c
d81f0e99-1648-413f-886b-8e186c3182db	2026-03-27	\N	\N	3d0a295c-1808-4390-bea7-50d9bd3d0faf	SOAP, JAVEL ??? HOUSE KEEPING	5430.00	t	3	2026	2026-04-21 17:11:19.898707+00	2026-04-21 17:11:19.898707+00	2128c23d-cd0b-479e-b945-9ab84988d0c3
e4853c72-f847-4ebb-a385-ad948ce4e9ef	2026-03-27	\N	\N	ded401ee-a44a-429f-8847-507555d690e9	DIESEL GENERATOR ??? ELECTRISITY	12280.00	t	3	2026	2026-04-21 17:11:20.48064+00	2026-04-21 17:11:20.48064+00	85af5791-fe1b-4276-b734-2e5e00a67354
3bfc70e0-e4e6-4d50-a010-502b70b39b9d	2026-03-27	6214c344-b5f9-4d17-b539-e367889ffa9c	\N	dbb4f40d-c363-4c95-9bec-e51a8a17afab	DIESEL PRADO HOUSE 4 ??? MOTOR VEHICLES EXPENSES	3292.74	f	3	2026	2026-04-21 17:11:21.042991+00	2026-04-21 17:11:21.042991+00	4385d149-f06f-492d-ad2e-9584e91ccd73
36b3a38a-b30b-460e-9e12-cad3be26d3f7	2026-03-30	\N	\N	8350e17d-9aaf-4477-9889-f23ffd2cf8ea	BANK CHARGES ??? BANK CHARGES	120.00	t	3	2026	2026-04-21 17:11:21.604274+00	2026-04-21 17:11:21.604274+00	41e068d8-5eed-4d36-8391-b3871ce6740d
22efbbb8-3e0a-44d5-843b-c5ad5e2bd097	2026-03-30	\N	\N	8350e17d-9aaf-4477-9889-f23ffd2cf8ea	BANK CHARGES ??? BANK CHARGES	120.00	t	3	2026	2026-04-21 17:11:21.604274+00	2026-04-21 17:11:21.604274+00	41e068d8-5eed-4d36-8391-b3871ce6740d
fda146c5-fff2-4625-bd17-71ccef07e10b	2026-03-31	\N	\N	fe7ecebd-073a-4d4c-9bc7-1a8d3112b93d	GLOBES ??? GENERAL MAINTRENANCE	1235.00	t	3	2026	2026-04-21 17:11:22.152775+00	2026-04-21 17:11:22.152775+00	8c3e989f-1c39-4ff4-8d05-9aa189577c2e
07268917-e87a-439c-be6c-c2bb34b1fb76	2026-03-01	\N	\N	7277bf7f-0a2f-4363-ad96-cf34e30d4819	CASUALS GARDEN ABLUTION PLUS PLANTS	1800.00	t	3	2026	2026-04-21 17:11:22.356171+00	2026-04-21 17:11:22.356171+00	ffd70777-be09-418c-9519-11635d62f689
46eb71e8-53ca-4be3-8bdb-bd7b086940df	2026-03-01	\N	\N	fe7ecebd-073a-4d4c-9bc7-1a8d3112b93d	PAVERS ABLUTION BLOCK	1200.00	t	3	2026	2026-04-21 17:11:22.356171+00	2026-04-21 17:11:22.356171+00	ffd70777-be09-418c-9519-11635d62f689
83fbe600-9b6c-489c-a59d-9d446aa3d13a	2026-03-01	bf17ad40-c04f-4438-8456-1bb96ebcecc7	\N	9e205d02-03ec-4b83-a6d5-e31f74d021be	INSPECTION FEE MARINTINE BOATS	3600.00	f	3	2026	2026-04-21 17:11:22.356171+00	2026-04-21 17:11:22.356171+00	ffd70777-be09-418c-9519-11635d62f689
dbd483cd-c313-4d3b-a580-8641c1aab202	2026-03-01	b0e3af81-86f7-4e03-8742-a859303b62a6	\N	1b643d33-14d8-43a5-9beb-2dafaf6b401c	INSPECTION FEE MARINTINE BOATS	3600.00	f	3	2026	2026-04-21 17:11:22.356171+00	2026-04-21 17:11:22.356171+00	ffd70777-be09-418c-9519-11635d62f689
42b18dcf-7c8e-497d-8d24-bbcdce587190	2026-03-01	\N	\N	a26e6c21-d0ec-4dad-8eea-b209b4bc5cd7	PETROL ALLOWANCE	5000.00	t	3	2026	2026-04-21 17:11:22.356171+00	2026-04-21 17:11:22.356171+00	ffd70777-be09-418c-9519-11635d62f689
f346cc11-b697-4be1-80c6-82cf217c26a2	2026-03-01	\N	\N	9b767233-4660-448b-9fd9-bf3f6201873c	SALARY MARCH	35000.00	t	3	2026	2026-04-21 17:11:22.356171+00	2026-04-21 17:11:22.356171+00	ffd70777-be09-418c-9519-11635d62f689
fc51f64a-d489-429d-8074-3b94e917e53a	2026-02-02	\N	\N	8350e17d-9aaf-4477-9889-f23ffd2cf8ea	Bank Charges ??? Office expenses	7.00	t	2	2026	2026-04-21 17:11:09.10899+00	2026-04-21 17:11:09.10899+00	d0f6d152-f45b-479c-afc9-e0323132d94d
5ace7d47-5844-4727-958d-adc22f9304aa	2026-02-02	\N	\N	8350e17d-9aaf-4477-9889-f23ffd2cf8ea	Bank Charges ??? Office expenses	7.00	t	2	2026	2026-04-21 17:11:09.10899+00	2026-04-21 17:11:09.10899+00	d0f6d152-f45b-479c-afc9-e0323132d94d
c0b7b414-5467-4bdc-b41e-cd965b26b989	2026-02-02	\N	\N	8350e17d-9aaf-4477-9889-f23ffd2cf8ea	Bank Charges ??? Office expenses	7.00	t	2	2026	2026-04-21 17:11:09.10899+00	2026-04-21 17:11:09.10899+00	d0f6d152-f45b-479c-afc9-e0323132d94d
2f302b30-57e0-4632-b15a-e7284703fc6e	2026-02-09	\N	\N	8350e17d-9aaf-4477-9889-f23ffd2cf8ea	Bank Charges ??? Office expenses	7.00	t	2	2026	2026-04-21 17:11:09.693952+00	2026-04-21 17:11:09.693952+00	9783cc84-01d0-474b-9ee4-2193695aecbf
821ed5a9-b5ab-4aba-b368-6e9146dcdce4	2026-02-14	\N	\N	a26e6c21-d0ec-4dad-8eea-b209b4bc5cd7	Diesel Generator ??? General Maintenance	4263.00	t	2	2026	2026-04-21 17:11:10.284467+00	2026-04-21 17:11:10.284467+00	eb6436d0-f25f-495c-acb2-de63d825b779
45e0670b-27a2-4275-b7de-cd5405606de0	2026-02-19	\N	\N	e03b9332-c067-4f05-abb0-ded1930718de	Admin Fee ??? Admin Cost	146740.00	t	2	2026	2026-04-21 17:11:10.858542+00	2026-04-21 17:11:10.858542+00	dac6fcb8-6edd-41d0-a49d-d0997b2df260
2823dcc6-c368-464e-9f9f-205106a48bc7	2026-02-23	\N	\N	8350e17d-9aaf-4477-9889-f23ffd2cf8ea	Bank Charges ??? Office expenses	7.00	t	2	2026	2026-04-21 17:11:11.441011+00	2026-04-21 17:11:11.441011+00	77538e9d-ac57-4c74-89e6-52d33b16760b
bd3f08c8-1720-4952-aa7f-0fb0042b156c	2026-02-23	\N	\N	8350e17d-9aaf-4477-9889-f23ffd2cf8ea	Bank Charges ??? Office expenses	120.00	t	2	2026	2026-04-21 17:11:11.441011+00	2026-04-21 17:11:11.441011+00	77538e9d-ac57-4c74-89e6-52d33b16760b
5f7c2aad-593e-4a92-9529-01b7f7ada2bf	2026-02-23	\N	\N	8350e17d-9aaf-4477-9889-f23ffd2cf8ea	Bank Charges ??? Office expenses	7.00	t	2	2026	2026-04-21 17:11:11.441011+00	2026-04-21 17:11:11.441011+00	77538e9d-ac57-4c74-89e6-52d33b16760b
31ca8a1d-bf42-4d3a-b297-562e4ab66a76	2026-02-23	\N	\N	fe7ecebd-073a-4d4c-9bc7-1a8d3112b93d	Revisao de Extintores ??? MAINTENANCE	21558.60	t	2	2026	2026-04-21 17:11:11.994714+00	2026-04-21 17:11:11.994714+00	82e7e135-6ee3-433e-89e1-800d374532e8
61a64e36-60ba-4d2b-9140-dfafd6149d33	2026-02-26	\N	\N	3d0a295c-1808-4390-bea7-50d9bd3d0faf	Cleaning supplies ??? HOUSE KEEPING	755.00	t	2	2026	2026-04-21 17:11:12.577655+00	2026-04-21 17:11:12.577655+00	0973ad26-f24a-491e-9c53-b21a54481841
b3a9cdd9-e6cb-4a5d-9850-5e81166152d8	2026-02-01	\N	\N	9b767233-4660-448b-9fd9-bf3f6201873c	INSS	6762.74	t	2	2026	2026-04-21 17:11:13.135454+00	2026-04-21 17:11:13.135454+00	e917f46d-f352-4cb7-aa48-8badafcb6ec3
3b606181-0c48-4d57-b4c8-57fbd50d6252	2026-02-01	ea35b0ac-a1c4-4269-ac14-c52e1de9d514	\N	a899ce0c-e15f-4843-84da-66be66bffca2	INSS	1404.37	f	2	2026	2026-04-21 17:11:13.135454+00	2026-04-21 17:11:13.135454+00	e917f46d-f352-4cb7-aa48-8badafcb6ec3
1693d8a5-eaaa-467e-9b75-1882f0242278	2026-02-01	bf17ad40-c04f-4438-8456-1bb96ebcecc7	\N	9e205d02-03ec-4b83-a6d5-e31f74d021be	INSS	2608.00	f	2	2026	2026-04-21 17:11:13.135454+00	2026-04-21 17:11:13.135454+00	e917f46d-f352-4cb7-aa48-8badafcb6ec3
b9569723-25be-40a6-888a-aa00eac795cf	2026-02-01	b0e3af81-86f7-4e03-8742-a859303b62a6	\N	1b643d33-14d8-43a5-9beb-2dafaf6b401c	INSS	1548.93	f	2	2026	2026-04-21 17:11:13.135454+00	2026-04-21 17:11:13.135454+00	e917f46d-f352-4cb7-aa48-8badafcb6ec3
5924a763-5ed3-4e79-bc08-48d95c5febfb	2026-02-01	6214c344-b5f9-4d17-b539-e367889ffa9c	\N	dbb4f40d-c363-4c95-9bec-e51a8a17afab	INSS	1725.00	f	2	2026	2026-04-21 17:11:13.135454+00	2026-04-21 17:11:13.135454+00	e917f46d-f352-4cb7-aa48-8badafcb6ec3
49bf5c7a-2961-4a9a-b8d3-efd25295b354	2026-02-01	\N	\N	8350e17d-9aaf-4477-9889-f23ffd2cf8ea	STARLINK FOR FEB	3000.00	t	2	2026	2026-04-21 17:11:13.135454+00	2026-04-21 17:11:13.135454+00	e917f46d-f352-4cb7-aa48-8badafcb6ec3
803d25c7-b0a1-42df-b914-eed274f336ca	2026-02-01	bf17ad40-c04f-4438-8456-1bb96ebcecc7	\N	9e205d02-03ec-4b83-a6d5-e31f74d021be	INACIO AND PEDRO CLEANING BOAT	800.00	f	2	2026	2026-04-21 17:11:13.135454+00	2026-04-21 17:11:13.135454+00	e917f46d-f352-4cb7-aa48-8badafcb6ec3
866be1c6-70d8-4d8f-bb22-4b6a8a7995b6	2026-02-01	b0e3af81-86f7-4e03-8742-a859303b62a6	\N	1b643d33-14d8-43a5-9beb-2dafaf6b401c	BEFORE CYCLONE INACIO, ZITO AND PEDRO	1600.00	f	2	2026	2026-04-21 17:11:13.135454+00	2026-04-21 17:11:13.135454+00	e917f46d-f352-4cb7-aa48-8badafcb6ec3
883015d5-fbc2-4442-9288-cac72e5ebcfd	2026-02-01	\N	\N	a26e6c21-d0ec-4dad-8eea-b209b4bc5cd7	PETROL ALLOWANS JAN AND FEB	10000.00	t	2	2026	2026-04-21 17:11:13.135454+00	2026-04-21 17:11:13.135454+00	e917f46d-f352-4cb7-aa48-8badafcb6ec3
74e06b68-3202-488e-a8f4-d4ee7c7af6f9	2026-02-01	\N	\N	9b767233-4660-448b-9fd9-bf3f6201873c	ANDRISA HALF OF EXPENSES DIRE	109470.00	t	2	2026	2026-04-21 17:11:13.135454+00	2026-04-21 17:11:13.135454+00	e917f46d-f352-4cb7-aa48-8badafcb6ec3
1afd4850-40c2-4abd-b2d8-cafd5b240abd	2026-02-01	\N	\N	7277bf7f-0a2f-4363-ad96-cf34e30d4819	ANDRISA HALF OF EXPENSES DIRE	4.10	t	2	2026	2026-04-21 17:11:13.135454+00	2026-04-21 17:11:13.135454+00	e917f46d-f352-4cb7-aa48-8badafcb6ec3
32072b07-7809-42eb-bc7c-5efe3462df9a	2026-02-01	bf17ad40-c04f-4438-8456-1bb96ebcecc7	\N	9e205d02-03ec-4b83-a6d5-e31f74d021be	SEAPORT CLEANING MATERIAL BOATS	7762.50	f	2	2026	2026-04-21 17:11:13.135454+00	2026-04-21 17:11:13.135454+00	e917f46d-f352-4cb7-aa48-8badafcb6ec3
69a01468-835b-471e-b630-a658c8d7a63a	2026-02-01	b0e3af81-86f7-4e03-8742-a859303b62a6	\N	1b643d33-14d8-43a5-9beb-2dafaf6b401c	SEAPORT CLEANING MATERIAL BOATS	15525.00	f	2	2026	2026-04-21 17:11:13.135454+00	2026-04-21 17:11:13.135454+00	e917f46d-f352-4cb7-aa48-8badafcb6ec3
922a0181-e193-4ffc-88f8-ae1d8199ebe7	2026-02-01	\N	\N	9b767233-4660-448b-9fd9-bf3f6201873c	CHRIS MONTHLY FEE	35000.00	t	2	2026	2026-04-21 17:11:13.135454+00	2026-04-21 17:11:13.135454+00	e917f46d-f352-4cb7-aa48-8badafcb6ec3
8e59aaa0-82ae-4128-b7cc-630a7d555c0f	2026-02-01	\N	\N	7277bf7f-0a2f-4363-ad96-cf34e30d4819	FOOD FOR WORKERS	21000.00	t	2	2026	2026-04-21 17:11:13.135454+00	2026-04-21 17:11:13.135454+00	e917f46d-f352-4cb7-aa48-8badafcb6ec3
30b9f935-e182-490a-8c74-189e89c3ef78	2026-02-11	\N	\N	3d0a295c-1808-4390-bea7-50d9bd3d0faf	WINDO CLEAN ??? HOUSE KEEPING	910.00	t	2	2026	2026-04-21 17:11:13.712485+00	2026-04-21 17:11:13.712485+00	c31b5328-d57c-4be6-855c-7e6cd4c22fef
b5f8e248-cbf9-49f0-af47-9e202eff8b67	2026-02-11	\N	\N	cd3a4860-e203-4611-8359-dd41f7e7f89b	IMPOSTOS VEICULOS ??? TAX  LICENSE	2420.00	t	2	2026	2026-04-21 17:11:14.268613+00	2026-04-21 17:11:14.268613+00	9497feb1-2ab0-4fb0-840d-1384e94a872c
2e5c1d5a-942d-44f6-a1c0-f6ce478d3cfb	2026-02-02	\N	\N	8d1dbf26-84f1-494d-bd35-562efef6eb77	Quimical swimming pools ??? Pool Maintenance	905.00	t	2	2026	2026-04-21 17:11:09.318786+00	2026-04-21 17:11:09.318786+00	c5b911e6-be47-4eef-b087-8adae0c4ec1e
6abb45ce-c9fa-434e-8d42-57a1854f6d04	2026-02-02	\N	\N	8d1dbf26-84f1-494d-bd35-562efef6eb77	Quimical swimming pools ??? Pool Maintenance	1519.60	t	2	2026	2026-04-21 17:11:09.318786+00	2026-04-21 17:11:09.318786+00	c5b911e6-be47-4eef-b087-8adae0c4ec1e
0dbf4dab-63f2-4232-b4ae-1292b2011210	2026-02-10	\N	\N	ded401ee-a44a-429f-8847-507555d690e9	Electrisity ??? Gas& Eletrisity	58424.49	t	2	2026	2026-04-21 17:11:09.901357+00	2026-04-21 17:11:09.901357+00	6db82ac8-55c7-4c02-868b-6935dcac2700
db9ba5f8-b518-4958-a71d-6ba7dbaf79a9	2026-02-18	\N	\N	8350e17d-9aaf-4477-9889-f23ffd2cf8ea	Bank Charges ??? Office expenses	7.00	t	2	2026	2026-04-21 17:11:10.469756+00	2026-04-21 17:11:10.469756+00	b9132dd4-dc69-404f-b1af-0866519b3521
20fbeff3-604f-4627-a6da-89d5a6a34df2	2026-02-18	\N	\N	8350e17d-9aaf-4477-9889-f23ffd2cf8ea	Bank Charges ??? Office expenses	7.00	t	2	2026	2026-04-21 17:11:10.469756+00	2026-04-21 17:11:10.469756+00	b9132dd4-dc69-404f-b1af-0866519b3521
a4ca437f-1e0d-40a5-a848-bd3301566a6d	2026-02-19	\N	\N	8350e17d-9aaf-4477-9889-f23ffd2cf8ea	Bank Charges ??? Office expenses	7.00	t	2	2026	2026-04-21 17:11:11.04737+00	2026-04-21 17:11:11.04737+00	85ba8589-cfaa-4293-a354-cd8ec0bf93eb
ddf83cb7-d898-48a8-915e-348ae11c5748	2026-02-23	6214c344-b5f9-4d17-b539-e367889ffa9c	\N	dbb4f40d-c363-4c95-9bec-e51a8a17afab	House Kepping Towel Duck ??? House Keping	20787.20	f	2	2026	2026-04-21 17:11:11.628028+00	2026-04-21 17:11:11.628028+00	bbdbe6a5-10b9-48e4-822d-336f9cb97c2d
d29558ab-a055-4d00-9920-94858a311a8a	2026-02-25	\N	\N	9b767233-4660-448b-9fd9-bf3f6201873c	Salario Feb ??? SALARIES FEB	169068.42	t	2	2026	2026-04-21 17:11:12.214201+00	2026-04-21 17:11:12.214201+00	6ac3b6be-2f36-4a5e-975e-c8c11ea8ca40
0840748f-7fd6-4e2f-ab99-f72a22e6d5c4	2026-02-25	ea35b0ac-a1c4-4269-ac14-c52e1de9d514	\N	a899ce0c-e15f-4843-84da-66be66bffca2	Salario Feb ??? SALARIES FEB	35109.33	f	2	2026	2026-04-21 17:11:12.214201+00	2026-04-21 17:11:12.214201+00	6ac3b6be-2f36-4a5e-975e-c8c11ea8ca40
0373a270-f7be-46c5-bbcb-b50b54f06f69	2026-02-25	bf17ad40-c04f-4438-8456-1bb96ebcecc7	\N	9e205d02-03ec-4b83-a6d5-e31f74d021be	Salario Feb ??? SALARIES FEB	65199.92	f	2	2026	2026-04-21 17:11:12.214201+00	2026-04-21 17:11:12.214201+00	6ac3b6be-2f36-4a5e-975e-c8c11ea8ca40
45dd4864-54eb-40e7-b9ea-5438c200e7dd	2026-02-25	b0e3af81-86f7-4e03-8742-a859303b62a6	\N	1b643d33-14d8-43a5-9beb-2dafaf6b401c	Salario Feb ??? SALARIES FEB	38723.33	f	2	2026	2026-04-21 17:11:12.214201+00	2026-04-21 17:11:12.214201+00	6ac3b6be-2f36-4a5e-975e-c8c11ea8ca40
d0dff0e1-9965-4c30-868f-ee56cdd5ee34	2026-02-25	6214c344-b5f9-4d17-b539-e367889ffa9c	\N	dbb4f40d-c363-4c95-9bec-e51a8a17afab	Salario Feb ??? SALARIES FEB	43125.00	f	2	2026	2026-04-21 17:11:12.214201+00	2026-04-21 17:11:12.214201+00	6ac3b6be-2f36-4a5e-975e-c8c11ea8ca40
d4d7c7d3-4a08-4838-bfee-04af7ff8a0f2	2026-02-26	\N	\N	fe7ecebd-073a-4d4c-9bc7-1a8d3112b93d	Eletrical material ??? General Maintenance	1465.00	t	2	2026	2026-04-21 17:11:12.76184+00	2026-04-21 17:11:12.76184+00	d4ecc8e5-8576-46ad-b6ff-c0b45208d79e
350626c7-9e47-4823-8196-f217dcaebc27	2026-02-05	\N	\N	8350e17d-9aaf-4477-9889-f23ffd2cf8ea	DOCUMENTS TO MAPUTO ??? OFFICE & BANK CHARGES	495.00	t	2	2026	2026-04-21 17:11:13.316057+00	2026-04-21 17:11:13.316057+00	2b8aa542-5a94-4553-86a4-a7c91fa13798
\.


--
-- Data for Name: import_log; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.import_log (id, filename, file_type, month, year, records_imported, status, imported_by, error_details, created_at) FROM stdin;
\.


--
-- Data for Name: income_transactions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.income_transactions (id, date, property_id, guest_name, description, accommodation_amount_mzn, amount_usd, month, year, created_at, updated_at, journal_entry_id) FROM stdin;
3441bc57-1201-4661-abfa-bc2e3e4d60c8	2026-01-02	b0e3af81-86f7-4e03-8742-a859303b62a6	ALEX	\N	594297.00	9396.00	1	2026	2026-04-13 09:06:45.972972+00	2026-04-13 09:06:45.972972+00	d0049a70-ab5d-4f3e-a36b-72902dceb611
813a09c4-8af9-41bc-8ab3-cc3420fe835b	2026-01-03	ea35b0ac-a1c4-4269-ac14-c52e1de9d514	ALEX	\N	958350.00	15151.78	1	2026	2026-04-13 09:06:45.972972+00	2026-04-13 09:06:45.972972+00	47a8c121-81a6-4392-bdc8-efa8a8e8431a
1d9d385f-ed79-4077-a5db-341c12ed022b	2026-01-04	b0e3af81-86f7-4e03-8742-a859303b62a6	ALEX	\N	751171.00	11876.22	1	2026	2026-04-13 09:06:45.972972+00	2026-04-13 09:06:45.972972+00	c3ed77e5-c385-4752-9e87-d7874f646b1b
a1f9cb9f-6a81-4a8e-a42c-2220d6340850	2026-01-09	bf17ad40-c04f-4438-8456-1bb96ebcecc7	WARREN STEAD DEP BANK	\N	948750.00	15000.00	1	2026	2026-04-13 09:06:45.972972+00	2026-04-13 09:06:45.972972+00	399f9d9a-6f51-45f0-ac5f-aca9c3a593bc
3dae6133-5ded-4d21-9d3c-eb1481682f49	2026-01-10	bf17ad40-c04f-4438-8456-1bb96ebcecc7	WARREN STEAD	\N	941920.00	14892.02	1	2026	2026-04-13 09:06:45.972972+00	2026-04-13 09:06:45.972972+00	0d348fd1-a4f7-4258-aa0e-97c1d65cedc0
1069f22a-2c07-4a0b-812c-add966df5081	2026-01-11	ea35b0ac-a1c4-4269-ac14-c52e1de9d514	CREDIT IVA H1 - LESLEY X 6 NIGHTS	\N	68000.00	1000.00	1	2026	2026-04-13 09:06:45.972972+00	2026-04-13 09:06:45.972972+00	2795d965-504b-418a-9273-faad8e274d4a
eba45d1f-c23d-42f0-ae7c-f93787fc4a83	2026-01-12	b0e3af81-86f7-4e03-8742-a859303b62a6	ALEX	\N	638900.00	10101.19	1	2026	2026-04-13 09:06:45.972972+00	2026-04-13 09:06:45.972972+00	01a5e615-ac14-4ec5-b24d-cd23054e4430
5da3732e-28aa-45b6-a283-c8ac855bf591	2026-01-16	bf17ad40-c04f-4438-8456-1bb96ebcecc7	BRENDON	\N	55200.00	800.00	1	2026	2026-04-13 09:06:45.972972+00	2026-04-13 09:06:45.972972+00	875ececf-e730-434f-951a-a6eb2ac9cbe9
6296370c-b299-4c47-b5bd-c03e1bf622a9	2026-01-16	ea35b0ac-a1c4-4269-ac14-c52e1de9d514	TAFY	\N	812375.00	12125.00	1	2026	2026-04-13 09:06:45.972972+00	2026-04-13 09:06:45.972972+00	b6539d2b-f989-45cb-a1e7-4b55fffbe86a
96bba594-dfc3-4654-91f4-6d134c5dadde	2026-01-16	ea35b0ac-a1c4-4269-ac14-c52e1de9d514	TAFY RECEIVED FROM ROBIN	\N	465650.00	6950.00	1	2026	2026-04-13 09:06:45.972972+00	2026-04-13 09:06:45.972972+00	aed6d853-a889-4cf7-80db-ddc5a61dae07
ac54c013-7df0-4e4c-b19a-13d889415553	2026-01-16	bf17ad40-c04f-4438-8456-1bb96ebcecc7	WARREN STEAD	\N	958350.00	15151.78	1	2026	2026-04-13 09:06:45.972972+00	2026-04-13 09:06:45.972972+00	a61a796e-0f7e-4d46-b3b8-8f55d0c10bcd
efa13fc6-51e7-4159-8092-5dfe792789b5	2026-01-16	bf17ad40-c04f-4438-8456-1bb96ebcecc7	BRENDON 7 DAYS @80	\N	37520.00	560.00	1	2026	2026-04-13 09:06:45.972972+00	2026-04-13 09:06:45.972972+00	c1276af4-69fc-4788-beb2-2b1f76b2aedd
f30da5de-4f59-4ca6-aa69-f846cc4eea72	2026-01-16	ea35b0ac-a1c4-4269-ac14-c52e1de9d514	TAFY RECEIVED FROM ALEX	\N	335000.00	5000.00	1	2026	2026-04-13 09:06:45.972972+00	2026-04-13 09:06:45.972972+00	59cb3ec9-4125-41b2-81bd-eb4d43294a48
ace94d66-9bf5-4589-956a-396e4da8d5e6	2026-01-17	6214c344-b5f9-4d17-b539-e367889ffa9c	ARON ACCOMMODATION IN H4	\N	98490.00	1470.00	1	2026	2026-04-13 09:06:45.972972+00	2026-04-13 09:06:45.972972+00	805513af-ac06-4c94-9a4c-1ecfa3d18efa
1a4536c7-23a9-4ee5-9314-a570c2eaff6b	2026-01-18	b0e3af81-86f7-4e03-8742-a859303b62a6	ALEX	\N	948750.00	15000.00	1	2026	2026-04-13 09:06:45.972972+00	2026-04-13 09:06:45.972972+00	cb7106c2-327d-4802-9972-afe97b18cfed
234ed239-5b62-41a3-abd2-1400a195e4df	2026-01-19	bf17ad40-c04f-4438-8456-1bb96ebcecc7	BRENDON	\N	22400.00	320.00	1	2026	2026-04-13 09:06:45.972972+00	2026-04-13 09:06:45.972972+00	e17bb3a0-f9db-42b2-bebe-d42437a6c077
41e28b7a-9c7e-4dd6-898d-6ea9df96c643	2026-01-20	6214c344-b5f9-4d17-b539-e367889ffa9c	WARREN COHEN INVESTMENT	\N	948750.00	15000.00	1	2026	2026-04-13 09:06:45.972972+00	2026-04-13 09:06:45.972972+00	ee6564f1-0260-45a2-a3c7-1b143b634770
7e2a35d2-71e6-46ac-8f06-d56d12911c46	2026-01-21	b0e3af81-86f7-4e03-8742-a859303b62a6	WARREN STEAD	\N	958350.00	15151.78	1	2026	2026-04-13 09:06:45.972972+00	2026-04-13 09:06:45.972972+00	d6af991f-69c5-445d-a129-560295d4317c
4592d261-0399-49c6-b5f2-1bae4157cbab	2026-01-22	6214c344-b5f9-4d17-b539-e367889ffa9c	ALAIN WARREN	\N	60720.00	880.00	1	2026	2026-04-13 09:06:45.972972+00	2026-04-13 09:06:45.972972+00	0eb252c8-5395-43c5-a2d4-90d9b414de6e
07180c22-6e02-4743-aa3d-e1fa46c9b694	2026-01-23	b0e3af81-86f7-4e03-8742-a859303b62a6	ALEX TRANSFER TO MONIQUE	\N	222300.00	3000.00	1	2026	2026-04-13 09:06:45.972972+00	2026-04-13 09:06:45.972972+00	9e9f74bc-088f-4d3a-9845-c936f9f3c649
4533942f-8e27-4722-816e-1c796ebd4da6	2026-01-23	ea35b0ac-a1c4-4269-ac14-c52e1de9d514	TAFY RECEIVED FROM AANGIE	\N	310000.00	5000.00	1	2026	2026-04-13 09:06:45.972972+00	2026-04-13 09:06:45.972972+00	a46a684b-3b58-4e16-a898-3061240eacd2
18d3f604-37c7-42c3-acf0-329402d9c5a2	2026-01-24	b0e3af81-86f7-4e03-8742-a859303b62a6	ALEX	\N	293480.00	4640.00	1	2026	2026-04-13 09:06:45.972972+00	2026-04-13 09:06:45.972972+00	14e2b201-5949-4704-bd53-791a49ab0162
3f5eba4a-fe6f-41d8-b744-07d882e169a2	2026-01-24	6214c344-b5f9-4d17-b539-e367889ffa9c	WARREN COHEN INVESTMENT	\N	948750.00	15000.00	1	2026	2026-04-13 09:06:45.972972+00	2026-04-13 09:06:45.972972+00	cd26d10b-3b86-4cf6-a0df-9c64b8c40aa1
789c18ea-2005-443a-9510-2c4fca7a87f9	2026-01-24	6214c344-b5f9-4d17-b539-e367889ffa9c	WARREN PAY TRACY SALARY AND RECRUITMENT	\N	458172.00	6942.00	1	2026	2026-04-13 09:06:45.972972+00	2026-04-13 09:06:45.972972+00	e542f423-107d-46b5-97c8-1c5ae2f29c0e
3e80cd1d-a1cf-4cf2-90b5-cd58158b9332	2026-01-25	b0e3af81-86f7-4e03-8742-a859303b62a6	CREDIT IVA H3 - KEITH & SUE X 8 NIGHTS @ 75	\N	40200.00	600.00	1	2026	2026-04-13 09:06:45.972972+00	2026-04-13 09:06:45.972972+00	26b816ca-351b-4a11-af7b-a7157b77dcd9
47e07600-702f-47af-8957-0312b2ff88cc	2026-01-25	bf17ad40-c04f-4438-8456-1bb96ebcecc7	WARREN	\N	119000.00	1750.00	1	2026	2026-04-13 09:06:45.972972+00	2026-04-13 09:06:45.972972+00	03ec732b-2cd8-4f8c-a74a-e22860fce4c2
5d5f37de-0766-4c31-ba8c-870f26f4c22f	2026-01-25	b0e3af81-86f7-4e03-8742-a859303b62a6	ALEX	\N	132000.00	2000.00	1	2026	2026-04-13 09:06:45.972972+00	2026-04-13 09:06:45.972972+00	da4944ec-9ec9-42fe-9b87-85aaecaa5d04
61d29e92-e33c-4f75-b76d-d37f390ee338	2026-01-25	ea35b0ac-a1c4-4269-ac14-c52e1de9d514	TAFY	\N	551000.00	8711.46	1	2026	2026-04-13 09:06:45.972972+00	2026-04-13 09:06:45.972972+00	afaeed91-7caf-4e0c-a094-79a3193fb669
a28b19bd-9454-4c85-ad33-466f2a89d209	2026-01-25	bf17ad40-c04f-4438-8456-1bb96ebcecc7	WARREN STEAD	\N	958350.00	15151.78	1	2026	2026-04-13 09:06:45.972972+00	2026-04-13 09:06:45.972972+00	fa134df7-0fff-43c5-8ffc-195c01bdf6a0
b4939f29-4b22-484c-b543-6113ca54b506	2026-01-29	ea35b0ac-a1c4-4269-ac14-c52e1de9d514	TAFY RE ROBIN	\N	207000.00	3000.00	1	2026	2026-04-13 09:06:45.972972+00	2026-04-13 09:06:45.972972+00	bc55651d-20d3-4d01-aec8-5d8104fc0e5b
f4533932-e0c5-4907-a863-aaa214cb6e69	2026-01-29	6214c344-b5f9-4d17-b539-e367889ffa9c	WARREN INVESTMENT DOLLAR ACCOUNT	\N	569250.00	9000.00	1	2026	2026-04-13 09:06:45.972972+00	2026-04-13 09:06:45.972972+00	b9a4b698-c5db-45ec-a240-0ca761ef676a
0d90e6c9-be85-41ce-96b4-2343d69151d1	2026-01-30	b0e3af81-86f7-4e03-8742-a859303b62a6	KEIVIN PAY TO BANK	\N	420000.00	6640.32	1	2026	2026-04-13 09:06:45.972972+00	2026-04-13 09:06:45.972972+00	687ae46e-4716-4153-85f6-6b79d201cb7a
89416c2c-c14d-4595-a3f6-a03ef0067c65	2026-02-02	b0e3af81-86f7-4e03-8742-a859303b62a6	ALEX	\N	594297.00	9396.00	2	2026	2026-04-13 09:06:45.972972+00	2026-04-13 09:06:45.972972+00	4dfe9a53-1ccd-4013-bda2-5c1055bfd280
e3243d26-075f-46b8-bb97-9a705e26a74f	2026-02-03	ea35b0ac-a1c4-4269-ac14-c52e1de9d514	ALEX	\N	958350.00	15151.78	2	2026	2026-04-13 09:06:45.972972+00	2026-04-13 09:06:45.972972+00	90d0dc0f-19f9-4d08-bdf2-e16544dd6120
28d743c5-c796-43cf-95a7-56675fbfc003	2026-02-04	b0e3af81-86f7-4e03-8742-a859303b62a6	ALEX	\N	751171.00	11876.22	2	2026	2026-04-13 09:06:45.972972+00	2026-04-13 09:06:45.972972+00	9acea114-3cbd-434e-bcee-2b62e6a7216b
58d63911-f366-4cc3-aa61-b91c17923f34	2026-02-09	bf17ad40-c04f-4438-8456-1bb96ebcecc7	WARREN STEAD DEP BANK	\N	948750.00	15000.00	2	2026	2026-04-13 09:06:46.199479+00	2026-04-13 09:06:46.199479+00	6e94b6a6-091f-425c-b6b8-e53a2de972ff
aa467779-c14a-4d6f-a6b9-35ac5b6eee12	2026-02-10	bf17ad40-c04f-4438-8456-1bb96ebcecc7	WARREN STEAD	\N	941920.00	14892.02	2	2026	2026-04-13 09:06:46.199479+00	2026-04-13 09:06:46.199479+00	1f898a27-907b-4a8a-84e3-cfa3dc671c94
42cb4ea2-d9f9-4cbd-a995-a3bcddd54631	2026-02-11	ea35b0ac-a1c4-4269-ac14-c52e1de9d514	CREDIT IVA H1 - LESLEY X 6 NIGHTS	\N	68000.00	1000.00	2	2026	2026-04-13 09:06:45.972972+00	2026-04-13 09:06:45.972972+00	c348fb39-02c9-444f-96d7-785677486d78
8668bd99-27c2-4582-ba7d-407981a4e034	2026-02-12	b0e3af81-86f7-4e03-8742-a859303b62a6	ALEX	\N	638900.00	10101.19	2	2026	2026-04-13 09:06:46.199479+00	2026-04-13 09:06:46.199479+00	092ff6aa-01c0-424a-8321-525c41c65e2c
2679859c-de01-4d94-addc-c827ef72a59f	2026-02-16	bf17ad40-c04f-4438-8456-1bb96ebcecc7	BRENDON 7 DAYS @80	\N	37520.00	560.00	2	2026	2026-04-13 09:06:45.972972+00	2026-04-13 09:06:45.972972+00	4a8c0b31-ceb5-4c61-b19b-3af5a5f20b4d
43303196-8ac1-4e73-af2d-ee85e166851b	2026-02-16	ea35b0ac-a1c4-4269-ac14-c52e1de9d514	TAFY RECEIVED FROM ROBIN	\N	465650.00	6950.00	2	2026	2026-04-13 09:06:45.972972+00	2026-04-13 09:06:45.972972+00	752c8b55-5b8b-4678-93b4-99ed6ec43091
ac45973e-7fce-449d-9517-e81b3eca33af	2026-02-16	bf17ad40-c04f-4438-8456-1bb96ebcecc7	WARREN STEAD	\N	958350.00	15151.78	2	2026	2026-04-13 09:06:45.972972+00	2026-04-13 09:06:45.972972+00	dc6b8e89-566a-4f3d-9a00-aab2c7cf6b9c
f00adeab-dfff-432a-9ace-dbf5cc31f1db	2026-02-16	ea35b0ac-a1c4-4269-ac14-c52e1de9d514	TAFY RECEIVED FROM ALEX	\N	335000.00	5000.00	2	2026	2026-04-13 09:06:45.972972+00	2026-04-13 09:06:45.972972+00	5fd793f3-5294-4934-b089-f6dbfe9a07dc
6fb177a6-bfd7-45b3-8392-fd467b7daff1	2026-02-16	bf17ad40-c04f-4438-8456-1bb96ebcecc7	BRENDON	\N	55200.00	800.00	2	2026	2026-04-13 09:06:46.199479+00	2026-04-13 09:06:46.199479+00	3bcb4c43-1afc-4a14-83a8-e8cbee548977
b9c93133-281f-405c-8170-142fdadaf55c	2026-02-16	ea35b0ac-a1c4-4269-ac14-c52e1de9d514	TAFY	\N	812375.00	12125.00	2	2026	2026-04-13 09:06:46.199479+00	2026-04-13 09:06:46.199479+00	34c2b0b3-58f3-436a-8ba6-35a188938c3e
ffbc4f79-e222-400d-97d7-19f797f13b07	2026-02-16	ea35b0ac-a1c4-4269-ac14-c52e1de9d514	TAFY	\N	335000.00	5000.00	2	2026	2026-04-13 09:06:46.199479+00	2026-04-13 09:06:46.199479+00	d9ca6b0c-7d92-4983-a3b8-ef0de5affbba
2e3dfdb0-10d6-4e67-84da-5afd6adf8210	2026-02-17	6214c344-b5f9-4d17-b539-e367889ffa9c	ARON ACCOMMODATION IN H4	\N	98490.00	1470.00	2	2026	2026-04-13 09:06:45.972972+00	2026-04-13 09:06:45.972972+00	c3a9ce6a-81e3-44b9-b714-1bf7bdf52fc9
1b490664-acec-4935-8cf7-04f0f49edd35	2026-02-18	b0e3af81-86f7-4e03-8742-a859303b62a6	ALEX	\N	948750.00	15000.00	2	2026	2026-04-13 09:06:46.199479+00	2026-04-13 09:06:46.199479+00	14021e21-fa0b-4e0c-8d4c-8755179cc230
f05a6a09-cb41-44ef-b600-fcf2752ae029	2026-02-19	bf17ad40-c04f-4438-8456-1bb96ebcecc7	BRENDON	\N	22400.00	320.00	2	2026	2026-04-13 09:06:46.199479+00	2026-04-13 09:06:46.199479+00	69b77cba-e269-4b78-b4d4-7d4220e8764d
39a7511c-ffc3-4a1d-afd8-133709ae055b	2026-02-20	6214c344-b5f9-4d17-b539-e367889ffa9c	WARREN COHEN INVESTMENT	\N	948750.00	15000.00	2	2026	2026-04-13 09:06:45.972972+00	2026-04-13 09:06:45.972972+00	2779d770-7027-4b37-9902-3d94607d3572
1b39ccd0-eb2f-430b-8c68-2bb09896df92	2026-02-21	b0e3af81-86f7-4e03-8742-a859303b62a6	WARREN STEAD	\N	958350.00	15151.78	2	2026	2026-04-13 09:06:45.972972+00	2026-04-13 09:06:45.972972+00	9d34c92c-d0a6-44e2-a6c3-d15957da8145
c068d7bf-1c26-46a3-bab9-a112ce006ddf	2026-02-22	6214c344-b5f9-4d17-b539-e367889ffa9c	ALAIN WARREN	\N	60720.00	880.00	2	2026	2026-04-13 09:06:46.199479+00	2026-04-13 09:06:46.199479+00	1faa3a4a-8859-437d-ae14-5d4232c21e3b
0954ba9d-44f9-49ce-9be7-202a9406c7ab	2026-02-23	ea35b0ac-a1c4-4269-ac14-c52e1de9d514	TAFY RECEIVED FROM AANGIE	\N	310000.00	5000.00	2	2026	2026-04-13 09:06:45.972972+00	2026-04-13 09:06:45.972972+00	99001375-4cc9-4f62-9374-518be7a9b426
4ebfbc50-3764-4c6e-ac5f-978bf0566cad	2026-02-23	b0e3af81-86f7-4e03-8742-a859303b62a6	ALEX TRANSFER TO MONIQUE	\N	222300.00	3000.00	2	2026	2026-04-13 09:06:46.199479+00	2026-04-13 09:06:46.199479+00	aaf65970-10e5-4c38-b835-8bdb91e90817
8efa9f82-4b4f-4c07-8e39-f3460e0323ff	2026-02-24	6214c344-b5f9-4d17-b539-e367889ffa9c	WARREN PAY TRACY SALARY AND RECRUITMENT	\N	458172.00	6942.00	2	2026	2026-04-13 09:06:45.972972+00	2026-04-13 09:06:45.972972+00	e145dc08-f86a-4899-861e-1c2947dc2ec1
bf9e2cf4-6cb0-4a25-9903-c0423e0a3794	2026-02-24	b0e3af81-86f7-4e03-8742-a859303b62a6	ALEX	\N	293480.00	4640.00	2	2026	2026-04-13 09:06:45.972972+00	2026-04-13 09:06:45.972972+00	c26bae19-f04e-4b0d-be5b-cc3e401be8c5
f59bd5ac-d1fe-4f3d-a5f7-f73bfa63f7c5	2026-02-24	6214c344-b5f9-4d17-b539-e367889ffa9c	WARREN COHEN INVESTMENT	\N	948750.00	15000.00	2	2026	2026-04-13 09:06:46.199479+00	2026-04-13 09:06:46.199479+00	f1883d19-e0db-4067-b665-089f2f66cd75
5d92494f-2e2c-4490-9707-f36b342659c7	2026-02-25	bf17ad40-c04f-4438-8456-1bb96ebcecc7	WARREN STEAD	\N	958350.00	15151.78	2	2026	2026-04-13 09:06:45.972972+00	2026-04-13 09:06:45.972972+00	6349b650-82d2-48af-8ce0-f7e796591d10
88e4aaa9-1c37-4bff-b576-537e13c21c49	2026-02-25	b0e3af81-86f7-4e03-8742-a859303b62a6	CREDIT IVA H3 - KEITH & SUE X 8 NIGHTS @ 75	\N	40200.00	600.00	2	2026	2026-04-13 09:06:45.972972+00	2026-04-13 09:06:45.972972+00	878c6e58-822f-481b-87ec-0920aa7d7c29
e3c36357-efda-449f-ac66-7995134b348b	2026-02-25	b0e3af81-86f7-4e03-8742-a859303b62a6	ALEX	\N	132000.00	2000.00	2	2026	2026-04-13 09:06:45.972972+00	2026-04-13 09:06:45.972972+00	e7d2226e-dd88-45cb-9ab8-d67693c58368
61ce52c7-4a9c-4f3f-bfac-58bf65fabfca	2026-02-25	bf17ad40-c04f-4438-8456-1bb96ebcecc7	WARREN	\N	119000.00	1750.00	2	2026	2026-04-13 09:06:46.199479+00	2026-04-13 09:06:46.199479+00	82c0c79e-5a59-4608-a9f8-ec97f5c99ce7
d421f077-7168-4dbb-9f8f-36ec861147ea	2026-02-25	ea35b0ac-a1c4-4269-ac14-c52e1de9d514	TAFY	\N	551000.00	8711.46	2	2026	2026-04-13 09:06:46.199479+00	2026-04-13 09:06:46.199479+00	ae1c23f4-f70a-4ee9-b77a-819072fc1561
32e3ecf3-b6bf-44d0-95ba-1aef3bdd20e2	2026-02-28	b0e3af81-86f7-4e03-8742-a859303b62a6	KEIVIN PAY TO BANK	\N	420000.00	6640.32	2	2026	2026-04-13 09:06:45.972972+00	2026-04-13 09:06:45.972972+00	a82d3dc7-e567-48f1-b9f3-d55f79f98de5
28c75f42-ac37-48d9-8789-0b7e5555dbbe	2026-02-28	ea35b0ac-a1c4-4269-ac14-c52e1de9d514	TAFY RE ROBIN	\N	207000.00	3000.00	2	2026	2026-04-13 09:06:46.199479+00	2026-04-13 09:06:46.199479+00	87bffe9f-3589-4eeb-a413-81d41f97c28e
9adaaca4-826b-48b3-8c21-bb5a1cc859bc	2026-02-28	6214c344-b5f9-4d17-b539-e367889ffa9c	WARREN INVESTMENT DOLLAR ACCOUNT	\N	569250.00	9000.00	2	2026	2026-04-13 09:06:46.199479+00	2026-04-13 09:06:46.199479+00	7e5d464d-93fd-44d7-b673-9bd143afed80
bce9e8ec-c843-473a-b25c-0cfee9bf62ba	2026-03-02	b0e3af81-86f7-4e03-8742-a859303b62a6	ALEX	\N	594297.00	9396.00	3	2026	2026-04-13 09:06:46.199479+00	2026-04-13 09:06:46.199479+00	48333f31-bd2b-4ae9-8367-d48dc672533b
507baae5-9a0d-4fe2-a281-664ce6b9abe3	2026-03-03	ea35b0ac-a1c4-4269-ac14-c52e1de9d514	ALEX	\N	958350.00	15151.78	3	2026	2026-04-13 09:06:46.199479+00	2026-04-13 09:06:46.199479+00	f6cb5a78-020e-4d1b-aef7-e9d37adb84d6
c8a920cf-32cc-4688-988e-3c5cbdefdd80	2026-03-04	b0e3af81-86f7-4e03-8742-a859303b62a6	ALEX	\N	751171.00	11876.22	3	2026	2026-04-13 09:06:46.199479+00	2026-04-13 09:06:46.199479+00	63f05972-e49f-4c10-82f4-d08ffb5e10c5
6c518ca9-1a4a-4dd1-87a8-ddecb93c26ce	2026-03-09	bf17ad40-c04f-4438-8456-1bb96ebcecc7	WARREN STEAD DEP BANK	\N	948750.00	15000.00	3	2026	2026-04-13 09:06:46.199479+00	2026-04-13 09:06:46.199479+00	0a45eea3-943f-4037-bca2-4d7a5aef6e91
65450fd3-8332-42b9-be13-64b6ead6589d	2026-03-10	bf17ad40-c04f-4438-8456-1bb96ebcecc7	WARREN STEAD	\N	941920.00	14892.02	3	2026	2026-04-13 09:06:46.199479+00	2026-04-13 09:06:46.199479+00	5c8f19bd-2353-46bd-a190-36c66645ef4f
9709da80-d9bf-4352-a39d-70b54c30262e	2026-03-11	ea35b0ac-a1c4-4269-ac14-c52e1de9d514	CREDIT IVA H1 - LESLEY X 6 NIGHTS	\N	68000.00	1000.00	3	2026	2026-04-13 09:06:46.199479+00	2026-04-13 09:06:46.199479+00	0f31bf99-0040-475f-96f8-117d491c5bc8
46c7037b-5b3b-4fd4-be66-1c95614263af	2026-03-12	b0e3af81-86f7-4e03-8742-a859303b62a6	ALEX	\N	638900.00	10101.19	3	2026	2026-04-13 09:06:46.199479+00	2026-04-13 09:06:46.199479+00	26d387df-67c4-49d9-8bd6-c73b7b90d95e
03d462fe-3b12-4f49-8a73-ac2fd9bc0a4b	2026-03-16	ea35b0ac-a1c4-4269-ac14-c52e1de9d514	TAFY RECEIVED FROM ROBIN	\N	465650.00	6950.00	3	2026	2026-04-13 09:06:46.199479+00	2026-04-13 09:06:46.199479+00	d762a09d-656a-4655-ba46-63b7f92030d9
2aba1003-4b22-4460-a3ac-b4849587c5b0	2026-03-16	bf17ad40-c04f-4438-8456-1bb96ebcecc7	BRENDON	\N	55200.00	800.00	3	2026	2026-04-13 09:06:46.199479+00	2026-04-13 09:06:46.199479+00	6863b383-ebd9-4de6-8bd0-7f4ffa2882c6
32a00646-183b-42d3-9492-0691f03f270a	2026-03-16	6214c344-b5f9-4d17-b539-e367889ffa9c	WARREN COHEN INVESTMENT	\N	1407000.00	21000.00	3	2026	2026-04-13 09:06:46.199479+00	2026-04-13 09:06:46.199479+00	cfa3608a-4da5-438c-8066-d64d52f79acc
4546b618-cf6c-406e-bdf2-97e4232379c3	2026-03-16	ea35b0ac-a1c4-4269-ac14-c52e1de9d514	TAFY	\N	335000.00	5000.00	3	2026	2026-04-13 09:06:46.199479+00	2026-04-13 09:06:46.199479+00	9ea68823-2b5c-4adb-9252-00d45e9fec67
82672f4e-fbdf-4cb3-bc5c-22654fadb3ea	2026-03-16	bf17ad40-c04f-4438-8456-1bb96ebcecc7	BRENDON 7 DAYS @80	\N	37520.00	560.00	3	2026	2026-04-13 09:06:46.199479+00	2026-04-13 09:06:46.199479+00	7b385729-d24c-4dea-9539-e204646e9f13
8f6349f7-9cc0-47a2-a156-d18152937a14	2026-03-16	ea35b0ac-a1c4-4269-ac14-c52e1de9d514	TAFY RECEIVED FROM ALEX	\N	335000.00	5000.00	3	2026	2026-04-13 09:06:46.199479+00	2026-04-13 09:06:46.199479+00	206d00a7-e385-431b-a1f0-820e7ed914d1
a06e08b9-620e-4a29-9f13-46a732e7b258	2026-03-16	ea35b0ac-a1c4-4269-ac14-c52e1de9d514	TAFY ELIANA	\N	38400.00	607.11	3	2026	2026-04-13 09:06:46.199479+00	2026-04-13 09:06:46.199479+00	fa22d2bc-b2ae-441a-9cb8-c8e65ce187c6
ae3885b7-6e81-4264-b7bb-e4596aa912d6	2026-03-16	bf17ad40-c04f-4438-8456-1bb96ebcecc7	WARREN STEAD	\N	958350.00	15151.78	3	2026	2026-04-13 09:06:46.199479+00	2026-04-13 09:06:46.199479+00	1ce836ed-220b-4496-8a9a-a740f187fa04
f1a7da25-4f70-49ac-b20a-9f3bc61859e1	2026-03-16	ea35b0ac-a1c4-4269-ac14-c52e1de9d514	TAFY	\N	812375.00	12125.00	3	2026	2026-04-13 09:06:46.199479+00	2026-04-13 09:06:46.199479+00	49361d80-a483-454d-9edc-656a363e82c1
0a9819b0-e317-44df-9c31-4a72beeb1733	2026-03-17	6214c344-b5f9-4d17-b539-e367889ffa9c	ARON ACCOMMODATION IN H4	\N	98490.00	1470.00	3	2026	2026-04-13 09:06:46.199479+00	2026-04-13 09:06:46.199479+00	55bc3e9d-d935-4cf1-b7ad-23faddfe7e07
6f82d966-5bc5-49ac-8821-6e7b6ad78ff7	2026-03-18	b0e3af81-86f7-4e03-8742-a859303b62a6	ALEX	\N	948750.00	15000.00	3	2026	2026-04-13 09:06:46.199479+00	2026-04-13 09:06:46.199479+00	e4d1e4d1-a50a-41a0-bdfa-c2cc2e38cd0a
0a2d282f-f83c-4536-8352-7367b8d6fce1	2026-03-19	bf17ad40-c04f-4438-8456-1bb96ebcecc7	BRENDON	\N	22400.00	320.00	3	2026	2026-04-13 09:06:46.199479+00	2026-04-13 09:06:46.199479+00	411eac46-c4b3-42e5-a991-4f77314745f8
aafdbadf-98d3-41d7-8d44-77136e1f6ffb	2026-03-20	6214c344-b5f9-4d17-b539-e367889ffa9c	WARREN COHEN INVESTMENT	\N	948750.00	15000.00	3	2026	2026-04-13 09:06:46.199479+00	2026-04-13 09:06:46.199479+00	d743140a-88ad-47fd-ae48-5ada617199ba
0c836e99-c20a-4c86-95a3-756407ae2d31	2026-03-21	b0e3af81-86f7-4e03-8742-a859303b62a6	WARREN STEAD	\N	958350.00	15151.78	3	2026	2026-04-13 09:06:46.199479+00	2026-04-13 09:06:46.199479+00	a8aafe73-74ed-4759-9828-d6cb50be160f
c9b0c7a8-91b0-442a-abf9-bf828612e05f	2026-03-22	6214c344-b5f9-4d17-b539-e367889ffa9c	ALAIN WARREN	\N	60720.00	880.00	3	2026	2026-04-13 09:06:46.199479+00	2026-04-13 09:06:46.199479+00	ded44176-e7f6-43d2-908b-6645e4481ab3
a8c0e208-b799-4aab-aee3-9f687e8847b3	2026-03-23	b0e3af81-86f7-4e03-8742-a859303b62a6	ALEX TRANSFER TO MONIQUE	\N	222300.00	3000.00	3	2026	2026-04-13 09:06:46.199479+00	2026-04-13 09:06:46.199479+00	03554493-32cc-45e1-a930-03703e07307b
c9fe6b5e-0a00-4f52-9d29-8059c20f0445	2026-03-23	ea35b0ac-a1c4-4269-ac14-c52e1de9d514	TAFY RECEIVED FROM AANGIE	\N	310000.00	5000.00	3	2026	2026-04-13 09:06:46.199479+00	2026-04-13 09:06:46.199479+00	5a759d36-c218-4541-9f61-cddb57ade7e6
365ef547-7b02-45eb-a8b4-9d80ed21fcbb	2026-03-24	6214c344-b5f9-4d17-b539-e367889ffa9c	WARREN PAY TRACY SALARY AND RECRUITMENT	\N	458172.00	6942.00	3	2026	2026-04-13 09:06:46.199479+00	2026-04-13 09:06:46.199479+00	97f8b77b-d458-4fa1-b001-20826cb5a5c4
4efa6d72-b18c-4c72-a374-e500c41a048a	2026-03-24	b0e3af81-86f7-4e03-8742-a859303b62a6	ALEX	\N	293480.00	4640.00	3	2026	2026-04-13 09:06:46.199479+00	2026-04-13 09:06:46.199479+00	4d3ea5d5-c8cf-4925-a531-9221876b19db
d59bcdbf-c2bf-4f0f-a00e-236cdf78809f	2026-03-24	6214c344-b5f9-4d17-b539-e367889ffa9c	WARREN COHEN INVESTMENT	\N	948750.00	15000.00	3	2026	2026-04-13 09:06:46.199479+00	2026-04-13 09:06:46.199479+00	63797375-7ca4-44a8-8300-ad4e7c538392
3bde08ef-4fdb-47d0-99ea-8a74ff0622df	2026-03-25	bf17ad40-c04f-4438-8456-1bb96ebcecc7	WARREN	\N	119000.00	1750.00	3	2026	2026-04-13 09:06:46.199479+00	2026-04-13 09:06:46.199479+00	951ba03c-1c13-441e-a38e-ed25e8966238
41130366-59b1-4dbd-ab1f-a3635184e276	2026-03-25	ea35b0ac-a1c4-4269-ac14-c52e1de9d514	TAFY	\N	551000.00	8711.46	3	2026	2026-04-13 09:06:46.199479+00	2026-04-13 09:06:46.199479+00	b33219e3-86fa-403b-aa1e-39e51c09404a
70bb260c-b1e5-4576-9f1f-f6ffbdc16712	2026-03-25	b0e3af81-86f7-4e03-8742-a859303b62a6	CREDIT IVA H3 - KEITH & SUE X 8 NIGHTS @ 75	\N	40200.00	600.00	3	2026	2026-04-13 09:06:46.199479+00	2026-04-13 09:06:46.199479+00	85888e62-46aa-4085-8dd7-c6e56d1ca454
79eb54a8-59f1-4338-85ce-bdaf666a1923	2026-03-25	b0e3af81-86f7-4e03-8742-a859303b62a6	ALEX	\N	132000.00	2000.00	3	2026	2026-04-13 09:06:46.199479+00	2026-04-13 09:06:46.199479+00	eb16be51-0c12-4db9-bda3-715f775279fe
e4ce331c-97d3-4f10-8358-54defd15f2f8	2026-03-25	bf17ad40-c04f-4438-8456-1bb96ebcecc7	WARREN STEAD	\N	958350.00	15151.78	3	2026	2026-04-13 09:06:46.199479+00	2026-04-13 09:06:46.199479+00	a9629fb9-c052-4fea-8fb7-03ae1f781a86
8d28d047-767a-47e8-bd14-0ceba680ccde	2026-03-29	6214c344-b5f9-4d17-b539-e367889ffa9c	WARREN INVESTMENT DOLLAR ACCOUNT	\N	569250.00	9000.00	3	2026	2026-04-13 09:06:46.199479+00	2026-04-13 09:06:46.199479+00	e7d59e7e-9db7-4174-8860-58ebcf24cc93
dd74dd95-4703-4e1a-86e2-3ad6a1f9ce1c	2026-03-29	ea35b0ac-a1c4-4269-ac14-c52e1de9d514	TAFY RE ROBIN	\N	207000.00	3000.00	3	2026	2026-04-13 09:06:46.199479+00	2026-04-13 09:06:46.199479+00	6da826be-190e-480b-a2a1-e9a28f5491b2
c4145cdc-0c44-419c-a0c0-554fd67b4e79	2026-03-30	b0e3af81-86f7-4e03-8742-a859303b62a6	KEIVIN PAY TO BANK	\N	420000.00	6640.32	3	2026	2026-04-13 09:06:46.199479+00	2026-04-13 09:06:46.199479+00	a0162379-4a21-4be9-bfec-2b28529b3a19
\.


--
-- Data for Name: inss_payments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.inss_payments (id, month, year, amount, payment_date, reference, created_at) FROM stdin;
\.


--
-- Data for Name: invoices; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.invoices (id, invoice_number, invoice_series, invoice_date, due_date, property_id, client_name, client_nuit, client_address, line_items, subtotal_mzn, vat_amount_mzn, total_mzn, currency, exchange_rate, status, at_hash, at_qr_code, journal_entry_id, income_tx_id, issued_by, created_at, updated_at) FROM stdin;
7bfcc344-e57e-4eb3-8e6a-925c35ae1559	FT 2026/001	FT	2026-01-01	2026-01-01	b0e3af81-86f7-4e03-8742-a859303b62a6	ALEX	\N	\N	[{"quantity": 1, "vat_rate": 0.16, "line_total": 594297, "unit_price": 512325, "vat_amount": 81972, "description": "Accommodation - ALEX"}]	512325	81972	594297	MZN	1	issued	BJDs4BRI	A:123456789*B:999999999*C:MZ*D:FT*E:N*F:20260101*G:FT 2026/001*H:BJDs4BRI*I1:MZ*N:81972.00*O:594297.00*Q:BJDs4BRI	d0049a70-ab5d-4f3e-a36b-72902dceb611	3441bc57-1201-4661-abfa-bc2e3e4d60c8	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-01-01 12:00:00+00	2026-01-01 12:00:00+00
a8a3312f-ef38-45d6-a065-89badb71eb74	FT 2026/002	FT	2026-01-02	2026-01-02	ea35b0ac-a1c4-4269-ac14-c52e1de9d514	ALEX	\N	\N	[{"quantity": 1, "vat_rate": 0.16, "line_total": 958350, "unit_price": 826163.79, "vat_amount": 132186.21, "description": "Accommodation - ALEX"}]	826163.79	132186.21	958350	MZN	1	issued	V3IzFVZe	A:123456789*B:999999999*C:MZ*D:FT*E:N*F:20260102*G:FT 2026/002*H:V3IzFVZe*I1:MZ*N:132186.21*O:958350.00*Q:V3IzFVZe	47a8c121-81a6-4392-bdc8-efa8a8e8431a	813a09c4-8af9-41bc-8ab3-cc3420fe835b	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-01-02 12:00:00+00	2026-01-02 12:00:00+00
8564e702-dc16-43b7-a609-4c6b56ad14b5	FT 2026/003	FT	2026-01-03	2026-01-03	b0e3af81-86f7-4e03-8742-a859303b62a6	ALEX	\N	\N	[{"quantity": 1, "vat_rate": 0.16, "line_total": 751171, "unit_price": 647561.21, "vat_amount": 103609.79, "description": "Accommodation - ALEX"}]	647561.21	103609.79	751171	MZN	1	issued	OMUO+Nk7	A:123456789*B:999999999*C:MZ*D:FT*E:N*F:20260103*G:FT 2026/003*H:OMUO+Nk7*I1:MZ*N:103609.79*O:751171.00*Q:OMUO+Nk7	c3ed77e5-c385-4752-9e87-d7874f646b1b	1d9d385f-ed79-4077-a5db-341c12ed022b	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-01-03 12:00:00+00	2026-01-03 12:00:00+00
d132d020-2d40-49c3-bf62-100ec8a70fe5	FT 2026/004	FT	2026-01-08	2026-01-08	bf17ad40-c04f-4438-8456-1bb96ebcecc7	WARREN STEAD DEP BANK	\N	\N	[{"quantity": 1, "vat_rate": 0.16, "line_total": 948750, "unit_price": 817887.93, "vat_amount": 130862.07, "description": "Accommodation - WARREN STEAD DEP BANK"}]	817887.93	130862.07	948750	MZN	1	issued	es5s0SSm	A:123456789*B:999999999*C:MZ*D:FT*E:N*F:20260108*G:FT 2026/004*H:es5s0SSm*I1:MZ*N:130862.07*O:948750.00*Q:es5s0SSm	399f9d9a-6f51-45f0-ac5f-aca9c3a593bc	a1f9cb9f-6a81-4a8e-a42c-2220d6340850	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-01-08 12:00:00+00	2026-01-08 12:00:00+00
e1122c3d-e340-4ed8-bedb-43b50e62770e	FT 2026/005	FT	2026-01-09	2026-01-09	bf17ad40-c04f-4438-8456-1bb96ebcecc7	WARREN STEAD	\N	\N	[{"quantity": 1, "vat_rate": 0.16, "line_total": 941920, "unit_price": 812000, "vat_amount": 129920, "description": "Accommodation - WARREN STEAD"}]	812000	129920	941920	MZN	1	issued	U9YfvVWE	A:123456789*B:999999999*C:MZ*D:FT*E:N*F:20260109*G:FT 2026/005*H:U9YfvVWE*I1:MZ*N:129920.00*O:941920.00*Q:U9YfvVWE	0d348fd1-a4f7-4258-aa0e-97c1d65cedc0	3dae6133-5ded-4d21-9d3c-eb1481682f49	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-01-09 12:00:00+00	2026-01-09 12:00:00+00
44f1ad10-0a67-4b92-a3e2-3002b23f4d06	FT 2026/006	FT	2026-01-10	2026-01-10	ea35b0ac-a1c4-4269-ac14-c52e1de9d514	CREDIT IVA H1 - LESLEY X 6 NIGHTS	\N	\N	[{"quantity": 1, "vat_rate": 0.16, "line_total": 68000, "unit_price": 58620.69, "vat_amount": 9379.31, "description": "Accommodation - CREDIT IVA H1 - LESLEY X 6 NIGHTS"}]	58620.69	9379.31	68000	MZN	1	issued	tT4CzOtr	A:123456789*B:999999999*C:MZ*D:FT*E:N*F:20260110*G:FT 2026/006*H:tT4CzOtr*I1:MZ*N:9379.31*O:68000.00*Q:tT4CzOtr	2795d965-504b-418a-9273-faad8e274d4a	1069f22a-2c07-4a0b-812c-add966df5081	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-01-10 12:00:00+00	2026-01-10 12:00:00+00
381d8fb1-9a13-488c-b2ad-ae68cb8cce2e	FT 2026/007	FT	2026-01-11	2026-01-11	b0e3af81-86f7-4e03-8742-a859303b62a6	ALEX	\N	\N	[{"quantity": 1, "vat_rate": 0.16, "line_total": 638900, "unit_price": 550775.86, "vat_amount": 88124.14, "description": "Accommodation - ALEX"}]	550775.86	88124.14	638900	MZN	1	issued	i5m5Axcz	A:123456789*B:999999999*C:MZ*D:FT*E:N*F:20260111*G:FT 2026/007*H:i5m5Axcz*I1:MZ*N:88124.14*O:638900.00*Q:i5m5Axcz	01a5e615-ac14-4ec5-b24d-cd23054e4430	eba45d1f-c23d-42f0-ae7c-f93787fc4a83	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-01-11 12:00:00+00	2026-01-11 12:00:00+00
d9b6e91d-63c3-480a-81de-9ee5b2192596	FT 2026/008	FT	2026-01-15	2026-01-15	bf17ad40-c04f-4438-8456-1bb96ebcecc7	BRENDON	\N	\N	[{"quantity": 1, "vat_rate": 0.16, "line_total": 55200, "unit_price": 47586.21, "vat_amount": 7613.79, "description": "Accommodation - BRENDON"}]	47586.21	7613.79	55200	MZN	1	issued	Wlh8IBl4	A:123456789*B:999999999*C:MZ*D:FT*E:N*F:20260115*G:FT 2026/008*H:Wlh8IBl4*I1:MZ*N:7613.79*O:55200.00*Q:Wlh8IBl4	875ececf-e730-434f-951a-a6eb2ac9cbe9	5da3732e-28aa-45b6-a283-c8ac855bf591	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-01-15 12:00:00+00	2026-01-15 12:00:00+00
3a2c5301-423c-40c1-842b-cd0081743861	FT 2026/009	FT	2026-01-15	2026-01-15	ea35b0ac-a1c4-4269-ac14-c52e1de9d514	TAFY	\N	\N	[{"quantity": 1, "vat_rate": 0.16, "line_total": 812375, "unit_price": 700323.28, "vat_amount": 112051.72, "description": "Accommodation - TAFY"}]	700323.28	112051.72	812375	MZN	1	issued	EP9Lr8gP	A:123456789*B:999999999*C:MZ*D:FT*E:N*F:20260115*G:FT 2026/009*H:EP9Lr8gP*I1:MZ*N:112051.72*O:812375.00*Q:EP9Lr8gP	b6539d2b-f989-45cb-a1e7-4b55fffbe86a	6296370c-b299-4c47-b5bd-c03e1bf622a9	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-01-15 12:00:00+00	2026-01-15 12:00:00+00
594c37a4-cdc1-4cd1-995f-84f9edc1fa21	FT 2026/010	FT	2026-01-15	2026-01-15	ea35b0ac-a1c4-4269-ac14-c52e1de9d514	TAFY RECEIVED FROM ROBIN	\N	\N	[{"quantity": 1, "vat_rate": 0.16, "line_total": 465650, "unit_price": 401422.41, "vat_amount": 64227.59, "description": "Accommodation - TAFY RECEIVED FROM ROBIN"}]	401422.41	64227.59	465650	MZN	1	issued	kHW5M9Fm	A:123456789*B:999999999*C:MZ*D:FT*E:N*F:20260115*G:FT 2026/010*H:kHW5M9Fm*I1:MZ*N:64227.59*O:465650.00*Q:kHW5M9Fm	aed6d853-a889-4cf7-80db-ddc5a61dae07	96bba594-dfc3-4654-91f4-6d134c5dadde	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-01-15 12:00:00+00	2026-01-15 12:00:00+00
4ee2b073-cb40-4a89-8e13-9b40de5e4828	FT 2026/011	FT	2026-01-15	2026-01-15	bf17ad40-c04f-4438-8456-1bb96ebcecc7	WARREN STEAD	\N	\N	[{"quantity": 1, "vat_rate": 0.16, "line_total": 958350, "unit_price": 826163.79, "vat_amount": 132186.21, "description": "Accommodation - WARREN STEAD"}]	826163.79	132186.21	958350	MZN	1	issued	cTKrazel	A:123456789*B:999999999*C:MZ*D:FT*E:N*F:20260115*G:FT 2026/011*H:cTKrazel*I1:MZ*N:132186.21*O:958350.00*Q:cTKrazel	a61a796e-0f7e-4d46-b3b8-8f55d0c10bcd	ac54c013-7df0-4e4c-b19a-13d889415553	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-01-15 12:00:00+00	2026-01-15 12:00:00+00
54620452-e155-47e1-b75f-34c3afba788a	FT 2026/012	FT	2026-01-15	2026-01-15	bf17ad40-c04f-4438-8456-1bb96ebcecc7	BRENDON 7 DAYS @80	\N	\N	[{"quantity": 1, "vat_rate": 0.16, "line_total": 37520, "unit_price": 32344.83, "vat_amount": 5175.17, "description": "Accommodation - BRENDON 7 DAYS @80"}]	32344.83	5175.17	37520	MZN	1	issued	3wtumqZf	A:123456789*B:999999999*C:MZ*D:FT*E:N*F:20260115*G:FT 2026/012*H:3wtumqZf*I1:MZ*N:5175.17*O:37520.00*Q:3wtumqZf	c1276af4-69fc-4788-beb2-2b1f76b2aedd	efa13fc6-51e7-4159-8092-5dfe792789b5	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-01-15 12:00:00+00	2026-01-15 12:00:00+00
a4d41711-6fb2-4d6b-a7ed-d9553b772bd9	FT 2026/013	FT	2026-01-15	2026-01-15	ea35b0ac-a1c4-4269-ac14-c52e1de9d514	TAFY RECEIVED FROM ALEX	\N	\N	[{"quantity": 1, "vat_rate": 0.16, "line_total": 335000, "unit_price": 288793.1, "vat_amount": 46206.9, "description": "Accommodation - TAFY RECEIVED FROM ALEX"}]	288793.1	46206.9	335000	MZN	1	issued	EDrRbG90	A:123456789*B:999999999*C:MZ*D:FT*E:N*F:20260115*G:FT 2026/013*H:EDrRbG90*I1:MZ*N:46206.90*O:335000.00*Q:EDrRbG90	59cb3ec9-4125-41b2-81bd-eb4d43294a48	f30da5de-4f59-4ca6-aa69-f846cc4eea72	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-01-15 12:00:00+00	2026-01-15 12:00:00+00
6b7f7520-840a-4f45-9722-8295f27f0f15	FT 2026/014	FT	2026-01-16	2026-01-16	6214c344-b5f9-4d17-b539-e367889ffa9c	ARON ACCOMMODATION IN H4	\N	\N	[{"quantity": 1, "vat_rate": 0.16, "line_total": 98490, "unit_price": 84905.17, "vat_amount": 13584.83, "description": "Accommodation - ARON ACCOMMODATION IN H4"}]	84905.17	13584.83	98490	MZN	1	issued	XqOpQGMz	A:123456789*B:999999999*C:MZ*D:FT*E:N*F:20260116*G:FT 2026/014*H:XqOpQGMz*I1:MZ*N:13584.83*O:98490.00*Q:XqOpQGMz	805513af-ac06-4c94-9a4c-1ecfa3d18efa	ace94d66-9bf5-4589-956a-396e4da8d5e6	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-01-16 12:00:00+00	2026-01-16 12:00:00+00
3cfbe2b1-9822-4f67-b010-5529e12cec1d	FT 2026/015	FT	2026-01-17	2026-01-17	b0e3af81-86f7-4e03-8742-a859303b62a6	ALEX	\N	\N	[{"quantity": 1, "vat_rate": 0.16, "line_total": 948750, "unit_price": 817887.93, "vat_amount": 130862.07, "description": "Accommodation - ALEX"}]	817887.93	130862.07	948750	MZN	1	issued	azYZCSni	A:123456789*B:999999999*C:MZ*D:FT*E:N*F:20260117*G:FT 2026/015*H:azYZCSni*I1:MZ*N:130862.07*O:948750.00*Q:azYZCSni	cb7106c2-327d-4802-9972-afe97b18cfed	1a4536c7-23a9-4ee5-9314-a570c2eaff6b	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-01-17 12:00:00+00	2026-01-17 12:00:00+00
9a59a4c1-59f9-499b-b230-a43224627fb4	FT 2026/016	FT	2026-01-18	2026-01-18	bf17ad40-c04f-4438-8456-1bb96ebcecc7	BRENDON	\N	\N	[{"quantity": 1, "vat_rate": 0.16, "line_total": 22400, "unit_price": 19310.34, "vat_amount": 3089.66, "description": "Accommodation - BRENDON"}]	19310.34	3089.66	22400	MZN	1	issued	/IMYc140	A:123456789*B:999999999*C:MZ*D:FT*E:N*F:20260118*G:FT 2026/016*H:/IMYc140*I1:MZ*N:3089.66*O:22400.00*Q:/IMYc140	e17bb3a0-f9db-42b2-bebe-d42437a6c077	234ed239-5b62-41a3-abd2-1400a195e4df	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-01-18 12:00:00+00	2026-01-18 12:00:00+00
79106cd0-e430-4d10-b378-5399af1b5399	FT 2026/017	FT	2026-01-19	2026-01-19	6214c344-b5f9-4d17-b539-e367889ffa9c	WARREN COHEN INVESTMENT	\N	\N	[{"quantity": 1, "vat_rate": 0.16, "line_total": 948750, "unit_price": 817887.93, "vat_amount": 130862.07, "description": "Accommodation - WARREN COHEN INVESTMENT"}]	817887.93	130862.07	948750	MZN	1	issued	5JY9/Nim	A:123456789*B:999999999*C:MZ*D:FT*E:N*F:20260119*G:FT 2026/017*H:5JY9/Nim*I1:MZ*N:130862.07*O:948750.00*Q:5JY9/Nim	ee6564f1-0260-45a2-a3c7-1b143b634770	41e28b7a-9c7e-4dd6-898d-6ea9df96c643	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-01-19 12:00:00+00	2026-01-19 12:00:00+00
4939a85a-adc1-450e-9db5-9147711ffb9c	FT 2026/018	FT	2026-01-20	2026-01-20	b0e3af81-86f7-4e03-8742-a859303b62a6	WARREN STEAD	\N	\N	[{"quantity": 1, "vat_rate": 0.16, "line_total": 958350, "unit_price": 826163.79, "vat_amount": 132186.21, "description": "Accommodation - WARREN STEAD"}]	826163.79	132186.21	958350	MZN	1	issued	juBJ7w3t	A:123456789*B:999999999*C:MZ*D:FT*E:N*F:20260120*G:FT 2026/018*H:juBJ7w3t*I1:MZ*N:132186.21*O:958350.00*Q:juBJ7w3t	d6af991f-69c5-445d-a129-560295d4317c	7e2a35d2-71e6-46ac-8f06-d56d12911c46	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-01-20 12:00:00+00	2026-01-20 12:00:00+00
1fe331aa-29b1-4ab9-b933-fa35ff7b28ac	FT 2026/019	FT	2026-01-21	2026-01-21	6214c344-b5f9-4d17-b539-e367889ffa9c	ALAIN WARREN	\N	\N	[{"quantity": 1, "vat_rate": 0.16, "line_total": 60720, "unit_price": 52344.83, "vat_amount": 8375.17, "description": "Accommodation - ALAIN WARREN"}]	52344.83	8375.17	60720	MZN	1	issued	7ixxyGa0	A:123456789*B:999999999*C:MZ*D:FT*E:N*F:20260121*G:FT 2026/019*H:7ixxyGa0*I1:MZ*N:8375.17*O:60720.00*Q:7ixxyGa0	0eb252c8-5395-43c5-a2d4-90d9b414de6e	4592d261-0399-49c6-b5f2-1bae4157cbab	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-01-21 12:00:00+00	2026-01-21 12:00:00+00
516581bd-43f9-4ac2-8738-52ad0ce5ed54	FT 2026/020	FT	2026-01-22	2026-01-22	b0e3af81-86f7-4e03-8742-a859303b62a6	ALEX TRANSFER TO MONIQUE	\N	\N	[{"quantity": 1, "vat_rate": 0.16, "line_total": 222300, "unit_price": 191637.93, "vat_amount": 30662.07, "description": "Accommodation - ALEX TRANSFER TO MONIQUE"}]	191637.93	30662.07	222300	MZN	1	issued	8RRU5aBA	A:123456789*B:999999999*C:MZ*D:FT*E:N*F:20260122*G:FT 2026/020*H:8RRU5aBA*I1:MZ*N:30662.07*O:222300.00*Q:8RRU5aBA	9e9f74bc-088f-4d3a-9845-c936f9f3c649	07180c22-6e02-4743-aa3d-e1fa46c9b694	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-01-22 12:00:00+00	2026-01-22 12:00:00+00
a0af5ddc-85ab-48dd-a868-9e6c2c5c4509	FT 2026/021	FT	2026-01-22	2026-01-22	ea35b0ac-a1c4-4269-ac14-c52e1de9d514	TAFY RECEIVED FROM AANGIE	\N	\N	[{"quantity": 1, "vat_rate": 0.16, "line_total": 310000, "unit_price": 267241.38, "vat_amount": 42758.62, "description": "Accommodation - TAFY RECEIVED FROM AANGIE"}]	267241.38	42758.62	310000	MZN	1	issued	OJw42SZT	A:123456789*B:999999999*C:MZ*D:FT*E:N*F:20260122*G:FT 2026/021*H:OJw42SZT*I1:MZ*N:42758.62*O:310000.00*Q:OJw42SZT	a46a684b-3b58-4e16-a898-3061240eacd2	4533942f-8e27-4722-816e-1c796ebd4da6	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-01-22 12:00:00+00	2026-01-22 12:00:00+00
2ac53512-e236-4243-a4d8-1fbd3941500c	FT 2026/022	FT	2026-01-23	2026-01-23	b0e3af81-86f7-4e03-8742-a859303b62a6	ALEX	\N	\N	[{"quantity": 1, "vat_rate": 0.16, "line_total": 293480, "unit_price": 253000, "vat_amount": 40480, "description": "Accommodation - ALEX"}]	253000	40480	293480	MZN	1	issued	Io4J+kYi	A:123456789*B:999999999*C:MZ*D:FT*E:N*F:20260123*G:FT 2026/022*H:Io4J+kYi*I1:MZ*N:40480.00*O:293480.00*Q:Io4J+kYi	14e2b201-5949-4704-bd53-791a49ab0162	18d3f604-37c7-42c3-acf0-329402d9c5a2	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-01-23 12:00:00+00	2026-01-23 12:00:00+00
50684481-6edb-4fc7-8ef4-726503fce2d6	FT 2026/023	FT	2026-01-23	2026-01-23	6214c344-b5f9-4d17-b539-e367889ffa9c	WARREN COHEN INVESTMENT	\N	\N	[{"quantity": 1, "vat_rate": 0.16, "line_total": 948750, "unit_price": 817887.93, "vat_amount": 130862.07, "description": "Accommodation - WARREN COHEN INVESTMENT"}]	817887.93	130862.07	948750	MZN	1	issued	QTu20pGl	A:123456789*B:999999999*C:MZ*D:FT*E:N*F:20260123*G:FT 2026/023*H:QTu20pGl*I1:MZ*N:130862.07*O:948750.00*Q:QTu20pGl	cd26d10b-3b86-4cf6-a0df-9c64b8c40aa1	3f5eba4a-fe6f-41d8-b744-07d882e169a2	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-01-23 12:00:00+00	2026-01-23 12:00:00+00
115a166c-b08d-4076-976d-1350c5abebb1	FT 2026/024	FT	2026-01-23	2026-01-23	6214c344-b5f9-4d17-b539-e367889ffa9c	WARREN PAY TRACY SALARY AND RECRUITMENT	\N	\N	[{"quantity": 1, "vat_rate": 0.16, "line_total": 458172, "unit_price": 394975.86, "vat_amount": 63196.14, "description": "Accommodation - WARREN PAY TRACY SALARY AND RECRUITMENT"}]	394975.86	63196.14	458172	MZN	1	issued	OSA4CgT1	A:123456789*B:999999999*C:MZ*D:FT*E:N*F:20260123*G:FT 2026/024*H:OSA4CgT1*I1:MZ*N:63196.14*O:458172.00*Q:OSA4CgT1	e542f423-107d-46b5-97c8-1c5ae2f29c0e	789c18ea-2005-443a-9510-2c4fca7a87f9	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-01-23 12:00:00+00	2026-01-23 12:00:00+00
8e7ac9c0-bed9-4981-bcd1-56186016139e	FT 2026/025	FT	2026-01-24	2026-01-24	b0e3af81-86f7-4e03-8742-a859303b62a6	CREDIT IVA H3 - KEITH & SUE X 8 NIGHTS @ 75	\N	\N	[{"quantity": 1, "vat_rate": 0.16, "line_total": 40200, "unit_price": 34655.17, "vat_amount": 5544.83, "description": "Accommodation - CREDIT IVA H3 - KEITH & SUE X 8 NIGHTS @ 75"}]	34655.17	5544.83	40200	MZN	1	issued	uA2/JCoT	A:123456789*B:999999999*C:MZ*D:FT*E:N*F:20260124*G:FT 2026/025*H:uA2/JCoT*I1:MZ*N:5544.83*O:40200.00*Q:uA2/JCoT	26b816ca-351b-4a11-af7b-a7157b77dcd9	3e80cd1d-a1cf-4cf2-90b5-cd58158b9332	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-01-24 12:00:00+00	2026-01-24 12:00:00+00
4ffe5633-202b-4da1-b002-e07b9fd21831	FT 2026/026	FT	2026-01-24	2026-01-24	bf17ad40-c04f-4438-8456-1bb96ebcecc7	WARREN	\N	\N	[{"quantity": 1, "vat_rate": 0.16, "line_total": 119000, "unit_price": 102586.21, "vat_amount": 16413.79, "description": "Accommodation - WARREN"}]	102586.21	16413.79	119000	MZN	1	issued	M3m3mxM9	A:123456789*B:999999999*C:MZ*D:FT*E:N*F:20260124*G:FT 2026/026*H:M3m3mxM9*I1:MZ*N:16413.79*O:119000.00*Q:M3m3mxM9	03ec732b-2cd8-4f8c-a74a-e22860fce4c2	47e07600-702f-47af-8957-0312b2ff88cc	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-01-24 12:00:00+00	2026-01-24 12:00:00+00
c0e2f43c-97b7-4efd-8d70-6ebe26b2e2ab	FT 2026/027	FT	2026-01-24	2026-01-24	b0e3af81-86f7-4e03-8742-a859303b62a6	ALEX	\N	\N	[{"quantity": 1, "vat_rate": 0.16, "line_total": 132000, "unit_price": 113793.1, "vat_amount": 18206.9, "description": "Accommodation - ALEX"}]	113793.1	18206.9	132000	MZN	1	issued	Pos42YoB	A:123456789*B:999999999*C:MZ*D:FT*E:N*F:20260124*G:FT 2026/027*H:Pos42YoB*I1:MZ*N:18206.90*O:132000.00*Q:Pos42YoB	da4944ec-9ec9-42fe-9b87-85aaecaa5d04	5d5f37de-0766-4c31-ba8c-870f26f4c22f	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-01-24 12:00:00+00	2026-01-24 12:00:00+00
3b97fd04-03d7-4df6-8421-9213f18973ab	FT 2026/028	FT	2026-01-24	2026-01-24	ea35b0ac-a1c4-4269-ac14-c52e1de9d514	TAFY	\N	\N	[{"quantity": 1, "vat_rate": 0.16, "line_total": 551000, "unit_price": 475000, "vat_amount": 76000, "description": "Accommodation - TAFY"}]	475000	76000	551000	MZN	1	issued	NTvHj4uf	A:123456789*B:999999999*C:MZ*D:FT*E:N*F:20260124*G:FT 2026/028*H:NTvHj4uf*I1:MZ*N:76000.00*O:551000.00*Q:NTvHj4uf	afaeed91-7caf-4e0c-a094-79a3193fb669	61d29e92-e33c-4f75-b76d-d37f390ee338	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-01-24 12:00:00+00	2026-01-24 12:00:00+00
a69c8b6f-2a7c-473b-9a9c-58283707f3d6	FT 2026/029	FT	2026-01-24	2026-01-24	bf17ad40-c04f-4438-8456-1bb96ebcecc7	WARREN STEAD	\N	\N	[{"quantity": 1, "vat_rate": 0.16, "line_total": 958350, "unit_price": 826163.79, "vat_amount": 132186.21, "description": "Accommodation - WARREN STEAD"}]	826163.79	132186.21	958350	MZN	1	issued	Z1Ns3FI7	A:123456789*B:999999999*C:MZ*D:FT*E:N*F:20260124*G:FT 2026/029*H:Z1Ns3FI7*I1:MZ*N:132186.21*O:958350.00*Q:Z1Ns3FI7	fa134df7-0fff-43c5-8ffc-195c01bdf6a0	a28b19bd-9454-4c85-ad33-466f2a89d209	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-01-24 12:00:00+00	2026-01-24 12:00:00+00
14c1669e-2e96-4596-a52a-708be68a8be0	FT 2026/030	FT	2026-01-28	2026-01-28	ea35b0ac-a1c4-4269-ac14-c52e1de9d514	TAFY RE ROBIN	\N	\N	[{"quantity": 1, "vat_rate": 0.16, "line_total": 207000, "unit_price": 178448.28, "vat_amount": 28551.72, "description": "Accommodation - TAFY RE ROBIN"}]	178448.28	28551.72	207000	MZN	1	issued	MwUOGwuW	A:123456789*B:999999999*C:MZ*D:FT*E:N*F:20260128*G:FT 2026/030*H:MwUOGwuW*I1:MZ*N:28551.72*O:207000.00*Q:MwUOGwuW	bc55651d-20d3-4d01-aec8-5d8104fc0e5b	b4939f29-4b22-484c-b543-6113ca54b506	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-01-28 12:00:00+00	2026-01-28 12:00:00+00
78a92ba6-5256-4e7d-a9cd-1c942c01d4bd	FT 2026/031	FT	2026-01-28	2026-01-28	6214c344-b5f9-4d17-b539-e367889ffa9c	WARREN INVESTMENT DOLLAR ACCOUNT	\N	\N	[{"quantity": 1, "vat_rate": 0.16, "line_total": 569250, "unit_price": 490732.76, "vat_amount": 78517.24, "description": "Accommodation - WARREN INVESTMENT DOLLAR ACCOUNT"}]	490732.76	78517.24	569250	MZN	1	issued	/gqWKqVC	A:123456789*B:999999999*C:MZ*D:FT*E:N*F:20260128*G:FT 2026/031*H:/gqWKqVC*I1:MZ*N:78517.24*O:569250.00*Q:/gqWKqVC	b9a4b698-c5db-45ec-a240-0ca761ef676a	f4533932-e0c5-4907-a863-aaa214cb6e69	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-01-28 12:00:00+00	2026-01-28 12:00:00+00
f7004bd1-5d74-4fde-897a-82738b4c5734	FT 2026/032	FT	2026-01-29	2026-01-29	b0e3af81-86f7-4e03-8742-a859303b62a6	KEIVIN PAY TO BANK	\N	\N	[{"quantity": 1, "vat_rate": 0.16, "line_total": 420000, "unit_price": 362068.97, "vat_amount": 57931.03, "description": "Accommodation - KEIVIN PAY TO BANK"}]	362068.97	57931.03	420000	MZN	1	issued	/BNTbawj	A:123456789*B:999999999*C:MZ*D:FT*E:N*F:20260129*G:FT 2026/032*H:/BNTbawj*I1:MZ*N:57931.03*O:420000.00*Q:/BNTbawj	687ae46e-4716-4153-85f6-6b79d201cb7a	0d90e6c9-be85-41ce-96b4-2343d69151d1	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-01-29 12:00:00+00	2026-01-29 12:00:00+00
ad9e44fc-2975-4102-80d0-c3a743789e37	FT 2026/033	FT	2026-02-01	2026-02-01	b0e3af81-86f7-4e03-8742-a859303b62a6	ALEX	\N	\N	[{"quantity": 1, "vat_rate": 0.16, "line_total": 594297, "unit_price": 512325, "vat_amount": 81972, "description": "Accommodation - ALEX"}]	512325	81972	594297	MZN	1	issued	CmkhTi6/	A:123456789*B:999999999*C:MZ*D:FT*E:N*F:20260201*G:FT 2026/033*H:CmkhTi6/*I1:MZ*N:81972.00*O:594297.00*Q:CmkhTi6/	4dfe9a53-1ccd-4013-bda2-5c1055bfd280	89416c2c-c14d-4595-a3f6-a03ef0067c65	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-02-01 12:00:00+00	2026-02-01 12:00:00+00
8518bda4-bbcc-4b98-b335-5ffb9b55dc38	FT 2026/034	FT	2026-02-02	2026-02-02	ea35b0ac-a1c4-4269-ac14-c52e1de9d514	ALEX	\N	\N	[{"quantity": 1, "vat_rate": 0.16, "line_total": 958350, "unit_price": 826163.79, "vat_amount": 132186.21, "description": "Accommodation - ALEX"}]	826163.79	132186.21	958350	MZN	1	issued	FWzidcoP	A:123456789*B:999999999*C:MZ*D:FT*E:N*F:20260202*G:FT 2026/034*H:FWzidcoP*I1:MZ*N:132186.21*O:958350.00*Q:FWzidcoP	90d0dc0f-19f9-4d08-bdf2-e16544dd6120	e3243d26-075f-46b8-bb97-9a705e26a74f	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-02-02 12:00:00+00	2026-02-02 12:00:00+00
1b4b187b-575a-451e-9d2b-36aec7dcb9a0	FT 2026/035	FT	2026-02-03	2026-02-03	b0e3af81-86f7-4e03-8742-a859303b62a6	ALEX	\N	\N	[{"quantity": 1, "vat_rate": 0.16, "line_total": 751171, "unit_price": 647561.21, "vat_amount": 103609.79, "description": "Accommodation - ALEX"}]	647561.21	103609.79	751171	MZN	1	issued	1fueAk/2	A:123456789*B:999999999*C:MZ*D:FT*E:N*F:20260203*G:FT 2026/035*H:1fueAk/2*I1:MZ*N:103609.79*O:751171.00*Q:1fueAk/2	9acea114-3cbd-434e-bcee-2b62e6a7216b	28d743c5-c796-43cf-95a7-56675fbfc003	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-02-03 12:00:00+00	2026-02-03 12:00:00+00
7ca799af-0b01-4d7e-b442-db07951a6bad	FT 2026/036	FT	2026-02-08	2026-02-08	bf17ad40-c04f-4438-8456-1bb96ebcecc7	WARREN STEAD DEP BANK	\N	\N	[{"quantity": 1, "vat_rate": 0.16, "line_total": 948750, "unit_price": 817887.93, "vat_amount": 130862.07, "description": "Accommodation - WARREN STEAD DEP BANK"}]	817887.93	130862.07	948750	MZN	1	issued	+YdG1woD	A:123456789*B:999999999*C:MZ*D:FT*E:N*F:20260208*G:FT 2026/036*H:+YdG1woD*I1:MZ*N:130862.07*O:948750.00*Q:+YdG1woD	6e94b6a6-091f-425c-b6b8-e53a2de972ff	58d63911-f366-4cc3-aa61-b91c17923f34	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-02-08 12:00:00+00	2026-02-08 12:00:00+00
945685bf-3257-4544-a4fd-8ef37b608c19	FT 2026/037	FT	2026-02-09	2026-02-09	bf17ad40-c04f-4438-8456-1bb96ebcecc7	WARREN STEAD	\N	\N	[{"quantity": 1, "vat_rate": 0.16, "line_total": 941920, "unit_price": 812000, "vat_amount": 129920, "description": "Accommodation - WARREN STEAD"}]	812000	129920	941920	MZN	1	issued	0lAnu7+H	A:123456789*B:999999999*C:MZ*D:FT*E:N*F:20260209*G:FT 2026/037*H:0lAnu7+H*I1:MZ*N:129920.00*O:941920.00*Q:0lAnu7+H	1f898a27-907b-4a8a-84e3-cfa3dc671c94	aa467779-c14a-4d6f-a6b9-35ac5b6eee12	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-02-09 12:00:00+00	2026-02-09 12:00:00+00
11742975-a6b0-4c2c-aea3-e67023630a23	FT 2026/038	FT	2026-02-10	2026-02-10	ea35b0ac-a1c4-4269-ac14-c52e1de9d514	CREDIT IVA H1 - LESLEY X 6 NIGHTS	\N	\N	[{"quantity": 1, "vat_rate": 0.16, "line_total": 68000, "unit_price": 58620.69, "vat_amount": 9379.31, "description": "Accommodation - CREDIT IVA H1 - LESLEY X 6 NIGHTS"}]	58620.69	9379.31	68000	MZN	1	issued	8P1K9fGa	A:123456789*B:999999999*C:MZ*D:FT*E:N*F:20260210*G:FT 2026/038*H:8P1K9fGa*I1:MZ*N:9379.31*O:68000.00*Q:8P1K9fGa	c348fb39-02c9-444f-96d7-785677486d78	42cb4ea2-d9f9-4cbd-a995-a3bcddd54631	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-02-10 12:00:00+00	2026-02-10 12:00:00+00
7925e367-3784-4c9f-a921-a3b9962829aa	FT 2026/039	FT	2026-02-11	2026-02-11	b0e3af81-86f7-4e03-8742-a859303b62a6	ALEX	\N	\N	[{"quantity": 1, "vat_rate": 0.16, "line_total": 638900, "unit_price": 550775.86, "vat_amount": 88124.14, "description": "Accommodation - ALEX"}]	550775.86	88124.14	638900	MZN	1	issued	odtrHor1	A:123456789*B:999999999*C:MZ*D:FT*E:N*F:20260211*G:FT 2026/039*H:odtrHor1*I1:MZ*N:88124.14*O:638900.00*Q:odtrHor1	092ff6aa-01c0-424a-8321-525c41c65e2c	8668bd99-27c2-4582-ba7d-407981a4e034	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-02-11 12:00:00+00	2026-02-11 12:00:00+00
f432bc78-0fad-480b-b0ae-32c712663bb7	FT 2026/040	FT	2026-02-15	2026-02-15	bf17ad40-c04f-4438-8456-1bb96ebcecc7	BRENDON 7 DAYS @80	\N	\N	[{"quantity": 1, "vat_rate": 0.16, "line_total": 37520, "unit_price": 32344.83, "vat_amount": 5175.17, "description": "Accommodation - BRENDON 7 DAYS @80"}]	32344.83	5175.17	37520	MZN	1	issued	h8jRRzE6	A:123456789*B:999999999*C:MZ*D:FT*E:N*F:20260215*G:FT 2026/040*H:h8jRRzE6*I1:MZ*N:5175.17*O:37520.00*Q:h8jRRzE6	4a8c0b31-ceb5-4c61-b19b-3af5a5f20b4d	2679859c-de01-4d94-addc-c827ef72a59f	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-02-15 12:00:00+00	2026-02-15 12:00:00+00
e549a838-5023-4373-a3ca-ec25caead7a7	FT 2026/041	FT	2026-02-15	2026-02-15	ea35b0ac-a1c4-4269-ac14-c52e1de9d514	TAFY RECEIVED FROM ROBIN	\N	\N	[{"quantity": 1, "vat_rate": 0.16, "line_total": 465650, "unit_price": 401422.41, "vat_amount": 64227.59, "description": "Accommodation - TAFY RECEIVED FROM ROBIN"}]	401422.41	64227.59	465650	MZN	1	issued	wvX6Gh6M	A:123456789*B:999999999*C:MZ*D:FT*E:N*F:20260215*G:FT 2026/041*H:wvX6Gh6M*I1:MZ*N:64227.59*O:465650.00*Q:wvX6Gh6M	752c8b55-5b8b-4678-93b4-99ed6ec43091	43303196-8ac1-4e73-af2d-ee85e166851b	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-02-15 12:00:00+00	2026-02-15 12:00:00+00
ecc3808e-22d0-4b09-89a9-3d36cc5668ef	FT 2026/042	FT	2026-02-15	2026-02-15	bf17ad40-c04f-4438-8456-1bb96ebcecc7	WARREN STEAD	\N	\N	[{"quantity": 1, "vat_rate": 0.16, "line_total": 958350, "unit_price": 826163.79, "vat_amount": 132186.21, "description": "Accommodation - WARREN STEAD"}]	826163.79	132186.21	958350	MZN	1	issued	E53J6hNb	A:123456789*B:999999999*C:MZ*D:FT*E:N*F:20260215*G:FT 2026/042*H:E53J6hNb*I1:MZ*N:132186.21*O:958350.00*Q:E53J6hNb	dc6b8e89-566a-4f3d-9a00-aab2c7cf6b9c	ac45973e-7fce-449d-9517-e81b3eca33af	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-02-15 12:00:00+00	2026-02-15 12:00:00+00
94c685cd-92f0-4583-859d-c92002db7090	FT 2026/043	FT	2026-02-15	2026-02-15	ea35b0ac-a1c4-4269-ac14-c52e1de9d514	TAFY RECEIVED FROM ALEX	\N	\N	[{"quantity": 1, "vat_rate": 0.16, "line_total": 335000, "unit_price": 288793.1, "vat_amount": 46206.9, "description": "Accommodation - TAFY RECEIVED FROM ALEX"}]	288793.1	46206.9	335000	MZN	1	issued	qNEue2xB	A:123456789*B:999999999*C:MZ*D:FT*E:N*F:20260215*G:FT 2026/043*H:qNEue2xB*I1:MZ*N:46206.90*O:335000.00*Q:qNEue2xB	5fd793f3-5294-4934-b089-f6dbfe9a07dc	f00adeab-dfff-432a-9ace-dbf5cc31f1db	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-02-15 12:00:00+00	2026-02-15 12:00:00+00
0483fc35-f9f3-47af-8331-513b6db6ac26	FT 2026/044	FT	2026-02-15	2026-02-15	bf17ad40-c04f-4438-8456-1bb96ebcecc7	BRENDON	\N	\N	[{"quantity": 1, "vat_rate": 0.16, "line_total": 55200, "unit_price": 47586.21, "vat_amount": 7613.79, "description": "Accommodation - BRENDON"}]	47586.21	7613.79	55200	MZN	1	issued	aWwT/5a+	A:123456789*B:999999999*C:MZ*D:FT*E:N*F:20260215*G:FT 2026/044*H:aWwT/5a+*I1:MZ*N:7613.79*O:55200.00*Q:aWwT/5a+	3bcb4c43-1afc-4a14-83a8-e8cbee548977	6fb177a6-bfd7-45b3-8392-fd467b7daff1	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-02-15 12:00:00+00	2026-02-15 12:00:00+00
82be2064-1478-4420-87c0-1dff2409fe8f	FT 2026/045	FT	2026-02-15	2026-02-15	ea35b0ac-a1c4-4269-ac14-c52e1de9d514	TAFY	\N	\N	[{"quantity": 1, "vat_rate": 0.16, "line_total": 812375, "unit_price": 700323.28, "vat_amount": 112051.72, "description": "Accommodation - TAFY"}]	700323.28	112051.72	812375	MZN	1	issued	ixIkw9Ib	A:123456789*B:999999999*C:MZ*D:FT*E:N*F:20260215*G:FT 2026/045*H:ixIkw9Ib*I1:MZ*N:112051.72*O:812375.00*Q:ixIkw9Ib	34c2b0b3-58f3-436a-8ba6-35a188938c3e	b9c93133-281f-405c-8170-142fdadaf55c	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-02-15 12:00:00+00	2026-02-15 12:00:00+00
03732e90-3c2a-4b90-b11c-ffd9864b1e44	FT 2026/046	FT	2026-02-15	2026-02-15	ea35b0ac-a1c4-4269-ac14-c52e1de9d514	TAFY	\N	\N	[{"quantity": 1, "vat_rate": 0.16, "line_total": 335000, "unit_price": 288793.1, "vat_amount": 46206.9, "description": "Accommodation - TAFY"}]	288793.1	46206.9	335000	MZN	1	issued	iNzyiyyV	A:123456789*B:999999999*C:MZ*D:FT*E:N*F:20260215*G:FT 2026/046*H:iNzyiyyV*I1:MZ*N:46206.90*O:335000.00*Q:iNzyiyyV	d9ca6b0c-7d92-4983-a3b8-ef0de5affbba	ffbc4f79-e222-400d-97d7-19f797f13b07	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-02-15 12:00:00+00	2026-02-15 12:00:00+00
4b6d0104-111d-45a7-8bd6-8d4d56f923fd	FT 2026/047	FT	2026-02-16	2026-02-16	6214c344-b5f9-4d17-b539-e367889ffa9c	ARON ACCOMMODATION IN H4	\N	\N	[{"quantity": 1, "vat_rate": 0.16, "line_total": 98490, "unit_price": 84905.17, "vat_amount": 13584.83, "description": "Accommodation - ARON ACCOMMODATION IN H4"}]	84905.17	13584.83	98490	MZN	1	issued	EbxniidA	A:123456789*B:999999999*C:MZ*D:FT*E:N*F:20260216*G:FT 2026/047*H:EbxniidA*I1:MZ*N:13584.83*O:98490.00*Q:EbxniidA	c3a9ce6a-81e3-44b9-b714-1bf7bdf52fc9	2e3dfdb0-10d6-4e67-84da-5afd6adf8210	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-02-16 12:00:00+00	2026-02-16 12:00:00+00
282c1bc0-8060-439d-909a-364bd27f98e1	FT 2026/048	FT	2026-02-17	2026-02-17	b0e3af81-86f7-4e03-8742-a859303b62a6	ALEX	\N	\N	[{"quantity": 1, "vat_rate": 0.16, "line_total": 948750, "unit_price": 817887.93, "vat_amount": 130862.07, "description": "Accommodation - ALEX"}]	817887.93	130862.07	948750	MZN	1	issued	RkGvmEtz	A:123456789*B:999999999*C:MZ*D:FT*E:N*F:20260217*G:FT 2026/048*H:RkGvmEtz*I1:MZ*N:130862.07*O:948750.00*Q:RkGvmEtz	14021e21-fa0b-4e0c-8d4c-8755179cc230	1b490664-acec-4935-8cf7-04f0f49edd35	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-02-17 12:00:00+00	2026-02-17 12:00:00+00
78650675-c8c7-41f5-99d5-6448553153c3	FT 2026/049	FT	2026-02-18	2026-02-18	bf17ad40-c04f-4438-8456-1bb96ebcecc7	BRENDON	\N	\N	[{"quantity": 1, "vat_rate": 0.16, "line_total": 22400, "unit_price": 19310.34, "vat_amount": 3089.66, "description": "Accommodation - BRENDON"}]	19310.34	3089.66	22400	MZN	1	issued	FVE0eXdd	A:123456789*B:999999999*C:MZ*D:FT*E:N*F:20260218*G:FT 2026/049*H:FVE0eXdd*I1:MZ*N:3089.66*O:22400.00*Q:FVE0eXdd	69b77cba-e269-4b78-b4d4-7d4220e8764d	f05a6a09-cb41-44ef-b600-fcf2752ae029	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-02-18 12:00:00+00	2026-02-18 12:00:00+00
2cd83afc-2795-4e83-b053-d3f969e8c189	FT 2026/050	FT	2026-02-19	2026-02-19	6214c344-b5f9-4d17-b539-e367889ffa9c	WARREN COHEN INVESTMENT	\N	\N	[{"quantity": 1, "vat_rate": 0.16, "line_total": 948750, "unit_price": 817887.93, "vat_amount": 130862.07, "description": "Accommodation - WARREN COHEN INVESTMENT"}]	817887.93	130862.07	948750	MZN	1	issued	molsRqFh	A:123456789*B:999999999*C:MZ*D:FT*E:N*F:20260219*G:FT 2026/050*H:molsRqFh*I1:MZ*N:130862.07*O:948750.00*Q:molsRqFh	2779d770-7027-4b37-9902-3d94607d3572	39a7511c-ffc3-4a1d-afd8-133709ae055b	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-02-19 12:00:00+00	2026-02-19 12:00:00+00
b8fd54a9-097b-4b83-b8cc-a7592f148e51	FT 2026/051	FT	2026-02-20	2026-02-20	b0e3af81-86f7-4e03-8742-a859303b62a6	WARREN STEAD	\N	\N	[{"quantity": 1, "vat_rate": 0.16, "line_total": 958350, "unit_price": 826163.79, "vat_amount": 132186.21, "description": "Accommodation - WARREN STEAD"}]	826163.79	132186.21	958350	MZN	1	issued	PXrPN6qG	A:123456789*B:999999999*C:MZ*D:FT*E:N*F:20260220*G:FT 2026/051*H:PXrPN6qG*I1:MZ*N:132186.21*O:958350.00*Q:PXrPN6qG	9d34c92c-d0a6-44e2-a6c3-d15957da8145	1b39ccd0-eb2f-430b-8c68-2bb09896df92	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-02-20 12:00:00+00	2026-02-20 12:00:00+00
f2d8ed30-de71-4284-8314-13a36ee54ad6	FT 2026/052	FT	2026-02-21	2026-02-21	6214c344-b5f9-4d17-b539-e367889ffa9c	ALAIN WARREN	\N	\N	[{"quantity": 1, "vat_rate": 0.16, "line_total": 60720, "unit_price": 52344.83, "vat_amount": 8375.17, "description": "Accommodation - ALAIN WARREN"}]	52344.83	8375.17	60720	MZN	1	issued	qvG82fFB	A:123456789*B:999999999*C:MZ*D:FT*E:N*F:20260221*G:FT 2026/052*H:qvG82fFB*I1:MZ*N:8375.17*O:60720.00*Q:qvG82fFB	1faa3a4a-8859-437d-ae14-5d4232c21e3b	c068d7bf-1c26-46a3-bab9-a112ce006ddf	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-02-21 12:00:00+00	2026-02-21 12:00:00+00
368b2981-40f9-449b-a97b-9386eca6fa64	FT 2026/053	FT	2026-02-22	2026-02-22	ea35b0ac-a1c4-4269-ac14-c52e1de9d514	TAFY RECEIVED FROM AANGIE	\N	\N	[{"quantity": 1, "vat_rate": 0.16, "line_total": 310000, "unit_price": 267241.38, "vat_amount": 42758.62, "description": "Accommodation - TAFY RECEIVED FROM AANGIE"}]	267241.38	42758.62	310000	MZN	1	issued	kc5+m2W+	A:123456789*B:999999999*C:MZ*D:FT*E:N*F:20260222*G:FT 2026/053*H:kc5+m2W+*I1:MZ*N:42758.62*O:310000.00*Q:kc5+m2W+	99001375-4cc9-4f62-9374-518be7a9b426	0954ba9d-44f9-49ce-9be7-202a9406c7ab	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-02-22 12:00:00+00	2026-02-22 12:00:00+00
095d1eed-f700-4196-83e1-1c4c022aecf1	FT 2026/054	FT	2026-02-22	2026-02-22	b0e3af81-86f7-4e03-8742-a859303b62a6	ALEX TRANSFER TO MONIQUE	\N	\N	[{"quantity": 1, "vat_rate": 0.16, "line_total": 222300, "unit_price": 191637.93, "vat_amount": 30662.07, "description": "Accommodation - ALEX TRANSFER TO MONIQUE"}]	191637.93	30662.07	222300	MZN	1	issued	/Y6fo4Fx	A:123456789*B:999999999*C:MZ*D:FT*E:N*F:20260222*G:FT 2026/054*H:/Y6fo4Fx*I1:MZ*N:30662.07*O:222300.00*Q:/Y6fo4Fx	aaf65970-10e5-4c38-b835-8bdb91e90817	4ebfbc50-3764-4c6e-ac5f-978bf0566cad	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-02-22 12:00:00+00	2026-02-22 12:00:00+00
628dfdd5-a3b1-4915-bc61-853d4bca6bc4	FT 2026/055	FT	2026-02-23	2026-02-23	6214c344-b5f9-4d17-b539-e367889ffa9c	WARREN PAY TRACY SALARY AND RECRUITMENT	\N	\N	[{"quantity": 1, "vat_rate": 0.16, "line_total": 458172, "unit_price": 394975.86, "vat_amount": 63196.14, "description": "Accommodation - WARREN PAY TRACY SALARY AND RECRUITMENT"}]	394975.86	63196.14	458172	MZN	1	issued	sAE/FQFb	A:123456789*B:999999999*C:MZ*D:FT*E:N*F:20260223*G:FT 2026/055*H:sAE/FQFb*I1:MZ*N:63196.14*O:458172.00*Q:sAE/FQFb	e145dc08-f86a-4899-861e-1c2947dc2ec1	8efa9f82-4b4f-4c07-8e39-f3460e0323ff	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-02-23 12:00:00+00	2026-02-23 12:00:00+00
b7e45606-a4b5-4c98-9b53-a87644043e0e	FT 2026/056	FT	2026-02-23	2026-02-23	b0e3af81-86f7-4e03-8742-a859303b62a6	ALEX	\N	\N	[{"quantity": 1, "vat_rate": 0.16, "line_total": 293480, "unit_price": 253000, "vat_amount": 40480, "description": "Accommodation - ALEX"}]	253000	40480	293480	MZN	1	issued	qxw7Uw0X	A:123456789*B:999999999*C:MZ*D:FT*E:N*F:20260223*G:FT 2026/056*H:qxw7Uw0X*I1:MZ*N:40480.00*O:293480.00*Q:qxw7Uw0X	c26bae19-f04e-4b0d-be5b-cc3e401be8c5	bf9e2cf4-6cb0-4a25-9903-c0423e0a3794	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-02-23 12:00:00+00	2026-02-23 12:00:00+00
ffbc1729-26a4-4155-95a0-bcfa73108e2e	FT 2026/057	FT	2026-02-23	2026-02-23	6214c344-b5f9-4d17-b539-e367889ffa9c	WARREN COHEN INVESTMENT	\N	\N	[{"quantity": 1, "vat_rate": 0.16, "line_total": 948750, "unit_price": 817887.93, "vat_amount": 130862.07, "description": "Accommodation - WARREN COHEN INVESTMENT"}]	817887.93	130862.07	948750	MZN	1	issued	I2yPyR6m	A:123456789*B:999999999*C:MZ*D:FT*E:N*F:20260223*G:FT 2026/057*H:I2yPyR6m*I1:MZ*N:130862.07*O:948750.00*Q:I2yPyR6m	f1883d19-e0db-4067-b665-089f2f66cd75	f59bd5ac-d1fe-4f3d-a5f7-f73bfa63f7c5	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-02-23 12:00:00+00	2026-02-23 12:00:00+00
66f07447-0739-4bdb-a98e-c426efeffaff	FT 2026/058	FT	2026-02-24	2026-02-24	bf17ad40-c04f-4438-8456-1bb96ebcecc7	WARREN STEAD	\N	\N	[{"quantity": 1, "vat_rate": 0.16, "line_total": 958350, "unit_price": 826163.79, "vat_amount": 132186.21, "description": "Accommodation - WARREN STEAD"}]	826163.79	132186.21	958350	MZN	1	issued	bd9lbgd6	A:123456789*B:999999999*C:MZ*D:FT*E:N*F:20260224*G:FT 2026/058*H:bd9lbgd6*I1:MZ*N:132186.21*O:958350.00*Q:bd9lbgd6	6349b650-82d2-48af-8ce0-f7e796591d10	5d92494f-2e2c-4490-9707-f36b342659c7	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-02-24 12:00:00+00	2026-02-24 12:00:00+00
ed55a9a4-1678-4439-b8c6-1448531b71fa	FT 2026/059	FT	2026-02-24	2026-02-24	b0e3af81-86f7-4e03-8742-a859303b62a6	CREDIT IVA H3 - KEITH & SUE X 8 NIGHTS @ 75	\N	\N	[{"quantity": 1, "vat_rate": 0.16, "line_total": 40200, "unit_price": 34655.17, "vat_amount": 5544.83, "description": "Accommodation - CREDIT IVA H3 - KEITH & SUE X 8 NIGHTS @ 75"}]	34655.17	5544.83	40200	MZN	1	issued	IxMOMWuz	A:123456789*B:999999999*C:MZ*D:FT*E:N*F:20260224*G:FT 2026/059*H:IxMOMWuz*I1:MZ*N:5544.83*O:40200.00*Q:IxMOMWuz	878c6e58-822f-481b-87ec-0920aa7d7c29	88e4aaa9-1c37-4bff-b576-537e13c21c49	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-02-24 12:00:00+00	2026-02-24 12:00:00+00
73df97f9-59ab-4791-aa52-2728083dbeff	FT 2026/060	FT	2026-02-24	2026-02-24	b0e3af81-86f7-4e03-8742-a859303b62a6	ALEX	\N	\N	[{"quantity": 1, "vat_rate": 0.16, "line_total": 132000, "unit_price": 113793.1, "vat_amount": 18206.9, "description": "Accommodation - ALEX"}]	113793.1	18206.9	132000	MZN	1	issued	lYf6pzsq	A:123456789*B:999999999*C:MZ*D:FT*E:N*F:20260224*G:FT 2026/060*H:lYf6pzsq*I1:MZ*N:18206.90*O:132000.00*Q:lYf6pzsq	e7d2226e-dd88-45cb-9ab8-d67693c58368	e3c36357-efda-449f-ac66-7995134b348b	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-02-24 12:00:00+00	2026-02-24 12:00:00+00
97916d66-6b4f-4d83-8a3e-0525cf8bf51f	FT 2026/061	FT	2026-02-24	2026-02-24	bf17ad40-c04f-4438-8456-1bb96ebcecc7	WARREN	\N	\N	[{"quantity": 1, "vat_rate": 0.16, "line_total": 119000, "unit_price": 102586.21, "vat_amount": 16413.79, "description": "Accommodation - WARREN"}]	102586.21	16413.79	119000	MZN	1	issued	1QeERFQ/	A:123456789*B:999999999*C:MZ*D:FT*E:N*F:20260224*G:FT 2026/061*H:1QeERFQ/*I1:MZ*N:16413.79*O:119000.00*Q:1QeERFQ/	82c0c79e-5a59-4608-a9f8-ec97f5c99ce7	61ce52c7-4a9c-4f3f-bfac-58bf65fabfca	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-02-24 12:00:00+00	2026-02-24 12:00:00+00
4758a3c3-76ca-4767-a168-fc89c6310642	FT 2026/062	FT	2026-02-24	2026-02-24	ea35b0ac-a1c4-4269-ac14-c52e1de9d514	TAFY	\N	\N	[{"quantity": 1, "vat_rate": 0.16, "line_total": 551000, "unit_price": 475000, "vat_amount": 76000, "description": "Accommodation - TAFY"}]	475000	76000	551000	MZN	1	issued	2PFSoQnX	A:123456789*B:999999999*C:MZ*D:FT*E:N*F:20260224*G:FT 2026/062*H:2PFSoQnX*I1:MZ*N:76000.00*O:551000.00*Q:2PFSoQnX	ae1c23f4-f70a-4ee9-b77a-819072fc1561	d421f077-7168-4dbb-9f8f-36ec861147ea	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-02-24 12:00:00+00	2026-02-24 12:00:00+00
945148ae-5a32-407c-b680-d94ff6d9d4bd	FT 2026/063	FT	2026-02-27	2026-02-27	b0e3af81-86f7-4e03-8742-a859303b62a6	KEIVIN PAY TO BANK	\N	\N	[{"quantity": 1, "vat_rate": 0.16, "line_total": 420000, "unit_price": 362068.97, "vat_amount": 57931.03, "description": "Accommodation - KEIVIN PAY TO BANK"}]	362068.97	57931.03	420000	MZN	1	issued	kcVQF+ZQ	A:123456789*B:999999999*C:MZ*D:FT*E:N*F:20260227*G:FT 2026/063*H:kcVQF+ZQ*I1:MZ*N:57931.03*O:420000.00*Q:kcVQF+ZQ	a82d3dc7-e567-48f1-b9f3-d55f79f98de5	32e3ecf3-b6bf-44d0-95ba-1aef3bdd20e2	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-02-27 12:00:00+00	2026-02-27 12:00:00+00
f7c04bf8-4705-4ed4-82bc-25a81ae232d4	FT 2026/064	FT	2026-02-27	2026-02-27	ea35b0ac-a1c4-4269-ac14-c52e1de9d514	TAFY RE ROBIN	\N	\N	[{"quantity": 1, "vat_rate": 0.16, "line_total": 207000, "unit_price": 178448.28, "vat_amount": 28551.72, "description": "Accommodation - TAFY RE ROBIN"}]	178448.28	28551.72	207000	MZN	1	issued	xLDRyU3z	A:123456789*B:999999999*C:MZ*D:FT*E:N*F:20260227*G:FT 2026/064*H:xLDRyU3z*I1:MZ*N:28551.72*O:207000.00*Q:xLDRyU3z	87bffe9f-3589-4eeb-a413-81d41f97c28e	28c75f42-ac37-48d9-8789-0b7e5555dbbe	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-02-27 12:00:00+00	2026-02-27 12:00:00+00
a5756ea8-5c0f-4de1-8b3f-1bd6dc2506cc	FT 2026/065	FT	2026-02-27	2026-02-27	6214c344-b5f9-4d17-b539-e367889ffa9c	WARREN INVESTMENT DOLLAR ACCOUNT	\N	\N	[{"quantity": 1, "vat_rate": 0.16, "line_total": 569250, "unit_price": 490732.76, "vat_amount": 78517.24, "description": "Accommodation - WARREN INVESTMENT DOLLAR ACCOUNT"}]	490732.76	78517.24	569250	MZN	1	issued	mKTIlw11	A:123456789*B:999999999*C:MZ*D:FT*E:N*F:20260227*G:FT 2026/065*H:mKTIlw11*I1:MZ*N:78517.24*O:569250.00*Q:mKTIlw11	7e5d464d-93fd-44d7-b673-9bd143afed80	9adaaca4-826b-48b3-8c21-bb5a1cc859bc	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-02-27 12:00:00+00	2026-02-27 12:00:00+00
5d6a6b83-8d95-489f-a0bd-44133c4a43b5	FT 2026/066	FT	2026-03-01	2026-03-01	b0e3af81-86f7-4e03-8742-a859303b62a6	ALEX	\N	\N	[{"quantity": 1, "vat_rate": 0.16, "line_total": 594297, "unit_price": 512325, "vat_amount": 81972, "description": "Accommodation - ALEX"}]	512325	81972	594297	MZN	1	issued	WfFgYmMn	A:123456789*B:999999999*C:MZ*D:FT*E:N*F:20260301*G:FT 2026/066*H:WfFgYmMn*I1:MZ*N:81972.00*O:594297.00*Q:WfFgYmMn	48333f31-bd2b-4ae9-8367-d48dc672533b	bce9e8ec-c843-473a-b25c-0cfee9bf62ba	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-03-01 12:00:00+00	2026-03-01 12:00:00+00
1e2b075b-bc93-4e89-9609-def7c6cca9ce	FT 2026/067	FT	2026-03-02	2026-03-02	ea35b0ac-a1c4-4269-ac14-c52e1de9d514	ALEX	\N	\N	[{"quantity": 1, "vat_rate": 0.16, "line_total": 958350, "unit_price": 826163.79, "vat_amount": 132186.21, "description": "Accommodation - ALEX"}]	826163.79	132186.21	958350	MZN	1	issued	mkD4ROUH	A:123456789*B:999999999*C:MZ*D:FT*E:N*F:20260302*G:FT 2026/067*H:mkD4ROUH*I1:MZ*N:132186.21*O:958350.00*Q:mkD4ROUH	f6cb5a78-020e-4d1b-aef7-e9d37adb84d6	507baae5-9a0d-4fe2-a281-664ce6b9abe3	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-03-02 12:00:00+00	2026-03-02 12:00:00+00
305d05d3-d1b8-4a36-a84d-7bffc5ae9236	FT 2026/068	FT	2026-03-03	2026-03-03	b0e3af81-86f7-4e03-8742-a859303b62a6	ALEX	\N	\N	[{"quantity": 1, "vat_rate": 0.16, "line_total": 751171, "unit_price": 647561.21, "vat_amount": 103609.79, "description": "Accommodation - ALEX"}]	647561.21	103609.79	751171	MZN	1	issued	0rFQ0v04	A:123456789*B:999999999*C:MZ*D:FT*E:N*F:20260303*G:FT 2026/068*H:0rFQ0v04*I1:MZ*N:103609.79*O:751171.00*Q:0rFQ0v04	63f05972-e49f-4c10-82f4-d08ffb5e10c5	c8a920cf-32cc-4688-988e-3c5cbdefdd80	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-03-03 12:00:00+00	2026-03-03 12:00:00+00
e4e0c557-f861-4321-8c25-2669cc75af75	FT 2026/069	FT	2026-03-08	2026-03-08	bf17ad40-c04f-4438-8456-1bb96ebcecc7	WARREN STEAD DEP BANK	\N	\N	[{"quantity": 1, "vat_rate": 0.16, "line_total": 948750, "unit_price": 817887.93, "vat_amount": 130862.07, "description": "Accommodation - WARREN STEAD DEP BANK"}]	817887.93	130862.07	948750	MZN	1	issued	GOn6Uy6M	A:123456789*B:999999999*C:MZ*D:FT*E:N*F:20260308*G:FT 2026/069*H:GOn6Uy6M*I1:MZ*N:130862.07*O:948750.00*Q:GOn6Uy6M	0a45eea3-943f-4037-bca2-4d7a5aef6e91	6c518ca9-1a4a-4dd1-87a8-ddecb93c26ce	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-03-08 12:00:00+00	2026-03-08 12:00:00+00
5d8ed113-4bcc-48b5-8180-e96255c2414b	FT 2026/070	FT	2026-03-09	2026-03-09	bf17ad40-c04f-4438-8456-1bb96ebcecc7	WARREN STEAD	\N	\N	[{"quantity": 1, "vat_rate": 0.16, "line_total": 941920, "unit_price": 812000, "vat_amount": 129920, "description": "Accommodation - WARREN STEAD"}]	812000	129920	941920	MZN	1	issued	0f/aUXsO	A:123456789*B:999999999*C:MZ*D:FT*E:N*F:20260309*G:FT 2026/070*H:0f/aUXsO*I1:MZ*N:129920.00*O:941920.00*Q:0f/aUXsO	5c8f19bd-2353-46bd-a190-36c66645ef4f	65450fd3-8332-42b9-be13-64b6ead6589d	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-03-09 12:00:00+00	2026-03-09 12:00:00+00
afafea53-3673-4031-b90d-6d647b378180	FT 2026/071	FT	2026-03-10	2026-03-10	ea35b0ac-a1c4-4269-ac14-c52e1de9d514	CREDIT IVA H1 - LESLEY X 6 NIGHTS	\N	\N	[{"quantity": 1, "vat_rate": 0.16, "line_total": 68000, "unit_price": 58620.69, "vat_amount": 9379.31, "description": "Accommodation - CREDIT IVA H1 - LESLEY X 6 NIGHTS"}]	58620.69	9379.31	68000	MZN	1	issued	L+nv6+VJ	A:123456789*B:999999999*C:MZ*D:FT*E:N*F:20260310*G:FT 2026/071*H:L+nv6+VJ*I1:MZ*N:9379.31*O:68000.00*Q:L+nv6+VJ	0f31bf99-0040-475f-96f8-117d491c5bc8	9709da80-d9bf-4352-a39d-70b54c30262e	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-03-10 12:00:00+00	2026-03-10 12:00:00+00
2d570a5b-a34c-4bf4-8b38-8dffdcb12a01	FT 2026/072	FT	2026-03-11	2026-03-11	b0e3af81-86f7-4e03-8742-a859303b62a6	ALEX	\N	\N	[{"quantity": 1, "vat_rate": 0.16, "line_total": 638900, "unit_price": 550775.86, "vat_amount": 88124.14, "description": "Accommodation - ALEX"}]	550775.86	88124.14	638900	MZN	1	issued	0RW/MQJ4	A:123456789*B:999999999*C:MZ*D:FT*E:N*F:20260311*G:FT 2026/072*H:0RW/MQJ4*I1:MZ*N:88124.14*O:638900.00*Q:0RW/MQJ4	26d387df-67c4-49d9-8bd6-c73b7b90d95e	46c7037b-5b3b-4fd4-be66-1c95614263af	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-03-11 12:00:00+00	2026-03-11 12:00:00+00
a17a61fa-ce8b-43a6-88ba-9562a3340fcb	FT 2026/073	FT	2026-03-15	2026-03-15	ea35b0ac-a1c4-4269-ac14-c52e1de9d514	TAFY RECEIVED FROM ROBIN	\N	\N	[{"quantity": 1, "vat_rate": 0.16, "line_total": 465650, "unit_price": 401422.41, "vat_amount": 64227.59, "description": "Accommodation - TAFY RECEIVED FROM ROBIN"}]	401422.41	64227.59	465650	MZN	1	issued	w/cZV1w7	A:123456789*B:999999999*C:MZ*D:FT*E:N*F:20260315*G:FT 2026/073*H:w/cZV1w7*I1:MZ*N:64227.59*O:465650.00*Q:w/cZV1w7	d762a09d-656a-4655-ba46-63b7f92030d9	03d462fe-3b12-4f49-8a73-ac2fd9bc0a4b	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-03-15 12:00:00+00	2026-03-15 12:00:00+00
226046ee-819c-40bf-bc56-7ebe68188aa7	FT 2026/074	FT	2026-03-15	2026-03-15	bf17ad40-c04f-4438-8456-1bb96ebcecc7	BRENDON	\N	\N	[{"quantity": 1, "vat_rate": 0.16, "line_total": 55200, "unit_price": 47586.21, "vat_amount": 7613.79, "description": "Accommodation - BRENDON"}]	47586.21	7613.79	55200	MZN	1	issued	NAnYp1Wb	A:123456789*B:999999999*C:MZ*D:FT*E:N*F:20260315*G:FT 2026/074*H:NAnYp1Wb*I1:MZ*N:7613.79*O:55200.00*Q:NAnYp1Wb	6863b383-ebd9-4de6-8bd0-7f4ffa2882c6	2aba1003-4b22-4460-a3ac-b4849587c5b0	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-03-15 12:00:00+00	2026-03-15 12:00:00+00
657a2306-3683-4d81-a97f-c3342b00c066	FT 2026/075	FT	2026-03-15	2026-03-15	6214c344-b5f9-4d17-b539-e367889ffa9c	WARREN COHEN INVESTMENT	\N	\N	[{"quantity": 1, "vat_rate": 0.16, "line_total": 1407000, "unit_price": 1212931.03, "vat_amount": 194068.97, "description": "Accommodation - WARREN COHEN INVESTMENT"}]	1212931.03	194068.97	1407000	MZN	1	issued	AoTj37SY	A:123456789*B:999999999*C:MZ*D:FT*E:N*F:20260315*G:FT 2026/075*H:AoTj37SY*I1:MZ*N:194068.97*O:1407000.00*Q:AoTj37SY	cfa3608a-4da5-438c-8066-d64d52f79acc	32a00646-183b-42d3-9492-0691f03f270a	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-03-15 12:00:00+00	2026-03-15 12:00:00+00
d038450a-5d73-4f77-8b2d-a72f448282ec	FT 2026/076	FT	2026-03-15	2026-03-15	ea35b0ac-a1c4-4269-ac14-c52e1de9d514	TAFY	\N	\N	[{"quantity": 1, "vat_rate": 0.16, "line_total": 335000, "unit_price": 288793.1, "vat_amount": 46206.9, "description": "Accommodation - TAFY"}]	288793.1	46206.9	335000	MZN	1	issued	clk2mMcJ	A:123456789*B:999999999*C:MZ*D:FT*E:N*F:20260315*G:FT 2026/076*H:clk2mMcJ*I1:MZ*N:46206.90*O:335000.00*Q:clk2mMcJ	9ea68823-2b5c-4adb-9252-00d45e9fec67	4546b618-cf6c-406e-bdf2-97e4232379c3	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-03-15 12:00:00+00	2026-03-15 12:00:00+00
4dafe3dd-807d-4ecc-a390-d9feef4775cd	FT 2026/077	FT	2026-03-15	2026-03-15	bf17ad40-c04f-4438-8456-1bb96ebcecc7	BRENDON 7 DAYS @80	\N	\N	[{"quantity": 1, "vat_rate": 0.16, "line_total": 37520, "unit_price": 32344.83, "vat_amount": 5175.17, "description": "Accommodation - BRENDON 7 DAYS @80"}]	32344.83	5175.17	37520	MZN	1	issued	G6cFK7rd	A:123456789*B:999999999*C:MZ*D:FT*E:N*F:20260315*G:FT 2026/077*H:G6cFK7rd*I1:MZ*N:5175.17*O:37520.00*Q:G6cFK7rd	7b385729-d24c-4dea-9539-e204646e9f13	82672f4e-fbdf-4cb3-bc5c-22654fadb3ea	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-03-15 12:00:00+00	2026-03-15 12:00:00+00
ff09803c-06aa-4cea-aab6-e4e3b5ce280f	FT 2026/078	FT	2026-03-15	2026-03-15	ea35b0ac-a1c4-4269-ac14-c52e1de9d514	TAFY RECEIVED FROM ALEX	\N	\N	[{"quantity": 1, "vat_rate": 0.16, "line_total": 335000, "unit_price": 288793.1, "vat_amount": 46206.9, "description": "Accommodation - TAFY RECEIVED FROM ALEX"}]	288793.1	46206.9	335000	MZN	1	issued	D9eSy3kR	A:123456789*B:999999999*C:MZ*D:FT*E:N*F:20260315*G:FT 2026/078*H:D9eSy3kR*I1:MZ*N:46206.90*O:335000.00*Q:D9eSy3kR	206d00a7-e385-431b-a1f0-820e7ed914d1	8f6349f7-9cc0-47a2-a156-d18152937a14	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-03-15 12:00:00+00	2026-03-15 12:00:00+00
5510131d-98a9-446a-b214-965ae8fd151e	FT 2026/079	FT	2026-03-15	2026-03-15	ea35b0ac-a1c4-4269-ac14-c52e1de9d514	TAFY ELIANA	\N	\N	[{"quantity": 1, "vat_rate": 0.16, "line_total": 38400, "unit_price": 33103.45, "vat_amount": 5296.55, "description": "Accommodation - TAFY ELIANA"}]	33103.45	5296.55	38400	MZN	1	issued	oZunWOgj	A:123456789*B:999999999*C:MZ*D:FT*E:N*F:20260315*G:FT 2026/079*H:oZunWOgj*I1:MZ*N:5296.55*O:38400.00*Q:oZunWOgj	fa22d2bc-b2ae-441a-9cb8-c8e65ce187c6	a06e08b9-620e-4a29-9f13-46a732e7b258	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-03-15 12:00:00+00	2026-03-15 12:00:00+00
a3c79750-9ee0-4d5d-862c-5a2ee0840954	FT 2026/080	FT	2026-03-15	2026-03-15	bf17ad40-c04f-4438-8456-1bb96ebcecc7	WARREN STEAD	\N	\N	[{"quantity": 1, "vat_rate": 0.16, "line_total": 958350, "unit_price": 826163.79, "vat_amount": 132186.21, "description": "Accommodation - WARREN STEAD"}]	826163.79	132186.21	958350	MZN	1	issued	LROrKLQW	A:123456789*B:999999999*C:MZ*D:FT*E:N*F:20260315*G:FT 2026/080*H:LROrKLQW*I1:MZ*N:132186.21*O:958350.00*Q:LROrKLQW	1ce836ed-220b-4496-8a9a-a740f187fa04	ae3885b7-6e81-4264-b7bb-e4596aa912d6	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-03-15 12:00:00+00	2026-03-15 12:00:00+00
bba741cc-c08f-4e22-80d1-5f5c2c243a6f	FT 2026/081	FT	2026-03-15	2026-03-15	ea35b0ac-a1c4-4269-ac14-c52e1de9d514	TAFY	\N	\N	[{"quantity": 1, "vat_rate": 0.16, "line_total": 812375, "unit_price": 700323.28, "vat_amount": 112051.72, "description": "Accommodation - TAFY"}]	700323.28	112051.72	812375	MZN	1	issued	Lhn7NNPJ	A:123456789*B:999999999*C:MZ*D:FT*E:N*F:20260315*G:FT 2026/081*H:Lhn7NNPJ*I1:MZ*N:112051.72*O:812375.00*Q:Lhn7NNPJ	49361d80-a483-454d-9edc-656a363e82c1	f1a7da25-4f70-49ac-b20a-9f3bc61859e1	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-03-15 12:00:00+00	2026-03-15 12:00:00+00
d3e51348-1d68-41c2-a3f8-52defae12fa9	FT 2026/082	FT	2026-03-16	2026-03-16	6214c344-b5f9-4d17-b539-e367889ffa9c	ARON ACCOMMODATION IN H4	\N	\N	[{"quantity": 1, "vat_rate": 0.16, "line_total": 98490, "unit_price": 84905.17, "vat_amount": 13584.83, "description": "Accommodation - ARON ACCOMMODATION IN H4"}]	84905.17	13584.83	98490	MZN	1	issued	YZPD4o/B	A:123456789*B:999999999*C:MZ*D:FT*E:N*F:20260316*G:FT 2026/082*H:YZPD4o/B*I1:MZ*N:13584.83*O:98490.00*Q:YZPD4o/B	55bc3e9d-d935-4cf1-b7ad-23faddfe7e07	0a9819b0-e317-44df-9c31-4a72beeb1733	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-03-16 12:00:00+00	2026-03-16 12:00:00+00
aa2ce594-88dd-41aa-8046-409210aa1df2	FT 2026/083	FT	2026-03-17	2026-03-17	b0e3af81-86f7-4e03-8742-a859303b62a6	ALEX	\N	\N	[{"quantity": 1, "vat_rate": 0.16, "line_total": 948750, "unit_price": 817887.93, "vat_amount": 130862.07, "description": "Accommodation - ALEX"}]	817887.93	130862.07	948750	MZN	1	issued	ZugbAGCK	A:123456789*B:999999999*C:MZ*D:FT*E:N*F:20260317*G:FT 2026/083*H:ZugbAGCK*I1:MZ*N:130862.07*O:948750.00*Q:ZugbAGCK	e4d1e4d1-a50a-41a0-bdfa-c2cc2e38cd0a	6f82d966-5bc5-49ac-8821-6e7b6ad78ff7	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-03-17 12:00:00+00	2026-03-17 12:00:00+00
2336cf71-70a0-4e37-bdf7-db3e94240e3a	FT 2026/084	FT	2026-03-18	2026-03-18	bf17ad40-c04f-4438-8456-1bb96ebcecc7	BRENDON	\N	\N	[{"quantity": 1, "vat_rate": 0.16, "line_total": 22400, "unit_price": 19310.34, "vat_amount": 3089.66, "description": "Accommodation - BRENDON"}]	19310.34	3089.66	22400	MZN	1	issued	yDAAEbH7	A:123456789*B:999999999*C:MZ*D:FT*E:N*F:20260318*G:FT 2026/084*H:yDAAEbH7*I1:MZ*N:3089.66*O:22400.00*Q:yDAAEbH7	411eac46-c4b3-42e5-a991-4f77314745f8	0a2d282f-f83c-4536-8352-7367b8d6fce1	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-03-18 12:00:00+00	2026-03-18 12:00:00+00
0d24dfce-0dd6-4656-9469-debd53ec68cb	FT 2026/085	FT	2026-03-19	2026-03-19	6214c344-b5f9-4d17-b539-e367889ffa9c	WARREN COHEN INVESTMENT	\N	\N	[{"quantity": 1, "vat_rate": 0.16, "line_total": 948750, "unit_price": 817887.93, "vat_amount": 130862.07, "description": "Accommodation - WARREN COHEN INVESTMENT"}]	817887.93	130862.07	948750	MZN	1	issued	IaWwE9OW	A:123456789*B:999999999*C:MZ*D:FT*E:N*F:20260319*G:FT 2026/085*H:IaWwE9OW*I1:MZ*N:130862.07*O:948750.00*Q:IaWwE9OW	d743140a-88ad-47fd-ae48-5ada617199ba	aafdbadf-98d3-41d7-8d44-77136e1f6ffb	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-03-19 12:00:00+00	2026-03-19 12:00:00+00
99faa9da-f378-4a0c-bc51-41020679c81f	FT 2026/086	FT	2026-03-20	2026-03-20	b0e3af81-86f7-4e03-8742-a859303b62a6	WARREN STEAD	\N	\N	[{"quantity": 1, "vat_rate": 0.16, "line_total": 958350, "unit_price": 826163.79, "vat_amount": 132186.21, "description": "Accommodation - WARREN STEAD"}]	826163.79	132186.21	958350	MZN	1	issued	bHd6dJMi	A:123456789*B:999999999*C:MZ*D:FT*E:N*F:20260320*G:FT 2026/086*H:bHd6dJMi*I1:MZ*N:132186.21*O:958350.00*Q:bHd6dJMi	a8aafe73-74ed-4759-9828-d6cb50be160f	0c836e99-c20a-4c86-95a3-756407ae2d31	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-03-20 12:00:00+00	2026-03-20 12:00:00+00
585ed5ea-feb4-4330-80f7-8e28bf37fb4e	FT 2026/087	FT	2026-03-21	2026-03-21	6214c344-b5f9-4d17-b539-e367889ffa9c	ALAIN WARREN	\N	\N	[{"quantity": 1, "vat_rate": 0.16, "line_total": 60720, "unit_price": 52344.83, "vat_amount": 8375.17, "description": "Accommodation - ALAIN WARREN"}]	52344.83	8375.17	60720	MZN	1	issued	+V4EymWU	A:123456789*B:999999999*C:MZ*D:FT*E:N*F:20260321*G:FT 2026/087*H:+V4EymWU*I1:MZ*N:8375.17*O:60720.00*Q:+V4EymWU	ded44176-e7f6-43d2-908b-6645e4481ab3	c9b0c7a8-91b0-442a-abf9-bf828612e05f	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-03-21 12:00:00+00	2026-03-21 12:00:00+00
700ccd2e-f94c-4128-830b-bc08a0939773	FT 2026/088	FT	2026-03-22	2026-03-22	b0e3af81-86f7-4e03-8742-a859303b62a6	ALEX TRANSFER TO MONIQUE	\N	\N	[{"quantity": 1, "vat_rate": 0.16, "line_total": 222300, "unit_price": 191637.93, "vat_amount": 30662.07, "description": "Accommodation - ALEX TRANSFER TO MONIQUE"}]	191637.93	30662.07	222300	MZN	1	issued	t/J5RwME	A:123456789*B:999999999*C:MZ*D:FT*E:N*F:20260322*G:FT 2026/088*H:t/J5RwME*I1:MZ*N:30662.07*O:222300.00*Q:t/J5RwME	03554493-32cc-45e1-a930-03703e07307b	a8c0e208-b799-4aab-aee3-9f687e8847b3	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-03-22 12:00:00+00	2026-03-22 12:00:00+00
a780cf95-0d86-4965-83ef-0842f773d6ce	FT 2026/089	FT	2026-03-22	2026-03-22	ea35b0ac-a1c4-4269-ac14-c52e1de9d514	TAFY RECEIVED FROM AANGIE	\N	\N	[{"quantity": 1, "vat_rate": 0.16, "line_total": 310000, "unit_price": 267241.38, "vat_amount": 42758.62, "description": "Accommodation - TAFY RECEIVED FROM AANGIE"}]	267241.38	42758.62	310000	MZN	1	issued	1ixQRw90	A:123456789*B:999999999*C:MZ*D:FT*E:N*F:20260322*G:FT 2026/089*H:1ixQRw90*I1:MZ*N:42758.62*O:310000.00*Q:1ixQRw90	5a759d36-c218-4541-9f61-cddb57ade7e6	c9fe6b5e-0a00-4f52-9d29-8059c20f0445	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-03-22 12:00:00+00	2026-03-22 12:00:00+00
88f4f1f1-1989-44cc-a0a4-42040d2d1ea4	FT 2026/090	FT	2026-03-23	2026-03-23	6214c344-b5f9-4d17-b539-e367889ffa9c	WARREN PAY TRACY SALARY AND RECRUITMENT	\N	\N	[{"quantity": 1, "vat_rate": 0.16, "line_total": 458172, "unit_price": 394975.86, "vat_amount": 63196.14, "description": "Accommodation - WARREN PAY TRACY SALARY AND RECRUITMENT"}]	394975.86	63196.14	458172	MZN	1	issued	4BYu5CWN	A:123456789*B:999999999*C:MZ*D:FT*E:N*F:20260323*G:FT 2026/090*H:4BYu5CWN*I1:MZ*N:63196.14*O:458172.00*Q:4BYu5CWN	97f8b77b-d458-4fa1-b001-20826cb5a5c4	365ef547-7b02-45eb-a8b4-9d80ed21fcbb	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-03-23 12:00:00+00	2026-03-23 12:00:00+00
6cedbbd6-dfac-48c1-afd5-9454d1ab3da4	FT 2026/091	FT	2026-03-23	2026-03-23	b0e3af81-86f7-4e03-8742-a859303b62a6	ALEX	\N	\N	[{"quantity": 1, "vat_rate": 0.16, "line_total": 293480, "unit_price": 253000, "vat_amount": 40480, "description": "Accommodation - ALEX"}]	253000	40480	293480	MZN	1	issued	hhfSH87g	A:123456789*B:999999999*C:MZ*D:FT*E:N*F:20260323*G:FT 2026/091*H:hhfSH87g*I1:MZ*N:40480.00*O:293480.00*Q:hhfSH87g	4d3ea5d5-c8cf-4925-a531-9221876b19db	4efa6d72-b18c-4c72-a374-e500c41a048a	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-03-23 12:00:00+00	2026-03-23 12:00:00+00
943be1bc-732e-44c7-8775-0cdbfd9a40a5	FT 2026/092	FT	2026-03-23	2026-03-23	6214c344-b5f9-4d17-b539-e367889ffa9c	WARREN COHEN INVESTMENT	\N	\N	[{"quantity": 1, "vat_rate": 0.16, "line_total": 948750, "unit_price": 817887.93, "vat_amount": 130862.07, "description": "Accommodation - WARREN COHEN INVESTMENT"}]	817887.93	130862.07	948750	MZN	1	issued	bUXV/uDY	A:123456789*B:999999999*C:MZ*D:FT*E:N*F:20260323*G:FT 2026/092*H:bUXV/uDY*I1:MZ*N:130862.07*O:948750.00*Q:bUXV/uDY	63797375-7ca4-44a8-8300-ad4e7c538392	d59bcdbf-c2bf-4f0f-a00e-236cdf78809f	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-03-23 12:00:00+00	2026-03-23 12:00:00+00
b1531dcf-45f6-4ea6-a626-539feed77284	FT 2026/093	FT	2026-03-24	2026-03-24	bf17ad40-c04f-4438-8456-1bb96ebcecc7	WARREN	\N	\N	[{"quantity": 1, "vat_rate": 0.16, "line_total": 119000, "unit_price": 102586.21, "vat_amount": 16413.79, "description": "Accommodation - WARREN"}]	102586.21	16413.79	119000	MZN	1	issued	GM3IoGtx	A:123456789*B:999999999*C:MZ*D:FT*E:N*F:20260324*G:FT 2026/093*H:GM3IoGtx*I1:MZ*N:16413.79*O:119000.00*Q:GM3IoGtx	951ba03c-1c13-441e-a38e-ed25e8966238	3bde08ef-4fdb-47d0-99ea-8a74ff0622df	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-03-24 12:00:00+00	2026-03-24 12:00:00+00
22425b23-2464-4102-9e60-c5ded3111e71	FT 2026/094	FT	2026-03-24	2026-03-24	ea35b0ac-a1c4-4269-ac14-c52e1de9d514	TAFY	\N	\N	[{"quantity": 1, "vat_rate": 0.16, "line_total": 551000, "unit_price": 475000, "vat_amount": 76000, "description": "Accommodation - TAFY"}]	475000	76000	551000	MZN	1	issued	jTzEkbyn	A:123456789*B:999999999*C:MZ*D:FT*E:N*F:20260324*G:FT 2026/094*H:jTzEkbyn*I1:MZ*N:76000.00*O:551000.00*Q:jTzEkbyn	b33219e3-86fa-403b-aa1e-39e51c09404a	41130366-59b1-4dbd-ab1f-a3635184e276	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-03-24 12:00:00+00	2026-03-24 12:00:00+00
7d4e8a55-4d8e-4c4f-b080-394a1f6744db	FT 2026/095	FT	2026-03-24	2026-03-24	b0e3af81-86f7-4e03-8742-a859303b62a6	CREDIT IVA H3 - KEITH & SUE X 8 NIGHTS @ 75	\N	\N	[{"quantity": 1, "vat_rate": 0.16, "line_total": 40200, "unit_price": 34655.17, "vat_amount": 5544.83, "description": "Accommodation - CREDIT IVA H3 - KEITH & SUE X 8 NIGHTS @ 75"}]	34655.17	5544.83	40200	MZN	1	issued	pBOlqnZg	A:123456789*B:999999999*C:MZ*D:FT*E:N*F:20260324*G:FT 2026/095*H:pBOlqnZg*I1:MZ*N:5544.83*O:40200.00*Q:pBOlqnZg	85888e62-46aa-4085-8dd7-c6e56d1ca454	70bb260c-b1e5-4576-9f1f-f6ffbdc16712	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-03-24 12:00:00+00	2026-03-24 12:00:00+00
ee6e024d-7be9-4e8c-9993-eebaafad39e0	FT 2026/096	FT	2026-03-24	2026-03-24	b0e3af81-86f7-4e03-8742-a859303b62a6	ALEX	\N	\N	[{"quantity": 1, "vat_rate": 0.16, "line_total": 132000, "unit_price": 113793.1, "vat_amount": 18206.9, "description": "Accommodation - ALEX"}]	113793.1	18206.9	132000	MZN	1	issued	ZyouJ4/p	A:123456789*B:999999999*C:MZ*D:FT*E:N*F:20260324*G:FT 2026/096*H:ZyouJ4/p*I1:MZ*N:18206.90*O:132000.00*Q:ZyouJ4/p	eb16be51-0c12-4db9-bda3-715f775279fe	79eb54a8-59f1-4338-85ce-bdaf666a1923	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-03-24 12:00:00+00	2026-03-24 12:00:00+00
08388579-238a-4cba-ad61-b4b6165af82b	FT 2026/097	FT	2026-03-24	2026-03-24	bf17ad40-c04f-4438-8456-1bb96ebcecc7	WARREN STEAD	\N	\N	[{"quantity": 1, "vat_rate": 0.16, "line_total": 958350, "unit_price": 826163.79, "vat_amount": 132186.21, "description": "Accommodation - WARREN STEAD"}]	826163.79	132186.21	958350	MZN	1	issued	qPKeAVzJ	A:123456789*B:999999999*C:MZ*D:FT*E:N*F:20260324*G:FT 2026/097*H:qPKeAVzJ*I1:MZ*N:132186.21*O:958350.00*Q:qPKeAVzJ	a9629fb9-c052-4fea-8fb7-03ae1f781a86	e4ce331c-97d3-4f10-8358-54defd15f2f8	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-03-24 12:00:00+00	2026-03-24 12:00:00+00
af30ab59-636e-4a76-8bcc-949d26fa1a0f	FT 2026/098	FT	2026-03-28	2026-03-28	6214c344-b5f9-4d17-b539-e367889ffa9c	WARREN INVESTMENT DOLLAR ACCOUNT	\N	\N	[{"quantity": 1, "vat_rate": 0.16, "line_total": 569250, "unit_price": 490732.76, "vat_amount": 78517.24, "description": "Accommodation - WARREN INVESTMENT DOLLAR ACCOUNT"}]	490732.76	78517.24	569250	MZN	1	issued	sBZlcHUX	A:123456789*B:999999999*C:MZ*D:FT*E:N*F:20260328*G:FT 2026/098*H:sBZlcHUX*I1:MZ*N:78517.24*O:569250.00*Q:sBZlcHUX	e7d59e7e-9db7-4174-8860-58ebcf24cc93	8d28d047-767a-47e8-bd14-0ceba680ccde	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-03-28 12:00:00+00	2026-03-28 12:00:00+00
abb0ee4e-1803-4bdf-a944-bcbe83bcb51c	FT 2026/099	FT	2026-03-28	2026-03-28	ea35b0ac-a1c4-4269-ac14-c52e1de9d514	TAFY RE ROBIN	\N	\N	[{"quantity": 1, "vat_rate": 0.16, "line_total": 207000, "unit_price": 178448.28, "vat_amount": 28551.72, "description": "Accommodation - TAFY RE ROBIN"}]	178448.28	28551.72	207000	MZN	1	issued	6ZskYRRm	A:123456789*B:999999999*C:MZ*D:FT*E:N*F:20260328*G:FT 2026/099*H:6ZskYRRm*I1:MZ*N:28551.72*O:207000.00*Q:6ZskYRRm	6da826be-190e-480b-a2a1-e9a28f5491b2	dd74dd95-4703-4e1a-86e2-3ad6a1f9ce1c	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-03-28 12:00:00+00	2026-03-28 12:00:00+00
bcf1f624-0d81-4fc4-8e2a-88ddba1607a7	FT 2026/100	FT	2026-03-29	2026-03-29	b0e3af81-86f7-4e03-8742-a859303b62a6	KEIVIN PAY TO BANK	\N	\N	[{"quantity": 1, "vat_rate": 0.16, "line_total": 420000, "unit_price": 362068.97, "vat_amount": 57931.03, "description": "Accommodation - KEIVIN PAY TO BANK"}]	362068.97	57931.03	420000	MZN	1	issued	88drX/bQ	A:123456789*B:999999999*C:MZ*D:FT*E:N*F:20260329*G:FT 2026/100*H:88drX/bQ*I1:MZ*N:57931.03*O:420000.00*Q:88drX/bQ	a0162379-4a21-4be9-bfec-2b28529b3a19	c4145cdc-0c44-419c-a0c0-554fd67b4e79	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-03-29 12:00:00+00	2026-03-29 12:00:00+00
6e7812c9-e041-4085-a7df-ad70f5d52098	IMP 2026/94	IMP	2026-01-09	\N	\N	HALWICK TRANSPORT RE BUDGIE	\N	\N	[{"qty": 1, "unit": 242887.93103448275, "amount": 281750, "vat_rate": 0.16000000000000003, "description": "HALWICK TRANSPORT RE BUDGIE"}]	242887.93103448275	38862.06896551725	281750	MZN	1	imported	\N	\N	\N	\N	\N	2026-04-22 06:12:26.158204+00	2026-04-22 06:12:26.158204+00
bedd751e-807b-4dc9-bfc8-088b98ca79eb	IMP 2026/95	IMP	2026-02-10	\N	\N	TAFY CHIGUMBU	\N	\N	[{"qty": 1, "unit": 75900, "amount": 88044, "vat_rate": 0.16, "description": "TAFY CHIGUMBU"}]	75900	12144	88044	MZN	1	imported	\N	\N	\N	\N	\N	2026-04-22 06:12:28.295005+00	2026-04-22 06:12:28.295005+00
949d69d7-8a6a-4dc4-8ea2-e9311db1743d	IMP 2026/96	IMP	2026-03-20	\N	\N	LINDA CLACK	\N	\N	[{"qty": 1, "unit": 379500, "amount": 440220, "vat_rate": 0.16, "description": "LINDA CLACK"}]	379500	60720	440220	MZN	1	imported	\N	\N	\N	\N	\N	2026-04-22 06:12:30.299882+00	2026-04-22 06:12:30.299882+00
\.


--
-- Data for Name: irps_payments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.irps_payments (id, month, year, amount, payment_date, reference, created_at) FROM stdin;
\.


--
-- Data for Name: journal_entries; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.journal_entries (id, entry_date, reference, description, entry_type, property_id, posted, posted_at, posted_by, created_by, created_at) FROM stdin;
7e05dad7-7a50-46ba-8719-edf0779184ca	2026-01-11	jan26.xlsx	Supplier invoice ??? TRANSFER FEE (1/2026)	supplier_invoice	\N	f	\N	\N	\N	2026-04-21 17:11:01.209686+00
b39b2d3a-6860-4c6a-a12e-f7263effc15b	2026-01-12	jan26.xlsx	Supplier invoice ??? TRANSFER FEE (1/2026)	supplier_invoice	\N	f	\N	\N	\N	2026-04-21 17:11:01.785455+00
7a4e4cc8-2e5a-4d92-9de4-f56c2038cef6	2026-01-20	jan26.xlsx	Supplier invoice ??? TRANSFER FEE (1/2026)	supplier_invoice	\N	f	\N	\N	\N	2026-04-21 17:11:02.350445+00
fa272459-f525-49fb-927e-859f21f5951e	2026-01-23	jan26.xlsx	Supplier invoice ??? COTOVELO PVC (1/2026)	supplier_invoice	\N	f	\N	\N	\N	2026-04-21 17:11:02.920699+00
a1e4bf57-2b0a-484d-b572-f68fb58c8557	2026-01-23	jan26.xlsx	Supplier invoice ??? BANK CHARGES (1/2026)	supplier_invoice	\N	f	\N	\N	\N	2026-04-21 17:11:03.505501+00
d47bdc0c-eb31-40fb-9431-68539d099079	2026-01-28	jan26.xlsx	Supplier invoice ??? DILUENTE ESMALTE QD 750ML (1/2026)	supplier_invoice	\N	f	\N	\N	\N	2026-04-21 17:11:04.114491+00
e64b14a4-1449-4484-8256-c7fdfdb5f382	2026-01-29	jan26.xlsx	Supplier invoice ??? LESCO - CX PROVA DE AGUA 4X4 (1/2026)	supplier_invoice	\N	f	\N	\N	\N	2026-04-21 17:11:04.687614+00
c0c4721b-387c-408c-b60a-c10ab2559e37	2026-01-06	jan26.xlsx	Supplier invoice ??? BEBE (1/2026)	supplier_invoice	\N	f	\N	\N	\N	2026-04-21 17:11:05.261272+00
4a8c839e-b13a-4623-be10-ad485968d37f	2026-01-23	jan26.xlsx	Supplier invoice ??? TRANSFER TO PRE-PAID (1/2026)	supplier_invoice	\N	f	\N	\N	\N	2026-04-21 17:11:05.839543+00
2bdc2163-568c-4a39-89a0-84648a0f29e4	2026-01-23	jan26.xlsx	Supplier invoice ??? TRANSFER (1/2026)	supplier_invoice	\N	f	\N	\N	\N	2026-04-21 17:11:06.456803+00
109e24b2-2122-42ec-8e8c-eb57bef982fd	2026-01-12	jan26.xlsx	Supplier invoice ??? MATIAS (1/2026)	supplier_invoice	\N	f	\N	\N	\N	2026-04-21 17:11:07.049284+00
c50dde20-2d91-4f8e-b2b2-582bf222eb2c	2026-01-31	jan26.xlsx	Supplier invoice ??? CHRIS (1/2026)	supplier_invoice	\N	f	\N	\N	\N	2026-04-21 17:11:07.602485+00
1c425d00-f1cf-4d3a-8f85-654509498fa1	2026-03-09	mar26.xlsx	Supplier invoice ??? VARNISH (3/2026)	supplier_invoice	\N	f	\N	\N	\N	2026-04-21 17:11:15.776658+00
af28dd0c-0020-40df-8d1d-9fae46b401e7	2026-03-09	mar26.xlsx	Supplier invoice ??? BANK CHARGES (3/2026)	supplier_invoice	\N	f	\N	\N	\N	2026-04-21 17:11:16.34256+00
1d137822-619d-440e-bac3-3e5a7edbecaa	2026-03-16	mar26.xlsx	Supplier invoice ??? PLASTIC DE LUXO (3/2026)	supplier_invoice	\N	f	\N	\N	\N	2026-04-21 17:11:16.909651+00
2383350e-7a15-4b49-b9ac-ab7c33b9f49a	2026-03-18	mar26.xlsx	Supplier invoice ??? BANK CHARGES (3/2026)	supplier_invoice	\N	f	\N	\N	\N	2026-04-21 17:11:17.461048+00
e75a86ee-42c9-466e-9978-bdf0f1bc8ff9	2026-03-19	mar26.xlsx	Supplier invoice ??? CLEANING MATERIAL (3/2026)	supplier_invoice	\N	f	\N	\N	\N	2026-04-21 17:11:18.029895+00
6665feb8-ec43-41e8-a8e6-479fa51c33f3	2026-03-19	mar26.xlsx	Supplier invoice ??? BANK CHARGES (3/2026)	supplier_invoice	\N	f	\N	\N	\N	2026-04-21 17:11:18.606656+00
ef789ae0-f38c-4012-bff0-e6b7ce7bc81c	2026-03-25	mar26.xlsx	Supplier invoice ??? BANK CHARGES (3/2026)	supplier_invoice	\N	f	\N	\N	\N	2026-04-21 17:11:19.201154+00
2128c23d-cd0b-479e-b945-9ab84988d0c3	2026-03-27	mar26.xlsx	Supplier invoice ??? SOAP, JAVEL (3/2026)	supplier_invoice	\N	f	\N	\N	\N	2026-04-21 17:11:19.754947+00
85af5791-fe1b-4276-b734-2e5e00a67354	2026-03-27	mar26.xlsx	Supplier invoice ??? DIESEL GENERATOR (3/2026)	supplier_invoice	\N	f	\N	\N	\N	2026-04-21 17:11:20.340653+00
4385d149-f06f-492d-ad2e-9584e91ccd73	2026-03-27	mar26.xlsx	Supplier invoice ??? DIESEL PRADO HOUSE 4 (3/2026)	supplier_invoice	\N	f	\N	\N	\N	2026-04-21 17:11:20.901778+00
41e068d8-5eed-4d36-8391-b3871ce6740d	2026-03-30	mar26.xlsx	Supplier invoice ??? BANK CHARGES (3/2026)	supplier_invoice	\N	f	\N	\N	\N	2026-04-21 17:11:21.470513+00
8c3e989f-1c39-4ff4-8d05-9aa189577c2e	2026-03-31	mar26.xlsx	Supplier invoice ??? GLOBES (3/2026)	supplier_invoice	\N	f	\N	\N	\N	2026-04-21 17:11:22.014719+00
83a6fb82-d8b9-4827-adc8-e71eb1256eaf	2026-01-03	jan26.xlsx	Supplier invoice ??? ENH DECEMBER (1/2026)	supplier_invoice	\N	f	\N	\N	\N	2026-04-21 17:11:00.778362+00
c55e90aa-685f-4975-b5ce-3e7bb3b246bc	2026-01-11	jan26.xlsx	Supplier invoice ??? ADMIN FEE (1/2026)	supplier_invoice	\N	f	\N	\N	\N	2026-04-21 17:11:01.399303+00
89ddfb17-f5d5-47f5-9d6f-894fad670df7	2026-01-16	jan26.xlsx	Supplier invoice ??? TRANSFER FEE (1/2026)	supplier_invoice	\N	f	\N	\N	\N	2026-04-21 17:11:01.972209+00
41e7ff5a-d37d-4270-acd4-d0ff351358a1	2026-01-22	jan26.xlsx	Supplier invoice ??? FILES (1/2026)	supplier_invoice	\N	f	\N	\N	\N	2026-04-21 17:11:02.542618+00
4ac70d05-8898-485d-8baf-978f6a9ee47f	2026-01-22	jan26.xlsx	Supplier invoice ??? TRANSFER TO PETTY CASH (1/2026)	supplier_invoice	\N	f	\N	\N	\N	2026-04-21 17:11:03.119669+00
5d8a32a0-73c6-4bc5-8739-cc348ae8f173	2026-01-23	jan26.xlsx	Supplier invoice ??? BREAD (1/2026)	supplier_invoice	\N	f	\N	\N	\N	2026-04-21 17:11:03.696218+00
d84c5a1d-4510-47e6-9085-7b755ddbbb7e	2026-01-29	jan26.xlsx	Supplier invoice ??? GAS JANUARY (1/2026)	supplier_invoice	\N	f	\N	\N	\N	2026-04-21 17:11:04.306471+00
d3d9a7fe-8f58-4d0e-867d-da921c035dd5	2026-01-29	jan26.xlsx	Supplier invoice ??? 2 TOMADA SA E 2 CX 4X4 (1/2026)	supplier_invoice	\N	f	\N	\N	\N	2026-04-21 17:11:04.883267+00
422cea12-835c-4ce1-a924-c2d48d12bf4e	2026-01-14	jan26.xlsx	Supplier invoice ??? FINE ON LATE PY OF 2023 (1/2026)	supplier_invoice	\N	f	\N	\N	\N	2026-04-21 17:11:05.457999+00
38a6efb2-c9ae-4977-8118-717f4208d60c	2026-01-07	jan26.xlsx	Supplier invoice ??? SAND PAPER & LUBRICATE SPRAY (1/2026)	supplier_invoice	\N	f	\N	\N	\N	2026-04-21 17:11:06.040039+00
08426640-7d4f-4075-bbe4-51769a845d3e	2026-01-01	jan26.xlsx	Supplier invoice ??? ALEX (1/2026)	supplier_invoice	\N	f	\N	\N	\N	2026-04-21 17:11:06.643425+00
09e26dc1-2e4c-4923-b999-8cf2fbd413b8	2026-01-21	jan26.xlsx	Supplier invoice ??? BEBE (1/2026)	supplier_invoice	\N	f	\N	\N	\N	2026-04-21 17:11:07.23966+00
101f3ddf-6f52-4595-ad92-f0e28ff9f5bc	2026-01-31	jan26.xlsx	Supplier invoice ??? WARREN (1/2026)	supplier_invoice	\N	f	\N	\N	\N	2026-04-21 17:11:07.781619+00
64bdb517-2370-45d2-82f5-0d26cc9a97d2	2026-03-02	mar26.xlsx	Supplier invoice ??? BANK CHARGES (3/2026)	supplier_invoice	\N	f	\N	\N	\N	2026-04-21 17:11:15.389698+00
f5d6b151-a579-486e-aa8d-6a4d7b242ef4	2026-03-09	mar26.xlsx	Supplier invoice ??? DIESEL MMR0998 (3/2026)	supplier_invoice	\N	f	\N	\N	\N	2026-04-21 17:11:15.968036+00
b63e52f7-2566-4e83-b643-f432f5f38501	2026-03-11	mar26.xlsx	Supplier invoice ??? BANK CHARGES (3/2026)	supplier_invoice	\N	f	\N	\N	\N	2026-04-21 17:11:16.553546+00
08af3a5a-5054-463b-9849-69f9516fab4d	2026-03-17	mar26.xlsx	Supplier invoice ??? CARTO DEBITO (3/2026)	supplier_invoice	\N	f	\N	\N	\N	2026-04-21 17:11:17.093685+00
66dae584-41ba-4780-8003-cb4d173da95c	2026-03-18	mar26.xlsx	Supplier invoice ??? IMPRA (3/2026)	supplier_invoice	\N	f	\N	\N	\N	2026-04-21 17:11:17.640764+00
1cb99578-4d38-4d77-bdff-3540e48e9880	2026-03-19	mar26.xlsx	Supplier invoice ??? BATTERY PRADO H4 (3/2026)	supplier_invoice	\N	f	\N	\N	\N	2026-04-21 17:11:18.219614+00
aab75988-68fb-4634-97b7-c9cfe0de6ea5	2026-03-23	mar26.xlsx	Supplier invoice ??? PETTY CASH (3/2026)	supplier_invoice	\N	f	\N	\N	\N	2026-04-21 17:11:18.83367+00
a64976d7-0b33-4889-9ea1-63ae172fe546	2026-03-25	mar26.xlsx	Supplier invoice ??? ADMIN FEE (3/2026)	supplier_invoice	\N	f	\N	\N	\N	2026-04-21 17:11:19.388131+00
c7e89fa9-d9a9-45cc-8c29-6a0673a7d9ab	2026-03-27	mar26.xlsx	Supplier invoice ??? IPRA 2026 (3/2026)	supplier_invoice	\N	f	\N	\N	\N	2026-04-21 17:11:19.942639+00
2f5e4be7-3504-4e0b-ac21-27c42a0419ec	2026-03-27	mar26.xlsx	Supplier invoice ??? Q20 OIL ANTI RUST (3/2026)	supplier_invoice	\N	f	\N	\N	\N	2026-04-21 17:11:20.527474+00
766b41b6-beea-4245-825f-6405f709d467	2026-03-30	mar26.xlsx	Supplier invoice ??? INSS (3/2026)	supplier_invoice	\N	f	\N	\N	\N	2026-04-21 17:11:21.09175+00
42d826ae-c937-4ce5-94a8-83e4d2a01290	2026-03-30	mar26.xlsx	Supplier invoice ??? WORKMENS COMPENSATIO (3/2026)	supplier_invoice	\N	f	\N	\N	\N	2026-04-21 17:11:21.651107+00
ffd70777-be09-418c-9519-11635d62f689	2026-03-01	mar26.xlsx	Supplier invoice ??? UNKNOWN SUPPLIER (3/2026)	supplier_invoice	\N	f	\N	\N	\N	2026-04-21 17:11:22.214486+00
c50729ec-109b-4981-b0ce-048a2991afe5	2026-01-06	jan26.xlsx	Supplier invoice ??? PAINT STEEL (1/2026)	supplier_invoice	\N	f	\N	\N	\N	2026-04-21 17:11:01.013015+00
903ab038-9096-40de-8b85-b8e88ee7ad90	2026-01-11	jan26.xlsx	Supplier invoice ??? ELECTRICITY DECEMBER (1/2026)	supplier_invoice	\N	f	\N	\N	\N	2026-04-21 17:11:01.583709+00
d52e8430-d0e4-4e5a-8118-6015df6ec0c3	2026-01-20	jan26.xlsx	Supplier invoice ??? ACCOUNTING FEE JANUARY (1/2026)	supplier_invoice	\N	f	\N	\N	\N	2026-04-21 17:11:02.163354+00
8a10746b-08e3-4821-807e-fcd472263cc4	2026-01-22	jan26.xlsx	Supplier invoice ??? TRANSFER FEE (1/2026)	supplier_invoice	\N	f	\N	\N	\N	2026-04-21 17:11:02.731279+00
51b73b94-6be3-4e8a-8457-0b8482d8dee3	2026-01-23	jan26.xlsx	Supplier invoice ??? SALARIES JANUARY (1/2026)	supplier_invoice	\N	f	\N	\N	\N	2026-04-21 17:11:03.309146+00
43b5c163-357c-4eaf-ab87-1f00105aff62	2026-01-26	jan26.xlsx	Supplier invoice ??? INSS (1/2026)	supplier_invoice	\N	f	\N	\N	\N	2026-04-21 17:11:03.920994+00
deceee25-3803-4fca-a562-0d240cfa77c9	2026-01-29	jan26.xlsx	Supplier invoice ??? TRANSFER FEE (1/2026)	supplier_invoice	\N	f	\N	\N	\N	2026-04-21 17:11:04.503992+00
28f1a09f-fecf-48ba-b1f6-939df1708942	2026-01-06	jan26.xlsx	Supplier invoice ??? DOCUMENTS TO MAPUTO (1/2026)	supplier_invoice	\N	f	\N	\N	\N	2026-04-21 17:11:05.065302+00
7b2765a3-4712-4cec-a269-5ca9d3f57d5a	2026-01-22	jan26.xlsx	Supplier invoice ??? TRANSFER FROM CHEQUE ACCOUNT (1/2026)	supplier_invoice	\N	f	\N	\N	\N	2026-04-21 17:11:05.651493+00
e202902a-cc37-4098-9907-0d24efd1c24c	2026-01-23	jan26.xlsx	Supplier invoice ??? STEEL FOR SECURITY DOOR (1/2026)	supplier_invoice	\N	f	\N	\N	\N	2026-04-21 17:11:06.237196+00
e6e26b0e-f7a7-4236-8251-166c368d9ab6	2026-01-03	jan26.xlsx	Supplier invoice ??? EUZEBIO (1/2026)	supplier_invoice	\N	f	\N	\N	\N	2026-04-21 17:11:06.865421+00
d188ef75-2204-43e0-878a-bb6f0d01add1	2026-01-30	jan26.xlsx	Supplier invoice ??? WELDER (1/2026)	supplier_invoice	\N	f	\N	\N	\N	2026-04-21 17:11:07.425916+00
3090a957-25f8-4b24-a2c4-6bc505154216	2026-01-31	jan26.xlsx	Supplier invoice ??? BEBE (1/2026)	supplier_invoice	\N	f	\N	\N	\N	2026-04-21 17:11:07.981267+00
060ee2e9-e3e4-4a5a-a517-472f03358b89	2026-03-05	mar26.xlsx	Supplier invoice ??? BANK CHARGES (3/2026)	supplier_invoice	\N	f	\N	\N	\N	2026-04-21 17:11:15.566187+00
d6073f74-fbdf-401c-ba06-811e27b70b91	2026-03-09	mar26.xlsx	Supplier invoice ??? TOILET PAPER (3/2026)	supplier_invoice	\N	f	\N	\N	\N	2026-04-21 17:11:16.155173+00
cad757fa-1fbf-4f44-b1b8-4eed2323eace	2026-03-16	mar26.xlsx	Supplier invoice ??? CHLOOR (3/2026)	supplier_invoice	\N	f	\N	\N	\N	2026-04-21 17:11:16.733269+00
d0d84e82-3b1d-4736-8314-c2146d304b1e	2026-03-18	mar26.xlsx	Supplier invoice ??? ACCOUNTING (3/2026)	supplier_invoice	\N	f	\N	\N	\N	2026-04-21 17:11:17.278626+00
12b7484a-9f99-4ef7-99b5-52568b17bd51	2026-03-19	mar26.xlsx	Supplier invoice ??? BALDE PARA CONSTRUTOR (3/2026)	supplier_invoice	\N	f	\N	\N	\N	2026-04-21 17:11:17.834459+00
6a995698-36ae-4f74-b00e-dc91e3a13b5f	2026-03-19	mar26.xlsx	Supplier invoice ??? SEALER H3 (3/2026)	supplier_invoice	\N	f	\N	\N	\N	2026-04-21 17:11:18.402475+00
387d60f6-d031-4ab0-b420-cc1ba73bc5a8	2026-03-25	mar26.xlsx	Supplier invoice ??? SALARY MARCH (3/2026)	supplier_invoice	\N	f	\N	\N	\N	2026-04-21 17:11:19.016108+00
65a1e181-cd13-4ab6-9f4a-99badc3afa6e	2026-03-26	mar26.xlsx	Supplier invoice ??? LIGHTS OUTSIDE (3/2026)	supplier_invoice	\N	f	\N	\N	\N	2026-04-21 17:11:19.574898+00
d2b9f3f8-ea34-4825-8ec8-3559a8ecf194	2026-03-27	mar26.xlsx	Supplier invoice ??? TAE (3/2026)	supplier_invoice	\N	f	\N	\N	\N	2026-04-21 17:11:20.144313+00
f1655b41-b117-4a2a-b1ff-aabaf33aaa3d	2026-03-30	mar26.xlsx	Supplier invoice ??? DIESEL TOYOTA AKL491MP (3/2026)	supplier_invoice	\N	f	\N	\N	\N	2026-04-21 17:11:20.71124+00
f856d264-214f-4fd0-9d02-86c40199bdb0	2026-03-30	mar26.xlsx	Supplier invoice ??? INSURANCE VEHICLES (3/2026)	supplier_invoice	\N	f	\N	\N	\N	2026-04-21 17:11:21.289549+00
1d69d281-e4f4-40ba-8d74-63a26b1ed986	2026-03-31	mar26.xlsx	Supplier invoice ??? GAS FEBRUARY (3/2026)	supplier_invoice	\N	f	\N	\N	\N	2026-04-21 17:11:21.828521+00
d0f6d152-f45b-479c-afc9-e0323132d94d	2026-02-02	feb26.xlsx	Supplier invoice ??? BANK CHARGES (2/2026)	supplier_invoice	\N	f	\N	\N	\N	2026-04-21 17:11:08.962764+00
9783cc84-01d0-474b-9ee4-2193695aecbf	2026-02-09	feb26.xlsx	Supplier invoice ??? BANK CHARGES (2/2026)	supplier_invoice	\N	f	\N	\N	\N	2026-04-21 17:11:09.555347+00
eb6436d0-f25f-495c-acb2-de63d825b779	2026-02-14	feb26.xlsx	Supplier invoice ??? DIESEL GENERATOR (2/2026)	supplier_invoice	\N	f	\N	\N	\N	2026-04-21 17:11:10.142042+00
dac6fcb8-6edd-41d0-a49d-d0997b2df260	2026-02-19	feb26.xlsx	Supplier invoice ??? ADMIN FEE (2/2026)	supplier_invoice	\N	f	\N	\N	\N	2026-04-21 17:11:10.708949+00
77538e9d-ac57-4c74-89e6-52d33b16760b	2026-02-23	feb26.xlsx	Supplier invoice ??? BANK CHARGES (2/2026)	supplier_invoice	\N	f	\N	\N	\N	2026-04-21 17:11:11.290192+00
82e7e135-6ee3-433e-89e1-800d374532e8	2026-02-23	feb26.xlsx	Supplier invoice ??? REVISAO DE EXTINTORES (2/2026)	supplier_invoice	\N	f	\N	\N	\N	2026-04-21 17:11:11.8579+00
0973ad26-f24a-491e-9c53-b21a54481841	2026-02-26	feb26.xlsx	Supplier invoice ??? CLEANING SUPPLIES (2/2026)	supplier_invoice	\N	f	\N	\N	\N	2026-04-21 17:11:12.442691+00
e917f46d-f352-4cb7-aa48-8badafcb6ec3	2026-02-01	feb26.xlsx	Supplier invoice ??? UNKNOWN SUPPLIER (2/2026)	supplier_invoice	\N	f	\N	\N	\N	2026-04-21 17:11:12.987109+00
c31b5328-d57c-4be6-855c-7e6cd4c22fef	2026-02-11	feb26.xlsx	Supplier invoice ??? WINDO CLEAN (2/2026)	supplier_invoice	\N	f	\N	\N	\N	2026-04-21 17:11:13.568122+00
9497feb1-2ab0-4fb0-840d-1384e94a872c	2026-02-11	feb26.xlsx	Supplier invoice ??? IMPOSTOS VEICULOS (2/2026)	supplier_invoice	\N	f	\N	\N	\N	2026-04-21 17:11:14.132782+00
c5b911e6-be47-4eef-b087-8adae0c4ec1e	2026-02-02	feb26.xlsx	Supplier invoice ??? QUIMICAL SWIMMING POOLS (2/2026)	supplier_invoice	\N	f	\N	\N	\N	2026-04-21 17:11:09.161323+00
6db82ac8-55c7-4c02-868b-6935dcac2700	2026-02-10	feb26.xlsx	Supplier invoice ??? ELECTRISITY (2/2026)	supplier_invoice	\N	f	\N	\N	\N	2026-04-21 17:11:09.742102+00
b9132dd4-dc69-404f-b1af-0866519b3521	2026-02-18	feb26.xlsx	Supplier invoice ??? BANK CHARGES (2/2026)	supplier_invoice	\N	f	\N	\N	\N	2026-04-21 17:11:10.330446+00
85ba8589-cfaa-4293-a354-cd8ec0bf93eb	2026-02-19	feb26.xlsx	Supplier invoice ??? BANK CHARGES (2/2026)	supplier_invoice	\N	f	\N	\N	\N	2026-04-21 17:11:10.901678+00
bbdbe6a5-10b9-48e4-822d-336f9cb97c2d	2026-02-23	feb26.xlsx	Supplier invoice ??? HOUSE KEPPING TOWEL DUCK (2/2026)	supplier_invoice	\N	f	\N	\N	\N	2026-04-21 17:11:11.486259+00
6ac3b6be-2f36-4a5e-975e-c8c11ea8ca40	2026-02-25	feb26.xlsx	Supplier invoice ??? SALARIO FEB (2/2026)	supplier_invoice	\N	f	\N	\N	\N	2026-04-21 17:11:12.046148+00
d4ecc8e5-8576-46ad-b6ff-c0b45208d79e	2026-02-26	feb26.xlsx	Supplier invoice ??? ELETRICAL MATERIAL (2/2026)	supplier_invoice	\N	f	\N	\N	\N	2026-04-21 17:11:12.630675+00
2b8aa542-5a94-4553-86a4-a7c91fa13798	2026-02-05	feb26.xlsx	Supplier invoice ??? DOCUMENTS TO MAPUTO (2/2026)	supplier_invoice	\N	f	\N	\N	\N	2026-04-21 17:11:13.179674+00
d0af4c12-13e7-48f4-98f8-ed5aa5ed8bb9	2026-02-11	feb26.xlsx	Supplier invoice ??? SUNLIGHT (2/2026)	supplier_invoice	\N	f	\N	\N	\N	2026-04-21 17:11:13.756367+00
c6ef3c34-26b4-4379-a979-15bf0f48df71	2026-02-11	feb26.xlsx	Supplier invoice ??? TAX RADIO LICENSE (2/2026)	supplier_invoice	\N	f	\N	\N	\N	2026-04-21 17:11:14.322072+00
9123593a-5a0a-4e08-a00e-f7f94a5c2834	2026-02-04	feb26.xlsx	Supplier invoice ??? BANK CHARGES (2/2026)	supplier_invoice	\N	f	\N	\N	\N	2026-04-21 17:11:09.364585+00
a0990117-2e10-4337-97ce-1bc4d4a253c3	2026-02-10	feb26.xlsx	Supplier invoice ??? BANK CHARGES (2/2026)	supplier_invoice	\N	f	\N	\N	\N	2026-04-21 17:11:09.944349+00
3ccb8873-50fa-4c76-b90b-3389c162170e	2026-02-18	feb26.xlsx	Supplier invoice ??? ACCOUNTING (2/2026)	supplier_invoice	\N	f	\N	\N	\N	2026-04-21 17:11:10.519646+00
a44a8505-6f69-4f3d-b3ba-c7379a2fe151	2026-02-23	feb26.xlsx	Supplier invoice ??? GAS JAN (2/2026)	supplier_invoice	\N	f	\N	\N	\N	2026-04-21 17:11:11.093326+00
4a92ba63-57f8-415f-97fa-421662784440	2026-02-23	feb26.xlsx	Supplier invoice ??? SIM R SEG (2/2026)	supplier_invoice	\N	f	\N	\N	\N	2026-04-21 17:11:11.669762+00
e26b6f3a-e7f5-473b-a653-a9330df61afa	2026-02-25	feb26.xlsx	Supplier invoice ??? BANK CHARGES (2/2026)	supplier_invoice	\N	f	\N	\N	\N	2026-04-21 17:11:12.257475+00
88c35807-ef27-4641-91db-8f5bbf36d490	2026-02-27	feb26.xlsx	Supplier invoice ??? LAMPADAS (2/2026)	supplier_invoice	\N	f	\N	\N	\N	2026-04-21 17:11:12.810434+00
e60e8788-385c-473f-b58a-1dcc9dc0f511	2026-02-09	feb26.xlsx	Supplier invoice ??? FISH  BODYBOARD (2/2026)	supplier_invoice	\N	f	\N	\N	\N	2026-04-21 17:11:13.361207+00
8b1b885c-402e-4498-bada-6e7644272a32	2026-02-11	feb26.xlsx	Supplier invoice ??? SOAP (2/2026)	supplier_invoice	\N	f	\N	\N	\N	2026-04-21 17:11:13.950381+00
9cd81326-24e4-49dd-9b23-2f37738ba1c6	2026-02-12	feb26.xlsx	Supplier invoice ??? TECNO 40 X 2 (2/2026)	supplier_invoice	\N	f	\N	\N	\N	2026-04-21 17:11:14.514842+00
d0049a70-ab5d-4f3e-a36b-72902dceb611	2026-01-01	FT 2026/001	Invoice FT 2026/001: ALEX	income	b0e3af81-86f7-4e03-8742-a859303b62a6	t	2026-04-19 12:50:23.471096+00	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 12:50:23.471096+00
47a8c121-81a6-4392-bdc8-efa8a8e8431a	2026-01-02	FT 2026/002	Invoice FT 2026/002: ALEX	income	ea35b0ac-a1c4-4269-ac14-c52e1de9d514	t	2026-04-19 12:50:23.471096+00	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 12:50:23.471096+00
c3ed77e5-c385-4752-9e87-d7874f646b1b	2026-01-03	FT 2026/003	Invoice FT 2026/003: ALEX	income	b0e3af81-86f7-4e03-8742-a859303b62a6	t	2026-04-19 12:50:23.471096+00	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 12:50:23.471096+00
399f9d9a-6f51-45f0-ac5f-aca9c3a593bc	2026-01-08	FT 2026/004	Invoice FT 2026/004: WARREN STEAD DEP BANK	income	bf17ad40-c04f-4438-8456-1bb96ebcecc7	t	2026-04-19 12:50:23.471096+00	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 12:50:23.471096+00
0d348fd1-a4f7-4258-aa0e-97c1d65cedc0	2026-01-09	FT 2026/005	Invoice FT 2026/005: WARREN STEAD	income	bf17ad40-c04f-4438-8456-1bb96ebcecc7	t	2026-04-19 12:50:23.471096+00	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 12:50:23.471096+00
2795d965-504b-418a-9273-faad8e274d4a	2026-01-10	FT 2026/006	Invoice FT 2026/006: CREDIT IVA H1 - LESLEY X 6 NIGHTS	income	ea35b0ac-a1c4-4269-ac14-c52e1de9d514	t	2026-04-19 12:50:23.471096+00	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 12:50:23.471096+00
01a5e615-ac14-4ec5-b24d-cd23054e4430	2026-01-11	FT 2026/007	Invoice FT 2026/007: ALEX	income	b0e3af81-86f7-4e03-8742-a859303b62a6	t	2026-04-19 12:50:23.471096+00	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 12:50:23.471096+00
875ececf-e730-434f-951a-a6eb2ac9cbe9	2026-01-15	FT 2026/008	Invoice FT 2026/008: BRENDON	income	bf17ad40-c04f-4438-8456-1bb96ebcecc7	t	2026-04-19 12:50:23.471096+00	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 12:50:23.471096+00
b6539d2b-f989-45cb-a1e7-4b55fffbe86a	2026-01-15	FT 2026/009	Invoice FT 2026/009: TAFY	income	ea35b0ac-a1c4-4269-ac14-c52e1de9d514	t	2026-04-19 12:50:23.471096+00	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 12:50:23.471096+00
aed6d853-a889-4cf7-80db-ddc5a61dae07	2026-01-15	FT 2026/010	Invoice FT 2026/010: TAFY RECEIVED FROM ROBIN	income	ea35b0ac-a1c4-4269-ac14-c52e1de9d514	t	2026-04-19 12:50:23.471096+00	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 12:50:23.471096+00
a61a796e-0f7e-4d46-b3b8-8f55d0c10bcd	2026-01-15	FT 2026/011	Invoice FT 2026/011: WARREN STEAD	income	bf17ad40-c04f-4438-8456-1bb96ebcecc7	t	2026-04-19 12:50:23.471096+00	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 12:50:23.471096+00
c1276af4-69fc-4788-beb2-2b1f76b2aedd	2026-01-15	FT 2026/012	Invoice FT 2026/012: BRENDON 7 DAYS @80	income	bf17ad40-c04f-4438-8456-1bb96ebcecc7	t	2026-04-19 12:50:23.471096+00	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 12:50:23.471096+00
59cb3ec9-4125-41b2-81bd-eb4d43294a48	2026-01-15	FT 2026/013	Invoice FT 2026/013: TAFY RECEIVED FROM ALEX	income	ea35b0ac-a1c4-4269-ac14-c52e1de9d514	t	2026-04-19 12:50:23.471096+00	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 12:50:23.471096+00
805513af-ac06-4c94-9a4c-1ecfa3d18efa	2026-01-16	FT 2026/014	Invoice FT 2026/014: ARON ACCOMMODATION IN H4	income	6214c344-b5f9-4d17-b539-e367889ffa9c	t	2026-04-19 12:50:23.471096+00	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 12:50:23.471096+00
cb7106c2-327d-4802-9972-afe97b18cfed	2026-01-17	FT 2026/015	Invoice FT 2026/015: ALEX	income	b0e3af81-86f7-4e03-8742-a859303b62a6	t	2026-04-19 12:50:23.471096+00	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 12:50:23.471096+00
e17bb3a0-f9db-42b2-bebe-d42437a6c077	2026-01-18	FT 2026/016	Invoice FT 2026/016: BRENDON	income	bf17ad40-c04f-4438-8456-1bb96ebcecc7	t	2026-04-19 12:50:23.471096+00	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 12:50:23.471096+00
ee6564f1-0260-45a2-a3c7-1b143b634770	2026-01-19	FT 2026/017	Invoice FT 2026/017: WARREN COHEN INVESTMENT	income	6214c344-b5f9-4d17-b539-e367889ffa9c	t	2026-04-19 12:50:23.471096+00	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 12:50:23.471096+00
d6af991f-69c5-445d-a129-560295d4317c	2026-01-20	FT 2026/018	Invoice FT 2026/018: WARREN STEAD	income	b0e3af81-86f7-4e03-8742-a859303b62a6	t	2026-04-19 12:50:23.471096+00	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 12:50:23.471096+00
0eb252c8-5395-43c5-a2d4-90d9b414de6e	2026-01-21	FT 2026/019	Invoice FT 2026/019: ALAIN WARREN	income	6214c344-b5f9-4d17-b539-e367889ffa9c	t	2026-04-19 12:50:23.471096+00	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 12:50:23.471096+00
9e9f74bc-088f-4d3a-9845-c936f9f3c649	2026-01-22	FT 2026/020	Invoice FT 2026/020: ALEX TRANSFER TO MONIQUE	income	b0e3af81-86f7-4e03-8742-a859303b62a6	t	2026-04-19 12:50:23.471096+00	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 12:50:23.471096+00
a46a684b-3b58-4e16-a898-3061240eacd2	2026-01-22	FT 2026/021	Invoice FT 2026/021: TAFY RECEIVED FROM AANGIE	income	ea35b0ac-a1c4-4269-ac14-c52e1de9d514	t	2026-04-19 12:50:23.471096+00	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 12:50:23.471096+00
14e2b201-5949-4704-bd53-791a49ab0162	2026-01-23	FT 2026/022	Invoice FT 2026/022: ALEX	income	b0e3af81-86f7-4e03-8742-a859303b62a6	t	2026-04-19 12:50:23.471096+00	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 12:50:23.471096+00
cd26d10b-3b86-4cf6-a0df-9c64b8c40aa1	2026-01-23	FT 2026/023	Invoice FT 2026/023: WARREN COHEN INVESTMENT	income	6214c344-b5f9-4d17-b539-e367889ffa9c	t	2026-04-19 12:50:23.471096+00	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 12:50:23.471096+00
e542f423-107d-46b5-97c8-1c5ae2f29c0e	2026-01-23	FT 2026/024	Invoice FT 2026/024: WARREN PAY TRACY SALARY AND RECRUITMENT	income	6214c344-b5f9-4d17-b539-e367889ffa9c	t	2026-04-19 12:50:23.471096+00	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 12:50:23.471096+00
26b816ca-351b-4a11-af7b-a7157b77dcd9	2026-01-24	FT 2026/025	Invoice FT 2026/025: CREDIT IVA H3 - KEITH & SUE X 8 NIGHTS @ 75	income	b0e3af81-86f7-4e03-8742-a859303b62a6	t	2026-04-19 12:50:23.471096+00	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 12:50:23.471096+00
03ec732b-2cd8-4f8c-a74a-e22860fce4c2	2026-01-24	FT 2026/026	Invoice FT 2026/026: WARREN	income	bf17ad40-c04f-4438-8456-1bb96ebcecc7	t	2026-04-19 12:50:23.471096+00	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 12:50:23.471096+00
da4944ec-9ec9-42fe-9b87-85aaecaa5d04	2026-01-24	FT 2026/027	Invoice FT 2026/027: ALEX	income	b0e3af81-86f7-4e03-8742-a859303b62a6	t	2026-04-19 12:50:23.471096+00	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 12:50:23.471096+00
afaeed91-7caf-4e0c-a094-79a3193fb669	2026-01-24	FT 2026/028	Invoice FT 2026/028: TAFY	income	ea35b0ac-a1c4-4269-ac14-c52e1de9d514	t	2026-04-19 12:50:23.471096+00	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 12:50:23.471096+00
fa134df7-0fff-43c5-8ffc-195c01bdf6a0	2026-01-24	FT 2026/029	Invoice FT 2026/029: WARREN STEAD	income	bf17ad40-c04f-4438-8456-1bb96ebcecc7	t	2026-04-19 12:50:23.471096+00	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 12:50:23.471096+00
bc55651d-20d3-4d01-aec8-5d8104fc0e5b	2026-01-28	FT 2026/030	Invoice FT 2026/030: TAFY RE ROBIN	income	ea35b0ac-a1c4-4269-ac14-c52e1de9d514	t	2026-04-19 12:50:23.471096+00	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 12:50:23.471096+00
b9a4b698-c5db-45ec-a240-0ca761ef676a	2026-01-28	FT 2026/031	Invoice FT 2026/031: WARREN INVESTMENT DOLLAR ACCOUNT	income	6214c344-b5f9-4d17-b539-e367889ffa9c	t	2026-04-19 12:50:23.471096+00	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 12:50:23.471096+00
687ae46e-4716-4153-85f6-6b79d201cb7a	2026-01-29	FT 2026/032	Invoice FT 2026/032: KEIVIN PAY TO BANK	income	b0e3af81-86f7-4e03-8742-a859303b62a6	t	2026-04-19 12:50:23.471096+00	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 12:50:23.471096+00
4dfe9a53-1ccd-4013-bda2-5c1055bfd280	2026-02-01	FT 2026/033	Invoice FT 2026/033: ALEX	income	b0e3af81-86f7-4e03-8742-a859303b62a6	t	2026-04-19 12:50:23.471096+00	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 12:50:23.471096+00
90d0dc0f-19f9-4d08-bdf2-e16544dd6120	2026-02-02	FT 2026/034	Invoice FT 2026/034: ALEX	income	ea35b0ac-a1c4-4269-ac14-c52e1de9d514	t	2026-04-19 12:50:23.471096+00	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 12:50:23.471096+00
9acea114-3cbd-434e-bcee-2b62e6a7216b	2026-02-03	FT 2026/035	Invoice FT 2026/035: ALEX	income	b0e3af81-86f7-4e03-8742-a859303b62a6	t	2026-04-19 12:50:23.471096+00	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 12:50:23.471096+00
6e94b6a6-091f-425c-b6b8-e53a2de972ff	2026-02-08	FT 2026/036	Invoice FT 2026/036: WARREN STEAD DEP BANK	income	bf17ad40-c04f-4438-8456-1bb96ebcecc7	t	2026-04-19 12:50:23.471096+00	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 12:50:23.471096+00
1f898a27-907b-4a8a-84e3-cfa3dc671c94	2026-02-09	FT 2026/037	Invoice FT 2026/037: WARREN STEAD	income	bf17ad40-c04f-4438-8456-1bb96ebcecc7	t	2026-04-19 12:50:23.471096+00	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 12:50:23.471096+00
c348fb39-02c9-444f-96d7-785677486d78	2026-02-10	FT 2026/038	Invoice FT 2026/038: CREDIT IVA H1 - LESLEY X 6 NIGHTS	income	ea35b0ac-a1c4-4269-ac14-c52e1de9d514	t	2026-04-19 12:50:23.471096+00	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 12:50:23.471096+00
092ff6aa-01c0-424a-8321-525c41c65e2c	2026-02-11	FT 2026/039	Invoice FT 2026/039: ALEX	income	b0e3af81-86f7-4e03-8742-a859303b62a6	t	2026-04-19 12:50:23.471096+00	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 12:50:23.471096+00
4a8c0b31-ceb5-4c61-b19b-3af5a5f20b4d	2026-02-15	FT 2026/040	Invoice FT 2026/040: BRENDON 7 DAYS @80	income	bf17ad40-c04f-4438-8456-1bb96ebcecc7	t	2026-04-19 12:50:23.471096+00	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 12:50:23.471096+00
752c8b55-5b8b-4678-93b4-99ed6ec43091	2026-02-15	FT 2026/041	Invoice FT 2026/041: TAFY RECEIVED FROM ROBIN	income	ea35b0ac-a1c4-4269-ac14-c52e1de9d514	t	2026-04-19 12:50:23.471096+00	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 12:50:23.471096+00
dc6b8e89-566a-4f3d-9a00-aab2c7cf6b9c	2026-02-15	FT 2026/042	Invoice FT 2026/042: WARREN STEAD	income	bf17ad40-c04f-4438-8456-1bb96ebcecc7	t	2026-04-19 12:50:23.471096+00	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 12:50:23.471096+00
5fd793f3-5294-4934-b089-f6dbfe9a07dc	2026-02-15	FT 2026/043	Invoice FT 2026/043: TAFY RECEIVED FROM ALEX	income	ea35b0ac-a1c4-4269-ac14-c52e1de9d514	t	2026-04-19 12:50:23.471096+00	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 12:50:23.471096+00
3bcb4c43-1afc-4a14-83a8-e8cbee548977	2026-02-15	FT 2026/044	Invoice FT 2026/044: BRENDON	income	bf17ad40-c04f-4438-8456-1bb96ebcecc7	t	2026-04-19 12:50:23.471096+00	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 12:50:23.471096+00
34c2b0b3-58f3-436a-8ba6-35a188938c3e	2026-02-15	FT 2026/045	Invoice FT 2026/045: TAFY	income	ea35b0ac-a1c4-4269-ac14-c52e1de9d514	t	2026-04-19 12:50:23.471096+00	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 12:50:23.471096+00
d9ca6b0c-7d92-4983-a3b8-ef0de5affbba	2026-02-15	FT 2026/046	Invoice FT 2026/046: TAFY	income	ea35b0ac-a1c4-4269-ac14-c52e1de9d514	t	2026-04-19 12:50:23.471096+00	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 12:50:23.471096+00
c3a9ce6a-81e3-44b9-b714-1bf7bdf52fc9	2026-02-16	FT 2026/047	Invoice FT 2026/047: ARON ACCOMMODATION IN H4	income	6214c344-b5f9-4d17-b539-e367889ffa9c	t	2026-04-19 12:50:23.471096+00	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 12:50:23.471096+00
14021e21-fa0b-4e0c-8d4c-8755179cc230	2026-02-17	FT 2026/048	Invoice FT 2026/048: ALEX	income	b0e3af81-86f7-4e03-8742-a859303b62a6	t	2026-04-19 12:50:23.471096+00	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 12:50:23.471096+00
69b77cba-e269-4b78-b4d4-7d4220e8764d	2026-02-18	FT 2026/049	Invoice FT 2026/049: BRENDON	income	bf17ad40-c04f-4438-8456-1bb96ebcecc7	t	2026-04-19 12:50:23.471096+00	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 12:50:23.471096+00
2779d770-7027-4b37-9902-3d94607d3572	2026-02-19	FT 2026/050	Invoice FT 2026/050: WARREN COHEN INVESTMENT	income	6214c344-b5f9-4d17-b539-e367889ffa9c	t	2026-04-19 12:50:23.471096+00	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 12:50:23.471096+00
9d34c92c-d0a6-44e2-a6c3-d15957da8145	2026-02-20	FT 2026/051	Invoice FT 2026/051: WARREN STEAD	income	b0e3af81-86f7-4e03-8742-a859303b62a6	t	2026-04-19 12:50:23.471096+00	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 12:50:23.471096+00
1faa3a4a-8859-437d-ae14-5d4232c21e3b	2026-02-21	FT 2026/052	Invoice FT 2026/052: ALAIN WARREN	income	6214c344-b5f9-4d17-b539-e367889ffa9c	t	2026-04-19 12:50:23.471096+00	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 12:50:23.471096+00
99001375-4cc9-4f62-9374-518be7a9b426	2026-02-22	FT 2026/053	Invoice FT 2026/053: TAFY RECEIVED FROM AANGIE	income	ea35b0ac-a1c4-4269-ac14-c52e1de9d514	t	2026-04-19 12:50:23.471096+00	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 12:50:23.471096+00
aaf65970-10e5-4c38-b835-8bdb91e90817	2026-02-22	FT 2026/054	Invoice FT 2026/054: ALEX TRANSFER TO MONIQUE	income	b0e3af81-86f7-4e03-8742-a859303b62a6	t	2026-04-19 12:50:23.471096+00	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 12:50:23.471096+00
e145dc08-f86a-4899-861e-1c2947dc2ec1	2026-02-23	FT 2026/055	Invoice FT 2026/055: WARREN PAY TRACY SALARY AND RECRUITMENT	income	6214c344-b5f9-4d17-b539-e367889ffa9c	t	2026-04-19 12:50:23.471096+00	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 12:50:23.471096+00
c26bae19-f04e-4b0d-be5b-cc3e401be8c5	2026-02-23	FT 2026/056	Invoice FT 2026/056: ALEX	income	b0e3af81-86f7-4e03-8742-a859303b62a6	t	2026-04-19 12:50:23.471096+00	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 12:50:23.471096+00
f1883d19-e0db-4067-b665-089f2f66cd75	2026-02-23	FT 2026/057	Invoice FT 2026/057: WARREN COHEN INVESTMENT	income	6214c344-b5f9-4d17-b539-e367889ffa9c	t	2026-04-19 12:50:23.471096+00	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 12:50:23.471096+00
6349b650-82d2-48af-8ce0-f7e796591d10	2026-02-24	FT 2026/058	Invoice FT 2026/058: WARREN STEAD	income	bf17ad40-c04f-4438-8456-1bb96ebcecc7	t	2026-04-19 12:50:23.471096+00	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 12:50:23.471096+00
878c6e58-822f-481b-87ec-0920aa7d7c29	2026-02-24	FT 2026/059	Invoice FT 2026/059: CREDIT IVA H3 - KEITH & SUE X 8 NIGHTS @ 75	income	b0e3af81-86f7-4e03-8742-a859303b62a6	t	2026-04-19 12:50:23.471096+00	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 12:50:23.471096+00
e7d2226e-dd88-45cb-9ab8-d67693c58368	2026-02-24	FT 2026/060	Invoice FT 2026/060: ALEX	income	b0e3af81-86f7-4e03-8742-a859303b62a6	t	2026-04-19 12:50:23.471096+00	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 12:50:23.471096+00
82c0c79e-5a59-4608-a9f8-ec97f5c99ce7	2026-02-24	FT 2026/061	Invoice FT 2026/061: WARREN	income	bf17ad40-c04f-4438-8456-1bb96ebcecc7	t	2026-04-19 12:50:23.471096+00	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 12:50:23.471096+00
ae1c23f4-f70a-4ee9-b77a-819072fc1561	2026-02-24	FT 2026/062	Invoice FT 2026/062: TAFY	income	ea35b0ac-a1c4-4269-ac14-c52e1de9d514	t	2026-04-19 12:50:23.471096+00	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 12:50:23.471096+00
a82d3dc7-e567-48f1-b9f3-d55f79f98de5	2026-02-27	FT 2026/063	Invoice FT 2026/063: KEIVIN PAY TO BANK	income	b0e3af81-86f7-4e03-8742-a859303b62a6	t	2026-04-19 12:50:23.471096+00	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 12:50:23.471096+00
87bffe9f-3589-4eeb-a413-81d41f97c28e	2026-02-27	FT 2026/064	Invoice FT 2026/064: TAFY RE ROBIN	income	ea35b0ac-a1c4-4269-ac14-c52e1de9d514	t	2026-04-19 12:50:23.471096+00	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 12:50:23.471096+00
7e5d464d-93fd-44d7-b673-9bd143afed80	2026-02-27	FT 2026/065	Invoice FT 2026/065: WARREN INVESTMENT DOLLAR ACCOUNT	income	6214c344-b5f9-4d17-b539-e367889ffa9c	t	2026-04-19 12:50:23.471096+00	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 12:50:23.471096+00
48333f31-bd2b-4ae9-8367-d48dc672533b	2026-03-01	FT 2026/066	Invoice FT 2026/066: ALEX	income	b0e3af81-86f7-4e03-8742-a859303b62a6	t	2026-04-19 12:50:23.471096+00	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 12:50:23.471096+00
f6cb5a78-020e-4d1b-aef7-e9d37adb84d6	2026-03-02	FT 2026/067	Invoice FT 2026/067: ALEX	income	ea35b0ac-a1c4-4269-ac14-c52e1de9d514	t	2026-04-19 12:50:23.471096+00	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 12:50:23.471096+00
63f05972-e49f-4c10-82f4-d08ffb5e10c5	2026-03-03	FT 2026/068	Invoice FT 2026/068: ALEX	income	b0e3af81-86f7-4e03-8742-a859303b62a6	t	2026-04-19 12:50:23.471096+00	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 12:50:23.471096+00
0a45eea3-943f-4037-bca2-4d7a5aef6e91	2026-03-08	FT 2026/069	Invoice FT 2026/069: WARREN STEAD DEP BANK	income	bf17ad40-c04f-4438-8456-1bb96ebcecc7	t	2026-04-19 12:50:23.471096+00	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 12:50:23.471096+00
5c8f19bd-2353-46bd-a190-36c66645ef4f	2026-03-09	FT 2026/070	Invoice FT 2026/070: WARREN STEAD	income	bf17ad40-c04f-4438-8456-1bb96ebcecc7	t	2026-04-19 12:50:23.471096+00	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 12:50:23.471096+00
0f31bf99-0040-475f-96f8-117d491c5bc8	2026-03-10	FT 2026/071	Invoice FT 2026/071: CREDIT IVA H1 - LESLEY X 6 NIGHTS	income	ea35b0ac-a1c4-4269-ac14-c52e1de9d514	t	2026-04-19 12:50:23.471096+00	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 12:50:23.471096+00
26d387df-67c4-49d9-8bd6-c73b7b90d95e	2026-03-11	FT 2026/072	Invoice FT 2026/072: ALEX	income	b0e3af81-86f7-4e03-8742-a859303b62a6	t	2026-04-19 12:50:23.471096+00	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 12:50:23.471096+00
d762a09d-656a-4655-ba46-63b7f92030d9	2026-03-15	FT 2026/073	Invoice FT 2026/073: TAFY RECEIVED FROM ROBIN	income	ea35b0ac-a1c4-4269-ac14-c52e1de9d514	t	2026-04-19 12:50:23.471096+00	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 12:50:23.471096+00
6863b383-ebd9-4de6-8bd0-7f4ffa2882c6	2026-03-15	FT 2026/074	Invoice FT 2026/074: BRENDON	income	bf17ad40-c04f-4438-8456-1bb96ebcecc7	t	2026-04-19 12:50:23.471096+00	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 12:50:23.471096+00
cfa3608a-4da5-438c-8066-d64d52f79acc	2026-03-15	FT 2026/075	Invoice FT 2026/075: WARREN COHEN INVESTMENT	income	6214c344-b5f9-4d17-b539-e367889ffa9c	t	2026-04-19 12:50:23.471096+00	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 12:50:23.471096+00
9ea68823-2b5c-4adb-9252-00d45e9fec67	2026-03-15	FT 2026/076	Invoice FT 2026/076: TAFY	income	ea35b0ac-a1c4-4269-ac14-c52e1de9d514	t	2026-04-19 12:50:23.471096+00	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 12:50:23.471096+00
7b385729-d24c-4dea-9539-e204646e9f13	2026-03-15	FT 2026/077	Invoice FT 2026/077: BRENDON 7 DAYS @80	income	bf17ad40-c04f-4438-8456-1bb96ebcecc7	t	2026-04-19 12:50:23.471096+00	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 12:50:23.471096+00
206d00a7-e385-431b-a1f0-820e7ed914d1	2026-03-15	FT 2026/078	Invoice FT 2026/078: TAFY RECEIVED FROM ALEX	income	ea35b0ac-a1c4-4269-ac14-c52e1de9d514	t	2026-04-19 12:50:23.471096+00	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 12:50:23.471096+00
fa22d2bc-b2ae-441a-9cb8-c8e65ce187c6	2026-03-15	FT 2026/079	Invoice FT 2026/079: TAFY ELIANA	income	ea35b0ac-a1c4-4269-ac14-c52e1de9d514	t	2026-04-19 12:50:23.471096+00	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 12:50:23.471096+00
1ce836ed-220b-4496-8a9a-a740f187fa04	2026-03-15	FT 2026/080	Invoice FT 2026/080: WARREN STEAD	income	bf17ad40-c04f-4438-8456-1bb96ebcecc7	t	2026-04-19 12:50:23.471096+00	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 12:50:23.471096+00
49361d80-a483-454d-9edc-656a363e82c1	2026-03-15	FT 2026/081	Invoice FT 2026/081: TAFY	income	ea35b0ac-a1c4-4269-ac14-c52e1de9d514	t	2026-04-19 12:50:23.471096+00	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 12:50:23.471096+00
55bc3e9d-d935-4cf1-b7ad-23faddfe7e07	2026-03-16	FT 2026/082	Invoice FT 2026/082: ARON ACCOMMODATION IN H4	income	6214c344-b5f9-4d17-b539-e367889ffa9c	t	2026-04-19 12:50:23.471096+00	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 12:50:23.471096+00
e4d1e4d1-a50a-41a0-bdfa-c2cc2e38cd0a	2026-03-17	FT 2026/083	Invoice FT 2026/083: ALEX	income	b0e3af81-86f7-4e03-8742-a859303b62a6	t	2026-04-19 12:50:23.471096+00	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 12:50:23.471096+00
411eac46-c4b3-42e5-a991-4f77314745f8	2026-03-18	FT 2026/084	Invoice FT 2026/084: BRENDON	income	bf17ad40-c04f-4438-8456-1bb96ebcecc7	t	2026-04-19 12:50:23.471096+00	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 12:50:23.471096+00
d743140a-88ad-47fd-ae48-5ada617199ba	2026-03-19	FT 2026/085	Invoice FT 2026/085: WARREN COHEN INVESTMENT	income	6214c344-b5f9-4d17-b539-e367889ffa9c	t	2026-04-19 12:50:23.471096+00	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 12:50:23.471096+00
a8aafe73-74ed-4759-9828-d6cb50be160f	2026-03-20	FT 2026/086	Invoice FT 2026/086: WARREN STEAD	income	b0e3af81-86f7-4e03-8742-a859303b62a6	t	2026-04-19 12:50:23.471096+00	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 12:50:23.471096+00
ded44176-e7f6-43d2-908b-6645e4481ab3	2026-03-21	FT 2026/087	Invoice FT 2026/087: ALAIN WARREN	income	6214c344-b5f9-4d17-b539-e367889ffa9c	t	2026-04-19 12:50:23.471096+00	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 12:50:23.471096+00
03554493-32cc-45e1-a930-03703e07307b	2026-03-22	FT 2026/088	Invoice FT 2026/088: ALEX TRANSFER TO MONIQUE	income	b0e3af81-86f7-4e03-8742-a859303b62a6	t	2026-04-19 12:50:23.471096+00	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 12:50:23.471096+00
5a759d36-c218-4541-9f61-cddb57ade7e6	2026-03-22	FT 2026/089	Invoice FT 2026/089: TAFY RECEIVED FROM AANGIE	income	ea35b0ac-a1c4-4269-ac14-c52e1de9d514	t	2026-04-19 12:50:23.471096+00	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 12:50:23.471096+00
97f8b77b-d458-4fa1-b001-20826cb5a5c4	2026-03-23	FT 2026/090	Invoice FT 2026/090: WARREN PAY TRACY SALARY AND RECRUITMENT	income	6214c344-b5f9-4d17-b539-e367889ffa9c	t	2026-04-19 12:50:23.471096+00	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 12:50:23.471096+00
4d3ea5d5-c8cf-4925-a531-9221876b19db	2026-03-23	FT 2026/091	Invoice FT 2026/091: ALEX	income	b0e3af81-86f7-4e03-8742-a859303b62a6	t	2026-04-19 12:50:23.471096+00	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 12:50:23.471096+00
63797375-7ca4-44a8-8300-ad4e7c538392	2026-03-23	FT 2026/092	Invoice FT 2026/092: WARREN COHEN INVESTMENT	income	6214c344-b5f9-4d17-b539-e367889ffa9c	t	2026-04-19 12:50:23.471096+00	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 12:50:23.471096+00
951ba03c-1c13-441e-a38e-ed25e8966238	2026-03-24	FT 2026/093	Invoice FT 2026/093: WARREN	income	bf17ad40-c04f-4438-8456-1bb96ebcecc7	t	2026-04-19 12:50:23.471096+00	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 12:50:23.471096+00
b33219e3-86fa-403b-aa1e-39e51c09404a	2026-03-24	FT 2026/094	Invoice FT 2026/094: TAFY	income	ea35b0ac-a1c4-4269-ac14-c52e1de9d514	t	2026-04-19 12:50:23.471096+00	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 12:50:23.471096+00
85888e62-46aa-4085-8dd7-c6e56d1ca454	2026-03-24	FT 2026/095	Invoice FT 2026/095: CREDIT IVA H3 - KEITH & SUE X 8 NIGHTS @ 75	income	b0e3af81-86f7-4e03-8742-a859303b62a6	t	2026-04-19 12:50:23.471096+00	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 12:50:23.471096+00
eb16be51-0c12-4db9-bda3-715f775279fe	2026-03-24	FT 2026/096	Invoice FT 2026/096: ALEX	income	b0e3af81-86f7-4e03-8742-a859303b62a6	t	2026-04-19 12:50:23.471096+00	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 12:50:23.471096+00
a9629fb9-c052-4fea-8fb7-03ae1f781a86	2026-03-24	FT 2026/097	Invoice FT 2026/097: WARREN STEAD	income	bf17ad40-c04f-4438-8456-1bb96ebcecc7	t	2026-04-19 12:50:23.471096+00	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 12:50:23.471096+00
e7d59e7e-9db7-4174-8860-58ebcf24cc93	2026-03-28	FT 2026/098	Invoice FT 2026/098: WARREN INVESTMENT DOLLAR ACCOUNT	income	6214c344-b5f9-4d17-b539-e367889ffa9c	t	2026-04-19 12:50:23.471096+00	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 12:50:23.471096+00
6da826be-190e-480b-a2a1-e9a28f5491b2	2026-03-28	FT 2026/099	Invoice FT 2026/099: TAFY RE ROBIN	income	ea35b0ac-a1c4-4269-ac14-c52e1de9d514	t	2026-04-19 12:50:23.471096+00	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 12:50:23.471096+00
a0162379-4a21-4be9-bfec-2b28529b3a19	2026-03-29	FT 2026/100	Invoice FT 2026/100: KEIVIN PAY TO BANK	income	b0e3af81-86f7-4e03-8742-a859303b62a6	t	2026-04-19 12:50:23.471096+00	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 12:50:23.471096+00
4ba85fd7-80c6-40f7-b934-e49633eecbee	2026-01-06	\N	Petty Cash: PORTADOR DIARIO | DOCUMENTS TO MAPUTO | OFFICE & BANK CHARGES	petty_cash	\N	t	\N	\N	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 14:14:45.00583+00
07fcc7d5-808c-42b0-b2ab-ffde146987ac	2026-01-14	\N	Petty Cash: EDM | FINE ON LATE PY OF 2023 | FINES	petty_cash	\N	t	\N	\N	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 14:14:45.00583+00
4ca75372-0ac2-477c-95c6-73fccef02de6	2026-01-22	\N	Petty Cash: PORTADAR | TRANSFER FROM CHEQUE ACCOUNT	petty_cash	\N	t	\N	\N	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 14:14:45.00583+00
27704642-909a-44e5-b479-154f3957b57b	2026-01-23	\N	Petty Cash: CASH | TRANSFER TO PRE-PAID | SUSPENSE	petty_cash	\N	t	\N	\N	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 14:14:45.00583+00
6531e19f-2f5a-4dfe-b36d-6ce8fc16e6a6	2026-02-05	\N	Petty Cash: PORTADOR DIARIO | DOCUMENTS TO MAPUTO | OFFICE & BANK CHARGES	petty_cash	\N	t	\N	\N	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 14:14:45.00583+00
e9710257-41eb-4ead-ab25-4695e7e3734a	2026-02-09	\N	Petty Cash: OTIMO | FISH  BODYBOARD | HOUSE 4	petty_cash	\N	t	\N	\N	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 14:14:45.00583+00
ecc763a6-7d5a-4aed-996a-5bc45fe4510a	2026-02-11	\N	Petty Cash: SUPERMERICADO | WINDO CLEAN | HOUSE KEEPING	petty_cash	\N	t	\N	\N	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 14:14:45.00583+00
10316b94-9981-4b66-8cbe-d66d7d9a4e3a	2026-02-11	\N	Petty Cash: SPAR | SUNLIGHT | HOUSE KEEPING	petty_cash	\N	t	\N	\N	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 14:14:45.00583+00
a0acd0bb-eb31-42ed-82d8-90bf1069bfdb	2026-02-11	\N	Petty Cash: SPAR | SOAP | HOUSE KEEPING HOUSE 1	petty_cash	\N	t	\N	\N	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 14:14:45.00583+00
b1d0c13c-b014-4d20-9b97-f936c956d005	2026-02-11	\N	Petty Cash: MUNICIPAL | IMPOSTOS VEICULOS | TAX  LICENSE	petty_cash	\N	t	\N	\N	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 14:14:45.00583+00
23e6bb37-9735-4400-aa98-731474431e77	2026-02-11	\N	Petty Cash: RADIO MOCAMBIQUE | TAX RADIO LICENSE | TAX RADIO LICENSE	petty_cash	\N	t	\N	\N	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 14:14:45.00583+00
8b47f37a-f5f0-4530-b300-2a30a24b0ff1	2026-02-12	\N	Petty Cash: AMUJI | TECNO 40 X 2 | CELL FOR GUARDS SECURITY	petty_cash	\N	t	\N	\N	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 14:14:45.00583+00
39865c69-516c-4338-b73d-06b0c1e32c8e	2026-03-01	\N	Petty Cash: PORTADOR | PETTY CASH | SUSPENSE	petty_cash	\N	t	\N	\N	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 14:14:45.00583+00
2a1f257c-8d4d-4196-8377-6a40ec407a97	2026-03-05	\N	Petty Cash: PORTADOR | DOCUMENTS TO MAPUTO | COURIER FEE OFFICE	petty_cash	\N	t	\N	\N	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 14:14:45.00583+00
70fd627c-004b-45ae-bf35-4c671b85f50c	2026-01-03	\N	BDO Recovery: Payment to ENH DECEMBER (BIM MZN)	supplier_payment	\N	t	\N	\N	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 14:31:23.801922+00
79331021-4d46-49a0-9d0b-1cf020bd37e0	2026-01-03	\N	BDO Recovery: Payment to TRANSFER FROM DOLLAR ACCOUNT (BIM MZN)	supplier_payment	\N	t	\N	\N	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 14:31:23.801922+00
0600d3c9-36c6-4ecb-8dd2-027753aac341	2026-01-06	\N	BDO Recovery: Payment to PAINT STEEL (BIM MZN)	supplier_payment	\N	t	\N	\N	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 14:31:23.801922+00
c3bf3303-2f6c-47d8-a2c3-f13ff33f779d	2026-01-09	\N	BDO Recovery: Payment to WARREN STEAD (BIM MZN)	supplier_payment	\N	t	\N	\N	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 14:31:23.801922+00
765cb5dd-85c3-45c2-90fc-e9270c6f7712	2026-01-09	\N	BDO Recovery: Payment to WARREN STEAD (BIM MZN)	supplier_payment	\N	t	\N	\N	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 14:31:23.801922+00
000ac3b5-39fc-4462-9010-d16337c184cf	2026-01-09	\N	BDO Recovery: Payment to WARREN STEAD (BIM MZN)	supplier_payment	\N	t	\N	\N	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 14:31:23.801922+00
f1b45e9f-53a2-484d-a650-e79aff9c6c42	2026-01-11	\N	BDO Recovery: Payment to FELIX ADVANCE (BIM MZN)	supplier_payment	\N	t	\N	\N	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 14:31:23.801922+00
e0999dc2-0f69-45f6-9472-574cbb9f7531	2026-01-11	\N	BDO Recovery: Payment to TRANSFER FEE (BIM MZN)	supplier_payment	\N	t	\N	\N	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 14:31:23.801922+00
75940ed7-f4a9-42d1-a6d0-795705d337d2	2026-01-11	\N	BDO Recovery: Payment to ADMIN FEE (BIM MZN)	supplier_payment	\N	t	\N	\N	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 14:31:23.801922+00
be4477af-4051-41f8-93d6-21e62f8b194c	2026-01-11	\N	BDO Recovery: Payment to TRANSFER FEE (BIM MZN)	supplier_payment	\N	t	\N	\N	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 14:31:23.801922+00
fb49ab78-f71b-402b-8d2e-78d4e91f8b40	2026-01-11	\N	BDO Recovery: Payment to ELECTRICITY DECEMBER (BIM MZN)	supplier_payment	\N	t	\N	\N	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 14:31:23.801922+00
54b5739e-f566-41c3-92a7-a6acf5680fc8	2026-01-11	\N	BDO Recovery: Payment to TRANSFER FEE (BIM MZN)	supplier_payment	\N	t	\N	\N	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 14:31:23.801922+00
35f00013-d1c8-4dbc-b7c7-aa2b16efb0a5	2026-01-12	\N	BDO Recovery: Payment to FELIX ADVANCE (BIM MZN)	supplier_payment	\N	t	\N	\N	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 14:31:23.801922+00
cd1d3182-048a-4074-8e5a-2dbb91249b81	2026-01-12	\N	BDO Recovery: Payment to TRANSFER FEE (BIM MZN)	supplier_payment	\N	t	\N	\N	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 14:31:23.801922+00
d6726456-acb9-4b97-a919-0900981c5805	2026-01-16	\N	BDO Recovery: Payment to ADVANCE JELSON (BIM MZN)	supplier_payment	\N	t	\N	\N	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 14:31:23.801922+00
5cf1be23-2f20-4697-88f8-f811c0d0bffa	2026-01-16	\N	BDO Recovery: Payment to TRANSFER FEE (BIM MZN)	supplier_payment	\N	t	\N	\N	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 14:31:23.801922+00
5ee4e0ac-511e-4586-8d01-ce3c1528719f	2026-01-20	\N	BDO Recovery: Payment to ACCOUNTING FEE JANUARY (BIM MZN)	supplier_payment	\N	t	\N	\N	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 14:31:23.801922+00
e1b7baff-b6ee-485d-bf1a-81a794e6953f	2026-01-20	\N	BDO Recovery: Payment to TRANSFER FEE (BIM MZN)	supplier_payment	\N	t	\N	\N	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 14:31:23.801922+00
6d1cb34f-e2be-4697-bfc7-98c07c6ad1d0	2026-01-22	\N	BDO Recovery: Payment to FILES (BIM MZN)	supplier_payment	\N	t	\N	\N	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 14:31:23.801922+00
97ada1a5-72f7-4c00-8ca6-b3ee53eb19c6	2026-01-22	\N	BDO Recovery: Payment to TRANSFER FEE (BIM MZN)	supplier_payment	\N	t	\N	\N	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 14:31:23.801922+00
946100f1-b70e-46c2-a360-c8a15b6c55ca	2026-01-23	\N	BDO Recovery: Payment to COTOVELO PVC (BIM MZN)	supplier_payment	\N	t	\N	\N	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 14:31:23.801922+00
7014c22f-55bb-4f2a-afff-6ea3dd6444f1	2026-01-22	\N	BDO Recovery: Payment to TRANSFER TO PETTY CASH (BIM MZN)	supplier_payment	\N	t	\N	\N	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 14:31:23.801922+00
cdf7b4be-d6d3-43f2-935d-5a876645ab76	2026-01-23	\N	BDO Recovery: Payment to SALARIES JANUARY (BIM MZN)	supplier_payment	\N	t	\N	\N	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 14:31:23.801922+00
91e083e4-0fcd-4f7e-922a-7eb7a0b2fab0	2026-01-23	\N	BDO Recovery: Payment to BANK CHARGES (BIM MZN)	supplier_payment	\N	t	\N	\N	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 14:31:23.801922+00
bf963a0b-96e2-48f0-90d7-1f628d008bd7	2026-01-23	\N	BDO Recovery: Payment to BREAD (BIM MZN)	supplier_payment	\N	t	\N	\N	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 14:31:23.801922+00
d34d3265-ad07-44af-a01e-4bea665cbb75	2026-01-26	\N	BDO Recovery: Payment to IRPS (BIM MZN)	supplier_payment	\N	t	\N	\N	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 14:31:23.801922+00
d56967b6-2cd6-4df0-86f2-49041a33b295	2026-01-26	\N	BDO Recovery: Payment to INSS (BIM MZN)	supplier_payment	\N	t	\N	\N	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 14:31:23.801922+00
3465b09f-4950-4ebb-87d8-65f3e8392bc8	2026-01-28	\N	BDO Recovery: Payment to DILUENTE ESMALTE QD 750ML (BIM MZN)	supplier_payment	\N	t	\N	\N	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 14:31:23.801922+00
43cf3d37-0f70-4a82-9dda-b013ca1b9716	2026-01-29	\N	BDO Recovery: Payment to GAS JANUARY (BIM MZN)	supplier_payment	\N	t	\N	\N	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 14:31:23.801922+00
8973a91d-0d6e-4210-9b77-8892cba4ca6b	2026-01-29	\N	BDO Recovery: Payment to TRANSFER FEE (BIM MZN)	supplier_payment	\N	t	\N	\N	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 14:31:23.801922+00
65c4b1bb-39f2-4170-b8b2-e23a33fb7038	2026-01-29	\N	BDO Recovery: Payment to LESCO - CX PROVA DE AGUA 4X4 (BIM MZN)	supplier_payment	\N	t	\N	\N	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 14:31:23.801922+00
efc2c4b7-0a89-4a43-b266-1c06cd9bae41	2026-01-29	\N	BDO Recovery: Payment to 2 TOMADA SA E 2 CX 4X4 (BIM MZN)	supplier_payment	\N	t	\N	\N	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 14:31:23.801922+00
391f802b-17ab-473c-bb7c-2b061c586e64	2026-02-02	\N	BDO Recovery: Payment to Leave (BIM MZN)	supplier_payment	\N	t	\N	\N	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 14:31:23.801922+00
cba364bf-a1a8-4915-be44-2c7ab945da74	2026-02-02	\N	BDO Recovery: Payment to Bank Charges (BIM MZN)	supplier_payment	\N	t	\N	\N	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 14:31:23.801922+00
ff454c16-ce08-4aca-adef-93c935c4e28b	2026-02-02	\N	BDO Recovery: Payment to Quimical swimming pools (BIM MZN)	supplier_payment	\N	t	\N	\N	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 14:31:23.801922+00
1e2ace5c-a3e5-43bf-9acc-af49524f1acf	2026-02-02	\N	BDO Recovery: Payment to Quimical swimming pools (BIM MZN)	supplier_payment	\N	t	\N	\N	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 14:31:23.801922+00
f143bfe6-be25-4e61-8dc5-1c28008e7b42	2026-02-02	\N	BDO Recovery: Payment to Bank Charges (BIM MZN)	supplier_payment	\N	t	\N	\N	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 14:31:23.801922+00
5886c69c-618e-4fee-9fb7-3af3b55a4b76	2026-02-02	\N	BDO Recovery: Payment to Advance (BIM MZN)	supplier_payment	\N	t	\N	\N	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 14:31:23.801922+00
502f3c4d-149a-4c9c-9707-b9d5e4e23d89	2026-02-02	\N	BDO Recovery: Payment to Bank Charges (BIM MZN)	supplier_payment	\N	t	\N	\N	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 14:31:23.801922+00
981f8824-7235-46e1-805b-2771ee1d9388	2026-02-04	\N	BDO Recovery: Payment to Union Fee (BIM MZN)	supplier_payment	\N	t	\N	\N	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 14:31:23.801922+00
09a04e9a-bb52-400b-a00e-09b0398482fe	2026-02-04	\N	BDO Recovery: Payment to Bank Charges (BIM MZN)	supplier_payment	\N	t	\N	\N	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 14:31:23.801922+00
cfed887c-99fc-42b4-85ee-021fc233d0b1	2026-02-09	\N	BDO Recovery: Payment to Advance (BIM MZN)	supplier_payment	\N	t	\N	\N	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 14:31:23.801922+00
91d7b864-ee32-427b-9dc8-7834c27a1251	2026-02-09	\N	BDO Recovery: Payment to Bank Charges (BIM MZN)	supplier_payment	\N	t	\N	\N	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 14:31:23.801922+00
c38e7aa7-cfbd-4601-baf5-bb579eaa8fe1	2026-02-10	\N	BDO Recovery: Payment to Electrisity (BIM MZN)	supplier_payment	\N	t	\N	\N	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 14:31:23.801922+00
fd1227e0-60ac-4e62-9514-5122cf716093	2026-02-10	\N	BDO Recovery: Payment to Bank Charges (BIM MZN)	supplier_payment	\N	t	\N	\N	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 14:31:23.801922+00
de83df3b-b1fa-44ba-b72e-a967c4d1b882	2026-02-14	\N	BDO Recovery: Payment to Diesel Generator (BIM MZN)	supplier_payment	\N	t	\N	\N	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 14:31:23.801922+00
5ee9b19f-5766-44fd-a8f8-d1eb6232d9bf	2026-02-18	\N	BDO Recovery: Payment to Advance (BIM MZN)	supplier_payment	\N	t	\N	\N	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 14:31:23.801922+00
7873473c-8023-4faf-9a46-33f8eb60d099	2026-02-18	\N	BDO Recovery: Payment to Bank Charges (BIM MZN)	supplier_payment	\N	t	\N	\N	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 14:31:23.801922+00
20b81470-5381-44ff-9d1c-572ccb9e9a6e	2026-02-18	\N	BDO Recovery: Payment to Accounting (BIM MZN)	supplier_payment	\N	t	\N	\N	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 14:31:23.801922+00
17c5d250-be5e-4297-9e3a-7f5545f96956	2026-02-18	\N	BDO Recovery: Payment to Bank Charges (BIM MZN)	supplier_payment	\N	t	\N	\N	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 14:31:23.801922+00
d4a496b6-edde-40c3-b919-8fe088775ef9	2026-02-19	\N	BDO Recovery: Payment to Admin Fee (BIM MZN)	supplier_payment	\N	t	\N	\N	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 14:31:23.801922+00
80e0da88-1dfd-4e95-82b1-55f9c4051d13	2026-02-19	\N	BDO Recovery: Payment to Bank Charges (BIM MZN)	supplier_payment	\N	t	\N	\N	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 14:31:23.801922+00
fc2c9050-aecf-4211-a70d-807c3586d4a6	2026-02-23	\N	BDO Recovery: Payment to Gas Jan (BIM MZN)	supplier_payment	\N	t	\N	\N	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 14:31:23.801922+00
32c9a1aa-9be1-42f9-bac8-26ef5e537d07	2026-02-23	\N	BDO Recovery: Payment to Bank Charges (BIM MZN)	supplier_payment	\N	t	\N	\N	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 14:31:23.801922+00
21fbe376-3ee2-42a3-aec2-0f2235b8480e	2026-02-23	\N	BDO Recovery: Payment to House Kepping Towel Duck (BIM MZN)	supplier_payment	\N	t	\N	\N	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 14:31:23.801922+00
06d92fad-acfa-43dd-89f3-dbd9a08ec7f3	2026-02-23	\N	BDO Recovery: Payment to Bank Charges (BIM MZN)	supplier_payment	\N	t	\N	\N	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 14:31:23.801922+00
d8697e6b-4106-403a-97ae-d60c735c9309	2026-02-23	\N	BDO Recovery: Payment to SIM R SEG (BIM MZN)	supplier_payment	\N	t	\N	\N	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 14:31:23.801922+00
5aa5e6df-6ece-468f-ac97-11bcba65dcc7	2026-02-23	\N	BDO Recovery: Payment to Revisao de Extintores (BIM MZN)	supplier_payment	\N	t	\N	\N	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 14:31:23.801922+00
6b13853a-4a3c-49d2-81d1-1ef14423c87e	2026-02-23	\N	BDO Recovery: Payment to Bank Charges (BIM MZN)	supplier_payment	\N	t	\N	\N	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 14:31:23.801922+00
46bfdfef-a019-48db-a3be-0ca3218145d9	2026-02-25	\N	BDO Recovery: Payment to Dolar to Mets (BIM MZN)	supplier_payment	\N	t	\N	\N	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 14:31:23.801922+00
1b4a834b-25d2-44a2-9037-811891ee2ad0	2026-02-25	\N	BDO Recovery: Payment to Salario Feb (BIM MZN)	supplier_payment	\N	t	\N	\N	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 14:31:23.801922+00
14653821-431b-4fef-85dd-d577f5eaf851	2026-02-25	\N	BDO Recovery: Payment to Bank Charges (BIM MZN)	supplier_payment	\N	t	\N	\N	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 14:31:23.801922+00
e77c5672-e6c9-4a9a-ba1e-9cdfe912482e	2026-02-26	\N	BDO Recovery: Payment to Cleaning supplies (BIM MZN)	supplier_payment	\N	t	\N	\N	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 14:31:23.801922+00
66ddeba1-baac-4466-af59-6de23a2b2a2d	2026-02-26	\N	BDO Recovery: Payment to Eletrical material (BIM MZN)	supplier_payment	\N	t	\N	\N	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 14:31:23.801922+00
c6991e6a-040a-4d96-b1bf-7b27f4e02d48	2026-02-27	\N	BDO Recovery: Payment to Lampadas (BIM MZN)	supplier_payment	\N	t	\N	\N	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 14:31:23.801922+00
7788c766-2c49-47d9-ad8f-748250de87a8	2026-01-01	\N	BDO Recovery: Payment to SINDICATO FEB (BIM MZN)	supplier_payment	\N	t	\N	\N	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 14:31:23.801922+00
e0845c91-72f6-459d-8ed7-9cc5f84a584b	2026-01-01	\N	BDO Recovery: Payment to INSS FEB (BIM MZN)	supplier_payment	\N	t	\N	\N	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 14:31:23.801922+00
9b7e2f04-50b7-4d2a-8721-dd785de5f5f9	2026-01-01	\N	BDO Recovery: Payment to IRPS FEB (BIM MZN)	supplier_payment	\N	t	\N	\N	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 14:31:23.801922+00
34b31397-961e-4a11-980f-c25a09321d94	2026-03-02	\N	BDO Recovery: Payment to JELSON (BIM MZN)	supplier_payment	\N	t	\N	\N	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 14:31:23.801922+00
34ee36ef-a06a-4a78-868b-2bfec8b8fcd2	2026-03-02	\N	BDO Recovery: Payment to BANK CHARGES (BIM MZN)	supplier_payment	\N	t	\N	\N	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 14:31:23.801922+00
e25f182e-e4ce-46ee-b9c1-f2a90e4b6a69	2026-03-05	\N	BDO Recovery: Payment to EMILIO ADVANCE (BIM MZN)	supplier_payment	\N	t	\N	\N	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 14:31:23.801922+00
7f271f15-1cda-4068-a121-c298843a98ad	2026-03-05	\N	BDO Recovery: Payment to BANK CHARGES (BIM MZN)	supplier_payment	\N	t	\N	\N	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 14:31:23.801922+00
a44725e8-2b6e-4759-a36c-3e36cd9f067c	2026-03-05	\N	BDO Recovery: Payment to TAFY ACCOMMODATION (BIM MZN)	supplier_payment	\N	t	\N	\N	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 14:31:23.801922+00
6f3edf0d-e0e7-4184-ba86-ec0f2ca5d038	2026-03-05	\N	BDO Recovery: Payment to CALDERON ADVANCE (BIM MZN)	supplier_payment	\N	t	\N	\N	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 14:31:23.801922+00
a4a013bc-18f0-4b6c-84b0-7272a510924c	2026-03-05	\N	BDO Recovery: Payment to BANK CHARGES (BIM MZN)	supplier_payment	\N	t	\N	\N	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 14:31:23.801922+00
8233fca7-afa2-47b9-bab5-e3a821593f90	2026-03-09	\N	BDO Recovery: Payment to VARNISH (BIM MZN)	supplier_payment	\N	t	\N	\N	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 14:31:23.801922+00
cc0e2d5a-65cd-481c-987d-7cac83a56b90	2026-03-09	\N	BDO Recovery: Payment to DIESEL MMR0998 (BIM MZN)	supplier_payment	\N	t	\N	\N	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 14:31:23.801922+00
11777c0b-72b4-4165-9a92-6f5138d4a9d3	2026-03-09	\N	BDO Recovery: Payment to TOILET PAPER (BIM MZN)	supplier_payment	\N	t	\N	\N	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 14:31:23.801922+00
010bfffd-2984-48eb-b1b9-8456df13031f	2026-03-09	\N	BDO Recovery: Payment to BANK CHARGES (BIM MZN)	supplier_payment	\N	t	\N	\N	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 14:31:23.801922+00
7d5da831-1b34-49fe-83f2-fbdc1f1c0429	2026-03-11	\N	BDO Recovery: Payment to ELECTRICITY (BIM MZN)	supplier_payment	\N	t	\N	\N	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 14:31:23.801922+00
b235ee0a-374b-4b37-bcf0-b172aee2e2ac	2026-03-11	\N	BDO Recovery: Payment to BANK CHARGES (BIM MZN)	supplier_payment	\N	t	\N	\N	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 14:31:23.801922+00
e76969e6-dd19-4d10-a78b-e339a0146b8c	2026-03-11	\N	BDO Recovery: Payment to IRPS (BIM MZN)	supplier_payment	\N	t	\N	\N	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 14:31:23.801922+00
10b47199-83a0-4106-90f3-29ea1f81f744	2026-03-16	\N	BDO Recovery: Payment to CHLOOR (BIM MZN)	supplier_payment	\N	t	\N	\N	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 14:31:23.801922+00
ff6b2260-d7de-4df3-8b72-110429e7d7cd	2026-03-16	\N	BDO Recovery: Payment to PLASTIC DE LUXO (BIM MZN)	supplier_payment	\N	t	\N	\N	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 14:31:23.801922+00
df97d337-15ba-472c-ba3a-76b9cb014bbf	2026-03-17	\N	BDO Recovery: Payment to CARTO DEBITO (BIM MZN)	supplier_payment	\N	t	\N	\N	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 14:31:23.801922+00
d0e63759-9db1-491b-bca5-d5deae0877d2	2026-03-18	\N	BDO Recovery: Payment to ACCOUNTING (BIM MZN)	supplier_payment	\N	t	\N	\N	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 14:31:23.801922+00
36cc4f2d-0976-42eb-a7ae-54b01b818b11	2026-03-18	\N	BDO Recovery: Payment to BANK CHARGES (BIM MZN)	supplier_payment	\N	t	\N	\N	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 14:31:23.801922+00
a29188f4-a4c9-40d3-8119-10ac33b8e02f	2026-03-18	\N	BDO Recovery: Payment to INSURANCE (BIM MZN)	supplier_payment	\N	t	\N	\N	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 14:31:23.801922+00
7eb96e78-caab-4bca-bb4d-2408f6304895	2026-03-18	\N	BDO Recovery: Payment to INSURANCE (BIM MZN)	supplier_payment	\N	t	\N	\N	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 14:31:23.801922+00
b6fdac54-e129-42d0-9a54-180fcf8e9c1c	2026-03-19	\N	BDO Recovery: Payment to BALDE PARA CONSTRUTOR (BIM MZN)	supplier_payment	\N	t	\N	\N	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 14:31:23.801922+00
3251888f-71ea-464b-a509-a566e9bf1777	2026-03-19	\N	BDO Recovery: Payment to CLEANING MATERIAL (BIM MZN)	supplier_payment	\N	t	\N	\N	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 14:31:23.801922+00
3ab25f78-42c1-48b2-be0e-87a736e93566	2026-03-19	\N	BDO Recovery: Payment to BATTERY PRADO H4 (BIM MZN)	supplier_payment	\N	t	\N	\N	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 14:31:23.801922+00
fa8933ad-a985-48ea-8621-ab8f5bc07ce7	2026-03-19	\N	BDO Recovery: Payment to SEALER H3 (BIM MZN)	supplier_payment	\N	t	\N	\N	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 14:31:23.801922+00
c7475e43-861b-4afa-a9e0-54980b2ba538	2026-03-19	\N	BDO Recovery: Payment to BANK CHARGES (BIM MZN)	supplier_payment	\N	t	\N	\N	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 14:31:23.801922+00
c5de8ffe-c61d-4711-9cf9-e7d648a95496	2026-03-24	\N	BDO Recovery: Payment to TRANSFER DOLLARS TO METICAIS (BIM MZN)	supplier_payment	\N	t	\N	\N	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 14:31:23.801922+00
46e0e21c-4f3b-4d18-8db4-d5d6bb4db62c	2026-03-23	\N	BDO Recovery: Payment to PETTY CASH (BIM MZN)	supplier_payment	\N	t	\N	\N	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 14:31:23.801922+00
b256a2ef-e123-448d-b1f3-2481e8004c0c	2026-03-25	\N	BDO Recovery: Payment to SALARY MARCH (BIM MZN)	supplier_payment	\N	t	\N	\N	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 14:31:23.801922+00
b8a61737-e3ce-42e1-a7ba-2102c671b1b7	2026-03-25	\N	BDO Recovery: Payment to BANK CHARGES (BIM MZN)	supplier_payment	\N	t	\N	\N	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 14:31:23.801922+00
88e3f59d-eac2-4475-ba97-62b15bc4b89b	2026-03-25	\N	BDO Recovery: Payment to ADMIN FEE (BIM MZN)	supplier_payment	\N	t	\N	\N	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 14:31:23.801922+00
e17bbdc3-2371-4d7d-a9f0-741b24171179	2026-03-25	\N	BDO Recovery: Payment to ACCOMMODATION ADVANCE APRIL (BIM MZN)	supplier_payment	\N	t	\N	\N	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 14:31:23.801922+00
9a21c0e1-8892-4c99-8c6c-8554b636ac43	2026-03-26	\N	BDO Recovery: Payment to LIGHTS OUTSIDE (BIM MZN)	supplier_payment	\N	t	\N	\N	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 14:31:23.801922+00
984a4b31-ee6e-48a9-b168-c46b26799de5	2026-03-26	\N	BDO Recovery: Payment to SINDICATO (BIM MZN)	supplier_payment	\N	t	\N	\N	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 14:31:23.801922+00
7d808c48-ef1b-4dbd-a9ee-94d05827516e	2026-03-27	\N	BDO Recovery: Payment to SOAP, JAVEL (BIM MZN)	supplier_payment	\N	t	\N	\N	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 14:31:23.801922+00
bc6173fd-d346-4299-b1f3-5f0b095b8313	2026-03-27	\N	BDO Recovery: Payment to TRANSFER DOLLARS TO METICAIS (BIM MZN)	supplier_payment	\N	t	\N	\N	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 14:31:23.801922+00
6666393d-ccf9-4cc6-9bc7-350302678215	2026-03-27	\N	BDO Recovery: Payment to IPRA 2026 (BIM MZN)	supplier_payment	\N	t	\N	\N	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 14:31:23.801922+00
e1c8e104-9893-437f-b100-b2c2878bfdb4	2026-03-27	\N	BDO Recovery: Payment to TAE (BIM MZN)	supplier_payment	\N	t	\N	\N	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 14:31:23.801922+00
13529d6b-6eef-4604-9103-7eb4c1a2ee94	2026-03-27	\N	BDO Recovery: Payment to DIESEL GENERATOR (BIM MZN)	supplier_payment	\N	t	\N	\N	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 14:31:23.801922+00
c3fd9a38-82bc-4e1a-8790-2e3c1011256c	2026-03-27	\N	BDO Recovery: Payment to Q20 OIL ANTI RUST (BIM MZN)	supplier_payment	\N	t	\N	\N	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 14:31:23.801922+00
76616db5-2b14-43a8-9dff-4e86114fb78c	2026-03-30	\N	BDO Recovery: Payment to DIESEL TOYOTA AKL491MP (BIM MZN)	supplier_payment	\N	t	\N	\N	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 14:31:23.801922+00
4d289ed5-d6cb-429e-8d16-f01e7a10d54f	2026-03-27	\N	BDO Recovery: Payment to DIESEL PRADO HOUSE 4 (BIM MZN)	supplier_payment	\N	t	\N	\N	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 14:31:23.801922+00
fff02efc-de6f-414c-80c7-618fc47174e7	2026-03-30	\N	BDO Recovery: Payment to INSS (BIM MZN)	supplier_payment	\N	t	\N	\N	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 14:31:23.801922+00
8a6794b5-adc2-4c13-9a45-0fec5a78ca1a	2026-03-30	\N	BDO Recovery: Payment to TRANSFER DOLLARS TO METICAIS (BIM MZN)	supplier_payment	\N	t	\N	\N	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 14:31:23.801922+00
a49ad381-5458-4f5d-bbf7-4a0738ffc3de	2026-03-30	\N	BDO Recovery: Payment to INSURANCE VEHICLES (BIM MZN)	supplier_payment	\N	t	\N	\N	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 14:31:23.801922+00
41731cf2-fc43-4e70-8727-840955acfc80	2026-03-30	\N	BDO Recovery: Payment to BANK CHARGES (BIM MZN)	supplier_payment	\N	t	\N	\N	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 14:31:23.801922+00
52555a44-3783-4e15-bcd7-9b126144965f	2026-03-30	\N	BDO Recovery: Payment to WORKMENS COMPENSATIO (BIM MZN)	supplier_payment	\N	t	\N	\N	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 14:31:23.801922+00
27564a1f-af7a-4acb-a7ae-b2a4f42802db	2026-03-30	\N	BDO Recovery: Payment to BANK CHARGES (BIM MZN)	supplier_payment	\N	t	\N	\N	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 14:31:23.801922+00
517adcce-ab93-40bb-ae30-eda57dfcba5e	2026-03-31	\N	BDO Recovery: Payment to GAS FEBRUARY (BIM MZN)	supplier_payment	\N	t	\N	\N	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 14:31:23.801922+00
8cf7cd1b-ca0f-447f-8ad4-30b8509a2578	2026-03-31	\N	BDO Recovery: Payment to GLOBES (BIM MZN)	supplier_payment	\N	t	\N	\N	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 14:31:23.801922+00
63138b7e-f2fa-4368-afc2-55b19309aa3f	2026-03-31	\N	BDO Recovery: Payment to IRPS (BIM MZN)	supplier_payment	\N	t	\N	\N	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 14:31:23.801922+00
119db070-9743-472c-b7fb-2f96b4d2ef9a	2026-03-17	\N	Equity Contribution: WARREN COHEN - SHAREHOLDERS CONTRIBUTION	equity	\N	t	\N	\N	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 14:31:23.801922+00
97355425-0567-47a0-89bf-e06eb0e9ec99	2026-03-17	\N	Equity Contribution: WARREN COHEN - SHAREHOLDERS CONTRIBUTION	equity	\N	t	\N	\N	1e6a9107-e40e-4416-8443-7bfa5e0b00ba	2026-04-19 14:31:23.801922+00
\.


--
-- Data for Name: journal_lines; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.journal_lines (id, journal_entry_id, account_id, debit, credit, memo) FROM stdin;
3cc87e55-51d3-4ff4-a5d5-27a162dba248	7e05dad7-7a50-46ba-8719-edf0779184ca	d1b3d196-3608-4ab9-a2f3-b0a7845c524b	7	0	BANKCHARGES OFFICE EXPENSES
3eea9309-8b5d-4b95-8007-f129aadddad2	7e05dad7-7a50-46ba-8719-edf0779184ca	d1b3d196-3608-4ab9-a2f3-b0a7845c524b	7	0	BANKCHARGES OFFICE EXPENSES
48894548-2746-4d5e-bc83-3ee7c99ba630	7e05dad7-7a50-46ba-8719-edf0779184ca	d1b3d196-3608-4ab9-a2f3-b0a7845c524b	7	0	BANKCHARGES OFFICE EXPENSES
90e2b139-0d25-4381-a806-8ee16084e3ff	7e05dad7-7a50-46ba-8719-edf0779184ca	874b7069-fafa-46ab-b6f4-b8b3781ac18d	0	21	Suspense ??? awaiting reclassification
c30798ae-2c22-4023-9c85-3f8d1299d6fe	b39b2d3a-6860-4c6a-a12e-f7263effc15b	d1b3d196-3608-4ab9-a2f3-b0a7845c524b	7	0	BANKCHARGES OFFICE EXPENSES
b55f43e5-0f69-4817-b0b3-939415301b8e	b39b2d3a-6860-4c6a-a12e-f7263effc15b	874b7069-fafa-46ab-b6f4-b8b3781ac18d	0	7	Suspense ??? awaiting reclassification
9ce72a73-9aa8-41d0-aef6-4d742bc835e4	7a4e4cc8-2e5a-4d92-9de4-f56c2038cef6	d1b3d196-3608-4ab9-a2f3-b0a7845c524b	7	0	BANK CHARGES OFFICE EXPENSES
102c14bb-be8e-418c-b590-5fd9641873fd	7a4e4cc8-2e5a-4d92-9de4-f56c2038cef6	874b7069-fafa-46ab-b6f4-b8b3781ac18d	0	7	Suspense ??? awaiting reclassification
1459f480-2ba6-4165-8746-8ef63a02513c	fa272459-f525-49fb-927e-859f21f5951e	f4316599-685b-4fc2-b68d-f04179abe57a	1037.39	0	GENERAL MAITENANCE
a93b2f63-c64e-4ca3-b81f-20c0b6e4c734	fa272459-f525-49fb-927e-859f21f5951e	874b7069-fafa-46ab-b6f4-b8b3781ac18d	0	1037.39	Suspense ??? awaiting reclassification
92c84974-2cbf-4ad9-bc28-c0d00dd2ee04	a1e4bf57-2b0a-484d-b572-f68fb58c8557	d1b3d196-3608-4ab9-a2f3-b0a7845c524b	257	0	OFFICE EXPENSES
3d7fa442-c7fe-4113-b1fc-f00d2e9bb15b	a1e4bf57-2b0a-484d-b572-f68fb58c8557	874b7069-fafa-46ab-b6f4-b8b3781ac18d	0	257	Suspense ??? awaiting reclassification
7203a28c-0f85-407d-a5a1-896b6c137cc7	d47bdc0c-eb31-40fb-9431-68539d099079	f4316599-685b-4fc2-b68d-f04179abe57a	524	0	GENERAL MAINTENANCE
dc94cd43-b5c2-4dc1-a238-a0b8a096c457	d47bdc0c-eb31-40fb-9431-68539d099079	874b7069-fafa-46ab-b6f4-b8b3781ac18d	0	524	Suspense ??? awaiting reclassification
b511bf0a-3e1f-4c05-adaf-1e02046f0202	e64b14a4-1449-4484-8256-c7fdfdb5f382	f4316599-685b-4fc2-b68d-f04179abe57a	2025	0	GENERAL MAINTENANCE
f057c44c-4a59-4809-923a-3ab9bbb14112	e64b14a4-1449-4484-8256-c7fdfdb5f382	874b7069-fafa-46ab-b6f4-b8b3781ac18d	0	2025	Suspense ??? awaiting reclassification
67f6ddfe-cfbb-471e-ac91-f86efbad9c55	c0c4721b-387c-408c-b60a-c10ab2559e37	f4316599-685b-4fc2-b68d-f04179abe57a	10000	0	PETTY CSH
f8480eb5-dd7c-426a-a2aa-0e5b7d915f5c	c0c4721b-387c-408c-b60a-c10ab2559e37	874b7069-fafa-46ab-b6f4-b8b3781ac18d	0	10000	Suspense ??? awaiting reclassification
084bd23c-17a8-4452-96fb-003af9fc7ece	4a8c839e-b13a-4623-be10-ad485968d37f	874b7069-fafa-46ab-b6f4-b8b3781ac18d	88	0	SUSPENSE
471a9b19-1114-4f65-a756-ab7fdce4b3b9	4a8c839e-b13a-4623-be10-ad485968d37f	874b7069-fafa-46ab-b6f4-b8b3781ac18d	0	88	Suspense ??? awaiting reclassification
3806cbf0-ed83-4e50-94fc-bb84a86397e6	2bdc2163-568c-4a39-89a0-84648a0f29e4	874b7069-fafa-46ab-b6f4-b8b3781ac18d	0	88	SUSPENSE
097e3a28-dd8f-47a7-8944-00b1c4b449d8	2bdc2163-568c-4a39-89a0-84648a0f29e4	874b7069-fafa-46ab-b6f4-b8b3781ac18d	88	0	Suspense reversal
7652b118-c073-4742-93bb-446af1b5505b	109e24b2-2122-42ec-8e8c-eb57bef982fd	6b8b2920-50ae-4223-8a0f-1cab882ee142	7000	0	CASUAL GUARD FOR JANUARY
8a922875-5dd6-43d3-85c5-4550c3607c56	109e24b2-2122-42ec-8e8c-eb57bef982fd	874b7069-fafa-46ab-b6f4-b8b3781ac18d	0	7000	Suspense ??? awaiting reclassification
cd04d687-8bba-4179-9050-af4b18f52273	c50dde20-2d91-4f8e-b2b2-582bf222eb2c	87fb5009-8839-4d72-9029-d60089264222	35000	0	CHRIS MONTHLY JANUARY
c71cc70d-b04d-4654-a7fd-7d75e57a8a87	c50dde20-2d91-4f8e-b2b2-582bf222eb2c	874b7069-fafa-46ab-b6f4-b8b3781ac18d	0	35000	Suspense ??? awaiting reclassification
7ea57b0f-7e10-4f02-a2fb-16c6212912fc	1c425d00-f1cf-4d3a-8f85-654509498fa1	f4316599-685b-4fc2-b68d-f04179abe57a	3328	0	GENERAL EXPENSES
d5952612-738c-42c3-9cab-99cca4435310	1c425d00-f1cf-4d3a-8f85-654509498fa1	874b7069-fafa-46ab-b6f4-b8b3781ac18d	0	3328	Suspense ??? awaiting reclassification
39819312-02a8-4e71-ade8-8eead5e57416	af28dd0c-0020-40df-8d1d-9fae46b401e7	d1b3d196-3608-4ab9-a2f3-b0a7845c524b	7	0	BANK CHARGES SINDICATO BEB
9aa0c0d3-e86c-4a81-9993-c1b26da352fe	af28dd0c-0020-40df-8d1d-9fae46b401e7	874b7069-fafa-46ab-b6f4-b8b3781ac18d	0	7	Suspense ??? awaiting reclassification
cb532de8-0550-450e-8319-50f3daf8764d	1d137822-619d-440e-bac3-3e5a7edbecaa	50fb02f6-a453-4017-a9be-ec814c86db70	1290	0	HOUSE KEEPING
430ff72e-4a21-44d2-843c-bc3199ac673f	1d137822-619d-440e-bac3-3e5a7edbecaa	874b7069-fafa-46ab-b6f4-b8b3781ac18d	0	1290	Suspense ??? awaiting reclassification
19ba62bc-3095-4664-8eda-b25b97891470	2383350e-7a15-4b49-b9ac-ab7c33b9f49a	d1b3d196-3608-4ab9-a2f3-b0a7845c524b	7	0	BANK CHARGES
d0f71f57-993d-4d09-932b-a2a34f32d8ef	2383350e-7a15-4b49-b9ac-ab7c33b9f49a	874b7069-fafa-46ab-b6f4-b8b3781ac18d	0	7	Suspense ??? awaiting reclassification
e35fa518-c148-4b7d-9bca-dd311a33f21c	e75a86ee-42c9-466e-9978-bdf0f1bc8ff9	50fb02f6-a453-4017-a9be-ec814c86db70	3330	0	HOUSE KEEPING
4986fb95-69ba-4704-adb9-219a5bd7d31e	e75a86ee-42c9-466e-9978-bdf0f1bc8ff9	874b7069-fafa-46ab-b6f4-b8b3781ac18d	0	3330	Suspense ??? awaiting reclassification
9c6cf7cc-b99a-4300-b36b-20db9240b6e2	6665feb8-ec43-41e8-a8e6-479fa51c33f3	d1b3d196-3608-4ab9-a2f3-b0a7845c524b	7	0	BANK CHARGES
106afc1c-6cf2-4311-91e7-18321a8272fe	6665feb8-ec43-41e8-a8e6-479fa51c33f3	874b7069-fafa-46ab-b6f4-b8b3781ac18d	0	7	Suspense ??? awaiting reclassification
fc75953c-4120-4450-94b8-890294875615	ef789ae0-f38c-4012-bff0-e6b7ce7bc81c	d1b3d196-3608-4ab9-a2f3-b0a7845c524b	257	0	BANK CHARGES
631fd690-c9b2-48a0-8ddc-77ca9c387e60	ef789ae0-f38c-4012-bff0-e6b7ce7bc81c	874b7069-fafa-46ab-b6f4-b8b3781ac18d	0	257	Suspense ??? awaiting reclassification
d421179a-de86-4099-8961-7fdb54cde5d2	2128c23d-cd0b-479e-b945-9ab84988d0c3	50fb02f6-a453-4017-a9be-ec814c86db70	5430	0	HOUSE KEEPING
062c4d94-ba23-4325-ad55-a664e75a8faf	2128c23d-cd0b-479e-b945-9ab84988d0c3	874b7069-fafa-46ab-b6f4-b8b3781ac18d	0	5430	Suspense ??? awaiting reclassification
ad058101-e62b-40ac-a9f3-078c91b34801	85af5791-fe1b-4276-b734-2e5e00a67354	70b46831-94b4-4d9b-85d3-9ac5a24c375b	12280	0	ELECTRISITY
a4f73fd5-b414-4e5a-83b6-7c4cc817be36	85af5791-fe1b-4276-b734-2e5e00a67354	874b7069-fafa-46ab-b6f4-b8b3781ac18d	0	12280	Suspense ??? awaiting reclassification
78d3ac55-4c6e-40fb-a559-c72252050588	4385d149-f06f-492d-ad2e-9584e91ccd73	ec75b33a-b32c-47a7-ac2b-1ca610c87b0c	3292.74	0	MOTOR VEHICLES EXPENSES
81f162a7-b0c3-4b05-b09c-fe5c7c4ad703	4385d149-f06f-492d-ad2e-9584e91ccd73	874b7069-fafa-46ab-b6f4-b8b3781ac18d	0	3292.74	Suspense ??? awaiting reclassification
b7118349-3653-4a45-a154-dd58a02c3389	41e068d8-5eed-4d36-8391-b3871ce6740d	d1b3d196-3608-4ab9-a2f3-b0a7845c524b	120	0	BANK CHARGES
75a52438-e463-4689-9242-b2bb36d780c5	41e068d8-5eed-4d36-8391-b3871ce6740d	d1b3d196-3608-4ab9-a2f3-b0a7845c524b	120	0	BANK CHARGES
6816ff68-f50e-4930-95c3-b633c5965cec	41e068d8-5eed-4d36-8391-b3871ce6740d	874b7069-fafa-46ab-b6f4-b8b3781ac18d	0	240	Suspense ??? awaiting reclassification
0174a4ce-2c44-4cad-98bc-0acb26f240c7	8c3e989f-1c39-4ff4-8d05-9aa189577c2e	f4316599-685b-4fc2-b68d-f04179abe57a	1235	0	GENERAL MAINTRENANCE
cde43aae-1c17-4b5f-b5ba-825515868047	8c3e989f-1c39-4ff4-8d05-9aa189577c2e	874b7069-fafa-46ab-b6f4-b8b3781ac18d	0	1235	Suspense ??? awaiting reclassification
75b700ae-5135-4310-8aec-e412abf247cf	83a6fb82-d8b9-4827-adc8-e71eb1256eaf	70b46831-94b4-4d9b-85d3-9ac5a24c375b	6426.95	0	GAS DECEMBER
9dbf24c8-fc09-4035-b5d6-e9fcb32d6dd0	83a6fb82-d8b9-4827-adc8-e71eb1256eaf	874b7069-fafa-46ab-b6f4-b8b3781ac18d	0	6426.95	Suspense ??? awaiting reclassification
0ec1cf36-4295-4a78-b15d-04458d29c44c	c55e90aa-685f-4975-b5ce-3e7bb3b246bc	187fe3a6-3f3f-4f8c-a570-70ae06e907ca	146740	0	ADMIN AND ACCOUNTING
416207bb-5ff5-4476-8ca2-4c6ccc931d08	c55e90aa-685f-4975-b5ce-3e7bb3b246bc	874b7069-fafa-46ab-b6f4-b8b3781ac18d	0	146740	Suspense ??? awaiting reclassification
9867f447-ec95-43c2-a74f-277792755721	89ddfb17-f5d5-47f5-9d6f-894fad670df7	d1b3d196-3608-4ab9-a2f3-b0a7845c524b	7	0	BANK CHARGES OFFICE EXPENSES
f2db757e-a203-439a-bc6c-9a7405e32f0c	89ddfb17-f5d5-47f5-9d6f-894fad670df7	874b7069-fafa-46ab-b6f4-b8b3781ac18d	0	7	Suspense ??? awaiting reclassification
fd0d7950-148b-4cb1-abf0-ce754c559516	41e7ff5a-d37d-4270-acd4-d0ff351358a1	d1b3d196-3608-4ab9-a2f3-b0a7845c524b	1500	0	STATIONARY
d6186a20-dd1e-4289-89c5-d7c6e861f563	41e7ff5a-d37d-4270-acd4-d0ff351358a1	874b7069-fafa-46ab-b6f4-b8b3781ac18d	0	1500	Suspense ??? awaiting reclassification
a34762ca-511a-449c-84c0-5e63431b3712	4ac70d05-8898-485d-8baf-978f6a9ee47f	874b7069-fafa-46ab-b6f4-b8b3781ac18d	10000	0	SUSPENCE
5ef6b8aa-325d-4f06-babb-ad88876dfe75	4ac70d05-8898-485d-8baf-978f6a9ee47f	874b7069-fafa-46ab-b6f4-b8b3781ac18d	0	10000	Suspense ??? awaiting reclassification
33a52f78-cb8e-4863-804f-9298df0d9ea2	5d8a32a0-73c6-4bc5-8739-cc348ae8f173	6b8b2920-50ae-4223-8a0f-1cab882ee142	12000	0	WORKERS FOOD ALOWANCE
7bba0ed1-6b0b-49d3-baf9-57ee166486ed	5d8a32a0-73c6-4bc5-8739-cc348ae8f173	874b7069-fafa-46ab-b6f4-b8b3781ac18d	0	12000	Suspense ??? awaiting reclassification
46d0f8ba-edc6-4d74-9a5e-8e1078a39362	d84c5a1d-4510-47e6-9085-7b755ddbbb7e	70b46831-94b4-4d9b-85d3-9ac5a24c375b	4833.15	0	GAS & ELECTRISITY
c256c129-5686-446a-87af-c34732f74aa2	d84c5a1d-4510-47e6-9085-7b755ddbbb7e	874b7069-fafa-46ab-b6f4-b8b3781ac18d	0	4833.15	Suspense ??? awaiting reclassification
9b1b709b-2922-42aa-a6ec-2958183f855c	d3d9a7fe-8f58-4d0e-867d-da921c035dd5	f4316599-685b-4fc2-b68d-f04179abe57a	900	0	GENERAL MAINTENANCE
4da24500-1f88-422c-bde9-1b3100310e34	d3d9a7fe-8f58-4d0e-867d-da921c035dd5	874b7069-fafa-46ab-b6f4-b8b3781ac18d	0	900	Suspense ??? awaiting reclassification
2c3e8eaf-e0be-48cd-9472-56fe6f764590	422cea12-835c-4ce1-a924-c2d48d12bf4e	d1b3d196-3608-4ab9-a2f3-b0a7845c524b	1462.56	0	FINES
2c4f30b4-f50a-468a-8c6f-21eeebe165ff	422cea12-835c-4ce1-a924-c2d48d12bf4e	874b7069-fafa-46ab-b6f4-b8b3781ac18d	0	1462.56	Suspense ??? awaiting reclassification
b84ba806-30b8-43b8-82b5-30776a9ca772	38a6efb2-c9ae-4977-8118-717f4208d60c	f4316599-685b-4fc2-b68d-f04179abe57a	8329	0	GENERAL MAITENANCE
4c6b1d8b-18ba-49d6-8c12-eaaff2ee4d36	38a6efb2-c9ae-4977-8118-717f4208d60c	874b7069-fafa-46ab-b6f4-b8b3781ac18d	0	8329	Suspense ??? awaiting reclassification
abbe709a-ff4a-4390-925e-995be35bcc52	08426640-7d4f-4075-bbe4-51769a845d3e	d1b3d196-3608-4ab9-a2f3-b0a7845c524b	3000	0	STARLINK FOR JAN
ba2014de-73de-4664-b5ca-b1af9e0b5301	08426640-7d4f-4075-bbe4-51769a845d3e	874b7069-fafa-46ab-b6f4-b8b3781ac18d	0	3000	Suspense ??? awaiting reclassification
d2013854-4cac-4e52-87b3-97734f5c1d70	09e26dc1-2e4c-4923-b999-8cf2fbd413b8	6b8b2920-50ae-4223-8a0f-1cab882ee142	21000	0	FOOD FOR WORKERS
b0c02fc7-4812-44eb-96c1-8cc4de411e4e	09e26dc1-2e4c-4923-b999-8cf2fbd413b8	874b7069-fafa-46ab-b6f4-b8b3781ac18d	0	21000	Suspense ??? awaiting reclassification
cf39a257-8a5c-4295-bd1e-78c62c91733e	101f3ddf-6f52-4595-ad92-f0e28ff9f5bc	28313434-8859-4a01-9892-7d359ab212fd	2220	0	Shortfall on Ronny money from Warren
c2cf389e-cf19-49d3-8dc7-87570510307e	101f3ddf-6f52-4595-ad92-f0e28ff9f5bc	874b7069-fafa-46ab-b6f4-b8b3781ac18d	0	2220	Suspense ??? awaiting reclassification
2f19bc82-2fea-4ace-a82b-4ab85cfd2c7e	64bdb517-2370-45d2-82f5-0d26cc9a97d2	d1b3d196-3608-4ab9-a2f3-b0a7845c524b	7	0	BANK CHARGES
a2b446d4-3bdf-4d85-97f8-51d5d4510799	64bdb517-2370-45d2-82f5-0d26cc9a97d2	874b7069-fafa-46ab-b6f4-b8b3781ac18d	0	7	Suspense ??? awaiting reclassification
8f1e409a-c756-4af3-b8ad-aeb08d589796	f5d6b151-a579-486e-aa8d-6a4d7b242ef4	81e2a489-220c-4c3b-a529-e2f08c60b4be	7384.37	0	MOTOR VEHICLE LANDCO
afb270c4-312f-42c3-aac8-ef0e6c99eade	f5d6b151-a579-486e-aa8d-6a4d7b242ef4	874b7069-fafa-46ab-b6f4-b8b3781ac18d	0	7384.37	Suspense ??? awaiting reclassification
9a27ad15-95a1-4d7c-877c-2d9dd73ca7ac	b63e52f7-2566-4e83-b643-f432f5f38501	d1b3d196-3608-4ab9-a2f3-b0a7845c524b	7	0	BANK CHARGES
6f271272-6b05-4dcf-b79b-502f53e8ce69	b63e52f7-2566-4e83-b643-f432f5f38501	874b7069-fafa-46ab-b6f4-b8b3781ac18d	0	7	Suspense ??? awaiting reclassification
1e00096f-06aa-439a-ac41-551d6c28afcc	08af3a5a-5054-463b-9849-69f9516fab4d	d1b3d196-3608-4ab9-a2f3-b0a7845c524b	600	0	BANK CHARGES
58f6c1ac-d2b5-41fc-8c24-2a8634e08116	08af3a5a-5054-463b-9849-69f9516fab4d	874b7069-fafa-46ab-b6f4-b8b3781ac18d	0	600	Suspense ??? awaiting reclassification
7e2c8a20-67b7-4d0d-9d11-7197494148ba	66dae584-41ba-4780-8003-cb4d173da95c	5fe74161-6045-4c6b-95b0-b3d1a5caea04	1409.68	0	INSURANCE JETSKI
dadbe8cf-2502-4451-9ef5-661e45c5d339	66dae584-41ba-4780-8003-cb4d173da95c	5fe74161-6045-4c6b-95b0-b3d1a5caea04	1409.68	0	INSURANCE TRAILER
30017f0b-7f49-4c21-9da5-eb866012e2df	66dae584-41ba-4780-8003-cb4d173da95c	874b7069-fafa-46ab-b6f4-b8b3781ac18d	0	2819.36	Suspense ??? awaiting reclassification
71083e14-899c-48ed-bab3-0b671fdb2c20	1cb99578-4d38-4d77-bdff-3540e48e9880	ec75b33a-b32c-47a7-ac2b-1ca610c87b0c	10500	0	MOTOR VEHICLES EXPENSES
f0d854a6-64ca-4bc8-bc69-a2f1a25170cc	1cb99578-4d38-4d77-bdff-3540e48e9880	874b7069-fafa-46ab-b6f4-b8b3781ac18d	0	10500	Suspense ??? awaiting reclassification
5406ea7e-2ce2-4521-a789-8026d5e5fc60	aab75988-68fb-4634-97b7-c9cfe0de6ea5	874b7069-fafa-46ab-b6f4-b8b3781ac18d	18889.39	0	SUSPENSE
8a29e370-8a98-4a5e-b849-2ea46e802a5c	aab75988-68fb-4634-97b7-c9cfe0de6ea5	874b7069-fafa-46ab-b6f4-b8b3781ac18d	0	18889.39	Suspense ??? awaiting reclassification
4d1dfbec-d67a-4e91-b935-b5493dd2a700	a64976d7-0b33-4889-9ea1-63ae172fe546	187fe3a6-3f3f-4f8c-a570-70ae06e907ca	146740	0	ACCOUNTING AND ADMIN
92133f92-5884-4527-b0c9-b7edc6f51eb9	a64976d7-0b33-4889-9ea1-63ae172fe546	874b7069-fafa-46ab-b6f4-b8b3781ac18d	0	146740	Suspense ??? awaiting reclassification
9aa3b834-34a0-4934-bc57-962a1b69c0bd	c7e89fa9-d9a9-45cc-8c29-6a0673a7d9ab	02bb5911-fe97-49bd-87dc-67e8873049f8	52850	0	LAND TAX
e5bb1295-ad00-4c23-a557-02690fdf360b	c7e89fa9-d9a9-45cc-8c29-6a0673a7d9ab	874b7069-fafa-46ab-b6f4-b8b3781ac18d	0	52850	Suspense ??? awaiting reclassification
9bc91327-253b-4e8e-aae9-bd38252924c6	c50729ec-109b-4981-b0ce-048a2991afe5	f4316599-685b-4fc2-b68d-f04179abe57a	1420.24	0	GENERAL MAINENANCE
b26fb211-79c5-4361-a409-16a0ba158740	c50729ec-109b-4981-b0ce-048a2991afe5	874b7069-fafa-46ab-b6f4-b8b3781ac18d	0	1420.24	Suspense ??? awaiting reclassification
0dd1cb05-25e7-4464-80fb-27750ce0a80e	903ab038-9096-40de-8b85-b8e88ee7ad90	70b46831-94b4-4d9b-85d3-9ac5a24c375b	77851.16	0	GAS & ELECTRISITY
d5cc73b7-c136-4b7d-845b-e9ec1aa5fa9e	903ab038-9096-40de-8b85-b8e88ee7ad90	874b7069-fafa-46ab-b6f4-b8b3781ac18d	0	77851.16	Suspense ??? awaiting reclassification
bf21e64c-4767-4302-99f6-707d185ec1c4	d52e8430-d0e4-4e5a-8118-6015df6ec0c3	187fe3a6-3f3f-4f8c-a570-70ae06e907ca	37385.8	0	ACCOUNTING FEE
27aad162-1ecd-48c5-b0b5-0aa02ce6ccd2	d52e8430-d0e4-4e5a-8118-6015df6ec0c3	874b7069-fafa-46ab-b6f4-b8b3781ac18d	0	37385.8	Suspense ??? awaiting reclassification
71c6c0fc-adcc-4069-ae5d-588cc424997a	8a10746b-08e3-4821-807e-fcd472263cc4	d1b3d196-3608-4ab9-a2f3-b0a7845c524b	7	0	BANK CHARGES OFFICE EXPENSES
3085f84d-b76c-4e59-ab25-9e9348c27a51	8a10746b-08e3-4821-807e-fcd472263cc4	874b7069-fafa-46ab-b6f4-b8b3781ac18d	0	7	Suspense ??? awaiting reclassification
e48f4526-b372-4951-a60f-4c09bd56165b	51b73b94-6be3-4e8a-8457-0b8482d8dee3	87fb5009-8839-4d72-9029-d60089264222	174740	0	SALARIES & WAGES
4167c960-6632-4b40-8fce-3d2ab364d681	51b73b94-6be3-4e8a-8457-0b8482d8dee3	f2e2debb-22fa-4a16-85ab-a07383ed6aad	33449	0	SALARIES & WAGES
11f8eff9-1a3f-42ac-8703-dc403febb43c	51b73b94-6be3-4e8a-8457-0b8482d8dee3	28313434-8859-4a01-9892-7d359ab212fd	58534	0	SALARIES & WAGES
99ea2e13-c988-4c2d-ac75-5e52744a912b	51b73b94-6be3-4e8a-8457-0b8482d8dee3	07bb7fe0-e3a9-4ef0-bcf5-769379b58e22	36625	0	SALARIES & WAGES
4bb3bd4b-55df-4793-a23e-e208ca665cfb	51b73b94-6be3-4e8a-8457-0b8482d8dee3	ec75b33a-b32c-47a7-ac2b-1ca610c87b0c	43125	0	SALARIES & WAGES
61954125-536c-4eaf-9f3e-3a3c153073d1	51b73b94-6be3-4e8a-8457-0b8482d8dee3	874b7069-fafa-46ab-b6f4-b8b3781ac18d	0	346473	Suspense ??? awaiting reclassification
4a9c76d0-e200-42ab-9971-1c18fa4f937d	43b5c163-357c-4eaf-ab87-1f00105aff62	87fb5009-8839-4d72-9029-d60089264222	6989.6	0	SALARIES$ WAGES
5d000e66-490a-46fe-b729-05cd5af77b0a	43b5c163-357c-4eaf-ab87-1f00105aff62	f2e2debb-22fa-4a16-85ab-a07383ed6aad	1337.96	0	SALARIES$ WAGES
794b83bb-962c-4a8c-b904-896b987ad734	43b5c163-357c-4eaf-ab87-1f00105aff62	28313434-8859-4a01-9892-7d359ab212fd	2341.36	0	SALARIES$ WAGES
44dcdf1e-2334-4c9f-a615-91a5f49cc8fb	43b5c163-357c-4eaf-ab87-1f00105aff62	07bb7fe0-e3a9-4ef0-bcf5-769379b58e22	1465	0	SALARIES$ WAGES
f5fe6a7d-5423-4fa2-a960-6be066fc2ea2	43b5c163-357c-4eaf-ab87-1f00105aff62	ec75b33a-b32c-47a7-ac2b-1ca610c87b0c	1725	0	SALARIES$ WAGES
f3cce251-e267-487f-bc99-12f5b2733cbe	43b5c163-357c-4eaf-ab87-1f00105aff62	874b7069-fafa-46ab-b6f4-b8b3781ac18d	0	13858.920000000002	Suspense ??? awaiting reclassification
25a78393-9d37-41ee-b9dc-c770fd1f7504	deceee25-3803-4fca-a562-0d240cfa77c9	d1b3d196-3608-4ab9-a2f3-b0a7845c524b	7	0	BANKCHARGES OFFICE EXPENSES
e1f861fb-8caf-450d-8433-8e2787d1da9f	deceee25-3803-4fca-a562-0d240cfa77c9	874b7069-fafa-46ab-b6f4-b8b3781ac18d	0	7	Suspense ??? awaiting reclassification
9011dff2-9a55-4a0e-9feb-00c93bdc4946	28f1a09f-fecf-48ba-b1f6-939df1708942	d1b3d196-3608-4ab9-a2f3-b0a7845c524b	575	0	OFFICE & BANK CHARGES
1c4c936b-278c-4674-b4b1-6a932460e327	28f1a09f-fecf-48ba-b1f6-939df1708942	874b7069-fafa-46ab-b6f4-b8b3781ac18d	0	575	Suspense ??? awaiting reclassification
dcffb92f-ae65-4b12-b00d-32740043830d	7b2765a3-4712-4cec-a269-5ca9d3f57d5a	874b7069-fafa-46ab-b6f4-b8b3781ac18d	0	10000	SUSPENCE
33e41b4a-987d-42bd-a431-acd6ed81398b	7b2765a3-4712-4cec-a269-5ca9d3f57d5a	874b7069-fafa-46ab-b6f4-b8b3781ac18d	10000	0	Suspense reversal
cb2497ca-ddbd-4fa4-8509-36ed8a22d266	e202902a-cc37-4098-9907-0d24efd1c24c	07bb7fe0-e3a9-4ef0-bcf5-769379b58e22	10208	0	NEW BUILDING
d9fa0db7-0dc0-4659-a2b8-fc4e169ff0f5	e202902a-cc37-4098-9907-0d24efd1c24c	874b7069-fafa-46ab-b6f4-b8b3781ac18d	0	10208	Suspense ??? awaiting reclassification
726c5abd-3bc9-47d6-8252-2a7bed1d3383	e6e26b0e-f7a7-4236-8251-166c368d9ab6	8b0b5f3d-dc15-46cd-8515-3193543e89cf	3000	0	MONEY FOR OPERATION
d443bfd3-5f79-4830-adac-1ffe65f6a06d	e6e26b0e-f7a7-4236-8251-166c368d9ab6	874b7069-fafa-46ab-b6f4-b8b3781ac18d	0	3000	Suspense ??? awaiting reclassification
3017c776-c029-4bcd-b6a4-cd52c335e770	d188ef75-2204-43e0-878a-bb6f0d01add1	6b8b2920-50ae-4223-8a0f-1cab882ee142	9000	0	RAYMONDO FOR ACCOMMODATION 9 DAY @1500
1e292674-1735-4f13-a5c4-4490d2ce8e7a	d188ef75-2204-43e0-878a-bb6f0d01add1	874b7069-fafa-46ab-b6f4-b8b3781ac18d	0	9000	Suspense ??? awaiting reclassification
df9f66d3-02e0-4deb-ae2e-ebf0feba648a	3090a957-25f8-4b24-a2c4-6bc505154216	87fb5009-8839-4d72-9029-d60089264222	21440	0	BEBE LEAVE ONE WEEK DOUG
fa7c1a96-c54a-48a0-9c96-6fb86711522e	3090a957-25f8-4b24-a2c4-6bc505154216	874b7069-fafa-46ab-b6f4-b8b3781ac18d	0	21440	Suspense ??? awaiting reclassification
193fb08c-a34a-4c4a-acce-dc19e0b9cf99	060ee2e9-e3e4-4a5a-a517-472f03358b89	d1b3d196-3608-4ab9-a2f3-b0a7845c524b	7	0	BANK CHARGES
75834958-b71e-4953-8533-524a452608f4	060ee2e9-e3e4-4a5a-a517-472f03358b89	d1b3d196-3608-4ab9-a2f3-b0a7845c524b	120	0	BANK CHARGES
efdc20de-09cc-41a1-938a-6f13d60dd275	060ee2e9-e3e4-4a5a-a517-472f03358b89	874b7069-fafa-46ab-b6f4-b8b3781ac18d	0	127	Suspense ??? awaiting reclassification
1396d496-fc90-4fb6-870e-428497e9aa08	d6073f74-fbdf-401c-ba06-811e27b70b91	50fb02f6-a453-4017-a9be-ec814c86db70	5245	0	HOUSE KEEPING
989bc2ba-dd12-4999-816b-ef98b0dd60d0	d6073f74-fbdf-401c-ba06-811e27b70b91	874b7069-fafa-46ab-b6f4-b8b3781ac18d	0	5245	Suspense ??? awaiting reclassification
8ea79fac-d7f0-437e-a75b-963ebbae0022	cad757fa-1fbf-4f44-b1b8-4eed2323eace	0a0cd0b7-9663-488d-a06e-5d87d353ea93	8710	0	SWIMMING POOL CHEMICALS
f87a41c9-8320-4be8-9d06-1a049cb5588e	cad757fa-1fbf-4f44-b1b8-4eed2323eace	874b7069-fafa-46ab-b6f4-b8b3781ac18d	0	8710	Suspense ??? awaiting reclassification
a5f071e6-26a9-4a60-84ed-41e6ef420a62	d0d84e82-3b1d-4736-8314-c2146d304b1e	187fe3a6-3f3f-4f8c-a570-70ae06e907ca	37386	0	ADMIN AND ACCOUNTING
3afd1c35-5c4e-46b0-b9b6-d106faca6814	d0d84e82-3b1d-4736-8314-c2146d304b1e	874b7069-fafa-46ab-b6f4-b8b3781ac18d	0	37386	Suspense ??? awaiting reclassification
04a166bc-e82d-49e4-9e72-4f7660c5ad79	12b7484a-9f99-4ef7-99b5-52568b17bd51	f4316599-685b-4fc2-b68d-f04179abe57a	788	0	GENERAL EXPENSES
ea17f50d-b247-4fcd-aec4-464075c8d94b	12b7484a-9f99-4ef7-99b5-52568b17bd51	874b7069-fafa-46ab-b6f4-b8b3781ac18d	0	788	Suspense ??? awaiting reclassification
033f6758-4bcb-44f6-9e6e-13bd962210ff	6a995698-36ae-4f74-b00e-dc91e3a13b5f	07bb7fe0-e3a9-4ef0-bcf5-769379b58e22	5688	0	GENERAL EXPENSES
4a75e426-a2f9-4c1f-a147-aed909dde9a0	6a995698-36ae-4f74-b00e-dc91e3a13b5f	874b7069-fafa-46ab-b6f4-b8b3781ac18d	0	5688	Suspense ??? awaiting reclassification
03918bc5-716a-4a25-a6dd-fe94de32a1ac	387d60f6-d031-4ab0-b420-cc1ba73bc5a8	87fb5009-8839-4d72-9029-d60089264222	164821	0	SALARIES & WAGES
d31bdcdd-0538-4b09-8f1b-b81c6a29340b	387d60f6-d031-4ab0-b420-cc1ba73bc5a8	f2e2debb-22fa-4a16-85ab-a07383ed6aad	34870.88	0	SALARIES & WAGES
9bc1876b-2111-4261-9c6c-44fdd320b53d	387d60f6-d031-4ab0-b420-cc1ba73bc5a8	28313434-8859-4a01-9892-7d359ab212fd	58534	0	SALARIES & WAGES
34fe0b7f-c46e-4cbf-8044-55bdea3f09e0	387d60f6-d031-4ab0-b420-cc1ba73bc5a8	07bb7fe0-e3a9-4ef0-bcf5-769379b58e22	36625	0	SALARIES & WAGES
6fe938a8-6dd1-474c-9308-aae3e1277c56	d0f6d152-f45b-479c-afc9-e0323132d94d	d1b3d196-3608-4ab9-a2f3-b0a7845c524b	7	0	Office expenses
281378fb-8d56-4f8c-83cf-3a5dbb3e51da	d0f6d152-f45b-479c-afc9-e0323132d94d	d1b3d196-3608-4ab9-a2f3-b0a7845c524b	7	0	Office expenses
419fea7b-7943-4ce9-a0c5-df535d7379b9	d0f6d152-f45b-479c-afc9-e0323132d94d	d1b3d196-3608-4ab9-a2f3-b0a7845c524b	7	0	Office expenses
7723e62c-ca21-4592-a517-7aeb5e009e31	d0f6d152-f45b-479c-afc9-e0323132d94d	874b7069-fafa-46ab-b6f4-b8b3781ac18d	0	21	Suspense ??? awaiting reclassification
b99092ae-0b80-462d-92da-f010cce81132	9783cc84-01d0-474b-9ee4-2193695aecbf	d1b3d196-3608-4ab9-a2f3-b0a7845c524b	7	0	Office expenses
88292ed6-a312-44b1-920a-e89aab01f3e3	9783cc84-01d0-474b-9ee4-2193695aecbf	874b7069-fafa-46ab-b6f4-b8b3781ac18d	0	7	Suspense ??? awaiting reclassification
412fff91-b62b-443c-b8cd-ac15b49d19b5	eb6436d0-f25f-495c-acb2-de63d825b779	81e2a489-220c-4c3b-a529-e2f08c60b4be	4263	0	General Maintenance
fa4ec3d7-d7fa-4651-842e-fbc37930137f	eb6436d0-f25f-495c-acb2-de63d825b779	874b7069-fafa-46ab-b6f4-b8b3781ac18d	0	4263	Suspense ??? awaiting reclassification
106a6644-b371-4879-b811-d0752ab33bb4	dac6fcb8-6edd-41d0-a49d-d0997b2df260	187fe3a6-3f3f-4f8c-a570-70ae06e907ca	146740	0	Admin Cost
58e3c4c2-cb2f-4a13-9476-15d1c1a5f321	dac6fcb8-6edd-41d0-a49d-d0997b2df260	874b7069-fafa-46ab-b6f4-b8b3781ac18d	0	146740	Suspense ??? awaiting reclassification
4430cb33-4888-4bd7-92e8-41a9e972ee3a	77538e9d-ac57-4c74-89e6-52d33b16760b	d1b3d196-3608-4ab9-a2f3-b0a7845c524b	7	0	Office expenses
39ab89cc-3d5f-44e7-bed8-97b50070e88a	77538e9d-ac57-4c74-89e6-52d33b16760b	d1b3d196-3608-4ab9-a2f3-b0a7845c524b	120	0	Office expenses
3add4b94-8be5-492c-a0f7-abe377cc6936	77538e9d-ac57-4c74-89e6-52d33b16760b	d1b3d196-3608-4ab9-a2f3-b0a7845c524b	7	0	Office expenses
00d44426-bc18-4ce7-b460-302382155324	77538e9d-ac57-4c74-89e6-52d33b16760b	874b7069-fafa-46ab-b6f4-b8b3781ac18d	0	134	Suspense ??? awaiting reclassification
6ad53c47-227e-49ae-81b6-7af7dc3fd0a6	82e7e135-6ee3-433e-89e1-800d374532e8	f4316599-685b-4fc2-b68d-f04179abe57a	21558.6	0	MAINTENANCE
24c85174-bd3e-4079-ad48-7d4e35fa92c0	82e7e135-6ee3-433e-89e1-800d374532e8	874b7069-fafa-46ab-b6f4-b8b3781ac18d	0	21558.6	Suspense ??? awaiting reclassification
cc189cc6-4c13-4ac7-9c22-7c96a98a8e82	0973ad26-f24a-491e-9c53-b21a54481841	50fb02f6-a453-4017-a9be-ec814c86db70	755	0	HOUSE KEEPING
4f215859-70c8-46e3-95c0-01c3cc927f1f	0973ad26-f24a-491e-9c53-b21a54481841	874b7069-fafa-46ab-b6f4-b8b3781ac18d	0	755	Suspense ??? awaiting reclassification
ae5387d3-98b3-4870-8828-fb110d7d51f4	e917f46d-f352-4cb7-aa48-8badafcb6ec3	87fb5009-8839-4d72-9029-d60089264222	6762.736666666668	0	INSS
09535cb9-405d-4110-97d7-4a3e33a3e25d	e917f46d-f352-4cb7-aa48-8badafcb6ec3	f2e2debb-22fa-4a16-85ab-a07383ed6aad	1404.3733333333334	0	INSS
c901ba21-b5cf-4b4b-96bd-ab4ffbb78130	e917f46d-f352-4cb7-aa48-8badafcb6ec3	28313434-8859-4a01-9892-7d359ab212fd	2607.996666666667	0	INSS
908cffbc-f575-4ff2-854f-426e0163d08d	e917f46d-f352-4cb7-aa48-8badafcb6ec3	07bb7fe0-e3a9-4ef0-bcf5-769379b58e22	1548.9333333333332	0	INSS
8caead2d-1efc-43d2-9118-4a97522a7191	e917f46d-f352-4cb7-aa48-8badafcb6ec3	ec75b33a-b32c-47a7-ac2b-1ca610c87b0c	1725	0	INSS
141143bc-c8f2-42d5-948f-077c8a0bd2c1	e917f46d-f352-4cb7-aa48-8badafcb6ec3	d1b3d196-3608-4ab9-a2f3-b0a7845c524b	3000	0	STARLINK FOR FEB
3f9abf5d-d65b-491c-9a0c-1d60de50024c	e917f46d-f352-4cb7-aa48-8badafcb6ec3	28313434-8859-4a01-9892-7d359ab212fd	800	0	INACIO AND PEDRO CLEANING BOAT
5ce51904-06ca-4d93-adab-a86b22116753	e917f46d-f352-4cb7-aa48-8badafcb6ec3	07bb7fe0-e3a9-4ef0-bcf5-769379b58e22	1600	0	BEFORE CYCLONE INACIO, ZITO AND PEDRO
2ff362cc-aa6a-48bc-9dbf-7771e534e765	e917f46d-f352-4cb7-aa48-8badafcb6ec3	81e2a489-220c-4c3b-a529-e2f08c60b4be	10000	0	PETROL ALLOWANS JAN AND FEB
2ac75122-30cb-4ff0-a0c2-305940266d8e	e917f46d-f352-4cb7-aa48-8badafcb6ec3	87fb5009-8839-4d72-9029-d60089264222	109469.99999999999	0	ANDRISA HALF OF EXPENSES DIRE
1b0e923a-87ed-4096-9d82-61895e00fb05	e917f46d-f352-4cb7-aa48-8badafcb6ec3	6b8b2920-50ae-4223-8a0f-1cab882ee142	4.1	0	ANDRISA HALF OF EXPENSES DIRE
f0ea2d38-dc59-4bc1-a23f-bfae2f4ddd1a	e917f46d-f352-4cb7-aa48-8badafcb6ec3	28313434-8859-4a01-9892-7d359ab212fd	7762.5	0	SEAPORT CLEANING MATERIAL BOATS
044ac1a1-9069-4133-89d1-df50ace15eb8	e917f46d-f352-4cb7-aa48-8badafcb6ec3	07bb7fe0-e3a9-4ef0-bcf5-769379b58e22	15525	0	SEAPORT CLEANING MATERIAL BOATS
aa040723-d8b6-4bb9-a694-862c7a1f9976	e917f46d-f352-4cb7-aa48-8badafcb6ec3	87fb5009-8839-4d72-9029-d60089264222	35000	0	CHRIS MONTHLY FEE
967f953c-a75d-422e-a8b0-b7bf3782b9ea	e917f46d-f352-4cb7-aa48-8badafcb6ec3	6b8b2920-50ae-4223-8a0f-1cab882ee142	21000	0	FOOD FOR WORKERS
697563d5-0b52-4e9f-a0be-d11432c7fe0b	e917f46d-f352-4cb7-aa48-8badafcb6ec3	874b7069-fafa-46ab-b6f4-b8b3781ac18d	0	218210.63999999998	Suspense ??? awaiting reclassification
7d99717a-7bf1-4a48-82bc-8b5a4c42a294	c31b5328-d57c-4be6-855c-7e6cd4c22fef	50fb02f6-a453-4017-a9be-ec814c86db70	910	0	HOUSE KEEPING
0dfd21c4-5cb6-44a6-b3b4-f86f4afdcbc9	c31b5328-d57c-4be6-855c-7e6cd4c22fef	874b7069-fafa-46ab-b6f4-b8b3781ac18d	0	910	Suspense ??? awaiting reclassification
f042895b-6d26-40d9-b082-4f8958b8a67b	9497feb1-2ab0-4fb0-840d-1384e94a872c	5fe74161-6045-4c6b-95b0-b3d1a5caea04	2420	0	TAX  LICENSE
913f213f-20fc-42d1-86fc-f9663e4ce0ca	9497feb1-2ab0-4fb0-840d-1384e94a872c	874b7069-fafa-46ab-b6f4-b8b3781ac18d	0	2420	Suspense ??? awaiting reclassification
e20897cc-34bc-4b5c-86fa-885eef31f8a0	c5b911e6-be47-4eef-b087-8adae0c4ec1e	0a0cd0b7-9663-488d-a06e-5d87d353ea93	905	0	Pool Maintenance
290a81c0-8611-490b-970f-641663f0b999	c5b911e6-be47-4eef-b087-8adae0c4ec1e	0a0cd0b7-9663-488d-a06e-5d87d353ea93	1519.6	0	Pool Maintenance
199d5535-23ea-4bd0-9588-fe04702f03ce	c5b911e6-be47-4eef-b087-8adae0c4ec1e	874b7069-fafa-46ab-b6f4-b8b3781ac18d	0	2424.6	Suspense ??? awaiting reclassification
b96c89b8-ceb1-43ce-9a15-a03d27a4ab70	6db82ac8-55c7-4c02-868b-6935dcac2700	70b46831-94b4-4d9b-85d3-9ac5a24c375b	58424.49	0	Gas& Eletrisity
bc7c9a74-bff4-4e47-9d5b-5acc8e81a7f8	6db82ac8-55c7-4c02-868b-6935dcac2700	874b7069-fafa-46ab-b6f4-b8b3781ac18d	0	58424.49	Suspense ??? awaiting reclassification
a559e590-4507-45f6-920a-f73e8cbef459	b9132dd4-dc69-404f-b1af-0866519b3521	d1b3d196-3608-4ab9-a2f3-b0a7845c524b	7	0	Office expenses
5056a71a-863a-4bf2-ac9f-57f3690277c9	b9132dd4-dc69-404f-b1af-0866519b3521	d1b3d196-3608-4ab9-a2f3-b0a7845c524b	7	0	Office expenses
8ebdb5ad-468e-473d-af94-e9d2b141eb2b	b9132dd4-dc69-404f-b1af-0866519b3521	874b7069-fafa-46ab-b6f4-b8b3781ac18d	0	14	Suspense ??? awaiting reclassification
9676be63-e988-418b-88b4-db021f522874	85ba8589-cfaa-4293-a354-cd8ec0bf93eb	d1b3d196-3608-4ab9-a2f3-b0a7845c524b	7	0	Office expenses
944ce92c-a21c-4fb0-9da7-083fedd32d42	85ba8589-cfaa-4293-a354-cd8ec0bf93eb	874b7069-fafa-46ab-b6f4-b8b3781ac18d	0	7	Suspense ??? awaiting reclassification
bed94d47-3f52-4b82-8a07-211b8b42dd1a	bbdbe6a5-10b9-48e4-822d-336f9cb97c2d	ec75b33a-b32c-47a7-ac2b-1ca610c87b0c	20787.2	0	House Keping
efd88cad-f7cc-49e3-a5cf-91c876862413	bbdbe6a5-10b9-48e4-822d-336f9cb97c2d	874b7069-fafa-46ab-b6f4-b8b3781ac18d	0	20787.2	Suspense ??? awaiting reclassification
de910da1-a4fb-4ef5-8dfc-b9792806a21c	6ac3b6be-2f36-4a5e-975e-c8c11ea8ca40	87fb5009-8839-4d72-9029-d60089264222	169068.4166666667	0	SALARIES FEB
b517f4dc-73aa-4db5-b1e7-af7a85b0281e	6ac3b6be-2f36-4a5e-975e-c8c11ea8ca40	f2e2debb-22fa-4a16-85ab-a07383ed6aad	35109.333333333336	0	SALARIES FEB
738c1b51-6002-4201-9595-57e05d9bf3b3	6ac3b6be-2f36-4a5e-975e-c8c11ea8ca40	28313434-8859-4a01-9892-7d359ab212fd	65199.91666666667	0	SALARIES FEB
a61070b1-a181-439b-87ff-4d810dd16071	6ac3b6be-2f36-4a5e-975e-c8c11ea8ca40	07bb7fe0-e3a9-4ef0-bcf5-769379b58e22	38723.33333333333	0	SALARIES FEB
f715dc51-cd7d-4ad8-8be5-c95e1bf3ab7a	6ac3b6be-2f36-4a5e-975e-c8c11ea8ca40	ec75b33a-b32c-47a7-ac2b-1ca610c87b0c	43125	0	SALARIES FEB
9c6574db-4022-448c-a745-326f1dee05a6	6ac3b6be-2f36-4a5e-975e-c8c11ea8ca40	874b7069-fafa-46ab-b6f4-b8b3781ac18d	0	351226	Suspense ??? awaiting reclassification
f88c83fa-9ba9-4dde-b4bd-48832b304c80	d4ecc8e5-8576-46ad-b6ff-c0b45208d79e	f4316599-685b-4fc2-b68d-f04179abe57a	1465	0	General Maintenance
d55a4a9f-185c-4d30-bd3e-6d712e2f8f5b	d4ecc8e5-8576-46ad-b6ff-c0b45208d79e	874b7069-fafa-46ab-b6f4-b8b3781ac18d	0	1465	Suspense ??? awaiting reclassification
69c926ab-0b94-469a-a3b7-9acd2035f6c4	2b8aa542-5a94-4553-86a4-a7c91fa13798	d1b3d196-3608-4ab9-a2f3-b0a7845c524b	495	0	OFFICE & BANK CHARGES
f9aa812b-9d79-445b-9297-5372061651b4	2b8aa542-5a94-4553-86a4-a7c91fa13798	874b7069-fafa-46ab-b6f4-b8b3781ac18d	0	495	Suspense ??? awaiting reclassification
72bc8e62-dee3-4d06-9e84-e98bc35f8f1d	d0af4c12-13e7-48f4-98f8-ed5aa5ed8bb9	50fb02f6-a453-4017-a9be-ec814c86db70	570	0	HOUSE KEEPING
5ff31e9f-8101-4cb4-bd12-886a99f94124	d0af4c12-13e7-48f4-98f8-ed5aa5ed8bb9	874b7069-fafa-46ab-b6f4-b8b3781ac18d	0	570	Suspense ??? awaiting reclassification
402f6673-e357-4908-b980-5498f8376a6a	c6ef3c34-26b4-4379-a979-15bf0f48df71	5fe74161-6045-4c6b-95b0-b3d1a5caea04	1296	0	TAX RADIO LICENSE
495e6d42-ff21-43f8-9377-8198d22496fe	c6ef3c34-26b4-4379-a979-15bf0f48df71	874b7069-fafa-46ab-b6f4-b8b3781ac18d	0	1296	Suspense ??? awaiting reclassification
b952bbba-0ccc-448a-bf22-9a2727e32693	9123593a-5a0a-4e08-a00e-f7f94a5c2834	d1b3d196-3608-4ab9-a2f3-b0a7845c524b	7	0	Office expenses
7e11bc46-29ca-4d40-bf5a-1a31692c4feb	9123593a-5a0a-4e08-a00e-f7f94a5c2834	874b7069-fafa-46ab-b6f4-b8b3781ac18d	0	7	Suspense ??? awaiting reclassification
744dbfbc-55a5-4beb-bc15-ccf729c9bbfe	a0990117-2e10-4337-97ce-1bc4d4a253c3	d1b3d196-3608-4ab9-a2f3-b0a7845c524b	7	0	Office expenses
5b4ad0fb-d8fa-4726-9585-2e64930939f8	a0990117-2e10-4337-97ce-1bc4d4a253c3	874b7069-fafa-46ab-b6f4-b8b3781ac18d	0	7	Suspense ??? awaiting reclassification
04f0a10c-9855-4bb7-9384-f6dd567f7c3b	3ccb8873-50fa-4c76-b90b-3389c162170e	187fe3a6-3f3f-4f8c-a570-70ae06e907ca	37386.8	0	Accounting fee Feb
f7d15867-49e1-4ec8-845a-0bae9a107443	3ccb8873-50fa-4c76-b90b-3389c162170e	874b7069-fafa-46ab-b6f4-b8b3781ac18d	0	37386.8	Suspense ??? awaiting reclassification
11027b5c-e4fd-49f8-89b0-2c62a95511d3	a44a8505-6f69-4f3d-b3ba-c7379a2fe151	70b46831-94b4-4d9b-85d3-9ac5a24c375b	4470.61	0	Gas& Eletrisity
3b320b38-36cc-4332-adb5-13baf860972c	a44a8505-6f69-4f3d-b3ba-c7379a2fe151	874b7069-fafa-46ab-b6f4-b8b3781ac18d	0	4470.61	Suspense ??? awaiting reclassification
3a57d46b-6f0b-48e1-a792-b0f2a8657250	4a92ba63-57f8-415f-97fa-421662784440	5fe74161-6045-4c6b-95b0-b3d1a5caea04	1409.68	0	INSURANCE JET SKI AND TRAILER
af623239-0907-43c7-bad1-df6faa8db507	4a92ba63-57f8-415f-97fa-421662784440	874b7069-fafa-46ab-b6f4-b8b3781ac18d	0	1409.68	Suspense ??? awaiting reclassification
7c0d228b-d111-49f8-8ce4-835da34be110	e26b6f3a-e7f5-473b-a653-a9330df61afa	d1b3d196-3608-4ab9-a2f3-b0a7845c524b	254	0	Office expenses
b65e065e-d7e2-436e-8423-17f041920dcd	e26b6f3a-e7f5-473b-a653-a9330df61afa	874b7069-fafa-46ab-b6f4-b8b3781ac18d	0	254	Suspense ??? awaiting reclassification
9d5b3763-8888-4fa3-9f6d-d51d976210cb	88c35807-ef27-4641-91db-8f5bbf36d490	f4316599-685b-4fc2-b68d-f04179abe57a	1250	0	General Maintenance
85aa4f1f-a700-4754-a187-15993fb056b2	88c35807-ef27-4641-91db-8f5bbf36d490	874b7069-fafa-46ab-b6f4-b8b3781ac18d	0	1250	Suspense ??? awaiting reclassification
0081f1c4-c6d5-4447-a240-269250673362	e60e8788-385c-473f-b58a-1dcc9dc0f511	ec75b33a-b32c-47a7-ac2b-1ca610c87b0c	10068.8	0	HOUSE 4
c9262350-824a-45d6-bfa9-b65ff2b13a26	e60e8788-385c-473f-b58a-1dcc9dc0f511	874b7069-fafa-46ab-b6f4-b8b3781ac18d	0	10068.8	Suspense ??? awaiting reclassification
cabf4005-0ecf-4516-9c86-17622c9e3523	8b1b885c-402e-4498-bada-6e7644272a32	f2e2debb-22fa-4a16-85ab-a07383ed6aad	1030	0	HOUSE KEEPING HOUSE 1
21147ac6-b6cc-4626-9972-5effa8deb98b	8b1b885c-402e-4498-bada-6e7644272a32	874b7069-fafa-46ab-b6f4-b8b3781ac18d	0	1030	Suspense ??? awaiting reclassification
4c02d120-5de3-4ba2-a599-b49bc43daa8c	9cd81326-24e4-49dd-9b23-2f37738ba1c6	50fb02f6-a453-4017-a9be-ec814c86db70	10500	0	CELL FOR GUARDS SECURITY
e97459ba-3c67-4419-9a23-c6d08d5c6829	9cd81326-24e4-49dd-9b23-2f37738ba1c6	874b7069-fafa-46ab-b6f4-b8b3781ac18d	0	10500	Suspense ??? awaiting reclassification
cbd30ce6-f843-4263-8da4-d2c3ead91292	387d60f6-d031-4ab0-b420-cc1ba73bc5a8	ec75b33a-b32c-47a7-ac2b-1ca610c87b0c	43125	0	SALARIES & WAGES
338bc51e-7b42-4464-87d1-8aa1d7eac627	387d60f6-d031-4ab0-b420-cc1ba73bc5a8	874b7069-fafa-46ab-b6f4-b8b3781ac18d	0	337975.88	Suspense ??? awaiting reclassification
c39ba8b9-a52f-470d-ae05-e66cfb04743a	65a1e181-cd13-4ab6-9f4a-99badc3afa6e	f4316599-685b-4fc2-b68d-f04179abe57a	1440	0	GENERAL MAITENANCE
a114893d-6e6a-4a3d-a4dd-6d58ef4135b8	65a1e181-cd13-4ab6-9f4a-99badc3afa6e	874b7069-fafa-46ab-b6f4-b8b3781ac18d	0	1440	Suspense ??? awaiting reclassification
7c862363-99f8-4313-a0fc-a2bc390e4346	d2b9f3f8-ea34-4825-8ec8-3559a8ecf194	02bb5911-fe97-49bd-87dc-67e8873049f8	10300	0	LAND TAX
21ebd1b4-d8ef-4c0a-aed4-fa077198352d	d2b9f3f8-ea34-4825-8ec8-3559a8ecf194	874b7069-fafa-46ab-b6f4-b8b3781ac18d	0	10300	Suspense ??? awaiting reclassification
75ac051d-9b97-4fbb-a2cb-cfa9f0dbbe89	f1655b41-b117-4a2a-b1ff-aabaf33aaa3d	81e2a489-220c-4c3b-a529-e2f08c60b4be	5385.02	0	MOTOR VEHICLES EXPENSES
0d351c16-739a-4ec0-afb5-1cfc1ac1b044	f1655b41-b117-4a2a-b1ff-aabaf33aaa3d	874b7069-fafa-46ab-b6f4-b8b3781ac18d	0	5385.02	Suspense ??? awaiting reclassification
d259bbdf-3612-4c7a-a961-3e9886aad2d2	f856d264-214f-4fd0-9d02-86c40199bdb0	5fe74161-6045-4c6b-95b0-b3d1a5caea04	277172.71	0	INSURANCE
63d56039-ace1-4e5d-9da7-6b2982daea92	f856d264-214f-4fd0-9d02-86c40199bdb0	874b7069-fafa-46ab-b6f4-b8b3781ac18d	0	277172.71	Suspense ??? awaiting reclassification
86cfd219-a023-42bb-9833-695c86b696a8	1d69d281-e4f4-40ba-8d74-63a26b1ed986	70b46831-94b4-4d9b-85d3-9ac5a24c375b	3800.61	0	GAS & ELECTRISITY
7a13015b-f4d1-4d0c-97c8-dff57baee3e9	1d69d281-e4f4-40ba-8d74-63a26b1ed986	874b7069-fafa-46ab-b6f4-b8b3781ac18d	0	3800.61	Suspense ??? awaiting reclassification
92d53c9b-246e-4881-8db4-cea03aab7499	2f5e4be7-3504-4e0b-ac21-27c42a0419ec	f4316599-685b-4fc2-b68d-f04179abe57a	1160	0	GENERAL MAINTRENANCE
94b70f89-b9b9-4ff6-92ec-ef72361d6d08	2f5e4be7-3504-4e0b-ac21-27c42a0419ec	874b7069-fafa-46ab-b6f4-b8b3781ac18d	0	1160	Suspense ??? awaiting reclassification
13e814b1-da92-4240-a899-5950fa980e9d	766b41b6-beea-4245-825f-6405f709d467	87fb5009-8839-4d72-9029-d60089264222	6592.84	0	SALARIES & WAGES
512fe4a2-160d-4bb1-864e-5dcac5e4a7ac	766b41b6-beea-4245-825f-6405f709d467	f2e2debb-22fa-4a16-85ab-a07383ed6aad	1394.8352	0	SALARIES & WAGES
16f7dd08-747a-415c-af86-5564aeddfc95	766b41b6-beea-4245-825f-6405f709d467	28313434-8859-4a01-9892-7d359ab212fd	2341.36	0	SALARIES & WAGES
95c4f735-fdbd-465e-ae6e-1a7dd30d886e	766b41b6-beea-4245-825f-6405f709d467	07bb7fe0-e3a9-4ef0-bcf5-769379b58e22	1465	0	SALARIES & WAGES
0e47a45f-ba8a-49c5-9bda-2bf63c8b6e34	766b41b6-beea-4245-825f-6405f709d467	ec75b33a-b32c-47a7-ac2b-1ca610c87b0c	1725	0	SALARIES & WAGES
60129728-01df-4ff8-ba24-524379f081b6	766b41b6-beea-4245-825f-6405f709d467	874b7069-fafa-46ab-b6f4-b8b3781ac18d	0	13519.0352	Suspense ??? awaiting reclassification
c2e8c955-a689-4d04-b99b-4ad048a6e359	42d826ae-c937-4ce5-94a8-83e4d2a01290	5fe74161-6045-4c6b-95b0-b3d1a5caea04	30417.98	0	INSURANCE
0ed1889d-185b-4509-887c-7f52bf1aa589	42d826ae-c937-4ce5-94a8-83e4d2a01290	874b7069-fafa-46ab-b6f4-b8b3781ac18d	0	30417.98	Suspense ??? awaiting reclassification
750dbf4b-3b43-442c-a07d-1f5c229b1535	ffd70777-be09-418c-9519-11635d62f689	d1b3d196-3608-4ab9-a2f3-b0a7845c524b	3000	0	STARLINK FOR FEB
b1828ad0-cb42-4a59-9672-bc5f71d1b377	ffd70777-be09-418c-9519-11635d62f689	6b8b2920-50ae-4223-8a0f-1cab882ee142	500	0	COLLECT BUDGIE AT AIRPORT 25 FEB
428f9164-e3a2-4cf3-9fed-cf31d731f087	ffd70777-be09-418c-9519-11635d62f689	50fb02f6-a453-4017-a9be-ec814c86db70	2000	0	PETTY CASH
76e775bb-d6f2-4efe-9dc9-6fd5fb166c4b	ffd70777-be09-418c-9519-11635d62f689	28313434-8859-4a01-9892-7d359ab212fd	1500	0	PETTY CASH
9c02c480-0f25-4982-9306-5c637787210a	ffd70777-be09-418c-9519-11635d62f689	07bb7fe0-e3a9-4ef0-bcf5-769379b58e22	1500	0	PETTY CASH
c2b62f0d-73c0-4f4c-a5c7-c8811e42ad65	ffd70777-be09-418c-9519-11635d62f689	50fb02f6-a453-4017-a9be-ec814c86db70	720	0	HANDY ANDY, SUNLIGHT DOVE SOAP GUEST
cc0f1119-6310-4f40-b839-248860c92ed8	ffd70777-be09-418c-9519-11635d62f689	07bb7fe0-e3a9-4ef0-bcf5-769379b58e22	5000	0	FIX INTERNET OF CASA CAJU
d80e1dc8-c244-4d95-b682-5efb3e89f66f	ffd70777-be09-418c-9519-11635d62f689	50fb02f6-a453-4017-a9be-ec814c86db70	2500	0	Geraldo rubish Landco
425d2132-00b1-4d6e-ae08-af2bf87c5f37	ffd70777-be09-418c-9519-11635d62f689	02bb5911-fe97-49bd-87dc-67e8873049f8	6000	0	2 X ROAD CERTIFICATES @ 3000 EACH
605bc209-892b-465d-9ddc-62c563aa6258	ffd70777-be09-418c-9519-11635d62f689	07bb7fe0-e3a9-4ef0-bcf5-769379b58e22	3000	0	2 X ROAD CERTIFICATES @ 3000 EACH
5edaea68-b86e-4b31-a1bc-876d0a6b72f5	ffd70777-be09-418c-9519-11635d62f689	ec75b33a-b32c-47a7-ac2b-1ca610c87b0c	3000	0	2 X ROAD CERTIFICATES @ 3000 EACH
8e31329f-a9be-472f-a991-ed1b1e4b8a36	ffd70777-be09-418c-9519-11635d62f689	6b8b2920-50ae-4223-8a0f-1cab882ee142	21000	0	FOOD WORKERS
f0f8d479-86ab-4dc0-afa5-1147e234d8f3	ffd70777-be09-418c-9519-11635d62f689	6b8b2920-50ae-4223-8a0f-1cab882ee142	1800	0	CASUALS GARDEN ABLUTION PLUS PLANTS
d405b5d2-6e0c-4dc5-9e7e-dddfb1fee03c	ffd70777-be09-418c-9519-11635d62f689	f4316599-685b-4fc2-b68d-f04179abe57a	1200	0	PAVERS ABLUTION BLOCK
a0fdc652-435e-4313-b611-42fcb8049f9f	ffd70777-be09-418c-9519-11635d62f689	28313434-8859-4a01-9892-7d359ab212fd	3600	0	INSPECTION FEE MARINTINE BOATS
e29a4020-6750-43b0-9034-69e8c14c2e3a	ffd70777-be09-418c-9519-11635d62f689	07bb7fe0-e3a9-4ef0-bcf5-769379b58e22	3600	0	INSPECTION FEE MARINTINE BOATS
d6c2efad-c5b5-4b75-9037-effb03f99f0b	ffd70777-be09-418c-9519-11635d62f689	81e2a489-220c-4c3b-a529-e2f08c60b4be	5000	0	PETROL ALLOWANCE
371dad41-01e9-4a0c-87c9-493b10684125	ffd70777-be09-418c-9519-11635d62f689	87fb5009-8839-4d72-9029-d60089264222	35000	0	SALARY MARCH
1b566c13-2c23-4935-a8d6-2fa766d9db8a	ffd70777-be09-418c-9519-11635d62f689	874b7069-fafa-46ab-b6f4-b8b3781ac18d	0	99920	Suspense ??? awaiting reclassification
7d0726f9-88aa-41d0-ba32-14baca82e8b3	d0049a70-ab5d-4f3e-a36b-72902dceb611	c31a0335-c51a-4e4e-a6a0-031f0ab068c0	594297	0	Invoice receivable FT 2026/001
a4e917ca-56b9-42e5-8b53-40bd18ae5c66	d0049a70-ab5d-4f3e-a36b-72902dceb611	1222da46-5238-4e7f-a4a6-ceef448e178a	0	512325	Accommodation - ALEX
b5a5f012-e12e-469a-ab6a-5633bba30d55	d0049a70-ab5d-4f3e-a36b-72902dceb611	fbce077f-9236-4c37-8a27-aa02fa20fa16	0	81972	VAT 16%
200492b5-db40-40b7-bf17-0a10c1f5bdf4	47a8c121-81a6-4392-bdc8-efa8a8e8431a	c31a0335-c51a-4e4e-a6a0-031f0ab068c0	958350	0	Invoice receivable FT 2026/002
18f174fe-48af-4631-9241-fb2617cd4d2b	47a8c121-81a6-4392-bdc8-efa8a8e8431a	1222da46-5238-4e7f-a4a6-ceef448e178a	0	826163.79	Accommodation - ALEX
b839be27-7899-4068-8d8e-f9efe684e118	47a8c121-81a6-4392-bdc8-efa8a8e8431a	fbce077f-9236-4c37-8a27-aa02fa20fa16	0	132186.21	VAT 16%
6c8e4b52-e1ef-4b17-ba8e-fc30ad734c99	c3ed77e5-c385-4752-9e87-d7874f646b1b	c31a0335-c51a-4e4e-a6a0-031f0ab068c0	751171	0	Invoice receivable FT 2026/003
71e55396-f06f-4f2b-a7f3-55bb908edb2f	c3ed77e5-c385-4752-9e87-d7874f646b1b	1222da46-5238-4e7f-a4a6-ceef448e178a	0	647561.21	Accommodation - ALEX
cf3d8ca3-cc70-4289-8b58-6126f09913c1	c3ed77e5-c385-4752-9e87-d7874f646b1b	fbce077f-9236-4c37-8a27-aa02fa20fa16	0	103609.79	VAT 16%
c8792a2b-c30b-4e07-9016-d2d3cc2995bd	399f9d9a-6f51-45f0-ac5f-aca9c3a593bc	c31a0335-c51a-4e4e-a6a0-031f0ab068c0	948750	0	Invoice receivable FT 2026/004
306162c6-b4f4-4d34-9752-cfe45f1c095d	399f9d9a-6f51-45f0-ac5f-aca9c3a593bc	1222da46-5238-4e7f-a4a6-ceef448e178a	0	817887.93	Accommodation - WARREN STEAD DEP BANK
889ce212-ed64-43a4-9e6b-7c2acaa4da34	399f9d9a-6f51-45f0-ac5f-aca9c3a593bc	fbce077f-9236-4c37-8a27-aa02fa20fa16	0	130862.07	VAT 16%
13d45678-1a94-485b-8e08-0b4eaf22afaf	0d348fd1-a4f7-4258-aa0e-97c1d65cedc0	c31a0335-c51a-4e4e-a6a0-031f0ab068c0	941920	0	Invoice receivable FT 2026/005
1333c091-18cb-4eaa-940a-40a383bb790d	0d348fd1-a4f7-4258-aa0e-97c1d65cedc0	1222da46-5238-4e7f-a4a6-ceef448e178a	0	812000	Accommodation - WARREN STEAD
2fac3948-49c2-4b0d-8515-8b906ae9596d	0d348fd1-a4f7-4258-aa0e-97c1d65cedc0	fbce077f-9236-4c37-8a27-aa02fa20fa16	0	129920	VAT 16%
a4255a64-d548-4f5d-8f75-ee9a5678392e	2795d965-504b-418a-9273-faad8e274d4a	c31a0335-c51a-4e4e-a6a0-031f0ab068c0	68000	0	Invoice receivable FT 2026/006
3364fc4f-4924-47d8-9f93-f4b2e7b5ace8	2795d965-504b-418a-9273-faad8e274d4a	1222da46-5238-4e7f-a4a6-ceef448e178a	0	58620.69	Accommodation - CREDIT IVA H1 - LESLEY X 6 NIGHTS
c6ab2494-76cb-4fc7-8e49-4f7fb7671e25	2795d965-504b-418a-9273-faad8e274d4a	fbce077f-9236-4c37-8a27-aa02fa20fa16	0	9379.31	VAT 16%
6145d69a-fcc3-4168-8343-1009d460d2dd	01a5e615-ac14-4ec5-b24d-cd23054e4430	c31a0335-c51a-4e4e-a6a0-031f0ab068c0	638900	0	Invoice receivable FT 2026/007
017c239d-dfa9-46c1-b04f-b1961792e529	01a5e615-ac14-4ec5-b24d-cd23054e4430	1222da46-5238-4e7f-a4a6-ceef448e178a	0	550775.86	Accommodation - ALEX
26fc6940-edde-47d5-b442-12bab5c971f4	01a5e615-ac14-4ec5-b24d-cd23054e4430	fbce077f-9236-4c37-8a27-aa02fa20fa16	0	88124.14	VAT 16%
f2f5bc45-2475-4333-886e-a2cedfa3703f	875ececf-e730-434f-951a-a6eb2ac9cbe9	c31a0335-c51a-4e4e-a6a0-031f0ab068c0	55200	0	Invoice receivable FT 2026/008
6b067f6e-1cf8-4e1e-ac03-f1613db5ae7a	875ececf-e730-434f-951a-a6eb2ac9cbe9	1222da46-5238-4e7f-a4a6-ceef448e178a	0	47586.21	Accommodation - BRENDON
e1bb730a-676c-46ae-a1f4-35d1f3e0fe95	875ececf-e730-434f-951a-a6eb2ac9cbe9	fbce077f-9236-4c37-8a27-aa02fa20fa16	0	7613.79	VAT 16%
83d49ebc-23ce-46b3-bfac-123b0fa2eeca	b6539d2b-f989-45cb-a1e7-4b55fffbe86a	c31a0335-c51a-4e4e-a6a0-031f0ab068c0	812375	0	Invoice receivable FT 2026/009
599cf838-017d-471b-8121-68d0d7369ac3	b6539d2b-f989-45cb-a1e7-4b55fffbe86a	1222da46-5238-4e7f-a4a6-ceef448e178a	0	700323.28	Accommodation - TAFY
06808dd7-91a6-47fe-8ba1-91a8b4293109	b6539d2b-f989-45cb-a1e7-4b55fffbe86a	fbce077f-9236-4c37-8a27-aa02fa20fa16	0	112051.72	VAT 16%
c7efc090-4d9e-459d-a678-327c6fa20cc0	aed6d853-a889-4cf7-80db-ddc5a61dae07	c31a0335-c51a-4e4e-a6a0-031f0ab068c0	465650	0	Invoice receivable FT 2026/010
dafbfaca-c91e-4a52-aa9f-56b07ac346be	aed6d853-a889-4cf7-80db-ddc5a61dae07	1222da46-5238-4e7f-a4a6-ceef448e178a	0	401422.41	Accommodation - TAFY RECEIVED FROM ROBIN
848bec63-9fe2-4ae3-acdd-544e4f8bced7	aed6d853-a889-4cf7-80db-ddc5a61dae07	fbce077f-9236-4c37-8a27-aa02fa20fa16	0	64227.59	VAT 16%
9427457d-ff80-447e-a92c-2400ac329bd9	a61a796e-0f7e-4d46-b3b8-8f55d0c10bcd	c31a0335-c51a-4e4e-a6a0-031f0ab068c0	958350	0	Invoice receivable FT 2026/011
60bf363f-717b-45d3-bc78-a92ef2295c36	a61a796e-0f7e-4d46-b3b8-8f55d0c10bcd	1222da46-5238-4e7f-a4a6-ceef448e178a	0	826163.79	Accommodation - WARREN STEAD
c0e45955-ac2f-469f-9eeb-40a8e626ba0d	a61a796e-0f7e-4d46-b3b8-8f55d0c10bcd	fbce077f-9236-4c37-8a27-aa02fa20fa16	0	132186.21	VAT 16%
1f1d54a8-b645-49cd-9b9a-f1bad3064039	c1276af4-69fc-4788-beb2-2b1f76b2aedd	c31a0335-c51a-4e4e-a6a0-031f0ab068c0	37520	0	Invoice receivable FT 2026/012
9467b138-0997-4af9-bfbe-0c65a0110a2f	c1276af4-69fc-4788-beb2-2b1f76b2aedd	1222da46-5238-4e7f-a4a6-ceef448e178a	0	32344.83	Accommodation - BRENDON 7 DAYS @80
bed40ffb-2393-485c-987b-6550cd6e6c2e	c1276af4-69fc-4788-beb2-2b1f76b2aedd	fbce077f-9236-4c37-8a27-aa02fa20fa16	0	5175.17	VAT 16%
ba01f4b1-c517-480b-996d-0eba69fddc79	59cb3ec9-4125-41b2-81bd-eb4d43294a48	c31a0335-c51a-4e4e-a6a0-031f0ab068c0	335000	0	Invoice receivable FT 2026/013
ec7fe771-04f3-43e3-b444-43446ab62ef3	59cb3ec9-4125-41b2-81bd-eb4d43294a48	1222da46-5238-4e7f-a4a6-ceef448e178a	0	288793.1	Accommodation - TAFY RECEIVED FROM ALEX
ffd5c591-b3c5-4297-9ffb-2964ce51fb8f	59cb3ec9-4125-41b2-81bd-eb4d43294a48	fbce077f-9236-4c37-8a27-aa02fa20fa16	0	46206.9	VAT 16%
4d934d5b-8c3d-4e5b-8fc9-0ad148ea7682	805513af-ac06-4c94-9a4c-1ecfa3d18efa	c31a0335-c51a-4e4e-a6a0-031f0ab068c0	98490	0	Invoice receivable FT 2026/014
71fd271d-a57d-4467-9093-00b02dbf4f72	805513af-ac06-4c94-9a4c-1ecfa3d18efa	1222da46-5238-4e7f-a4a6-ceef448e178a	0	84905.17	Accommodation - ARON ACCOMMODATION IN H4
383d2d59-b67c-4d18-9dca-1f622fc9b9ae	805513af-ac06-4c94-9a4c-1ecfa3d18efa	fbce077f-9236-4c37-8a27-aa02fa20fa16	0	13584.83	VAT 16%
83a3f76d-9d2d-4cae-b28c-e46556c74c94	cb7106c2-327d-4802-9972-afe97b18cfed	c31a0335-c51a-4e4e-a6a0-031f0ab068c0	948750	0	Invoice receivable FT 2026/015
9eae90e4-4be0-40a6-857d-736e5ac9e6d2	cb7106c2-327d-4802-9972-afe97b18cfed	1222da46-5238-4e7f-a4a6-ceef448e178a	0	817887.93	Accommodation - ALEX
470262fb-af84-4d4c-a00d-bc52fbf343cb	cb7106c2-327d-4802-9972-afe97b18cfed	fbce077f-9236-4c37-8a27-aa02fa20fa16	0	130862.07	VAT 16%
e6b9319a-ce75-4460-aa6a-cfae314501b9	e17bb3a0-f9db-42b2-bebe-d42437a6c077	c31a0335-c51a-4e4e-a6a0-031f0ab068c0	22400	0	Invoice receivable FT 2026/016
ba3576e0-859e-4131-94e3-a03afb170e77	e17bb3a0-f9db-42b2-bebe-d42437a6c077	1222da46-5238-4e7f-a4a6-ceef448e178a	0	19310.34	Accommodation - BRENDON
343b84bc-745a-43be-8aa0-1bc65f71bc24	e17bb3a0-f9db-42b2-bebe-d42437a6c077	fbce077f-9236-4c37-8a27-aa02fa20fa16	0	3089.66	VAT 16%
4ed187f5-72a1-43d7-ab88-773fb3706ac0	ee6564f1-0260-45a2-a3c7-1b143b634770	c31a0335-c51a-4e4e-a6a0-031f0ab068c0	948750	0	Invoice receivable FT 2026/017
f05b04a1-e982-46ef-8d15-ef6d50324226	ee6564f1-0260-45a2-a3c7-1b143b634770	1222da46-5238-4e7f-a4a6-ceef448e178a	0	817887.93	Accommodation - WARREN COHEN INVESTMENT
002cbc44-6579-4a6d-90fd-3d8f934d76a3	ee6564f1-0260-45a2-a3c7-1b143b634770	fbce077f-9236-4c37-8a27-aa02fa20fa16	0	130862.07	VAT 16%
970cf05c-e8b1-4153-ad4b-867223cdb8bb	d6af991f-69c5-445d-a129-560295d4317c	c31a0335-c51a-4e4e-a6a0-031f0ab068c0	958350	0	Invoice receivable FT 2026/018
e97bbe0c-eea5-4b3d-b874-28bd8a0c73ba	d6af991f-69c5-445d-a129-560295d4317c	1222da46-5238-4e7f-a4a6-ceef448e178a	0	826163.79	Accommodation - WARREN STEAD
9570668b-ff29-44e2-b80d-3158c408ec25	d6af991f-69c5-445d-a129-560295d4317c	fbce077f-9236-4c37-8a27-aa02fa20fa16	0	132186.21	VAT 16%
240096fc-77c2-4358-8173-43ac80e21476	0eb252c8-5395-43c5-a2d4-90d9b414de6e	c31a0335-c51a-4e4e-a6a0-031f0ab068c0	60720	0	Invoice receivable FT 2026/019
f6ccc3a9-77ea-4f50-a57e-b854192a6ec4	0eb252c8-5395-43c5-a2d4-90d9b414de6e	1222da46-5238-4e7f-a4a6-ceef448e178a	0	52344.83	Accommodation - ALAIN WARREN
7adde42c-684e-4fa2-8fe3-3330acde3aca	0eb252c8-5395-43c5-a2d4-90d9b414de6e	fbce077f-9236-4c37-8a27-aa02fa20fa16	0	8375.17	VAT 16%
6e9f0438-703d-4fe8-8d6a-76f998f16173	9e9f74bc-088f-4d3a-9845-c936f9f3c649	c31a0335-c51a-4e4e-a6a0-031f0ab068c0	222300	0	Invoice receivable FT 2026/020
ee4a8172-a171-4f8d-bc9a-1fdb5af3e408	9e9f74bc-088f-4d3a-9845-c936f9f3c649	1222da46-5238-4e7f-a4a6-ceef448e178a	0	191637.93	Accommodation - ALEX TRANSFER TO MONIQUE
43b407ae-c1a5-440d-92f0-36b1884582f4	9e9f74bc-088f-4d3a-9845-c936f9f3c649	fbce077f-9236-4c37-8a27-aa02fa20fa16	0	30662.07	VAT 16%
4187c9ed-5a12-4f01-a343-572c980ae2d6	a46a684b-3b58-4e16-a898-3061240eacd2	c31a0335-c51a-4e4e-a6a0-031f0ab068c0	310000	0	Invoice receivable FT 2026/021
a5bb605a-4402-439c-ae41-5d58fdcae75e	a46a684b-3b58-4e16-a898-3061240eacd2	1222da46-5238-4e7f-a4a6-ceef448e178a	0	267241.38	Accommodation - TAFY RECEIVED FROM AANGIE
ed0e4d29-bdfd-4764-aca1-82df489eb59e	a46a684b-3b58-4e16-a898-3061240eacd2	fbce077f-9236-4c37-8a27-aa02fa20fa16	0	42758.62	VAT 16%
d91f7320-3c61-4dc0-bf01-d6272b830654	14e2b201-5949-4704-bd53-791a49ab0162	c31a0335-c51a-4e4e-a6a0-031f0ab068c0	293480	0	Invoice receivable FT 2026/022
402a3378-47a7-4304-81b4-1eda0b40daf9	14e2b201-5949-4704-bd53-791a49ab0162	1222da46-5238-4e7f-a4a6-ceef448e178a	0	253000	Accommodation - ALEX
9eef9c2f-53dd-4fa4-8982-eb8f4aa5e853	14e2b201-5949-4704-bd53-791a49ab0162	fbce077f-9236-4c37-8a27-aa02fa20fa16	0	40480	VAT 16%
6018688c-c628-4872-b75e-f247a049c8e1	cd26d10b-3b86-4cf6-a0df-9c64b8c40aa1	c31a0335-c51a-4e4e-a6a0-031f0ab068c0	948750	0	Invoice receivable FT 2026/023
9635e935-b65e-40f9-9bb5-b34cd56c6762	cd26d10b-3b86-4cf6-a0df-9c64b8c40aa1	1222da46-5238-4e7f-a4a6-ceef448e178a	0	817887.93	Accommodation - WARREN COHEN INVESTMENT
58738f08-750e-43f2-92a1-224816040949	cd26d10b-3b86-4cf6-a0df-9c64b8c40aa1	fbce077f-9236-4c37-8a27-aa02fa20fa16	0	130862.07	VAT 16%
e0b6abc0-bddb-4b59-bc67-6c0c845f5334	e542f423-107d-46b5-97c8-1c5ae2f29c0e	c31a0335-c51a-4e4e-a6a0-031f0ab068c0	458172	0	Invoice receivable FT 2026/024
4d426412-fb78-49d6-b902-479832be0701	e542f423-107d-46b5-97c8-1c5ae2f29c0e	1222da46-5238-4e7f-a4a6-ceef448e178a	0	394975.86	Accommodation - WARREN PAY TRACY SALARY AND RECRUITMENT
36852c64-2925-41d1-a9f8-1a94adfdc871	e542f423-107d-46b5-97c8-1c5ae2f29c0e	fbce077f-9236-4c37-8a27-aa02fa20fa16	0	63196.14	VAT 16%
1717f107-e2a2-46c6-af8b-db74a140a88a	26b816ca-351b-4a11-af7b-a7157b77dcd9	c31a0335-c51a-4e4e-a6a0-031f0ab068c0	40200	0	Invoice receivable FT 2026/025
5d32248e-51c9-4137-8d98-21a6504e2753	26b816ca-351b-4a11-af7b-a7157b77dcd9	1222da46-5238-4e7f-a4a6-ceef448e178a	0	34655.17	Accommodation - CREDIT IVA H3 - KEITH & SUE X 8 NIGHTS @ 75
fde54b74-46ac-451e-ae3f-c395e9c528d6	26b816ca-351b-4a11-af7b-a7157b77dcd9	fbce077f-9236-4c37-8a27-aa02fa20fa16	0	5544.83	VAT 16%
8d1e8692-2786-47ac-822a-358e6a895f8c	03ec732b-2cd8-4f8c-a74a-e22860fce4c2	c31a0335-c51a-4e4e-a6a0-031f0ab068c0	119000	0	Invoice receivable FT 2026/026
32b815f9-83d2-416a-8114-3f04bd29ae55	03ec732b-2cd8-4f8c-a74a-e22860fce4c2	1222da46-5238-4e7f-a4a6-ceef448e178a	0	102586.21	Accommodation - WARREN
b14c7165-2e81-4f12-ade4-46d1a566afc0	03ec732b-2cd8-4f8c-a74a-e22860fce4c2	fbce077f-9236-4c37-8a27-aa02fa20fa16	0	16413.79	VAT 16%
a8def229-f1b6-42ec-bcbf-685a8ea17db0	da4944ec-9ec9-42fe-9b87-85aaecaa5d04	c31a0335-c51a-4e4e-a6a0-031f0ab068c0	132000	0	Invoice receivable FT 2026/027
2540f8ad-6081-458c-8036-49d95803b689	da4944ec-9ec9-42fe-9b87-85aaecaa5d04	1222da46-5238-4e7f-a4a6-ceef448e178a	0	113793.1	Accommodation - ALEX
48a24e9e-6ccc-4c17-8bc7-b1b9f82754e0	da4944ec-9ec9-42fe-9b87-85aaecaa5d04	fbce077f-9236-4c37-8a27-aa02fa20fa16	0	18206.9	VAT 16%
b1d2c845-f058-4204-ab80-a271f1334338	afaeed91-7caf-4e0c-a094-79a3193fb669	c31a0335-c51a-4e4e-a6a0-031f0ab068c0	551000	0	Invoice receivable FT 2026/028
a13c0cdf-41d0-42ad-9cfd-0441b054dc09	afaeed91-7caf-4e0c-a094-79a3193fb669	1222da46-5238-4e7f-a4a6-ceef448e178a	0	475000	Accommodation - TAFY
01996763-292e-4bd6-bee8-5299c6ddd839	afaeed91-7caf-4e0c-a094-79a3193fb669	fbce077f-9236-4c37-8a27-aa02fa20fa16	0	76000	VAT 16%
23072c38-d150-43e0-816d-bb4099ca8726	fa134df7-0fff-43c5-8ffc-195c01bdf6a0	c31a0335-c51a-4e4e-a6a0-031f0ab068c0	958350	0	Invoice receivable FT 2026/029
e4cf34a3-6e30-443e-bf9d-b902cab1a754	fa134df7-0fff-43c5-8ffc-195c01bdf6a0	1222da46-5238-4e7f-a4a6-ceef448e178a	0	826163.79	Accommodation - WARREN STEAD
4d46ea65-f1f7-4902-9fea-901610f6dc99	fa134df7-0fff-43c5-8ffc-195c01bdf6a0	fbce077f-9236-4c37-8a27-aa02fa20fa16	0	132186.21	VAT 16%
fde0098d-2c19-4f06-a6bf-954345e00d13	bc55651d-20d3-4d01-aec8-5d8104fc0e5b	c31a0335-c51a-4e4e-a6a0-031f0ab068c0	207000	0	Invoice receivable FT 2026/030
bd97d40a-3e4e-477d-ad39-35081390ef9a	bc55651d-20d3-4d01-aec8-5d8104fc0e5b	1222da46-5238-4e7f-a4a6-ceef448e178a	0	178448.28	Accommodation - TAFY RE ROBIN
82bdbe76-73cf-40b8-8340-bcfbee40c4a8	bc55651d-20d3-4d01-aec8-5d8104fc0e5b	fbce077f-9236-4c37-8a27-aa02fa20fa16	0	28551.72	VAT 16%
f52854e3-b6df-4bca-873e-f5524684786f	b9a4b698-c5db-45ec-a240-0ca761ef676a	c31a0335-c51a-4e4e-a6a0-031f0ab068c0	569250	0	Invoice receivable FT 2026/031
cbc63a4b-09af-4e44-a700-5aa45322da20	b9a4b698-c5db-45ec-a240-0ca761ef676a	1222da46-5238-4e7f-a4a6-ceef448e178a	0	490732.76	Accommodation - WARREN INVESTMENT DOLLAR ACCOUNT
3baa299d-d3eb-4122-ad70-df00f5be6db8	b9a4b698-c5db-45ec-a240-0ca761ef676a	fbce077f-9236-4c37-8a27-aa02fa20fa16	0	78517.24	VAT 16%
654f6969-37c8-4a2a-8e06-5bffc883d308	687ae46e-4716-4153-85f6-6b79d201cb7a	c31a0335-c51a-4e4e-a6a0-031f0ab068c0	420000	0	Invoice receivable FT 2026/032
bd5c59c7-5d29-46a4-8472-c618bcc4b08e	687ae46e-4716-4153-85f6-6b79d201cb7a	1222da46-5238-4e7f-a4a6-ceef448e178a	0	362068.97	Accommodation - KEIVIN PAY TO BANK
6cacc1cd-eedb-498e-9820-36bca8b33bb8	687ae46e-4716-4153-85f6-6b79d201cb7a	fbce077f-9236-4c37-8a27-aa02fa20fa16	0	57931.03	VAT 16%
bd291317-e38f-40ce-9afc-c8cea2495ffd	4dfe9a53-1ccd-4013-bda2-5c1055bfd280	c31a0335-c51a-4e4e-a6a0-031f0ab068c0	594297	0	Invoice receivable FT 2026/033
e6eab5df-f18d-4acb-b534-e31e359e9a3b	4dfe9a53-1ccd-4013-bda2-5c1055bfd280	1222da46-5238-4e7f-a4a6-ceef448e178a	0	512325	Accommodation - ALEX
68dce6a9-86e6-4160-b5e7-1236f56a8130	4dfe9a53-1ccd-4013-bda2-5c1055bfd280	fbce077f-9236-4c37-8a27-aa02fa20fa16	0	81972	VAT 16%
3988f61e-3897-419b-8065-b292d74fbebf	90d0dc0f-19f9-4d08-bdf2-e16544dd6120	c31a0335-c51a-4e4e-a6a0-031f0ab068c0	958350	0	Invoice receivable FT 2026/034
ed09a4bc-e1ae-4240-9dae-b15d44e2d511	90d0dc0f-19f9-4d08-bdf2-e16544dd6120	1222da46-5238-4e7f-a4a6-ceef448e178a	0	826163.79	Accommodation - ALEX
85fb4868-aa00-41cb-a710-a5674e6d5d64	90d0dc0f-19f9-4d08-bdf2-e16544dd6120	fbce077f-9236-4c37-8a27-aa02fa20fa16	0	132186.21	VAT 16%
57d6228d-9268-4cca-b7f6-66d2d0237f3c	9acea114-3cbd-434e-bcee-2b62e6a7216b	c31a0335-c51a-4e4e-a6a0-031f0ab068c0	751171	0	Invoice receivable FT 2026/035
ae575953-cabe-4a0f-95d2-80b5b36072ab	9acea114-3cbd-434e-bcee-2b62e6a7216b	1222da46-5238-4e7f-a4a6-ceef448e178a	0	647561.21	Accommodation - ALEX
685a2f7c-404a-4aa5-813d-2619b4c0241f	9acea114-3cbd-434e-bcee-2b62e6a7216b	fbce077f-9236-4c37-8a27-aa02fa20fa16	0	103609.79	VAT 16%
16d25bbb-444b-401b-825a-1be8883e0346	6e94b6a6-091f-425c-b6b8-e53a2de972ff	c31a0335-c51a-4e4e-a6a0-031f0ab068c0	948750	0	Invoice receivable FT 2026/036
dc420f4a-96cc-45a0-8862-185047d931ff	6e94b6a6-091f-425c-b6b8-e53a2de972ff	1222da46-5238-4e7f-a4a6-ceef448e178a	0	817887.93	Accommodation - WARREN STEAD DEP BANK
e9bdf0eb-270d-4d4e-bfb8-2a81e3869a19	6e94b6a6-091f-425c-b6b8-e53a2de972ff	fbce077f-9236-4c37-8a27-aa02fa20fa16	0	130862.07	VAT 16%
724b446d-57b1-4bdb-b4dd-7388213d5611	1f898a27-907b-4a8a-84e3-cfa3dc671c94	c31a0335-c51a-4e4e-a6a0-031f0ab068c0	941920	0	Invoice receivable FT 2026/037
4e04015d-81f6-4667-8bec-ce2ef239e9fb	1f898a27-907b-4a8a-84e3-cfa3dc671c94	1222da46-5238-4e7f-a4a6-ceef448e178a	0	812000	Accommodation - WARREN STEAD
3b9d60b6-7fe2-45f6-84f2-b152cf9bd5e1	1f898a27-907b-4a8a-84e3-cfa3dc671c94	fbce077f-9236-4c37-8a27-aa02fa20fa16	0	129920	VAT 16%
e2652b19-8fe3-4c6c-b2a2-42729e9f8c86	c348fb39-02c9-444f-96d7-785677486d78	c31a0335-c51a-4e4e-a6a0-031f0ab068c0	68000	0	Invoice receivable FT 2026/038
fe0d1d4c-ed86-4d3e-8de0-6fbd6de6bbc9	c348fb39-02c9-444f-96d7-785677486d78	1222da46-5238-4e7f-a4a6-ceef448e178a	0	58620.69	Accommodation - CREDIT IVA H1 - LESLEY X 6 NIGHTS
8807f1d5-4875-404e-ae5b-b7921f7c949b	c348fb39-02c9-444f-96d7-785677486d78	fbce077f-9236-4c37-8a27-aa02fa20fa16	0	9379.31	VAT 16%
9ff85955-dff7-4182-9949-73bdcf74274d	092ff6aa-01c0-424a-8321-525c41c65e2c	c31a0335-c51a-4e4e-a6a0-031f0ab068c0	638900	0	Invoice receivable FT 2026/039
00d3c950-5235-4fea-86a8-7b514525a37a	092ff6aa-01c0-424a-8321-525c41c65e2c	1222da46-5238-4e7f-a4a6-ceef448e178a	0	550775.86	Accommodation - ALEX
49453aa4-bdb8-4469-b5f5-5269f6389115	092ff6aa-01c0-424a-8321-525c41c65e2c	fbce077f-9236-4c37-8a27-aa02fa20fa16	0	88124.14	VAT 16%
77462971-d413-48ba-973a-5e63faf71263	4a8c0b31-ceb5-4c61-b19b-3af5a5f20b4d	c31a0335-c51a-4e4e-a6a0-031f0ab068c0	37520	0	Invoice receivable FT 2026/040
6a332097-04fa-451d-8c71-170b4a08c6d9	4a8c0b31-ceb5-4c61-b19b-3af5a5f20b4d	1222da46-5238-4e7f-a4a6-ceef448e178a	0	32344.83	Accommodation - BRENDON 7 DAYS @80
d5777740-bd43-4f46-b8d7-fafdb207fddf	4a8c0b31-ceb5-4c61-b19b-3af5a5f20b4d	fbce077f-9236-4c37-8a27-aa02fa20fa16	0	5175.17	VAT 16%
aabdd106-e8d0-4083-a892-4e2bc9e3ad72	752c8b55-5b8b-4678-93b4-99ed6ec43091	c31a0335-c51a-4e4e-a6a0-031f0ab068c0	465650	0	Invoice receivable FT 2026/041
0474e005-994a-4238-a600-b6926aa726a0	752c8b55-5b8b-4678-93b4-99ed6ec43091	1222da46-5238-4e7f-a4a6-ceef448e178a	0	401422.41	Accommodation - TAFY RECEIVED FROM ROBIN
3ecfba6e-13f6-4fe8-976e-a3d272e1ad64	752c8b55-5b8b-4678-93b4-99ed6ec43091	fbce077f-9236-4c37-8a27-aa02fa20fa16	0	64227.59	VAT 16%
c527e4d6-313d-4d42-892d-3aab3a2b41db	dc6b8e89-566a-4f3d-9a00-aab2c7cf6b9c	c31a0335-c51a-4e4e-a6a0-031f0ab068c0	958350	0	Invoice receivable FT 2026/042
e2436936-e758-4cbd-a9b9-102dfec45d37	dc6b8e89-566a-4f3d-9a00-aab2c7cf6b9c	1222da46-5238-4e7f-a4a6-ceef448e178a	0	826163.79	Accommodation - WARREN STEAD
1aa3105e-48fa-4642-bf76-d5871e1e6044	dc6b8e89-566a-4f3d-9a00-aab2c7cf6b9c	fbce077f-9236-4c37-8a27-aa02fa20fa16	0	132186.21	VAT 16%
97b01fc2-3c1b-4c58-896f-e29c09be8313	5fd793f3-5294-4934-b089-f6dbfe9a07dc	c31a0335-c51a-4e4e-a6a0-031f0ab068c0	335000	0	Invoice receivable FT 2026/043
462c7d10-1292-401b-9981-bac770343c82	5fd793f3-5294-4934-b089-f6dbfe9a07dc	1222da46-5238-4e7f-a4a6-ceef448e178a	0	288793.1	Accommodation - TAFY RECEIVED FROM ALEX
a5987703-f5f7-4147-b66c-02ac5c178825	5fd793f3-5294-4934-b089-f6dbfe9a07dc	fbce077f-9236-4c37-8a27-aa02fa20fa16	0	46206.9	VAT 16%
53136f96-b07c-4e94-9a7b-4644320527ae	3bcb4c43-1afc-4a14-83a8-e8cbee548977	c31a0335-c51a-4e4e-a6a0-031f0ab068c0	55200	0	Invoice receivable FT 2026/044
333aa7c2-7537-4d8f-9809-f8f5b2ae6f1e	3bcb4c43-1afc-4a14-83a8-e8cbee548977	1222da46-5238-4e7f-a4a6-ceef448e178a	0	47586.21	Accommodation - BRENDON
3174ff99-8b03-411b-b10d-37b116c2b0da	3bcb4c43-1afc-4a14-83a8-e8cbee548977	fbce077f-9236-4c37-8a27-aa02fa20fa16	0	7613.79	VAT 16%
1037272a-6d5a-4d73-a795-4c8241f23568	34c2b0b3-58f3-436a-8ba6-35a188938c3e	c31a0335-c51a-4e4e-a6a0-031f0ab068c0	812375	0	Invoice receivable FT 2026/045
37c784b8-175a-4e6c-a406-9c405af195a7	34c2b0b3-58f3-436a-8ba6-35a188938c3e	1222da46-5238-4e7f-a4a6-ceef448e178a	0	700323.28	Accommodation - TAFY
76683033-1fc5-42d1-bb63-caacb12e9cba	34c2b0b3-58f3-436a-8ba6-35a188938c3e	fbce077f-9236-4c37-8a27-aa02fa20fa16	0	112051.72	VAT 16%
4e8baa3f-02fd-4acd-8d8a-2ff2c5f94146	d9ca6b0c-7d92-4983-a3b8-ef0de5affbba	c31a0335-c51a-4e4e-a6a0-031f0ab068c0	335000	0	Invoice receivable FT 2026/046
e3b2ccf3-530c-4cb8-aadf-a687faa0602c	d9ca6b0c-7d92-4983-a3b8-ef0de5affbba	1222da46-5238-4e7f-a4a6-ceef448e178a	0	288793.1	Accommodation - TAFY
53a3bf17-2d48-4aca-8892-5aa69a6920fc	d9ca6b0c-7d92-4983-a3b8-ef0de5affbba	fbce077f-9236-4c37-8a27-aa02fa20fa16	0	46206.9	VAT 16%
75846130-a711-47fc-95e5-1ffd54444a68	c3a9ce6a-81e3-44b9-b714-1bf7bdf52fc9	c31a0335-c51a-4e4e-a6a0-031f0ab068c0	98490	0	Invoice receivable FT 2026/047
66b8948a-b863-4626-82eb-da567f8a4076	c3a9ce6a-81e3-44b9-b714-1bf7bdf52fc9	1222da46-5238-4e7f-a4a6-ceef448e178a	0	84905.17	Accommodation - ARON ACCOMMODATION IN H4
8a534bac-2372-4e91-afe3-7d0f214da6d2	c3a9ce6a-81e3-44b9-b714-1bf7bdf52fc9	fbce077f-9236-4c37-8a27-aa02fa20fa16	0	13584.83	VAT 16%
802171a8-075b-48f6-87ba-7ae39af2cc56	14021e21-fa0b-4e0c-8d4c-8755179cc230	c31a0335-c51a-4e4e-a6a0-031f0ab068c0	948750	0	Invoice receivable FT 2026/048
bbcf73e1-9b9a-4348-bb9d-b68d64ba46ef	14021e21-fa0b-4e0c-8d4c-8755179cc230	1222da46-5238-4e7f-a4a6-ceef448e178a	0	817887.93	Accommodation - ALEX
77f592d7-f795-457a-b929-51fc464debd1	14021e21-fa0b-4e0c-8d4c-8755179cc230	fbce077f-9236-4c37-8a27-aa02fa20fa16	0	130862.07	VAT 16%
98f1dafe-322a-4f17-87e8-4ce54132b08e	69b77cba-e269-4b78-b4d4-7d4220e8764d	c31a0335-c51a-4e4e-a6a0-031f0ab068c0	22400	0	Invoice receivable FT 2026/049
1e5522fb-0964-41fb-afef-8914b3d56b6f	69b77cba-e269-4b78-b4d4-7d4220e8764d	1222da46-5238-4e7f-a4a6-ceef448e178a	0	19310.34	Accommodation - BRENDON
2be78425-d224-4b12-bed5-d658162ddbb5	69b77cba-e269-4b78-b4d4-7d4220e8764d	fbce077f-9236-4c37-8a27-aa02fa20fa16	0	3089.66	VAT 16%
8834ceec-6d4c-4cfe-a537-0e229cb09dfe	2779d770-7027-4b37-9902-3d94607d3572	c31a0335-c51a-4e4e-a6a0-031f0ab068c0	948750	0	Invoice receivable FT 2026/050
71866ffc-6bef-47f2-ae1d-b09c74915815	2779d770-7027-4b37-9902-3d94607d3572	1222da46-5238-4e7f-a4a6-ceef448e178a	0	817887.93	Accommodation - WARREN COHEN INVESTMENT
9ef69c59-d176-487f-a97f-625e65abbf1d	2779d770-7027-4b37-9902-3d94607d3572	fbce077f-9236-4c37-8a27-aa02fa20fa16	0	130862.07	VAT 16%
2f58f52f-1307-4387-9480-4ecdb97345b7	a9629fb9-c052-4fea-8fb7-03ae1f781a86	fbce077f-9236-4c37-8a27-aa02fa20fa16	0	132186.21	VAT 16%
ffaba20a-9471-41ec-9976-109d3fa46004	9d34c92c-d0a6-44e2-a6c3-d15957da8145	c31a0335-c51a-4e4e-a6a0-031f0ab068c0	958350	0	Invoice receivable FT 2026/051
d6e0f54f-9dc1-4b58-ae26-55acee154fba	9d34c92c-d0a6-44e2-a6c3-d15957da8145	1222da46-5238-4e7f-a4a6-ceef448e178a	0	826163.79	Accommodation - WARREN STEAD
e15106a3-6d4f-4dca-8736-6a79ad91eb26	9d34c92c-d0a6-44e2-a6c3-d15957da8145	fbce077f-9236-4c37-8a27-aa02fa20fa16	0	132186.21	VAT 16%
05be18d5-4bab-445e-91d9-dfaf0f4897d5	1faa3a4a-8859-437d-ae14-5d4232c21e3b	c31a0335-c51a-4e4e-a6a0-031f0ab068c0	60720	0	Invoice receivable FT 2026/052
02f0a503-58e0-491d-892f-02866ae0826b	1faa3a4a-8859-437d-ae14-5d4232c21e3b	1222da46-5238-4e7f-a4a6-ceef448e178a	0	52344.83	Accommodation - ALAIN WARREN
9121a554-63d5-42e4-af4b-f94e282b37b6	1faa3a4a-8859-437d-ae14-5d4232c21e3b	fbce077f-9236-4c37-8a27-aa02fa20fa16	0	8375.17	VAT 16%
318a2634-86df-4b82-a1a5-0bd5bd656f8e	99001375-4cc9-4f62-9374-518be7a9b426	c31a0335-c51a-4e4e-a6a0-031f0ab068c0	310000	0	Invoice receivable FT 2026/053
0f425dd8-718a-4631-8808-7122935c3eca	99001375-4cc9-4f62-9374-518be7a9b426	1222da46-5238-4e7f-a4a6-ceef448e178a	0	267241.38	Accommodation - TAFY RECEIVED FROM AANGIE
b0d990a2-3207-4dc8-86bd-c6ca01d5db34	99001375-4cc9-4f62-9374-518be7a9b426	fbce077f-9236-4c37-8a27-aa02fa20fa16	0	42758.62	VAT 16%
91cf5ba8-1a62-4b8b-937d-c1699c6bbf2e	aaf65970-10e5-4c38-b835-8bdb91e90817	c31a0335-c51a-4e4e-a6a0-031f0ab068c0	222300	0	Invoice receivable FT 2026/054
17c776c8-594f-4000-ab57-9ade943ca551	aaf65970-10e5-4c38-b835-8bdb91e90817	1222da46-5238-4e7f-a4a6-ceef448e178a	0	191637.93	Accommodation - ALEX TRANSFER TO MONIQUE
75a44bd9-66ae-4a7f-8add-0f872c025fab	aaf65970-10e5-4c38-b835-8bdb91e90817	fbce077f-9236-4c37-8a27-aa02fa20fa16	0	30662.07	VAT 16%
e91ffffa-f71f-4845-a953-38504e6fb3c8	e145dc08-f86a-4899-861e-1c2947dc2ec1	c31a0335-c51a-4e4e-a6a0-031f0ab068c0	458172	0	Invoice receivable FT 2026/055
f171ba7e-e175-4888-9492-b5515dbcf8d8	e145dc08-f86a-4899-861e-1c2947dc2ec1	1222da46-5238-4e7f-a4a6-ceef448e178a	0	394975.86	Accommodation - WARREN PAY TRACY SALARY AND RECRUITMENT
61ea81bc-d42b-4254-bbe6-fada158190a7	e145dc08-f86a-4899-861e-1c2947dc2ec1	fbce077f-9236-4c37-8a27-aa02fa20fa16	0	63196.14	VAT 16%
d4ee303b-5cff-4c9d-84db-3cbfabdd33a0	c26bae19-f04e-4b0d-be5b-cc3e401be8c5	c31a0335-c51a-4e4e-a6a0-031f0ab068c0	293480	0	Invoice receivable FT 2026/056
156a8a09-72ff-4777-9203-9b8a658d59ee	c26bae19-f04e-4b0d-be5b-cc3e401be8c5	1222da46-5238-4e7f-a4a6-ceef448e178a	0	253000	Accommodation - ALEX
bdbb56b7-489f-49df-ac61-ba24413c89ad	c26bae19-f04e-4b0d-be5b-cc3e401be8c5	fbce077f-9236-4c37-8a27-aa02fa20fa16	0	40480	VAT 16%
994086f1-f38c-4bd2-a87b-7cbe7cc3cde8	f1883d19-e0db-4067-b665-089f2f66cd75	c31a0335-c51a-4e4e-a6a0-031f0ab068c0	948750	0	Invoice receivable FT 2026/057
f76b85d1-5163-42c5-9d0f-a82552edc5e3	f1883d19-e0db-4067-b665-089f2f66cd75	1222da46-5238-4e7f-a4a6-ceef448e178a	0	817887.93	Accommodation - WARREN COHEN INVESTMENT
3e556521-44f9-45a9-bf61-4cd3947b0d17	f1883d19-e0db-4067-b665-089f2f66cd75	fbce077f-9236-4c37-8a27-aa02fa20fa16	0	130862.07	VAT 16%
94610859-12da-4ab7-a88a-de8d77eaf2a0	6349b650-82d2-48af-8ce0-f7e796591d10	c31a0335-c51a-4e4e-a6a0-031f0ab068c0	958350	0	Invoice receivable FT 2026/058
983ec950-50e9-49b8-8112-c05c2addbaec	6349b650-82d2-48af-8ce0-f7e796591d10	1222da46-5238-4e7f-a4a6-ceef448e178a	0	826163.79	Accommodation - WARREN STEAD
66d513f0-7d4d-424c-abc8-cf2f2f5eafdf	6349b650-82d2-48af-8ce0-f7e796591d10	fbce077f-9236-4c37-8a27-aa02fa20fa16	0	132186.21	VAT 16%
ce3c1871-ec3e-4f6f-ba72-a15c93b2db36	878c6e58-822f-481b-87ec-0920aa7d7c29	c31a0335-c51a-4e4e-a6a0-031f0ab068c0	40200	0	Invoice receivable FT 2026/059
29446d14-20b1-4d46-87c8-cd0d15ff6dff	878c6e58-822f-481b-87ec-0920aa7d7c29	1222da46-5238-4e7f-a4a6-ceef448e178a	0	34655.17	Accommodation - CREDIT IVA H3 - KEITH & SUE X 8 NIGHTS @ 75
4f1ecbda-2ae5-4cc4-a6aa-5204a2c69b48	878c6e58-822f-481b-87ec-0920aa7d7c29	fbce077f-9236-4c37-8a27-aa02fa20fa16	0	5544.83	VAT 16%
aaf3cef9-9610-4f84-8b1a-fb3f375d88d4	e7d2226e-dd88-45cb-9ab8-d67693c58368	c31a0335-c51a-4e4e-a6a0-031f0ab068c0	132000	0	Invoice receivable FT 2026/060
8b49a535-dc80-4d9a-a03e-c0765b69f785	e7d2226e-dd88-45cb-9ab8-d67693c58368	1222da46-5238-4e7f-a4a6-ceef448e178a	0	113793.1	Accommodation - ALEX
c9f67f0d-6649-4890-b5b4-3c61c3f590e6	e7d2226e-dd88-45cb-9ab8-d67693c58368	fbce077f-9236-4c37-8a27-aa02fa20fa16	0	18206.9	VAT 16%
284d6331-e089-49d7-ae89-8cae9de430d1	82c0c79e-5a59-4608-a9f8-ec97f5c99ce7	c31a0335-c51a-4e4e-a6a0-031f0ab068c0	119000	0	Invoice receivable FT 2026/061
1bfb976e-9bba-494a-aa59-83d46a573a78	82c0c79e-5a59-4608-a9f8-ec97f5c99ce7	1222da46-5238-4e7f-a4a6-ceef448e178a	0	102586.21	Accommodation - WARREN
0b40cfb2-2946-49bb-9b83-c2294935d07a	82c0c79e-5a59-4608-a9f8-ec97f5c99ce7	fbce077f-9236-4c37-8a27-aa02fa20fa16	0	16413.79	VAT 16%
047950fd-36a4-4196-9ba6-0298f8c6a58f	ae1c23f4-f70a-4ee9-b77a-819072fc1561	c31a0335-c51a-4e4e-a6a0-031f0ab068c0	551000	0	Invoice receivable FT 2026/062
2ec96369-4242-431e-bc74-e74fa024142c	ae1c23f4-f70a-4ee9-b77a-819072fc1561	1222da46-5238-4e7f-a4a6-ceef448e178a	0	475000	Accommodation - TAFY
a16f20d3-73e8-4d32-b1f3-55905657a4b8	ae1c23f4-f70a-4ee9-b77a-819072fc1561	fbce077f-9236-4c37-8a27-aa02fa20fa16	0	76000	VAT 16%
1db17658-4250-42a0-ac1c-0aa53f5b61bc	a82d3dc7-e567-48f1-b9f3-d55f79f98de5	c31a0335-c51a-4e4e-a6a0-031f0ab068c0	420000	0	Invoice receivable FT 2026/063
58362269-e0c2-4322-a95e-7eecce247729	a82d3dc7-e567-48f1-b9f3-d55f79f98de5	1222da46-5238-4e7f-a4a6-ceef448e178a	0	362068.97	Accommodation - KEIVIN PAY TO BANK
473065fc-23f1-429f-9d9c-afd588350393	a82d3dc7-e567-48f1-b9f3-d55f79f98de5	fbce077f-9236-4c37-8a27-aa02fa20fa16	0	57931.03	VAT 16%
b0607e00-e9b1-4ad5-9137-c6ed65c0ba1e	87bffe9f-3589-4eeb-a413-81d41f97c28e	c31a0335-c51a-4e4e-a6a0-031f0ab068c0	207000	0	Invoice receivable FT 2026/064
a1fc49d7-0946-4bb2-b88f-f4b54423ae2d	87bffe9f-3589-4eeb-a413-81d41f97c28e	1222da46-5238-4e7f-a4a6-ceef448e178a	0	178448.28	Accommodation - TAFY RE ROBIN
f0fc6b33-1e82-4525-bf77-cce718062648	87bffe9f-3589-4eeb-a413-81d41f97c28e	fbce077f-9236-4c37-8a27-aa02fa20fa16	0	28551.72	VAT 16%
f10eac5f-d5e9-4f56-9388-d3b648374f3d	7e5d464d-93fd-44d7-b673-9bd143afed80	c31a0335-c51a-4e4e-a6a0-031f0ab068c0	569250	0	Invoice receivable FT 2026/065
c4b4b5fa-7abf-4f3e-aa05-4487e53f3bfd	7e5d464d-93fd-44d7-b673-9bd143afed80	1222da46-5238-4e7f-a4a6-ceef448e178a	0	490732.76	Accommodation - WARREN INVESTMENT DOLLAR ACCOUNT
75bfce70-689c-4334-b57c-063c24ffd807	7e5d464d-93fd-44d7-b673-9bd143afed80	fbce077f-9236-4c37-8a27-aa02fa20fa16	0	78517.24	VAT 16%
e995c365-8ae9-455c-989d-39d38a7ab2c0	48333f31-bd2b-4ae9-8367-d48dc672533b	c31a0335-c51a-4e4e-a6a0-031f0ab068c0	594297	0	Invoice receivable FT 2026/066
fc2c10ba-b450-4e29-860b-2be09b5675a5	48333f31-bd2b-4ae9-8367-d48dc672533b	1222da46-5238-4e7f-a4a6-ceef448e178a	0	512325	Accommodation - ALEX
5f3ff8b4-f893-4122-aa6f-ba6b525c07ba	48333f31-bd2b-4ae9-8367-d48dc672533b	fbce077f-9236-4c37-8a27-aa02fa20fa16	0	81972	VAT 16%
11131151-7f01-4db9-9986-cf24e7979194	f6cb5a78-020e-4d1b-aef7-e9d37adb84d6	c31a0335-c51a-4e4e-a6a0-031f0ab068c0	958350	0	Invoice receivable FT 2026/067
a51a30c1-b54e-4dd6-9720-b82d8d7ceeef	f6cb5a78-020e-4d1b-aef7-e9d37adb84d6	1222da46-5238-4e7f-a4a6-ceef448e178a	0	826163.79	Accommodation - ALEX
72cd35ac-f9dd-4706-a688-657ff0f99731	f6cb5a78-020e-4d1b-aef7-e9d37adb84d6	fbce077f-9236-4c37-8a27-aa02fa20fa16	0	132186.21	VAT 16%
ad76b7ec-9282-4bc3-af5c-c5e06bb32008	63f05972-e49f-4c10-82f4-d08ffb5e10c5	c31a0335-c51a-4e4e-a6a0-031f0ab068c0	751171	0	Invoice receivable FT 2026/068
66892844-6bd8-4e31-b58a-773889469367	63f05972-e49f-4c10-82f4-d08ffb5e10c5	1222da46-5238-4e7f-a4a6-ceef448e178a	0	647561.21	Accommodation - ALEX
99cf8d86-26a5-4652-9b72-52903ac9973d	63f05972-e49f-4c10-82f4-d08ffb5e10c5	fbce077f-9236-4c37-8a27-aa02fa20fa16	0	103609.79	VAT 16%
c824075f-5eca-4e52-966a-4150a77cb231	0a45eea3-943f-4037-bca2-4d7a5aef6e91	c31a0335-c51a-4e4e-a6a0-031f0ab068c0	948750	0	Invoice receivable FT 2026/069
4333ae4c-531f-4ee6-a995-0966337dad08	0a45eea3-943f-4037-bca2-4d7a5aef6e91	1222da46-5238-4e7f-a4a6-ceef448e178a	0	817887.93	Accommodation - WARREN STEAD DEP BANK
63c5a18b-a30b-402a-9e80-c2b058d7751d	0a45eea3-943f-4037-bca2-4d7a5aef6e91	fbce077f-9236-4c37-8a27-aa02fa20fa16	0	130862.07	VAT 16%
b17b3c0d-7708-465a-9a26-51c3261210f0	5c8f19bd-2353-46bd-a190-36c66645ef4f	c31a0335-c51a-4e4e-a6a0-031f0ab068c0	941920	0	Invoice receivable FT 2026/070
a685448e-c697-4895-a6b1-706fb29ac7c4	5c8f19bd-2353-46bd-a190-36c66645ef4f	1222da46-5238-4e7f-a4a6-ceef448e178a	0	812000	Accommodation - WARREN STEAD
f6248f26-f531-465d-9413-da2031a42846	5c8f19bd-2353-46bd-a190-36c66645ef4f	fbce077f-9236-4c37-8a27-aa02fa20fa16	0	129920	VAT 16%
8f05ed91-a17a-4d10-84d3-c9ff3c111315	0f31bf99-0040-475f-96f8-117d491c5bc8	c31a0335-c51a-4e4e-a6a0-031f0ab068c0	68000	0	Invoice receivable FT 2026/071
fa2a36b8-5548-4ea8-8a83-8dbd00a6b994	0f31bf99-0040-475f-96f8-117d491c5bc8	1222da46-5238-4e7f-a4a6-ceef448e178a	0	58620.69	Accommodation - CREDIT IVA H1 - LESLEY X 6 NIGHTS
2c1c75af-f95a-4b04-b03f-995f32cafe9d	0f31bf99-0040-475f-96f8-117d491c5bc8	fbce077f-9236-4c37-8a27-aa02fa20fa16	0	9379.31	VAT 16%
bcb10fbd-bbef-476a-824c-d9011c43dfe7	26d387df-67c4-49d9-8bd6-c73b7b90d95e	c31a0335-c51a-4e4e-a6a0-031f0ab068c0	638900	0	Invoice receivable FT 2026/072
4c7a567d-1ba4-4e8a-8b65-f834ab81c997	26d387df-67c4-49d9-8bd6-c73b7b90d95e	1222da46-5238-4e7f-a4a6-ceef448e178a	0	550775.86	Accommodation - ALEX
ef3496db-faa6-4411-a9b6-5d7ae0bb702b	26d387df-67c4-49d9-8bd6-c73b7b90d95e	fbce077f-9236-4c37-8a27-aa02fa20fa16	0	88124.14	VAT 16%
c1805c97-2cf7-4cd2-a63d-f2fa2f2e571b	d762a09d-656a-4655-ba46-63b7f92030d9	c31a0335-c51a-4e4e-a6a0-031f0ab068c0	465650	0	Invoice receivable FT 2026/073
6a55b244-768a-472d-8ce0-51d0d2dad09c	d762a09d-656a-4655-ba46-63b7f92030d9	1222da46-5238-4e7f-a4a6-ceef448e178a	0	401422.41	Accommodation - TAFY RECEIVED FROM ROBIN
6bcb8d35-df28-475b-88f2-6baa0e5fb281	d762a09d-656a-4655-ba46-63b7f92030d9	fbce077f-9236-4c37-8a27-aa02fa20fa16	0	64227.59	VAT 16%
0aaf3ef1-d897-4b41-b06b-1bab87ed9e26	6863b383-ebd9-4de6-8bd0-7f4ffa2882c6	c31a0335-c51a-4e4e-a6a0-031f0ab068c0	55200	0	Invoice receivable FT 2026/074
8f7e59e2-9aca-4567-a43d-7baa4402e881	6863b383-ebd9-4de6-8bd0-7f4ffa2882c6	1222da46-5238-4e7f-a4a6-ceef448e178a	0	47586.21	Accommodation - BRENDON
6de5a356-677f-4fed-944b-2fd5fc563b56	6863b383-ebd9-4de6-8bd0-7f4ffa2882c6	fbce077f-9236-4c37-8a27-aa02fa20fa16	0	7613.79	VAT 16%
b75d4a04-48ee-4ae0-966d-1e32bf89263a	cfa3608a-4da5-438c-8066-d64d52f79acc	c31a0335-c51a-4e4e-a6a0-031f0ab068c0	1407000	0	Invoice receivable FT 2026/075
ae823607-8daf-44dc-ae50-c8fa8810d0fd	cfa3608a-4da5-438c-8066-d64d52f79acc	1222da46-5238-4e7f-a4a6-ceef448e178a	0	1212931.03	Accommodation - WARREN COHEN INVESTMENT
21ee7944-7dd2-4638-96d6-4058bd680baa	cfa3608a-4da5-438c-8066-d64d52f79acc	fbce077f-9236-4c37-8a27-aa02fa20fa16	0	194068.97	VAT 16%
c07d5e05-7dfb-4253-9dea-edb43d941c4f	9ea68823-2b5c-4adb-9252-00d45e9fec67	c31a0335-c51a-4e4e-a6a0-031f0ab068c0	335000	0	Invoice receivable FT 2026/076
c445f05a-a313-41fe-9bc8-3be0ce00f211	9ea68823-2b5c-4adb-9252-00d45e9fec67	1222da46-5238-4e7f-a4a6-ceef448e178a	0	288793.1	Accommodation - TAFY
5c83bfd2-6872-472e-a534-b3665d82280f	9ea68823-2b5c-4adb-9252-00d45e9fec67	fbce077f-9236-4c37-8a27-aa02fa20fa16	0	46206.9	VAT 16%
f94010e8-296b-483a-8750-d49de5056336	7b385729-d24c-4dea-9539-e204646e9f13	c31a0335-c51a-4e4e-a6a0-031f0ab068c0	37520	0	Invoice receivable FT 2026/077
53f70854-4ecb-4fc2-ba90-559d2601ebd4	7b385729-d24c-4dea-9539-e204646e9f13	1222da46-5238-4e7f-a4a6-ceef448e178a	0	32344.83	Accommodation - BRENDON 7 DAYS @80
3f8a5b6e-8baf-4d2a-81d1-0f83edfe7867	7b385729-d24c-4dea-9539-e204646e9f13	fbce077f-9236-4c37-8a27-aa02fa20fa16	0	5175.17	VAT 16%
94fabdda-4366-4233-ad6c-2db7c4e69223	206d00a7-e385-431b-a1f0-820e7ed914d1	c31a0335-c51a-4e4e-a6a0-031f0ab068c0	335000	0	Invoice receivable FT 2026/078
12f2dbd6-290d-44a8-baa9-b29f4773d9ae	206d00a7-e385-431b-a1f0-820e7ed914d1	1222da46-5238-4e7f-a4a6-ceef448e178a	0	288793.1	Accommodation - TAFY RECEIVED FROM ALEX
c619ba98-6b42-4769-bc36-0d58f3bcaf90	206d00a7-e385-431b-a1f0-820e7ed914d1	fbce077f-9236-4c37-8a27-aa02fa20fa16	0	46206.9	VAT 16%
61898f23-c275-44e7-9095-cc0b527f26cb	fa22d2bc-b2ae-441a-9cb8-c8e65ce187c6	c31a0335-c51a-4e4e-a6a0-031f0ab068c0	38400	0	Invoice receivable FT 2026/079
9ea09798-9b9b-4563-a014-88a8711c669c	fa22d2bc-b2ae-441a-9cb8-c8e65ce187c6	1222da46-5238-4e7f-a4a6-ceef448e178a	0	33103.45	Accommodation - TAFY ELIANA
e6557df4-856d-41ac-82ee-aa29e9e359da	fa22d2bc-b2ae-441a-9cb8-c8e65ce187c6	fbce077f-9236-4c37-8a27-aa02fa20fa16	0	5296.55	VAT 16%
e8bd5c6a-06e0-43e4-a4ae-9b5832651a7f	1ce836ed-220b-4496-8a9a-a740f187fa04	c31a0335-c51a-4e4e-a6a0-031f0ab068c0	958350	0	Invoice receivable FT 2026/080
b23928a7-33e2-460f-8756-cc564a0982e3	1ce836ed-220b-4496-8a9a-a740f187fa04	1222da46-5238-4e7f-a4a6-ceef448e178a	0	826163.79	Accommodation - WARREN STEAD
ad6a1bde-1299-4147-a661-2662b72c030f	1ce836ed-220b-4496-8a9a-a740f187fa04	fbce077f-9236-4c37-8a27-aa02fa20fa16	0	132186.21	VAT 16%
ff87d205-ce0c-4204-a89c-83e7fa42b655	49361d80-a483-454d-9edc-656a363e82c1	c31a0335-c51a-4e4e-a6a0-031f0ab068c0	812375	0	Invoice receivable FT 2026/081
3454733d-4f0b-42a2-a265-7ee7d9def1db	49361d80-a483-454d-9edc-656a363e82c1	1222da46-5238-4e7f-a4a6-ceef448e178a	0	700323.28	Accommodation - TAFY
b658612b-5453-4928-8442-7d7bcd2d80a8	49361d80-a483-454d-9edc-656a363e82c1	fbce077f-9236-4c37-8a27-aa02fa20fa16	0	112051.72	VAT 16%
02bf8b64-eb8e-49d0-9433-eb12245b1420	55bc3e9d-d935-4cf1-b7ad-23faddfe7e07	c31a0335-c51a-4e4e-a6a0-031f0ab068c0	98490	0	Invoice receivable FT 2026/082
e20dbcb0-2d42-444a-b62c-813725269b3a	55bc3e9d-d935-4cf1-b7ad-23faddfe7e07	1222da46-5238-4e7f-a4a6-ceef448e178a	0	84905.17	Accommodation - ARON ACCOMMODATION IN H4
0154a73b-668c-4dba-ba71-49706dbf3f0c	55bc3e9d-d935-4cf1-b7ad-23faddfe7e07	fbce077f-9236-4c37-8a27-aa02fa20fa16	0	13584.83	VAT 16%
607e8bfa-d1ae-40d4-895e-42b8971cb856	e4d1e4d1-a50a-41a0-bdfa-c2cc2e38cd0a	c31a0335-c51a-4e4e-a6a0-031f0ab068c0	948750	0	Invoice receivable FT 2026/083
13202344-9f3f-4552-8408-cb22192401bd	e4d1e4d1-a50a-41a0-bdfa-c2cc2e38cd0a	1222da46-5238-4e7f-a4a6-ceef448e178a	0	817887.93	Accommodation - ALEX
48a7a752-f582-497e-bf89-ae6d814fb68f	e4d1e4d1-a50a-41a0-bdfa-c2cc2e38cd0a	fbce077f-9236-4c37-8a27-aa02fa20fa16	0	130862.07	VAT 16%
edceb040-450c-46d5-b1ac-21ab9fa9aa43	411eac46-c4b3-42e5-a991-4f77314745f8	c31a0335-c51a-4e4e-a6a0-031f0ab068c0	22400	0	Invoice receivable FT 2026/084
7b4d99e8-70e2-4479-ac04-b8a0ee4c91c3	411eac46-c4b3-42e5-a991-4f77314745f8	1222da46-5238-4e7f-a4a6-ceef448e178a	0	19310.34	Accommodation - BRENDON
72461431-c4e2-4792-b35c-0285aee46264	411eac46-c4b3-42e5-a991-4f77314745f8	fbce077f-9236-4c37-8a27-aa02fa20fa16	0	3089.66	VAT 16%
70846581-1eab-4c6d-a4f2-aba755e3443e	d743140a-88ad-47fd-ae48-5ada617199ba	c31a0335-c51a-4e4e-a6a0-031f0ab068c0	948750	0	Invoice receivable FT 2026/085
0a21eda5-3d6f-4122-b1bf-3a2201d386c1	d743140a-88ad-47fd-ae48-5ada617199ba	1222da46-5238-4e7f-a4a6-ceef448e178a	0	817887.93	Accommodation - WARREN COHEN INVESTMENT
17739586-e210-40c3-8380-91f0e105a9aa	d743140a-88ad-47fd-ae48-5ada617199ba	fbce077f-9236-4c37-8a27-aa02fa20fa16	0	130862.07	VAT 16%
ae747be4-f9c2-4e2d-a385-6777c8966c6b	a8aafe73-74ed-4759-9828-d6cb50be160f	c31a0335-c51a-4e4e-a6a0-031f0ab068c0	958350	0	Invoice receivable FT 2026/086
2977d670-4e03-4215-b152-a56de387fee5	a8aafe73-74ed-4759-9828-d6cb50be160f	1222da46-5238-4e7f-a4a6-ceef448e178a	0	826163.79	Accommodation - WARREN STEAD
ff0a9a9f-50f7-4357-999c-45b79161b856	a8aafe73-74ed-4759-9828-d6cb50be160f	fbce077f-9236-4c37-8a27-aa02fa20fa16	0	132186.21	VAT 16%
acc3e2a6-b7a4-49a6-afb1-8e023c812196	ded44176-e7f6-43d2-908b-6645e4481ab3	c31a0335-c51a-4e4e-a6a0-031f0ab068c0	60720	0	Invoice receivable FT 2026/087
4cdd2be6-c1d1-4900-aed9-a1e2d0c9f085	ded44176-e7f6-43d2-908b-6645e4481ab3	1222da46-5238-4e7f-a4a6-ceef448e178a	0	52344.83	Accommodation - ALAIN WARREN
0f28b7f4-478f-4d62-b7c9-51fbf03f4626	ded44176-e7f6-43d2-908b-6645e4481ab3	fbce077f-9236-4c37-8a27-aa02fa20fa16	0	8375.17	VAT 16%
e3e56acc-dad6-413b-9e42-b4a848a65912	03554493-32cc-45e1-a930-03703e07307b	c31a0335-c51a-4e4e-a6a0-031f0ab068c0	222300	0	Invoice receivable FT 2026/088
7083fca7-d316-420d-bfc1-76f4b5bddd23	03554493-32cc-45e1-a930-03703e07307b	1222da46-5238-4e7f-a4a6-ceef448e178a	0	191637.93	Accommodation - ALEX TRANSFER TO MONIQUE
01f4259c-1d3a-4e95-94bb-173930431db2	03554493-32cc-45e1-a930-03703e07307b	fbce077f-9236-4c37-8a27-aa02fa20fa16	0	30662.07	VAT 16%
9eb1a83a-c2eb-4726-b788-76cbde400e48	5a759d36-c218-4541-9f61-cddb57ade7e6	c31a0335-c51a-4e4e-a6a0-031f0ab068c0	310000	0	Invoice receivable FT 2026/089
7adf6bd5-7101-484a-9d62-6eb0420ab0b6	5a759d36-c218-4541-9f61-cddb57ade7e6	1222da46-5238-4e7f-a4a6-ceef448e178a	0	267241.38	Accommodation - TAFY RECEIVED FROM AANGIE
316fb38f-fb0f-43e8-a17c-6b6190e42fde	5a759d36-c218-4541-9f61-cddb57ade7e6	fbce077f-9236-4c37-8a27-aa02fa20fa16	0	42758.62	VAT 16%
1bfed3d7-c9e2-430b-85a4-f5c3868e144c	97f8b77b-d458-4fa1-b001-20826cb5a5c4	c31a0335-c51a-4e4e-a6a0-031f0ab068c0	458172	0	Invoice receivable FT 2026/090
0bec50ff-cce6-4f18-9621-305662984d6a	97f8b77b-d458-4fa1-b001-20826cb5a5c4	1222da46-5238-4e7f-a4a6-ceef448e178a	0	394975.86	Accommodation - WARREN PAY TRACY SALARY AND RECRUITMENT
5b0e4dc9-2c91-4201-8715-719dbf488156	97f8b77b-d458-4fa1-b001-20826cb5a5c4	fbce077f-9236-4c37-8a27-aa02fa20fa16	0	63196.14	VAT 16%
078f7800-a02e-4e26-a28b-14ebc85e6eb7	4d3ea5d5-c8cf-4925-a531-9221876b19db	c31a0335-c51a-4e4e-a6a0-031f0ab068c0	293480	0	Invoice receivable FT 2026/091
f0a8122a-5d5e-471f-8088-c89097ec511b	4d3ea5d5-c8cf-4925-a531-9221876b19db	1222da46-5238-4e7f-a4a6-ceef448e178a	0	253000	Accommodation - ALEX
063db219-9654-4f6d-b42c-021bd3d394f3	4d3ea5d5-c8cf-4925-a531-9221876b19db	fbce077f-9236-4c37-8a27-aa02fa20fa16	0	40480	VAT 16%
75908a49-3c66-4523-8270-a0ef7831022e	63797375-7ca4-44a8-8300-ad4e7c538392	c31a0335-c51a-4e4e-a6a0-031f0ab068c0	948750	0	Invoice receivable FT 2026/092
91b1b784-fbe6-4713-9ddf-aa7b9c27091c	63797375-7ca4-44a8-8300-ad4e7c538392	1222da46-5238-4e7f-a4a6-ceef448e178a	0	817887.93	Accommodation - WARREN COHEN INVESTMENT
4e8a7fa7-62a2-4911-a168-ff4d5ef54b1b	63797375-7ca4-44a8-8300-ad4e7c538392	fbce077f-9236-4c37-8a27-aa02fa20fa16	0	130862.07	VAT 16%
4acf2733-fa61-46c4-b734-c2f59011a339	951ba03c-1c13-441e-a38e-ed25e8966238	c31a0335-c51a-4e4e-a6a0-031f0ab068c0	119000	0	Invoice receivable FT 2026/093
b6a8f232-1240-4e7f-b0ee-c0da4028c2d1	951ba03c-1c13-441e-a38e-ed25e8966238	1222da46-5238-4e7f-a4a6-ceef448e178a	0	102586.21	Accommodation - WARREN
f300ab75-b2ea-4298-be3d-e52dbd89ac62	951ba03c-1c13-441e-a38e-ed25e8966238	fbce077f-9236-4c37-8a27-aa02fa20fa16	0	16413.79	VAT 16%
3784fccf-537f-444e-9df2-246ccc806335	b33219e3-86fa-403b-aa1e-39e51c09404a	c31a0335-c51a-4e4e-a6a0-031f0ab068c0	551000	0	Invoice receivable FT 2026/094
4afa3a34-1616-4f39-bba6-ffd4d3e862f5	b33219e3-86fa-403b-aa1e-39e51c09404a	1222da46-5238-4e7f-a4a6-ceef448e178a	0	475000	Accommodation - TAFY
1597e567-b80d-4604-a2d1-7b898b036ab3	b33219e3-86fa-403b-aa1e-39e51c09404a	fbce077f-9236-4c37-8a27-aa02fa20fa16	0	76000	VAT 16%
9ae7c8e7-a5a4-4e16-96ee-94e8531a7dfd	85888e62-46aa-4085-8dd7-c6e56d1ca454	c31a0335-c51a-4e4e-a6a0-031f0ab068c0	40200	0	Invoice receivable FT 2026/095
e3537935-bf3c-494b-9e0a-a56eefbb5e39	85888e62-46aa-4085-8dd7-c6e56d1ca454	1222da46-5238-4e7f-a4a6-ceef448e178a	0	34655.17	Accommodation - CREDIT IVA H3 - KEITH & SUE X 8 NIGHTS @ 75
502a71f8-ab3c-4a0c-bd8a-4c73107b1a14	85888e62-46aa-4085-8dd7-c6e56d1ca454	fbce077f-9236-4c37-8a27-aa02fa20fa16	0	5544.83	VAT 16%
c8831846-5378-40af-98a2-6bcff0f23352	eb16be51-0c12-4db9-bda3-715f775279fe	c31a0335-c51a-4e4e-a6a0-031f0ab068c0	132000	0	Invoice receivable FT 2026/096
26d66b6b-a02f-4cd4-ad2d-39a527078f3f	eb16be51-0c12-4db9-bda3-715f775279fe	1222da46-5238-4e7f-a4a6-ceef448e178a	0	113793.1	Accommodation - ALEX
f30a9b5f-8a98-4b8b-bc69-02e0371e0fbc	eb16be51-0c12-4db9-bda3-715f775279fe	fbce077f-9236-4c37-8a27-aa02fa20fa16	0	18206.9	VAT 16%
70534f1c-56ad-4642-96e4-32bc8a416d54	a9629fb9-c052-4fea-8fb7-03ae1f781a86	c31a0335-c51a-4e4e-a6a0-031f0ab068c0	958350	0	Invoice receivable FT 2026/097
f491a242-d69a-42ae-8ef3-ef093ccd1f13	a9629fb9-c052-4fea-8fb7-03ae1f781a86	1222da46-5238-4e7f-a4a6-ceef448e178a	0	826163.79	Accommodation - WARREN STEAD
aa9e702c-e32d-476b-b737-f3a5c590dfdd	e7d59e7e-9db7-4174-8860-58ebcf24cc93	c31a0335-c51a-4e4e-a6a0-031f0ab068c0	569250	0	Invoice receivable FT 2026/098
8191ecd0-a3a5-4a2c-a188-85cd327a119a	e7d59e7e-9db7-4174-8860-58ebcf24cc93	1222da46-5238-4e7f-a4a6-ceef448e178a	0	490732.76	Accommodation - WARREN INVESTMENT DOLLAR ACCOUNT
33b4aae6-cc01-4514-b58f-93895d928133	e7d59e7e-9db7-4174-8860-58ebcf24cc93	fbce077f-9236-4c37-8a27-aa02fa20fa16	0	78517.24	VAT 16%
b2696091-cb34-49db-8f36-f41de400f2ca	6da826be-190e-480b-a2a1-e9a28f5491b2	c31a0335-c51a-4e4e-a6a0-031f0ab068c0	207000	0	Invoice receivable FT 2026/099
5a34e2c9-8267-4d32-8126-6d899a7f469a	6da826be-190e-480b-a2a1-e9a28f5491b2	1222da46-5238-4e7f-a4a6-ceef448e178a	0	178448.28	Accommodation - TAFY RE ROBIN
144d0cca-0ea9-4512-9a11-3f3d0b4c3cc8	6da826be-190e-480b-a2a1-e9a28f5491b2	fbce077f-9236-4c37-8a27-aa02fa20fa16	0	28551.72	VAT 16%
b57011fe-a887-406a-8431-840fe3b13965	a0162379-4a21-4be9-bfec-2b28529b3a19	c31a0335-c51a-4e4e-a6a0-031f0ab068c0	420000	0	Invoice receivable FT 2026/100
de03b5b8-e65d-462b-b984-c13f49dc6fc1	a0162379-4a21-4be9-bfec-2b28529b3a19	1222da46-5238-4e7f-a4a6-ceef448e178a	0	362068.97	Accommodation - KEIVIN PAY TO BANK
4811cf1d-a1b6-463f-8625-89aaf1665c7e	a0162379-4a21-4be9-bfec-2b28529b3a19	fbce077f-9236-4c37-8a27-aa02fa20fa16	0	57931.03	VAT 16%
80b5ff2b-156a-4b94-bb90-1bb8e3985d47	4ba85fd7-80c6-40f7-b934-e49633eecbee	97048dbc-5f9d-4ac4-961a-76ea11ae416a	575	0	3310
996ba3c1-c9cf-447d-9957-3078d8435af2	4ba85fd7-80c6-40f7-b934-e49633eecbee	b67e88f5-4e1c-45b3-9e1a-52d922be3470	0	575	3310
44fa2a78-42af-4676-a9dd-8c4cd972f178	07fcc7d5-808c-42b0-b2ab-ffde146987ac	4d329d98-68bb-4636-8f5b-0602eedd3eaa	1462.56	0	\N
fdc33786-0f0e-4389-b3b2-2bcad0412f6c	07fcc7d5-808c-42b0-b2ab-ffde146987ac	b67e88f5-4e1c-45b3-9e1a-52d922be3470	0	1462.56	\N
9beaa1d3-1e66-4103-8103-95e4a7992a69	4ca75372-0ac2-477c-95c6-73fccef02de6	b67e88f5-4e1c-45b3-9e1a-52d922be3470	10000	0	877824
01d70260-0ac9-4b87-942b-abd784ac3391	4ca75372-0ac2-477c-95c6-73fccef02de6	b22da86d-a963-4cba-916c-af63a51491d0	0	10000	877824
be00e467-1f3d-4a28-a15a-15c6d7ac7cb8	27704642-909a-44e5-b479-154f3957b57b	b22da86d-a963-4cba-916c-af63a51491d0	88	0	TRF
f3d38961-8d37-4943-83c4-ade14a97e259	27704642-909a-44e5-b479-154f3957b57b	b67e88f5-4e1c-45b3-9e1a-52d922be3470	0	88	TRF
cf294c9f-152c-4d00-b761-7b21ff1ee00c	6531e19f-2f5a-4dfe-b36d-6ce8fc16e6a6	97048dbc-5f9d-4ac4-961a-76ea11ae416a	495	0	3370
77b8b0d6-6127-497b-8093-3e215fffcf83	6531e19f-2f5a-4dfe-b36d-6ce8fc16e6a6	b67e88f5-4e1c-45b3-9e1a-52d922be3470	0	495	3370
25a2307d-8823-42db-9bd0-eb35540b0c03	e9710257-41eb-4ead-ab25-4695e7e3734a	97048dbc-5f9d-4ac4-961a-76ea11ae416a	10068.8	0	1925
74f5e9cf-79d6-4305-9788-3853c6ca275d	e9710257-41eb-4ead-ab25-4695e7e3734a	b67e88f5-4e1c-45b3-9e1a-52d922be3470	0	10068.8	1925
ef4c51b9-0e0c-4c06-8fef-4c6903e90c5d	ecc763a6-7d5a-4aed-996a-5bc45fe4510a	97048dbc-5f9d-4ac4-961a-76ea11ae416a	910	0	93068
a876a5c4-8fac-4482-9b62-c0c3eb59b7ad	ecc763a6-7d5a-4aed-996a-5bc45fe4510a	b67e88f5-4e1c-45b3-9e1a-52d922be3470	0	910	93068
31429ada-1e77-4230-8636-c63e3cdbb4c5	10316b94-9981-4b66-8cbe-d66d7d9a4e3a	97048dbc-5f9d-4ac4-961a-76ea11ae416a	570	0	1663
004b6476-1f74-4aed-810a-1e49a1e24bb4	10316b94-9981-4b66-8cbe-d66d7d9a4e3a	b67e88f5-4e1c-45b3-9e1a-52d922be3470	0	570	1663
0a90ff87-8aa8-4d89-af31-7ca387a12040	a0acd0bb-eb31-42ed-82d8-90bf1069bfdb	97048dbc-5f9d-4ac4-961a-76ea11ae416a	1030	0	1662
70c48117-643c-4da7-a522-336f52fa8875	a0acd0bb-eb31-42ed-82d8-90bf1069bfdb	b67e88f5-4e1c-45b3-9e1a-52d922be3470	0	1030	1662
acb137dc-beac-4425-a2b3-9b4a12f0d104	b1d0c13c-b014-4d20-9b97-f936c956d005	4d329d98-68bb-4636-8f5b-0602eedd3eaa	2420	0	112202
e4d2f162-49f8-40d2-bb08-756a78d054de	b1d0c13c-b014-4d20-9b97-f936c956d005	b67e88f5-4e1c-45b3-9e1a-52d922be3470	0	2420	112202
65b2e471-0519-4e22-8e05-5ab06ba2cebd	23e6bb37-9735-4400-aa98-731474431e77	4d329d98-68bb-4636-8f5b-0602eedd3eaa	1296	0	120436
72acb771-09ac-4957-beb8-70be84fbf8ee	23e6bb37-9735-4400-aa98-731474431e77	b67e88f5-4e1c-45b3-9e1a-52d922be3470	0	1296	120436
66f6b622-e276-4d67-aee3-dc4c1505221f	8b47f37a-f5f0-4530-b300-2a30a24b0ff1	97048dbc-5f9d-4ac4-961a-76ea11ae416a	10500	0	3285
7d7711f7-3e9c-4f65-89e6-6457573716c8	8b47f37a-f5f0-4530-b300-2a30a24b0ff1	b67e88f5-4e1c-45b3-9e1a-52d922be3470	0	10500	3285
2ad4037b-6a9f-4e24-ab22-423db59fdcaf	39865c69-516c-4338-b73d-06b0c1e32c8e	b67e88f5-4e1c-45b3-9e1a-52d922be3470	18889.39	0	8777827
11ccc66a-393a-42b9-bb1e-c7a3a659e361	39865c69-516c-4338-b73d-06b0c1e32c8e	b22da86d-a963-4cba-916c-af63a51491d0	0	18889.39	8777827
dc95c495-3522-4f32-bc1b-01ac081b07f1	2a1f257c-8d4d-4196-8377-6a40ec407a97	97048dbc-5f9d-4ac4-961a-76ea11ae416a	495	0	3432
6021991d-1ce6-43bf-ae6a-8f1781ceb802	2a1f257c-8d4d-4196-8377-6a40ec407a97	b67e88f5-4e1c-45b3-9e1a-52d922be3470	0	495	3432
487cc99d-a681-4a30-9d78-eeabb5a43c57	70fd627c-004b-45ae-bf35-4c671b85f50c	4f036481-e176-460a-8cf6-557ce9308c49	177398.49	0	5001016048
d32afe1f-8213-4740-8575-b1fd24e6030f	70fd627c-004b-45ae-bf35-4c671b85f50c	c096aa8f-fd2f-4a1f-8c61-7b9dee4df4ab	0	177398.49	5001016048
86237aa6-8135-4c35-b712-bb5cce388f58	79331021-4d46-49a0-9d0b-1cf020bd37e0	4f036481-e176-460a-8cf6-557ce9308c49	443048.49	0	TRF
59e28b63-cb13-446f-b3de-a1732f3d653d	79331021-4d46-49a0-9d0b-1cf020bd37e0	c096aa8f-fd2f-4a1f-8c61-7b9dee4df4ab	0	443048.49	TRF
0594690d-3cb3-4300-b570-dc8a89e42245	0600d3c9-36c6-4ecb-8dd2-027753aac341	4f036481-e176-460a-8cf6-557ce9308c49	441628.25	0	569405
c1d18238-2b41-4746-a901-4fc2f982bb20	0600d3c9-36c6-4ecb-8dd2-027753aac341	c096aa8f-fd2f-4a1f-8c61-7b9dee4df4ab	0	441628.25	569405
eca9495f-9c56-4d62-89a9-68746e2976d1	c3bf3303-2f6c-47d8-a2c3-f13ff33f779d	4f036481-e176-460a-8cf6-557ce9308c49	673628.25	0	DEP
b901f348-3050-4deb-9b74-5fb6e034412f	c3bf3303-2f6c-47d8-a2c3-f13ff33f779d	c096aa8f-fd2f-4a1f-8c61-7b9dee4df4ab	0	673628.25	DEP
cf613109-fa4f-46f1-8931-ef7d46f65cc6	765cb5dd-85c3-45c2-90fc-e9270c6f7712	4f036481-e176-460a-8cf6-557ce9308c49	955378.25	0	DEP
8abb2862-5972-44e2-8b97-01ae34a5643b	765cb5dd-85c3-45c2-90fc-e9270c6f7712	c096aa8f-fd2f-4a1f-8c61-7b9dee4df4ab	0	955378.25	DEP
40c027b1-663a-450e-99d4-6308ba0d63df	000ac3b5-39fc-4462-9010-d16337c184cf	4f036481-e176-460a-8cf6-557ce9308c49	1390378.25	0	DEP
01b94574-162b-4628-aa45-5084f7cde6ab	000ac3b5-39fc-4462-9010-d16337c184cf	c096aa8f-fd2f-4a1f-8c61-7b9dee4df4ab	0	1390378.25	DEP
84ba5bc8-be4e-465e-87e6-a253f89d4443	f1b45e9f-53a2-484d-a650-e79aff9c6c42	4f036481-e176-460a-8cf6-557ce9308c49	1387878.25	0	TRF
da1a1381-4b8a-4b45-9be7-d795b1f754b8	f1b45e9f-53a2-484d-a650-e79aff9c6c42	c096aa8f-fd2f-4a1f-8c61-7b9dee4df4ab	0	1387878.25	TRF
a693f339-deac-4c90-b290-0c930f195097	e0999dc2-0f69-45f6-9472-574cbb9f7531	4f036481-e176-460a-8cf6-557ce9308c49	1387871.25	0	TRF
7d1c5dfe-885d-4770-9f4e-0df41cbac461	e0999dc2-0f69-45f6-9472-574cbb9f7531	c096aa8f-fd2f-4a1f-8c61-7b9dee4df4ab	0	1387871.25	TRF
af940239-ae17-4104-bc59-e858a21ce415	75940ed7-f4a9-42d1-a6d0-795705d337d2	4f036481-e176-460a-8cf6-557ce9308c49	1241131.25	0	TRF
ebe22d45-22dc-4aba-90c8-4fcb3e7cf736	75940ed7-f4a9-42d1-a6d0-795705d337d2	c096aa8f-fd2f-4a1f-8c61-7b9dee4df4ab	0	1241131.25	TRF
4dbd49bd-ed55-47e1-bce2-f54fd36dbd52	be4477af-4051-41f8-93d6-21e62f8b194c	4f036481-e176-460a-8cf6-557ce9308c49	1241124.25	0	TRF
45e390ba-9a47-414e-b2a9-62f3b5f7afca	be4477af-4051-41f8-93d6-21e62f8b194c	c096aa8f-fd2f-4a1f-8c61-7b9dee4df4ab	0	1241124.25	TRF
0a514ac1-deea-47ac-8792-6997087f5a29	fb49ab78-f71b-402b-8d2e-78d4e91f8b40	4f036481-e176-460a-8cf6-557ce9308c49	1163273.09	0	57037750173
0519c3b4-371a-4adb-a045-c1e855e0a464	fb49ab78-f71b-402b-8d2e-78d4e91f8b40	c096aa8f-fd2f-4a1f-8c61-7b9dee4df4ab	0	1163273.09	57037750173
92d67c2e-6206-41ae-91f4-f4bddb14acc8	54b5739e-f566-41c3-92a7-a6acf5680fc8	4f036481-e176-460a-8cf6-557ce9308c49	1163266.09	0	TRF
e145d29a-1cd6-4689-9674-e1c1aab5acc4	54b5739e-f566-41c3-92a7-a6acf5680fc8	c096aa8f-fd2f-4a1f-8c61-7b9dee4df4ab	0	1163266.09	TRF
3fc83cdc-8f3c-4467-8cf6-6622fa6bd991	35f00013-d1c8-4dbc-b7c7-aa2b16efb0a5	4f036481-e176-460a-8cf6-557ce9308c49	1160266.09	0	TRF
ed9fb4f2-5299-430d-8536-0e3818986512	35f00013-d1c8-4dbc-b7c7-aa2b16efb0a5	c096aa8f-fd2f-4a1f-8c61-7b9dee4df4ab	0	1160266.09	TRF
d039e80d-1a0c-47ae-a197-7bb683c7a006	cd1d3182-048a-4074-8e5a-2dbb91249b81	4f036481-e176-460a-8cf6-557ce9308c49	1160259.09	0	TRF
415637a3-9d18-4a3a-89ac-8332c296d5b0	cd1d3182-048a-4074-8e5a-2dbb91249b81	c096aa8f-fd2f-4a1f-8c61-7b9dee4df4ab	0	1160259.09	TRF
caf21e8f-3aa6-4ee3-a27b-9bd9946f8cd9	d6726456-acb9-4b97-a919-0900981c5805	4f036481-e176-460a-8cf6-557ce9308c49	1158759.09	0	TRF
a3f791a6-f405-49a2-8b29-753df466b29b	d6726456-acb9-4b97-a919-0900981c5805	c096aa8f-fd2f-4a1f-8c61-7b9dee4df4ab	0	1158759.09	TRF
4994b309-d38d-4bbf-a4a4-c8d60b12cded	5cf1be23-2f20-4697-88f8-f811c0d0bffa	4f036481-e176-460a-8cf6-557ce9308c49	1158752.09	0	TRF
c7ecdc3c-fac4-4c76-9fe0-fc2411943fd9	5cf1be23-2f20-4697-88f8-f811c0d0bffa	c096aa8f-fd2f-4a1f-8c61-7b9dee4df4ab	0	1158752.09	TRF
061309b7-6fd8-4bbe-a20a-5ce40e37265b	5ee4e0ac-511e-4586-8d01-ce3c1528719f	4f036481-e176-460a-8cf6-557ce9308c49	1121366.29	0	38316
de0c3088-9aa5-402f-91a7-9eb8cc4ed427	5ee4e0ac-511e-4586-8d01-ce3c1528719f	c096aa8f-fd2f-4a1f-8c61-7b9dee4df4ab	0	1121366.29	38316
dc863e2b-6d2f-4436-b1f7-859902ac435e	e1b7baff-b6ee-485d-bf1a-81a794e6953f	4f036481-e176-460a-8cf6-557ce9308c49	1121359.29	0	TRF
1d2acd89-e53f-4125-9e73-488be700547c	e1b7baff-b6ee-485d-bf1a-81a794e6953f	c096aa8f-fd2f-4a1f-8c61-7b9dee4df4ab	0	1121359.29	TRF
d9a433c3-89b2-4031-bbe4-0478ba20c7d8	6d1cb34f-e2be-4697-bfc7-98c07c6ad1d0	4f036481-e176-460a-8cf6-557ce9308c49	1119859.29	0	2723
2c9e4309-0b06-4a94-af62-6d1771792c19	6d1cb34f-e2be-4697-bfc7-98c07c6ad1d0	c096aa8f-fd2f-4a1f-8c61-7b9dee4df4ab	0	1119859.29	2723
8b90f3f9-c5dd-4272-a7c8-685fa0d23a7e	97ada1a5-72f7-4c00-8ca6-b3ee53eb19c6	4f036481-e176-460a-8cf6-557ce9308c49	1119852.29	0	TRF
d6f6cba5-2bbd-4a36-9b25-33816bc58981	97ada1a5-72f7-4c00-8ca6-b3ee53eb19c6	c096aa8f-fd2f-4a1f-8c61-7b9dee4df4ab	0	1119852.29	TRF
1da05335-2d0e-4608-97cb-58ae893775c5	946100f1-b70e-46c2-a360-c8a15b6c55ca	4f036481-e176-460a-8cf6-557ce9308c49	1118814.9000000001	0	7240
6f954fab-34f9-4f46-90c0-4e9de3441c1b	946100f1-b70e-46c2-a360-c8a15b6c55ca	c096aa8f-fd2f-4a1f-8c61-7b9dee4df4ab	0	1118814.9000000001	7240
8e42790a-76b0-4fff-83c5-9d899b629090	7014c22f-55bb-4f2a-afff-6ea3dd6444f1	4f036481-e176-460a-8cf6-557ce9308c49	1108814.9000000001	0	877824
c5ac3611-f170-48f3-97f1-1e5559708094	7014c22f-55bb-4f2a-afff-6ea3dd6444f1	c096aa8f-fd2f-4a1f-8c61-7b9dee4df4ab	0	1108814.9000000001	877824
34de18b0-962c-4ac8-8a6c-392e944baa08	cdf7b4be-d6d3-43f2-935d-5a876645ab76	4f036481-e176-460a-8cf6-557ce9308c49	793638.3200000001	0	TRF
9afa6f04-dc9f-4d5e-b5fb-138b579203cc	cdf7b4be-d6d3-43f2-935d-5a876645ab76	c096aa8f-fd2f-4a1f-8c61-7b9dee4df4ab	0	793638.3200000001	TRF
61624182-53df-4b49-8d02-a5964dba728a	91e083e4-0fcd-4f7e-922a-7eb7a0b2fab0	4f036481-e176-460a-8cf6-557ce9308c49	793381.3200000001	0	TRF
187cbaef-eea2-4f69-a543-78230671ad0b	91e083e4-0fcd-4f7e-922a-7eb7a0b2fab0	c096aa8f-fd2f-4a1f-8c61-7b9dee4df4ab	0	793381.3200000001	TRF
08d18def-1a91-4490-885c-09bc408413a6	bf963a0b-96e2-48f0-90d7-1f628d008bd7	4f036481-e176-460a-8cf6-557ce9308c49	781381.3200000001	0	877825
d7b2e214-83c5-43df-9603-f010371a5bcc	bf963a0b-96e2-48f0-90d7-1f628d008bd7	c096aa8f-fd2f-4a1f-8c61-7b9dee4df4ab	0	781381.3200000001	877825
98140f29-1b67-4f0b-b913-64ffad5347ff	d34d3265-ad07-44af-a01e-4bea665cbb75	4f036481-e176-460a-8cf6-557ce9308c49	770943.8200000001	0	FINANCE
b1855241-8d81-474c-a5c9-ae0b621c4a6f	d34d3265-ad07-44af-a01e-4bea665cbb75	c096aa8f-fd2f-4a1f-8c61-7b9dee4df4ab	0	770943.8200000001	FINANCE
c3a1115b-727b-4acb-8283-2eb138e6401d	d56967b6-2cd6-4df0-86f2-49041a33b295	4f036481-e176-460a-8cf6-557ce9308c49	746690.7100000001	0	\N
c971728d-29a3-4a0d-aa5d-3452eecc51c2	d56967b6-2cd6-4df0-86f2-49041a33b295	c096aa8f-fd2f-4a1f-8c61-7b9dee4df4ab	0	746690.7100000001	\N
d77fcb87-5277-4960-99d4-7097def1e485	3465b09f-4950-4ebb-87d8-65f3e8392bc8	4f036481-e176-460a-8cf6-557ce9308c49	746166.7100000001	0	7227
3cd5630f-8456-4ac9-8abc-3c04bad0284a	3465b09f-4950-4ebb-87d8-65f3e8392bc8	c096aa8f-fd2f-4a1f-8c61-7b9dee4df4ab	0	746166.7100000001	7227
05b324d8-b43c-4dce-b998-faed7551c335	43cf3d37-0f70-4a82-9dda-b013ca1b9716	4f036481-e176-460a-8cf6-557ce9308c49	741333.56	0	5001017192
c70a44df-3075-473c-b7f0-556280d7cef2	43cf3d37-0f70-4a82-9dda-b013ca1b9716	c096aa8f-fd2f-4a1f-8c61-7b9dee4df4ab	0	741333.56	5001017192
dee67074-2368-4ef2-813c-d12e39a9080a	8973a91d-0d6e-4210-9b77-8892cba4ca6b	4f036481-e176-460a-8cf6-557ce9308c49	741326.56	0	TRF
b3e16949-ca52-4d61-9cab-60701c27097e	8973a91d-0d6e-4210-9b77-8892cba4ca6b	c096aa8f-fd2f-4a1f-8c61-7b9dee4df4ab	0	741326.56	TRF
28619648-2b70-4545-a165-60974da0a9db	65c4b1bb-39f2-4170-b8b2-e23a33fb7038	4f036481-e176-460a-8cf6-557ce9308c49	739301.56	0	214671
2e227a17-9e74-4cc9-abd6-305f2fbd2fed	65c4b1bb-39f2-4170-b8b2-e23a33fb7038	c096aa8f-fd2f-4a1f-8c61-7b9dee4df4ab	0	739301.56	214671
d10d8a1d-17ca-4639-9809-5eb710777906	efc2c4b7-0a89-4a43-b266-1c06cd9bae41	4f036481-e176-460a-8cf6-557ce9308c49	738401.56	0	17056
d3cba5a8-8441-4e79-b1ee-bb2dbb40ad58	efc2c4b7-0a89-4a43-b266-1c06cd9bae41	c096aa8f-fd2f-4a1f-8c61-7b9dee4df4ab	0	738401.56	17056
cfaeef12-7058-4036-b00e-bc0ffde910be	391f802b-17ab-473c-bb7c-2b061c586e64	4f036481-e176-460a-8cf6-557ce9308c49	727414.3600000001	0	TRF
bca05626-092f-49f0-bdf5-784272f8c06d	391f802b-17ab-473c-bb7c-2b061c586e64	c096aa8f-fd2f-4a1f-8c61-7b9dee4df4ab	0	727414.3600000001	TRF
77b3ac84-f7bd-4494-8056-e80b69961954	cba364bf-a1a8-4915-be44-2c7ab945da74	4f036481-e176-460a-8cf6-557ce9308c49	727407.3600000001	0	TRF
30f78a3d-6b80-43d4-ac65-bf21c94d1138	cba364bf-a1a8-4915-be44-2c7ab945da74	c096aa8f-fd2f-4a1f-8c61-7b9dee4df4ab	0	727407.3600000001	TRF
d0496f92-1465-4071-bef5-60ed3faf0033	ff454c16-ce08-4aca-adef-93c935c4e28b	4f036481-e176-460a-8cf6-557ce9308c49	726502.3600000001	0	214
5fd64678-3e42-41f0-9909-ffa7b69a4220	ff454c16-ce08-4aca-adef-93c935c4e28b	c096aa8f-fd2f-4a1f-8c61-7b9dee4df4ab	0	726502.3600000001	214
34ef1420-7ff4-4138-8fc7-b675d4386e99	1e2ace5c-a3e5-43bf-9acc-af49524f1acf	4f036481-e176-460a-8cf6-557ce9308c49	724982.7600000001	0	879
6cef8f9e-4da6-458a-a83f-faffe1ab6d50	1e2ace5c-a3e5-43bf-9acc-af49524f1acf	c096aa8f-fd2f-4a1f-8c61-7b9dee4df4ab	0	724982.7600000001	879
a01a529a-e4b3-4523-8145-502ce25c2a0f	f143bfe6-be25-4e61-8dc5-1c28008e7b42	4f036481-e176-460a-8cf6-557ce9308c49	724975.7600000001	0	TRF
a97f2cc3-a585-49b2-9342-9c2e7b435fb3	f143bfe6-be25-4e61-8dc5-1c28008e7b42	c096aa8f-fd2f-4a1f-8c61-7b9dee4df4ab	0	724975.7600000001	TRF
5a949de2-10f9-42ad-9574-d22a0659abd6	5886c69c-618e-4fee-9fb7-3af3b55a4b76	4f036481-e176-460a-8cf6-557ce9308c49	723975.7600000001	0	TRF
38250fef-85b7-4c38-9f37-257e83d2183e	5886c69c-618e-4fee-9fb7-3af3b55a4b76	c096aa8f-fd2f-4a1f-8c61-7b9dee4df4ab	0	723975.7600000001	TRF
20526540-7cdf-4236-a0ab-39e84dd72f9e	502f3c4d-149a-4c9c-9707-b9d5e4e23d89	4f036481-e176-460a-8cf6-557ce9308c49	723968.7600000001	0	TRF
3e7960eb-1539-4629-93aa-32113b26a7ac	502f3c4d-149a-4c9c-9707-b9d5e4e23d89	c096aa8f-fd2f-4a1f-8c61-7b9dee4df4ab	0	723968.7600000001	TRF
ef1941f1-e2e4-489a-8e55-26d81e2ee740	981f8824-7235-46e1-805b-2771ee1d9388	4f036481-e176-460a-8cf6-557ce9308c49	720504.0300000001	0	TRF
d1b3c41e-e1b1-4458-a518-e10d4eae407d	981f8824-7235-46e1-805b-2771ee1d9388	c096aa8f-fd2f-4a1f-8c61-7b9dee4df4ab	0	720504.0300000001	TRF
bc24ff7e-fead-44b2-a76b-336ce20730fb	09a04e9a-bb52-400b-a00e-09b0398482fe	4f036481-e176-460a-8cf6-557ce9308c49	720497.0300000001	0	TRF
beb910fa-8ec0-4b2e-95a4-bc595a498d0c	09a04e9a-bb52-400b-a00e-09b0398482fe	c096aa8f-fd2f-4a1f-8c61-7b9dee4df4ab	0	720497.0300000001	TRF
c75ee8e7-eb71-44dc-94fa-175809827c96	cfed887c-99fc-42b4-85ee-021fc233d0b1	4f036481-e176-460a-8cf6-557ce9308c49	716997.0300000001	0	TRF
616022a5-0658-4577-9bdb-5851c92282bc	cfed887c-99fc-42b4-85ee-021fc233d0b1	c096aa8f-fd2f-4a1f-8c61-7b9dee4df4ab	0	716997.0300000001	TRF
ec71c984-1576-4193-a15a-2a91de8e4637	91d7b864-ee32-427b-9dc8-7834c27a1251	4f036481-e176-460a-8cf6-557ce9308c49	716990.0300000001	0	TRF
6d3cdd2c-00fe-48e7-a440-7f0f9eac5c2b	91d7b864-ee32-427b-9dc8-7834c27a1251	c096aa8f-fd2f-4a1f-8c61-7b9dee4df4ab	0	716990.0300000001	TRF
454c00be-ef7d-48d4-8a9f-2f10cbf0b1f6	c38e7aa7-cfbd-4601-baf5-bb579eaa8fe1	4f036481-e176-460a-8cf6-557ce9308c49	658565.5400000002	0	57037750285
3d21be08-d6ba-4972-a5d1-83e0f22c1e4f	c38e7aa7-cfbd-4601-baf5-bb579eaa8fe1	c096aa8f-fd2f-4a1f-8c61-7b9dee4df4ab	0	658565.5400000002	57037750285
a7299853-47c5-4706-a414-623f9cac4215	fd1227e0-60ac-4e62-9514-5122cf716093	4f036481-e176-460a-8cf6-557ce9308c49	658558.5400000002	0	TRF
ec0cf5ab-6a3c-4f28-b077-504d24f230f0	fd1227e0-60ac-4e62-9514-5122cf716093	c096aa8f-fd2f-4a1f-8c61-7b9dee4df4ab	0	658558.5400000002	TRF
e6c1cbda-300a-4192-85fc-c4d6548ea83e	de83df3b-b1fa-44ba-b72e-a967c4d1b882	4f036481-e176-460a-8cf6-557ce9308c49	654295.5400000002	0	11752
e2b04a3a-f0bf-436d-ae7e-285929def9a3	de83df3b-b1fa-44ba-b72e-a967c4d1b882	c096aa8f-fd2f-4a1f-8c61-7b9dee4df4ab	0	654295.5400000002	11752
738ba1ca-49a9-49fd-b6bf-b01e6554b76c	5ee9b19f-5766-44fd-a8f8-d1eb6232d9bf	4f036481-e176-460a-8cf6-557ce9308c49	653795.5400000002	0	TRF
a22bb657-4fb8-43a7-91bb-0c1a0ba144cb	5ee9b19f-5766-44fd-a8f8-d1eb6232d9bf	c096aa8f-fd2f-4a1f-8c61-7b9dee4df4ab	0	653795.5400000002	TRF
ee16d1e3-0cdb-4765-88b0-f6a177efcb04	7873473c-8023-4faf-9a46-33f8eb60d099	4f036481-e176-460a-8cf6-557ce9308c49	653788.5400000002	0	TRF
9ad7ba3b-90e7-4ac1-a90d-14c40835d614	7873473c-8023-4faf-9a46-33f8eb60d099	c096aa8f-fd2f-4a1f-8c61-7b9dee4df4ab	0	653788.5400000002	TRF
4aed66b0-3e88-4f30-b927-409f6ab4b8b9	20b81470-5381-44ff-9d1c-572ccb9e9a6e	4f036481-e176-460a-8cf6-557ce9308c49	616401.7400000001	0	38484
d259f891-11f5-4074-873d-7df6e018b622	20b81470-5381-44ff-9d1c-572ccb9e9a6e	c096aa8f-fd2f-4a1f-8c61-7b9dee4df4ab	0	616401.7400000001	38484
f8911e99-4e18-4961-a8b0-ada1258c60cd	17c5d250-be5e-4297-9e3a-7f5545f96956	4f036481-e176-460a-8cf6-557ce9308c49	616394.7400000001	0	TRF
7326ceba-df62-4b4d-a128-8bafcf1429c1	17c5d250-be5e-4297-9e3a-7f5545f96956	c096aa8f-fd2f-4a1f-8c61-7b9dee4df4ab	0	616394.7400000001	TRF
f1d0fe66-5eb1-4737-9f5c-e1bb49454001	d4a496b6-edde-40c3-b919-8fe088775ef9	4f036481-e176-460a-8cf6-557ce9308c49	469654.7400000001	0	429
6ebdb464-52d5-4d1e-ac05-de62a08ab69e	d4a496b6-edde-40c3-b919-8fe088775ef9	c096aa8f-fd2f-4a1f-8c61-7b9dee4df4ab	0	469654.7400000001	429
8fe181ae-51c6-4177-a16a-b301b8530eb5	80e0da88-1dfd-4e95-82b1-55f9c4051d13	4f036481-e176-460a-8cf6-557ce9308c49	469647.7400000001	0	TRF
62be8ca5-72b6-422d-ade1-f97bf3d96c6a	80e0da88-1dfd-4e95-82b1-55f9c4051d13	c096aa8f-fd2f-4a1f-8c61-7b9dee4df4ab	0	469647.7400000001	TRF
0352e469-5b52-4fd9-b3c4-42a81c031587	fc2c9050-aecf-4211-a70d-807c3586d4a6	4f036481-e176-460a-8cf6-557ce9308c49	465177.1300000001	0	1400001604
3327124c-791a-4d9e-ab61-dedfe256257d	fc2c9050-aecf-4211-a70d-807c3586d4a6	c096aa8f-fd2f-4a1f-8c61-7b9dee4df4ab	0	465177.1300000001	1400001604
3a50dad2-4d8e-4ae5-9426-dc488a27abbc	32c9a1aa-9be1-42f9-bac8-26ef5e537d07	4f036481-e176-460a-8cf6-557ce9308c49	465170.1300000001	0	Trf
1f514ccd-95fa-4d2c-892a-2c020dba6d14	32c9a1aa-9be1-42f9-bac8-26ef5e537d07	c096aa8f-fd2f-4a1f-8c61-7b9dee4df4ab	0	465170.1300000001	Trf
a5b54253-735d-4911-8608-3d5661126fe1	21fbe376-3ee2-42a3-aec2-0f2235b8480e	4f036481-e176-460a-8cf6-557ce9308c49	444382.9300000001	0	1930
60aa9350-bf68-448b-b7a1-f7e3688e76bc	21fbe376-3ee2-42a3-aec2-0f2235b8480e	c096aa8f-fd2f-4a1f-8c61-7b9dee4df4ab	0	444382.9300000001	1930
c96b9ce4-28c7-45f4-af06-7a0dd598188a	06d92fad-acfa-43dd-89f3-dbd9a08ec7f3	4f036481-e176-460a-8cf6-557ce9308c49	444262.9300000001	0	TRF
a4df9625-00a3-4d83-b90a-2763e178f107	06d92fad-acfa-43dd-89f3-dbd9a08ec7f3	c096aa8f-fd2f-4a1f-8c61-7b9dee4df4ab	0	444262.9300000001	TRF
084e4974-144d-4ba7-90bf-bff15a8204ed	d8697e6b-4106-403a-97ae-d60c735c9309	4f036481-e176-460a-8cf6-557ce9308c49	442853.2500000001	0	TRF
1390ae91-b3e7-4e6a-8916-53355f449d78	d8697e6b-4106-403a-97ae-d60c735c9309	c096aa8f-fd2f-4a1f-8c61-7b9dee4df4ab	0	442853.2500000001	TRF
b96e70ea-26f7-42ce-908e-1c98854456dc	5aa5e6df-6ece-468f-ac97-11bcba65dcc7	4f036481-e176-460a-8cf6-557ce9308c49	421294.65000000014	0	2627
9bca2137-1d2b-42a5-8dbe-c24f2ac6cc7a	5aa5e6df-6ece-468f-ac97-11bcba65dcc7	c096aa8f-fd2f-4a1f-8c61-7b9dee4df4ab	0	421294.65000000014	2627
6a5f5785-2454-4e7a-839b-2ce13e2b31e1	6b13853a-4a3c-49d2-81d1-1ef14423c87e	4f036481-e176-460a-8cf6-557ce9308c49	421287.65000000014	0	TRF
f547f525-a1d3-48ef-8367-4ea23747aa96	6b13853a-4a3c-49d2-81d1-1ef14423c87e	c096aa8f-fd2f-4a1f-8c61-7b9dee4df4ab	0	421287.65000000014	TRF
670a0e0f-47e2-4fa6-9894-ce4d67f193db	46bfdfef-a019-48db-a3be-0ca3218145d9	4f036481-e176-460a-8cf6-557ce9308c49	611037.6500000001	0	TRF
86821819-7f94-4ef8-a17e-4fddfd9bb40d	46bfdfef-a019-48db-a3be-0ca3218145d9	c096aa8f-fd2f-4a1f-8c61-7b9dee4df4ab	0	611037.6500000001	TRF
0e000704-6774-44ca-85b1-838cc0dfbe66	1b4a834b-25d2-44a2-9037-811891ee2ad0	4f036481-e176-460a-8cf6-557ce9308c49	300285.39000000013	0	TRF
d6c8bc4f-728c-4ee3-8aba-5e447b6a1da6	1b4a834b-25d2-44a2-9037-811891ee2ad0	c096aa8f-fd2f-4a1f-8c61-7b9dee4df4ab	0	300285.39000000013	TRF
0f5f6679-1343-4a86-8b31-70323e8d4489	14653821-431b-4fef-85dd-d577f5eaf851	4f036481-e176-460a-8cf6-557ce9308c49	300031.39000000013	0	TRF
f1ffde61-6a24-4e9a-aa5f-fbd12998d7e8	14653821-431b-4fef-85dd-d577f5eaf851	c096aa8f-fd2f-4a1f-8c61-7b9dee4df4ab	0	300031.39000000013	TRF
5cba07ec-7ae9-414b-9bb0-4549d6dbfe35	e77c5672-e6c9-4a9a-ba1e-9cdfe912482e	4f036481-e176-460a-8cf6-557ce9308c49	299276.39000000013	0	7823
f1f0bf9b-9ea3-49d9-92ef-b7308ffb467c	e77c5672-e6c9-4a9a-ba1e-9cdfe912482e	c096aa8f-fd2f-4a1f-8c61-7b9dee4df4ab	0	299276.39000000013	7823
e731909f-8564-4ed7-b8da-3dcbd0625c7c	66ddeba1-baac-4466-af59-6de23a2b2a2d	4f036481-e176-460a-8cf6-557ce9308c49	297811.39000000013	0	15928/911376
b2526b8f-b36a-4a05-973c-b329c33c6f9d	66ddeba1-baac-4466-af59-6de23a2b2a2d	c096aa8f-fd2f-4a1f-8c61-7b9dee4df4ab	0	297811.39000000013	15928/911376
d7d6a594-bf92-4fc3-bd5b-6e2001ad41ca	c6991e6a-040a-4d96-b1bf-7b27f4e02d48	4f036481-e176-460a-8cf6-557ce9308c49	296561.39000000013	0	1/215423
7eab0528-050f-4031-b1e3-e7714c63b13f	c6991e6a-040a-4d96-b1bf-7b27f4e02d48	c096aa8f-fd2f-4a1f-8c61-7b9dee4df4ab	0	296561.39000000013	1/215423
06dc2cdc-8118-4c8c-bc4f-2c2c15c01473	7788c766-2c49-47d9-ad8f-748250de87a8	4f036481-e176-460a-8cf6-557ce9308c49	293049.1300000001	0	\N
f3a47bf7-b9df-4552-8a23-55ad61a49bd2	7788c766-2c49-47d9-ad8f-748250de87a8	c096aa8f-fd2f-4a1f-8c61-7b9dee4df4ab	0	293049.1300000001	\N
f9400c73-c428-49f9-81e1-fda66c9bf800	e0845c91-72f6-459d-8ed7-9cc5f84a584b	4f036481-e176-460a-8cf6-557ce9308c49	268463.3100000001	0	\N
5154236d-6cbe-4a81-923a-0975287d434f	e0845c91-72f6-459d-8ed7-9cc5f84a584b	c096aa8f-fd2f-4a1f-8c61-7b9dee4df4ab	0	268463.3100000001	\N
a2ce08ae-14e9-4800-8e4e-c08d74025cce	9b7e2f04-50b7-4d2a-8721-dd785de5f5f9	4f036481-e176-460a-8cf6-557ce9308c49	258025.8100000001	0	\N
7f036c0c-c83a-4a8c-90cd-a9ebb337b143	9b7e2f04-50b7-4d2a-8721-dd785de5f5f9	c096aa8f-fd2f-4a1f-8c61-7b9dee4df4ab	0	258025.8100000001	\N
8fb8ff9a-a357-4545-a700-d282c9ce6f77	34b31397-961e-4a11-980f-c25a09321d94	4f036481-e176-460a-8cf6-557ce9308c49	253025.81000000017	0	TRF
2da214c6-06f8-4ecf-b4b5-2151eb7a92e9	34b31397-961e-4a11-980f-c25a09321d94	c096aa8f-fd2f-4a1f-8c61-7b9dee4df4ab	0	253025.81000000017	TRF
d10c4ac5-e7e6-4822-a2f9-a1ca990852b1	34ee36ef-a06a-4a78-868b-2bfec8b8fcd2	4f036481-e176-460a-8cf6-557ce9308c49	253018.81000000017	0	TRF
ada36f0d-748d-4fce-9f7f-c215a4998166	34ee36ef-a06a-4a78-868b-2bfec8b8fcd2	c096aa8f-fd2f-4a1f-8c61-7b9dee4df4ab	0	253018.81000000017	TRF
a56fe69f-68fd-4268-9203-8e66df3ccfc2	e25f182e-e4ce-46ee-b9c1-f2a90e4b6a69	4f036481-e176-460a-8cf6-557ce9308c49	250718.81000000017	0	TRF
a02d26fb-a0f4-4328-8f4d-e195b314837b	e25f182e-e4ce-46ee-b9c1-f2a90e4b6a69	c096aa8f-fd2f-4a1f-8c61-7b9dee4df4ab	0	250718.81000000017	TRF
525accf3-154d-4130-a256-0fd8d385ee7e	7f271f15-1cda-4068-a121-c298843a98ad	4f036481-e176-460a-8cf6-557ce9308c49	250711.81000000017	0	TRF
fea468a2-87a3-441e-b260-333106bf7a87	7f271f15-1cda-4068-a121-c298843a98ad	c096aa8f-fd2f-4a1f-8c61-7b9dee4df4ab	0	250711.81000000017	TRF
d7281fc9-4a92-45af-a7a6-f56702250187	a44725e8-2b6e-4759-a36c-3e36cd9f067c	4f036481-e176-460a-8cf6-557ce9308c49	338755.8100000002	0	DEP
2caea851-cf9c-47a7-8243-e758dc6093c4	a44725e8-2b6e-4759-a36c-3e36cd9f067c	c096aa8f-fd2f-4a1f-8c61-7b9dee4df4ab	0	338755.8100000002	DEP
ef7e7af6-ddcb-4f2b-b0f2-84d66d0546b6	6f3edf0d-e0e7-4184-ba86-ec0f2ca5d038	4f036481-e176-460a-8cf6-557ce9308c49	337255.8100000002	0	TRF
1383cf94-ab59-487f-b15b-3e7e444256a9	6f3edf0d-e0e7-4184-ba86-ec0f2ca5d038	c096aa8f-fd2f-4a1f-8c61-7b9dee4df4ab	0	337255.8100000002	TRF
b0fd2d43-bcde-43e6-b82c-1d1879cf35cc	a4a013bc-18f0-4b6c-84b0-7272a510924c	4f036481-e176-460a-8cf6-557ce9308c49	337135.8100000002	0	TRF
5b8ff66b-42dd-4e4d-b793-092b346ca2c8	a4a013bc-18f0-4b6c-84b0-7272a510924c	c096aa8f-fd2f-4a1f-8c61-7b9dee4df4ab	0	337135.8100000002	TRF
e829741e-5509-4a1a-87ab-893027823bdd	8233fca7-afa2-47b9-bab5-e3a821593f90	4f036481-e176-460a-8cf6-557ce9308c49	333807.8100000002	0	6961
0dc44040-39d9-49c3-b55b-c81de6f4610c	8233fca7-afa2-47b9-bab5-e3a821593f90	c096aa8f-fd2f-4a1f-8c61-7b9dee4df4ab	0	333807.8100000002	6961
7ace60d1-5857-431d-b6a2-62d949465062	cc0e2d5a-65cd-481c-987d-7cac83a56b90	4f036481-e176-460a-8cf6-557ce9308c49	326423.4400000002	0	57438
c7bc0d70-8905-4338-8243-1bb560110b50	cc0e2d5a-65cd-481c-987d-7cac83a56b90	c096aa8f-fd2f-4a1f-8c61-7b9dee4df4ab	0	326423.4400000002	57438
3257d06b-0335-46af-8bc2-e9fbd5713b09	11777c0b-72b4-4165-9a92-6f5138d4a9d3	4f036481-e176-460a-8cf6-557ce9308c49	321178.4400000002	0	D/C
0bf66bb9-297b-43de-bf1b-58e68afb5ead	11777c0b-72b4-4165-9a92-6f5138d4a9d3	c096aa8f-fd2f-4a1f-8c61-7b9dee4df4ab	0	321178.4400000002	D/C
2b9832e4-ce1c-4992-93d0-eaf45c39b4f6	010bfffd-2984-48eb-b1b9-8456df13031f	4f036481-e176-460a-8cf6-557ce9308c49	321171.4400000002	0	TRF
b6f0868d-bb0b-44a7-816a-374d29173f80	010bfffd-2984-48eb-b1b9-8456df13031f	c096aa8f-fd2f-4a1f-8c61-7b9dee4df4ab	0	321171.4400000002	TRF
de89b48f-635b-4ac4-a73f-7650c86e2d75	7d5da831-1b34-49fe-83f2-fbdc1f1c0429	4f036481-e176-460a-8cf6-557ce9308c49	270059.5600000002	0	TRF
37786a5a-8d7e-4ecd-9fea-7b9bab2b1549	7d5da831-1b34-49fe-83f2-fbdc1f1c0429	c096aa8f-fd2f-4a1f-8c61-7b9dee4df4ab	0	270059.5600000002	TRF
66a14944-6e4b-45c9-a44f-76c36b59c4d7	b235ee0a-374b-4b37-bcf0-b172aee2e2ac	4f036481-e176-460a-8cf6-557ce9308c49	270052.5600000002	0	TRF
3e6baf29-b499-4367-9fdb-0f2bea8d035f	b235ee0a-374b-4b37-bcf0-b172aee2e2ac	c096aa8f-fd2f-4a1f-8c61-7b9dee4df4ab	0	270052.5600000002	TRF
5a081b77-6629-4932-b3fa-917fae936904	e76969e6-dd19-4d10-a78b-e339a0146b8c	4f036481-e176-460a-8cf6-557ce9308c49	269923.0700000002	0	TRF
b551112f-8b62-4460-b40f-2284f4258db4	e76969e6-dd19-4d10-a78b-e339a0146b8c	c096aa8f-fd2f-4a1f-8c61-7b9dee4df4ab	0	269923.0700000002	TRF
f8340a56-50f8-42d9-a5ce-e8f9a3bf56bf	10b47199-83a0-4106-90f3-29ea1f81f744	4f036481-e176-460a-8cf6-557ce9308c49	261213.07000000018	0	425/2026
60aa30aa-e01c-4be4-8085-51d6c1c77ba3	10b47199-83a0-4106-90f3-29ea1f81f744	c096aa8f-fd2f-4a1f-8c61-7b9dee4df4ab	0	261213.07000000018	425/2026
4cc4346f-40bb-4ce8-b18c-e48ed636dd1a	ff6b2260-d7de-4df3-8b72-110429e7d7cd	4f036481-e176-460a-8cf6-557ce9308c49	259923.07000000018	0	94962
41595a40-c399-4f8f-a18a-324769c95e31	ff6b2260-d7de-4df3-8b72-110429e7d7cd	c096aa8f-fd2f-4a1f-8c61-7b9dee4df4ab	0	259923.07000000018	94962
b7f86a14-31c6-448b-b374-062f7f3f7aa1	df97d337-15ba-472c-ba3a-76b9cb014bbf	4f036481-e176-460a-8cf6-557ce9308c49	259323.07000000018	0	TRF
9a979d9b-ed97-4349-9912-5cdfaed6dc49	df97d337-15ba-472c-ba3a-76b9cb014bbf	c096aa8f-fd2f-4a1f-8c61-7b9dee4df4ab	0	259323.07000000018	TRF
40668959-8c69-44cb-a834-901f5df1d1cf	d0e63759-9db1-491b-bca5-d5deae0877d2	4f036481-e176-460a-8cf6-557ce9308c49	221937.07000000018	0	38632
81f3f806-1d66-4900-90d4-ca29e297df89	d0e63759-9db1-491b-bca5-d5deae0877d2	c096aa8f-fd2f-4a1f-8c61-7b9dee4df4ab	0	221937.07000000018	38632
e58b4944-776a-4c19-b3ec-b798a16a850f	36cc4f2d-0976-42eb-a7ae-54b01b818b11	4f036481-e176-460a-8cf6-557ce9308c49	221930.07000000018	0	TRF
6c7c9166-ce29-478a-bf88-52b1b36ee0dd	36cc4f2d-0976-42eb-a7ae-54b01b818b11	c096aa8f-fd2f-4a1f-8c61-7b9dee4df4ab	0	221930.07000000018	TRF
d4f4b477-6b7f-4838-8515-fd1f3b888eb7	a29188f4-a4c9-40d3-8119-10ac33b8e02f	4f036481-e176-460a-8cf6-557ce9308c49	220520.3900000002	0	TRF
e763ce8d-2f90-4bfc-bd3f-1b1a79ca219a	a29188f4-a4c9-40d3-8119-10ac33b8e02f	c096aa8f-fd2f-4a1f-8c61-7b9dee4df4ab	0	220520.3900000002	TRF
0c480292-4742-4169-9255-e287aa69f009	7eb96e78-caab-4bca-bb4d-2408f6304895	4f036481-e176-460a-8cf6-557ce9308c49	219110.7100000002	0	TRF
a8b576bb-53c9-47ee-a192-95ca2e03e96b	7eb96e78-caab-4bca-bb4d-2408f6304895	c096aa8f-fd2f-4a1f-8c61-7b9dee4df4ab	0	219110.7100000002	TRF
dd6bd1b7-26ba-4eda-874f-193f755d5f47	b6fdac54-e129-42d0-9a54-180fcf8e9c1c	4f036481-e176-460a-8cf6-557ce9308c49	218322.7100000002	0	7231
5d447d6a-e095-4a58-900c-6d12b3b139e0	b6fdac54-e129-42d0-9a54-180fcf8e9c1c	c096aa8f-fd2f-4a1f-8c61-7b9dee4df4ab	0	218322.7100000002	7231
330c9dca-0899-41a5-b7b7-5825b94548ff	3251888f-71ea-464b-a509-a566e9bf1777	4f036481-e176-460a-8cf6-557ce9308c49	214992.7100000002	0	1745
f3d32238-54e1-445b-bf97-094bcd581496	3251888f-71ea-464b-a509-a566e9bf1777	c096aa8f-fd2f-4a1f-8c61-7b9dee4df4ab	0	214992.7100000002	1745
df6eef04-1b9d-44b8-9c29-86d7e75a790a	3ab25f78-42c1-48b2-be0e-87a736e93566	4f036481-e176-460a-8cf6-557ce9308c49	204492.7100000002	0	1/402
fc8bed9d-d0d8-43ed-8952-f9318b98ec00	3ab25f78-42c1-48b2-be0e-87a736e93566	c096aa8f-fd2f-4a1f-8c61-7b9dee4df4ab	0	204492.7100000002	1/402
4eed43f1-eff4-4a51-a34d-34928983ab5e	fa8933ad-a985-48ea-8621-ab8f5bc07ce7	4f036481-e176-460a-8cf6-557ce9308c49	198804.7100000002	0	1/215927
31b28346-7d09-4714-9dd0-1958cc5b9713	fa8933ad-a985-48ea-8621-ab8f5bc07ce7	c096aa8f-fd2f-4a1f-8c61-7b9dee4df4ab	0	198804.7100000002	1/215927
a79ee93f-4618-47c7-baed-9aea6c5b8663	c7475e43-861b-4afa-a9e0-54980b2ba538	4f036481-e176-460a-8cf6-557ce9308c49	198797.7100000002	0	TRF
c1cbdd21-593b-4ebd-8769-91319db1e6ba	c7475e43-861b-4afa-a9e0-54980b2ba538	c096aa8f-fd2f-4a1f-8c61-7b9dee4df4ab	0	198797.7100000002	TRF
58821d43-3733-4db5-a395-dcae4d192a52	c5de8ffe-c61d-4711-9cf9-e7d648a95496	4f036481-e176-460a-8cf6-557ce9308c49	515047.7100000002	0	TRF
5a89d877-8ad5-49f8-b7a8-130f311d2315	c5de8ffe-c61d-4711-9cf9-e7d648a95496	c096aa8f-fd2f-4a1f-8c61-7b9dee4df4ab	0	515047.7100000002	TRF
60dc5ada-cc4e-4c0e-b39a-eb0bb6c1bb77	46e0e21c-4f3b-4d18-8db4-d5d6bb4db62c	4f036481-e176-460a-8cf6-557ce9308c49	496158.3200000002	0	8777827
63a463cc-6452-4aa5-8ab7-0cd02f25612e	46e0e21c-4f3b-4d18-8db4-d5d6bb4db62c	c096aa8f-fd2f-4a1f-8c61-7b9dee4df4ab	0	496158.3200000002	8777827
2df8b69b-6339-4460-b9f0-dca1a5759473	b256a2ef-e123-448d-b1f3-2481e8004c0c	4f036481-e176-460a-8cf6-557ce9308c49	191068.4700000002	0	TRF
3aba8740-28eb-4a98-b6e3-5d187dc9d2b3	b256a2ef-e123-448d-b1f3-2481e8004c0c	c096aa8f-fd2f-4a1f-8c61-7b9dee4df4ab	0	191068.4700000002	TRF
30b35f90-aa8a-415f-a734-2f1df5c3ea8a	b8a61737-e3ce-42e1-a7ba-2102c671b1b7	4f036481-e176-460a-8cf6-557ce9308c49	190811.4700000002	0	TRF
672aaf6d-6354-43ea-9803-278609427dee	b8a61737-e3ce-42e1-a7ba-2102c671b1b7	c096aa8f-fd2f-4a1f-8c61-7b9dee4df4ab	0	190811.4700000002	TRF
b7b63139-bbcf-472d-b064-ce0a8ecaf66e	88e3f59d-eac2-4475-ba97-62b15bc4b89b	4f036481-e176-460a-8cf6-557ce9308c49	44071.470000000205	0	431
15857466-3a82-48f8-8d13-60ed8b2c600c	88e3f59d-eac2-4475-ba97-62b15bc4b89b	c096aa8f-fd2f-4a1f-8c61-7b9dee4df4ab	0	44071.470000000205	431
9e12173c-4faf-485f-adc9-24d65575600e	e17bbdc3-2371-4d7d-a9f0-741b24171179	4f036481-e176-460a-8cf6-557ce9308c49	82471.4700000002	0	F98
f2d25d14-c2f3-4c4c-b7af-52e491bc8c7f	e17bbdc3-2371-4d7d-a9f0-741b24171179	c096aa8f-fd2f-4a1f-8c61-7b9dee4df4ab	0	82471.4700000002	F98
15c1621e-49b7-44d4-af58-8c9b3b9d0701	9a21c0e1-8892-4c99-8c6c-8554b636ac43	4f036481-e176-460a-8cf6-557ce9308c49	81031.4700000002	0	24198
6b0b8865-f6c9-4aa9-bc23-139b0dff199e	9a21c0e1-8892-4c99-8c6c-8554b636ac43	c096aa8f-fd2f-4a1f-8c61-7b9dee4df4ab	0	81031.4700000002	24198
20a90b2e-8432-495c-a822-09a1a955095c	984a4b31-ee6e-48a9-b168-c46b26799de5	4f036481-e176-460a-8cf6-557ce9308c49	77651.71000000021	0	I/N
406f9438-c16b-4f90-98c1-758a993a7f77	984a4b31-ee6e-48a9-b168-c46b26799de5	c096aa8f-fd2f-4a1f-8c61-7b9dee4df4ab	0	77651.71000000021	I/N
4587cecc-2834-4c11-916c-4893859f2ba3	7d808c48-ef1b-4dbd-a9ee-94d05827516e	4f036481-e176-460a-8cf6-557ce9308c49	72221.71000000021	0	1765
2fb5bbe3-f41f-468c-98e0-34b95d0ccacf	7d808c48-ef1b-4dbd-a9ee-94d05827516e	c096aa8f-fd2f-4a1f-8c61-7b9dee4df4ab	0	72221.71000000021	1765
b25f33e7-ed59-4dc0-9c06-da86357fa367	bc6173fd-d346-4299-b1f3-5f0b095b8313	4f036481-e176-460a-8cf6-557ce9308c49	388471.7100000002	0	TRF
899108e6-f872-4201-888c-f906fcb63671	bc6173fd-d346-4299-b1f3-5f0b095b8313	c096aa8f-fd2f-4a1f-8c61-7b9dee4df4ab	0	388471.7100000002	TRF
d445c8f5-1a60-4782-918e-e29e13055cec	6666393d-ccf9-4cc6-9bc7-350302678215	4f036481-e176-460a-8cf6-557ce9308c49	335621.7100000002	0	TRF
4f2e098e-a527-4bf9-981a-52fe6186ceac	6666393d-ccf9-4cc6-9bc7-350302678215	c096aa8f-fd2f-4a1f-8c61-7b9dee4df4ab	0	335621.7100000002	TRF
81de3709-c813-4875-b344-f84e403d4ef8	e1c8e104-9893-437f-b100-b2c2878bfdb4	4f036481-e176-460a-8cf6-557ce9308c49	325321.7100000002	0	TRF
2397c32c-448d-4855-91d5-ea256dde7cae	e1c8e104-9893-437f-b100-b2c2878bfdb4	c096aa8f-fd2f-4a1f-8c61-7b9dee4df4ab	0	325321.7100000002	TRF
517bcae8-b8bd-40d1-8bdd-13b214c750c2	13529d6b-6eef-4604-9103-7eb4c1a2ee94	4f036481-e176-460a-8cf6-557ce9308c49	313041.7100000002	0	12801
e08e79b4-af08-4f76-9158-e56dc815d265	13529d6b-6eef-4604-9103-7eb4c1a2ee94	c096aa8f-fd2f-4a1f-8c61-7b9dee4df4ab	0	313041.7100000002	12801
a3e1794b-f789-4b1c-98f5-a24901fa3264	c3fd9a38-82bc-4e1a-8790-2e3c1011256c	4f036481-e176-460a-8cf6-557ce9308c49	311881.7100000002	0	1/4101
b232597c-2f52-4c71-9517-807ff9748b17	c3fd9a38-82bc-4e1a-8790-2e3c1011256c	c096aa8f-fd2f-4a1f-8c61-7b9dee4df4ab	0	311881.7100000002	1/4101
4340c4ce-38ce-4ed2-9bbc-ec20fe17142d	76616db5-2b14-43a8-9dff-4e86114fb78c	4f036481-e176-460a-8cf6-557ce9308c49	306496.6900000002	0	6192
2ebf0ff7-fae1-4f64-9eac-89772ff93d90	76616db5-2b14-43a8-9dff-4e86114fb78c	c096aa8f-fd2f-4a1f-8c61-7b9dee4df4ab	0	306496.6900000002	6192
018c15ca-ad8a-48ec-b1c7-8cfdeb31ddc0	4d289ed5-d6cb-429e-8d16-f01e7a10d54f	4f036481-e176-460a-8cf6-557ce9308c49	303203.9500000002	0	6196
73dda8f5-e179-4ac9-91e2-a7be67e93a4a	4d289ed5-d6cb-429e-8d16-f01e7a10d54f	c096aa8f-fd2f-4a1f-8c61-7b9dee4df4ab	0	303203.9500000002	6196
dda10990-b788-490d-9cb0-9c5e680df6f2	fff02efc-de6f-414c-80c7-618fc47174e7	4f036481-e176-460a-8cf6-557ce9308c49	279545.6400000002	0	TRF
1c241f08-f38d-41b4-9cef-7d22747ea5bb	fff02efc-de6f-414c-80c7-618fc47174e7	c096aa8f-fd2f-4a1f-8c61-7b9dee4df4ab	0	279545.6400000002	TRF
f0ddc961-411f-4c79-964c-fea4bd947c07	8a6794b5-adc2-4c13-9a45-0fec5a78ca1a	4f036481-e176-460a-8cf6-557ce9308c49	595795.6400000001	0	TRF
2cf81721-44b2-4130-bcba-b26584595a7f	8a6794b5-adc2-4c13-9a45-0fec5a78ca1a	c096aa8f-fd2f-4a1f-8c61-7b9dee4df4ab	0	595795.6400000001	TRF
6df86c88-0fa2-4822-a530-fa3a728c2f6e	a49ad381-5458-4f5d-bbf7-4a0738ffc3de	4f036481-e176-460a-8cf6-557ce9308c49	318622.9300000001	0	TRF
575439b6-863e-474a-8fa7-e46a676a2561	a49ad381-5458-4f5d-bbf7-4a0738ffc3de	c096aa8f-fd2f-4a1f-8c61-7b9dee4df4ab	0	318622.9300000001	TRF
30325137-c974-4589-a6fd-6cadb7325a7d	41731cf2-fc43-4e70-8727-840955acfc80	4f036481-e176-460a-8cf6-557ce9308c49	318502.9300000001	0	TRF
c954d7a6-218f-4e06-9d85-b230c50b3629	41731cf2-fc43-4e70-8727-840955acfc80	c096aa8f-fd2f-4a1f-8c61-7b9dee4df4ab	0	318502.9300000001	TRF
ef1918f0-0399-4581-8ba2-0eeb5199b3ca	52555a44-3783-4e15-bcd7-9b126144965f	4f036481-e176-460a-8cf6-557ce9308c49	288084.9500000001	0	TRF
0db9b205-e174-4eee-89bc-4d06cd9cbf71	52555a44-3783-4e15-bcd7-9b126144965f	c096aa8f-fd2f-4a1f-8c61-7b9dee4df4ab	0	288084.9500000001	TRF
5dc141bf-bb3d-4dd8-85bd-3f1597e9fbbf	27564a1f-af7a-4acb-a7ae-b2a4f42802db	4f036481-e176-460a-8cf6-557ce9308c49	287964.9500000001	0	TRF
d0af99ea-5994-4f9e-a6bc-56709eceb0bf	27564a1f-af7a-4acb-a7ae-b2a4f42802db	c096aa8f-fd2f-4a1f-8c61-7b9dee4df4ab	0	287964.9500000001	TRF
e8532a40-cdec-478c-ac68-85fdd65e716a	517adcce-ab93-40bb-ae30-eda57dfcba5e	4f036481-e176-460a-8cf6-557ce9308c49	284164.34000000014	0	5001021475
3f914401-239f-403f-93e6-833a2ff16888	517adcce-ab93-40bb-ae30-eda57dfcba5e	c096aa8f-fd2f-4a1f-8c61-7b9dee4df4ab	0	284164.34000000014	5001021475
0415a6c0-49f5-4ef9-9cfc-09466420d92c	8cf7cd1b-ca0f-447f-8ad4-30b8509a2578	4f036481-e176-460a-8cf6-557ce9308c49	282929.34000000014	0	96253
46c330f2-4ba6-45e3-9efd-ab557b0807f6	8cf7cd1b-ca0f-447f-8ad4-30b8509a2578	c096aa8f-fd2f-4a1f-8c61-7b9dee4df4ab	0	282929.34000000014	96253
39604339-e03c-406d-86a9-a9c2073ab281	63138b7e-f2fa-4368-afc2-55b19309aa3f	4f036481-e176-460a-8cf6-557ce9308c49	272491.84000000014	0	TRF
2f4ffb3a-5a5a-4eb0-8814-e4e0806752f7	63138b7e-f2fa-4368-afc2-55b19309aa3f	c096aa8f-fd2f-4a1f-8c61-7b9dee4df4ab	0	272491.84000000014	TRF
c092dfd7-13e0-4a64-ad81-00ca3d8b2617	119db070-9743-472c-b7fb-2f96b4d2ef9a	c096aa8f-fd2f-4a1f-8c61-7b9dee4df4ab	21000	0	\N
f5ed24d8-759f-473e-a510-3f28057175dc	119db070-9743-472c-b7fb-2f96b4d2ef9a	831219f9-e9dc-4c44-9efa-c850286cb0ac	0	21000	\N
cfbb326f-c2ec-4a42-8ee6-9f52842f1e4e	97355425-0567-47a0-89bf-e06eb0e9ec99	c096aa8f-fd2f-4a1f-8c61-7b9dee4df4ab	21000	0	\N
df58ab54-b173-4f3a-a35c-652800f9ae4c	97355425-0567-47a0-89bf-e06eb0e9ec99	831219f9-e9dc-4c44-9efa-c850286cb0ac	0	21000	\N
\.


--
-- Data for Name: petty_cash_transactions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.petty_cash_transactions (id, date, description, credit, debit, balance, month, year, created_at, reference, supplier, allocation, vat_amount, net_amount, source_file, journal_entry_id) FROM stdin;
a6a3806d-a971-4ccc-a1e2-4f004c947d39	2026-01-01	BALANCE	0.00	0.00	525.97	1	2026	2026-04-22 06:12:26.512018+00	\N	BALANCE	\N	0	0	Petty cash 	\N
761af656-1e25-4a42-90cd-0270541f0858	2026-01-06	DOCUMENTS TO MAPUTO	0.00	575.00	-49.03	1	2026	2026-04-22 06:12:26.512018+00	3310	PORTADOR DIARIO	OFFICE & BANK CHARGES	0	0	Petty cash 	\N
d17c6bf3-24f4-4976-bd4d-e8ef8d8f26ff	2026-01-14	FINE ON LATE PY OF 2023	0.00	1462.56	-1511.59	1	2026	2026-04-22 06:12:26.512018+00	\N	EDM	FINES	0	0	Petty cash 	\N
d10a349b-2583-4602-8fd9-b61da2fdbd3f	2026-01-22	TRANSFER FROM CHEQUE ACCOUNT	10000.00	0.00	8488.41	1	2026	2026-04-22 06:12:26.512018+00	877824	PORTADAR	\N	0	0	Petty cash 	\N
d6f25961-c88a-4b7c-833f-3e3f766d7d9e	2026-01-23	TRANSFER TO PRE-PAID	0.00	88.00	8400.41	1	2026	2026-04-22 06:12:26.512018+00	TRF	CASH	SUSPENSE	0	0	Petty cash 	\N
eeba665a-04fe-4495-bec0-1184552e1bb2	2026-02-01	BALANCE	0.00	0.00	8400.41	2	2026	2026-04-22 06:12:28.601241+00	\N	BALANCE	\N	0	0	Petty cash 	\N
74393468-f84b-4b1f-b3ca-01a452d22377	2026-02-05	DOCUMENTS TO MAPUTO	0.00	495.00	7905.41	2	2026	2026-04-22 06:12:28.601241+00	3370	PORTADOR DIARIO	OFFICE & BANK CHARGES	0	0	Petty cash 	\N
3fc3ef94-106e-4f02-a2a7-365730cdc627	2026-02-09	FISH  BODYBOARD	0.00	10068.80	-2163.39	2	2026	2026-04-22 06:12:28.601241+00	1925	OTIMO	HOUSE 4	0	0	Petty cash 	\N
4fceee47-2459-447a-aa45-70a98741d257	2026-02-11	WINDO CLEAN	0.00	910.00	-3073.39	2	2026	2026-04-22 06:12:28.601241+00	93068	SUPERMERICADO	HOUSE KEEPING	0	0	Petty cash 	\N
3b119ee1-e2f8-468b-a509-f62d8ad2b60c	2026-02-11	SUNLIGHT	0.00	570.00	-3643.39	2	2026	2026-04-22 06:12:28.601241+00	1663	SPAR	HOUSE KEEPING	0	0	Petty cash 	\N
2ede1c39-f18d-4976-91f8-046b5220de79	2026-02-11	SOAP	0.00	1030.00	-4673.39	2	2026	2026-04-22 06:12:28.601241+00	1662	SPAR	HOUSE KEEPING HOUSE 1	0	0	Petty cash 	\N
d5e15adb-a303-42a1-9391-9725bac61d4e	2026-02-11	IMPOSTOS VEICULOS	0.00	2420.00	-7093.39	2	2026	2026-04-22 06:12:28.601241+00	112202	MUNICIPAL	TAX  LICENSE	0	0	Petty cash 	\N
bb184a33-4098-4a6c-a190-f6b515f32a09	2026-04-01	BALANCE	0.00	0.00	-495.00	4	2026	2026-04-19 12:50:23.471096+00	\N	BALANCE	\N	0	0	04 BDO Bank Control 2026.xlsx	\N
072189c2-57cf-466d-9afd-4a9fd5ef980c	2026-02-11	TAX RADIO LICENSE	0.00	1296.00	-8389.39	2	2026	2026-04-22 06:12:28.601241+00	120436	RADIO MOCAMBIQUE	TAX RADIO LICENSE	0	0	Petty cash 	\N
6a9ca7ab-001d-46da-b291-54c58c37c78d	2026-02-12	TECNO 40 X 2	0.00	10500.00	-18889.39	2	2026	2026-04-22 06:12:28.601241+00	3285	AMUJI	CELL FOR GUARDS SECURITY	0	0	Petty cash 	\N
1ed27fdd-9b6f-441d-9044-49a7de2a4c3b	2026-03-01	BALANCE	0.00	0.00	-18889.39	3	2026	2026-04-22 06:12:30.616628+00	\N	BALANCE	\N	0	0	Petty cash 	\N
bf75d3cf-e5f8-4b8e-bbd3-07fb9a2054d4	2026-03-01	PETTY CASH	18889.39	0.00	0.00	3	2026	2026-04-22 06:12:30.616628+00	8777827	PORTADOR	SUSPENSE	0	0	Petty cash 	\N
8a1aedbf-6fcd-4873-b0ae-36782ecb39bb	2026-03-05	DOCUMENTS TO MAPUTO	0.00	495.00	-495.00	3	2026	2026-04-22 06:12:30.616628+00	3432	PORTADOR	COURIER FEE OFFICE	0	0	Petty cash 	\N
48e4f8c8-e570-4ab7-b053-1f0e366e3a62	2026-01-01	BALANCE	0.00	0.00	50986.27	1	2026	2026-04-22 06:12:26.561679+00	\N	BALANCE	\N	0	0	Pre-paid	\N
97e1fccf-31b1-4d9e-9888-3f45abf65c22	2026-01-07	SAND PAPER & LUBRICATE SPRAY	0.00	8329.00	42657.27	1	2026	2026-04-22 06:12:26.561679+00	569560	CONSTRUA	GENERAL MAITENANCE	0	0	Pre-paid	\N
e11bc58a-f333-4ff1-bfed-f4a4d1f86595	2026-01-23	STEEL FOR SECURITY DOOR	0.00	10208.00	32449.27	1	2026	2026-04-22 06:12:26.561679+00	7240	CONSTRUA	NEW BUILDING	0	0	Pre-paid	\N
038deeb7-6560-4a88-b1b8-6944da808c13	2026-01-23	TRANSFER	88.00	0.00	32537.27	1	2026	2026-04-22 06:12:26.561679+00	TRF	PETTY CASH	SUSPENSE	0	0	Pre-paid	\N
6f40942c-0eb6-4bdc-a0ae-1d7ac6aa2013	2026-02-01	BALANCE	0.00	0.00	32537.27	2	2026	2026-04-22 06:12:28.651889+00	\N	BALANCE	\N	0	0	Pre-paid	\N
9a01b40b-6505-4cc1-afe1-9ebffa75f1ac	2026-02-01	BALANCE	0.00	0.00	32537.27	3	2026	2026-04-22 06:12:30.662987+00	\N	BALANCE	\N	0	0	Pre-paid	\N
\.


--
-- Data for Name: profiles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.profiles (id, user_id, display_name, email, created_at, updated_at) FROM stdin;
f9748252-4bd4-49db-a7d0-acf4a7e3b4d9	0ed252b7-ad3b-4b83-9210-4250da9bd291	andrisa.schnell@gmail.com	andrisa.schnell@gmail.com	2026-04-12 06:32:39.175957+00	2026-04-12 06:32:39.175957+00
49520ba7-a8e4-47dd-af34-95daaed55f88	b0146922-1ddd-4a77-a9c6-8b70a114f852	cwschnell@gmail.com	cwschnell@gmail.com	2026-04-15 13:28:55.986756+00	2026-04-15 13:28:55.986756+00
c1db700d-8a68-4b1c-a215-2fe519f3522a	a5e4e04a-7ff4-45eb-ab69-86c3fd92f84a	test@example.com	test@example.com	2026-04-27 08:11:49.398561+00	2026-04-27 08:11:49.398561+00
\.


--
-- Data for Name: properties; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.properties (id, name, code, description, created_at, updated_at) FROM stdin;
ea35b0ac-a1c4-4269-ac14-c52e1de9d514	Casa Luz	H1	House 1 - Tafy	2026-04-12 06:03:10.130395+00	2026-04-12 06:03:10.130395+00
bf17ad40-c04f-4438-8456-1bb96ebcecc7	Casa Aurora	H2	House 2 - Stead/Warren	2026-04-12 06:03:10.130395+00	2026-04-12 06:03:10.130395+00
b0e3af81-86f7-4e03-8742-a859303b62a6	Casa Caju	H3	House 3 - Kevin/Alex	2026-04-12 06:03:10.130395+00	2026-04-12 06:03:10.130395+00
6214c344-b5f9-4d17-b539-e367889ffa9c	Casa Coco	H4	House 4 - Cohen/Warren	2026-04-12 06:03:10.130395+00	2026-04-12 06:03:10.130395+00
4885ca89-81c7-4633-81a0-a5c422e4b275	Lodge Communal	LC	\N	2026-04-19 15:03:09.058786+00	2026-04-19 15:03:09.058786+00
\.


--
-- Data for Name: salary_advances; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.salary_advances (id, employee_id, amount, date, description, month, year, created_at) FROM stdin;
\.


--
-- Data for Name: salary_lines; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.salary_lines (id, salary_run_id, employee_id, base_salary, food_allowance, back_payment, days_worked, monthly_salary, nightshift_hours, overtime_25_percent, overtime_15x_hours, overtime_15x_amount, overtime_2x_hours, overtime_2x_amount, gratification, holiday_days, holiday_amount, gross_total, advance, irps, debt, inss_employee, sind, total_deductions, net_salary, nib, created_at, guardas_25, category) FROM stdin;
483caf48-9c2c-45f7-9419-0661ea20ccef	1d57b1c9-558a-4cb5-9df4-144bf2bcec23	f3da8412-3dae-45b0-b4df-23da5df5dbca	74180.00	8000.00	0.00	30	81000.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0	0.00	81000.00	0.00	10437.50	0.00	2430.00	810.00	13677.50	67322.50	\N	2026-04-13 09:07:45.003791+00	0	\N
4a2c343c-124b-404e-b9a8-e5d06b082126	1d57b1c9-558a-4cb5-9df4-144bf2bcec23	20c0e869-ee8c-464c-99b8-5df806753cd0	10400.00	0.00	0.00	30	11336.00	160.00	1889.33	0.00	0.00	36.00	4251.00	0.00	0	0.00	17476.33	0.00	0.00	0.00	524.29	174.76	699.05	16777.28	\N	2026-04-13 09:07:45.003791+00	0	\N
1e9c3d84-a98e-4bbd-81bb-2b0bf413e7f6	1d57b1c9-558a-4cb5-9df4-144bf2bcec23	8c597645-cf92-4003-84af-a781c51f69d1	10400.00	0.00	0.00	30	11336.00	160.00	1889.33	0.00	0.00	40.00	4723.33	0.00	0	0.00	17948.67	0.00	0.00	0.00	538.46	179.49	717.95	17230.72	\N	2026-04-13 09:07:45.003791+00	0	\N
94393a94-6e0b-4e73-9b88-5b24b7981177	1d57b1c9-558a-4cb5-9df4-144bf2bcec23	8540a557-d3a3-45ed-99c1-a96007dc63de	10400.00	0.00	0.00	30	11336.00	160.00	1889.33	0.00	0.00	8.00	944.67	0.00	0	0.00	14170.00	0.00	0.00	0.00	425.10	141.70	566.80	13603.20	\N	2026-04-13 09:07:45.003791+00	0	\N
af25d4c3-fe20-47cc-a291-be90451c0dc6	1d57b1c9-558a-4cb5-9df4-144bf2bcec23	a35d12c2-81fe-42bc-b195-38e9e713be34	10000.00	0.00	0.00	30	10900.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0	0.00	10900.00	0.00	0.00	0.00	327.00	109.00	436.00	10464.00	\N	2026-04-13 09:07:45.003791+00	0	\N
d07cf3db-c11b-47e5-92e5-dc061db62932	1d57b1c9-558a-4cb5-9df4-144bf2bcec23	a591d7ff-6607-4406-b1bb-99fea46605e4	10500.00	0.00	0.00	30	11445.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0	0.00	11445.00	0.00	0.00	0.00	343.35	114.45	457.80	10987.20	\N	2026-04-13 09:07:45.003791+00	0	\N
9764218e-7d1b-4328-b3e3-8f2ce1288922	1d57b1c9-558a-4cb5-9df4-144bf2bcec23	69627fba-2984-43c4-800e-c592fd1a18d0	10000.00	0.00	0.00	30	10900.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0	0.00	10900.00	0.00	0.00	0.00	327.00	109.00	436.00	10464.00	\N	2026-04-13 09:07:45.003791+00	0	\N
6de2496e-f3b8-4b97-8364-d8fffb367cfa	1d57b1c9-558a-4cb5-9df4-144bf2bcec23	b2db1ad4-a7d5-4551-8f47-edbf98149a8d	10000.00	0.00	0.00	30	10900.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0	0.00	10900.00	5500.00	0.00	0.00	327.00	109.00	5936.00	4964.00	\N	2026-04-13 09:07:45.003791+00	0	\N
444eec11-8585-489e-be05-ac07d2e14db6	1d57b1c9-558a-4cb5-9df4-144bf2bcec23	8aa3936d-1f8c-48f6-982a-2f9b58d2ec64	10050.00	0.00	0.00	30	10955.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0	0.00	10955.00	0.00	0.00	0.00	328.65	109.55	438.20	10516.80	\N	2026-04-13 09:07:45.003791+00	0	\N
1d0ef58c-4725-4f65-b051-f811a88f3764	1d57b1c9-558a-4cb5-9df4-144bf2bcec23	25ef4bf1-4d69-4bea-b060-1d46a50248e8	13600.00	0.00	0.00	30	14824.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0	0.00	14824.00	0.00	0.00	0.00	444.72	148.24	592.96	14231.04	\N	2026-04-13 09:07:45.003791+00	0	\N
5c2d14c8-0eec-4214-bd43-7a31741acab6	1d57b1c9-558a-4cb5-9df4-144bf2bcec23	6b858a35-05f5-4de9-9c69-15c80fde978e	13000.00	0.00	0.00	30	14170.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0	0.00	14170.00	0.00	0.00	0.00	425.10	141.70	566.80	13603.20	\N	2026-04-13 09:07:45.003791+00	0	\N
812f8a89-dcf1-4be5-b9e5-34c29b180d11	1d57b1c9-558a-4cb5-9df4-144bf2bcec23	c4ab3503-9e29-4c60-a8de-53dcca2b4225	13650.00	0.00	0.00	30	14879.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0	0.00	14879.00	0.00	0.00	0.00	446.37	148.79	595.16	14283.84	\N	2026-04-13 09:07:45.003791+00	0	\N
46b1edc8-a4ad-422d-8824-a7e0205488e6	1d57b1c9-558a-4cb5-9df4-144bf2bcec23	b21601cf-206c-4a78-9cb7-73045874f36e	10050.00	0.00	0.00	30	10955.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0	0.00	10955.00	0.00	0.00	0.00	328.65	109.55	438.20	10516.80	\N	2026-04-13 09:07:45.003791+00	0	\N
166f14f6-3a89-483b-a562-bbff4c019b5a	1d57b1c9-558a-4cb5-9df4-144bf2bcec23	7fcc5c4b-e6fe-4bb4-a459-d2481d7e7cf1	15000.00	0.00	0.00	30	16350.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0	0.00	16350.00	0.00	0.00	0.00	490.50	163.50	654.00	15696.00	\N	2026-04-13 09:07:45.003791+00	0	\N
cad47422-133e-4ca9-ad68-4592108301c7	1d57b1c9-558a-4cb5-9df4-144bf2bcec23	ffd04fc1-9c18-4182-8998-4c1d7a09dc30	15000.00	0.00	0.00	30	16350.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0	0.00	16350.00	0.00	0.00	0.00	490.50	163.50	654.00	15696.00	\N	2026-04-13 09:07:45.003791+00	0	\N
7ec1bf25-7b2e-489a-9baa-447f99267049	1d57b1c9-558a-4cb5-9df4-144bf2bcec23	58ee18f4-5296-4864-9cf6-5dc79c29cfa5	10500.00	0.00	0.00	30	11445.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0	0.00	11445.00	0.00	0.00	0.00	343.35	114.45	457.80	10987.20	\N	2026-04-13 09:07:45.003791+00	0	\N
f33bfbcf-2a7e-40bd-be1d-fa83cb8d3165	1d57b1c9-558a-4cb5-9df4-144bf2bcec23	1914c017-1c20-4db2-b712-413a6ac194dd	10050.00	0.00	0.00	30	10955.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0	0.00	10955.00	0.00	0.00	0.00	328.65	109.55	438.20	10516.80	\N	2026-04-13 09:07:45.003791+00	0	\N
fc4f002e-ee71-4415-9aa1-e8845443da06	1d57b1c9-558a-4cb5-9df4-144bf2bcec23	b609a704-c683-4b18-b1a5-6c62e382afde	13050.00	0.00	0.00	30	14225.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0	0.00	14225.00	0.00	0.00	0.00	426.75	142.25	569.00	13656.00	\N	2026-04-13 09:07:45.003791+00	0	\N
82abc239-7029-4897-a6e1-4cd64dea8f84	1d57b1c9-558a-4cb5-9df4-144bf2bcec23	e7a713f6-7914-45d8-ac51-839247b3d641	10500.00	0.00	0.00	30	11445.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0	0.00	11445.00	1500.00	0.00	0.00	343.35	114.45	1957.80	9487.20	\N	2026-04-13 09:07:45.003791+00	0	\N
11692b27-e211-4eff-ae5e-6fc911ba3a85	1d57b1c9-558a-4cb5-9df4-144bf2bcec23	7a0ff3cb-1b78-48af-b980-681e55f09980	13050.00	0.00	0.00	30	14225.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0	0.00	14225.00	0.00	0.00	0.00	426.75	142.25	569.00	13656.00	\N	2026-04-13 09:07:45.003791+00	0	\N
e3d55f45-ce63-4d5b-b0ce-240ab373226e	1d57b1c9-558a-4cb5-9df4-144bf2bcec23	0b1c761f-1e1d-4025-a4d4-1f6cfa312118	10050.00	0.00	0.00	30	10955.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0	0.00	10955.00	0.00	0.00	0.00	328.65	109.55	438.20	10516.80	\N	2026-04-13 09:07:45.003791+00	0	\N
86aa52e5-40bd-4348-9a0e-439f77f400b3	5c51575f-5258-4084-bdc0-ba81999c3d1d	f3da8412-3dae-45b0-b4df-23da5df5dbca	0.00	73000.00	8000.00	30	30.00	81000.00	0.00	0.00	0.00	0.00	0.00	0.00	0	0.00	0.00	81000.00	0.00	10437.50	0.00	2430.00	810.00	13677.50	\N	2026-04-13 09:07:45.218815+00	0	\N
da6121fb-3f36-4d3c-8013-37e16c397e9a	5c51575f-5258-4084-bdc0-ba81999c3d1d	20c0e869-ee8c-464c-99b8-5df806753cd0	0.00	11336.00	0.00	30	30.00	11336.00	160.00	1889.33	0.00	0.00	12.00	0.00	0	0.00	0.00	14642.33	0.00	0.00	0.00	439.27	146.42	585.69	\N	2026-04-13 09:07:45.218815+00	0	\N
dfebd31b-7164-4946-8ac9-1d1e47b93621	5c51575f-5258-4084-bdc0-ba81999c3d1d	8c597645-cf92-4003-84af-a781c51f69d1	0.00	11336.00	0.00	30	30.00	11336.00	160.00	1889.33	0.00	0.00	8.00	0.00	0	0.00	0.00	14170.00	0.00	0.00	0.00	425.10	141.70	566.80	\N	2026-04-13 09:07:45.218815+00	0	\N
a7a350ef-acf2-41ae-a56e-7ef684e9a767	5c51575f-5258-4084-bdc0-ba81999c3d1d	8540a557-d3a3-45ed-99c1-a96007dc63de	0.00	11336.00	0.00	30	30.00	11336.00	160.00	1889.33	0.00	0.00	12.00	0.00	0	0.00	0.00	14642.33	0.00	0.00	0.00	439.27	146.42	585.69	\N	2026-04-13 09:07:45.218815+00	0	\N
ae431267-03dc-417c-9781-810fe979ef25	5c51575f-5258-4084-bdc0-ba81999c3d1d	a35d12c2-81fe-42bc-b195-38e9e713be34	0.00	10900.00	0.00	30	30.00	10900.00	0.00	0.00	0.00	0.00	0.00	0.00	0	0.00	0.00	10900.00	0.00	0.00	0.00	327.00	109.00	436.00	\N	2026-04-13 09:07:45.218815+00	0	\N
c7fce1fe-0b85-4526-b42d-980d26455b9f	5c51575f-5258-4084-bdc0-ba81999c3d1d	a591d7ff-6607-4406-b1bb-99fea46605e4	0.00	11445.00	0.00	30	30.00	11445.00	0.00	0.00	0.00	0.00	0.00	0.00	0	0.00	0.00	11445.00	1500.00	0.00	0.00	343.35	114.45	1957.80	\N	2026-04-13 09:07:45.218815+00	0	\N
88e5da14-6c04-4932-8759-f5076b1e457d	5c51575f-5258-4084-bdc0-ba81999c3d1d	69627fba-2984-43c4-800e-c592fd1a18d0	0.00	10900.00	0.00	30	30.00	10900.00	0.00	0.00	0.00	0.00	0.00	0.00	0	0.00	0.00	10900.00	0.00	0.00	0.00	327.00	109.00	436.00	\N	2026-04-13 09:07:45.218815+00	0	\N
dcaa8ef8-c5d9-46fc-9cce-39d649d1295d	5c51575f-5258-4084-bdc0-ba81999c3d1d	b2db1ad4-a7d5-4551-8f47-edbf98149a8d	0.00	10900.00	0.00	30	30.00	10900.00	0.00	0.00	6.00	468.75	0.00	0.00	0	0.00	0.00	11368.75	0.00	0.00	0.00	341.06	113.69	454.75	\N	2026-04-13 09:07:45.218815+00	0	\N
60692ae4-cb00-4ea6-b973-3d65db2f08d5	5c51575f-5258-4084-bdc0-ba81999c3d1d	8aa3936d-1f8c-48f6-982a-2f9b58d2ec64	0.00	10955.00	0.00	30	30.00	10955.00	0.00	0.00	0.00	0.00	0.00	0.00	0	0.00	0.00	10955.00	0.00	0.00	0.00	328.65	109.55	438.20	\N	2026-04-13 09:07:45.218815+00	0	\N
d5861c2b-d06a-4500-838a-a249249e0ab3	5c51575f-5258-4084-bdc0-ba81999c3d1d	25ef4bf1-4d69-4bea-b060-1d46a50248e8	0.00	14824.00	0.00	30	30.00	14824.00	0.00	0.00	4.00	425.00	8.00	0.00	0	0.00	0.00	16484.33	0.00	0.00	0.00	494.53	164.84	659.37	\N	2026-04-13 09:07:45.218815+00	0	\N
d237d942-e988-4bfe-a852-63af88e17319	5c51575f-5258-4084-bdc0-ba81999c3d1d	6b858a35-05f5-4de9-9c69-15c80fde978e	0.00	14170.00	0.00	30	30.00	14170.00	0.00	0.00	0.00	0.00	0.00	0.00	0	0.00	0.00	14170.00	0.00	0.00	0.00	425.10	141.70	566.80	\N	2026-04-13 09:07:45.218815+00	0	\N
2047084a-f02d-43b6-ab3d-a777a9459157	5c51575f-5258-4084-bdc0-ba81999c3d1d	c4ab3503-9e29-4c60-a8de-53dcca2b4225	0.00	14879.00	0.00	30	30.00	14879.00	0.00	0.00	16.00	1706.25	32.00	0.00	0	0.00	0.00	21544.92	0.00	0.00	0.00	646.35	215.45	861.80	\N	2026-04-13 09:07:45.218815+00	0	\N
10ac71a9-ac55-4ce7-bfd9-091f288b8764	5c51575f-5258-4084-bdc0-ba81999c3d1d	b21601cf-206c-4a78-9cb7-73045874f36e	0.00	10955.00	0.00	30	30.00	10955.00	0.00	0.00	0.00	0.00	0.00	0.00	0	0.00	0.00	10955.00	0.00	0.00	0.00	328.65	109.55	438.20	\N	2026-04-13 09:07:45.218815+00	0	\N
0df8cf45-e642-4f6c-8cd5-8e6261b2f685	5c51575f-5258-4084-bdc0-ba81999c3d1d	7fcc5c4b-e6fe-4bb4-a459-d2481d7e7cf1	0.00	16350.00	0.00	30	30.00	16350.00	0.00	0.00	0.00	0.00	0.00	0.00	0	0.00	0.00	16350.00	0.00	0.00	0.00	490.50	163.50	654.00	\N	2026-04-13 09:07:45.218815+00	0	\N
6f590a98-e216-49f5-9b7a-47857747bc7a	5c51575f-5258-4084-bdc0-ba81999c3d1d	ffd04fc1-9c18-4182-8998-4c1d7a09dc30	0.00	16350.00	0.00	30	30.00	16350.00	0.00	0.00	0.00	0.00	0.00	0.00	0	0.00	0.00	16350.00	0.00	0.00	0.00	490.50	163.50	654.00	\N	2026-04-13 09:07:45.218815+00	0	\N
1e753fc9-778b-4c0c-aeb9-d42707f0b18a	5c51575f-5258-4084-bdc0-ba81999c3d1d	58ee18f4-5296-4864-9cf6-5dc79c29cfa5	0.00	11445.00	0.00	30	30.00	11445.00	0.00	0.00	0.00	0.00	0.00	0.00	0	0.00	0.00	11445.00	0.00	0.00	0.00	343.35	114.45	457.80	\N	2026-04-13 09:07:45.218815+00	0	\N
4b86c660-9ab0-4443-9621-0e015d23eb5b	5c51575f-5258-4084-bdc0-ba81999c3d1d	1914c017-1c20-4db2-b712-413a6ac194dd	0.00	10955.00	0.00	30	30.00	10955.00	0.00	0.00	0.00	0.00	8.00	0.00	0	0.00	0.00	11867.92	0.00	0.00	0.00	356.04	118.68	474.72	\N	2026-04-13 09:07:45.218815+00	0	\N
7b7696a9-3917-4646-8b87-44e354181e55	5c51575f-5258-4084-bdc0-ba81999c3d1d	b609a704-c683-4b18-b1a5-6c62e382afde	0.00	14225.00	0.00	30	30.00	14225.00	0.00	0.00	0.00	0.00	8.00	0.00	0	0.00	0.00	15410.42	3500.00	0.00	0.00	462.31	154.10	4116.42	\N	2026-04-13 09:07:45.218815+00	0	\N
1350217b-75f4-4fc3-9143-d1ed0ceecc37	5c51575f-5258-4084-bdc0-ba81999c3d1d	e7a713f6-7914-45d8-ac51-839247b3d641	0.00	11445.00	0.00	30	30.00	11445.00	0.00	0.00	0.00	0.00	0.00	0.00	0	0.00	0.00	11445.00	10987.20	0.00	0.00	343.35	114.45	11445.00	\N	2026-04-13 09:07:45.218815+00	0	\N
7df482be-ce9a-403c-b358-4958ee326cb0	5c51575f-5258-4084-bdc0-ba81999c3d1d	7a0ff3cb-1b78-48af-b980-681e55f09980	0.00	14225.00	0.00	30	30.00	14225.00	0.00	0.00	0.00	0.00	0.00	0.00	0	0.00	0.00	14225.00	0.00	0.00	0.00	426.75	142.25	569.00	\N	2026-04-13 09:07:45.218815+00	0	\N
439dea9f-d974-4895-85c7-e674ed000856	5c51575f-5258-4084-bdc0-ba81999c3d1d	0b1c761f-1e1d-4025-a4d4-1f6cfa312118	0.00	10955.00	0.00	30	30.00	10955.00	0.00	0.00	0.00	0.00	0.00	0.00	0	0.00	0.00	10955.00	0.00	0.00	0.00	328.65	109.55	438.20	\N	2026-04-13 09:07:45.218815+00	0	\N
86f05334-47ec-428a-8b7a-d8b79daab8a8	dce342a5-3d25-443d-b305-c53eaf39b35b	f3da8412-3dae-45b0-b4df-23da5df5dbca	0.00	73000.00	8000.00	30	30.00	81000.00	0.00	0.00	0.00	0.00	0.00	0.00	0	0.00	0.00	81000.00	0.00	10437.50	0.00	2430.00	810.00	13677.50	\N	2026-04-13 09:07:45.442803+00	0	\N
b6d7a08b-56b7-4959-b495-6c70d976c6bc	dce342a5-3d25-443d-b305-c53eaf39b35b	20c0e869-ee8c-464c-99b8-5df806753cd0	0.00	11336.00	0.00	30	30.00	11336.00	160.00	1889.33	0.00	0.00	0.00	0.00	0	0.00	0.00	13225.33	0.00	0.00	0.00	396.76	132.25	529.01	\N	2026-04-13 09:07:45.442803+00	0	\N
d2b60696-87a4-4b08-807e-30a9fbbaa0c1	dce342a5-3d25-443d-b305-c53eaf39b35b	8c597645-cf92-4003-84af-a781c51f69d1	0.00	11336.00	0.00	30	30.00	11336.00	160.00	1889.33	0.00	0.00	0.00	0.00	0	0.00	0.00	13225.33	0.00	0.00	0.00	396.76	132.25	529.01	\N	2026-04-13 09:07:45.442803+00	0	\N
7c4c1429-02ad-45dd-b3a6-27c9fe4990ae	dce342a5-3d25-443d-b305-c53eaf39b35b	8540a557-d3a3-45ed-99c1-a96007dc63de	0.00	11336.00	0.00	30	30.00	11336.00	160.00	1889.33	0.00	0.00	0.00	0.00	0	0.00	0.00	13225.33	0.00	0.00	0.00	396.76	132.25	529.01	\N	2026-04-13 09:07:45.442803+00	0	\N
5d99b5d4-dc66-447c-82d3-16aca25b0614	dce342a5-3d25-443d-b305-c53eaf39b35b	a35d12c2-81fe-42bc-b195-38e9e713be34	0.00	10900.00	0.00	30	30.00	10900.00	0.00	0.00	0.00	0.00	0.00	0.00	0	0.00	0.00	10900.00	0.00	0.00	0.00	327.00	109.00	436.00	\N	2026-04-13 09:07:45.442803+00	0	\N
d90b67f9-f40b-4a8b-8541-6e3d5cae0510	dce342a5-3d25-443d-b305-c53eaf39b35b	a591d7ff-6607-4406-b1bb-99fea46605e4	0.00	11445.00	0.00	30	30.00	11445.00	0.00	0.00	0.00	0.00	0.00	0.00	0	0.00	0.00	11445.00	2300.00	0.00	0.00	343.35	114.45	2757.80	\N	2026-04-13 09:07:45.442803+00	0	\N
b8462c47-7c8b-4416-b93e-d686f528c234	dce342a5-3d25-443d-b305-c53eaf39b35b	69627fba-2984-43c4-800e-c592fd1a18d0	0.00	10900.00	0.00	30	30.00	10900.00	0.00	0.00	0.00	0.00	0.00	0.00	0	0.00	0.00	10900.00	0.00	0.00	0.00	327.00	109.00	436.00	\N	2026-04-13 09:07:45.442803+00	0	\N
b13fef9a-ce29-48fe-959f-b5f63b55ff23	dce342a5-3d25-443d-b305-c53eaf39b35b	b2db1ad4-a7d5-4551-8f47-edbf98149a8d	0.00	10900.00	0.00	30	30.00	10900.00	0.00	0.00	0.00	0.00	0.00	0.00	0	0.00	0.00	10900.00	0.00	0.00	0.00	327.00	109.00	436.00	\N	2026-04-13 09:07:45.442803+00	0	\N
0b483b24-75a3-45ed-ac20-47d3da1ff550	dce342a5-3d25-443d-b305-c53eaf39b35b	8aa3936d-1f8c-48f6-982a-2f9b58d2ec64	0.00	10955.00	0.00	30	30.00	10955.00	0.00	0.00	0.00	0.00	0.00	0.00	0	0.00	0.00	10955.00	0.00	0.00	0.00	328.65	109.55	438.20	\N	2026-04-13 09:07:45.442803+00	0	\N
858417ec-964d-4995-a885-32f13e1ab327	dce342a5-3d25-443d-b305-c53eaf39b35b	25ef4bf1-4d69-4bea-b060-1d46a50248e8	0.00	14824.00	0.00	30	30.00	14824.00	0.00	0.00	0.00	0.00	0.00	0.00	0	0.00	0.00	14824.00	0.00	0.00	0.00	444.72	148.24	592.96	\N	2026-04-13 09:07:45.442803+00	0	\N
7ed903c8-96d3-4441-8cec-45060eb79c5b	dce342a5-3d25-443d-b305-c53eaf39b35b	6b858a35-05f5-4de9-9c69-15c80fde978e	0.00	14170.00	0.00	30	30.00	14170.00	0.00	0.00	14.00	1421.88	0.00	0.00	0	0.00	0.00	15591.88	0.00	0.00	0.00	467.76	155.92	623.68	\N	2026-04-13 09:07:45.442803+00	0	\N
2d16aaab-7654-41d8-b34e-0c3228094a6b	dce342a5-3d25-443d-b305-c53eaf39b35b	c4ab3503-9e29-4c60-a8de-53dcca2b4225	0.00	14879.00	0.00	30	30.00	14879.00	0.00	0.00	0.00	0.00	0.00	0.00	0	0.00	0.00	14879.00	0.00	129.49	0.00	446.37	148.79	724.65	\N	2026-04-13 09:07:45.442803+00	0	\N
05c2dfa9-6cc9-4eff-9f48-a7941a1c9047	dce342a5-3d25-443d-b305-c53eaf39b35b	b21601cf-206c-4a78-9cb7-73045874f36e	0.00	10955.00	0.00	30	30.00	10955.00	0.00	0.00	0.00	0.00	0.00	0.00	0	0.00	0.00	10955.00	0.00	0.00	0.00	328.65	109.55	438.20	\N	2026-04-13 09:07:45.442803+00	0	\N
0316b03d-b428-4dae-afd8-4d678371e9a4	dce342a5-3d25-443d-b305-c53eaf39b35b	7fcc5c4b-e6fe-4bb4-a459-d2481d7e7cf1	0.00	16350.00	0.00	30	30.00	16350.00	0.00	0.00	0.00	0.00	0.00	0.00	0	0.00	0.00	16350.00	0.00	0.00	0.00	490.50	163.50	654.00	\N	2026-04-13 09:07:45.442803+00	0	\N
0588dd97-c36e-4e03-95fd-f76501093250	dce342a5-3d25-443d-b305-c53eaf39b35b	ffd04fc1-9c18-4182-8998-4c1d7a09dc30	0.00	16350.00	0.00	30	30.00	16350.00	0.00	0.00	0.00	0.00	0.00	0.00	0	0.00	0.00	16350.00	1500.00	0.00	0.00	490.50	163.50	2154.00	\N	2026-04-13 09:07:45.442803+00	0	\N
5432f402-1981-471e-b058-d47783999d73	dce342a5-3d25-443d-b305-c53eaf39b35b	58ee18f4-5296-4864-9cf6-5dc79c29cfa5	0.00	11445.00	0.00	30	30.00	11445.00	0.00	0.00	0.00	0.00	0.00	0.00	0	0.00	0.00	11445.00	0.00	0.00	0.00	343.35	114.45	457.80	\N	2026-04-13 09:07:45.442803+00	0	\N
5eda5022-8640-43bf-b9d3-4dd5b1e18e1b	dce342a5-3d25-443d-b305-c53eaf39b35b	1914c017-1c20-4db2-b712-413a6ac194dd	0.00	10955.00	0.00	30	30.00	10955.00	0.00	0.00	0.00	0.00	0.00	0.00	0	0.00	0.00	10955.00	0.00	0.00	0.00	328.65	109.55	438.20	\N	2026-04-13 09:07:45.442803+00	0	\N
6dcc5cb1-3e70-4b67-913c-c48070c87c59	dce342a5-3d25-443d-b305-c53eaf39b35b	b609a704-c683-4b18-b1a5-6c62e382afde	0.00	14225.00	0.00	30	30.00	14225.00	0.00	0.00	0.00	0.00	0.00	0.00	0	0.00	0.00	14225.00	0.00	0.00	0.00	426.75	142.25	569.00	\N	2026-04-13 09:07:45.442803+00	0	\N
09d34093-dc84-4a18-bda8-5c5151999709	dce342a5-3d25-443d-b305-c53eaf39b35b	e7a713f6-7914-45d8-ac51-839247b3d641	0.00	11445.00	0.00	30	30.00	11445.00	0.00	0.00	0.00	0.00	0.00	0.00	0	0.00	0.00	11445.00	5000.00	0.00	0.00	343.35	114.45	5457.80	\N	2026-04-13 09:07:45.442803+00	0	\N
602f1e11-4957-43ab-901f-81d62cd96506	dce342a5-3d25-443d-b305-c53eaf39b35b	7a0ff3cb-1b78-48af-b980-681e55f09980	0.00	14225.00	0.00	30	30.00	14225.00	0.00	0.00	0.00	0.00	0.00	0.00	0	0.00	0.00	14225.00	0.00	0.00	0.00	426.75	142.25	569.00	\N	2026-04-13 09:07:45.442803+00	0	\N
91c4d08e-3db9-4b40-be63-35bb78d88130	dce342a5-3d25-443d-b305-c53eaf39b35b	0b1c761f-1e1d-4025-a4d4-1f6cfa312118	0.00	10955.00	0.00	30	30.00	10955.00	0.00	0.00	0.00	0.00	0.00	0.00	0	0.00	0.00	10955.00	0.00	0.00	0.00	328.65	109.55	438.20	\N	2026-04-13 09:07:45.442803+00	0	\N
1b9dd116-5285-4e61-a7db-c1d3a8880dcb	49ddb233-4029-4496-b526-f93317cf7f5b	f3da8412-3dae-45b0-b4df-23da5df5dbca	0.00	73000.00	8000.00	30	30.00	81000.00	0.00	0.00	0.00	0.00	0.00	0.00	0	0.00	0.00	81000.00	0.00	10437.50	0.00	2430.00	810.00	13677.50	\N	2026-04-13 09:07:45.661632+00	0	\N
7c097e72-28ba-48ec-b2a4-d00ad217d005	49ddb233-4029-4496-b526-f93317cf7f5b	20c0e869-ee8c-464c-99b8-5df806753cd0	0.00	11336.00	0.00	30	30.00	11336.00	160.00	1889.33	0.00	0.00	0.00	0.00	0	0.00	0.00	13225.33	0.00	0.00	0.00	396.76	132.25	529.01	\N	2026-04-13 09:07:45.661632+00	0	\N
3769dac9-7c66-429f-90d2-f1354d243c45	49ddb233-4029-4496-b526-f93317cf7f5b	8c597645-cf92-4003-84af-a781c51f69d1	0.00	11336.00	0.00	30	30.00	11336.00	160.00	1889.33	0.00	0.00	0.00	0.00	0	0.00	0.00	13225.33	0.00	0.00	0.00	396.76	132.25	529.01	\N	2026-04-13 09:07:45.661632+00	0	\N
bce2d9c0-94ed-4c66-9fb0-ffd077257ba9	49ddb233-4029-4496-b526-f93317cf7f5b	8540a557-d3a3-45ed-99c1-a96007dc63de	0.00	11336.00	0.00	30	30.00	11336.00	160.00	1889.33	0.00	0.00	0.00	0.00	0	0.00	0.00	13225.33	0.00	0.00	0.00	396.76	132.25	529.01	\N	2026-04-13 09:07:45.661632+00	0	\N
97ccc558-f24c-4648-abfa-33856c245fc4	49ddb233-4029-4496-b526-f93317cf7f5b	a35d12c2-81fe-42bc-b195-38e9e713be34	0.00	10900.00	0.00	30	30.00	10900.00	0.00	0.00	0.00	0.00	0.00	0.00	0	0.00	0.00	10900.00	0.00	0.00	0.00	327.00	109.00	436.00	\N	2026-04-13 09:07:45.661632+00	0	\N
16c264b6-bdfe-4125-b426-7647beaed373	49ddb233-4029-4496-b526-f93317cf7f5b	a591d7ff-6607-4406-b1bb-99fea46605e4	0.00	11445.00	0.00	30	30.00	11445.00	0.00	0.00	0.00	0.00	0.00	0.00	0	0.00	0.00	11445.00	0.00	0.00	0.00	343.35	114.45	457.80	\N	2026-04-13 09:07:45.661632+00	0	\N
a355e745-25c4-4975-8379-fcb378574cbe	49ddb233-4029-4496-b526-f93317cf7f5b	69627fba-2984-43c4-800e-c592fd1a18d0	0.00	10900.00	0.00	30	30.00	10900.00	0.00	0.00	0.00	0.00	0.00	0.00	0	0.00	0.00	10900.00	0.00	0.00	0.00	327.00	109.00	436.00	\N	2026-04-13 09:07:45.661632+00	0	\N
905be5ce-5317-4168-927f-56a3a2115e99	49ddb233-4029-4496-b526-f93317cf7f5b	b2db1ad4-a7d5-4551-8f47-edbf98149a8d	0.00	10900.00	0.00	30	30.00	10900.00	0.00	0.00	0.00	0.00	0.00	0.00	0	0.00	0.00	10900.00	0.00	0.00	0.00	327.00	109.00	436.00	\N	2026-04-13 09:07:45.661632+00	0	\N
4ccfb1d1-9822-405a-9d8b-43e6617ca9cf	49ddb233-4029-4496-b526-f93317cf7f5b	8aa3936d-1f8c-48f6-982a-2f9b58d2ec64	0.00	10955.00	0.00	30	30.00	10955.00	0.00	0.00	0.00	0.00	0.00	0.00	0	0.00	0.00	10955.00	0.00	0.00	0.00	328.65	109.55	438.20	\N	2026-04-13 09:07:45.661632+00	0	\N
1abc9ba8-a087-4406-b84c-76939886e3bd	49ddb233-4029-4496-b526-f93317cf7f5b	25ef4bf1-4d69-4bea-b060-1d46a50248e8	0.00	14824.00	0.00	30	30.00	14824.00	0.00	0.00	0.00	0.00	0.00	0.00	0	0.00	0.00	14824.00	4000.00	0.00	0.00	444.72	148.24	4592.96	\N	2026-04-13 09:07:45.661632+00	0	\N
1760c54c-46e0-409a-8470-7f6fa09557e9	49ddb233-4029-4496-b526-f93317cf7f5b	6b858a35-05f5-4de9-9c69-15c80fde978e	0.00	14170.00	0.00	30	30.00	14170.00	0.00	0.00	14.00	1421.88	0.00	0.00	0	0.00	0.00	15591.88	0.00	0.00	0.00	467.76	155.92	623.68	\N	2026-04-13 09:07:45.661632+00	0	\N
2e08aacc-3649-4209-b4f1-1d630fa80e82	49ddb233-4029-4496-b526-f93317cf7f5b	c4ab3503-9e29-4c60-a8de-53dcca2b4225	0.00	14879.00	0.00	30	30.00	14879.00	0.00	0.00	0.00	0.00	0.00	0.00	0	0.00	0.00	14879.00	6000.00	0.00	0.00	446.37	148.79	6595.16	\N	2026-04-13 09:07:45.661632+00	0	\N
35fb2135-29e5-43e2-8e83-8df1f39627eb	49ddb233-4029-4496-b526-f93317cf7f5b	b21601cf-206c-4a78-9cb7-73045874f36e	0.00	10955.00	0.00	30	30.00	10955.00	0.00	0.00	0.00	0.00	0.00	0.00	0	0.00	0.00	10955.00	0.00	0.00	0.00	328.65	109.55	438.20	\N	2026-04-13 09:07:45.661632+00	0	\N
a972d2e7-1e8a-4e62-a724-3c4d330f14ac	49ddb233-4029-4496-b526-f93317cf7f5b	7fcc5c4b-e6fe-4bb4-a459-d2481d7e7cf1	0.00	16350.00	0.00	30	30.00	16350.00	0.00	0.00	0.00	0.00	0.00	0.00	0	0.00	0.00	16350.00	6000.00	0.00	0.00	490.50	163.50	6654.00	\N	2026-04-13 09:07:45.661632+00	0	\N
7df1e889-14a0-4a38-8d60-74b9a52c0e1b	49ddb233-4029-4496-b526-f93317cf7f5b	ffd04fc1-9c18-4182-8998-4c1d7a09dc30	0.00	16350.00	0.00	30	30.00	16350.00	0.00	0.00	0.00	0.00	0.00	0.00	0	0.00	0.00	16350.00	3000.00	0.00	0.00	490.50	163.50	3654.00	\N	2026-04-13 09:07:45.661632+00	0	\N
1b01def6-6091-41c4-ade9-1a995fc86f1b	49ddb233-4029-4496-b526-f93317cf7f5b	58ee18f4-5296-4864-9cf6-5dc79c29cfa5	0.00	11445.00	0.00	30	30.00	11445.00	0.00	0.00	0.00	0.00	0.00	0.00	0	0.00	0.00	11445.00	2000.00	0.00	0.00	343.35	114.45	2457.80	\N	2026-04-13 09:07:45.661632+00	0	\N
d13420d3-c262-41ec-a88d-b3cddf55a1ff	49ddb233-4029-4496-b526-f93317cf7f5b	1914c017-1c20-4db2-b712-413a6ac194dd	0.00	10955.00	0.00	30	30.00	10955.00	0.00	0.00	0.00	0.00	0.00	0.00	0	0.00	0.00	10955.00	0.00	0.00	0.00	328.65	109.55	438.20	\N	2026-04-13 09:07:45.661632+00	0	\N
4b898948-7839-4d1f-b22a-b6e7bbf51be0	49ddb233-4029-4496-b526-f93317cf7f5b	b609a704-c683-4b18-b1a5-6c62e382afde	0.00	14225.00	0.00	30	30.00	14225.00	0.00	0.00	0.00	0.00	0.00	0.00	0	0.00	0.00	14225.00	0.00	0.00	0.00	426.75	142.25	569.00	\N	2026-04-13 09:07:45.661632+00	0	\N
6693c1e9-735a-4e2f-acdf-386a76135450	49ddb233-4029-4496-b526-f93317cf7f5b	e7a713f6-7914-45d8-ac51-839247b3d641	0.00	11445.00	0.00	30	30.00	11445.00	0.00	0.00	0.00	0.00	0.00	0.00	0	0.00	0.00	11445.00	0.00	0.00	0.00	343.35	114.45	457.80	\N	2026-04-13 09:07:45.661632+00	0	\N
4adf9d17-7d7c-46c2-b82a-882cba18c0d3	49ddb233-4029-4496-b526-f93317cf7f5b	7a0ff3cb-1b78-48af-b980-681e55f09980	0.00	14225.00	0.00	30	30.00	14225.00	0.00	0.00	0.00	0.00	0.00	0.00	0	0.00	0.00	14225.00	0.00	0.00	0.00	426.75	142.25	569.00	\N	2026-04-13 09:07:45.661632+00	0	\N
b00905ab-6128-490d-ac80-8c73cb810207	49ddb233-4029-4496-b526-f93317cf7f5b	0b1c761f-1e1d-4025-a4d4-1f6cfa312118	0.00	10955.00	0.00	30	30.00	10955.00	0.00	0.00	0.00	0.00	0.00	0.00	0	0.00	0.00	10955.00	0.00	0.00	0.00	328.65	109.55	438.20	\N	2026-04-13 09:07:45.661632+00	0	\N
\.


--
-- Data for Name: salary_runs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.salary_runs (id, month, year, total_gross, total_net, total_inss_employee, total_inss_employer, total_irps, status, created_at, updated_at, journal_entry_id) FROM stdin;
1d57b1c9-558a-4cb5-9df4-144bf2bcec23	1	2026	0.00	0.00	0.00	0.00	0.00	imported	2026-04-13 09:06:42.75494+00	2026-04-13 09:06:42.75494+00	\N
5c51575f-5258-4084-bdc0-ba81999c3d1d	2	2026	0.00	0.00	0.00	0.00	0.00	imported	2026-04-13 09:06:43.429962+00	2026-04-13 09:06:43.429962+00	\N
dce342a5-3d25-443d-b305-c53eaf39b35b	3	2026	0.00	0.00	0.00	0.00	0.00	imported	2026-04-13 09:06:44.042258+00	2026-04-13 09:06:44.042258+00	\N
49ddb233-4029-4496-b526-f93317cf7f5b	4	2026	0.00	0.00	0.00	0.00	0.00	imported	2026-04-13 09:06:44.694865+00	2026-04-13 09:06:44.694865+00	\N
\.


--
-- Data for Name: shareholder_balances; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.shareholder_balances (id, shareholder_id, property_id, month, year, opening_balance, income, expenses, closing_balance, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: shareholders; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.shareholders (id, name, email, property_code, ownership_percentage, created_at, updated_at) FROM stdin;
0ca35915-5885-4cc9-846d-a898db042da6	Tafy (Luz)	\N	H1	25.00	2026-04-12 06:03:10.130395+00	2026-04-12 06:03:10.130395+00
4a384169-ca7d-4344-81ea-b9bf30e1dcc3	Warren Stead (Aurora)	\N	H2	25.00	2026-04-12 06:03:10.130395+00	2026-04-12 06:03:10.130395+00
93125a84-6cb9-48b3-88f2-858773470230	Kevin / Alex (Caju)	\N	H3	25.00	2026-04-12 06:03:10.130395+00	2026-04-12 06:03:10.130395+00
ca977952-4a9e-4b14-84aa-a846c0e34062	Warren Cohen (Coco)	\N	H4	25.00	2026-04-12 06:03:10.130395+00	2026-04-12 06:03:10.130395+00
\.


--
-- Data for Name: supplier_invoices; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.supplier_invoices (id, supplier_id, invoice_number, invoice_date, description, allocation, amount_excl, vat_amount, total_amount, journal_entry_id, created_at) FROM stdin;
1ba03333-a189-4a22-9783-bada6a36f8e5	7e88fcb6-deec-4111-bcac-f999288427e2	\N	2026-01-11	BANKCHARGES OFFICE EXPENSES; BANKCHARGES OFFICE EXPENSES; BANKCHARGES OFFICE EXPENSES	shared	21	0	21	7e05dad7-7a50-46ba-8719-edf0779184ca	2026-04-21 17:11:01.308012+00
cfc327ec-504a-4bea-bde5-fd8f17b218ea	7e88fcb6-deec-4111-bcac-f999288427e2	\N	2026-01-12	BANKCHARGES OFFICE EXPENSES	shared	7	0	7	b39b2d3a-6860-4c6a-a12e-f7263effc15b	2026-04-21 17:11:01.878363+00
0187357a-0374-4e7a-86a6-ae444b0e9292	7e88fcb6-deec-4111-bcac-f999288427e2	\N	2026-01-20	BANK CHARGES OFFICE EXPENSES	shared	7	0	7	7a4e4cc8-2e5a-4d92-9de4-f56c2038cef6	2026-04-21 17:11:02.449164+00
721609d2-2f6c-4d5b-8900-9126160e8b54	6be23fa2-f91e-460e-a64a-844e1f0d81a8	\N	2026-01-23	GENERAL MAITENANCE	shared	1037.39	0	1037.39	fa272459-f525-49fb-927e-859f21f5951e	2026-04-21 17:11:03.022248+00
ba453b24-1480-4901-b3ce-e7f078527458	4394fe30-3fa3-4571-a4cd-75d67fadd193	\N	2026-01-23	OFFICE EXPENSES	shared	257	0	257	a1e4bf57-2b0a-484d-b572-f68fb58c8557	2026-04-21 17:11:03.601033+00
3e003825-2c2c-48ea-9a6b-e61d591b0e70	9d6680f6-0968-4b57-aee7-7a4c760ffc90	\N	2026-01-28	GENERAL MAINTENANCE	shared	524	0	524	d47bdc0c-eb31-40fb-9431-68539d099079	2026-04-21 17:11:04.211519+00
bc627869-b493-49f4-9d36-c39a98062e93	24822ced-7a0e-47b1-9d94-ee878f7941e9	\N	2026-01-29	GENERAL MAINTENANCE	shared	2025	0	2025	e64b14a4-1449-4484-8256-c7fdfdb5f382	2026-04-21 17:11:04.786658+00
e6c1336c-aeea-4d21-bc0b-73377404143b	61c5253c-1b4e-4265-9600-74983e13a91f	\N	2026-01-06	PETTY CSH	shared	10000	0	10000	c0c4721b-387c-408c-b60a-c10ab2559e37	2026-04-21 17:11:05.356708+00
75eebca9-cdfd-4d00-a713-5c7b0a162022	31974de8-c63a-42c9-a75c-00c7dfb2e4e7	\N	2026-01-23	SUSPENSE	shared	88	0	88	4a8c839e-b13a-4623-be10-ad485968d37f	2026-04-21 17:11:05.940642+00
a9284307-aae9-4193-8475-65774ae379ce	a4c4b098-6d24-4048-ae39-9bbb473c3a24	\N	2026-01-23	SUSPENSE	shared	-88	0	-88	2bdc2163-568c-4a39-89a0-84648a0f29e4	2026-04-21 17:11:06.546532+00
38d46252-71b0-4869-b81f-135e3a6f894d	0eac37ae-c535-4e60-aa94-f3d043b93629	\N	2026-01-12	CASUAL GUARD FOR JANUARY	shared	7000	0	7000	109e24b2-2122-42ec-8e8c-eb57bef982fd	2026-04-21 17:11:07.137361+00
979a9d10-2d1b-4dac-9f02-cfb172fc7a60	e75e5673-3e49-43d3-84f1-cf863679b36d	\N	2026-01-31	CHRIS MONTHLY JANUARY	shared	35000	0	35000	c50dde20-2d91-4f8e-b2b2-582bf222eb2c	2026-04-21 17:11:07.692607+00
129064a6-b2ed-4b62-b5ab-87135b57c2c2	4394fe30-3fa3-4571-a4cd-75d67fadd193	\N	2026-02-02	Office expenses; Office expenses; Office expenses	shared	21	0	21	d0f6d152-f45b-479c-afc9-e0323132d94d	2026-04-21 17:11:09.059962+00
59fd0c28-faa3-4970-a49b-1c9681a91a44	4394fe30-3fa3-4571-a4cd-75d67fadd193	\N	2026-02-09	Office expenses	shared	7	0	7	9783cc84-01d0-474b-9ee4-2193695aecbf	2026-04-21 17:11:09.646409+00
0e3a3f1a-2aab-4896-bbfd-f3010dbcab34	99c371ca-ebd5-467a-a592-0de9eb0f1714	\N	2026-02-14	General Maintenance	shared	4263	0	4263	eb6436d0-f25f-495c-acb2-de63d825b779	2026-04-21 17:11:10.235054+00
bbaac806-0553-43d1-90f8-12a77e48eaf8	0217e2c2-1671-41ec-bb04-5e9070aac023	\N	2026-02-19	Admin Cost	shared	146740	0	146740	dac6fcb8-6edd-41d0-a49d-d0997b2df260	2026-04-21 17:11:10.807933+00
b704a002-c01b-4dd3-80a7-4720c30b8c27	4394fe30-3fa3-4571-a4cd-75d67fadd193	\N	2026-02-23	Office expenses; Office expenses; Office expenses	shared	134	0	134	77538e9d-ac57-4c74-89e6-52d33b16760b	2026-04-21 17:11:11.383759+00
083127fc-0f8e-4b98-a4d1-31aff26e02b3	344c1fd1-ff52-4a5f-b111-9d31b82bc1ee	\N	2026-02-23	MAINTENANCE	shared	21558.6	0	21558.6	82e7e135-6ee3-433e-89e1-800d374532e8	2026-04-21 17:11:11.948604+00
138e86b2-e4ea-475b-b38a-3329bd984cd7	39794824-e458-47f3-b076-724c761cd613	\N	2026-02-26	HOUSE KEEPING	shared	755	0	755	0973ad26-f24a-491e-9c53-b21a54481841	2026-04-21 17:11:12.528555+00
4e61c558-ddde-470d-8d83-62803b7bc019	91c71f30-86dd-4722-83c4-2afa1f512ba9	\N	2026-02-01	INSS; INSS; INSS; INSS; INSS; STARLINK FOR FEB; INACIO AND PEDRO CLEANING BOAT; BEFORE CYCLONE INACIO, ZITO AND PEDRO; PETROL ALLOWANS JAN AND FEB; ANDRISA HALF OF EXPENSES DIRE; ANDRISA HALF OF EXPENSES DIRE; SEAPORT CLEANING MATERIAL BOATS; SEAPORT CLEANING MATERIAL BOATS; CHRIS MONTHLY FEE; FOOD FOR WORKERS	shared	218210.63999999998	0	218210.63999999998	e917f46d-f352-4cb7-aa48-8badafcb6ec3	2026-04-21 17:11:13.089938+00
616801bc-305b-4721-bcd8-c91818b8e0d2	8a4c2318-cbce-4d7e-9e88-6eaf3f66407a	\N	2026-02-11	HOUSE KEEPING	shared	910	0	910	c31b5328-d57c-4be6-855c-7e6cd4c22fef	2026-04-21 17:11:13.661815+00
4a180643-3da9-4ae8-90eb-2b1265e1ed91	92573ad4-efa4-448c-bedf-6cc77e85e775	\N	2026-02-11	TAX  LICENSE	shared	2420	0	2420	9497feb1-2ab0-4fb0-840d-1384e94a872c	2026-04-21 17:11:14.221563+00
182f58a3-9b5e-4edd-98e1-f473aae9f77f	ac39dbb1-0adf-4855-8e50-fddd757b9adb	\N	2026-03-09	GENERAL EXPENSES	shared	3328	0	3328	1c425d00-f1cf-4d3a-8f85-654509498fa1	2026-04-21 17:11:15.869468+00
25bea62d-ac58-4bb7-b2c2-f741e441bdcd	4394fe30-3fa3-4571-a4cd-75d67fadd193	\N	2026-03-09	BANK CHARGES SINDICATO BEB	shared	7	0	7	af28dd0c-0020-40df-8d1d-9fae46b401e7	2026-04-21 17:11:16.435673+00
e9273a55-1ce2-4315-9f8a-967cb258936a	da8da653-15c1-445c-857b-8fd8013f1871	\N	2026-03-16	HOUSE KEEPING	shared	1290	0	1290	1d137822-619d-440e-bac3-3e5a7edbecaa	2026-04-21 17:11:17.00078+00
09097661-c803-45af-85ed-0be81f2b8c14	4394fe30-3fa3-4571-a4cd-75d67fadd193	\N	2026-03-18	BANK CHARGES	shared	7	0	7	2383350e-7a15-4b49-b9ac-ab7c33b9f49a	2026-04-21 17:11:17.551076+00
b9598514-97e5-42b7-8850-73806feb8ab0	13141623-b36e-4a2d-bfef-dc910502c7ee	\N	2026-03-19	HOUSE KEEPING	shared	3330	0	3330	e75a86ee-42c9-466e-9978-bdf0f1bc8ff9	2026-04-21 17:11:18.130154+00
56d66f88-288c-4089-b69d-eb499bbfb387	4394fe30-3fa3-4571-a4cd-75d67fadd193	\N	2026-03-19	BANK CHARGES	shared	7	0	7	6665feb8-ec43-41e8-a8e6-479fa51c33f3	2026-04-21 17:11:18.726184+00
6ab7769b-f997-40da-b855-5d5fea640106	4394fe30-3fa3-4571-a4cd-75d67fadd193	\N	2026-03-25	BANK CHARGES	shared	257	0	257	ef789ae0-f38c-4012-bff0-e6b7ce7bc81c	2026-04-21 17:11:19.292101+00
091d9632-cc25-4ae2-9405-bcfd7d34148a	06e8628c-90aa-45a7-8473-1c4e70e32f51	\N	2026-03-27	HOUSE KEEPING	shared	5430	0	5430	2128c23d-cd0b-479e-b945-9ab84988d0c3	2026-04-21 17:11:19.855695+00
933c7ddb-fd65-452f-9c15-96da34c65b32	99c371ca-ebd5-467a-a592-0de9eb0f1714	\N	2026-03-27	ELECTRISITY	shared	12280	0	12280	85af5791-fe1b-4276-b734-2e5e00a67354	2026-04-21 17:11:20.432509+00
23231b81-6fda-4b6c-87f5-40064045d1e5	62482dfc-01ab-4c6d-99f1-aab184636127	\N	2026-03-27	MOTOR VEHICLES EXPENSES	H4	3292.74	0	3292.74	4385d149-f06f-492d-ad2e-9584e91ccd73	2026-04-21 17:11:20.998609+00
ed4ed621-5038-4d93-9197-0a389683b045	4394fe30-3fa3-4571-a4cd-75d67fadd193	\N	2026-03-30	BANK CHARGES; BANK CHARGES	shared	240	0	240	41e068d8-5eed-4d36-8391-b3871ce6740d	2026-04-21 17:11:21.560524+00
87652ec8-192f-44da-a49e-b463deca2fa9	952bf65f-1f2f-494d-a7a0-f8607f3bf34c	\N	2026-03-31	GENERAL MAINTRENANCE	shared	1235	0	1235	8c3e989f-1c39-4ff4-8d05-9aa189577c2e	2026-04-21 17:11:22.107543+00
1864e813-7d1c-4bd1-b71b-967921021ee5	98e939c5-4546-4098-be75-15ce04fa5e0b	\N	2026-01-03	GAS DECEMBER	shared	6426.95	0	6426.95	83a6fb82-d8b9-4827-adc8-e71eb1256eaf	2026-04-21 17:11:00.899556+00
4051cc7c-3611-4dcf-a771-f5b4a9f2cda6	0217e2c2-1671-41ec-bb04-5e9070aac023	\N	2026-01-11	ADMIN AND ACCOUNTING	shared	146740	0	146740	c55e90aa-685f-4975-b5ce-3e7bb3b246bc	2026-04-21 17:11:01.490236+00
f2321dac-22d4-40c8-9e2f-a49d7f4ba925	7e88fcb6-deec-4111-bcac-f999288427e2	\N	2026-01-16	BANK CHARGES OFFICE EXPENSES	shared	7	0	7	89ddfb17-f5d5-47f5-9d6f-894fad670df7	2026-04-21 17:11:02.065054+00
458d71bd-d3dd-4c2c-807c-078cc001c185	b4f05ab1-8ccf-49c8-b062-4d3c36beb7c9	\N	2026-01-22	STATIONARY	shared	1500	0	1500	41e7ff5a-d37d-4270-acd4-d0ff351358a1	2026-04-21 17:11:02.633003+00
cf2fde90-6517-4f23-89cd-2058653963f8	9d0c48c8-6dd5-4668-ac50-0bc5dd9844d0	\N	2026-01-22	SUSPENCE	shared	10000	0	10000	4ac70d05-8898-485d-8baf-978f6a9ee47f	2026-04-21 17:11:03.213192+00
ac373b6c-4b52-4a9f-b797-11b303121719	dde88162-f764-4ef4-9e92-cb0a5532daa0	\N	2026-01-23	WORKERS FOOD ALOWANCE	shared	12000	0	12000	5d8a32a0-73c6-4bc5-8739-cc348ae8f173	2026-04-21 17:11:03.805137+00
8444b2d3-e81a-4030-9720-4df1eedab762	330988e7-e2a7-4aa8-a4a8-0161cd9eb743	\N	2026-01-29	GAS & ELECTRISITY	shared	4833.15	0	4833.15	d84c5a1d-4510-47e6-9085-7b755ddbbb7e	2026-04-21 17:11:04.4004+00
bda9f77b-9615-4bb5-92c1-9b20a52e6a75	b96ac2c2-8f23-4f6e-9f41-fa224bdd58af	\N	2026-01-29	GENERAL MAINTENANCE	shared	900	0	900	d3d9a7fe-8f58-4d0e-867d-da921c035dd5	2026-04-21 17:11:04.980977+00
11a4242e-4922-48fe-aac4-a1859047e800	33a631c5-f1b0-4e33-b0eb-e8dc5271e170	\N	2026-01-14	FINES	shared	1462.56	0	1462.56	422cea12-835c-4ce1-a924-c2d48d12bf4e	2026-04-21 17:11:05.55146+00
cade700e-da96-47ac-bdeb-35d49b68fd90	9cd40e82-b1d9-42f5-93fc-3ccbde9f42e2	\N	2026-01-07	GENERAL MAITENANCE	shared	8329	0	8329	38a6efb2-c9ae-4977-8118-717f4208d60c	2026-04-21 17:11:06.148765+00
27d30419-a7a1-4c0d-9d68-0ea57e9a7dea	1e5ac5e4-e388-4c09-846c-f09d3f639170	\N	2026-01-01	STARLINK FOR JAN	shared	3000	0	3000	08426640-7d4f-4075-bbe4-51769a845d3e	2026-04-21 17:11:06.771528+00
ba5f0a26-b315-46ff-9895-bc29850de05b	61c5253c-1b4e-4265-9600-74983e13a91f	\N	2026-01-21	FOOD FOR WORKERS	shared	21000	0	21000	09e26dc1-2e4c-4923-b999-8cf2fbd413b8	2026-04-21 17:11:07.33934+00
016bbe8b-fb3c-4762-bddd-f28caa6604fe	473bc493-c937-49d4-bc71-d4853c9c8d80	\N	2026-01-31	Shortfall on Ronny money from Warren	H2	2220	0	2220	101f3ddf-6f52-4595-ad92-f0e28ff9f5bc	2026-04-21 17:11:07.888573+00
1cf9a41f-daf4-48e8-ad4b-6766e7d9d543	af047d34-7d63-48dd-96d0-a15c8445f1b7	\N	2026-02-02	Pool Maintenance; Pool Maintenance	shared	2424.6	0	2424.6	c5b911e6-be47-4eef-b087-8adae0c4ec1e	2026-04-21 17:11:09.26994+00
171904b3-a531-4b9b-85e0-c5633d289054	3e3b669c-5068-40d9-8684-99403c4534f5	\N	2026-02-10	Gas& Eletrisity	shared	58424.49	0	58424.49	6db82ac8-55c7-4c02-868b-6935dcac2700	2026-04-21 17:11:09.835268+00
093785b4-e5b3-466e-af0e-b92fe6e46948	4394fe30-3fa3-4571-a4cd-75d67fadd193	\N	2026-02-18	Office expenses; Office expenses	shared	14	0	14	b9132dd4-dc69-404f-b1af-0866519b3521	2026-04-21 17:11:10.422564+00
84487378-89c6-4b69-8d56-333d45cca8a6	4394fe30-3fa3-4571-a4cd-75d67fadd193	\N	2026-02-19	Office expenses	shared	7	0	7	85ba8589-cfaa-4293-a354-cd8ec0bf93eb	2026-04-21 17:11:10.99451+00
267c95c4-d7b8-4f8b-a578-5105826bb256	c71c6ca1-deca-4962-9ba2-556fa5665c3e	\N	2026-02-23	House Keping	H4	20787.2	0	20787.2	bbdbe6a5-10b9-48e4-822d-336f9cb97c2d	2026-04-21 17:11:11.576969+00
5736c0c4-39de-4589-97e0-93d66d8c8bdc	a5c1b88b-de7e-436f-96d0-08f589b70c39	\N	2026-02-25	SALARIES FEB; SALARIES FEB; SALARIES FEB; SALARIES FEB; SALARIES FEB	shared	351226	0	351226	6ac3b6be-2f36-4a5e-975e-c8c11ea8ca40	2026-04-21 17:11:12.159604+00
1f16bcc9-697f-48fc-be34-0c07538c1b0e	579876ff-a647-4bf8-a2ae-d16dca403d5d	\N	2026-02-26	General Maintenance	shared	1465	0	1465	d4ecc8e5-8576-46ad-b6ff-c0b45208d79e	2026-04-21 17:11:12.716239+00
65db3bd8-c552-4d1c-b084-ed4b9567f5ed	ad990edd-692d-4632-942d-73afbd8d983d	\N	2026-02-05	OFFICE & BANK CHARGES	shared	495	0	495	2b8aa542-5a94-4553-86a4-a7c91fa13798	2026-04-21 17:11:13.271035+00
0c688e2b-5f6a-42e8-a55a-c7af6d456ae7	18fe7103-10eb-45d5-ae04-a4619412d21f	\N	2026-02-11	HOUSE KEEPING	shared	570	0	570	d0af4c12-13e7-48f4-98f8-ed5aa5ed8bb9	2026-04-21 17:11:13.855922+00
045090b8-f014-4d9b-948f-c394ff362e4c	5aece965-88dc-46a6-ae1a-c6c2b7c2f7bd	\N	2026-02-11	TAX RADIO LICENSE	shared	1296	0	1296	c6ef3c34-26b4-4379-a979-15bf0f48df71	2026-04-21 17:11:14.41668+00
25457d9f-4472-46bd-9905-ce557f9d68e0	4394fe30-3fa3-4571-a4cd-75d67fadd193	\N	2026-03-02	BANK CHARGES	shared	7	0	7	64bdb517-2370-45d2-82f5-0d26cc9a97d2	2026-04-21 17:11:15.478262+00
46b4e399-7d52-47fa-af2a-4ab1f2ced137	7ae07315-b5e9-4ed8-9cba-f499c7975ccc	\N	2026-03-09	MOTOR VEHICLE LANDCO	shared	7384.37	0	7384.37	f5d6b151-a579-486e-aa8d-6a4d7b242ef4	2026-04-21 17:11:16.05756+00
a9d32d1c-f26f-4a3a-b9c8-924458b6bc08	4394fe30-3fa3-4571-a4cd-75d67fadd193	\N	2026-03-11	BANK CHARGES	shared	7	0	7	b63e52f7-2566-4e83-b643-f432f5f38501	2026-04-21 17:11:16.641824+00
b76607dc-0c97-420a-8b0d-26ae7a581344	124cee57-d69b-4097-8206-976644aa0923	\N	2026-03-17	BANK CHARGES	shared	600	0	600	08af3a5a-5054-463b-9849-69f9516fab4d	2026-04-21 17:11:17.185324+00
23e82d72-df30-48e8-96d9-5f43e8777415	2ba5a606-6a9e-4cab-96f0-c959b7bc78ca	\N	2026-03-18	INSURANCE JETSKI; INSURANCE TRAILER	shared	2819.36	0	2819.36	66dae584-41ba-4780-8003-cb4d173da95c	2026-04-21 17:11:17.735386+00
03f5d595-9602-4a52-9be7-7d4cd836a737	e04b6c92-a839-4896-918e-4c5857a044fe	\N	2026-03-19	MOTOR VEHICLES EXPENSES	H4	10500	0	10500	1cb99578-4d38-4d77-bdff-3540e48e9880	2026-04-21 17:11:18.309269+00
dcbbce11-eb7a-445a-a698-35f9a7702f74	55dbdbdc-95f0-492b-a279-1608751ec03a	\N	2026-03-23	SUSPENSE	shared	18889.39	0	18889.39	aab75988-68fb-4634-97b7-c9cfe0de6ea5	2026-04-21 17:11:18.924216+00
0b62706c-caa2-4cca-a933-9335b2134882	0217e2c2-1671-41ec-bb04-5e9070aac023	\N	2026-03-25	ACCOUNTING AND ADMIN	shared	146740	0	146740	a64976d7-0b33-4889-9ea1-63ae172fe546	2026-04-21 17:11:19.481818+00
fc247c6c-d0d9-4a28-ad90-47af8273edad	347dc5df-2a76-4f5d-97fb-99a4bb788a74	\N	2026-03-27	LAND TAX	shared	52850	0	52850	c7e89fa9-d9a9-45cc-8c29-6a0673a7d9ab	2026-04-21 17:11:20.038717+00
cae4fa9c-cecf-4d5a-a973-b92397ffb38b	d7fc63f7-a21b-40a8-910a-f056a56a5af0	\N	2026-03-27	GENERAL MAINTRENANCE	shared	1160	0	1160	2f5e4be7-3504-4e0b-ac21-27c42a0419ec	2026-04-21 17:11:20.620853+00
0522de2a-ef5f-4e19-9aca-bf98e9eb48c4	cc0dbaa3-dd9b-43fe-9188-bd9a44781c5a	\N	2026-03-30	SALARIES & WAGES; SALARIES & WAGES; SALARIES & WAGES; SALARIES & WAGES; SALARIES & WAGES	shared	13519.0352	0	13519.0352	766b41b6-beea-4245-825f-6405f709d467	2026-04-21 17:11:21.195173+00
6399f4a9-d8f0-4a80-9062-51bca7715de6	3d3f7965-5545-4579-aaab-045ff3cce2a3	\N	2026-03-30	INSURANCE	shared	30417.98	0	30417.98	42d826ae-c937-4ce5-94a8-83e4d2a01290	2026-04-21 17:11:21.738854+00
9a95f20a-0901-401a-9c61-e3644844314f	91c71f30-86dd-4722-83c4-2afa1f512ba9	\N	2026-03-01	STARLINK FOR FEB; COLLECT BUDGIE AT AIRPORT 25 FEB; PETTY CASH; PETTY CASH; PETTY CASH; HANDY ANDY, SUNLIGHT DOVE SOAP GUEST; FIX INTERNET OF CASA CAJU; Geraldo rubish Landco; 2 X ROAD CERTIFICATES @ 3000 EACH; 2 X ROAD CERTIFICATES @ 3000 EACH; 2 X ROAD CERTIFICATES @ 3000 EACH; FOOD WORKERS; CASUALS GARDEN ABLUTION PLUS PLANTS; PAVERS ABLUTION BLOCK; INSPECTION FEE MARINTINE BOATS; INSPECTION FEE MARINTINE BOATS; PETROL ALLOWANCE; SALARY MARCH	shared	99920	0	99920	ffd70777-be09-418c-9519-11635d62f689	2026-04-21 17:11:22.311387+00
ed3086a8-dd39-49e4-aaac-e99cc392d955	4394fe30-3fa3-4571-a4cd-75d67fadd193	\N	2026-02-04	Office expenses	shared	7	0	7	9123593a-5a0a-4e08-a00e-f7f94a5c2834	2026-04-21 17:11:09.462365+00
ecb70fa3-23ab-4e14-9fe2-750224a6053c	4394fe30-3fa3-4571-a4cd-75d67fadd193	\N	2026-02-10	Office expenses	shared	7	0	7	a0990117-2e10-4337-97ce-1bc4d4a253c3	2026-04-21 17:11:10.047292+00
8fd069c2-86a0-4164-870e-c966fcb40c11	60366f62-ac85-496e-be26-aff068680176	\N	2026-02-18	Accounting fee Feb	shared	37386.8	0	37386.8	3ccb8873-50fa-4c76-b90b-3389c162170e	2026-04-21 17:11:10.614215+00
ac9935f6-5a75-4759-8d62-4bd8eca5a6d4	46246d5f-743f-46ac-b5db-a29080c14442	\N	2026-02-23	Gas& Eletrisity	shared	4470.61	0	4470.61	a44a8505-6f69-4f3d-b3ba-c7379a2fe151	2026-04-21 17:11:11.197582+00
f1c2c164-caa8-4164-b872-920000211efd	c6a42f4f-ff70-48f8-8513-408ace12b930	\N	2026-02-23	INSURANCE JET SKI AND TRAILER	shared	1409.68	0	1409.68	4a92ba63-57f8-415f-97fa-421662784440	2026-04-21 17:11:11.761151+00
3098e7f6-dd31-41b9-bcec-1e399d2595ff	4394fe30-3fa3-4571-a4cd-75d67fadd193	\N	2026-02-25	Office expenses	shared	254	0	254	e26b6f3a-e7f5-473b-a653-a9330df61afa	2026-04-21 17:11:12.350171+00
7bdc7882-6d38-4cff-b40a-446f5372c549	112592b3-6026-49a9-90f6-5d8a705fdea1	\N	2026-02-27	General Maintenance	shared	1250	0	1250	88c35807-ef27-4641-91db-8f5bbf36d490	2026-04-21 17:11:12.896097+00
b994d0e4-00af-4538-9d43-0784a4dbe5fb	4b3c140b-4871-465a-baae-9806c0e4e492	\N	2026-02-09	HOUSE 4	H4	10068.8	0	10068.8	e60e8788-385c-473f-b58a-1dcc9dc0f511	2026-04-21 17:11:13.456147+00
0b006e8d-0e0e-4ac4-b853-4554cec5d6f4	31482388-64c6-467e-85c2-cc445993072e	\N	2026-02-11	HOUSE KEEPING HOUSE 1	H1	1030	0	1030	8b1b885c-402e-4498-bada-6e7644272a32	2026-04-21 17:11:14.042947+00
a35cd6b1-81a7-4b9d-82c5-ad1e00b3cdd5	fa43db45-e6b8-42e0-acc9-3824cf3db101	\N	2026-02-12	CELL FOR GUARDS SECURITY	shared	10500	0	10500	9cd81326-24e4-49dd-9b23-2f37738ba1c6	2026-04-21 17:11:14.61494+00
9ee67143-4379-4d5a-b825-e40fce1c9633	b47ca9fb-ac27-4492-a382-9d01b4574b78	\N	2026-01-06	GENERAL MAINENANCE	shared	1420.24	0	1420.24	c50729ec-109b-4981-b0ce-048a2991afe5	2026-04-21 17:11:01.113158+00
d24da972-500d-469f-a5c5-ffe55f5c9168	acec91b3-04c4-4a50-afd4-a09f37d3cb81	\N	2026-01-11	GAS & ELECTRISITY	shared	77851.16	0	77851.16	903ab038-9096-40de-8b85-b8e88ee7ad90	2026-04-21 17:11:01.683661+00
207dd865-5f64-4858-9a28-3017e8769ed3	ac2bc926-6f0e-4a34-9c44-b8f3d8761117	\N	2026-01-20	ACCOUNTING FEE	shared	37385.8	0	37385.8	d52e8430-d0e4-4e5a-8118-6015df6ec0c3	2026-04-21 17:11:02.255832+00
30a15b21-a222-4cd9-9d7e-f2826a1f0982	7e88fcb6-deec-4111-bcac-f999288427e2	\N	2026-01-22	BANK CHARGES OFFICE EXPENSES	shared	7	0	7	8a10746b-08e3-4821-807e-fcd472263cc4	2026-04-21 17:11:02.825064+00
39149ab2-f0d9-468e-b2f9-7e9fdfb512a5	0b08d6fb-be17-4b08-9c5a-87fb860a5a2b	\N	2026-01-23	SALARIES & WAGES; SALARIES & WAGES; SALARIES & WAGES; SALARIES & WAGES; SALARIES & WAGES	shared	346473	0	346473	51b73b94-6be3-4e8a-8457-0b8482d8dee3	2026-04-21 17:11:03.405573+00
556153a9-2f3b-4c56-a19c-768ff34292fd	cc0dbaa3-dd9b-43fe-9188-bd9a44781c5a	\N	2026-01-26	SALARIES$ WAGES; SALARIES$ WAGES; SALARIES$ WAGES; SALARIES$ WAGES; SALARIES$ WAGES	shared	13858.920000000002	0	13858.920000000002	43b5c163-357c-4eaf-ab87-1f00105aff62	2026-04-21 17:11:04.015682+00
27c2b011-a4a7-4296-a27a-bbdcca2e912b	7e88fcb6-deec-4111-bcac-f999288427e2	\N	2026-01-29	BANKCHARGES OFFICE EXPENSES	shared	7	0	7	deceee25-3803-4fca-a562-0d240cfa77c9	2026-04-21 17:11:04.596687+00
9bc79465-cf27-4831-a5e0-ae9a3062c35c	ad990edd-692d-4632-942d-73afbd8d983d	\N	2026-01-06	OFFICE & BANK CHARGES	shared	575	0	575	28f1a09f-fecf-48ba-b1f6-939df1708942	2026-04-21 17:11:05.162997+00
36666fbb-2df1-4a3d-8a52-20d7cc60c23d	53d555c4-2150-46aa-9257-225cc5ae443e	\N	2026-01-22	SUSPENCE	shared	-10000	0	-10000	7b2765a3-4712-4cec-a269-5ca9d3f57d5a	2026-04-21 17:11:05.741267+00
e62a5d42-2f9a-4586-91da-d34f88a1ec70	a66d5a83-cfe4-4c2f-946f-9fb5a8cc66b3	\N	2026-01-23	NEW BUILDING	H3	10208	0	10208	e202902a-cc37-4098-9907-0d24efd1c24c	2026-04-21 17:11:06.364555+00
f33a27a1-e59d-4911-8c4d-16ce2f2fceff	12801d54-43d3-4c13-9908-f12cdf1264b5	\N	2026-01-03	MONEY FOR OPERATION	shared	3000	0	3000	e6e26b0e-f7a7-4236-8251-166c368d9ab6	2026-04-21 17:11:06.955362+00
9fc53714-b5e4-46c7-ba59-8acced3bdc0f	2f22bd97-40d9-48c2-8788-a85c2b9de832	\N	2026-01-30	RAYMONDO FOR ACCOMMODATION 9 DAY @1500	shared	9000	0	9000	d188ef75-2204-43e0-878a-bb6f0d01add1	2026-04-21 17:11:07.515639+00
771a6ce4-ae87-4897-92cb-b82a6091856e	61c5253c-1b4e-4265-9600-74983e13a91f	\N	2026-01-31	BEBE LEAVE ONE WEEK DOUG	shared	21440	0	21440	3090a957-25f8-4b24-a2c4-6bc505154216	2026-04-21 17:11:08.081471+00
8799eaa1-39e4-4142-969c-1c0d75876c02	4394fe30-3fa3-4571-a4cd-75d67fadd193	\N	2026-03-05	BANK CHARGES; BANK CHARGES	shared	127	0	127	060ee2e9-e3e4-4a5a-a517-472f03358b89	2026-04-21 17:11:15.652629+00
252d82c4-87ba-4df7-98c3-b0d3064aa873	c4a44fa6-9c99-411c-a7be-e50d9f6cf278	\N	2026-03-09	HOUSE KEEPING	shared	5245	0	5245	d6073f74-fbdf-401c-ba06-811e27b70b91	2026-04-21 17:11:16.250982+00
3f181634-e6e4-4ce4-a9ef-605830dd46ca	343addbf-b523-422b-87c7-e6c68dc2da37	\N	2026-03-16	SWIMMING POOL CHEMICALS	shared	8710	0	8710	cad757fa-1fbf-4f44-b1b8-4eed2323eace	2026-04-21 17:11:16.826272+00
0a6badeb-aa7b-4fab-b81f-18b26a153c20	60366f62-ac85-496e-be26-aff068680176	\N	2026-03-18	ADMIN AND ACCOUNTING	shared	37386	0	37386	d0d84e82-3b1d-4736-8314-c2146d304b1e	2026-04-21 17:11:17.372973+00
790a4c30-a0f0-4ea6-8666-c5ed913b5f37	1438ad87-5882-41a2-8f9d-4ea75a808d2d	\N	2026-03-19	GENERAL EXPENSES	shared	788	0	788	12b7484a-9f99-4ef7-99b5-52568b17bd51	2026-04-21 17:11:17.93237+00
28363542-55f6-4381-b318-2c1f570b3d2a	74912e55-b48a-44a6-b90a-386a9e5debae	\N	2026-03-19	GENERAL EXPENSES	H3	5688	0	5688	6a995698-36ae-4f74-b00e-dc91e3a13b5f	2026-04-21 17:11:18.5027+00
ac82100d-b5e2-44b9-9887-1ef530c6177e	3ce821ee-9aa3-4293-b6e2-9f4842e09cc0	\N	2026-03-25	SALARIES & WAGES; SALARIES & WAGES; SALARIES & WAGES; SALARIES & WAGES; SALARIES & WAGES	shared	337975.88	0	337975.88	387d60f6-d031-4ab0-b420-cc1ba73bc5a8	2026-04-21 17:11:19.110073+00
87e7b58d-ef77-41ff-8add-8fd6947a188d	1d4ed829-0e19-43ba-ae41-d60637640363	\N	2026-03-26	GENERAL MAITENANCE	shared	1440	0	1440	65a1e181-cd13-4ab6-9f4a-99badc3afa6e	2026-04-21 17:11:19.665457+00
75f6e0ae-1ef1-49ae-b41d-b03c8874613c	7c7e56d0-1ed5-4ef6-b7ae-a6b3b89a8742	\N	2026-03-27	LAND TAX	shared	10300	0	10300	d2b9f3f8-ea34-4825-8ec8-3559a8ecf194	2026-04-21 17:11:20.242891+00
76286180-d284-4f8c-9ffe-a1dfc053f73c	84442e48-d370-4924-8974-d5db5cb63133	\N	2026-03-30	MOTOR VEHICLES EXPENSES	shared	5385.02	0	5385.02	f1655b41-b117-4a2a-b1ff-aabaf33aaa3d	2026-04-21 17:11:20.808653+00
343ff3c1-bc30-4d6a-86b7-ad8c54ac62ff	82051c46-e037-4ba0-a833-aabded996229	\N	2026-03-30	INSURANCE	shared	277172.71	0	277172.71	f856d264-214f-4fd0-9d02-86c40199bdb0	2026-04-21 17:11:21.380263+00
071189c5-f916-42c1-8b2d-69c153d9b43a	9dcc6cdb-7402-4e54-8e74-6e8b7241ffd4	\N	2026-03-31	GAS & ELECTRISITY	shared	3800.61	0	3800.61	1d69d281-e4f4-40ba-8d74-63a26b1ed986	2026-04-21 17:11:21.927942+00
\.


--
-- Data for Name: suppliers; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.suppliers (id, name, created_at) FROM stdin;
ad990edd-692d-4632-942d-73afbd8d983d	DOCUMENTS TO MAPUTO	2026-04-21 17:10:33.613348+00
61c5253c-1b4e-4265-9600-74983e13a91f	BEBE	2026-04-21 17:10:33.613348+00
33a631c5-f1b0-4e33-b0eb-e8dc5271e170	FINE ON LATE PY OF 2023	2026-04-21 17:10:33.613348+00
53d555c4-2150-46aa-9257-225cc5ae443e	TRANSFER FROM CHEQUE ACCOUNT	2026-04-21 17:10:33.613348+00
31974de8-c63a-42c9-a75c-00c7dfb2e4e7	TRANSFER TO PRE-PAID	2026-04-21 17:10:33.613348+00
9cd40e82-b1d9-42f5-93fc-3ccbde9f42e2	SAND PAPER & LUBRICATE SPRAY	2026-04-21 17:10:33.613348+00
a66d5a83-cfe4-4c2f-946f-9fb5a8cc66b3	STEEL FOR SECURITY DOOR	2026-04-21 17:10:33.613348+00
a4c4b098-6d24-4048-ae39-9bbb473c3a24	TRANSFER	2026-04-21 17:10:33.613348+00
1e5ac5e4-e388-4c09-846c-f09d3f639170	ALEX	2026-04-21 17:10:33.613348+00
12801d54-43d3-4c13-9908-f12cdf1264b5	EUZEBIO	2026-04-21 17:10:33.613348+00
0eac37ae-c535-4e60-aa94-f3d043b93629	MATIAS	2026-04-21 17:10:33.613348+00
2f22bd97-40d9-48c2-8788-a85c2b9de832	WELDER	2026-04-21 17:10:33.613348+00
e75e5673-3e49-43d3-84f1-cf863679b36d	CHRIS	2026-04-21 17:10:33.613348+00
473bc493-c937-49d4-bc71-d4853c9c8d80	WARREN	2026-04-21 17:10:33.613348+00
2ba5a606-6a9e-4cab-96f0-c959b7bc78ca	IMPRA	2026-04-21 17:11:15.341984+00
98e939c5-4546-4098-be75-15ce04fa5e0b	ENH DECEMBER	2026-04-19 14:31:23.801922+00
c5c34717-45a5-431c-8df6-8e34793ded90	TRANSFER FROM DOLLAR ACCOUNT	2026-04-19 14:31:23.801922+00
b47ca9fb-ac27-4492-a382-9d01b4574b78	PAINT STEEL	2026-04-19 14:31:23.801922+00
3aa3e607-5c3e-474f-a69f-77c120db2228	WARREN STEAD	2026-04-19 14:31:23.801922+00
acec91b3-04c4-4a50-afd4-a09f37d3cb81	ELECTRICITY DECEMBER	2026-04-19 14:31:23.801922+00
cddb8673-fce8-4b42-9ce6-2a7b1dac54cb	FELIX ADVANCE	2026-04-19 14:31:23.801922+00
1ae99c0b-49de-4d27-8ca2-908a397909db	ADVANCE JELSON	2026-04-19 14:31:23.801922+00
ac2bc926-6f0e-4a34-9c44-b8f3d8761117	ACCOUNTING FEE JANUARY	2026-04-19 14:31:23.801922+00
b4f05ab1-8ccf-49c8-b062-4d3c36beb7c9	FILES	2026-04-19 14:31:23.801922+00
6be23fa2-f91e-460e-a64a-844e1f0d81a8	COTOVELO PVC	2026-04-19 14:31:23.801922+00
9d0c48c8-6dd5-4668-ac50-0bc5dd9844d0	TRANSFER TO PETTY CASH	2026-04-19 14:31:23.801922+00
0b08d6fb-be17-4b08-9c5a-87fb860a5a2b	SALARIES JANUARY	2026-04-19 14:31:23.801922+00
dde88162-f764-4ef4-9e92-cb0a5532daa0	BREAD	2026-04-19 14:31:23.801922+00
9d6680f6-0968-4b57-aee7-7a4c760ffc90	DILUENTE ESMALTE QD 750ML	2026-04-19 14:31:23.801922+00
330988e7-e2a7-4aa8-a4a8-0161cd9eb743	GAS JANUARY	2026-04-19 14:31:23.801922+00
7e88fcb6-deec-4111-bcac-f999288427e2	TRANSFER FEE	2026-04-19 14:31:23.801922+00
24822ced-7a0e-47b1-9d94-ee878f7941e9	LESCO - CX PROVA DE AGUA 4X4	2026-04-19 14:31:23.801922+00
b96ac2c2-8f23-4f6e-9f41-fa224bdd58af	2 TOMADA SA E 2 CX 4X4	2026-04-19 14:31:23.801922+00
43a1e5c4-7c37-496d-965c-cd7844f3e18d	Leave	2026-04-19 14:31:23.801922+00
af047d34-7d63-48dd-96d0-a15c8445f1b7	Quimical swimming pools	2026-04-19 14:31:23.801922+00
f49c1e3a-251a-4ca6-89d5-f419b1740d17	Union Fee	2026-04-19 14:31:23.801922+00
3e3b669c-5068-40d9-8684-99403c4534f5	Electrisity	2026-04-19 14:31:23.801922+00
345d2f53-dff6-4b2d-80b0-730b6e7fac80	Diesel Generator	2026-04-19 14:31:23.801922+00
0f632ac6-e0e2-46e0-9344-af53470603fb	Advance	2026-04-19 14:31:23.801922+00
b290501f-2e93-4a3a-ae46-1e0182107eb7	Accounting	2026-04-19 14:31:23.801922+00
13aafcd0-3539-485a-b733-5cb1db3357b5	Admin Fee	2026-04-19 14:31:23.801922+00
46246d5f-743f-46ac-b5db-a29080c14442	Gas Jan	2026-04-19 14:31:23.801922+00
c71c6ca1-deca-4962-9ba2-556fa5665c3e	House Kepping Towel Duck	2026-04-19 14:31:23.801922+00
c6a42f4f-ff70-48f8-8513-408ace12b930	SIM R SEG	2026-04-19 14:31:23.801922+00
344c1fd1-ff52-4a5f-b111-9d31b82bc1ee	Revisao de Extintores	2026-04-19 14:31:23.801922+00
099ecc18-4193-4e3a-a676-b0e0f1da35d3	Dolar to Mets	2026-04-19 14:31:23.801922+00
a5c1b88b-de7e-436f-96d0-08f589b70c39	Salario Feb	2026-04-19 14:31:23.801922+00
e7261771-3861-41ed-8947-3e98843099d7	Bank Charges	2026-04-19 14:31:23.801922+00
39794824-e458-47f3-b076-724c761cd613	Cleaning supplies	2026-04-19 14:31:23.801922+00
579876ff-a647-4bf8-a2ae-d16dca403d5d	Eletrical material	2026-04-19 14:31:23.801922+00
112592b3-6026-49a9-90f6-5d8a705fdea1	Lampadas	2026-04-19 14:31:23.801922+00
91cf2e45-c87a-4070-af9c-8bc445a8c9c4	SINDICATO FEB	2026-04-19 14:31:23.801922+00
c920bb7c-f061-4d71-ae0f-79b2f5e8b202	INSS FEB	2026-04-19 14:31:23.801922+00
d40b81d8-5b3a-47e9-bd42-ef76dc96a7c2	IRPS FEB	2026-04-19 14:31:23.801922+00
82b664e0-ab38-486c-ac0e-aa193b1c7044	JELSON	2026-04-19 14:31:23.801922+00
ee61781c-4cf7-4ffa-aef4-452c7c8c5788	EMILIO ADVANCE	2026-04-19 14:31:23.801922+00
bcc6dae9-d134-4c58-85ed-92555e4d6c82	TAFY ACCOMMODATION	2026-04-19 14:31:23.801922+00
a847c4ff-01e1-4cad-9354-4c76c03da27c	CALDERON ADVANCE	2026-04-19 14:31:23.801922+00
ac39dbb1-0adf-4855-8e50-fddd757b9adb	VARNISH	2026-04-19 14:31:23.801922+00
7ae07315-b5e9-4ed8-9cba-f499c7975ccc	DIESEL MMR0998	2026-04-19 14:31:23.801922+00
c4a44fa6-9c99-411c-a7be-e50d9f6cf278	TOILET PAPER	2026-04-19 14:31:23.801922+00
964550a4-a9f3-4e9e-88bb-141f9739cc4d	ELECTRICITY	2026-04-19 14:31:23.801922+00
343addbf-b523-422b-87c7-e6c68dc2da37	CHLOOR	2026-04-19 14:31:23.801922+00
da8da653-15c1-445c-857b-8fd8013f1871	PLASTIC DE LUXO	2026-04-19 14:31:23.801922+00
124cee57-d69b-4097-8206-976644aa0923	CARTO DEBITO	2026-04-19 14:31:23.801922+00
60366f62-ac85-496e-be26-aff068680176	ACCOUNTING	2026-04-19 14:31:23.801922+00
8d305227-9253-4ea8-a700-abc888fb4554	INSURANCE	2026-04-19 14:31:23.801922+00
1438ad87-5882-41a2-8f9d-4ea75a808d2d	BALDE PARA CONSTRUTOR	2026-04-19 14:31:23.801922+00
13141623-b36e-4a2d-bfef-dc910502c7ee	CLEANING MATERIAL	2026-04-19 14:31:23.801922+00
e04b6c92-a839-4896-918e-4c5857a044fe	BATTERY PRADO H4	2026-04-19 14:31:23.801922+00
74912e55-b48a-44a6-b90a-386a9e5debae	SEALER H3	2026-04-19 14:31:23.801922+00
55dbdbdc-95f0-492b-a279-1608751ec03a	PETTY CASH	2026-04-19 14:31:23.801922+00
3ce821ee-9aa3-4293-b6e2-9f4842e09cc0	SALARY MARCH	2026-04-19 14:31:23.801922+00
0217e2c2-1671-41ec-bb04-5e9070aac023	ADMIN FEE	2026-04-19 14:31:23.801922+00
f76c3172-6dec-48ab-83b5-5d5f2d837f97	ACCOMMODATION ADVANCE APRIL	2026-04-19 14:31:23.801922+00
1d4ed829-0e19-43ba-ae41-d60637640363	LIGHTS OUTSIDE	2026-04-19 14:31:23.801922+00
f5c7ff56-196c-4b86-a53f-c3409b6b9bb8	SINDICATO	2026-04-19 14:31:23.801922+00
06e8628c-90aa-45a7-8473-1c4e70e32f51	SOAP, JAVEL	2026-04-19 14:31:23.801922+00
347dc5df-2a76-4f5d-97fb-99a4bb788a74	IPRA 2026	2026-04-19 14:31:23.801922+00
7c7e56d0-1ed5-4ef6-b7ae-a6b3b89a8742	TAE	2026-04-19 14:31:23.801922+00
99c371ca-ebd5-467a-a592-0de9eb0f1714	DIESEL GENERATOR	2026-04-19 14:31:23.801922+00
d7fc63f7-a21b-40a8-910a-f056a56a5af0	Q20 OIL ANTI RUST	2026-04-19 14:31:23.801922+00
84442e48-d370-4924-8974-d5db5cb63133	DIESEL TOYOTA AKL491MP	2026-04-19 14:31:23.801922+00
62482dfc-01ab-4c6d-99f1-aab184636127	DIESEL PRADO HOUSE 4	2026-04-19 14:31:23.801922+00
cc0dbaa3-dd9b-43fe-9188-bd9a44781c5a	INSS	2026-04-19 14:31:23.801922+00
e65762e4-005d-400f-ae75-669a807e959f	TRANSFER DOLLARS TO METICAIS	2026-04-19 14:31:23.801922+00
82051c46-e037-4ba0-a833-aabded996229	INSURANCE VEHICLES	2026-04-19 14:31:23.801922+00
3d3f7965-5545-4579-aaab-045ff3cce2a3	WORKMENS COMPENSATIO	2026-04-19 14:31:23.801922+00
4394fe30-3fa3-4571-a4cd-75d67fadd193	BANK CHARGES	2026-04-19 14:31:23.801922+00
9dcc6cdb-7402-4e54-8e74-6e8b7241ffd4	GAS FEBRUARY	2026-04-19 14:31:23.801922+00
952bf65f-1f2f-494d-a7a0-f8607f3bf34c	GLOBES	2026-04-19 14:31:23.801922+00
d4d79f53-4a55-4a46-98d1-23129c8ba212	IRPS	2026-04-19 14:31:23.801922+00
91c71f30-86dd-4722-83c4-2afa1f512ba9	UNKNOWN SUPPLIER	2026-04-21 17:11:08.913201+00
4b3c140b-4871-465a-baae-9806c0e4e492	FISH  BODYBOARD	2026-04-21 17:11:08.913201+00
8a4c2318-cbce-4d7e-9e88-6eaf3f66407a	WINDO CLEAN	2026-04-21 17:11:08.913201+00
18fe7103-10eb-45d5-ae04-a4619412d21f	SUNLIGHT	2026-04-21 17:11:08.913201+00
31482388-64c6-467e-85c2-cc445993072e	SOAP	2026-04-21 17:11:08.913201+00
92573ad4-efa4-448c-bedf-6cc77e85e775	IMPOSTOS VEICULOS	2026-04-21 17:11:08.913201+00
5aece965-88dc-46a6-ae1a-c6c2b7c2f7bd	TAX RADIO LICENSE	2026-04-21 17:11:08.913201+00
fa43db45-e6b8-42e0-acc9-3824cf3db101	TECNO 40 X 2	2026-04-21 17:11:08.913201+00
\.


--
-- Data for Name: user_roles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_roles (id, user_id, role) FROM stdin;
3d0bb8e1-04ef-4b07-8052-544f94f522af	0ed252b7-ad3b-4b83-9210-4250da9bd291	admin
a240f5ad-bb65-47ca-a13f-709a8cf6f42f	b0146922-1ddd-4a77-a9c6-8b70a114f852	admin
15fecb34-b089-4745-a10f-42a89c54e9a4	65607621-db72-4d57-9900-6cb4a77e0828	admin
9d96c08c-3137-4114-a1c5-6a75cf6fc538	f382f145-118b-4b82-b510-b88c634efd0e	admin
\.


--
-- Name: invoice_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.invoice_seq', 1, false);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: auth; Owner: postgres
--

ALTER TABLE ONLY auth.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: auth; Owner: postgres
--

ALTER TABLE ONLY auth.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: accounting_periods accounting_periods_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.accounting_periods
    ADD CONSTRAINT accounting_periods_pkey PRIMARY KEY (id);


--
-- Name: accounting_periods accounting_periods_year_month_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.accounting_periods
    ADD CONSTRAINT accounting_periods_year_month_key UNIQUE (year, month);


--
-- Name: accounts accounts_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.accounts
    ADD CONSTRAINT accounts_code_key UNIQUE (code);


--
-- Name: accounts accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.accounts
    ADD CONSTRAINT accounts_pkey PRIMARY KEY (id);


--
-- Name: bank_accounts bank_accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bank_accounts
    ADD CONSTRAINT bank_accounts_pkey PRIMARY KEY (id);


--
-- Name: bank_opening_balances bank_opening_balances_bank_account_id_month_year_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bank_opening_balances
    ADD CONSTRAINT bank_opening_balances_bank_account_id_month_year_key UNIQUE (bank_account_id, month, year);


--
-- Name: bank_opening_balances bank_opening_balances_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bank_opening_balances
    ADD CONSTRAINT bank_opening_balances_pkey PRIMARY KEY (id);


--
-- Name: bank_transactions bank_transactions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bank_transactions
    ADD CONSTRAINT bank_transactions_pkey PRIMARY KEY (id);


--
-- Name: bim_salary_transfers bim_salary_transfers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bim_salary_transfers
    ADD CONSTRAINT bim_salary_transfers_pkey PRIMARY KEY (id);


--
-- Name: cash_allocation_columns cash_allocation_columns_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cash_allocation_columns
    ADD CONSTRAINT cash_allocation_columns_pkey PRIMARY KEY (id);


--
-- Name: cash_allocation_columns cash_allocation_columns_sheet_type_column_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cash_allocation_columns
    ADD CONSTRAINT cash_allocation_columns_sheet_type_column_name_key UNIQUE (sheet_type, column_name);


--
-- Name: cash_dropdown_options cash_dropdown_options_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cash_dropdown_options
    ADD CONSTRAINT cash_dropdown_options_pkey PRIMARY KEY (id);


--
-- Name: cash_dropdown_options cash_dropdown_options_sheet_type_column_key_value_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cash_dropdown_options
    ADD CONSTRAINT cash_dropdown_options_sheet_type_column_key_value_key UNIQUE (sheet_type, column_key, value);


--
-- Name: cash_sheets cash_sheets_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cash_sheets
    ADD CONSTRAINT cash_sheets_pkey PRIMARY KEY (id);


--
-- Name: cash_sheets cash_sheets_sheet_type_month_year_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cash_sheets
    ADD CONSTRAINT cash_sheets_sheet_type_month_year_key UNIQUE (sheet_type, month, year);


--
-- Name: cash_transactions cash_transactions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cash_transactions
    ADD CONSTRAINT cash_transactions_pkey PRIMARY KEY (id);


--
-- Name: employees employees_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employees
    ADD CONSTRAINT employees_pkey PRIMARY KEY (id);


--
-- Name: exchange_rates exchange_rates_month_year_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.exchange_rates
    ADD CONSTRAINT exchange_rates_month_year_key UNIQUE (month, year);


--
-- Name: exchange_rates exchange_rates_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.exchange_rates
    ADD CONSTRAINT exchange_rates_pkey PRIMARY KEY (id);


--
-- Name: expense_categories expense_categories_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.expense_categories
    ADD CONSTRAINT expense_categories_name_key UNIQUE (name);


--
-- Name: expense_categories expense_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.expense_categories
    ADD CONSTRAINT expense_categories_pkey PRIMARY KEY (id);


--
-- Name: expense_transactions expense_transactions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.expense_transactions
    ADD CONSTRAINT expense_transactions_pkey PRIMARY KEY (id);


--
-- Name: import_log import_log_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.import_log
    ADD CONSTRAINT import_log_pkey PRIMARY KEY (id);


--
-- Name: income_transactions income_transactions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.income_transactions
    ADD CONSTRAINT income_transactions_pkey PRIMARY KEY (id);


--
-- Name: inss_payments inss_payments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.inss_payments
    ADD CONSTRAINT inss_payments_pkey PRIMARY KEY (id);


--
-- Name: invoices invoices_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_pkey PRIMARY KEY (id);


--
-- Name: irps_payments irps_payments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.irps_payments
    ADD CONSTRAINT irps_payments_pkey PRIMARY KEY (id);


--
-- Name: journal_entries journal_entries_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.journal_entries
    ADD CONSTRAINT journal_entries_pkey PRIMARY KEY (id);


--
-- Name: journal_lines journal_lines_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.journal_lines
    ADD CONSTRAINT journal_lines_pkey PRIMARY KEY (id);


--
-- Name: petty_cash_transactions petty_cash_transactions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.petty_cash_transactions
    ADD CONSTRAINT petty_cash_transactions_pkey PRIMARY KEY (id);


--
-- Name: profiles profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.profiles
    ADD CONSTRAINT profiles_pkey PRIMARY KEY (id);


--
-- Name: profiles profiles_user_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.profiles
    ADD CONSTRAINT profiles_user_id_key UNIQUE (user_id);


--
-- Name: properties properties_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.properties
    ADD CONSTRAINT properties_code_key UNIQUE (code);


--
-- Name: properties properties_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.properties
    ADD CONSTRAINT properties_pkey PRIMARY KEY (id);


--
-- Name: salary_advances salary_advances_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.salary_advances
    ADD CONSTRAINT salary_advances_pkey PRIMARY KEY (id);


--
-- Name: salary_lines salary_lines_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.salary_lines
    ADD CONSTRAINT salary_lines_pkey PRIMARY KEY (id);


--
-- Name: salary_runs salary_runs_month_year_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.salary_runs
    ADD CONSTRAINT salary_runs_month_year_key UNIQUE (month, year);


--
-- Name: salary_runs salary_runs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.salary_runs
    ADD CONSTRAINT salary_runs_pkey PRIMARY KEY (id);


--
-- Name: shareholder_balances shareholder_balances_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shareholder_balances
    ADD CONSTRAINT shareholder_balances_pkey PRIMARY KEY (id);


--
-- Name: shareholder_balances shareholder_balances_shareholder_id_property_id_month_year_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shareholder_balances
    ADD CONSTRAINT shareholder_balances_shareholder_id_property_id_month_year_key UNIQUE (shareholder_id, property_id, month, year);


--
-- Name: shareholders shareholders_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shareholders
    ADD CONSTRAINT shareholders_pkey PRIMARY KEY (id);


--
-- Name: supplier_invoices supplier_invoices_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.supplier_invoices
    ADD CONSTRAINT supplier_invoices_pkey PRIMARY KEY (id);


--
-- Name: suppliers suppliers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.suppliers
    ADD CONSTRAINT suppliers_pkey PRIMARY KEY (id);


--
-- Name: user_roles user_roles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_roles
    ADD CONSTRAINT user_roles_pkey PRIMARY KEY (id);


--
-- Name: user_roles user_roles_user_id_role_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_roles
    ADD CONSTRAINT user_roles_user_id_role_key UNIQUE (user_id, role);


--
-- Name: idx_cash_dropdown_lookup; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_cash_dropdown_lookup ON public.cash_dropdown_options USING btree (sheet_type, column_key);


--
-- Name: idx_cash_tx_funder; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_cash_tx_funder ON public.cash_transactions USING btree (funder);


--
-- Name: idx_cash_tx_receiver; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_cash_tx_receiver ON public.cash_transactions USING btree (receiver);


--
-- Name: idx_cash_tx_sheet; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_cash_tx_sheet ON public.cash_transactions USING btree (sheet_type, year, month);


--
-- Name: cash_sheets trg_cash_sheets_updated; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_cash_sheets_updated BEFORE UPDATE ON public.cash_sheets FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: cash_transactions trg_cash_tx_updated; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_cash_tx_updated BEFORE UPDATE ON public.cash_transactions FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: invoices trg_invoices_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_invoices_updated_at BEFORE UPDATE ON public.invoices FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: bank_opening_balances update_bank_opening_balances_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_bank_opening_balances_updated_at BEFORE UPDATE ON public.bank_opening_balances FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: employees update_employees_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_employees_updated_at BEFORE UPDATE ON public.employees FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: profiles update_profiles_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_profiles_updated_at BEFORE UPDATE ON public.profiles FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: properties update_properties_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_properties_updated_at BEFORE UPDATE ON public.properties FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: shareholders update_shareholders_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_shareholders_updated_at BEFORE UPDATE ON public.shareholders FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: bank_opening_balances bank_opening_balances_bank_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bank_opening_balances
    ADD CONSTRAINT bank_opening_balances_bank_account_id_fkey FOREIGN KEY (bank_account_id) REFERENCES public.bank_accounts(id) ON DELETE CASCADE;


--
-- Name: bank_transactions bank_transactions_bank_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bank_transactions
    ADD CONSTRAINT bank_transactions_bank_account_id_fkey FOREIGN KEY (bank_account_id) REFERENCES public.bank_accounts(id);


--
-- Name: bank_transactions bank_transactions_journal_entry_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bank_transactions
    ADD CONSTRAINT bank_transactions_journal_entry_id_fkey FOREIGN KEY (journal_entry_id) REFERENCES public.journal_entries(id);


--
-- Name: bim_salary_transfers bim_salary_transfers_employee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bim_salary_transfers
    ADD CONSTRAINT bim_salary_transfers_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES public.employees(id);


--
-- Name: bim_salary_transfers bim_salary_transfers_salary_run_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bim_salary_transfers
    ADD CONSTRAINT bim_salary_transfers_salary_run_id_fkey FOREIGN KEY (salary_run_id) REFERENCES public.salary_runs(id);


--
-- Name: cash_transactions cash_transactions_sheet_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cash_transactions
    ADD CONSTRAINT cash_transactions_sheet_id_fkey FOREIGN KEY (sheet_id) REFERENCES public.cash_sheets(id) ON DELETE CASCADE;


--
-- Name: expense_categories expense_categories_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.expense_categories
    ADD CONSTRAINT expense_categories_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES public.expense_categories(id);


--
-- Name: expense_transactions expense_transactions_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.expense_transactions
    ADD CONSTRAINT expense_transactions_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.expense_categories(id);


--
-- Name: expense_transactions expense_transactions_journal_entry_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.expense_transactions
    ADD CONSTRAINT expense_transactions_journal_entry_id_fkey FOREIGN KEY (journal_entry_id) REFERENCES public.journal_entries(id);


--
-- Name: expense_transactions expense_transactions_property_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.expense_transactions
    ADD CONSTRAINT expense_transactions_property_id_fkey FOREIGN KEY (property_id) REFERENCES public.properties(id);


--
-- Name: expense_transactions expense_transactions_shareholder_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.expense_transactions
    ADD CONSTRAINT expense_transactions_shareholder_id_fkey FOREIGN KEY (shareholder_id) REFERENCES public.shareholders(id);


--
-- Name: import_log import_log_imported_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.import_log
    ADD CONSTRAINT import_log_imported_by_fkey FOREIGN KEY (imported_by) REFERENCES auth.users(id);


--
-- Name: income_transactions income_transactions_journal_entry_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.income_transactions
    ADD CONSTRAINT income_transactions_journal_entry_id_fkey FOREIGN KEY (journal_entry_id) REFERENCES public.journal_entries(id);


--
-- Name: income_transactions income_transactions_property_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.income_transactions
    ADD CONSTRAINT income_transactions_property_id_fkey FOREIGN KEY (property_id) REFERENCES public.properties(id);


--
-- Name: invoices invoices_journal_entry_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_journal_entry_id_fkey FOREIGN KEY (journal_entry_id) REFERENCES public.journal_entries(id);


--
-- Name: journal_lines journal_lines_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.journal_lines
    ADD CONSTRAINT journal_lines_account_id_fkey FOREIGN KEY (account_id) REFERENCES public.accounts(id);


--
-- Name: journal_lines journal_lines_journal_entry_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.journal_lines
    ADD CONSTRAINT journal_lines_journal_entry_id_fkey FOREIGN KEY (journal_entry_id) REFERENCES public.journal_entries(id) ON DELETE CASCADE;


--
-- Name: petty_cash_transactions petty_cash_transactions_journal_entry_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.petty_cash_transactions
    ADD CONSTRAINT petty_cash_transactions_journal_entry_id_fkey FOREIGN KEY (journal_entry_id) REFERENCES public.journal_entries(id);


--
-- Name: salary_advances salary_advances_employee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.salary_advances
    ADD CONSTRAINT salary_advances_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES public.employees(id);


--
-- Name: salary_lines salary_lines_employee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.salary_lines
    ADD CONSTRAINT salary_lines_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES public.employees(id);


--
-- Name: salary_lines salary_lines_salary_run_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.salary_lines
    ADD CONSTRAINT salary_lines_salary_run_id_fkey FOREIGN KEY (salary_run_id) REFERENCES public.salary_runs(id) ON DELETE CASCADE;


--
-- Name: salary_runs salary_runs_journal_entry_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.salary_runs
    ADD CONSTRAINT salary_runs_journal_entry_id_fkey FOREIGN KEY (journal_entry_id) REFERENCES public.journal_entries(id);


--
-- Name: shareholder_balances shareholder_balances_property_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shareholder_balances
    ADD CONSTRAINT shareholder_balances_property_id_fkey FOREIGN KEY (property_id) REFERENCES public.properties(id);


--
-- Name: shareholder_balances shareholder_balances_shareholder_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shareholder_balances
    ADD CONSTRAINT shareholder_balances_shareholder_id_fkey FOREIGN KEY (shareholder_id) REFERENCES public.shareholders(id);


--
-- Name: shareholders shareholders_property_code_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shareholders
    ADD CONSTRAINT shareholders_property_code_fkey FOREIGN KEY (property_code) REFERENCES public.properties(code);


--
-- Name: supplier_invoices supplier_invoices_journal_entry_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.supplier_invoices
    ADD CONSTRAINT supplier_invoices_journal_entry_id_fkey FOREIGN KEY (journal_entry_id) REFERENCES public.journal_entries(id);


--
-- Name: supplier_invoices supplier_invoices_supplier_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.supplier_invoices
    ADD CONSTRAINT supplier_invoices_supplier_id_fkey FOREIGN KEY (supplier_id) REFERENCES public.suppliers(id);


--
-- Name: accounting_periods Admins can manage accounting_periods; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Admins can manage accounting_periods" ON public.accounting_periods TO authenticated USING (public.has_role(auth.uid(), 'admin'::public.app_role)) WITH CHECK (public.has_role(auth.uid(), 'admin'::public.app_role));


--
-- Name: accounts Admins can manage accounts; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Admins can manage accounts" ON public.accounts TO authenticated USING (public.has_role(auth.uid(), 'admin'::public.app_role)) WITH CHECK (public.has_role(auth.uid(), 'admin'::public.app_role));


--
-- Name: shareholder_balances Admins can manage balances; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Admins can manage balances" ON public.shareholder_balances TO authenticated USING (public.has_role(auth.uid(), 'admin'::public.app_role));


--
-- Name: bank_accounts Admins can manage bank_accounts; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Admins can manage bank_accounts" ON public.bank_accounts TO authenticated USING (public.has_role(auth.uid(), 'admin'::public.app_role));


--
-- Name: bank_opening_balances Admins can manage bank_opening_balances; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Admins can manage bank_opening_balances" ON public.bank_opening_balances TO authenticated USING (public.has_role(auth.uid(), 'admin'::public.app_role)) WITH CHECK (public.has_role(auth.uid(), 'admin'::public.app_role));


--
-- Name: bank_transactions Admins can manage bank_tx; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Admins can manage bank_tx" ON public.bank_transactions TO authenticated USING (public.has_role(auth.uid(), 'admin'::public.app_role));


--
-- Name: bim_salary_transfers Admins can manage bim_transfers; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Admins can manage bim_transfers" ON public.bim_salary_transfers TO authenticated USING (public.has_role(auth.uid(), 'admin'::public.app_role));


--
-- Name: cash_allocation_columns Admins can manage cash_alloc_cols; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Admins can manage cash_alloc_cols" ON public.cash_allocation_columns TO authenticated USING (public.has_role(auth.uid(), 'admin'::public.app_role)) WITH CHECK (public.has_role(auth.uid(), 'admin'::public.app_role));


--
-- Name: cash_dropdown_options Admins can manage cash_dropdown; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Admins can manage cash_dropdown" ON public.cash_dropdown_options TO authenticated USING (public.has_role(auth.uid(), 'admin'::public.app_role)) WITH CHECK (public.has_role(auth.uid(), 'admin'::public.app_role));


--
-- Name: cash_sheets Admins can manage cash_sheets; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Admins can manage cash_sheets" ON public.cash_sheets TO authenticated USING (public.has_role(auth.uid(), 'admin'::public.app_role)) WITH CHECK (public.has_role(auth.uid(), 'admin'::public.app_role));


--
-- Name: cash_transactions Admins can manage cash_tx; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Admins can manage cash_tx" ON public.cash_transactions TO authenticated USING (public.has_role(auth.uid(), 'admin'::public.app_role)) WITH CHECK (public.has_role(auth.uid(), 'admin'::public.app_role));


--
-- Name: employees Admins can manage employees; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Admins can manage employees" ON public.employees TO authenticated USING (public.has_role(auth.uid(), 'admin'::public.app_role));


--
-- Name: expense_categories Admins can manage expense_categories; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Admins can manage expense_categories" ON public.expense_categories TO authenticated USING (public.has_role(auth.uid(), 'admin'::public.app_role));


--
-- Name: expense_transactions Admins can manage expenses; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Admins can manage expenses" ON public.expense_transactions TO authenticated USING (public.has_role(auth.uid(), 'admin'::public.app_role));


--
-- Name: import_log Admins can manage imports; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Admins can manage imports" ON public.import_log TO authenticated USING (public.has_role(auth.uid(), 'admin'::public.app_role));


--
-- Name: income_transactions Admins can manage income; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Admins can manage income" ON public.income_transactions TO authenticated USING (public.has_role(auth.uid(), 'admin'::public.app_role));


--
-- Name: inss_payments Admins can manage inss; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Admins can manage inss" ON public.inss_payments TO authenticated USING (public.has_role(auth.uid(), 'admin'::public.app_role));


--
-- Name: invoices Admins can manage invoices; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Admins can manage invoices" ON public.invoices TO authenticated USING (public.has_role(auth.uid(), 'admin'::public.app_role)) WITH CHECK (public.has_role(auth.uid(), 'admin'::public.app_role));


--
-- Name: irps_payments Admins can manage irps; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Admins can manage irps" ON public.irps_payments TO authenticated USING (public.has_role(auth.uid(), 'admin'::public.app_role));


--
-- Name: journal_entries Admins can manage journal_entries; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Admins can manage journal_entries" ON public.journal_entries TO authenticated USING (public.has_role(auth.uid(), 'admin'::public.app_role)) WITH CHECK (public.has_role(auth.uid(), 'admin'::public.app_role));


--
-- Name: journal_lines Admins can manage journal_lines; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Admins can manage journal_lines" ON public.journal_lines TO authenticated USING (public.has_role(auth.uid(), 'admin'::public.app_role)) WITH CHECK (public.has_role(auth.uid(), 'admin'::public.app_role));


--
-- Name: petty_cash_transactions Admins can manage petty_cash; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Admins can manage petty_cash" ON public.petty_cash_transactions TO authenticated USING (public.has_role(auth.uid(), 'admin'::public.app_role));


--
-- Name: properties Admins can manage properties; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Admins can manage properties" ON public.properties TO authenticated USING (public.has_role(auth.uid(), 'admin'::public.app_role));


--
-- Name: exchange_rates Admins can manage rates; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Admins can manage rates" ON public.exchange_rates TO authenticated USING (public.has_role(auth.uid(), 'admin'::public.app_role));


--
-- Name: user_roles Admins can manage roles; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Admins can manage roles" ON public.user_roles USING (public.has_role(auth.uid(), 'admin'::public.app_role));


--
-- Name: salary_advances Admins can manage salary_advances; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Admins can manage salary_advances" ON public.salary_advances TO authenticated USING (public.has_role(auth.uid(), 'admin'::public.app_role));


--
-- Name: salary_lines Admins can manage salary_lines; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Admins can manage salary_lines" ON public.salary_lines TO authenticated USING (public.has_role(auth.uid(), 'admin'::public.app_role));


--
-- Name: salary_runs Admins can manage salary_runs; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Admins can manage salary_runs" ON public.salary_runs TO authenticated USING (public.has_role(auth.uid(), 'admin'::public.app_role));


--
-- Name: shareholders Admins can manage shareholders; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Admins can manage shareholders" ON public.shareholders TO authenticated USING (public.has_role(auth.uid(), 'admin'::public.app_role));


--
-- Name: supplier_invoices Admins can manage supplier_invoices; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Admins can manage supplier_invoices" ON public.supplier_invoices TO authenticated USING (public.has_role(auth.uid(), 'admin'::public.app_role)) WITH CHECK (public.has_role(auth.uid(), 'admin'::public.app_role));


--
-- Name: suppliers Admins can manage suppliers; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Admins can manage suppliers" ON public.suppliers TO authenticated USING (public.has_role(auth.uid(), 'admin'::public.app_role)) WITH CHECK (public.has_role(auth.uid(), 'admin'::public.app_role));


--
-- Name: accounting_periods Auth can view accounting_periods; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Auth can view accounting_periods" ON public.accounting_periods FOR SELECT TO authenticated USING (true);


--
-- Name: accounts Auth can view accounts; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Auth can view accounts" ON public.accounts FOR SELECT TO authenticated USING (true);


--
-- Name: shareholder_balances Auth can view balances; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Auth can view balances" ON public.shareholder_balances FOR SELECT TO authenticated USING (true);


--
-- Name: bank_accounts Auth can view bank_accounts; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Auth can view bank_accounts" ON public.bank_accounts FOR SELECT TO authenticated USING (true);


--
-- Name: bank_opening_balances Auth can view bank_opening_balances; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Auth can view bank_opening_balances" ON public.bank_opening_balances FOR SELECT TO authenticated USING (true);


--
-- Name: bank_transactions Auth can view bank_tx; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Auth can view bank_tx" ON public.bank_transactions FOR SELECT TO authenticated USING (true);


--
-- Name: bim_salary_transfers Auth can view bim_transfers; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Auth can view bim_transfers" ON public.bim_salary_transfers FOR SELECT TO authenticated USING (true);


--
-- Name: cash_allocation_columns Auth can view cash_alloc_cols; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Auth can view cash_alloc_cols" ON public.cash_allocation_columns FOR SELECT TO authenticated USING (true);


--
-- Name: cash_dropdown_options Auth can view cash_dropdown; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Auth can view cash_dropdown" ON public.cash_dropdown_options FOR SELECT TO authenticated USING (true);


--
-- Name: cash_sheets Auth can view cash_sheets; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Auth can view cash_sheets" ON public.cash_sheets FOR SELECT TO authenticated USING (true);


--
-- Name: cash_transactions Auth can view cash_tx; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Auth can view cash_tx" ON public.cash_transactions FOR SELECT TO authenticated USING (true);


--
-- Name: employees Auth can view employees; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Auth can view employees" ON public.employees FOR SELECT TO authenticated USING (true);


--
-- Name: expense_categories Auth can view expense_categories; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Auth can view expense_categories" ON public.expense_categories FOR SELECT TO authenticated USING (true);


--
-- Name: expense_transactions Auth can view expenses; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Auth can view expenses" ON public.expense_transactions FOR SELECT TO authenticated USING (true);


--
-- Name: import_log Auth can view imports; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Auth can view imports" ON public.import_log FOR SELECT TO authenticated USING (true);


--
-- Name: income_transactions Auth can view income; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Auth can view income" ON public.income_transactions FOR SELECT TO authenticated USING (true);


--
-- Name: inss_payments Auth can view inss; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Auth can view inss" ON public.inss_payments FOR SELECT TO authenticated USING (true);


--
-- Name: invoices Auth can view invoices; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Auth can view invoices" ON public.invoices FOR SELECT TO authenticated USING (true);


--
-- Name: irps_payments Auth can view irps; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Auth can view irps" ON public.irps_payments FOR SELECT TO authenticated USING (true);


--
-- Name: journal_entries Auth can view journal_entries; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Auth can view journal_entries" ON public.journal_entries FOR SELECT TO authenticated USING (true);


--
-- Name: journal_lines Auth can view journal_lines; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Auth can view journal_lines" ON public.journal_lines FOR SELECT TO authenticated USING (true);


--
-- Name: petty_cash_transactions Auth can view petty_cash; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Auth can view petty_cash" ON public.petty_cash_transactions FOR SELECT TO authenticated USING (true);


--
-- Name: properties Auth can view properties; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Auth can view properties" ON public.properties FOR SELECT TO authenticated USING (true);


--
-- Name: exchange_rates Auth can view rates; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Auth can view rates" ON public.exchange_rates FOR SELECT TO authenticated USING (true);


--
-- Name: salary_advances Auth can view salary_advances; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Auth can view salary_advances" ON public.salary_advances FOR SELECT TO authenticated USING (true);


--
-- Name: salary_lines Auth can view salary_lines; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Auth can view salary_lines" ON public.salary_lines FOR SELECT TO authenticated USING (true);


--
-- Name: salary_runs Auth can view salary_runs; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Auth can view salary_runs" ON public.salary_runs FOR SELECT TO authenticated USING (true);


--
-- Name: shareholders Auth can view shareholders; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Auth can view shareholders" ON public.shareholders FOR SELECT TO authenticated USING (true);


--
-- Name: supplier_invoices Auth can view supplier_invoices; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Auth can view supplier_invoices" ON public.supplier_invoices FOR SELECT TO authenticated USING (true);


--
-- Name: suppliers Auth can view suppliers; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Auth can view suppliers" ON public.suppliers FOR SELECT TO authenticated USING (true);


--
-- Name: profiles Users can insert own profile; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can insert own profile" ON public.profiles FOR INSERT WITH CHECK ((auth.uid() = user_id));


--
-- Name: profiles Users can update own profile; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can update own profile" ON public.profiles FOR UPDATE USING ((auth.uid() = user_id));


--
-- Name: profiles Users can view own profile; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can view own profile" ON public.profiles FOR SELECT USING ((auth.uid() = user_id));


--
-- Name: user_roles Users can view own roles; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can view own roles" ON public.user_roles FOR SELECT USING ((auth.uid() = user_id));


--
-- Name: accounting_periods; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.accounting_periods ENABLE ROW LEVEL SECURITY;

--
-- Name: accounts; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.accounts ENABLE ROW LEVEL SECURITY;

--
-- Name: bank_accounts; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.bank_accounts ENABLE ROW LEVEL SECURITY;

--
-- Name: bank_opening_balances; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.bank_opening_balances ENABLE ROW LEVEL SECURITY;

--
-- Name: bank_transactions; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.bank_transactions ENABLE ROW LEVEL SECURITY;

--
-- Name: bim_salary_transfers; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.bim_salary_transfers ENABLE ROW LEVEL SECURITY;

--
-- Name: cash_allocation_columns; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.cash_allocation_columns ENABLE ROW LEVEL SECURITY;

--
-- Name: cash_dropdown_options; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.cash_dropdown_options ENABLE ROW LEVEL SECURITY;

--
-- Name: cash_sheets; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.cash_sheets ENABLE ROW LEVEL SECURITY;

--
-- Name: cash_transactions; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.cash_transactions ENABLE ROW LEVEL SECURITY;

--
-- Name: employees; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.employees ENABLE ROW LEVEL SECURITY;

--
-- Name: exchange_rates; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.exchange_rates ENABLE ROW LEVEL SECURITY;

--
-- Name: expense_categories; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.expense_categories ENABLE ROW LEVEL SECURITY;

--
-- Name: expense_transactions; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.expense_transactions ENABLE ROW LEVEL SECURITY;

--
-- Name: import_log; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.import_log ENABLE ROW LEVEL SECURITY;

--
-- Name: income_transactions; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.income_transactions ENABLE ROW LEVEL SECURITY;

--
-- Name: inss_payments; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.inss_payments ENABLE ROW LEVEL SECURITY;

--
-- Name: invoices; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.invoices ENABLE ROW LEVEL SECURITY;

--
-- Name: irps_payments; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.irps_payments ENABLE ROW LEVEL SECURITY;

--
-- Name: journal_entries; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.journal_entries ENABLE ROW LEVEL SECURITY;

--
-- Name: journal_lines; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.journal_lines ENABLE ROW LEVEL SECURITY;

--
-- Name: petty_cash_transactions; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.petty_cash_transactions ENABLE ROW LEVEL SECURITY;

--
-- Name: profiles; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

--
-- Name: properties; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.properties ENABLE ROW LEVEL SECURITY;

--
-- Name: salary_advances; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.salary_advances ENABLE ROW LEVEL SECURITY;

--
-- Name: salary_lines; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.salary_lines ENABLE ROW LEVEL SECURITY;

--
-- Name: salary_runs; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.salary_runs ENABLE ROW LEVEL SECURITY;

--
-- Name: shareholder_balances; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.shareholder_balances ENABLE ROW LEVEL SECURITY;

--
-- Name: shareholders; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.shareholders ENABLE ROW LEVEL SECURITY;

--
-- Name: supplier_invoices; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.supplier_invoices ENABLE ROW LEVEL SECURITY;

--
-- Name: suppliers; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.suppliers ENABLE ROW LEVEL SECURITY;

--
-- Name: user_roles; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.user_roles ENABLE ROW LEVEL SECURITY;

--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE USAGE ON SCHEMA public FROM PUBLIC;


--
-- PostgreSQL database dump complete
--

\unrestrict f173P5RhBKT8YzKcLcKg1iCWLVwWkZcOAZUBy2dKR92HJreNJ8IjjZjiFiByjIl

