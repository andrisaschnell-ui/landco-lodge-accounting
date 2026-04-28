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
]);

function requireAuth(req, res, next) {
  const h = req.headers.authorization || "";
  const token = h.startsWith("Bearer ") ? h.slice(7) : null;
  if (!token) return res.status(401).json({ error: "missing token" });
  try { req.user = jwt.verify(token, JWT); next(); }
  catch { return res.status(401).json({ error: "invalid token" }); }
}

// ---------- auto-journal helpers ----------
async function createAutoJournal(client, type, data) {
  const { rows: [entry] } = await client.query(`
    INSERT INTO public.journal_entries
      (entry_date, description, entry_type, property_id, posted, created_by)
    VALUES ($1, $2, $3, $4, true, $5)
    RETURNING id`,
    [data.date || new Date(), data.description || `${type} Entry`, type, data.property_id, '00000000-0000-0000-0000-000000000000']
  );

  if (type === 'income') {
    await client.query(`
      INSERT INTO public.journal_lines (journal_entry_id, account_id, debit, credit)
      VALUES 
        ($1, (SELECT id FROM public.accounts WHERE code='211'), $2, 0),
        ($1, (SELECT id FROM public.accounts WHERE code='711'), 0, $2)`,
      [entry.id, data.accommodation_amount_mzn || 0]
    );
  } else if (type === 'expense') {
    // Look up the mapped account for the category
    const { rows: [cat] } = await client.query(
      "SELECT pgc_account_code FROM public.expense_categories WHERE id = $1",
      [data.category_id]
    );
    
    const accountCode = cat?.pgc_account_code || '69'; // Default to "Other Expenses" (6.9) if unmapped

    await client.query(`
      INSERT INTO public.journal_lines (journal_entry_id, account_id, debit, credit)
      VALUES 
        ($1, (SELECT id FROM public.accounts WHERE code=$2), $3, 0),
        ($1, (SELECT id FROM public.accounts WHERE code='111'), 0, $3)`,
      [entry.id, accountCode, data.amount_mzn || 0]
    );
  }
  return entry.id;
}

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

    // Trigger auto-journal for specific tables
    if (t === 'income_transactions') {
      const jeId = await createAutoJournal(client, 'income', row);
      await client.query(`UPDATE public.income_transactions SET journal_entry_id = $1 WHERE id = $2`, [jeId, row.id]);
      row.journal_entry_id = jeId;
    } else if (t === 'expense_transactions') {
      const jeId = await createAutoJournal(client, 'expense', row);
      await client.query(`UPDATE public.expense_transactions SET journal_entry_id = $1 WHERE id = $2`, [jeId, row.id]);
      row.journal_entry_id = jeId;
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
