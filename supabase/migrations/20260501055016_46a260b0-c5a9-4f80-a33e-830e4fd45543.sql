-- Allow anon (not-yet-authenticated) calls to fn_audit_event so we can record LOGIN_FAILED.
GRANT EXECUTE ON FUNCTION public.fn_audit_event(text, text, text, jsonb) TO anon, authenticated;