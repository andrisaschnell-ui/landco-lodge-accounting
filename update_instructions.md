# LANACC — Local Update Instructions

**Audience:** an automated agent (e.g. Antigravity / Lovable harness) **or** a human running an update on the office PC.

**Goal:** pull the latest `v5` code from GitHub, apply any new database migrations, rebuild the Docker stack, and verify the local app works — without losing data.

---

## TL;DR for the agent

> Run **one** of these from the project root, then read the resulting `update_local.log`:
>
> - **Windows:** `scripts\update_local.bat`
> - **Mac/Linux:** `bash scripts/update_local.sh`
>
> If the log ends with `UPDATE SUCCESSFUL`, open <http://localhost:8080> and report success.
> If it ends with `UPDATE COMPLETED WITH WARNINGS`, paste the failing lines back to the user and **do not** delete the `db/backups/pre_update_*.sql` snapshot.

---

## What the script does (in order)

| # | Step | Why it matters |
|---|---|---|
| 1 | **Pre-update backup** — `pg_dump` of `landco_v2_db` to `db/backups/pre_update_<timestamp>.sql` | Lets you roll back if the new code breaks something. |
| 2 | **`git fetch` + `git checkout v5` + `git pull --ff-only origin v5`** | v5 is the only supported branch. Fast-forward only — refuses to merge if there are uncommitted local changes. |
| 3 | **Diff old→new commit for new SQL files** under `supabase/migrations/` and `db/migrations/` | Only runs migrations that are actually new — safe to re-run the script. |
| 4 | **`docker compose --env-file .env.local up -d --build`** | Rebuilds the `web`, `api`, and `db` images and recreates containers. Existing Postgres data volume (`lanacc-pgdata-volume`) is preserved. |
| 5 | **Wait until Postgres accepts connections** (up to 60 s) | Prevents migrations from running against a half-booted DB. |
| 6 | **Apply each new migration** with `psql -v ON_ERROR_STOP=1` | Migrations should already be idempotent (`CREATE … IF NOT EXISTS`), so re-runs are harmless. |
| 7 | **Smoke test** four endpoints: `api/health`, `api/sync/status`, web on `:8080`, and a DB query | Confirms the stack is genuinely healthy before declaring success. |

A combined transcript is written to **`update_local.log`** in the project root.

---

## Pre-conditions (must be true before running)

- Docker Desktop is **running**.
- `git` and `docker` are on `PATH`.
- `.env.local` exists in the project root with all five secrets filled in (see `INSTALL.md` §4).
- No uncommitted local edits to tracked files. If the agent finds any, it should:
  1. `git status` — show them to the user, **or**
  2. `git stash push -u -m "pre-update"` — and warn the user.
  Do **not** force-discard the user's work.

---

## Agent recipe (copy/paste prompt)

> "Pull the latest code from branch `v5`, run `scripts\update_local.bat` (or `bash scripts/update_local.sh` on Mac/Linux), then read `update_local.log`. If the last line says `UPDATE SUCCESSFUL`, confirm the app is live at <http://localhost:8080>. Otherwise, report the failing step and the path of the backup file under `db/backups/pre_update_*.sql` so I can roll back."

---

## Manual fallback (if the script can't run)

```bat
REM 1. Backup
docker exec lanacc-db pg_dump -U postgres -d landco_v2_db --clean --if-exists > db\backups\manual_backup.sql

REM 2. Pull
git fetch origin && git checkout v5 && git pull --ff-only origin v5

REM 3. Rebuild
docker compose --env-file .env.local up -d --build

REM 4. Apply any NEW migrations manually, e.g.:
docker exec -i lanacc-db psql -U postgres -d landco_v2_db -v ON_ERROR_STOP=1 < supabase\migrations\<new_file>.sql

REM 5. Verify
curl http://localhost:4000/health
curl http://localhost:4000/api/sync/status
start http://localhost:8080
```

---

## Rollback

If the new version misbehaves:

```bat
scripts\stop.bat
scripts\restore.bat db\backups\pre_update_<timestamp>.sql
git checkout <OLD_SHA>          REM printed in update_local.log
scripts\start.bat
```

---

## Common failure modes

| Symptom in `update_local.log` | Cause | Fix |
|---|---|---|
| `git checkout v5 failed - commit/stash local changes first` | Uncommitted edits | `git status`, then commit or stash |
| `git pull not fast-forward` | Local commits diverged from v5 | Resolve manually with `git rebase origin/v5` |
| `docker compose build failed` | Missing var in `.env.local`, or Dockerfile error | Inspect tail of log; usually a missing secret |
| `Postgres not ready in 60s` | DB volume corruption or port 5432 taken | `docker logs lanacc-db` |
| `[FAIL] API /api/sync/status` | API container crashed on boot | `docker logs lanacc-api` |
| `[WARN] <migration>.sql failed/already applied` | Non-idempotent migration | Inspect migration; usually safe to ignore if objects already exist |

---

## Why a single script (not ad-hoc commands)

- **Reproducible** — the same 7 steps every time, regardless of who/what runs them.
- **Safe** — always takes a backup first; uses `--ff-only` so it can never silently merge.
- **Auditable** — every action is appended to `update_local.log`.
- **Agent-friendly** — one command, one log file, one success/failure line at the bottom.
