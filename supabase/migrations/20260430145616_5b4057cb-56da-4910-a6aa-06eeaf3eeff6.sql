-- =========================================================================
-- Release 1 — Step 3: auto-post triggers
-- =========================================================================

-- Helper: account id by code, with fallback to suspense 2999
CREATE OR REPLACE FUNCTION public.fn_account_id(_code text)
RETURNS uuid LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $$
  SELECT id FROM public.accounts WHERE code = _code LIMIT 1
$$;

CREATE OR REPLACE FUNCTION public.fn_account_or_suspense(_code text)
RETURNS uuid LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $$
  SELECT COALESCE(
    (SELECT id FROM public.accounts WHERE code = _code LIMIT 1),
    (SELECT id FROM public.accounts WHERE code = '2999' LIMIT 1)
  )
$$;

-- ---------- INCOME ----------
CREATE OR REPLACE FUNCTION public.fn_auto_post_income()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE
  v_entry_id uuid; v_total numeric;
  v_cash uuid; v_rev uuid;
BEGIN
  IF NEW.journal_entry_id IS NOT NULL THEN RETURN NEW; END IF;
  v_total := COALESCE(NEW.accommodation_amount_mzn, 0);
  IF v_total = 0 THEN RETURN NEW; END IF;

  v_cash := public.fn_account_or_suspense('1111');
  v_rev  := public.fn_account_or_suspense('7111');

  INSERT INTO public.journal_entries
    (entry_date, description, entry_type, reference, property_id,
     source_table, source_id, posted, posted_at)
  VALUES (NEW.date,
          COALESCE(NEW.description, 'Income: ' || COALESCE(NEW.guest_name,'Guest')),
          'income', NEW.id::text, NEW.property_id,
          'income_transactions', NEW.id, true, now())
  RETURNING id INTO v_entry_id;

  INSERT INTO public.journal_lines (journal_entry_id, account_id, debit, credit, memo) VALUES
    (v_entry_id, v_cash, v_total, 0,       'Cash received'),
    (v_entry_id, v_rev,  0,       v_total, 'Accommodation income');

  NEW.journal_entry_id := v_entry_id;
  RETURN NEW;
END $$;

DROP TRIGGER IF EXISTS trg_auto_post_income ON public.income_transactions;
CREATE TRIGGER trg_auto_post_income
  BEFORE INSERT ON public.income_transactions
  FOR EACH ROW EXECUTE FUNCTION public.fn_auto_post_income();

-- ---------- EXPENSE ----------
CREATE OR REPLACE FUNCTION public.fn_auto_post_expense()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE
  v_entry_id uuid; v_total numeric;
  v_exp uuid; v_cash uuid; v_code text;
BEGIN
  IF NEW.journal_entry_id IS NOT NULL THEN RETURN NEW; END IF;
  v_total := COALESCE(NEW.amount_mzn, 0);
  IF v_total = 0 THEN RETURN NEW; END IF;

  IF NEW.category_id IS NOT NULL THEN
    SELECT pgc_account_code INTO v_code
      FROM public.expense_categories WHERE id = NEW.category_id;
  END IF;
  v_exp  := public.fn_account_or_suspense(v_code);
  v_cash := public.fn_account_or_suspense('1111');

  INSERT INTO public.journal_entries
    (entry_date, description, entry_type, reference, property_id,
     source_table, source_id, posted, posted_at)
  VALUES (NEW.date, NEW.description, 'expense', NEW.id::text, NEW.property_id,
          'expense_transactions', NEW.id, true, now())
  RETURNING id INTO v_entry_id;

  INSERT INTO public.journal_lines (journal_entry_id, account_id, debit, credit, memo) VALUES
    (v_entry_id, v_exp,  v_total, 0,       NEW.description),
    (v_entry_id, v_cash, 0,       v_total, 'Paid');

  NEW.journal_entry_id := v_entry_id;
  RETURN NEW;
END $$;

DROP TRIGGER IF EXISTS trg_auto_post_expense ON public.expense_transactions;
CREATE TRIGGER trg_auto_post_expense
  BEFORE INSERT ON public.expense_transactions
  FOR EACH ROW EXECUTE FUNCTION public.fn_auto_post_expense();

-- ---------- BANK ----------
CREATE OR REPLACE FUNCTION public.fn_auto_post_bank()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE
  v_entry_id uuid; v_amt numeric;
  v_bank uuid; v_susp uuid; v_code text;
BEGIN
  IF NEW.journal_entry_id IS NOT NULL THEN RETURN NEW; END IF;
  v_amt := GREATEST(COALESCE(NEW.debit,0), COALESCE(NEW.credit,0));
  IF v_amt = 0 THEN RETURN NEW; END IF;

  IF NEW.bank_account_id IS NOT NULL THEN
    SELECT pgc_account_code INTO v_code
      FROM public.bank_accounts WHERE id = NEW.bank_account_id;
  END IF;
  v_bank := public.fn_account_or_suspense(v_code);
  v_susp := public.fn_account_or_suspense('2999');

  INSERT INTO public.journal_entries
    (entry_date, description, entry_type, reference,
     source_table, source_id, posted, posted_at)
  VALUES (NEW.date, NEW.description, 'bank', COALESCE(NEW.reference, NEW.id::text),
          'bank_transactions', NEW.id, true, now())
  RETURNING id INTO v_entry_id;

  IF COALESCE(NEW.debit,0) > 0 THEN
    INSERT INTO public.journal_lines (journal_entry_id, account_id, debit, credit, memo) VALUES
      (v_entry_id, v_bank, v_amt, 0,     NEW.description),
      (v_entry_id, v_susp, 0,     v_amt, NEW.description);
  ELSE
    INSERT INTO public.journal_lines (journal_entry_id, account_id, debit, credit, memo) VALUES
      (v_entry_id, v_susp, v_amt, 0,     NEW.description),
      (v_entry_id, v_bank, 0,     v_amt, NEW.description);
  END IF;

  NEW.journal_entry_id := v_entry_id;
  RETURN NEW;
