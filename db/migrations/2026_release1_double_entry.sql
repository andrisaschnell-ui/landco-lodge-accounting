-- =========================================================================
-- Release 1 — Activate the double-entry engine
-- One-shot migration for EXISTING local Postgres installs.
-- (Fresh installs already get this from db/init/01_schema_full.sql.)
--
-- How to run on a running local stack:
--   docker exec -i lanacc-postgres psql -U landco -d landco \
--     < db/migrations/2026_release1_double_entry.sql
-- =========================================================================

-- 1) Source traceability columns
ALTER TABLE public.journal_entries
  ADD COLUMN IF NOT EXISTS source_table text,
  ADD COLUMN IF NOT EXISTS source_id    uuid;

CREATE INDEX IF NOT EXISTS idx_journal_entries_source
  ON public.journal_entries (source_table, source_id);

-- 2) Balance-check trigger
CREATE OR REPLACE FUNCTION public.fn_journal_lines_balance_check()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE
  v_entry_id uuid;
  v_debit numeric; v_credit numeric; v_count integer;
BEGIN
  v_entry_id := COALESCE(NEW.journal_entry_id, OLD.journal_entry_id);
  SELECT COALESCE(SUM(debit),0), COALESCE(SUM(credit),0), COUNT(*)
    INTO v_debit, v_credit, v_count
    FROM public.journal_lines WHERE journal_entry_id = v_entry_id;
  IF v_count = 0 THEN RETURN COALESCE(NEW, OLD); END IF;
  IF ROUND(v_debit, 2) <> ROUND(v_credit, 2) THEN
    RAISE EXCEPTION 'Journal entry % is unbalanced: debit=% credit=% (difference=%)',
      v_entry_id, v_debit, v_credit, ROUND(v_debit - v_credit, 2);
  END IF;
  RETURN COALESCE(NEW, OLD);
END $$;

DROP TRIGGER IF EXISTS trg_journal_lines_balance_check ON public.journal_lines;
CREATE CONSTRAINT TRIGGER trg_journal_lines_balance_check
  AFTER INSERT OR UPDATE OR DELETE ON public.journal_lines
  DEFERRABLE INITIALLY DEFERRED
  FOR EACH ROW EXECUTE FUNCTION public.fn_journal_lines_balance_check();

-- 3) Period-lock trigger
CREATE OR REPLACE FUNCTION public.fn_journal_entries_period_lock()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE v_date date; v_closed boolean;
BEGIN
  v_date := COALESCE(NEW.entry_date, OLD.entry_date);
  IF v_date IS NULL THEN RETURN COALESCE(NEW, OLD); END IF;
  SELECT is_closed INTO v_closed FROM public.accounting_periods
   WHERE year = EXTRACT(YEAR FROM v_date)::int
     AND month = EXTRACT(MONTH FROM v_date)::int;
  IF v_closed IS TRUE THEN
    RAISE EXCEPTION 'Accounting period %-% is closed. Reopen it in Settings before posting.',
      EXTRACT(YEAR FROM v_date)::int, EXTRACT(MONTH FROM v_date)::int;
  END IF;
  RETURN COALESCE(NEW, OLD);
END $$;

DROP TRIGGER IF EXISTS trg_journal_entries_period_lock ON public.journal_entries;
CREATE TRIGGER trg_journal_entries_period_lock
  BEFORE INSERT OR UPDATE OR DELETE ON public.journal_entries
  FOR EACH ROW EXECUTE FUNCTION public.fn_journal_entries_period_lock();
