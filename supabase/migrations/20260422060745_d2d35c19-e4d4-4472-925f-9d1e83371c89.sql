-- Track BIM bank account opening balances (carry-forward from prior month)
CREATE TABLE public.bank_opening_balances (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  bank_account_id UUID NOT NULL REFERENCES public.bank_accounts(id) ON DELETE CASCADE,
  month INTEGER NOT NULL,
  year INTEGER NOT NULL,
  opening_balance NUMERIC NOT NULL DEFAULT 0,
  source_file TEXT,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  UNIQUE (bank_account_id, month, year)
);

ALTER TABLE public.bank_opening_balances ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Auth can view bank_opening_balances"
  ON public.bank_opening_balances FOR SELECT
  TO authenticated USING (true);

CREATE POLICY "Admins can manage bank_opening_balances"
  ON public.bank_opening_balances FOR ALL
  TO authenticated
  USING (has_role(auth.uid(), 'admin'::app_role))
  WITH CHECK (has_role(auth.uid(), 'admin'::app_role));

CREATE TRIGGER update_bank_opening_balances_updated_at
  BEFORE UPDATE ON public.bank_opening_balances
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();