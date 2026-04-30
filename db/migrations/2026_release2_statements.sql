-- =====================================================================
-- Release 2 — Statements & analysis (local mirror of cloud migration)
-- Apply to local Postgres after pulling latest code:
--   docker exec -i lanacc-postgres psql -U landco -d landco \
--     < db/migrations/2026_release2_statements.sql
-- =====================================================================

-- Budgets table
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

-- Aging support
ALTER TABLE public.supplier_invoices
  ADD COLUMN IF NOT EXISTS due_date date,
  ADD COLUMN IF NOT EXISTS paid_amount numeric NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS status text NOT NULL DEFAULT 'open';

ALTER TABLE public.invoices
  ADD COLUMN IF NOT EXISTS paid_amount numeric NOT NULL DEFAULT 0;
