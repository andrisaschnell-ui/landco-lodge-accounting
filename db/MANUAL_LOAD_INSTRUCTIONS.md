# Manual Schema + Data Load via pgAdmin

Use this when you want to rebuild the local database **by hand** using the
pgAdmin web UI at <http://localhost:5050> instead of letting Docker run the
init scripts.

You only need **two files** from the repo:

1. `db/SCHEMA_FULL.sql` — creates every table, type, sequence and helper.
2. `db/init/09_data_snapshot.sql` — 2,456 INSERTs of real data.

---

## Step 1 — Open pgAdmin

1. Make sure Docker is running: `docker compose up -d`
2. Open <http://localhost:5050>
3. Login: **admin@landco.com / root**

### First time only — register the DB server

Right-click **Servers → Register → Server…**

- **General tab → Name:** `lanacc-local`
- **Connection tab:**
  - Host name/address: `db`  *(the docker service name, NOT `localhost`)*
  - Port: `5432`
  - Maintenance database: `landco_v2_db`
  - Username: `postgres`
  - Password: `root`  (tick *Save password*)

Click **Save**. You should now see `landco_v2_db` under
`Servers → lanacc-local → Databases`.

---

## Step 2 — Load the schema

1. In the left tree, click **landco_v2_db** to select it.
2. Top menu → **Tools → Query Tool** (or press `Alt+Shift+Q`).
3. In the Query Tool toolbar click the **folder icon (Open File)** and pick
   `db/SCHEMA_FULL.sql` from your local repo.
4. Press **F5** (or click the ▶ Execute button).

The script first **drops the entire `public` schema** and rebuilds it, so it is
safe to re-run. You should see:

```
Query returned successfully in <1 sec.
```

Verify by running:
```sql
SELECT count(*) FROM information_schema.tables
WHERE table_schema = 'public';
```
You should get **30**.

---

## Step 3 — Load the data

1. Still in Query Tool (same DB selected), open
   `db/init/09_data_snapshot.sql`.
2. Press **F5**.

The script:
- Sets `session_replication_role = replica` (disables FK checks for the load)
- `TRUNCATE`s each table
- Re-inserts every row
- `COMMIT`s in a single transaction

Expected runtime: ~2 seconds.

### Verify

Open a new Query Tool tab and run:

```sql
SELECT 'accounts'             AS tbl, count(*) FROM public.accounts UNION ALL
SELECT 'journal_entries'      , count(*) FROM public.journal_entries UNION ALL
SELECT 'journal_lines'        , count(*) FROM public.journal_lines UNION ALL
SELECT 'income_transactions'  , count(*) FROM public.income_transactions UNION ALL
SELECT 'expense_transactions' , count(*) FROM public.expense_transactions UNION ALL
SELECT 'invoices'             , count(*) FROM public.invoices UNION ALL
SELECT 'cash_transactions'    , count(*) FROM public.cash_transactions;
```

Expected:

| table                | count |
|----------------------|------:|
| accounts             |    46 |
| journal_entries      |   340 |
| journal_lines        |   842 |
| income_transactions  |   100 |
| expense_transactions |   167 |
| invoices             |   103 |
| cash_transactions    |   171 |

---

## Step 4 — Restart the API container (clears connection cache)

```powershell
docker restart lanacc-api
```

Open <http://localhost:8080>, log in, and the screens should now show data.

---

## Troubleshooting

**`permission denied for schema public`** — Make sure you logged into pgAdmin
as `postgres` (not `admin`). The schema-drop step needs superuser rights.

**`relation "auth.users" does not exist`** — You skipped the schema script.
Re-run `db/SCHEMA_FULL.sql` first.

**Query Tool can't see the file** — pgAdmin's Open File dialog browses the
**pgAdmin container's filesystem**, not your PC. Two workarounds:
- Easier: open the .sql file in Notepad / VS Code, copy ALL the text, paste
  into the Query Tool, press F5.
- Or mount the repo into pgAdmin (advanced — edit `docker-compose.yml`).

**Data loaded but app still empty** — Restart the API: `docker restart lanacc-api`.
