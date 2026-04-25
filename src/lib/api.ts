// Drop-in helper for talking to the local LANACC API from the React app.
// Use INSTEAD of (or alongside) src/integrations/supabase/client.ts when running
// the on-premise Docker stack.

const getApiUrl = () => {
  const configured = import.meta.env.VITE_API_URL;
  if (configured) return configured;
  const host = typeof window !== 'undefined' ? window.location.hostname : 'localhost';
  return `http://${host}:4000`;
};
const API = getApiUrl();
export const getApiBase = () => API;

function token() { return localStorage.getItem("lanacc_token") || ""; }

export async function login(email: string, password: string) {
  const r = await fetch(`${API}/auth/login`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ email, password }),
  });
  if (!r.ok) throw new Error((await r.json()).error || "login failed");
  const data = await r.json();
  localStorage.setItem("lanacc_token", data.token);
  localStorage.setItem("lanacc_user", JSON.stringify(data.user));
  return data;
}

export function logout() {
  localStorage.removeItem("lanacc_token");
  localStorage.removeItem("lanacc_user");
}

export function getLocalUser() {
  const raw = localStorage.getItem("lanacc_user");
  if (!raw) return null;
  try { return JSON.parse(raw); }
  catch { return null; }
}

export async function api<T = any>(path: string, init: RequestInit = {}): Promise<T> {
  const r = await fetch(`${API}${path}`, {
    ...init,
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${token()}`,
      ...(init.headers || {}),
    },
  });
  if (!r.ok) throw new Error((await r.json().catch(() => ({}))).error || r.statusText);
  return r.json();
}

export const list   = (table: string)            => api(`/api/${table}`);
export const insert = (table: string, row: any)  => api(`/api/${table}`, { method: "POST", body: JSON.stringify(row) });
