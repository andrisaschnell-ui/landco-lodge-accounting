
ALTER TABLE public.bank_accounts ADD COLUMN IF NOT EXISTS pgc_account_code text;

ALTER TABLE public.bank_transactions ADD COLUMN IF NOT EXISTS journal_entry_id uuid REFERENCES public.journal_entries(id);

ALTER TABLE public.expense_categories
  ADD COLUMN IF NOT EXISTS pgc_account_code text,
  ADD COLUMN IF NOT EXISTS name_en text,
  ADD COLUMN IF NOT EXISTS name_pt text,
  ADD COLUMN IF NOT EXISTS category_type text,
  ADD COLUMN IF NOT EXISTS parent_id uuid REFERENCES public.expense_categories(id);

ALTER TABLE public.expense_transactions ADD COLUMN IF NOT EXISTS journal_entry_id uuid REFERENCES public.journal_entries(id);

ALTER TABLE public.income_transactions ADD COLUMN IF NOT EXISTS journal_entry_id uuid REFERENCES public.journal_entries(id);

ALTER TABLE public.petty_cash_transactions
  ADD COLUMN IF NOT EXISTS reference text,
  ADD COLUMN IF NOT EXISTS supplier text,
  ADD COLUMN IF NOT EXISTS allocation text,
  ADD COLUMN IF NOT EXISTS vat_amount numeric DEFAULT 0,
  ADD COLUMN IF NOT EXISTS net_amount numeric DEFAULT 0,
  ADD COLUMN IF NOT EXISTS source_file text,
  ADD COLUMN IF NOT EXISTS journal_entry_id uuid REFERENCES public.journal_entries(id);

ALTER TABLE public.salary_runs ADD COLUMN IF NOT EXISTS journal_entry_id uuid REFERENCES public.journal_entries(id);
