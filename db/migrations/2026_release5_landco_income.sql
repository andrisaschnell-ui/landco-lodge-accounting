CREATE TABLE IF NOT EXISTS public.landco_income (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  transaction_date date NOT NULL,
  period_month integer NOT NULL CHECK (period_month BETWEEN 1 AND 12),
  period_year integer NOT NULL,
  property_id uuid REFERENCES public.properties(id),
  property_code text NOT NULL CHECK (property_code IN ('H1','H2','H3','H4')),
  house_number integer CHECK (house_number BETWEEN 1 AND 4),
  description text NOT NULL,
  accommodation_amount_mzn numeric NOT NULL DEFAULT 0,
  h1_amount_mzn numeric NOT NULL DEFAULT 0,
  h2_amount_mzn numeric NOT NULL DEFAULT 0,
  h3_amount_mzn numeric NOT NULL DEFAULT 0,
  h4_amount_mzn numeric NOT NULL DEFAULT 0,
  total_mzn numeric NOT NULL DEFAULT 0,
  amount_usd numeric NOT NULL DEFAULT 0,
  exchange_rate_used numeric,
  monthly_total_mzn_source numeric,
  source_file text,
  source_sheet text NOT NULL DEFAULT 'INCOME',
  source_row_number integer,
  import_notes text,
  journal_entry_id uuid REFERENCES public.journal_entries(id),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (source_file, source_sheet, source_row_number)
);

CREATE INDEX IF NOT EXISTS idx_landco_income_period
  ON public.landco_income(period_year, period_month);

CREATE INDEX IF NOT EXISTS idx_landco_income_property
  ON public.landco_income(property_code, transaction_date);
