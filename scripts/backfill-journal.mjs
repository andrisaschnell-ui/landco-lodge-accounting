#!/usr/bin/env node
// Release 1 — Step 2: Backfill missing journal entries.
//
// Iterates every income / expense / bank / petty_cash / salary_run row that
// has journal_entry_id IS NULL and posts a balanced entry for it using the
// shared helpers in api/lib/autoPost.js.
//
// Modes:
//   LOCAL  — uses DATABASE_URL (or PGHOST/PGUSER/...). Run inside Docker:
//              docker exec -it lanacc-api node /app/scripts/backfill-journal.mjs
//   CLOUD  — set SUPABASE_DB_URL=postgres://... and run:
//              SUPABASE_DB_URL=... node scripts/backfill-journal.mjs
//
// Idempotent: rows with a non-null journal_entry_id are skipped.

import pkg from 'pg';
import {
  postIncome, postExpense, postBank, postPettyCash, postPayroll,
  linkSourceToEntry,
} from '../lib/autoPost.js';

const { Pool } = pkg;

const connectionString =
  process.env.SUPABASE_DB_URL ||
  process.env.DATABASE_URL ||
  null;

const pool = new Pool(connectionString ? { connectionString } : {});

const TARGETS = [
  { table: 'income_transactions',     poster: postIncome,    label: 'Income'      },
  { table: 'expense_transactions',    poster: postExpense,   label: 'Expense'     },
  { table: 'bank_transactions',       poster: postBank,      label: 'Bank'        },
  { table: 'petty_cash_transactions', poster: postPettyCash, label: 'Petty cash'  },
  { table: 'salary_runs',             poster: postPayroll,   label: 'Payroll run' },
];

async function backfill(t) {
  const { rows } = await pool.query(
    `SELECT * FROM public.${t.table}
      WHERE journal_entry_id IS NULL
      ORDER BY created_at ASC`);

  console.log(`\n[${t.label}] ${rows.length} unposted rows`);
  let ok = 0, skip = 0, fail = 0;

  for (const row of rows) {
    const client = await pool.connect();
    try {
      await client.query('BEGIN');
      const entryId = await t.poster(client, row, {});
      if (!entryId) { skip++; await client.query('ROLLBACK'); continue; }
      await linkSourceToEntry(client, t.table, row.id, entryId);
      await client.query('COMMIT');
      ok++;
    } catch (e) {
      await client.query('ROLLBACK').catch(() => {});
      fail++;
      console.error(`  ✗ ${t.table} ${row.id}: ${e.message}`);
    } finally {
      client.release();
    }
  }
  console.log(`  ✓ posted=${ok}  skipped=${skip}  failed=${fail}`);
  return { ok, skip, fail };
}

(async () => {
  console.log('LANACC — backfill journal entries');
  console.log('DB target:', connectionString ? 'override URL' : 'PG* env vars');

  let total = { ok: 0, skip: 0, fail: 0 };
  for (const t of TARGETS) {
    const r = await backfill(t);
    total.ok += r.ok; total.skip += r.skip; total.fail += r.fail;
  }

  console.log('\n=== TOTAL ===');
  console.log(`  posted=${total.ok}  skipped=${total.skip}  failed=${total.fail}`);
  console.log('Failed rows usually mean missing PGC code mapping (see Suspense 2999).');
  await pool.end();
  process.exit(total.fail > 0 ? 1 : 0);
})().catch(e => { console.error(e); process.exit(2); });
