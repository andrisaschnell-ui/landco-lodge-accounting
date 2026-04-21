import { createClient } from '@supabase/supabase-js';

const url = process.env.SUPABASE_URL;
const key = process.env.SUPABASE_SERVICE_ROLE_KEY;
const admin = createClient(url, key, { auth: { persistSession: false } });

const users = [
  { email: 'andrisa.schnell@gmail.com', password: 'Abcd7654#', display_name: 'Andrisa Schnell' },
  { email: 'cwschnell@gmail.com',       password: 'Abcd7654$', display_name: 'Gordon Board' },
];

for (const u of users) {
  // Try create; if exists, fetch + update password
  let { data, error } = await admin.auth.admin.createUser({
    email: u.email,
    password: u.password,
    email_confirm: true,
    user_metadata: { display_name: u.display_name },
  });
  if (error && /already/i.test(error.message)) {
    const { data: list } = await admin.auth.admin.listUsers();
    const existing = list.users.find(x => x.email === u.email);
    if (existing) {
      await admin.auth.admin.updateUserById(existing.id, { password: u.password, email_confirm: true });
      data = { user: existing };
      error = null;
      console.log(`updated existing: ${u.email} (${existing.id})`);
    }
  }
  if (error) { console.error(u.email, error.message); continue; }
  const uid = data.user.id;
  console.log(`ok: ${u.email} (${uid})`);

  // assign admin role (idempotent)
  const { error: roleErr } = await admin.from('user_roles').upsert(
    { user_id: uid, role: 'admin' },
    { onConflict: 'user_id,role' }
  );
  if (roleErr) console.error('role err', u.email, roleErr.message);
  else console.log(`  role=admin assigned`);
}
