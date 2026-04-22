-- ============================================================
-- LANACC — Cash Control Module (isolated notebook)
-- Tracks Petty Cash / Emola / M-Pesa independently of accounting.
-- ============================================================

CREATE TABLE IF NOT EXISTS public.cash_sheets (
  id                  uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  sheet_type          text NOT NULL,                -- 'petty_cash' | 'emola' | 'mpesa'
  year                integer NOT NULL,
  month               integer,                      -- null for emola/mpesa (single-sheet)
  opening_balance     numeric NOT NULL DEFAULT 0,
  opening_description text,
  source_file         text,
  created_at          timestamptz NOT NULL DEFAULT now(),
  updated_at          timestamptz NOT NULL DEFAULT now(),
  UNIQUE (sheet_type, year, month)
);

CREATE TABLE IF NOT EXISTS public.cash_transactions (
  id                 uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  sheet_id           uuid REFERENCES public.cash_sheets(id) ON DELETE CASCADE,
  sheet_type         text NOT NULL,
  year               integer NOT NULL,
  month              integer NOT NULL,
  row_no             integer,
  tx_date            date,
  description        text,
  -- Petty cash specific
  cheque_no          text,
  cell_no            text,
  entrada            numeric,
  saida              numeric,
  balance            numeric,
  bank_charges       numeric,
  -- Emola / Mpesa specific
  funder             text,
  receiver           text,
  company            text,
  -- Shared
  allocation_column  text,
  allocation_amount  numeric,
  allocations        jsonb NOT NULL DEFAULT '{}'::jsonb,
  source_file        text,
  created_at         timestamptz NOT NULL DEFAULT now(),
  updated_at         timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_cash_tx_sheet ON public.cash_transactions(sheet_type, year, month);

CREATE TABLE IF NOT EXISTS public.cash_dropdown_options (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  sheet_type  text NOT NULL,          -- 'petty_cash' | 'emola' | 'mpesa'
  column_key  text NOT NULL,          -- 'funder' | 'receiver' | 'allocation' | etc.
  value       text NOT NULL,
  sort_order  integer NOT NULL DEFAULT 0,
  created_at  timestamptz NOT NULL DEFAULT now(),
  UNIQUE (sheet_type, column_key, value)
);

CREATE TABLE IF NOT EXISTS public.cash_allocation_columns (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  sheet_type  text NOT NULL,
  column_name text NOT NULL,
  sort_order  integer NOT NULL DEFAULT 0,
  created_at  timestamptz NOT NULL DEFAULT now(),
  UNIQUE (sheet_type, column_name)
);
