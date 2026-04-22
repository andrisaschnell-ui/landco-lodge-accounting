INSERT INTO public.bank_accounts (name, bank_name, currency, account_number, pgc_account_code)
VALUES
  ('BIM MZN', 'BIM - Vilanculos', 'MZN', '93881257', '1211'),
  ('BIM USD', 'BIM - Vilanculos', 'USD', '93880869', '1212')
ON CONFLICT DO NOTHING;