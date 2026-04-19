-- ============================================================
-- LANACC - Accounting Recovery Support
-- Preserves workbook-level petty cash detail for future rebuilds
-- ============================================================

ALTER TABLE public.petty_cash_transactions
  ADD COLUMN IF NOT EXISTS reference text,
  ADD COLUMN IF NOT EXISTS supplier text,
  ADD COLUMN IF NOT EXISTS allocation text,
  ADD COLUMN IF NOT EXISTS vat_amount numeric DEFAULT 0,
  ADD COLUMN IF NOT EXISTS net_amount numeric DEFAULT 0,
  ADD COLUMN IF NOT EXISTS source_file text;
