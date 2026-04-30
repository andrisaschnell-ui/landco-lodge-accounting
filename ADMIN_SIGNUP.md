# Admin Users — Complete Guide

This document is the **single source of truth** for creating, promoting, resetting, and managing **admin users** for LANACC. It covers both deployment modes:

- **Cloud mode** — Lovable Cloud (Supabase) backend.
- **Local mode** — On-premise Docker stack (Postgres + Node API + Nginx) on each company's PC.

> Admin access is required to use the **Settings** page (the gear icon at the bottom of the left sidebar). Users without an `admin` role see a blank/inactive Settings screen.

---

## 1. How admin access works

LANACC has two roles, stored in the `public.user_roles` table (separate from `auth.users` for security):

| Role | What they can do |
|------|------------------|
| `admin` | Full read/write access to every page, including Settings, Properties, Shareholders, Backup, Sync, Account Mapping, Chart of Accounts, Invoices, etc. |
| `viewer` | Read-only access to all data pages. Settings is hidden / inactive. |

Role checks happen via the security-definer SQL function `public.has_role(user_id, role)`, which is referenced by every RLS policy. Roles are NEVER stored on `profiles` or in the JWT — this prevents privilege-escalation attacks.

The Settings button only "lights up" once the currently signed-in user has an `admin` row in `user_roles`.

---

## 2. The shared Admin PIN

All "create an admin" flows are gated by a shared secret PIN:

- **Default value**: `Abcd7654$#`
- **Cloud storage**: secret named `ADMIN_SIGNUP_PIN` (Lovable Cloud → Secrets).
- **Local storage**: variable `ADMIN_SIGNUP_PIN` inside each PC's `.env.local`, propagated into the `lanacc-api` container via `docker-compose.yml`.

> **Keep both values identical** so the same PIN works on every machine and on the cloud copy. Rotate by updating BOTH the cloud secret AND every machine's `.env.local`, then restart the local stacks.

The PIN is **never shipped to the browser**. The frontend posts it to the backend (Edge Function in cloud, Express endpoint in local), where it is compared to the env variable before any user is created.

---

## 3. Five ways to create / promote an admin

| # | Method | Mode | Use when |
|---|--------|------|----------|
| 1 | **In-app Admin Sign Up** with PIN | Cloud + Local | Default, easiest. New machine, new staff member, new cloud user. |
| 2 | **`make-admin` script** | Local only | A machine has no admin and no one can log in. Headless servers. |
| 3 | **`reset_admin_users` script** | Local only | The two built-in owner accounts need to be re-created from scratch. |
| 4 | **Promote existing user via SQL** | Local only | A user already exists but lacks the `admin` role. |
| 5 | **Promote existing user via Cloud UI** | Cloud only | Someone signed up normally and you want to elevate them. |

Each is detailed below.

---

### Method 1 — In-app Admin Sign Up (recommended)

Works in both Cloud and Local mode. No shell access needed.

1. Open the login page: `http://localhost:8080/auth` (local) or your cloud URL.
2. Use the **Cloud / Local** toggle (top-right) to pick the target backend.
3. Click **"Admin Sign Up"** at the bottom of the form.
4. Fill in:
   - Email
   - Password (≥ 8 characters)
   - **Admin PIN** = `Abcd7654$#`
5. Click **Create Admin Account**.

What happens behind the scenes:

- **Cloud**: the form calls the `signup-admin` Edge Function. It validates the PIN against `ADMIN_SIGNUP_PIN`, then uses the service role to call `admin.createUser({ email_confirm: true })` and inserts `{ user_id, role: 'admin' }` into `user_roles`. The user is auto-confirmed and signed in immediately.
- **Local**: the form POSTs to `http://localhost:4000/auth/signup-admin` on the `lanacc-api` container. The endpoint validates the PIN, then UPSERTs the user into `auth.users` (bcrypt-hashed password) and ensures an `admin` row exists in `public.user_roles`. Idempotent — safe to call again to reset the password of an existing email.

Failure messages and meaning:

| Error | Cause |
|-------|-------|
| `invalid admin PIN` | The PIN typed doesn't match the env var. |
| `Edge Function returned 500` (cloud) | `ADMIN_SIGNUP_PIN` secret not set in cloud, OR the function can't reach the service role. Check Lovable Cloud → Secrets. |
| `Failed to fetch` (local) | The `lanacc-api` container isn't running. Start it: `docker compose --env-file .env.local up -d`. |

---

### Method 2 — `make-admin` standalone script (local mode)

Use this when **nobody** can log into a particular PC. Runs against the local Docker stack.

**Windows:**
```bat
scripts\make-admin.bat
```

**Mac / Linux:**
```bash
chmod +x scripts/make-admin.sh
./scripts/make-admin.sh
```

The script prompts for email, password, and the PIN, then POSTs to the running `lanacc-api` container's `/auth/signup-admin` endpoint. Same backend logic as Method 1.

Requirements:
- Docker stack must be **running** (`docker compose ps` should show `lanacc-api` healthy).
- `.env.local` must contain `ADMIN_SIGNUP_PIN`.

This script does **not** work for cloud accounts — it doesn't ship the cloud service-role key. Use Method 1 for cloud.

