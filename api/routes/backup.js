// Backup / Restore routes for LANACC PostgreSQL database.
// Three scopes: 'landco' (accounting + master data), 'cash' (cash module),
// 'complete' (entire public schema).
//
// Targets:
//   - 'local' → /app/backups/<scope>/                (always available)
//   - 'usb_e' / 'usb_f' / 'usb_g' / 'usb_h'          (only if path exists & writable)
//     → maps to /mnt/usb_e/Lanco Backup/<scope>/ etc.
//
// USB drive letters must be pre-mounted via docker-compose.yml.
// The API auto-detects which USB targets are currently writable;
// disconnected drives are silently skipped.
//
// All write/restore endpoints require admin role.

import express from "express";
import fs from "fs";
import path from "path";
import { spawn } from "child_process";

const LOCAL_ROOT = process.env.BACKUP_DIR || "/app/backups";
const USB_FOLDER = "Lanco Backup"; // created on the USB drive if missing

const USB_MOUNTS = {
  usb_e: { path: "/mnt/usb_e", label: "USB E:" },
  usb_f: { path: "/mnt/usb_f", label: "USB F:" },
  usb_g: { path: "/mnt/usb_g", label: "USB G:" },
  usb_h: { path: "/mnt/usb_h", label: "USB H:" },
};

const SCOPES = {
  landco: {
    label: "Landco Accounting",
    tables: [
      "accounts","accounting_periods","journal_entries","journal_lines",
      "invoices","expense_categories","expense_transactions",
      "income_transactions","landco_income","properties","shareholders","shareholder_balances",
      "employees","salary_runs","salary_lines","salary_advances",
      "bim_salary_transfers","inss_payments","irps_payments",
      "bank_accounts","bank_opening_balances","bank_transactions",
      "petty_cash_transactions","suppliers","supplier_invoices",
      "exchange_rates",
    ],
  },
  cash: {
    label: "Cash Control",
    tables: [
      "cash_sheets","cash_transactions",
      "cash_dropdown_options","cash_allocation_columns",
    ],
  },
  complete: {
    label: "Complete Database",
    tables: null, // null = entire public schema
  },
};

// ---- target / path helpers ----

function isWritable(p) {
  try {
    if (!fs.existsSync(p)) return false;
    fs.accessSync(p, fs.constants.W_OK);
    return true;
  } catch { return false; }
}

/** Returns [{key, label, available}] for local + every configured USB. */
function listTargets() {
  const out = [{ key: "local", label: "Local container folder", available: true }];
  for (const [key, m] of Object.entries(USB_MOUNTS)) {
    out.push({ key, label: m.label, available: isWritable(m.path) });
  }
  return out;
}

/** Resolve scope dir for a target, creating intermediate folders as needed. */
function resolveDir(target, scope) {
  if (target === "local") {
    const dir = path.join(LOCAL_ROOT, scope);
    if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });
    return dir;
  }
  const usb = USB_MOUNTS[target];
  if (!usb) throw new Error(`unknown target: ${target}`);
  if (!isWritable(usb.path)) throw new Error(`${usb.label} is not connected or not writable`);
  const dir = path.join(usb.path, USB_FOLDER, scope);
  if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });
  return dir;
}

function timestamp() {
  const d = new Date();
  const p = (n) => String(n).padStart(2, "0");
  return `${d.getFullYear()}-${p(d.getMonth()+1)}-${p(d.getDate())}_${p(d.getHours())}${p(d.getMinutes())}`;
}

function safeNote(note) {
  if (!note) return "";
  return "_" + String(note).trim().replace(/[^a-zA-Z0-9_-]+/g, "-").slice(0, 40);
}

