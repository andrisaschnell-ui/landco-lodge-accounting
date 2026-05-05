// Manual two-way sync between local PostgreSQL (this container) and the cloud
// Supabase project (PostgREST). All business tables. Conflict policy: Local wins.
//
// Endpoints:
//   POST /api/sync/push   Local → Cloud
//   POST /api/sync/pull   Cloud → Local
//
// Cloud credentials come from env: SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY.
// If SUPABASE_SERVICE_ROLE_KEY is missing, push is disabled (anon key cannot
// write past RLS) and pull falls back to the anon key.

import express from "express";

const TABLES = [
  "properties","shareholders","bank_accounts","expense_categories",
  "employees","exchange_rates","income_transactions","expense_transactions",
  "landco_income",
  "bank_transactions","petty_cash_transactions","salary_runs","salary_lines",
  "salary_advances","bim_salary_transfers","inss_payments","irps_payments",
  "shareholder_balances","import_log","profiles","user_roles",
  "accounts","accounting_periods",
  "cash_sheets","cash_transactions","cash_dropdown_options","cash_allocation_columns",
  "suppliers","supplier_invoices",
  "journal_entries", "journal_lines", "invoices"
];

const SUPABASE_URL = process.env.SUPABASE_URL || process.env.VITE_SUPABASE_URL || "https://neakxehuonsrlvjrxhnd.supabase.co";
const SERVICE_KEY  = process.env.SUPABASE_SERVICE_ROLE_KEY || "";
const ANON_KEY     = process.env.SUPABASE_ANON_KEY || process.env.VITE_SUPABASE_PUBLISHABLE_KEY || "";

async function fetchCloudTable(table, key) {
  const r = await fetch(`${SUPABASE_URL}/rest/v1/${table}?select=*`, {
    headers: { apikey: key, Authorization: `Bearer ${key}`, "Accept-Profile": "public" },
  });
  if (!r.ok) throw new Error(`cloud GET ${table}: ${r.status} ${await r.text()}`);
  return r.json();
}

async function pushCloudTable(table, rows) {
  if (!rows.length) return 0;
  const r = await fetch(`${SUPABASE_URL}/rest/v1/${table}`, {
    method: "POST",
    headers: {
      apikey: SERVICE_KEY,
      Authorization: `Bearer ${SERVICE_KEY}`,
      "Content-Type": "application/json",
      Prefer: "resolution=merge-duplicates,return=minimal",
    },
    body: JSON.stringify(rows),
  });
  if (!r.ok) throw new Error(`cloud POST ${table}: ${r.status} ${await r.text()}`);
  return rows.length;
}

export default function syncRoutes(pool) {
  const router = express.Router();

  // Local → Cloud (Local wins via merge-duplicates upsert)
  router.post("/push", async (req, res) => {
    // Local sync permitted
    if (!SERVICE_KEY) return res.status(400).json({ error: "SUPABASE_SERVICE_ROLE_KEY not configured on API container" });
 
    console.log(`[SYNC] Starting PUSH Local -> Cloud...`);
    let totalRows = 0, ok = 0;
    const errors = [];
    for (const t of TABLES) {
      try {
        const { rows } = await pool.query(`SELECT * FROM public.${t}`);
        if (rows.length > 0) {
          const count = await pushCloudTable(t, rows);
          totalRows += count;
          console.log(`[SYNC] Pushed ${count} rows for table ${t}`);
        }
        ok++;
      } catch (e) { 
        console.error(`[SYNC] Error pushing table ${t}: ${e.message}`);
        errors.push({ table: t, error: e.message }); 
      }
    }
    console.log(`[SYNC] PUSH complete. Tables: ${ok}, Rows: ${totalRows}, Errors: ${errors.length}`);
    res.json({ ok: errors.length === 0, tables: ok, rows: totalRows, errors });
  });

  // Diagnostic: confirm which key (if any) the API container has loaded.
  // Safe to call without auth — returns booleans only, never the keys themselves.
  router.get("/status", (_req, res) => {
    res.json({
      supabase_url: SUPABASE_URL,
      service_role_key_loaded: !!SERVICE_KEY,
      anon_key_loaded: !!ANON_KEY,
      push_enabled: !!SERVICE_KEY,
      pull_will_use: SERVICE_KEY ? "service_role" : (ANON_KEY ? "anon (RLS-restricted, likely 0 rows)" : "none"),
    });
  });

  // Cloud → Local (upsert with replica triggers off so FK order doesn't matter)
  router.post("/pull", async (req, res) => {
    // Local sync permitted
    if (!SERVICE_KEY) {
      return res.status(400).json({
        error: "SUPABASE_SERVICE_ROLE_KEY not loaded in API container. " +
               "Pull would hit cloud RLS and return 0 rows. " +
               "Add the key to .env.local and run: docker compose --env-file .env.local up -d --force-recreate api",
      });
    }
    const key = SERVICE_KEY;
 
    console.log(`[SYNC] Starting PULL Cloud -> Local...`);
    const client = await pool.connect();
    let totalRows = 0, ok = 0;
    const errors = [];
    try {
      await client.query("BEGIN");
      await client.query("SET LOCAL session_replication_role = 'replica'");
      for (const t of TABLES) {
        try {
          const cloudRows = await fetchCloudTable(t, key);
          console.log(`[SYNC] Fetched ${cloudRows.length} rows from cloud for table ${t}`);
          for (const row of cloudRows) {
            const cols = Object.keys(row);
            if (!cols.length) continue;
            const params = cols.map((_, i) => `$${i + 1}`);
            const updates = cols.filter((c) => c !== "id").map((c) => `${c}=EXCLUDED.${c}`);
            const sql = `INSERT INTO public.${t} (${cols.join(",")}) VALUES (${params.join(",")})
                         ON CONFLICT (id) DO UPDATE SET ${updates.join(",") || "id=EXCLUDED.id"}`;
            await client.query(sql, cols.map((c) => row[c]));
            totalRows++;
          }
          ok++;
        } catch (e) { 
          console.error(`[SYNC] Error pulling table ${t}: ${e.message}`);
          errors.push({ table: t, error: e.message }); 
        }
      }
      await client.query("COMMIT");
      console.log(`[SYNC] PULL complete. Tables: ${ok}, Rows: ${totalRows}, Errors: ${errors.length}`);
    } catch (e) {
      console.error(`[SYNC] PULL critical failure: ${e.message}`);
      await client.query("ROLLBACK");
      return res.status(500).json({ error: e.message });
    } finally {
      client.release();
    }
    res.json({ ok: errors.length === 0, tables: ok, rows: totalRows, errors });
  });

  return router;
}
