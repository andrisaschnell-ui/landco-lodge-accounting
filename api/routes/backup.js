// Backup / Restore routes for LANACC PostgreSQL database.
// Three scopes: 'landco' (accounting + master data), 'cash' (cash module),
// 'complete' (entire public schema). Files live in /app/backups/<scope>/.
//
// All endpoints require admin role.

import express from "express";
import fs from "fs";
import path from "path";
import { spawn } from "child_process";

const BACKUP_ROOT = process.env.BACKUP_DIR || "/app/backups";

const SCOPES = {
  landco: {
    label: "Landco Accounting",
    tables: [
      "accounts","accounting_periods","journal_entries","journal_lines",
      "invoices","expense_categories","expense_transactions",
      "income_transactions","properties","shareholders","shareholder_balances",
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

function scopeDir(scope) {
  const dir = path.join(BACKUP_ROOT, scope);
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

  // List available scopes (used by UI)
  r.get("/scopes", requireAuth, (_req, res) => {
    res.json(Object.entries(SCOPES).map(([key, v]) => ({
      key, label: v.label,
    })));
  });

  // List backups in a scope
  r.get("/list", requireAuth, (req, res) => {
    const scope = String(req.query.scope || "");
    if (!SCOPES[scope]) return res.status(400).json({ error: "unknown scope" });
    const dir = scopeDir(scope);
    const files = fs.readdirSync(dir)
      .filter((f) => f.endsWith(".sql"))
      .map((f) => {
        const stat = fs.statSync(path.join(dir, f));
        return { filename: f, size: stat.size, mtime: stat.mtime };
      })
      .sort((a, b) => b.mtime - a.mtime);
    res.json(files);
  });

  // Create a backup
  r.post("/create", requireAuth, requireAdmin, async (req, res) => {
    const { scope, note } = req.body || {};
    if (!SCOPES[scope]) return res.status(400).json({ error: "unknown scope" });
    const cfg = SCOPES[scope];
    const dir = scopeDir(scope);
    const filename = `${scope}_${timestamp()}${safeNote(note)}.sql`;
    const filepath = path.join(dir, filename);

    const args = ["--clean", "--if-exists", "--no-owner", "--no-privileges", "-n", "public"];
    if (cfg.tables) {
      for (const t of cfg.tables) { args.push("-t", `public.${t}`); }
    }

    try {
      await runCmd("pg_dump", args, { stdoutFile: filepath });
      const stat = fs.statSync(filepath);
      res.json({ ok: true, filename, size: stat.size });
    } catch (e) {
      try { fs.unlinkSync(filepath); } catch {}
      res.status(500).json({ error: e.message });
    }
  });

  // Restore a backup (overwrites current data in scope)
  r.post("/restore", requireAuth, requireAdmin, async (req, res) => {
    const { scope, filename } = req.body || {};
    if (!SCOPES[scope]) return res.status(400).json({ error: "unknown scope" });
    if (!filename || filename.includes("/") || filename.includes("..")) {
      return res.status(400).json({ error: "invalid filename" });
    }
    const filepath = path.join(scopeDir(scope), filename);
    if (!fs.existsSync(filepath)) return res.status(404).json({ error: "backup not found" });

    try {
      await runCmd("psql", ["-v", "ON_ERROR_STOP=1", "-1"], { stdinFile: filepath });
      res.json({ ok: true, restored: filename });
    } catch (e) {
      res.status(500).json({ error: e.message });
    }
  });

  // Download a backup file
  r.get("/download", requireAuth, (req, res) => {
    const scope = String(req.query.scope || "");
    const filename = String(req.query.filename || "");
    if (!SCOPES[scope]) return res.status(400).json({ error: "unknown scope" });
    if (!filename || filename.includes("/") || filename.includes("..")) {
      return res.status(400).json({ error: "invalid filename" });
    }
    const filepath = path.join(scopeDir(scope), filename);
    if (!fs.existsSync(filepath)) return res.status(404).json({ error: "not found" });
    res.download(filepath, filename);
  });

  // Delete a backup file (admin only)
  r.delete("/file", requireAuth, requireAdmin, (req, res) => {
    const scope = String(req.query.scope || "");
    const filename = String(req.query.filename || "");
    if (!SCOPES[scope]) return res.status(400).json({ error: "unknown scope" });
    if (!filename || filename.includes("/") || filename.includes("..")) {
      return res.status(400).json({ error: "invalid filename" });
    }
    const filepath = path.join(scopeDir(scope), filename);
    if (!fs.existsSync(filepath)) return res.status(404).json({ error: "not found" });
    fs.unlinkSync(filepath);
    res.json({ ok: true });
  });

  return r;
}
