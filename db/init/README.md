# Database Init Scripts

Postgres runs every `*.sql` file in this folder **alphabetically**, but **only on first boot** (when the `lanacc-pgdata-volume` is empty).

Current layout — produces a fully-loaded database from scratch:

| # | File | Purpose |
|---|------|---------|
| 1 | `00_extensions.sql` | Enables `pgcrypto` and `uuid-ossp` |
| 2 | `01_schema_full.sql` | Drops & recreates the entire `public` schema (30 tables, types, helpers, mock `auth.users`) |
| 3 | `02_data_snapshot.sql` | Truncates and re-inserts all 2,456 rows of real data |

## Fresh rebuild from zero

```powershell
docker compose down -v        # -v wipes the DB volume so init scripts run again
docker compose up -d --build
docker logs -f lanacc-db      # wait for "database system is ready to accept connections"
docker logs -f lanacc-api     # should show "LANACC API listening on :4000"
```

That's it — no pgAdmin steps required.

## Rebuild WITHOUT wiping data

```powershell
docker compose up -d --build
```

The init scripts are **skipped** because the volume already exists. Use this after code-only changes.
