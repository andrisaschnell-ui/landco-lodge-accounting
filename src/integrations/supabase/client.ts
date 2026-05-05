// =====================================================================
// !!! DO NOT REGENERATE — MODE-AWARE CLIENT (LANACC custom) !!!
// =====================================================================
// In Cloud mode this is the real Supabase JS client.
// In Local mode it is a thin shim that routes .from(table).select/insert/
// update/delete to the local Docker API at VITE_API_URL.
//
// Lovable's auto-generator will silently overwrite this file with the
// stock 4-line client. If that happens you will lose Local mode and the
// app will crash when the user toggles to Local. To restore: copy the
// version from GitHub branch v5 back into this path, or run
// `git checkout origin/v5 -- src/integrations/supabase/client.ts`.
//
// SENTINEL: keep the line below verbatim — it is what we grep for to
// detect a regeneration in CI / install scripts.
// LANACC_MODE_AWARE_CLIENT_v1
// =====================================================================

import { createClient } from "@supabase/supabase-js";
import type { Database } from "./types";
import { getDbMode } from "@/lib/dbMode";
import { getApiBase } from "@/lib/api";

// Migrated 2026-04-29 from project yllodlsdldtttkftalwc → neakxehuonsrlvjrxhnd
const SUPABASE_URL = "https://neakxehuonsrlvjrxhnd.supabase.co";
const SUPABASE_PUBLISHABLE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5lYWt4ZWh1b25zcmx2anJ4aG5kIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzczODcyMzUsImV4cCI6MjA5Mjk2MzIzNX0.m9cL7bDv5jRFjBqmzxOYLus36ptEoY-BVdY7ohncMhg";

const cloudClient = createClient<Database>(SUPABASE_URL, SUPABASE_PUBLISHABLE_KEY, {
  auth: { storage: localStorage, persistSession: true, autoRefreshToken: true },
});

