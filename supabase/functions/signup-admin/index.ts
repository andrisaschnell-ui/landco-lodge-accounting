// PIN-gated admin signup. Anyone who knows ADMIN_SIGNUP_PIN can create a new
// admin user in this Supabase project. Uses the service role key so it can:
//   1) create an auth user (with email auto-confirmed)
//   2) insert the 'admin' role into public.user_roles (bypassing RLS)
//
// Public endpoint (verify_jwt = false) — security comes from the PIN check.

import { createClient } from "https://esm.sh/@supabase/supabase-js@2.57.4";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response(null, { headers: corsHeaders });
  }

  try {
    if (req.method !== "POST") {
      return json({ error: "method not allowed" }, 405);
    }

    const PIN = Deno.env.get("ADMIN_SIGNUP_PIN");
    if (!PIN) {
      return json({ error: "ADMIN_SIGNUP_PIN not configured on server" }, 500);
    }

    const body = await req.json().catch(() => null);
    if (!body) return json({ error: "invalid JSON body" }, 400);

    const email = String(body.email || "").trim().toLowerCase();
    const password = String(body.password || "");
    const pin = String(body.pin || "");

    if (!email || !password) return json({ error: "email and password required" }, 400);
    if (password.length < 8) return json({ error: "password must be at least 8 characters" }, 400);
    if (pin !== PIN) return json({ error: "invalid admin PIN" }, 403);

    const url = Deno.env.get("SUPABASE_URL")!;
    const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    const admin = createClient(url, serviceKey, {
      auth: { autoRefreshToken: false, persistSession: false },
    });

    // Create user (auto-confirmed so they can log in immediately)
    const { data: created, error: cErr } = await admin.auth.admin.createUser({
      email,
      password,
      email_confirm: true,
    });

    let userId = created?.user?.id;

    if (cErr) {
      // If user already exists, look them up so we can still grant admin
      const msg = cErr.message?.toLowerCase() || "";
      if (msg.includes("already") || msg.includes("registered") || msg.includes("exists")) {
        const { data: list, error: lErr } = await admin.auth.admin.listUsers();
        if (lErr) return json({ error: "lookup failed: " + lErr.message }, 500);
        const found = list.users.find((u) => u.email?.toLowerCase() === email);
        if (!found) return json({ error: "user exists but could not be found" }, 500);
        userId = found.id;
      } else {
        return json({ error: cErr.message }, 400);
      }
    }

    if (!userId) return json({ error: "no user id returned" }, 500);

    // Grant admin role (idempotent)
    const { error: rErr } = await admin
      .from("user_roles")
      .upsert({ user_id: userId, role: "admin" }, { onConflict: "user_id,role" });
    if (rErr) return json({ error: "role grant failed: " + rErr.message }, 500);

    return json({ ok: true, user_id: userId, email });
  } catch (e) {
    return json({ error: (e as Error).message }, 500);
  }
});

function json(payload: unknown, status = 200) {
  return new Response(JSON.stringify(payload), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}
