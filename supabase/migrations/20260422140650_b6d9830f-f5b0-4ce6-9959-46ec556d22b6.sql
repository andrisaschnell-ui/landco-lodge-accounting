
-- Cash Control module: fully isolated notebook for cash/mobile payments
-- No foreign keys to accounting tables; own RLS policies following existing pattern.

-- 1. Sheets: per (sheet_type, month, year) opening balance + metadata
CREATE TABLE public.cash_sheets (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  sheet_type TEXT NOT NULL CHECK (sheet_type IN ('petty_cash','emola','mpesa')),
  month INTEGER,           -- null for emola (single sheet)
  year INTEGER NOT NULL,
  opening_balance NUMERIC NOT NULL DEFAULT 0,
  opening_description TEXT,
  source_file TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (sheet_type, month, year)
);

-- 2. Transactions: unified table for all three sheet types
CREATE TABLE public.cash_transactions (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  sheet_type TEXT NOT NULL CHECK (sheet_type IN ('petty_cash','emola','mpesa')),
  sheet_id UUID REFERENCES public.cash_sheets(id) ON DELETE CASCADE,
  row_no INTEGER,
  tx_date DATE,
  month INTEGER NOT NULL,
  year INTEGER NOT NULL,
  -- Common
  description TEXT,
  funder TEXT,
  receiver TEXT,
  cell_no TEXT,
  -- Petty Cash specific
  cheque_no TEXT,
  company TEXT,
  -- Money flow
  entrada NUMERIC DEFAULT 0,     -- deposit / money in
  saida NUMERIC DEFAULT 0,        -- payment / money out
  bank_charges NUMERIC DEFAULT 0, -- mpesa
  balance NUMERIC,                -- stored balance (calc on client for display)
  -- Allocation: which category column this transaction hits + amount
  allocation_column TEXT,
  allocation_amount NUMERIC DEFAULT 0,
  -- Full allocation row as JSON (preserves all category columns per transaction)
  allocations JSONB NOT NULL DEFAULT '{}'::jsonb,
  source_file TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_cash_tx_sheet ON public.cash_transactions(sheet_type, year, month);
CREATE INDEX idx_cash_tx_funder ON public.cash_transactions(funder);
CREATE INDEX idx_cash_tx_receiver ON public.cash_transactions(receiver);

-- 3. Editable dropdown option lists
-- column_key examples: 'funder','receiver','company','allocation','cheque_type'
CREATE TABLE public.cash_dropdown_options (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  sheet_type TEXT NOT NULL CHECK (sheet_type IN ('petty_cash','emola','mpesa','all')),
  column_key TEXT NOT NULL,
  value TEXT NOT NULL,
  sort_order INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (sheet_type, column_key, value)
);

CREATE INDEX idx_cash_dropdown_lookup ON public.cash_dropdown_options(sheet_type, column_key);

-- 4. Allocation column definitions per sheet type (editable)
CREATE TABLE public.cash_allocation_columns (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  sheet_type TEXT NOT NULL CHECK (sheet_type IN ('petty_cash','emola','mpesa')),
  column_name TEXT NOT NULL,
  sort_order INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (sheet_type, column_name)
);

-- Timestamp triggers
CREATE TRIGGER trg_cash_sheets_updated BEFORE UPDATE ON public.cash_sheets
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER trg_cash_tx_updated BEFORE UPDATE ON public.cash_transactions
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- RLS (match existing pattern: admins manage, all authenticated can read)
ALTER TABLE public.cash_sheets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cash_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cash_dropdown_options ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cash_allocation_columns ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Admins can manage cash_sheets" ON public.cash_sheets
  FOR ALL TO authenticated
  USING (public.has_role(auth.uid(),'admin')) WITH CHECK (public.has_role(auth.uid(),'admin'));
CREATE POLICY "Auth can view cash_sheets" ON public.cash_sheets
  FOR SELECT TO authenticated USING (true);

CREATE POLICY "Admins can manage cash_tx" ON public.cash_transactions
  FOR ALL TO authenticated
  USING (public.has_role(auth.uid(),'admin')) WITH CHECK (public.has_role(auth.uid(),'admin'));
CREATE POLICY "Auth can view cash_tx" ON public.cash_transactions
  FOR SELECT TO authenticated USING (true);

CREATE POLICY "Admins can manage cash_dropdown" ON public.cash_dropdown_options
  FOR ALL TO authenticated
  USING (public.has_role(auth.uid(),'admin')) WITH CHECK (public.has_role(auth.uid(),'admin'));
CREATE POLICY "Auth can view cash_dropdown" ON public.cash_dropdown_options
  FOR SELECT TO authenticated USING (true);

CREATE POLICY "Admins can manage cash_alloc_cols" ON public.cash_allocation_columns
  FOR ALL TO authenticated
  USING (public.has_role(auth.uid(),'admin')) WITH CHECK (public.has_role(auth.uid(),'admin'));
CREATE POLICY "Auth can view cash_alloc_cols" ON public.cash_allocation_columns
  FOR SELECT TO authenticated USING (true);
