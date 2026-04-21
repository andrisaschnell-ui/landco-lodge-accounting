
-- 1. Add granular PGC accounts (Mozambique PGC-PE class 6 sub-accounts + a suspense control account)
INSERT INTO public.accounts (code, name, account_class, account_type, normal_side, parent_code, pgc_class) VALUES
  ('6111', 'Salários — Pessoal Comum (LC)',            6, 'expense', 'debit',  '611',  '61'),
  ('6112', 'Salários — Trabalho Casual',               6, 'expense', 'debit',  '611',  '61'),
  ('6211', 'Serviços — Office & Bank Charges',         6, 'expense', 'debit',  '621',  '62'),
  ('6212', 'Serviços — Admin Charges (BDO/Andrisa)',   6, 'expense', 'debit',  '621',  '62'),
  ('6213', 'Serviços — Comunidade',                    6, 'expense', 'debit',  '621',  '62'),
  ('6214', 'Serviços — House Keeping',                 6, 'expense', 'debit',  '621',  '62'),
  ('6221', 'Electricidade e Gás',                      6, 'expense', 'debit',  '622',  '62'),
  ('6231', 'Combustíveis — Diesel & Petrol',           6, 'expense', 'debit',  '623',  '62'),
  ('6241', 'Manutenção — Geral',                       6, 'expense', 'debit',  '624',  '62'),
  ('6242', 'Manutenção — Jardim & Piscina',            6, 'expense', 'debit',  '624',  '62'),
  ('6243', 'Manutenção — Veículos',                    6, 'expense', 'debit',  '624',  '62'),
  ('6244', 'Pequenas Ferramentas',                     6, 'expense', 'debit',  '624',  '62'),
  ('6245', 'Equipamento',                              6, 'expense', 'debit',  '624',  '62'),
  ('6311', 'Impostos Municipais & Marítimos (IPRA/TAE)', 6, 'expense', 'debit','631', '63'),
  ('6411', 'Despesas Casa Luz (H1)',                   6, 'expense', 'debit',  NULL,   '64'),
  ('6412', 'Despesas Casa Aurora (H2)',                6, 'expense', 'debit',  NULL,   '64'),
  ('6413', 'Despesas Casa Caju (H3)',                  6, 'expense', 'debit',  NULL,   '64'),
  ('6414', 'Despesas Casa Coco (H4)',                  6, 'expense', 'debit',  NULL,   '64'),
  ('262',  'Conta Suspensa (Suspense)',                2, 'asset',   'debit',  NULL,   '26')
ON CONFLICT (code) DO NOTHING;

-- 2. Insert the 6 missing expense categories
INSERT INTO public.expense_categories (name, name_pt, name_en, is_shared, category_type, pgc_account_code) VALUES
  ('EQUIPMENT',        'EQUIPAMENTO',               'Equipment',                true,  'main', '6245'),
  ('EXPENSES LUZ',     'DESPESAS LUZ',              'Luz House Expenses',       false, 'main', '6411'),
  ('EXPENSES AURORA',  'DESPESAS AURORA',           'Aurora House Expenses',    false, 'main', '6412'),
  ('EXPENSES CAJU',    'DESPESAS CAJU',             'Caju House Expenses',      false, 'main', '6413'),
  ('EXPENSES COCO',    'DESPESAS COCO',             'Coco House Expenses',      false, 'main', '6414'),
  ('SUSPENSE',         'CONTA SUSPENSA',            'Suspense Account',         true,  'main', '262')
ON CONFLICT DO NOTHING;

-- 3. Auto-map existing categories to the new granular PGC codes
UPDATE public.expense_categories SET pgc_account_code = '6111' WHERE name = 'SALARIES & WAGES';
UPDATE public.expense_categories SET pgc_account_code = '6112' WHERE name = 'CASUAL WORKERS AND FOOD ALLOWANCE';
UPDATE public.expense_categories SET pgc_account_code = '6211' WHERE name = 'OFFICE AND BANK CHARGES';
UPDATE public.expense_categories SET pgc_account_code = '6212' WHERE name = 'ADMIN CHARGES (BDO & ANDRISA)';
UPDATE public.expense_categories SET pgc_account_code = '6213' WHERE name = 'COMMUNITY';
UPDATE public.expense_categories SET pgc_account_code = '6214' WHERE name = 'HOUSE KEEPING';
UPDATE public.expense_categories SET pgc_account_code = '6221' WHERE name = 'GAS AND ELECTRICITY';
UPDATE public.expense_categories SET pgc_account_code = '6231' WHERE name = 'DIESEL AND PETROL';
UPDATE public.expense_categories SET pgc_account_code = '6241' WHERE name = 'MAINTENANCE GENERAL';
UPDATE public.expense_categories SET pgc_account_code = '6242' WHERE name = 'MAINTENANCE GARDEN & POOL';
UPDATE public.expense_categories SET pgc_account_code = '6243' WHERE name = 'MAINTENANCE VEHICLES';
UPDATE public.expense_categories SET pgc_account_code = '6244' WHERE name = 'SMALL TOOLS';
UPDATE public.expense_categories SET pgc_account_code = '6311' WHERE name = 'MARITIME & MUNICIPAL TAXES IPRA & TAE';
UPDATE public.expense_categories SET pgc_account_code = '626'  WHERE name = 'INSURANCE & LICENSE' AND EXISTS (SELECT 1 FROM public.accounts WHERE code='626');
