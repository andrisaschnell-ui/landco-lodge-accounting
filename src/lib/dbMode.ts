// Mode controller: switches the app between cloud (Supabase) and local (Docker API).
// Selection is persisted in localStorage. Toggling forces a hard reload so all
// modules (including the Supabase shim) re-evaluate against the new mode.

export type DbMode = "cloud" | "local";
const KEY = "lanacc_db_mode";

export function getDbMode(): DbMode {
  if (typeof window === "undefined") return "cloud";
  const v = localStorage.getItem(KEY);
  return v === "local" ? "local" : "cloud";
}

export function setDbMode(mode: DbMode) {
  localStorage.setItem(KEY, mode);
  // Drop both auth contexts so the new mode starts clean
  localStorage.removeItem("lanacc_token");
  localStorage.removeItem("lanacc_user");
  window.location.reload();
}

export function isLocalMode() { return getDbMode() === "local"; }
export function isCloudMode() { return getDbMode() === "cloud"; }
