# Loading Data into the Local PostgreSQL Container

The file **`09_data_snapshot.sql`** contains a full data backup from the cloud
(2,456 INSERT rows across 30 tables).

## How initialization works

Anything in `db/init/` is run **only the first time** the Postgres container is
created (i.e. when the `lanacc-pgdata-volume` does not yet exist). If you
already started Postgres once with an empty volume, the new SQL files will
**not** be picked up automatically — see Option B below.

---

## Option A — Fresh install (recommended)

This wipes the local DB volume and reseeds everything in order:
schema → admins → accounting → chart of accounts → invoices → cash control → **data snapshot**.

```powershell
docker compose down -v
docker compose up -d --build
```

Wait ~15 seconds, then verify:

```powershell
docker exec -it lanacc-db psql -U postgres -d landco_v2_db -c "SELECT count(*) FROM public.cash_transactions;"
```

You should see **171** rows.

---

## Option B — Load data into an already-running container

If you don't want to wipe your DB, load the snapshot manually:

### Windows PowerShell
```powershell
Get-Content db\init\09_data_snapshot.sql | docker exec -i lanacc-db psql -U postgres -d landco_v2_db
```

### Windows cmd.exe
```cmd
type db\init\09_data_snapshot.sql | docker exec -i lanacc-db psql -U postgres -d landco_v2_db
```

### Linux / macOS
```bash
docker exec -i lanacc-db psql -U postgres -d landco_v2_db < db/init/09_data_snapshot.sql
```

The script is idempotent — it `TRUNCATE`s each table before re-inserting, so it
is safe to run repeatedly.

---

## Verify

```powershell
docker exec -it lanacc-db psql -U postgres -d landco_v2_db -c "
SELECT 'accounts'             AS tbl, count(*) FROM public.accounts UNION ALL
SELECT 'journal_entries'      , count(*) FROM public.journal_entries UNION ALL
SELECT 'journal_lines'        , count(*) FROM public.journal_lines UNION ALL
SELECT 'income_transactions'  , count(*) FROM public.income_transactions UNION ALL
SELECT 'expense_transactions' , count(*) FROM public.expense_transactions UNION ALL
SELECT 'invoices'             , count(*) FROM public.invoices UNION ALL
SELECT 'cash_transactions'    , count(*) FROM public.cash_transactions;
"
```

Expected:
| table                  | count |
|------------------------|------:|
| accounts               |    46 |
| journal_entries        |   340 |
| journal_lines          |   842 |
| income_transactions    |   100 |
| expense_transactions   |   167 |
| invoices               |   103 |
| cash_transactions      |   171 |

---

## Troubleshooting

**"No data on screens"** — The web app is talking to the local API but the DB is
empty. Run Option A or Option B above.

**"relation does not exist"** — The schema hasn't been created. Make sure all
files `00_extensions.sql` … `08_cash_control.sql` ran successfully on first
start. Check with:
```powershell
docker logs lanacc-db | Select-String "init"
```

**Cloud → local secrets to know about**
- `.env` is **not** used by the local Docker stack. The cloud `.env` points at
  Supabase; locally, the API container reads its config from `docker-compose.yml`
  (`DATABASE_URL`, `JWT_SECRET`, etc.).
- The web container reads `VITE_API_URL=http://localhost:4000` from
  `docker-compose.yml`. If you change the API port, change it there too.
- The Supabase client in `src/integrations/supabase/client.ts` is replaced at
  container start by the local shim in `patches/client.local.ts` so the React
  app talks to the Express API instead of the cloud.
