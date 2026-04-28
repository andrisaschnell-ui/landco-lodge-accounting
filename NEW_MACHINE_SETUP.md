# Setting up Landco Lodge Accounting on a NEW computer

You only need to do this once per machine.

## Prerequisites
- Git installed
- Docker Desktop installed and **running**
- Your Supabase **service-role key** (Lovable → Cloud → Backend → API keys → `service_role`).
  Skip this only if you will never push local changes to the cloud from this machine.

## Steps

```bash
git clone <repo-url> landco
cd landco
git checkout v5
```

### Windows
```powershell
scripts\setup_new_machine.bat
```

### Mac / Linux
```bash
chmod +x scripts/*.sh
./scripts/setup_new_machine.sh
```

The script will:
1. Prompt you for the service-role key and write it to `.env.local` (gitignored).
2. `docker compose up -d --build`.
3. Wait for the database.
4. Create/reset both admin users so you can log in immediately.

When it finishes, open **http://localhost:8080** and log in as:
- `cwschnell@gmail.com` / `Abcd7654$`
- `andrisa.schnell@gmail.com` / `Abcd7654#`

## Re-running pieces later
| Need | Command |
|------|---------|
| Reset admin passwords | `scripts/reset_admin_users.bat` (or `.sh`) |
| Back up local DB | `scripts/backup.bat` |
| Restore local DB | `scripts/restore.bat <file>` |
| Switch local ↔ cloud | Toggle on the login page or in the header |