// Parse DATABASE_URL into pg env vars for pg_dump / psql
function pgEnv() {
  const url = new URL(process.env.DATABASE_URL);
  return {
    ...process.env,
    PGHOST: url.hostname,
    PGPORT: url.port || "5432",
    PGUSER: decodeURIComponent(url.username),
    PGPASSWORD: decodeURIComponent(url.password),
    PGDATABASE: url.pathname.replace(/^\//, ""),
  };
}

function runCmd(cmd, args, { stdoutFile, stdinFile } = {}) {
  return new Promise((resolve, reject) => {
    const child = spawn(cmd, args, { env: pgEnv() });
    let stderr = "";
    child.stderr.on("data", (d) => { stderr += d.toString(); });

    if (stdoutFile) {
      const out = fs.createWriteStream(stdoutFile);
      child.stdout.pipe(out);
    }
    if (stdinFile) {
      const inp = fs.createReadStream(stdinFile);
      inp.pipe(child.stdin);
    }

    child.on("error", reject);
    child.on("close", (code) => {
      if (code === 0) resolve({ stderr });
      else reject(new Error(`${cmd} exited ${code}: ${stderr}`));
    });
  });
}

function requireAdmin(req, res, next) {
  if (!req.user?.roles?.includes("admin")) {
    return res.status(403).json({ error: "admin only" });
  }
  next();
}

export default function backupRoutes(requireAuth) {
  const r = express.Router();

  r.get("/scopes", requireAuth, (_req, res) => {
    res.json(Object.entries(SCOPES).map(([key, v]) => ({ key, label: v.label })));
  });

  // List backup targets (local + any connected USB drives)
  r.get("/targets", requireAuth, (_req, res) => {
    res.json(listTargets());
  });

  // List backups in a (scope, target)
  r.get("/list", requireAuth, (req, res) => {
    const scope = String(req.query.scope || "");
    const target = String(req.query.target || "local");
    if (!SCOPES[scope]) return res.status(400).json({ error: "unknown scope" });
    try {
      const dir = resolveDir(target, scope);
      const files = fs.readdirSync(dir)
        .filter((f) => f.endsWith(".sql"))
        .map((f) => {
          const stat = fs.statSync(path.join(dir, f));
          return { filename: f, size: stat.size, mtime: stat.mtime };
        })
        .sort((a, b) => new Date(b.mtime) - new Date(a.mtime));
      res.json(files);
    } catch (e) {
      // Disconnected USB → return empty list rather than 500
      res.json([]);
    }
  });

  // Diagnostics: show exactly which database the API container is dumping,
  // and how many rows each table has. Use this to verify a backup BEFORE
  // trusting it ("if the rows are 0 here, your backup will be empty too").
  r.get("/diag", requireAuth, async (_req, res) => {
    try {
      const env = pgEnv();
      // Use psql to query the same DB pg_dump will hit
      const sql = `
        SELECT current_database() AS db,
               current_user       AS usr,
               inet_server_addr()::text AS host,
               inet_server_port() AS port,
               version() AS pg_version;
        SELECT table_name,
               (xpath('/row/c/text()',
                  query_to_xml(format('SELECT count(*) AS c FROM public.%I', table_name),
                               false, true, '')))[1]::text::bigint AS rows
        FROM information_schema.tables
        WHERE table_schema='public' AND table_type='BASE TABLE'
        ORDER BY table_name;
      `;
      const out = await new Promise((resolve, reject) => {
        const child = spawn("psql", ["-A", "-F", "|", "-t", "-c", sql], { env });
        let stdout = "", stderr = "";
        child.stdout.on("data", (d) => { stdout += d.toString(); });
        child.stderr.on("data", (d) => { stderr += d.toString(); });
        child.on("error", reject);
        child.on("close", (code) => code === 0 ? resolve(stdout) : reject(new Error(stderr)));
      });

      const lines = out.split("\n").filter(Boolean);
      // First line: db|usr|host|port|version
      const first = (lines.shift() || "").split("|");
      const tables = lines.map((l) => {
        const [name, rows] = l.split("|");
        return { table: name, rows: Number(rows || 0) };
      });
      const totalRows = tables.reduce((s, t) => s + t.rows, 0);

      res.json({
        connection: {
          DATABASE_URL_host: process.env.DATABASE_URL ? new URL(process.env.DATABASE_URL).host : null,
          db: first[0], user: first[1], server_host: first[2], server_port: first[3],
          pg_version: first[4],
        },
        tableCount: tables.length,
        totalRows,
        tables,
      });
    } catch (e) {
      res.status(500).json({ error: e.message });
    }
  });

  // Create a backup at the chosen target
  r.post("/create", requireAuth, requireAdmin, async (req, res) => {
    const { scope, note, target = "local" } = req.body || {};
    if (!SCOPES[scope]) return res.status(400).json({ error: "unknown scope" });
    const cfg = SCOPES[scope];

    let dir;
    try { dir = resolveDir(target, scope); }
    catch (e) { return res.status(400).json({ error: e.message }); }

    const filename = `${scope}_${timestamp()}${safeNote(note)}.sql`;
    const filepath = path.join(dir, filename);

    // Build pg_dump args.
    // - For scoped backups (landco / cash): list each table with -t.
    // - For "complete": dump the WHOLE database — no -n, no -t — so we get
    //   every schema, type, function, trigger, sequence and table.
    const args = ["--no-owner", "--no-privileges"];
    if (cfg.tables) {
      // Table-scoped dump. Use --clean so a restore will DROP+CREATE these tables.
      args.push("--clean", "--if-exists");
      for (const t of cfg.tables) { args.push("-t", `public.${t}`); }
    }
    // else: complete dump — let pg_dump emit the full database.

    try {
      await runCmd("pg_dump", args, { stdoutFile: filepath });

      // Strip Postgres 17-only GUCs (transaction_timeout) so older servers
      // can restore dumps produced by a newer pg_dump.
      try {
        const raw = fs.readFileSync(filepath, "utf8");
        const cleaned = raw
          .split("\n")
          .filter((l) => !/^SET\s+transaction_timeout\b/i.test(l.trim()))
          .join("\n");
        if (cleaned !== raw) fs.writeFileSync(filepath, cleaned);
      } catch { /* best-effort sanitisation */ }

      // Sanity check: count CREATE TABLE statements. If wildly fewer than
      // expected, the backup almost certainly hit the wrong database or had
      // permission errors — flag it instead of silently saving garbage.
      const stat = fs.statSync(filepath);
      const dump = fs.readFileSync(filepath, "utf8");
      const createTableCount = (dump.match(/^CREATE TABLE /gm) || []).length;
      const expectedMin = cfg.tables ? Math.ceil(cfg.tables.length * 0.8) : 10;

      if (createTableCount < expectedMin) {
        try { fs.unlinkSync(filepath); } catch {}
        return res.status(500).json({
          error: `Backup looks incomplete: only ${createTableCount} CREATE TABLE statements ` +
                 `found (expected at least ${expectedMin}). The API container may be connected ` +
                 `to the wrong database. Check GET /api/backup/diag to see what the API sees.`,
          createTableCount,
          expectedMin,
        });
      }

      res.json({
        ok: true, filename, size: stat.size, target,
        tablesInDump: createTableCount,
      });
    } catch (e) {
      try { fs.unlinkSync(filepath); } catch {}
      res.status(500).json({ error: e.message });
    }
  });

  // Restore a backup (overwrites current data in scope)
  r.post("/restore", requireAuth, requireAdmin, async (req, res) => {
    const { scope, filename, target = "local" } = req.body || {};
    if (!SCOPES[scope]) return res.status(400).json({ error: "unknown scope" });
    if (!filename || filename.includes("/") || filename.includes("..")) {
      return res.status(400).json({ error: "invalid filename" });
    }

    let dir;
    try { dir = resolveDir(target, scope); }
    catch (e) { return res.status(400).json({ error: e.message }); }

    const filepath = path.join(dir, filename);
    if (!fs.existsSync(filepath)) return res.status(404).json({ error: "backup not found" });

    try {
      // Sanitise: strip Postgres 17-only GUCs (e.g. transaction_timeout) so older
      // servers can restore dumps produced by a newer pg_dump. We write a cleaned
      // copy to /tmp and feed that to psql; the original .sql file is untouched.
      let sourceFile = filepath;
      try {
        const raw = fs.readFileSync(filepath, "utf8");
        const cleaned = raw
          .split("\n")
          .filter((l) => !/^SET\s+transaction_timeout\b/i.test(l.trim()))
          .join("\n");
        if (cleaned !== raw) {
          sourceFile = `/tmp/restore_${Date.now()}.sql`;
          fs.writeFileSync(sourceFile, cleaned);
        }
      } catch { /* fall back to original file */ }

      await runCmd("psql", ["-v", "ON_ERROR_STOP=1", "-1"], { stdinFile: sourceFile });
      if (sourceFile !== filepath) { try { fs.unlinkSync(sourceFile); } catch {} }
      res.json({ ok: true, restored: filename, target });
    } catch (e) {
      res.status(500).json({ error: e.message });
    }
  });

  // Download a backup file
  r.get("/download", requireAuth, (req, res) => {
    const scope = String(req.query.scope || "");
    const target = String(req.query.target || "local");
    const filename = String(req.query.filename || "");
    if (!SCOPES[scope]) return res.status(400).json({ error: "unknown scope" });
    if (!filename || filename.includes("/") || filename.includes("..")) {
      return res.status(400).json({ error: "invalid filename" });
    }
    let dir;
    try { dir = resolveDir(target, scope); }
    catch (e) { return res.status(400).json({ error: e.message }); }

    const filepath = path.join(dir, filename);
    if (!fs.existsSync(filepath)) return res.status(404).json({ error: "not found" });
    res.download(filepath, filename);
  });

  // Delete a backup file
  r.delete("/file", requireAuth, requireAdmin, (req, res) => {
    const scope = String(req.query.scope || "");
    const target = String(req.query.target || "local");
    const filename = String(req.query.filename || "");
    if (!SCOPES[scope]) return res.status(400).json({ error: "unknown scope" });
    if (!filename || filename.includes("/") || filename.includes("..")) {
      return res.status(400).json({ error: "invalid filename" });
    }
    let dir;
    try { dir = resolveDir(target, scope); }
    catch (e) { return res.status(400).json({ error: e.message }); }

    const filepath = path.join(dir, filename);
    if (!fs.existsSync(filepath)) return res.status(404).json({ error: "not found" });
    fs.unlinkSync(filepath);
    res.json({ ok: true });
  });

  return r;
}
