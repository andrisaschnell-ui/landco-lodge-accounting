# Granting Admin Access — Three Methods

The application gates admin creation behind a shared **PIN**. Anyone who knows the PIN can create an admin user, in either Cloud or Local mode.

- **Cloud PIN**: stored as the `ADMIN_SIGNUP_PIN` secret (Lovable Cloud → Secrets).
- **Local PIN**: stored as `ADMIN_SIGNUP_PIN` in each machine's `.env.local`.

Keep the two values **identical** so the same PIN works everywhere. Rotate by updating both.

---

## Method 1 — In-app Admin Sign Up (recommended)

1. Open the login page at `http://localhost:8080/auth` (local) or your cloud URL.
2. Pick the mode (**Cloud** or **Local**) using the toggle.
3. Click **Admin Sign Up** at the bottom.
4. Enter email, password (≥ 8 chars), and the **Admin PIN**.
5. On success, the new account is created with admin privileges and you're signed in.

Works in both modes. No shell access needed.

---

## Method 2 — Standalone script (local mode only)

Use this when no one can log into a particular machine.

### Windows
```bat
scripts\make-admin.bat
```

### Mac / Linux
```bash
chmod +x scripts/make-admin.sh
./scripts/make-admin.sh
```

The script:
- Posts to the running `lanacc-api` container's `/auth/signup-admin` endpoint.
- Validates the PIN against `ADMIN_SIGNUP_PIN` from `.env.local`.
- Creates or updates the user in `auth.users` (bcrypt-hashed password) and grants `admin` in `public.user_roles`.

For **cloud** accounts, use Method 1 instead — the standalone script doesn't ship the cloud service-role key.

---

## Method 3 — Reset the two built-in admins

Already documented in `NEW_MACHINE_SETUP.md`:

```bat
scripts\reset_admin_users.bat       :: Windows
./scripts/reset_admin_users.sh      # Mac / Linux
```

Use this only for the two hard-coded admins (`cwschnell@gmail.com`, `andrisa.schnell@gmail.com`).

---

## Setup checklist for a new machine

1. `.env.local` contains `ADMIN_SIGNUP_PIN=<your PIN>` (copy from `.env.example`).
2. `docker compose --env-file .env.local up -d --build`.
3. Open the app, choose **Local**, click **Admin Sign Up**, enter the PIN.

For cloud:
1. In the cloud project, confirm the `ADMIN_SIGNUP_PIN` secret is set to the same value.
2. Open the app, choose **Cloud**, click **Admin Sign Up**.

---

## Security notes

- The PIN is **never** shipped to the browser. The frontend sends it to the backend (edge function in cloud, Express endpoint in local), which compares it to its environment variable.
- Keep `.env.local` out of git (already in `.gitignore`).
- Rotate the PIN by updating the cloud secret and every machine's `.env.local`, then restart containers locally (`docker compose --env-file .env.local up -d`).