// ---------- Local-mode shim ----------
function localToken() { return localStorage.getItem("lanacc_token") || ""; }
async function http(path: string, init: RequestInit = {}) {
  const r = await fetch(`${getApiBase()}${path}`, {
    ...init,
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${localToken()}`,
      ...(init.headers || {}),
    },
  });
  const text = await r.text();
  const data = text ? (() => { try { return JSON.parse(text); } catch { return text; } })() : null;
  if (!r.ok) return { data: null, error: { message: (data && (data.error || data.message)) || r.statusText } };
  return { data, error: null };
}

function buildLocalQuery(table: string, selectCols: string = "*", options: { count?: string; head?: boolean } = {}) {
  const filters: Array<{ col: string; op: string; val: any }> = [];
  const order: Array<{ col: string; ascending: boolean }> = [];
  let limitN: number | null = null;
  let single = false;
  const wantsCount = options.count === "exact";
  const headOnly = options.head === true;

  const exec = async (): Promise<any> => {
    const res = await http(`/api/${table}`);
    if (res.error) return res;
    let rows: any[] = Array.isArray(res.data) ? res.data : [];

    // Simple join simulation for Local Mode (since generic API doesn't support nested selects yet)
    if (selectCols.includes("employees")) {
      const { data: emps } = await http("/api/employees");
      if (emps && Array.isArray(emps)) {
        const empMap = new Map(emps.map((e: any) => [e.id, e]));
        rows = rows.map(r => ({
          ...r,
          employees: r.employee_id ? empMap.get(r.employee_id) : null
        }));
      }
    }

    for (const f of filters) {
      rows = rows.filter((r) => {
        const v = r[f.col];
        switch (f.op) {
          case "eq": return v === f.val;
          case "neq": return v !== f.val;
          case "gt": return v > f.val;
          case "gte": return v >= f.val;
          case "lt": return v < f.val;
          case "lte": return v <= f.val;
          case "in": return Array.isArray(f.val) && f.val.includes(v);
          case "is": return v === f.val;
          default: return true;
        }
      });
    }
    for (const o of [...order].reverse()) {
      rows = [...rows].sort((a, b) => {
        const av = a[o.col], bv = b[o.col];
        if (av === bv) return 0;
        const cmp = av > bv ? 1 : -1;
        return o.ascending ? cmp : -cmp;
      });
    }
    const count = rows.length;
    if (limitN != null) rows = rows.slice(0, limitN);
    if (single) return { data: rows[0] ?? null, error: null, count: wantsCount ? count : null };
    return { data: headOnly ? null : rows, error: null, count: wantsCount ? count : null };
  };

  const chain: any = {
    eq: (c: string, v: any) => (filters.push({ col: c, op: "eq", val: v }), chain),
    neq: (c: string, v: any) => (filters.push({ col: c, op: "neq", val: v }), chain),
    gt: (c: string, v: any) => (filters.push({ col: c, op: "gt", val: v }), chain),
    gte: (c: string, v: any) => (filters.push({ col: c, op: "gte", val: v }), chain),
    lt: (c: string, v: any) => (filters.push({ col: c, op: "lt", val: v }), chain),
    lte: (c: string, v: any) => (filters.push({ col: c, op: "lte", val: v }), chain),
    in: (c: string, v: any[]) => (filters.push({ col: c, op: "in", val: v }), chain),
    is: (c: string, v: any) => (filters.push({ col: c, op: "is", val: v }), chain),
    order: (c: string, opts: any = {}) => (order.push({ col: c, ascending: opts.ascending !== false }), chain),
    limit: (n: number) => (limitN = n, chain),
    single: () => { single = true; return chain; },
    maybeSingle: () => { single = true; return chain; },
    then: (resolve: any, reject: any) => exec().then(resolve, reject),
  };

  return chain;
}

function localFrom(table: string) {
  return {
    select: (cols?: string, options?: { count?: string; head?: boolean }) => buildLocalQuery(table, cols || "*", options),
    insert: (rows: any | any[]) => {
      const arr = Array.isArray(rows) ? rows : [rows];
      const exec = async () => {
        const out: any[] = [];
        for (const row of arr) {
          const r = await http(`/api/${table}`, { method: "POST", body: JSON.stringify(row) });
          if (r.error) return r;
          out.push(r.data);
        }
        return { data: Array.isArray(rows) ? out : out[0], error: null };
      };

      const promise = exec();
      const chain: any = {
        select: (_cols?: string) => chain,
        single: () => promise.then(res => ({ data: Array.isArray(res.data) ? res.data[0] : res.data, error: res.error })),
        maybeSingle: () => promise.then(res => ({ data: Array.isArray(res.data) ? res.data[0] : res.data, error: res.error })),
        then: (resolve: any, reject: any) => promise.then(resolve, reject),
      };
      return chain;
    },
    update: (patch: any) => {
      const filters: Array<{ col: string; val: any }> = [];
      const builder: any = {
        eq: (c: string, v: any) => (filters.push({ col: c, val: v }), builder),
        in: (c: string, v: any[]) => (filters.push({ col: `__in_${c}`, val: v.join(",") }), builder),
        then: async (resolve: any, reject: any) => {
          const idFilter = filters.find((f) => f.col === "id");
          const qs = new URLSearchParams();
          filters.forEach((f) => qs.append(f.col, String(f.val)));
          const r = await http(`/api/${table}${qs.toString() ? `?${qs.toString()}` : ""}`, {
            method: "PATCH",
            body: JSON.stringify({ ...(idFilter ? { id: idFilter.val } : {}), ...patch }),
          });
          resolve(r);
        },
      };
      return builder;
    },
    delete: () => {
      const filters: Array<{ col: string; val: any }> = [];
      const builder: any = {
        eq: (c: string, v: any) => (filters.push({ col: c, val: v }), builder),
        in: (c: string, v: any[]) => (filters.push({ col: `__in_${c}`, val: v.join(",") }), builder),
        then: async (resolve: any) => {
          const idFilter = filters.find((f) => f.col === "id");
          const qs = new URLSearchParams();
          filters.forEach((f) => qs.append(f.col, String(f.val)));
          const r = await http(
            idFilter && filters.length === 1
              ? `/api/${table}/${encodeURIComponent(idFilter.val)}`
              : `/api/${table}?${qs.toString()}`,
            { method: "DELETE" },
          );
          resolve(r);
        },
      };
      return builder;
    },
    upsert: async (rows: any | any[], options?: Record<string, unknown>) => {
      return http(`/api/${table}/upsert`, {
        method: "POST",
        body: JSON.stringify({ payload: rows, options: options || {} }),
      });
    },
  };
}

// Local "auth" passthrough: real login happens via /lib/api.ts login().
// We expose a Supabase-shaped object so existing useAuth code keeps working.
const localAuth = {
  onAuthStateChange: (_cb: any) => ({ data: { subscription: { unsubscribe() {} } } }),
  getSession: async () => ({ data: { session: null } }),
  getUser: async () => {
    const token = localToken();
    if (!token) return { data: { user: null }, error: null };
    // In local mode we don't strictly decode the JWT here, just return a dummy
    // shape that keeps the UI and logging happy.
    return { data: { user: { id: "local-user" } }, error: null };
  },
  signInWithPassword: async () => ({ data: null, error: { message: "Use local login form" } }),
  signUp: async () => ({ data: null, error: { message: "Sign-up disabled in Local mode" } }),
  signOut: async () => ({ error: null }),
};

const localClient: any = {
  from: localFrom,
  auth: localAuth,
  rpc: async (fn: string, args: Record<string, unknown> = {}) => http(`/api/rpc/${fn}`, {
    method: "POST",
    body: JSON.stringify(args),
  }),
  channel: () => ({ on: () => ({ subscribe: () => ({}) }), subscribe: () => ({}) }),
  removeChannel: () => {},
  storage: { from: () => ({ upload: async () => ({ data: null, error: { message: "Storage not available in Local mode" } }) }) },
};

// Pick once at module load — ModeToggle reloads the page on switch so this is safe.
export const supabase: any = getDbMode() === "local" ? localClient : cloudClient;
