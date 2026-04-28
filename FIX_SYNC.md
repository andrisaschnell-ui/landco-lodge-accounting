# Fix: "Sync pull complete — 26 tables, 0 rows"

If sync runs without errors but pulls **0 rows** from Cloud, the API container
is hitting cloud RLS with the anon key because `SUPABASE_SERVICE_ROLE_KEY`
never reached it. This is the same fix on every machine.

## 1. Verify the diagnosis (browser)

Open: `http://localhost:4000/api/sync/status`

You should see:
```json
{
  "service_role_key_loaded": true,
  "push_enabled": true,
  "pull_will_use": "service_role"
}
```

If `service_role_key_loaded` is **false** → continue below.

## 2. One-shot fix per machine

### Windows
```powershell
cd <project-root>
git pull origin v5
.\scripts\fix_sync.bat
```

### Mac / Linux
```bash
cd <project-root>
git pull origin v5
bash scripts/fix_sync.sh
```

The script will:
1. Prompt for the service-role key (paste it once).
2. Write it to `.env.local` (gitignored).
3. Recreate the API container so it picks up the new env var.
4. Re-check `/api/sync/status` and confirm.

## 3. Where to get the key

Lovable → **Cloud** → **Backend** → **API keys** → copy the **`service_role`** key
(the long one, NOT the anon/publishable key).

> Treat it like a password. It bypasses all RLS.

## 4. Re-run the sync

In the app: **Sync** → **Pull Cloud → Local**.
You should now see a real row count instead of 0.

## After this fix, pull will refuse to silently fail

If the key is missing, `/api/sync/pull` now returns HTTP 400 with:
> `SUPABASE_SERVICE_ROLE_KEY not loaded in API container...`

You will see this in the toast in the UI, instead of a misleading "complete, 0 rows".
