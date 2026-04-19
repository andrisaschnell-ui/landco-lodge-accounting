INSERT INTO public.accounts (code, name, account_class, account_type, normal_side, pgc_class) VALUES
-- Class 1: Meios Financeiros
('11',   'Caixa',                          1,'asset','debit','Classe 1'),
('12',   'Depósitos à Ordem',              1,'asset','debit','Classe 1'),
('121',  'BCI — Conta MZN',               1,'asset','debit','Classe 1'),
('122',  'BIM — Conta MZN',               1,'asset','debit','Classe 1'),
('123',  'BCI — Conta USD',               1,'asset','debit','Classe 1'),
-- Class 2: Terceiros
('211',  'Clientes',                       2,'asset','debit','Classe 2'),
('221',  'Fornecedores',                   2,'liability','credit','Classe 2'),
('231',  'Pessoal — Remunerações a Pagar', 2,'liability','credit','Classe 2'),
('241',  'Estado — INSS a Pagar',          2,'liability','credit','Classe 2'),
('242',  'Estado — IRPS a Pagar',          2,'liability','credit','Classe 2'),
('243',  'Estado — IVA a Pagar',           2,'liability','credit','Classe 2'),
-- Class 3: Inventários (minimal for lodge)
('31',   'Mercadorias',                    3,'asset','debit','Classe 3'),
-- Class 5: Capital Próprio
('51',   'Capital Social',                 5,'equity','credit','Classe 5'),
('56',   'Resultados Transitados',         5,'equity','credit','Classe 5'),
-- Class 6: Gastos
('611',  'Gastos c/ Pessoal — Salários',   6,'expense','debit','Classe 6'),
('612',  'Gastos c/ Pessoal — INSS Entidade', 6,'expense','debit','Classe 6'),
('621',  'Fornecimentos e Serviços Externos', 6,'expense','debit','Classe 6'),
('622',  'Electricidade e Água',           6,'expense','debit','Classe 6'),
('623',  'Combustíveis',                   6,'expense','debit','Classe 6'),
('624',  'Manutenção e Reparações',        6,'expense','debit','Classe 6'),
('625',  'Comunicações',                   6,'expense','debit','Classe 6'),
('626',  'Seguros',                        6,'expense','debit','Classe 6'),
('631',  'Impostos e Taxas',               6,'expense','debit','Classe 6'),
-- Class 7: Rendimentos
('711',  'Vendas — Alojamento',            7,'income','credit','Classe 7'),
('712',  'Vendas — Restauração',           7,'income','credit','Classe 7'),
('713',  'Vendas — Actividades',           7,'income','credit','Classe 7'),
('714',  'Outros Rendimentos',             7,'income','credit','Classe 7')
ON CONFLICT (code) DO NOTHING;
