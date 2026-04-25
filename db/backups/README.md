# Local Backup Folder

This folder is bind-mounted into the API container at `/app/backups` (see
`docker-compose.yml`). Backups created via the **Database Backup** page are
written here:

- `landco/`    — Landco accounting data (journal, invoices, payroll, …)
- `cash/`      — Cash Control sheets and transactions
- `complete/`  — Full database dump (entire `public` schema)

Filenames look like: `landco_2026-04-25_1042_my-note.sql`

USB targets, when a drive is plugged in and uncommented in
`docker-compose.yml`, write to `<drive>:\Lanco Backup\<scope>\` instead.

## Important

The Database Backup page **only works when you run the app locally via
Docker** (the API container at `http://localhost:4000` is what creates the
SQL dumps). It does **not** work in the Lovable cloud preview — there is no
Docker, no `pg_dump`, and no USB drives there.
