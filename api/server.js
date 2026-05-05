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

const { Pool, types } = pkg;
// Force DATE (OID 1082) to be returned as a string (YYYY-MM-DD) instead of a JS Date object.
// This prevents serialization to ISO strings which break HTML5 date inputs.
types.setTypeParser(1082, (val) => val);

const pool = new Pool({ connectionString: process.env.DATABASE_URL });
const JWT = process.env.JWT_SECRET || "dev-secret";

const app = express();
app.use(cors());
app.use(express.json({ limit: "20mb" }));

// ---------- helpers ----------
const TABLES = new Set([
  "properties","shareholders","bank_accounts","expense_categories",
  "employees","exchange_rates","income_transactions","expense_transactions",
  "bank_transactions","bank_opening_balances","petty_cash_transactions","salary_runs","salary_lines",
  "salary_advances","bim_salary_transfers","inss_payments","irps_payments",
  "shareholder_balances","import_log","profiles","user_roles",
  "landco_income",
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
  "company_settings",
  // Core / Suppliers
  "suppliers","supplier_invoices",
  "journal_entries", "journal_lines", "invoices"
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
app.use('/api/sync', syncRoutes(pool));

app.post("/api/rpc/:fn", requireAuth, async (req, res) => {
  const fn = req.params.fn;
  const args = req.body || {};
  const allowed = new Set([
    "fn_account_or_suspense",
    "fn_generate_depreciation_schedule",
    "fn_post_depreciation_month",
  ]);
  if (!allowed.has(fn)) return res.status(404).json({ error: "unknown rpc" });

  const keys = Object.keys(args);
  const vals = keys.map((k) => args[k]);
  const placeholders = keys.map((_, i) => `$${i + 1}`).join(", ");
  const sql = `SELECT public.${fn}(${placeholders}) AS result`;

  try {
    const { rows } = await pool.query(sql, vals);
    res.json(rows[0]?.result ?? null);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// ---------- generic table API ----------
app.get("/api/:table/count", requireAuth, async (req, res) => {
  const t = req.params.table;
  if (!TABLES.has(t)) return res.status(404).json({ error: "unknown table" });
  let queryStr = `SELECT COUNT(*) as count FROM public.${t} `;
  let vals = [];
  let whereClauses = [];
  
  for (const [k, v] of Object.entries(req.query)) {
    if (k.startsWith('__isnull_')) {
      whereClauses.push(`${k.replace('__isnull_', '')} IS NULL`);
    } else if (k.startsWith('__not_')) {
      // simplified not null
      if (k.endsWith('_is')) {
         whereClauses.push(`${k.replace('__not_', '').replace('_is', '')} IS NOT NULL`);
      }
    } else if (k !== 'limit' && k !== 'order' && k !== 'ascending') {
      vals.push(v);
      whereClauses.push(`${k} = $${vals.length}`);
    }
  }
  if (whereClauses.length > 0) {
    queryStr += 'WHERE ' + whereClauses.join(' AND ') + ' ';
  }
  try {
    const { rows } = await pool.query(queryStr, vals);
    res.json([{ count: parseInt(rows[0].count, 10) }]);
  } catch (e) { res.status(500).json({ error: e.message }); }
});

app.get("/api/:table", requireAuth, async (req, res) => {
  const t = req.params.table;
  if (!TABLES.has(t)) return res.status(404).json({ error: "unknown table" });
  let limit = Math.min(parseInt(req.query.limit) || 1000, 5000);
  // Support pseudo-joins like "*, properties(name)" by simply selecting everything from main table
  let queryStr = `SELECT * FROM public.${t} `;
  let vals = [];
  let whereClauses = [];
  
  for (const [k, v] of Object.entries(req.query)) {
    if (k.startsWith('__isnull_')) {
      whereClauses.push(`${k.replace('__isnull_', '')} IS NULL`);
    } else if (k.startsWith('__in_')) {
      const parts = v.split(',');
      const placeholders = parts.map(p => { vals.push(p); return `$${vals.length}`; }).join(',');
      whereClauses.push(`${k.replace('__in_', '')} IN (${placeholders})`);
    } else if (k.startsWith('__gte_')) {
      vals.push(v);
      whereClauses.push(`${k.replace('__gte_', '')} >= $${vals.length}`);
    } else if (k.startsWith('__lte_')) {
      vals.push(v);
      whereClauses.push(`${k.replace('__lte_', '')} <= $${vals.length}`);
    } else if (k.startsWith('__not_')) {
      if (k.endsWith('_is')) {
        whereClauses.push(`${k.replace('__not_', '').replace('_is', '')} IS NOT NULL`);
      }
    } else if (k !== 'limit' && k !== 'order' && k !== 'ascending' && k !== 'select') {
      vals.push(v);
      whereClauses.push(`${k} = $${vals.length}`);
    }
  }
  if (whereClauses.length > 0) {
    queryStr += 'WHERE ' + whereClauses.join(' AND ') + ' ';
  }
  if (req.query.order) {
    // order could be an array if multiple were provided
    const orders = Array.isArray(req.query.order) ? req.query.order : [req.query.order];
    const asc = Array.isArray(req.query.ascending) ? req.query.ascending : [req.query.ascending];
    const clauses = orders.map((o, i) => {
      const dir = (asc[i] === 'false' || (!asc[i] && req.query.ascending === 'false')) ? 'DESC' : 'ASC';
      return `${o} ${dir}`;
    });
    queryStr += `ORDER BY ${clauses.join(', ')} `;
  }
  vals.push(limit);
  queryStr += `LIMIT $${vals.length}`;
  try {
    const { rows } = await pool.query(queryStr, vals);
    res.json(rows);
  } catch (e) { res.status(500).json({ error: e.message }); }
});

app.post("/api/:table", requireAuth, async (req, res) => {
  const t = req.params.table;
  if (!TABLES.has(t)) return res.status(404).json({ error: "unknown table" });
  if (!req.user.roles?.includes("admin")) return res.status(403).json({ error: "admin only" });
  
  const body = req.body || {};
  const rowsToInsert = Array.isArray(body) ? body : [body].filter(Boolean);
  if (!rowsToInsert.length) return res.json(Array.isArray(body) ? [] : null);

  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    const results = [];
    const poster = POSTERS[t];

    for (const rowData of rowsToInsert) {
      const cols = Object.keys(rowData);
      if (!cols.length) continue;
      const params = cols.map((_, i) => `$${i + 1}`);
      const { rows } = await client.query(
        `INSERT INTO public.${t} (${cols.join(",")}) VALUES (${params.join(",")}) RETURNING *`,
        cols.map(c => rowData[c])
      );
      const row = rows[0];

      if (poster && !row.journal_entry_id) {
        const jeId = await poster(client, row, { userId: req.user.sub });
        if (jeId) {
          await linkSourceToEntry(client, t, row.id, jeId);
          row.journal_entry_id = jeId;
        }
      }
      results.push(row);
    }

    await client.query('COMMIT');
    res.json(Array.isArray(body) ? results : results[0]);
  } catch (e) {
    await client.query('ROLLBACK');
    res.status(500).json({ error: e.message });
  } finally {
    client.release();
  }
});

app.post("/api/:table/upsert", requireAuth, async (req, res) => {
  const t = req.params.table;
  if (!TABLES.has(t)) return res.status(404).json({ error: "unknown table" });
  if (!req.user.roles?.includes("admin")) return res.status(403).json({ error: "admin only" });

  const { payload, options = {} } = req.body || {};
  const rows = Array.isArray(payload) ? payload : [payload].filter(Boolean);
  const onConflict = String(options.onConflict || "")
    .split(",")
    .map((part) => part.trim())
    .filter(Boolean);

  if (!rows.length) return res.status(400).json({ error: "empty payload" });
  if (!onConflict.length) return res.status(400).json({ error: "onConflict required" });

  const client = await pool.connect();
  try {
    await client.query("BEGIN");
    const results = [];

    for (const row of rows) {
      const cols = Object.keys(row || {});
      if (!cols.length) continue;

      const params = cols.map((_, i) => `$${i + 1}`);
      const updateCols = cols.filter((col) => !onConflict.includes(col));
      const conflictAction = options.ignoreDuplicates
        ? "DO NOTHING"
        : `DO UPDATE SET ${updateCols.map((col) => `${col}=EXCLUDED.${col}`).join(", ")}`;

      const sql = `
        INSERT INTO public.${t} (${cols.join(",")})
        VALUES (${params.join(",")})
        ON CONFLICT (${onConflict.join(", ")}) ${conflictAction}
        RETURNING *
      `;

      const { rows: upserted } = await client.query(sql, cols.map((col) => row[col]));
      if (upserted[0]) {
        results.push(upserted[0]);
        continue;
      }

      const where = onConflict.map((col, i) => `${col} = $${i + 1}`).join(" AND ");
      const { rows: existing } = await client.query(
        `SELECT * FROM public.${t} WHERE ${where} LIMIT 1`,
        onConflict.map((col) => row[col])
      );
      if (existing[0]) results.push(existing[0]);
    }

    await client.query("COMMIT");
    res.json(Array.isArray(payload) ? results : results[0] ?? null);
  } catch (e) {
    await client.query("ROLLBACK");
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
  const cols = Object.keys(body);
  if (!cols.length) return res.status(400).json({ error: "empty body" });

  const sets = cols.map((c, i) => `${c}=$${i + 1}`);
  const vals = cols.map(c => body[c]);
  const whereClauses = [];

  if (id) {
    vals.push(id);
    whereClauses.push(`id=$${vals.length}`);
  }

  for (const [k, v] of Object.entries(req.query)) {
    if (k.startsWith('__in_')) {
      const parts = String(v).split(',');
      const placeholders = parts.map((part) => {
        vals.push(part);
        return `$${vals.length}`;
      }).join(',');
      whereClauses.push(`${k.replace('__in_', '')} IN (${placeholders})`);
    } else if (k !== 'id') {
      vals.push(v);
      whereClauses.push(`${k}=$${vals.length}`);
    }
  }

  if (!whereClauses.length) return res.status(400).json({ error: "update requires id or query filters" });

  try {
    const { rows } = await pool.query(
      `UPDATE public.${t} SET ${sets.join(",")} WHERE ${whereClauses.join(" AND ")} RETURNING *`,
      vals
    );
    res.json(rows.length === 1 ? rows[0] : rows);
  } catch (e) { res.status(500).json({ error: e.message }); }
});

app.delete("/api/:table", requireAuth, async (req, res) => {
  const t = req.params.table;
  if (!TABLES.has(t)) return res.status(404).json({ error: "unknown table" });
  if (!req.user.roles?.includes("admin")) return res.status(403).json({ error: "admin only" });
  
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    const vals = [];
    const whereClauses = [];
    for (const [k, v] of Object.entries(req.query)) {
      if (k.startsWith('__in_')) {
        const parts = String(v).split(',');
        const placeholders = parts.map((part) => {
          vals.push(part);
          return `$${vals.length}`;
        }).join(',');
        whereClauses.push(`${k.replace('__in_', '')} IN (${placeholders})`);
      } else {
        vals.push(v);
        whereClauses.push(`${k} = $${vals.length}`);
      }
    }
    if (!whereClauses.length) {
      await client.query('ROLLBACK');
      return res.status(400).json({ error: "delete requires query filters" });
    }
    const { rowCount } = await client.query(
      `DELETE FROM public.${t} WHERE ${whereClauses.join(' AND ')}`,
      vals,
    );
    await client.query('COMMIT');
    res.json({ success: true, deleted: rowCount });
  } catch (e) {
    await client.query('ROLLBACK');
    res.status(500).json({ error: e.message });
  } finally {
    client.release();
  }
});

app.delete("/api/:table/:id", requireAuth, async (req, res) => {
  const t = req.params.table;
  if (!TABLES.has(t)) return res.status(404).json({ error: "unknown table" });
  if (!req.user.roles?.includes("admin")) return res.status(403).json({ error: "admin only" });
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    const { rowCount } = await client.query(`DELETE FROM public.${t} WHERE id = $1`, [req.params.id]);
    await client.query('COMMIT');
    res.json({ success: true, deleted: rowCount });
  } catch (e) {
    await client.query('ROLLBACK');
    res.status(500).json({ error: e.message });
  } finally {
    client.release();
  }
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
