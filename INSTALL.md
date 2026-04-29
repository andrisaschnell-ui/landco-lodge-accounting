# LANACC — Production Installation Manual

Single-user, on-premise deployment for **Landco Lodge Lda** with optional
two-way sync to Lovable Cloud.

> **Source of truth:** GitHub branch **`v5`**. Always clone or pull from `v5`.

---

## 1. What you are installing

| Component | Where it runs | Purpose |
|---|---|---|
| `lanacc-web` | Docker, `:8080` | React UI (Vite) |
| `lanacc-api` | Docker, `:4000` | Local Node API + auth + sync + backup |
| `lanacc-db`  | Docker, `:5432` | Postgres 17 (your authoritative data) |
| `lanacc-pgadmin` | Docker, `:5050` | Optional DB browser |
| Lovable Cloud | hosted | Mirror copy + browser-only access |
| Windows Task Scheduler | host PC | Nightly backup to USB at 22:00 |

The app has a **Cloud / Local toggle** in the top bar. Choose Cloud for
remote browser work, Local when you're on the office PC. The Sync button
moves data between them (Local wins on conflict).

---

## 2. Prerequisites (one-time per PC)

1. **Windows 10/11** with admin rights.
2. **Docker Desktop** (latest) — running, with WSL2 backend.
3. **Git for Windows**.
4. **Lexar USB drive** plugged in as **`E:\`** with folder
   `E:\landco_daily_backup` (already created).
5. The **Supabase service-role key** for project `neakxehuonsrlvjrxhnd`
   (Lovable → Cloud → Backend → API keys → `service_role`).

---

## 3. Clone the repo

```bat
cd C:\Users\<you>\Documents\Projects
git clone -b v5 https://github.com/<your-org>/landco.git landco
cd landco
```

If the repo is already cloned:

```bat
cd C:\Users\<you>\Documents\Projects\landco
git fetch origin
git checkout v5
git pull origin v5
```

> **One-time `.gitignore` patch** (the Lovable editor cannot modify
> `.gitignore` directly). Open `.gitignore` in the repo root and append
> these lines if missing, then commit them once:
> ```
> .env.local
> .env.*.local
> db/backups/*.sql
> db/backups/landco/
> db/backups/cash/
> db/backups/complete/
> ```

---

## 4. Create `.env.local` (secrets, never committed)

```bat
copy .env.example .env.local
notepad .env.local
```

Fill in **all five** secrets:

| Variable | What to put |
|---|---|
| `POSTGRES_PASSWORD` | A strong random password (≥ 20 chars). Used by Postgres + the API. |
| `JWT_SECRET` | Random 64-char string. Signs local login tokens. |
| `AT_SIGNING_KEY` | Random 64-char string. Signs invoices. |
| `PGADMIN_PASSWORD` | Password for pgAdmin UI on `:5050`. |
| `SUPABASE_SERVICE_ROLE_KEY` | Paste the service-role key. Required for Sync. |

Generate random strings quickly with PowerShell:

```powershell
-join ((48..57)+(65..90)+(97..122) | Get-Random -Count 64 | % {[char]$_})
```

> **First-time setup only:** if you are upgrading an existing install
> that used the old hard-coded `POSTGRES_PASSWORD=root`, see §10 below
> to rotate without losing data.

---

## 5. Start the stack

```bat
scripts\start.bat
```

This:
1. Verifies `.env.local` exists.
2. Runs `docker compose --env-file .env.local up -d --build`.
3. Prints health URLs and calls `/api/sync/status`.

You should see:

```
{"supabase_url":"https://neakxehuonsrlvjrxhnd.supabase.co",
 "service_role_key_loaded":true,
 "push_enabled":true, ...}
```

Open **http://localhost:8080** and log in.

If you ever lose your local password, run:

```bat
curl -X POST http://localhost:4000/auth/repair-users
```

This recreates the two admin accounts defined in `api/server.js`.

---

## 6. Install the daily backup task

Run **once, as Administrator**:

```bat
scripts\install_scheduled_task.bat
```

This registers a Windows scheduled task **"LANACC Daily Backup"** that
runs `scripts\daily_backup.bat` every day at **22:00**.

Each run:
- Calls `pg_dump` inside `lanacc-db`.
- Writes `lanacc_YYYYMMDD_HHMMSS.sql` to `E:\landco_daily_backup\`.
- Logs to `E:\landco_daily_backup\backup.log`.
- **Deletes dumps older than 30 days** (`forfiles /d -30`).

Verify:

```bat
schtasks /Query /TN "LANACC Daily Backup" /V /FO LIST
schtasks /Run   /TN "LANACC Daily Backup"
type E:\landco_daily_backup\backup.log
```

> The USB drive **must be plugged in at 22:00** for the backup to land
> on it. If it's missing, the script logs an error and exits non-zero.
> Treat the log as your daily check.

---

## 7. Using Cloud / Local toggle and Sync

- **Top-right toggle**: switches the app between Cloud (Supabase) and
  Local (Docker API). The page hard-reloads on switch.
- **Sync button** (Local mode only): opens a dialog with
  - **Pull Cloud → Local** — overwrites local rows with cloud rows on `id` match.
  - **Push Local → Cloud** — overwrites cloud rows with local rows on `id` match.
- Conflict policy is **Local wins**. Always Push after a session of
  local edits if you want the cloud mirror to stay current.

---

## 8. Restoring a backup

To restore the most recent dump from `E:\landco_daily_backup\`:

```bat
scripts\restore.bat E:\landco_daily_backup\lanacc_20260428_220000.sql
```

This pipes the SQL into `lanacc-db` via `docker exec`. The dump is a
`pg_dump --clean --if-exists`, so it drops and recreates everything
inside the `public` schema — your live data will be replaced.

> Always take a fresh backup before restoring an old one.

---

## 9. Other machines (laptop, etc.)

For each new PC:

1. Repeat §2 (prereqs) and §3 (clone `v5`).
2. Repeat §4 — **create your own `.env.local`** with the same
   `SUPABASE_SERVICE_ROLE_KEY` (cloud is shared) but its **own**
   `POSTGRES_PASSWORD` / `JWT_SECRET` / `AT_SIGNING_KEY` (local stack
   is independent per machine).
3. Run §5 to start.
4. Use **Cloud mode** by default when away from the office. Pull from
   Cloud → Local only when you want a working local copy.
5. The daily backup task (§6) is only needed on the **office PC** that
   holds the authoritative database.

---

## 10. Rotating from the old default secrets

If your existing install used `POSTGRES_PASSWORD=root` and the old
hard-coded `JWT_SECRET`:

```bat
REM 1. Take a final backup with the OLD password
scripts\daily_backup.bat

REM 2. Stop the stack
scripts\stop.bat

REM 3. Edit .env.local with new strong values (see §4)
notepad .env.local

REM 4. Update the password INSIDE Postgres before restarting,
REM    otherwise the db container will reject the new value.
docker start lanacc-db
docker exec -it lanacc-db psql -U postgres -d landco_v2_db ^
  -c "ALTER USER postgres WITH PASSWORD 'YOUR_NEW_PASSWORD';"

REM 5. Restart with the new env
scripts\start.bat
```

After rotation, anyone with the old `JWT_SECRET` is automatically
logged out (their tokens no longer validate).

---

## 11. Troubleshooting

| Symptom | Fix |
|---|---|
| `start.bat` says **".env.local not found"** | Do §4. |
| `/api/sync/status` shows `service_role_key_loaded: false` | The key is missing or `start.bat` was bypassed. Re-run `scripts\start.bat`. |
| Sync Pull returns 0 rows | Service-role key not loaded — same fix as above. |
| App crashes after Lovable made changes; toggle disappeared | Lovable regenerated `src/integrations/supabase/client.ts`. Restore: `git checkout origin/v5 -- src/integrations/supabase/client.ts` then `scripts\start.bat`. |
| `daily_backup.bat` exits with `ERROR: E:\landco_daily_backup not found` | USB drive not plugged in. |
| Forgot local password | `curl -X POST http://localhost:4000/auth/repair-users` |
| Need to start fresh | `scripts\stop.bat` then `docker volume rm lanacc-pgdata-volume` (⚠ deletes all local data — restore from a backup after). |

---

## 12. Production-readiness checklist

Before declaring this PC "live":

- [ ] `.env.local` exists with **all five** real secrets, none left as `CHANGE_ME_*`.
- [ ] `.env.local` is **not** in `git status` (it's gitignored).
- [ ] `scripts\start.bat` boots cleanly; `/api/sync/status` shows `push_enabled:true`.
- [ ] Sync → Pull works (rows > 0).
- [ ] Sync → Push works (no errors).
- [ ] `scripts\install_scheduled_task.bat` was run as Administrator.
- [ ] `schtasks /Run /TN "LANACC Daily Backup"` produces a fresh `.sql`
      in `E:\landco_daily_backup\` ≥ 100 KB.
- [ ] You have tested **§8 restore** at least once in a throwaway
      environment.
- [ ] The Lexar USB drive is left plugged in 24/7.

When all twelve boxes are checked, the system is safe to use with
company data for single-user production.