END $$;

DROP TRIGGER IF EXISTS trg_auto_post_bank ON public.bank_transactions;
CREATE TRIGGER trg_auto_post_bank
  BEFORE INSERT ON public.bank_transactions
  FOR EACH ROW EXECUTE FUNCTION public.fn_auto_post_bank();

-- ---------- PETTY CASH ----------
CREATE OR REPLACE FUNCTION public.fn_auto_post_petty_cash()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE
  v_entry_id uuid; v_amt numeric;
  v_cash uuid; v_susp uuid;
BEGIN
  IF NEW.journal_entry_id IS NOT NULL THEN RETURN NEW; END IF;
  v_amt := GREATEST(COALESCE(NEW.debit,0), COALESCE(NEW.credit,0));
  IF v_amt = 0 THEN RETURN NEW; END IF;

  v_cash := public.fn_account_or_suspense('1111');
  v_susp := public.fn_account_or_suspense('2999');

  INSERT INTO public.journal_entries
    (entry_date, description, entry_type, reference,
     source_table, source_id, posted, posted_at)
  VALUES (NEW.date, NEW.description, 'petty_cash', COALESCE(NEW.reference, NEW.id::text),
          'petty_cash_transactions', NEW.id, true, now())
  RETURNING id INTO v_entry_id;

  IF COALESCE(NEW.debit,0) > 0 THEN
    INSERT INTO public.journal_lines (journal_entry_id, account_id, debit, credit, memo) VALUES
      (v_entry_id, v_cash, v_amt, 0,     NEW.description),
      (v_entry_id, v_susp, 0,     v_amt, NEW.description);
  ELSE
    INSERT INTO public.journal_lines (journal_entry_id, account_id, debit, credit, memo) VALUES
      (v_entry_id, v_susp, v_amt, 0,     NEW.description),
      (v_entry_id, v_cash, 0,     v_amt, NEW.description);
  END IF;

  NEW.journal_entry_id := v_entry_id;
  RETURN NEW;
END $$;

DROP TRIGGER IF EXISTS trg_auto_post_petty_cash ON public.petty_cash_transactions;
CREATE TRIGGER trg_auto_post_petty_cash
  BEFORE INSERT ON public.petty_cash_transactions
  FOR EACH ROW EXECUTE FUNCTION public.fn_auto_post_petty_cash();

-- ---------- PAYROLL (salary_runs) ----------
CREATE OR REPLACE FUNCTION public.fn_auto_post_payroll()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE
  v_entry_id uuid;
  v_gross numeric; v_net numeric; v_inssE numeric; v_inssR numeric; v_irps numeric;
  v_salaryExp uuid; v_inssExp uuid; v_netPay uuid; v_inssPay uuid; v_irpsPay uuid;
  v_date date;
BEGIN
  IF NEW.journal_entry_id IS NOT NULL THEN RETURN NEW; END IF;
  v_gross := COALESCE(NEW.total_gross, 0);
  v_net   := COALESCE(NEW.total_net,   0);
  v_inssE := COALESCE(NEW.total_inss_employee, 0);
  v_inssR := COALESCE(NEW.total_inss_employer, 0);
  v_irps  := COALESCE(NEW.total_irps,  0);
  IF v_gross = 0 AND v_net = 0 THEN RETURN NEW; END IF;

  v_salaryExp := public.fn_account_or_suspense('6311');
  v_inssExp   := public.fn_account_or_suspense('6312');
  v_netPay    := public.fn_account_or_suspense('2511');
  v_inssPay   := public.fn_account_or_suspense('2451');
  v_irpsPay   := public.fn_account_or_suspense('2452');

  v_date := MAKE_DATE(NEW.year, NEW.month, 28);

  INSERT INTO public.journal_entries
    (entry_date, description, entry_type, reference,
     source_table, source_id, posted, posted_at)
  VALUES (v_date,
          'Payroll ' || NEW.year || '-' || LPAD(NEW.month::text, 2, '0'),
          'payroll', NEW.id::text,
          'salary_runs', NEW.id, true, now())
  RETURNING id INTO v_entry_id;

  INSERT INTO public.journal_lines (journal_entry_id, account_id, debit, credit, memo) VALUES
    (v_entry_id, v_salaryExp, v_gross,        0,              'Salaries gross'),
    (v_entry_id, v_inssExp,   v_inssR,        0,              'INSS employer 4%'),
    (v_entry_id, v_netPay,    0,              v_net,          'Net pay payable'),
    (v_entry_id, v_inssPay,   0,              v_inssE+v_inssR,'INSS payable'),
    (v_entry_id, v_irpsPay,   0,              v_irps,         'IRPS payable');

  NEW.journal_entry_id := v_entry_id;
  RETURN NEW;
END $$;

DROP TRIGGER IF EXISTS trg_auto_post_payroll ON public.salary_runs;
CREATE TRIGGER trg_auto_post_payroll
  BEFORE INSERT ON public.salary_runs
  FOR EACH ROW EXECUTE FUNCTION public.fn_auto_post_payroll();