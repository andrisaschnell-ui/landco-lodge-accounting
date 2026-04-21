
-- Sequence for invoice numbering
CREATE SEQUENCE IF NOT EXISTS public.invoice_seq START 1;

-- accounts (chart of accounts)
CREATE TABLE IF NOT EXISTS public.accounts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  code text NOT NULL UNIQUE,
  name text NOT NULL,
  account_class integer NOT NULL,
  account_type text NOT NULL,
  normal_side text NOT NULL CHECK (normal_side IN ('debit','credit')),
  parent_code text,
  is_active boolean NOT NULL DEFAULT true,
  pgc_class text,
  created_at timestamptz NOT NULL DEFAULT now()
);

-- accounting_periods
CREATE TABLE IF NOT EXISTS public.accounting_periods (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  year integer NOT NULL,
  month integer NOT NULL,
  is_closed boolean NOT NULL DEFAULT false,
  closed_at timestamptz,
  closed_by uuid,
  UNIQUE (year, month)
);

-- journal_entries
CREATE TABLE IF NOT EXISTS public.journal_entries (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  entry_date date NOT NULL,
  reference text,
  description text NOT NULL,
  entry_type text NOT NULL,
  property_id uuid,
  posted boolean NOT NULL DEFAULT false,
  posted_at timestamptz,
  posted_by uuid,
  created_by uuid,
  created_at timestamptz NOT NULL DEFAULT now()
);

-- journal_lines
CREATE TABLE IF NOT EXISTS public.journal_lines (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  journal_entry_id uuid NOT NULL REFERENCES public.journal_entries(id) ON DELETE CASCADE,
  account_id uuid NOT NULL REFERENCES public.accounts(id),
  debit numeric NOT NULL DEFAULT 0 CHECK (debit >= 0),
  credit numeric NOT NULL DEFAULT 0 CHECK (credit >= 0),
  memo text,
  CHECK (debit = 0 OR credit = 0)
);

-- suppliers
CREATE TABLE IF NOT EXISTS public.suppliers (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- supplier_invoices
CREATE TABLE IF NOT EXISTS public.supplier_invoices (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  supplier_id uuid REFERENCES public.suppliers(id),
  invoice_number text,
  invoice_date date,
  description text,
  allocation text,
  amount_excl numeric DEFAULT 0,
  vat_amount numeric DEFAULT 0,
  total_amount numeric DEFAULT 0,
  journal_entry_id uuid REFERENCES public.journal_entries(id),
  created_at timestamptz DEFAULT now()
);

-- invoices
CREATE TABLE IF NOT EXISTS public.invoices (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  invoice_number text NOT NULL,
  invoice_series text NOT NULL DEFAULT 'FT',
  invoice_date date NOT NULL,
  due_date date,
  property_id uuid,
  client_name text NOT NULL,
  client_nuit text,
  client_address text,
  line_items jsonb NOT NULL DEFAULT '[]'::jsonb,
  subtotal_mzn numeric NOT NULL DEFAULT 0,
  vat_amount_mzn numeric NOT NULL DEFAULT 0,
  total_mzn numeric NOT NULL DEFAULT 0,
  currency text NOT NULL DEFAULT 'MZN',
  exchange_rate numeric DEFAULT 1,
  status text NOT NULL DEFAULT 'draft',
  at_hash text,
  at_qr_code text,
  journal_entry_id uuid REFERENCES public.journal_entries(id),
  income_tx_id uuid,
  issued_by uuid,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

-- Enable RLS on all new tables
ALTER TABLE public.accounts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.accounting_periods ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.journal_entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.journal_lines ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.suppliers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.supplier_invoices ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.invoices ENABLE ROW LEVEL SECURITY;

-- Policies: admins manage, authenticated can view
DO $$
DECLARE t text;
BEGIN
  FOREACH t IN ARRAY ARRAY['accounts','accounting_periods','journal_entries','journal_lines','suppliers','supplier_invoices','invoices']
  LOOP
    EXECUTE format('CREATE POLICY "Admins can manage %1$s" ON public.%1$I FOR ALL TO authenticated USING (public.has_role(auth.uid(), ''admin''::public.app_role)) WITH CHECK (public.has_role(auth.uid(), ''admin''::public.app_role));', t);
    EXECUTE format('CREATE POLICY "Auth can view %1$s" ON public.%1$I FOR SELECT TO authenticated USING (true);', t);
  END LOOP;
END $$;

-- Trigger to keep invoices.updated_at fresh
CREATE TRIGGER trg_invoices_updated_at
BEFORE UPDATE ON public.invoices
FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
