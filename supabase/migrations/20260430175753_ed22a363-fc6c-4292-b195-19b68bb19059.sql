-- =====================================================================
-- RELEASE 4: Inventory, Assets, Banking, Workflow, Audit
-- =====================================================================

-- ---------- 1. FIXED ASSETS ------------------------------------------
CREATE TABLE public.fixed_assets (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  asset_code text NOT NULL UNIQUE,
  name text NOT NULL,
  description text,
  category text NOT NULL,                    -- building, vehicle, furniture, equipment, etc.
  property_id uuid REFERENCES public.properties(id),
  acquisition_date date NOT NULL,
  acquisition_cost numeric NOT NULL DEFAULT 0,
  salvage_value numeric NOT NULL DEFAULT 0,
  useful_life_months integer NOT NULL DEFAULT 60,
  depreciation_method text NOT NULL DEFAULT 'straight_line',  -- straight_line | none
  asset_account_code text NOT NULL,          -- e.g. '4321'
  accum_depr_account_code text NOT NULL,     -- e.g. '4328'
  depr_expense_account_code text NOT NULL,   -- e.g. '6421'
  status text NOT NULL DEFAULT 'active',     -- active | disposed | fully_depreciated
  disposed_date date,
  disposed_amount numeric,
  notes text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE public.depreciation_schedule (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  asset_id uuid NOT NULL REFERENCES public.fixed_assets(id) ON DELETE CASCADE,
  year integer NOT NULL,
  month integer NOT NULL,
  amount numeric NOT NULL,
  posted boolean NOT NULL DEFAULT false,
  journal_entry_id uuid,
  posted_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (asset_id, year, month)
);

ALTER TABLE public.fixed_assets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.depreciation_schedule ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Admins manage fixed_assets" ON public.fixed_assets
  FOR ALL TO authenticated USING (has_role(auth.uid(),'admin')) WITH CHECK (has_role(auth.uid(),'admin'));
CREATE POLICY "Auth view fixed_assets" ON public.fixed_assets
  FOR SELECT TO authenticated USING (true);

CREATE POLICY "Admins manage depreciation_schedule" ON public.depreciation_schedule
  FOR ALL TO authenticated USING (has_role(auth.uid(),'admin')) WITH CHECK (has_role(auth.uid(),'admin'));
CREATE POLICY "Auth view depreciation_schedule" ON public.depreciation_schedule
  FOR SELECT TO authenticated USING (true);

-- Function to generate the schedule (straight-line)
CREATE OR REPLACE FUNCTION public.fn_generate_depreciation_schedule(_asset_id uuid)
RETURNS integer
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public
AS $$
DECLARE
  a         public.fixed_assets%ROWTYPE;
  monthly   numeric;
  d         date;
  inserted  integer := 0;
  i         integer;
BEGIN
  SELECT * INTO a FROM public.fixed_assets WHERE id = _asset_id;
  IF a.depreciation_method <> 'straight_line' OR a.useful_life_months = 0 THEN
    RETURN 0;
  END IF;
  monthly := ROUND((a.acquisition_cost - a.salvage_value) / a.useful_life_months, 2);

  -- delete unposted future rows (allow regeneration)
  DELETE FROM public.depreciation_schedule
   WHERE asset_id = _asset_id AND posted = false;

  d := date_trunc('month', a.acquisition_date)::date;
  FOR i IN 0..(a.useful_life_months - 1) LOOP
    BEGIN
      INSERT INTO public.depreciation_schedule(asset_id, year, month, amount)
      VALUES (_asset_id, EXTRACT(YEAR FROM d)::int, EXTRACT(MONTH FROM d)::int, monthly);
      inserted := inserted + 1;
    EXCEPTION WHEN unique_violation THEN
      -- already exists (likely posted), skip
      NULL;
    END;
    d := (d + INTERVAL '1 month')::date;
  END LOOP;
  RETURN inserted;
END $$;

-- Post one month's depreciation as a JE
CREATE OR REPLACE FUNCTION public.fn_post_depreciation_month(_year int, _month int)
RETURNS integer
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public
AS $$
DECLARE
  r           record;
  v_entry_id  uuid;
  v_dep       uuid;
  v_acc       uuid;
  posted_n    integer := 0;
BEGIN
  FOR r IN
    SELECT ds.id AS schedule_id, ds.amount, fa.id AS asset_id, fa.name,
           fa.depr_expense_account_code, fa.accum_depr_account_code, fa.property_id
      FROM public.depreciation_schedule ds
      JOIN public.fixed_assets fa ON fa.id = ds.asset_id
     WHERE ds.year = _year AND ds.month = _month AND ds.posted = false
       AND fa.status = 'active'
       AND ds.amount > 0
  LOOP
    v_dep := public.fn_account_or_suspense(r.depr_expense_account_code);
    v_acc := public.fn_account_or_suspense(r.accum_depr_account_code);

    INSERT INTO public.journal_entries
      (entry_date, description, entry_type, reference, property_id,
       source_table, source_id, posted, posted_at)
    VALUES (MAKE_DATE(_year, _month, 28),
            'Depreciation: ' || r.name,
            'depreciation', r.schedule_id::text, r.property_id,
            'depreciation_schedule', r.schedule_id, true, now())
    RETURNING id INTO v_entry_id;

    INSERT INTO public.journal_lines (journal_entry_id, account_id, debit, credit, memo) VALUES
      (v_entry_id, v_dep, r.amount, 0,        'Depreciation expense'),
      (v_entry_id, v_acc, 0,        r.amount, 'Accumulated depreciation');

    UPDATE public.depreciation_schedule
       SET posted = true, journal_entry_id = v_entry_id, posted_at = now()
     WHERE id = r.schedule_id;
    posted_n := posted_n + 1;
  END LOOP;
  RETURN posted_n;
END $$;

-- ---------- 2. INVENTORY (Weighted Average Cost) ---------------------
CREATE TABLE public.inventory_items (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  sku text NOT NULL UNIQUE,
  name text NOT NULL,
  description text,
  unit text NOT NULL DEFAULT 'unit',          -- kg, l, unit, box
  category text,
  property_id uuid REFERENCES public.properties(id),
  inventory_account_code text NOT NULL DEFAULT '3211',
  cogs_account_code text NOT NULL DEFAULT '6111',
  reorder_level numeric DEFAULT 0,
  current_qty numeric NOT NULL DEFAULT 0,
  avg_cost numeric NOT NULL DEFAULT 0,        -- maintained automatically
  is_active boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE public.inventory_movements (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  item_id uuid NOT NULL REFERENCES public.inventory_items(id) ON DELETE RESTRICT,
  movement_type text NOT NULL,                -- 'in' (purchase/adjust+) | 'out' (consumption/sale/adjust-)
  qty numeric NOT NULL,                       -- always positive
  unit_cost numeric NOT NULL DEFAULT 0,       -- for 'in': purchase cost; for 'out': WAC at moment of move
  total_value numeric NOT NULL DEFAULT 0,     -- qty * unit_cost
  reference text,
  description text,
  movement_date date NOT NULL DEFAULT CURRENT_DATE,
  property_id uuid REFERENCES public.properties(id),
  source_table text,
  source_id uuid,
  journal_entry_id uuid,
  created_by uuid,
  created_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE public.inventory_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.inventory_movements ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Admins manage inventory_items" ON public.inventory_items
  FOR ALL TO authenticated USING (has_role(auth.uid(),'admin')) WITH CHECK (has_role(auth.uid(),'admin'));
CREATE POLICY "Auth view inventory_items" ON public.inventory_items
  FOR SELECT TO authenticated USING (true);

CREATE POLICY "Admins manage inventory_movements" ON public.inventory_movements
  FOR ALL TO authenticated USING (has_role(auth.uid(),'admin')) WITH CHECK (has_role(auth.uid(),'admin'));
CREATE POLICY "Auth view inventory_movements" ON public.inventory_movements
  FOR SELECT TO authenticated USING (true);

-- WAC engine: on each movement insert, recompute avg_cost and current_qty,
-- and auto-post a balanced journal entry.
CREATE OR REPLACE FUNCTION public.fn_inventory_movement_post()
RETURNS trigger
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public
AS $$
DECLARE
  v_item       public.inventory_items%ROWTYPE;
  v_new_qty    numeric;
  v_new_avg    numeric;
  v_inv_acc    uuid;
  v_cogs_acc   uuid;
  v_cash       uuid;
  v_entry_id   uuid;
  v_value      numeric;
BEGIN
  SELECT * INTO v_item FROM public.inventory_items WHERE id = NEW.item_id FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'inventory item % not found', NEW.item_id; END IF;

  IF NEW.movement_type = 'in' THEN
    v_new_qty := v_item.current_qty + NEW.qty;
    IF v_new_qty > 0 THEN
      v_new_avg := ROUND(((v_item.current_qty * v_item.avg_cost) + (NEW.qty * NEW.unit_cost)) / v_new_qty, 4);
    ELSE
      v_new_avg := NEW.unit_cost;
    END IF;
    v_value := ROUND(NEW.qty * NEW.unit_cost, 2);
    NEW.total_value := v_value;
  ELSIF NEW.movement_type = 'out' THEN
    IF NEW.qty > v_item.current_qty THEN
      RAISE EXCEPTION 'Insufficient stock for % (have %, requested %)', v_item.sku, v_item.current_qty, NEW.qty;
    END IF;
    v_new_qty := v_item.current_qty - NEW.qty;
    v_new_avg := v_item.avg_cost;             -- WAC unchanged on out
    NEW.unit_cost := v_item.avg_cost;
    v_value := ROUND(NEW.qty * v_item.avg_cost, 2);
    NEW.total_value := v_value;
  ELSE
    RAISE EXCEPTION 'Unknown movement_type %', NEW.movement_type;
  END IF;

  -- Auto-post JE if value > 0
  IF v_value > 0 THEN
    v_inv_acc  := public.fn_account_or_suspense(v_item.inventory_account_code);
    v_cogs_acc := public.fn_account_or_suspense(v_item.cogs_account_code);
    v_cash     := public.fn_account_or_suspense('1111');

    INSERT INTO public.journal_entries
      (entry_date, description, entry_type, reference, property_id,
       source_table, source_id, posted, posted_at)
    VALUES (NEW.movement_date,
            'Inventory ' || NEW.movement_type || ': ' || v_item.name ||
              ' x ' || NEW.qty,
            'inventory', NEW.id::text, NEW.property_id,
            'inventory_movements', NEW.id, true, now())
    RETURNING id INTO v_entry_id;

    IF NEW.movement_type = 'in' THEN
      INSERT INTO public.journal_lines (journal_entry_id, account_id, debit, credit, memo) VALUES
        (v_entry_id, v_inv_acc, v_value, 0,       'Inventory in'),
        (v_entry_id, v_cash,    0,       v_value, 'Paid for inventory');
    ELSE
      INSERT INTO public.journal_lines (journal_entry_id, account_id, debit, credit, memo) VALUES
        (v_entry_id, v_cogs_acc, v_value, 0,       'COGS / consumption'),
        (v_entry_id, v_inv_acc,  0,       v_value, 'Inventory out');
    END IF;
    NEW.journal_entry_id := v_entry_id;
  END IF;

  UPDATE public.inventory_items
     SET current_qty = v_new_qty,
         avg_cost    = v_new_avg,
         updated_at  = now()
   WHERE id = NEW.item_id;

  RETURN NEW;
END $$;

CREATE TRIGGER trg_inventory_movement_post
BEFORE INSERT ON public.inventory_movements
FOR EACH ROW EXECUTE FUNCTION public.fn_inventory_movement_post();

-- ---------- 3. BANK RECONCILIATION ------------------------------------
CREATE TABLE public.bank_reconciliations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  bank_account_id uuid NOT NULL,
  year integer NOT NULL,
  month integer NOT NULL,
  statement_balance numeric NOT NULL DEFAULT 0,
  book_balance numeric NOT NULL DEFAULT 0,
  difference numeric GENERATED ALWAYS AS (statement_balance - book_balance) STORED,
  status text NOT NULL DEFAULT 'open',          -- open | reconciled
  reconciled_by uuid,
  reconciled_at timestamptz,
  notes text,
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (bank_account_id, year, month)
);

-- Mark bank_transactions as reconciled
ALTER TABLE public.bank_transactions
  ADD COLUMN IF NOT EXISTS reconciled boolean NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS reconciliation_id uuid,
  ADD COLUMN IF NOT EXISTS matched_je_id uuid;

ALTER TABLE public.bank_reconciliations ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Admins manage bank_reconciliations" ON public.bank_reconciliations
  FOR ALL TO authenticated USING (has_role(auth.uid(),'admin')) WITH CHECK (has_role(auth.uid(),'admin'));
CREATE POLICY "Auth view bank_reconciliations" ON public.bank_reconciliations
  FOR SELECT TO authenticated USING (true);

-- ---------- 4. FX REVALUATION ----------------------------------------
CREATE TABLE public.fx_revaluations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  year integer NOT NULL,
  month integer NOT NULL,
  currency text NOT NULL,
  rate_used numeric NOT NULL,
  total_adjustment numeric NOT NULL DEFAULT 0,
  journal_entry_id uuid,
  posted boolean NOT NULL DEFAULT false,
  posted_by uuid,
  posted_at timestamptz,
  notes text,
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (year, month, currency)
);

ALTER TABLE public.fx_revaluations ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Admins manage fx_revaluations" ON public.fx_revaluations
  FOR ALL TO authenticated USING (has_role(auth.uid(),'admin')) WITH CHECK (has_role(auth.uid(),'admin'));
CREATE POLICY "Auth view fx_revaluations" ON public.fx_revaluations
  FOR SELECT TO authenticated USING (true);

-- ---------- 5. DOCUMENT ATTACHMENTS ----------------------------------
CREATE TABLE public.document_attachments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  source_table text NOT NULL,                  -- expense_transactions, supplier_invoices, etc.
  source_id uuid NOT NULL,
  storage_path text NOT NULL,                  -- bucket path
  filename text NOT NULL,
  mime_type text,
  file_size_bytes integer,
  ocr_text text,                               -- extracted by AI Gateway
  ocr_status text NOT NULL DEFAULT 'pending',  -- pending | done | failed | skipped
  ocr_processed_at timestamptz,
  uploaded_by uuid,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX idx_doc_attachments_source ON public.document_attachments(source_table, source_id);

ALTER TABLE public.document_attachments ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Admins manage document_attachments" ON public.document_attachments
  FOR ALL TO authenticated USING (has_role(auth.uid(),'admin')) WITH CHECK (has_role(auth.uid(),'admin'));
CREATE POLICY "Auth view document_attachments" ON public.document_attachments
  FOR SELECT TO authenticated USING (true);

-- Storage bucket for attachments (private)
INSERT INTO storage.buckets (id, name, public)
VALUES ('attachments', 'attachments', false)
ON CONFLICT (id) DO NOTHING;

CREATE POLICY "Admins upload attachments"
  ON storage.objects FOR INSERT TO authenticated
  WITH CHECK (bucket_id = 'attachments' AND has_role(auth.uid(),'admin'));

CREATE POLICY "Auth read attachments"
  ON storage.objects FOR SELECT TO authenticated
  USING (bucket_id = 'attachments');

CREATE POLICY "Admins delete attachments"
  ON storage.objects FOR DELETE TO authenticated
  USING (bucket_id = 'attachments' AND has_role(auth.uid(),'admin'));

-- ---------- 6. APPROVAL WORKFLOW -------------------------------------
ALTER TABLE public.expense_transactions
  ADD COLUMN IF NOT EXISTS approval_status text NOT NULL DEFAULT 'approved',  -- approved | pending | rejected
  ADD COLUMN IF NOT EXISTS approved_by uuid,
  ADD COLUMN IF NOT EXISTS approved_at timestamptz;

ALTER TABLE public.supplier_invoices
  ADD COLUMN IF NOT EXISTS approval_status text NOT NULL DEFAULT 'approved',
  ADD COLUMN IF NOT EXISTS approved_by uuid,
  ADD COLUMN IF NOT EXISTS approved_at timestamptz;

-- Threshold lives in company_settings
ALTER TABLE public.company_settings
  ADD COLUMN IF NOT EXISTS approval_threshold_mzn numeric NOT NULL DEFAULT 50000,
  ADD COLUMN IF NOT EXISTS approval_required boolean NOT NULL DEFAULT true;

-- Trigger: on expense insert above threshold => pending
CREATE OR REPLACE FUNCTION public.fn_expense_approval_gate()
RETURNS trigger
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public
AS $$
DECLARE
  v_thr numeric;
  v_required boolean;
BEGIN
  SELECT approval_threshold_mzn, approval_required
    INTO v_thr, v_required
    FROM public.company_settings LIMIT 1;
  IF v_required IS TRUE AND COALESCE(NEW.amount_mzn,0) >= COALESCE(v_thr, 50000) THEN
    NEW.approval_status := 'pending';
    -- Block auto-post: clear journal_entry_id so trigger order won't post it.
    -- We achieve this by deferring the auto-post: poster trigger checks status.
  END IF;
  RETURN NEW;
END $$;

CREATE TRIGGER trg_expense_approval_gate
BEFORE INSERT ON public.expense_transactions
FOR EACH ROW EXECUTE FUNCTION public.fn_expense_approval_gate();

-- Update auto-post to skip pending
CREATE OR REPLACE FUNCTION public.fn_auto_post_expense()
RETURNS trigger
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public
AS $$
DECLARE
  v_entry_id uuid; v_total numeric;
  v_exp uuid; v_cash uuid; v_code text;
BEGIN
  IF NEW.journal_entry_id IS NOT NULL THEN RETURN NEW; END IF;
  IF NEW.approval_status = 'pending' OR NEW.approval_status = 'rejected' THEN RETURN NEW; END IF;
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

-- Approve/reject helpers
CREATE OR REPLACE FUNCTION public.fn_approve_expense(_id uuid)
RETURNS void
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public
AS $$
DECLARE
  v_entry_id uuid; v_total numeric;
  v_exp uuid; v_cash uuid; v_code text;
  r public.expense_transactions%ROWTYPE;
BEGIN
  IF NOT has_role(auth.uid(), 'admin') THEN
    RAISE EXCEPTION 'admin only';
  END IF;
  SELECT * INTO r FROM public.expense_transactions WHERE id = _id FOR UPDATE;
  IF r.approval_status <> 'pending' THEN
    RAISE EXCEPTION 'expense % is not pending', _id;
  END IF;

  v_total := COALESCE(r.amount_mzn, 0);
  IF r.category_id IS NOT NULL THEN
    SELECT pgc_account_code INTO v_code FROM public.expense_categories WHERE id = r.category_id;
  END IF;
  v_exp  := public.fn_account_or_suspense(v_code);
  v_cash := public.fn_account_or_suspense('1111');

  INSERT INTO public.journal_entries
    (entry_date, description, entry_type, reference, property_id,
     source_table, source_id, posted, posted_at)
  VALUES (r.date, r.description, 'expense', r.id::text, r.property_id,
          'expense_transactions', r.id, true, now())
  RETURNING id INTO v_entry_id;

  INSERT INTO public.journal_lines (journal_entry_id, account_id, debit, credit, memo) VALUES
    (v_entry_id, v_exp,  v_total, 0,       r.description),
    (v_entry_id, v_cash, 0,       v_total, 'Paid');

  UPDATE public.expense_transactions
     SET approval_status = 'approved',
         approved_by = auth.uid(),
         approved_at = now(),
         journal_entry_id = v_entry_id
   WHERE id = _id;
END $$;

CREATE OR REPLACE FUNCTION public.fn_reject_expense(_id uuid, _reason text)
RETURNS void
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public
AS $$
BEGIN
  IF NOT has_role(auth.uid(), 'admin') THEN RAISE EXCEPTION 'admin only'; END IF;
  UPDATE public.expense_transactions
     SET approval_status = 'rejected',
         approved_by = auth.uid(),
         approved_at = now()
   WHERE id = _id AND approval_status = 'pending';
END $$;

-- ---------- 7. AUDIT LOG ---------------------------------------------
CREATE TABLE public.audit_log (
  id bigserial PRIMARY KEY,
  occurred_at timestamptz NOT NULL DEFAULT now(),
  actor_id uuid,
  actor_email text,
  action text NOT NULL,                  -- INSERT | UPDATE | DELETE | SELECT | LOGIN | LOGOUT | LOGIN_FAILED | ROLE_GRANT | ROLE_REVOKE
  table_name text,
  row_id text,
  old_data jsonb,
  new_data jsonb,
  ip_address text,
  user_agent text,
  details jsonb
);

CREATE INDEX idx_audit_log_occurred ON public.audit_log(occurred_at DESC);
CREATE INDEX idx_audit_log_table_row ON public.audit_log(table_name, row_id);
CREATE INDEX idx_audit_log_actor ON public.audit_log(actor_id);

ALTER TABLE public.audit_log ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Admins view audit_log" ON public.audit_log
  FOR SELECT TO authenticated USING (has_role(auth.uid(),'admin'));
-- inserts come from triggers (SECURITY DEFINER) and edge functions; no INSERT policy needed.

-- Generic audit trigger function
CREATE OR REPLACE FUNCTION public.fn_audit_row()
RETURNS trigger
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public
AS $$
DECLARE
  v_actor uuid := auth.uid();
  v_email text;
  v_row_id text;
BEGIN
  IF v_actor IS NOT NULL THEN
    SELECT email INTO v_email FROM public.profiles WHERE user_id = v_actor LIMIT 1;
  END IF;

  IF TG_OP = 'DELETE' THEN
    v_row_id := COALESCE(OLD.id::text, '');
    INSERT INTO public.audit_log(actor_id, actor_email, action, table_name, row_id, old_data)
    VALUES (v_actor, v_email, 'DELETE', TG_TABLE_NAME, v_row_id, to_jsonb(OLD));
    RETURN OLD;
  ELSIF TG_OP = 'UPDATE' THEN
    v_row_id := COALESCE(NEW.id::text, '');
    INSERT INTO public.audit_log(actor_id, actor_email, action, table_name, row_id, old_data, new_data)
    VALUES (v_actor, v_email, 'UPDATE', TG_TABLE_NAME, v_row_id, to_jsonb(OLD), to_jsonb(NEW));
    RETURN NEW;
  ELSE
    v_row_id := COALESCE(NEW.id::text, '');
    INSERT INTO public.audit_log(actor_id, actor_email, action, table_name, row_id, new_data)
    VALUES (v_actor, v_email, 'INSERT', TG_TABLE_NAME, v_row_id, to_jsonb(NEW));
    RETURN NEW;
  END IF;
END $$;

-- Apply audit triggers to financial tables
DO $$
DECLARE
  t text;
  tables text[] := ARRAY[
    'journal_entries','journal_lines','accounts','accounting_periods',
    'income_transactions','expense_transactions','bank_transactions',
    'petty_cash_transactions','salary_runs','salary_lines','salary_advances',
    'invoices','supplier_invoices','budgets',
    'fixed_assets','depreciation_schedule',
    'inventory_items','inventory_movements',
    'bank_reconciliations','fx_revaluations',
    'document_attachments','user_roles','company_settings'
  ];
BEGIN
  FOREACH t IN ARRAY tables LOOP
    EXECUTE format('DROP TRIGGER IF EXISTS trg_audit_%I ON public.%I', t, t);
    EXECUTE format(
      'CREATE TRIGGER trg_audit_%I AFTER INSERT OR UPDATE OR DELETE ON public.%I
         FOR EACH ROW EXECUTE FUNCTION public.fn_audit_row()', t, t);
  END LOOP;
END $$;

-- Helper for app code to log non-DB events (auth, sensitive reads)
CREATE OR REPLACE FUNCTION public.fn_audit_event(
  _action text, _table_name text, _row_id text,
  _details jsonb DEFAULT NULL
)
RETURNS void
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public
AS $$
DECLARE
  v_actor uuid := auth.uid();
  v_email text;
BEGIN
  IF v_actor IS NOT NULL THEN
    SELECT email INTO v_email FROM public.profiles WHERE user_id = v_actor LIMIT 1;
  END IF;
  INSERT INTO public.audit_log(actor_id, actor_email, action, table_name, row_id, details)
  VALUES (v_actor, v_email, _action, _table_name, _row_id, _details);
END $$;

GRANT EXECUTE ON FUNCTION public.fn_audit_event(text,text,text,jsonb) TO authenticated;
GRANT EXECUTE ON FUNCTION public.fn_approve_expense(uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION public.fn_reject_expense(uuid,text) TO authenticated;
GRANT EXECUTE ON FUNCTION public.fn_generate_depreciation_schedule(uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION public.fn_post_depreciation_month(int,int) TO authenticated;
