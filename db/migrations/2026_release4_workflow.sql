-- =====================================================================
-- RELEASE 4: Inventory, Assets, Banking, Workflow, Audit
-- Apply with:
--   docker exec -i lanacc-postgres psql -U landco -d landco < db/migrations/2026_release4_workflow.sql
-- =====================================================================

-- ---------- 1. FIXED ASSETS ------------------------------------------
CREATE TABLE IF NOT EXISTS public.fixed_assets (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  asset_code text NOT NULL UNIQUE,
  name text NOT NULL,
  description text,
  category text NOT NULL,
  property_id uuid,
  acquisition_date date NOT NULL,
  acquisition_cost numeric NOT NULL DEFAULT 0,
  salvage_value numeric NOT NULL DEFAULT 0,
  useful_life_months integer NOT NULL DEFAULT 60,
  depreciation_method text NOT NULL DEFAULT 'straight_line',
  asset_account_code text NOT NULL,
  accum_depr_account_code text NOT NULL,
  depr_expense_account_code text NOT NULL,
  status text NOT NULL DEFAULT 'active',
  disposed_date date,
  disposed_amount numeric,
  notes text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.depreciation_schedule (
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

CREATE OR REPLACE FUNCTION public.fn_generate_depreciation_schedule(_asset_id uuid)
RETURNS integer LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE a public.fixed_assets%ROWTYPE; monthly numeric; d date; inserted int := 0; i int;
BEGIN
  SELECT * INTO a FROM public.fixed_assets WHERE id = _asset_id;
  IF a.depreciation_method <> 'straight_line' OR a.useful_life_months = 0 THEN RETURN 0; END IF;
  monthly := ROUND((a.acquisition_cost - a.salvage_value) / a.useful_life_months, 2);
  DELETE FROM public.depreciation_schedule WHERE asset_id = _asset_id AND posted = false;
  d := date_trunc('month', a.acquisition_date)::date;
  FOR i IN 0..(a.useful_life_months - 1) LOOP
    BEGIN
      INSERT INTO public.depreciation_schedule(asset_id, year, month, amount)
      VALUES (_asset_id, EXTRACT(YEAR FROM d)::int, EXTRACT(MONTH FROM d)::int, monthly);
      inserted := inserted + 1;
    EXCEPTION WHEN unique_violation THEN NULL;
    END;
    d := (d + INTERVAL '1 month')::date;
  END LOOP;
  RETURN inserted;
END $$;

CREATE OR REPLACE FUNCTION public.fn_post_depreciation_month(_year int, _month int)
RETURNS integer LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE r record; v_entry_id uuid; v_dep uuid; v_acc uuid; posted_n int := 0;
BEGIN
  FOR r IN
    SELECT ds.id AS schedule_id, ds.amount, fa.id AS asset_id, fa.name,
           fa.depr_expense_account_code, fa.accum_depr_account_code, fa.property_id
      FROM public.depreciation_schedule ds JOIN public.fixed_assets fa ON fa.id = ds.asset_id
     WHERE ds.year = _year AND ds.month = _month AND ds.posted = false
       AND fa.status = 'active' AND ds.amount > 0
  LOOP
    v_dep := public.fn_account_or_suspense(r.depr_expense_account_code);
    v_acc := public.fn_account_or_suspense(r.accum_depr_account_code);
    INSERT INTO public.journal_entries (entry_date, description, entry_type, reference, property_id, source_table, source_id, posted, posted_at)
    VALUES (MAKE_DATE(_year, _month, 28), 'Depreciation: ' || r.name, 'depreciation', r.schedule_id::text, r.property_id, 'depreciation_schedule', r.schedule_id, true, now())
    RETURNING id INTO v_entry_id;
    INSERT INTO public.journal_lines (journal_entry_id, account_id, debit, credit, memo) VALUES
      (v_entry_id, v_dep, r.amount, 0, 'Depreciation expense'),
      (v_entry_id, v_acc, 0, r.amount, 'Accumulated depreciation');
    UPDATE public.depreciation_schedule SET posted = true, journal_entry_id = v_entry_id, posted_at = now() WHERE id = r.schedule_id;
    posted_n := posted_n + 1;
  END LOOP;
  RETURN posted_n;
END $$;

-- ---------- 2. INVENTORY (WAC) ---------------------------------------
CREATE TABLE IF NOT EXISTS public.inventory_items (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  sku text NOT NULL UNIQUE, name text NOT NULL, description text,
  unit text NOT NULL DEFAULT 'unit', category text, property_id uuid,
  inventory_account_code text NOT NULL DEFAULT '3211',
  cogs_account_code text NOT NULL DEFAULT '6111',
  reorder_level numeric DEFAULT 0,
  current_qty numeric NOT NULL DEFAULT 0,
  avg_cost numeric NOT NULL DEFAULT 0,
  is_active boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.inventory_movements (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  item_id uuid NOT NULL REFERENCES public.inventory_items(id) ON DELETE RESTRICT,
  movement_type text NOT NULL, qty numeric NOT NULL,
  unit_cost numeric NOT NULL DEFAULT 0, total_value numeric NOT NULL DEFAULT 0,
  reference text, description text,
  movement_date date NOT NULL DEFAULT CURRENT_DATE,
  property_id uuid, source_table text, source_id uuid,
  journal_entry_id uuid, created_by uuid,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE OR REPLACE FUNCTION public.fn_inventory_movement_post()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE v_item public.inventory_items%ROWTYPE; v_new_qty numeric; v_new_avg numeric;
        v_inv_acc uuid; v_cogs_acc uuid; v_cash uuid; v_entry_id uuid; v_value numeric;
BEGIN
  SELECT * INTO v_item FROM public.inventory_items WHERE id = NEW.item_id FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'inventory item % not found', NEW.item_id; END IF;
  IF NEW.movement_type = 'in' THEN
    v_new_qty := v_item.current_qty + NEW.qty;
    IF v_new_qty > 0 THEN
      v_new_avg := ROUND(((v_item.current_qty * v_item.avg_cost) + (NEW.qty * NEW.unit_cost)) / v_new_qty, 4);
    ELSE v_new_avg := NEW.unit_cost; END IF;
    v_value := ROUND(NEW.qty * NEW.unit_cost, 2); NEW.total_value := v_value;
  ELSIF NEW.movement_type = 'out' THEN
    IF NEW.qty > v_item.current_qty THEN
      RAISE EXCEPTION 'Insufficient stock for % (have %, requested %)', v_item.sku, v_item.current_qty, NEW.qty;
    END IF;
    v_new_qty := v_item.current_qty - NEW.qty; v_new_avg := v_item.avg_cost;
    NEW.unit_cost := v_item.avg_cost;
    v_value := ROUND(NEW.qty * v_item.avg_cost, 2); NEW.total_value := v_value;
  ELSE RAISE EXCEPTION 'Unknown movement_type %', NEW.movement_type;
  END IF;

  IF v_value > 0 THEN
    v_inv_acc := public.fn_account_or_suspense(v_item.inventory_account_code);
    v_cogs_acc := public.fn_account_or_suspense(v_item.cogs_account_code);
    v_cash := public.fn_account_or_suspense('1111');
    INSERT INTO public.journal_entries (entry_date, description, entry_type, reference, property_id, source_table, source_id, posted, posted_at)
    VALUES (NEW.movement_date, 'Inventory ' || NEW.movement_type || ': ' || v_item.name || ' x ' || NEW.qty,
            'inventory', NEW.id::text, NEW.property_id, 'inventory_movements', NEW.id, true, now())
    RETURNING id INTO v_entry_id;
    IF NEW.movement_type = 'in' THEN
      INSERT INTO public.journal_lines (journal_entry_id, account_id, debit, credit, memo) VALUES
        (v_entry_id, v_inv_acc, v_value, 0, 'Inventory in'),
        (v_entry_id, v_cash, 0, v_value, 'Paid for inventory');
    ELSE
      INSERT INTO public.journal_lines (journal_entry_id, account_id, debit, credit, memo) VALUES
        (v_entry_id, v_cogs_acc, v_value, 0, 'COGS / consumption'),
        (v_entry_id, v_inv_acc, 0, v_value, 'Inventory out');
    END IF;
    NEW.journal_entry_id := v_entry_id;
  END IF;

  UPDATE public.inventory_items SET current_qty = v_new_qty, avg_cost = v_new_avg, updated_at = now() WHERE id = NEW.item_id;
  RETURN NEW;
END $$;

DROP TRIGGER IF EXISTS trg_inventory_movement_post ON public.inventory_movements;
CREATE TRIGGER trg_inventory_movement_post
BEFORE INSERT ON public.inventory_movements
FOR EACH ROW EXECUTE FUNCTION public.fn_inventory_movement_post();

-- ---------- 3. BANK RECONCILIATION -----------------------------------
CREATE TABLE IF NOT EXISTS public.bank_reconciliations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  bank_account_id uuid NOT NULL,
  year integer NOT NULL, month integer NOT NULL,
  statement_balance numeric NOT NULL DEFAULT 0,
  book_balance numeric NOT NULL DEFAULT 0,
  difference numeric GENERATED ALWAYS AS (statement_balance - book_balance) STORED,
  status text NOT NULL DEFAULT 'open',
  reconciled_by uuid, reconciled_at timestamptz, notes text,
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (bank_account_id, year, month)
);

ALTER TABLE public.bank_transactions
  ADD COLUMN IF NOT EXISTS reconciled boolean NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS reconciliation_id uuid,
  ADD COLUMN IF NOT EXISTS matched_je_id uuid;

-- ---------- 4. FX REVALUATION ----------------------------------------
CREATE TABLE IF NOT EXISTS public.fx_revaluations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  year integer NOT NULL, month integer NOT NULL, currency text NOT NULL,
  rate_used numeric NOT NULL, total_adjustment numeric NOT NULL DEFAULT 0,
  journal_entry_id uuid, posted boolean NOT NULL DEFAULT false,
  posted_by uuid, posted_at timestamptz, notes text,
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (year, month, currency)
);

-- ---------- 5. DOCUMENT ATTACHMENTS ----------------------------------
CREATE TABLE IF NOT EXISTS public.document_attachments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  source_table text NOT NULL, source_id uuid NOT NULL,
  storage_path text NOT NULL, filename text NOT NULL,
  mime_type text, file_size_bytes integer,
  ocr_text text, ocr_status text NOT NULL DEFAULT 'pending',
  ocr_processed_at timestamptz, uploaded_by uuid,
  created_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_doc_attachments_source ON public.document_attachments(source_table, source_id);

-- ---------- 6. APPROVAL WORKFLOW -------------------------------------
CREATE TABLE IF NOT EXISTS public.company_settings (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  singleton boolean NOT NULL DEFAULT true UNIQUE,
  name text NOT NULL DEFAULT 'Landco Lda',
  nuit text,
  address text,
  logo_url text,
  currency text NOT NULL DEFAULT 'MZN',
  vat_rate numeric NOT NULL DEFAULT 16,
  invoice_series_prefix text NOT NULL DEFAULT 'FT',
  fiscal_year_start_month integer NOT NULL DEFAULT 1 CHECK (fiscal_year_start_month BETWEEN 1 AND 12),
  primary_color text NOT NULL DEFAULT '142 71% 45%',
  accent_color text NOT NULL DEFAULT '210 40% 50%',
  backup_folder_path text,
  sync_target_ref text,
  default_property_id uuid,
  default_shareholder_id uuid,
  updated_by uuid,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT singleton_true CHECK (singleton = true)
);

INSERT INTO public.company_settings (name, address, currency, vat_rate, invoice_series_prefix)
SELECT 'Landco Lda', 'Vilanculos, Mozambique', 'MZN', 16, 'FT'
WHERE NOT EXISTS (SELECT 1 FROM public.company_settings);

ALTER TABLE public.expense_transactions
  ADD COLUMN IF NOT EXISTS approval_status text NOT NULL DEFAULT 'approved',
  ADD COLUMN IF NOT EXISTS approved_by uuid,
  ADD COLUMN IF NOT EXISTS approved_at timestamptz;

ALTER TABLE public.supplier_invoices
  ADD COLUMN IF NOT EXISTS approval_status text NOT NULL DEFAULT 'approved',
  ADD COLUMN IF NOT EXISTS approved_by uuid,
  ADD COLUMN IF NOT EXISTS approved_at timestamptz;

ALTER TABLE public.company_settings
  ADD COLUMN IF NOT EXISTS approval_threshold_mzn numeric NOT NULL DEFAULT 50000,
  ADD COLUMN IF NOT EXISTS approval_required boolean NOT NULL DEFAULT true;

-- ---------- 7. AUDIT LOG ---------------------------------------------
CREATE TABLE IF NOT EXISTS public.audit_log (
  id bigserial PRIMARY KEY,
  occurred_at timestamptz NOT NULL DEFAULT now(),
  actor_id uuid, actor_email text,
  action text NOT NULL,
  table_name text, row_id text,
  old_data jsonb, new_data jsonb,
  ip_address text, user_agent text, details jsonb
);
CREATE INDEX IF NOT EXISTS idx_audit_log_occurred ON public.audit_log(occurred_at DESC);
CREATE INDEX IF NOT EXISTS idx_audit_log_table_row ON public.audit_log(table_name, row_id);
CREATE INDEX IF NOT EXISTS idx_audit_log_actor ON public.audit_log(actor_id);

CREATE OR REPLACE FUNCTION public.fn_audit_row()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE v_actor uuid; v_email text; v_row_id text;
BEGIN
  -- In local Node API, auth.uid() may not exist; use current_setting('app.user_id', true)
  BEGIN v_actor := current_setting('app.user_id', true)::uuid; EXCEPTION WHEN others THEN v_actor := NULL; END;
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

DO $$
DECLARE t text;
DECLARE tables text[] := ARRAY[
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
    EXECUTE format('CREATE TRIGGER trg_audit_%I AFTER INSERT OR UPDATE OR DELETE ON public.%I FOR EACH ROW EXECUTE FUNCTION public.fn_audit_row()', t, t);
  END LOOP;
END $$;
