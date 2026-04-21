
-- Delete the original Jan 2026 expenses that pre-date the fresh import.
-- The reimport inserted rows within the last few minutes; anything older than 5 min
-- is the stale data that needs to go.
DELETE FROM public.expense_transactions
WHERE month = 1 AND year = 2026
  AND created_at < now() - interval '5 minutes';
