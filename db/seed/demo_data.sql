-- ============================================================
--  demo_data.sql
--  Optional placeholder data for a brand-new company install.
--  The new admin user can edit or delete any of this freely.
--
--  Loaded by install-new-company.bat / .sh when the user
--  answers "yes" to "Load demo data?".
--
--  All inserts are idempotent (ON CONFLICT DO NOTHING) so the
--  file is safe to run more than once.
-- ============================================================

-- ---------- Chart of Accounts (minimal Mozambican PGC-style) --
INSERT INTO public.chart_of_accounts (code, name, account_type) VALUES
  ('1100','Bank — main',           'asset'),
  ('1110','Petty cash',            'asset'),
  ('1200','Accounts receivable',   'asset'),
  ('1300','Inventory',             'asset'),
  ('1500','Fixed assets',          'asset'),
  ('1590','Accumulated depreciation','asset'),
  ('2100','Accounts payable',      'liability'),
  ('2200','VAT payable',           'liability'),
  ('2300','Salaries payable',      'liability'),
  ('2400','INSS payable',          'liability'),
  ('2410','IRPS payable',          'liability'),
  ('2999','Suspense (unmapped)',   'liability'),
  ('3100','Share capital',         'equity'),
  ('3200','Retained earnings',     'equity'),
  ('4100','Sales revenue',         'income'),
  ('4200','Other income',          'income'),
  ('5100','Cost of goods sold',    'expense'),
  ('6100','Salaries & wages',      'expense'),
  ('6200','Rent',                  'expense'),
  ('6300','Utilities',             'expense'),
  ('6400','Office supplies',       'expense'),
  ('6500','Depreciation expense',  'expense'),
  ('6900','Bank charges',          'expense')
ON CONFLICT (code) DO NOTHING;

-- ---------- Properties (placeholder) --------------------------
INSERT INTO public.properties (name, location)
VALUES ('Main Property', 'Mozambique')
ON CONFLICT DO NOTHING;

-- ---------- Shareholders (placeholder) ------------------------
INSERT INTO public.shareholders (name, ownership_percentage)
VALUES
  ('Shareholder A', 50),
  ('Shareholder B', 50)
ON CONFLICT DO NOTHING;

-- ---------- Accounting period (current calendar year) ---------
INSERT INTO public.accounting_periods (period_start, period_end, is_closed)
SELECT
  date_trunc('year', now())::date,
  (date_trunc('year', now()) + interval '1 year - 1 day')::date,
  false
WHERE NOT EXISTS (
  SELECT 1 FROM public.accounting_periods
  WHERE period_start = date_trunc('year', now())::date
);

-- Done. New admin can review under:
--   /accounting/chart-of-accounts
--   /properties, /shareholders, /accounting/periods
