// LANACC local API: auth (login) + generic CRUD over whitelisted tables.
// Replaces Supabase for the on-premise Docker deployment.

import express from "express";
import cors from "cors";
import pkg from "pg";
import bcrypt from "bcryptjs";
import jwt from "jsonwebtoken";

// Route imports
import journalRoutes from './routes/journal.js';
import invoiceRoutes from './routes/invoices.js';
import reportRoutes from './routes/reports.js';
import cashControlRoutes from './routes/cash_control.js';
import backupRoutes from './routes/backup.js';
import syncRoutes from './routes/sync.js';
import { POSTERS, linkSourceToEntry } from './lib/autoPost.js';

const { Pool } = pkg;
const pool = new Pool({ connectionString: process.env.DATABASE_URL });
const JWT = process.env.JWT_SECRET || "dev-secret";

const app = express();
app.use(cors());
app.use(express.json({ limit: "20mb" }));

// ---------- helpers ----------
const TABLES = new Set([
  "properties","shareholders","bank_accounts","expense_categories",
  "employees","exchange_rates","income_transactions","expense_transactions",
  "bank_transactions","petty_cash_transactions","salary_runs","salary_lines",
  "salary_advances","bim_salary_transfers","inss_payments","irps_payments",
  "shareholder_balances","import_log","profiles","user_roles",
  // Accounting Upgrade Tables
  "accounts", "accounting_periods",
  // Cash Control (isolated notebook)
  "cash_sheets","cash_transactions","cash_dropdown_options","cash_allocation_columns",
  // Release 2
  "budgets",
  // Release 4: assets, inventory, banking, fx, attachments, audit
  "fixed_assets","depreciation_schedule",
  "inventory_items","inventory_movements",
  "bank_reconciliations","fx_revaluations",
  "document_attachments","audit_log",
]);

function requireAuth(req, res, next) {
  const h = req.headers.authorization || "";
  const token = h.startsWith("Bearer ") ? h.slice(7) : null;
  if (!token) return res.status(401).json({ error: "missing token" });
  try { req.user = jwt.verify(token, JWT); next(); }
  catch { return res.status(401).json({ error: "invalid token" }); }
}

// Auto-journal helpers live in api/lib/autoPost.js (shared with backfill script).

// ---------- auth ----------
app.post("/auth/login", async (req, res) => {
  const { email, password } = req.body || {};
  if (!email || !password) return res.status(400).json({ error: "email/password required" });
  const { rows } = await pool.query("SELECT id,email,password_hash,display_name FROM auth.users WHERE email=$1",[email]);
  const u = rows[0];
  if (!u || !bcrypt.compareSync(password, u.password_hash))
    return res.status(401).json({ error: "invalid credentials" });
  const { rows: rr } = await pool.query("SELECT role FROM public.user_roles WHERE user_id=$1",[u.id]);
  const roles = rr.map(r => r.role);
  const token = jwt.sign({ sub: u.id, email: u.email, roles }, JWT, { expiresIn: "12h" });
  res.json({ token, user: { id: u.id, email: u.email, display_name: u.display_name, roles } });
});

app.get("/auth/me", requireAuth, (req, res) => res.json({ user: req.user }));

// ---------- PIN-gated admin signup ----------
// Anyone who knows ADMIN_SIGNUP_PIN can create a new admin user on this
// local instance. Creates the row in auth.users (bcrypt hash) and grants
// 'admin' in public.user_roles. Idempotent: if the email already exists,
// the password is updated and the admin role is granted.
app.post("/auth/signup-admin", async (req, res) => {
  const PIN = process.env.ADMIN_SIGNUP_PIN;
  if (!PIN) return res.status(500).json({ error: "ADMIN_SIGNUP_PIN not configured on server" });

  const { email, password, pin, display_name } = req.body || {};
  if (!email || !password) return res.status(400).json({ error: "email and password required" });
  if (String(password).length < 8) return res.status(400).json({ error: "password must be at least 8 characters" });
  if (pin !== PIN) return res.status(403).json({ error: "invalid admin PIN" });

  const client = await pool.connect();
  try {
    await client.query("BEGIN");
    await client.query("CREATE SCHEMA IF NOT EXISTS auth");
    await client.query(`
      CREATE TABLE IF NOT EXISTS auth.users (
        id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
        email text UNIQUE NOT NULL,
        password_hash text NOT NULL,
        display_name text,
        created_at timestamptz DEFAULT now()
      )`);

    const hash = bcrypt.hashSync(String(password), 10);
    const lowered = String(email).trim().toLowerCase();

    const { rows } = await client.query(
      `INSERT INTO auth.users (email, password_hash, display_name)
       VALUES ($1, $2, $3)
       ON CONFLICT (email) DO UPDATE SET password_hash = EXCLUDED.password_hash
       RETURNING id, email`,
      [lowered, hash, display_name || lowered]
    );
    const userId = rows[0].id;

    await client.query(
      `INSERT INTO public.user_roles (user_id, role)
       VALUES ($1, 'admin'::app_role)
       ON CONFLICT (user_id, role) DO NOTHING`,
      [userId]
    );

    await client.query("COMMIT");
    res.json({ ok: true, user_id: userId, email: lowered });
  } catch (e) {
    await client.query("ROLLBACK");
    res.status(500).json({ error: e.message });
  } finally {
    client.release();
  }
});

// ---------- repair users (recreates the two admin accounts) ----------
// Public endpoint by design: lets you log back in when credentials are lost.
// Protected only by knowing the two fixed admin emails (it never changes any
// other accounts). Hashes are generated fresh each call.
const REPAIR_USERS = [
  { email: "cwschnell@gmail.com",       password: "Abcd7654$", display_name: "CW Schnell" },
  { email: "andrisa.schnell@gmail.com", password: "Abcd7654#", display_name: "Andrisa Schnell" },
];