---

### Method 3 — `reset_admin_users` script (local mode)

Re-creates the two hard-coded owner admins from a clean state:

- `cwschnell@gmail.com`
- `andrisa.schnell@gmail.com`

**Windows:**
```bat
scripts\reset_admin_users.bat
```

**Mac / Linux:**
```bash
./scripts/reset_admin_users.sh
```

What it does:
1. Deletes any existing rows for those two emails in `auth.users` and `user_roles`.
2. Re-inserts them with a default password (printed by the script) and the `admin` role.

Use this only as a recovery measure for the two built-in owner accounts. For everyone else use Methods 1, 2, or 4.

---

### Method 4 — Promote an existing user via SQL (local mode)

Use when a user already signed up (perhaps as `viewer`) and you want to elevate them.

```bash
docker exec -it lanacc-db psql -U postgres -d lanacc
```

Then in psql:

```sql
-- Find the user
SELECT id, email FROM auth.users WHERE email = 'someone@example.com';

-- Grant admin (idempotent)
INSERT INTO public.user_roles (user_id, role)
SELECT id, 'admin'::app_role FROM auth.users WHERE email = 'someone@example.com'
ON CONFLICT (user_id, role) DO NOTHING;
```

To **revoke** admin:

```sql
DELETE FROM public.user_roles
 WHERE role = 'admin'
   AND user_id = (SELECT id FROM auth.users WHERE email = 'someone@example.com');
```

The user must sign out and back in for the new role to take effect (the frontend caches role at session start).

---

### Method 5 — Promote an existing cloud user

For users who already exist in the Cloud backend (e.g. they signed up normally):

1. In the app, sign in as an existing admin.
2. Go to **Settings → Users** (if the screen is built; if not, use the SQL approach below via the Cloud "Read database" tool).
3. Find the user and click **Make Admin**.

Or directly via SQL on the cloud database (admin only, via the Cloud SQL editor):

```sql
INSERT INTO public.user_roles (user_id, role)
SELECT id, 'admin' FROM auth.users WHERE email = 'someone@example.com'
ON CONFLICT (user_id, role) DO NOTHING;
```

---

## 4. Setup checklist for a brand-new machine

1. Copy `.env.example` to `.env.local` and set:
   ```env
   ADMIN_SIGNUP_PIN=Abcd7654$#
   POSTGRES_PASSWORD=<strong-password>
   JWT_SECRET=<random-64-char-string>
   ```
2. Build & start the stack:
   ```bat
   docker compose --env-file .env.local up -d --build
   ```
3. Wait until `docker compose ps` shows `lanacc-db`, `lanacc-api`, `lanacc-web` all healthy.
4. Open `http://localhost:8080/auth`, switch the toggle to **Local**, click **Admin Sign Up**, type the PIN.
5. You're in — Settings is now active.

For the cloud copy (one-time per new company):
1. In Lovable Cloud → Secrets, confirm `ADMIN_SIGNUP_PIN` is set.
2. Open the cloud URL, switch to **Cloud** mode, click **Admin Sign Up**, type the PIN.

---

## 5. Rotating the PIN

When you want to change the shared secret:

1. **Cloud**: Update the `ADMIN_SIGNUP_PIN` secret in Lovable Cloud → Secrets. (No redeploy needed — Edge Functions read it on each invocation.)
2. **Every local PC**:
   - Edit `.env.local`, change the line `ADMIN_SIGNUP_PIN=...`.
   - Restart: `docker compose --env-file .env.local up -d` (rebuild not required; compose picks up the env).
3. Notify whoever needs the new PIN — old one stops working immediately.

---

## 6. Security notes

- The PIN never travels to the browser. Validation is server-side only.
- `.env.local` is in `.gitignore` — never commit it.
- Roles live in their own table with RLS. A compromised browser session cannot escalate itself to admin without the PIN AND the backend approving.
- Auto-confirm email is enabled **only** on the admin-signup path, so admins can log in immediately. Regular signups (if you ever enable them) still require email verification.
- For production hardening you can: rotate the PIN on a schedule, restrict the local API to `127.0.0.1` only, and put the cloud Edge Function behind an additional CAPTCHA.

---

## 7. Troubleshooting

| Symptom | Fix |
|---------|-----|
| Settings button stays inactive after signup | Confirm `user_roles` row exists for your user (`SELECT * FROM user_roles WHERE user_id = ...`). Sign out / in. |
| "invalid admin PIN" but you typed it correctly | The env var on the backend is different. Check `docker exec lanacc-api env \| grep ADMIN_SIGNUP_PIN` (local) or the Cloud secret value. |
| Cloud signup works but local doesn't | `lanacc-api` container missing `ADMIN_SIGNUP_PIN`. Stop, ensure `.env.local` has it, `docker compose --env-file .env.local up -d`. |
| Local signup works but cloud doesn't | Cloud secret missing or Edge Function not deployed. Check Lovable Cloud → Functions → `signup-admin` logs. |
| You forgot the PIN entirely | An existing admin can rotate it (see §5). If no admin exists anywhere, use Method 4 (SQL) to grant yourself admin, then set a new PIN. |
