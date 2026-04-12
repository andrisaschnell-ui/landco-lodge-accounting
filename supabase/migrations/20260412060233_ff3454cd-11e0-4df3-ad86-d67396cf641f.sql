
-- Create role enum
CREATE TYPE public.app_role AS ENUM ('admin', 'viewer');

-- Create updated_at trigger function
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SET search_path = public;

-- User roles table (MUST be created before has_role function)
CREATE TABLE public.user_roles (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  role app_role NOT NULL,
  UNIQUE (user_id, role)
);
ALTER TABLE public.user_roles ENABLE ROW LEVEL SECURITY;

-- Create has_role function (security definer to avoid RLS recursion)
CREATE OR REPLACE FUNCTION public.has_role(_user_id uuid, _role app_role)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.user_roles
    WHERE user_id = _user_id AND role = _role
  )
$$;

-- RLS for user_roles
CREATE POLICY "Users can view own roles" ON public.user_roles FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Admins can manage roles" ON public.user_roles FOR ALL USING (public.has_role(auth.uid(), 'admin'));

-- Profiles table
CREATE TABLE public.profiles (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL UNIQUE,
  display_name TEXT,
  email TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own profile" ON public.profiles FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can update own profile" ON public.profiles FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own profile" ON public.profiles FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE TRIGGER update_profiles_updated_at BEFORE UPDATE ON public.profiles FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- Auto-create profile on signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (user_id, email, display_name)
  VALUES (NEW.id, NEW.email, COALESCE(NEW.raw_user_meta_data->>'display_name', NEW.email));
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Properties table
CREATE TABLE public.properties (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  code TEXT NOT NULL UNIQUE,
  description TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
ALTER TABLE public.properties ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Auth can view properties" ON public.properties FOR SELECT TO authenticated USING (true);
CREATE POLICY "Admins can manage properties" ON public.properties FOR ALL TO authenticated USING (public.has_role(auth.uid(), 'admin'));
CREATE TRIGGER update_properties_updated_at BEFORE UPDATE ON public.properties FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- Shareholders table
CREATE TABLE public.shareholders (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  email TEXT,
  property_code TEXT REFERENCES public.properties(code),
  ownership_percentage NUMERIC(5,2),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
ALTER TABLE public.shareholders ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Auth can view shareholders" ON public.shareholders FOR SELECT TO authenticated USING (true);
CREATE POLICY "Admins can manage shareholders" ON public.shareholders FOR ALL TO authenticated USING (public.has_role(auth.uid(), 'admin'));
CREATE TRIGGER update_shareholders_updated_at BEFORE UPDATE ON public.shareholders FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- Employees table
CREATE TABLE public.employees (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  category TEXT,
  nib TEXT,
  nuit TEXT,
  base_salary NUMERIC(12,2) NOT NULL DEFAULT 0,
  food_allowance NUMERIC(12,2) DEFAULT 0,
  house_assignment TEXT,
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
ALTER TABLE public.employees ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Auth can view employees" ON public.employees FOR SELECT TO authenticated USING (true);
CREATE POLICY "Admins can manage employees" ON public.employees FOR ALL TO authenticated USING (public.has_role(auth.uid(), 'admin'));
CREATE TRIGGER update_employees_updated_at BEFORE UPDATE ON public.employees FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- Bank accounts table
CREATE TABLE public.bank_accounts (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  bank_name TEXT NOT NULL,
  account_number TEXT,
  currency TEXT NOT NULL DEFAULT 'MZN',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
ALTER TABLE public.bank_accounts ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Auth can view bank_accounts" ON public.bank_accounts FOR SELECT TO authenticated USING (true);
CREATE POLICY "Admins can manage bank_accounts" ON public.bank_accounts FOR ALL TO authenticated USING (public.has_role(auth.uid(), 'admin'));

-- Expense categories table
CREATE TABLE public.expense_categories (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL UNIQUE,
  is_shared BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
ALTER TABLE public.expense_categories ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Auth can view expense_categories" ON public.expense_categories FOR SELECT TO authenticated USING (true);
CREATE POLICY "Admins can manage expense_categories" ON public.expense_categories FOR ALL TO authenticated USING (public.has_role(auth.uid(), 'admin'));

-- Income transactions
CREATE TABLE public.income_transactions (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  date DATE NOT NULL,
  property_id UUID REFERENCES public.properties(id),
  guest_name TEXT,
  description TEXT,
  accommodation_amount_mzn NUMERIC(14,2) NOT NULL DEFAULT 0,
  amount_usd NUMERIC(14,2) DEFAULT 0,
  month INTEGER NOT NULL CHECK (month BETWEEN 1 AND 12),
  year INTEGER NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
ALTER TABLE public.income_transactions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Auth can view income" ON public.income_transactions FOR SELECT TO authenticated USING (true);
CREATE POLICY "Admins can manage income" ON public.income_transactions FOR ALL TO authenticated USING (public.has_role(auth.uid(), 'admin'));

-- Expense transactions
CREATE TABLE public.expense_transactions (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  date DATE,
  property_id UUID REFERENCES public.properties(id),
  shareholder_id UUID REFERENCES public.shareholders(id),
  category_id UUID REFERENCES public.expense_categories(id),
  description TEXT NOT NULL,
  amount_mzn NUMERIC(14,2) NOT NULL DEFAULT 0,
  is_shared BOOLEAN NOT NULL DEFAULT true,
  month INTEGER NOT NULL CHECK (month BETWEEN 1 AND 12),
  year INTEGER NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
ALTER TABLE public.expense_transactions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Auth can view expenses" ON public.expense_transactions FOR SELECT TO authenticated USING (true);
CREATE POLICY "Admins can manage expenses" ON public.expense_transactions FOR ALL TO authenticated USING (public.has_role(auth.uid(), 'admin'));

-- Bank transactions
CREATE TABLE public.bank_transactions (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  date DATE,
  bank_account_id UUID REFERENCES public.bank_accounts(id),
  description TEXT NOT NULL,
  debit NUMERIC(14,2) DEFAULT 0,
  credit NUMERIC(14,2) DEFAULT 0,
  balance NUMERIC(14,2) DEFAULT 0,
  reference TEXT,
  month INTEGER NOT NULL CHECK (month BETWEEN 1 AND 12),
  year INTEGER NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
ALTER TABLE public.bank_transactions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Auth can view bank_tx" ON public.bank_transactions FOR SELECT TO authenticated USING (true);
CREATE POLICY "Admins can manage bank_tx" ON public.bank_transactions FOR ALL TO authenticated USING (public.has_role(auth.uid(), 'admin'));

-- Petty cash transactions
CREATE TABLE public.petty_cash_transactions (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  date DATE,
  description TEXT NOT NULL,
  credit NUMERIC(14,2) DEFAULT 0,
  debit NUMERIC(14,2) DEFAULT 0,
  balance NUMERIC(14,2) DEFAULT 0,
  month INTEGER NOT NULL CHECK (month BETWEEN 1 AND 12),
  year INTEGER NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
ALTER TABLE public.petty_cash_transactions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Auth can view petty_cash" ON public.petty_cash_transactions FOR SELECT TO authenticated USING (true);
CREATE POLICY "Admins can manage petty_cash" ON public.petty_cash_transactions FOR ALL TO authenticated USING (public.has_role(auth.uid(), 'admin'));

-- Salary runs
CREATE TABLE public.salary_runs (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  month INTEGER NOT NULL CHECK (month BETWEEN 1 AND 12),
  year INTEGER NOT NULL,
  total_gross NUMERIC(14,2) DEFAULT 0,
  total_net NUMERIC(14,2) DEFAULT 0,
  total_inss_employee NUMERIC(14,2) DEFAULT 0,
  total_inss_employer NUMERIC(14,2) DEFAULT 0,
  total_irps NUMERIC(14,2) DEFAULT 0,
  status TEXT NOT NULL DEFAULT 'draft',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(month, year)
);
ALTER TABLE public.salary_runs ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Auth can view salary_runs" ON public.salary_runs FOR SELECT TO authenticated USING (true);
CREATE POLICY "Admins can manage salary_runs" ON public.salary_runs FOR ALL TO authenticated USING (public.has_role(auth.uid(), 'admin'));

-- Salary lines
CREATE TABLE public.salary_lines (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  salary_run_id UUID REFERENCES public.salary_runs(id) ON DELETE CASCADE NOT NULL,
  employee_id UUID REFERENCES public.employees(id) NOT NULL,
  base_salary NUMERIC(12,2) DEFAULT 0,
  food_allowance NUMERIC(12,2) DEFAULT 0,
  back_payment NUMERIC(12,2) DEFAULT 0,
  days_worked INTEGER DEFAULT 30,
  monthly_salary NUMERIC(12,2) DEFAULT 0,
  nightshift_hours NUMERIC(8,2) DEFAULT 0,
  overtime_25_percent NUMERIC(12,2) DEFAULT 0,
  overtime_15x_hours NUMERIC(8,2) DEFAULT 0,
  overtime_15x_amount NUMERIC(12,2) DEFAULT 0,
  overtime_2x_hours NUMERIC(8,2) DEFAULT 0,
  overtime_2x_amount NUMERIC(12,2) DEFAULT 0,
  gratification NUMERIC(12,2) DEFAULT 0,
  holiday_days INTEGER DEFAULT 0,
  holiday_amount NUMERIC(12,2) DEFAULT 0,
  gross_total NUMERIC(12,2) DEFAULT 0,
  advance NUMERIC(12,2) DEFAULT 0,
  irps NUMERIC(12,2) DEFAULT 0,
  debt NUMERIC(12,2) DEFAULT 0,
  inss_employee NUMERIC(12,2) DEFAULT 0,
  sind NUMERIC(12,2) DEFAULT 0,
  total_deductions NUMERIC(12,2) DEFAULT 0,
  net_salary NUMERIC(12,2) DEFAULT 0,
  nib TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
ALTER TABLE public.salary_lines ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Auth can view salary_lines" ON public.salary_lines FOR SELECT TO authenticated USING (true);
CREATE POLICY "Admins can manage salary_lines" ON public.salary_lines FOR ALL TO authenticated USING (public.has_role(auth.uid(), 'admin'));

-- Salary advances
CREATE TABLE public.salary_advances (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  employee_id UUID REFERENCES public.employees(id) NOT NULL,
  amount NUMERIC(12,2) NOT NULL,
  date DATE NOT NULL,
  description TEXT,
  month INTEGER NOT NULL CHECK (month BETWEEN 1 AND 12),
  year INTEGER NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
ALTER TABLE public.salary_advances ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Auth can view salary_advances" ON public.salary_advances FOR SELECT TO authenticated USING (true);
CREATE POLICY "Admins can manage salary_advances" ON public.salary_advances FOR ALL TO authenticated USING (public.has_role(auth.uid(), 'admin'));

-- BIM salary transfers
CREATE TABLE public.bim_salary_transfers (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  salary_run_id UUID REFERENCES public.salary_runs(id),
  employee_id UUID REFERENCES public.employees(id),
  nib TEXT,
  name TEXT NOT NULL,
  amount NUMERIC(12,2) NOT NULL,
  description TEXT,
  month INTEGER NOT NULL CHECK (month BETWEEN 1 AND 12),
  year INTEGER NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
ALTER TABLE public.bim_salary_transfers ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Auth can view bim_transfers" ON public.bim_salary_transfers FOR SELECT TO authenticated USING (true);
CREATE POLICY "Admins can manage bim_transfers" ON public.bim_salary_transfers FOR ALL TO authenticated USING (public.has_role(auth.uid(), 'admin'));

-- INSS payments
CREATE TABLE public.inss_payments (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  month INTEGER NOT NULL CHECK (month BETWEEN 1 AND 12),
  year INTEGER NOT NULL,
  amount NUMERIC(14,2) NOT NULL,
  payment_date DATE,
  reference TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
ALTER TABLE public.inss_payments ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Auth can view inss" ON public.inss_payments FOR SELECT TO authenticated USING (true);
CREATE POLICY "Admins can manage inss" ON public.inss_payments FOR ALL TO authenticated USING (public.has_role(auth.uid(), 'admin'));

-- IRPS payments
CREATE TABLE public.irps_payments (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  month INTEGER NOT NULL CHECK (month BETWEEN 1 AND 12),
  year INTEGER NOT NULL,
  amount NUMERIC(14,2) NOT NULL,
  payment_date DATE,
  reference TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
ALTER TABLE public.irps_payments ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Auth can view irps" ON public.irps_payments FOR SELECT TO authenticated USING (true);
CREATE POLICY "Admins can manage irps" ON public.irps_payments FOR ALL TO authenticated USING (public.has_role(auth.uid(), 'admin'));

-- Shareholder balances
CREATE TABLE public.shareholder_balances (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  shareholder_id UUID REFERENCES public.shareholders(id) NOT NULL,
  property_id UUID REFERENCES public.properties(id) NOT NULL,
  month INTEGER NOT NULL CHECK (month BETWEEN 1 AND 12),
  year INTEGER NOT NULL,
  opening_balance NUMERIC(14,2) DEFAULT 0,
  income NUMERIC(14,2) DEFAULT 0,
  expenses NUMERIC(14,2) DEFAULT 0,
  closing_balance NUMERIC(14,2) DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(shareholder_id, property_id, month, year)
);
ALTER TABLE public.shareholder_balances ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Auth can view balances" ON public.shareholder_balances FOR SELECT TO authenticated USING (true);
CREATE POLICY "Admins can manage balances" ON public.shareholder_balances FOR ALL TO authenticated USING (public.has_role(auth.uid(), 'admin'));

-- Exchange rates
CREATE TABLE public.exchange_rates (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  month INTEGER NOT NULL CHECK (month BETWEEN 1 AND 12),
  year INTEGER NOT NULL,
  mzn_per_usd NUMERIC(10,4) NOT NULL,
  mzn_per_zar NUMERIC(10,4),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(month, year)
);
ALTER TABLE public.exchange_rates ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Auth can view rates" ON public.exchange_rates FOR SELECT TO authenticated USING (true);
CREATE POLICY "Admins can manage rates" ON public.exchange_rates FOR ALL TO authenticated USING (public.has_role(auth.uid(), 'admin'));

-- Import log
CREATE TABLE public.import_log (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  filename TEXT NOT NULL,
  file_type TEXT NOT NULL,
  month INTEGER,
  year INTEGER,
  records_imported INTEGER DEFAULT 0,
  status TEXT NOT NULL DEFAULT 'pending',
  imported_by UUID REFERENCES auth.users(id),
  error_details TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
ALTER TABLE public.import_log ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Auth can view imports" ON public.import_log FOR SELECT TO authenticated USING (true);
CREATE POLICY "Admins can manage imports" ON public.import_log FOR ALL TO authenticated USING (public.has_role(auth.uid(), 'admin'));