app.post("/auth/repair-users", async (_req, res) => {
  const client = await pool.connect();
  try {
    await client.query("BEGIN");
    await client.query("CREATE SCHEMA IF NOT EXISTS auth");
    await client.query(`
      CREATE TABLE IF NOT EXISTS auth.users (
        id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
        email text UNIQUE NOT NULL,
        password_hash text NOT NULL,
        display_name text,
        created_at timestamptz DEFAULT now()
      )`);

    const results = [];
    for (const u of REPAIR_USERS) {
      const hash = bcrypt.hashSync(u.password, 10);
      const { rows } = await client.query(
        `INSERT INTO auth.users (email, password_hash, display_name)
         VALUES ($1,$2,$3)
         ON CONFLICT (email) DO UPDATE SET password_hash = EXCLUDED.password_hash
         RETURNING id, email`,
        [u.email, hash, u.display_name]
      );
      const userId = rows[0].id;
      await client.query(
        `INSERT INTO public.user_roles (user_id, role)
         VALUES ($1, 'admin'::app_role)
         ON CONFLICT (user_id, role) DO NOTHING`,
        [userId]
      );
      results.push({ email: rows[0].email, id: userId, role: "admin" });
    }
    await client.query("COMMIT");
    res.json({ ok: true, repaired: results });
  } catch (e) {
    await client.query("ROLLBACK");
    res.status(500).json({ error: e.message });
  } finally {
    client.release();
  }
});

// ---------- modular routes ----------
app.use('/api/journal', journalRoutes(pool, TABLES, requireAuth));
app.use('/api/invoices', invoiceRoutes(pool, TABLES, requireAuth));
app.use('/api/reports', reportRoutes(pool, requireAuth));
app.use('/api/cash-control', cashControlRoutes(pool, requireAuth));
app.use('/api/backup', backupRoutes(requireAuth));
app.use('/api/sync', syncRoutes(pool, requireAuth));

// ---------- generic table API ----------
app.get("/api/:table", requireAuth, async (req, res) => {
  const t = req.params.table;
  if (!TABLES.has(t)) return res.status(404).json({ error: "unknown table" });
  const limit = Math.min(parseInt(req.query.limit) || 1000, 5000);
  try {
    const { rows } = await pool.query(`SELECT * FROM public.${t} LIMIT $1`,[limit]);
    res.json(rows);
  } catch (e) { res.status(500).json({ error: e.message }); }
});

app.post("/api/:table", requireAuth, async (req, res) => {
  const t = req.params.table;
  if (!TABLES.has(t)) return res.status(404).json({ error: "unknown table" });
  if (!req.user.roles?.includes("admin")) return res.status(403).json({ error: "admin only" });
  const body = req.body || {};
  const cols = Object.keys(body);
  if (!cols.length) return res.status(400).json({ error: "empty body" });
  const params = cols.map((_, i) => `$${i + 1}`);

  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    const { rows } = await client.query(
      `INSERT INTO public.${t} (${cols.join(",")}) VALUES (${params.join(",")}) RETURNING *`,
      cols.map(c => body[c])
    );
    const row = rows[0];

    // Synchronous auto-post: if this table has a poster and the row isn't
    // already linked to a journal entry, create one. Failure rolls back the
    // whole transaction so the books stay balanced.
    const poster = POSTERS[t];
    if (poster && !row.journal_entry_id) {
      const jeId = await poster(client, row, { userId: req.user.sub });
      if (jeId) {
        await linkSourceToEntry(client, t, row.id, jeId);
        row.journal_entry_id = jeId;
      }
    }

    await client.query('COMMIT');
    res.json(row);
  } catch (e) {
    await client.query('ROLLBACK');
    res.status(500).json({ error: e.message });
  } finally {
    client.release();
  }
});

app.patch("/api/:table", requireAuth, async (req, res) => {
  const t = req.params.table;
  if (!TABLES.has(t)) return res.status(404).json({ error: "unknown table" });
  if (!req.user.roles?.includes("admin")) return res.status(403).json({ error: "admin only" });
  
  const { id, ...body } = req.body || {};
  if (!id) return res.status(400).json({ error: "id required" });
  
  const cols = Object.keys(body);
  if (!cols.length) return res.status(400).json({ error: "empty body" });
  
  const sets = cols.map((c, i) => `${c}=$${i + 2}`);
  const vals = cols.map(c => body[c]);

  try {
    const { rows } = await pool.query(
      `UPDATE public.${t} SET ${sets.join(",")} WHERE id=$1 RETURNING *`,
      [id, ...vals]
    );
    res.json(rows[0]);
  } catch (e) { res.status(500).json({ error: e.message }); }
});

app.get("/health", (_, res) => res.json({ ok: true }));

const port = process.env.PORT || 4000;
app.listen(port, () => {
  const banner = [
    "============================================================",
    `  LANACC API listening on :${port}`,
    `  JWT_SECRET loaded               : ${process.env.JWT_SECRET ? "yes" : "NO (using dev fallback!)"}`,
    `  AT_SIGNING_KEY loaded           : ${process.env.AT_SIGNING_KEY ? "yes" : "NO"}`,
    `  SUPABASE_URL                    : ${process.env.SUPABASE_URL || "(default)"}`,
    `  SUPABASE_SERVICE_ROLE_KEY loaded: ${process.env.SUPABASE_SERVICE_ROLE_KEY ? "yes (sync enabled)" : "NO (sync DISABLED)"}`,
    "============================================================",
  ].join("\n");
  console.log(banner);
});
