# New Company Setup

The app supports running multiple isolated company instances on the same machine, each with its own folder, Docker container set, and database.

## Quick start (Windows)

```cmd
cd C:\Lovable\Landco
scripts\clone-company.bat
```

You'll be prompted for:
- **Source folder** — usually this Landco install
- **Destination folder** — e.g. `C:\Lovable\EbonyBeach`
- **Company short name** — lowercase, no spaces, e.g. `ebony`
- **Ports** — web (default 8081), API (4001), DB (5433)

The script:
1. Copies the project (skipping `node_modules`, `.git`, `dist`)
2. Writes `.env.local` with new DB name/user/password and port mapping
3. Writes `docker-compose.override.yml` with unique container names + a unique named volume so the new DB is fully isolated

## After clone

```cmd
cd C:\Lovable\EbonyBeach
notepad .env.local        REM set POSTGRES_PASSWORD
docker compose --env-file .env.local up -d --build
```

Open `http://localhost:<WEB_PORT>`, sign in, then go to **Settings** in the sidebar (admin only) to set:
- **Identity** — company name, NUIT, address, logo (replaces "Landco Lda" everywhere)
- **Financial** — currency, VAT, invoice prefix, fiscal year start
- **Branding** — primary/accent colors (HSL, persists for everyone)
- **Operational** — backup folder, sync target, default property/shareholder

## Notes

- The new company starts with the **same schema** as Landco but **empty data** (the database is a fresh volume).
- Each instance has its own backup schedule — adjust the Windows scheduled task or `scripts/daily_backup.bat` per folder.
- Cloud sync (Lovable Cloud) is per-instance. If you want each company to sync to its own Cloud project, configure the sync target ref under Settings → Operational.
