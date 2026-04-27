# LANACC Mode Switch — Install Notes (in-repo version)

All files for the Cloud / Local toggle and manual two-way sync are now part of
the repository. **You no longer need to install any zip.** On any machine:

```powershell
git pull origin v5
docker compose up -d --build
```

## What's in the repo

| File | Purpose |
|---|---|
| `src/lib/dbMode.ts` | Cloud/Local controller, persisted in localStorage |
| `src/components/ModeToggle.tsx` | Toggle button (pill on login, chip in header) |
| `src/components/SyncPanel.tsx` | Manual Push/Pull dialog |
| `src/integrations/supabase/client.ts` | Mode-aware client (cloud SDK or local API shim) |
| `api/routes/sync.js` | `/api/sync/push` and `/api/sync/pull` endpoints |
| `api/server.js` | Wires sync routes |
| `src/pages/Auth.tsx` | Pill toggle on login screen |
| `src/components/AppLayout.tsx` | Header chip + Sync button |
| `docker-compose.override.yml` | LAN access + cloud sync env wiring |
| `.env.example` | Reference values; copy to `.env` if needed |

## One-time host setup

1. **Service-role key (only required for Push Local → Cloud).**
   In PowerShell before `docker compose up`:
   ```powershell
   $env:SUPABASE_SERVICE_ROLE_KEY="eyJ...your-service-role-key..."
   docker compose up -d --build
   ```
   Or paste it into `docker-compose.override.yml` under `api.environment`.

2. **LAN access from other PCs on the same Wi-Fi.**
   Find the host's LAN IPv4 (`ipconfig`), then either:
   - Edit `docker-compose.override.yml` → uncomment `VITE_API_URL=http://<host-ip>:4000` and rebuild `web`, or
   - Leave it empty: the app auto-detects `window.location.hostname:4000`, which works as long as the user opens `http://<host-ip>:8080` in their browser.

3. **First-time data seed (Local mode).**
   Toggle to **Local**, sign in with the two admin users, click **Sync → Pull Cloud → Local**.

## Backups

The toggle does **not** affect backups. The existing backup tool dumps whichever
database the API container is connected to (the local Postgres). Cloud backups
are managed by Lovable Cloud separately.

## Conflict policy

**Local wins** on both directions:
- Push: PostgREST `resolution=merge-duplicates` (local row overwrites cloud row with same id).
- Pull: `INSERT … ON CONFLICT (id) DO UPDATE` (cloud row overwrites local only when ids match — but since you push before pull when local is authoritative, run Pull first only on a fresh local DB).

Recommended workflow: **Pull once** to seed local, then work locally and **Push** periodically.
