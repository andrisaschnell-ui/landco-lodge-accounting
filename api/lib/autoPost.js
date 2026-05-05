// Shared double-entry posting helpers.
// Used by:
//   - api/server.js          (synchronous auto-post on row insert)
//   - api/routes/journal.js  (manual posting endpoints)
//   - scripts/backfill-journal.mjs (one-shot backfill of unposted rows)
//
// Every helper takes a `pg` Client (NOT pool) that is already inside a
// transaction, so the parent transaction can roll back if posting fails.
// The DB-level balance trigger is DEFERRABLE so we insert the entry first,
// then both lines, and the check fires at COMMIT.

const SUSPENSE_CODE   = '2999';   // unmapped fall-back
const PETTY_CASH_CODE = '1111';   // default cash-on-hand
const REVENUE_CODE    = '7111';   // default accommodation income

// ----- helpers -----------------------------------------------------------

async function accountIdByCode(client, code) {
  if (!code) return null;
  const { rows } = await client.query(
    'SELECT id FROM public.accounts WHERE code = $1 LIMIT 1', [code]);
  return rows[0]?.id || null;
}

async function resolveAccount(client, preferredCode, fallbackCode = SUSPENSE_CODE) {
  return (await accountIdByCode(client, preferredCode))
      || (await accountIdByCode(client, fallbackCode))
      || (await accountIdByCode(client, SUSPENSE_CODE));
}

async function insertEntry(client, e) {
  const { rows } = await client.query(`
    INSERT INTO public.journal_entries
      (entry_date, description, entry_type, reference,
       property_id, source_table, source_id,
       posted, posted_at, created_by)
    VALUES ($1,$2,$3,$4,$5,$6,$7,true,now(),$8)
    RETURNING id`,
    [e.entry_date, e.description, e.entry_type, e.reference || null,
     e.property_id || null, e.source_table, e.source_id,
     e.created_by || null]);
  return rows[0].id;
}

async function insertLines(client, entryId, lines) {
  for (const l of lines) {
    await client.query(`
      INSERT INTO public.journal_lines
        (journal_entry_id, account_id, debit, credit, memo)
      VALUES ($1,$2,$3,$4,$5)`,
      [entryId, l.account_id, l.debit || 0, l.credit || 0, l.memo || null]);
  }
}

// ----- per-source posters ------------------------------------------------

// INCOME: Dr Cash 1111 / Cr Revenue 7111 (or property-specific revenue if set)
export async function postIncome(client, row, opts = {}) {
  const total = Number(row.accommodation_amount_mzn || 0);
  if (!total) return null;

  const cashId    = await resolveAccount(client, PETTY_CASH_CODE);
  const revenueId = await resolveAccount(client, REVENUE_CODE);

  const entryId = await insertEntry(client, {
    entry_date:   row.date || (row.year ? `${row.year}-${String(row.month).padStart(2, '0')}-01` : new Date().toISOString().split('T')[0]),
    description:  row.description || `Income: ${row.guest_name || 'Guest'}`.trim(),
    entry_type:   'income',
    reference:    row.id,
    property_id:  row.property_id,
    source_table: 'income_transactions',
    source_id:    row.id,
    created_by:   opts.userId,
  });

  await insertLines(client, entryId, [
    { account_id: cashId,    debit: total, credit: 0,     memo: 'Cash received' },
    { account_id: revenueId, debit: 0,     credit: total, memo: 'Accommodation income' },
  ]);
  return entryId;
}

// LANDCO_INCOME: Dr Cash 1111 / Cr Revenue 7111
export async function postLandcoIncome(client, row, opts = {}) {
  const total = Number(row.total_mzn || 0);
  if (!total) return null;

  const cashId    = await resolveAccount(client, PETTY_CASH_CODE);
  const revenueId = await resolveAccount(client, REVENUE_CODE);

  const entryId = await insertEntry(client, {
    entry_date:   row.transaction_date,
    description:  row.description,
    entry_type:   'income',
    reference:    row.source_file,
    property_id:  row.property_id,
    source_table: 'landco_income',
    source_id:    row.id,
    created_by:   opts.userId,
  });

  await insertLines(client, entryId, [
    { account_id: cashId,    debit: total, credit: 0,     memo: row.description },
    { account_id: revenueId, debit: 0,     credit: total, memo: 'Lodge Income' },
  ]);
  return entryId;
}

// EXPENSE: Dr <category account> / Cr Cash 1111
export async function postExpense(client, row, opts = {}) {
  const total = Number(row.amount_mzn || 0);
  if (!total) return null;

  let expCode = null;
  if (row.category_id) {
    const { rows } = await client.query(
      'SELECT pgc_account_code FROM public.expense_categories WHERE id = $1',
      [row.category_id]);
    expCode = rows[0]?.pgc_account_code || null;
  }
  const expId  = await resolveAccount(client, expCode);
  const cashId = await resolveAccount(client, PETTY_CASH_CODE);

  const entryId = await insertEntry(client, {
    entry_date:   row.date || (row.year ? `${row.year}-${String(row.month).padStart(2, '0')}-01` : new Date().toISOString().split('T')[0]),
    description:  row.description,
    entry_type:   'expense',
    reference:    row.id,
    property_id:  row.property_id,
    source_table: 'expense_transactions',
    source_id:    row.id,
    created_by:   opts.userId,
  });

  await insertLines(client, entryId, [
    { account_id: expId,  debit: total, credit: 0,     memo: row.description },
    { account_id: cashId, debit: 0,     credit: total, memo: 'Paid' },
  ]);
  return entryId;
}

// BANK: Dr/Cr Bank vs suspense (until counterparty mapping arrives in Release 2)
export async function postBank(client, row, opts = {}) {
  const debit  = Number(row.debit  || 0);
  const credit = Number(row.credit || 0);
  if (!debit && !credit) return null;
  const amt = debit || credit;

  let bankCode = null;
  if (row.bank_account_id) {
    const { rows } = await client.query(
      'SELECT pgc_account_code FROM public.bank_accounts WHERE id = $1',
      [row.bank_account_id]);
    bankCode = rows[0]?.pgc_account_code || null;
  }
  const bankId     = await resolveAccount(client, bankCode);
  const suspenseId = await resolveAccount(client, SUSPENSE_CODE);

  const entryId = await insertEntry(client, {
    entry_date:   row.date || (row.year ? `${row.year}-${String(row.month).padStart(2, '0')}-01` : new Date().toISOString().split('T')[0]),
    description:  row.description,
    entry_type:   'bank',
    reference:    row.reference || row.id,
    source_table: 'bank_transactions',
    source_id:    row.id,
    created_by:   opts.userId,
  });

  await insertLines(client, entryId, [
    { account_id: debit ? bankId : suspenseId, debit: amt, credit: 0,   memo: row.description },
    { account_id: debit ? suspenseId : bankId, debit: 0,   credit: amt, memo: row.description },
  ]);
  return entryId;
}

// PETTY CASH: Dr/Cr Cash vs suspense
export async function postPettyCash(client, row, opts = {}) {
  const debit  = Number(row.debit  || 0);
  const credit = Number(row.credit || 0);
  if (!debit && !credit) return null;
  const amt = debit || credit;

  const cashId     = await resolveAccount(client, PETTY_CASH_CODE);
  const suspenseId = await resolveAccount(client, SUSPENSE_CODE);

  const entryId = await insertEntry(client, {
    entry_date:   row.date || (row.year ? `${row.year}-${String(row.month).padStart(2, '0')}-01` : new Date().toISOString().split('T')[0]),
    description:  row.description,
    entry_type:   'petty_cash',
    reference:    row.reference || row.id,
    source_table: 'petty_cash_transactions',
    source_id:    row.id,
    created_by:   opts.userId,
  });

  await insertLines(client, entryId, [
    { account_id: debit ? cashId : suspenseId, debit: amt, credit: 0,   memo: row.description },
    { account_id: debit ? suspenseId : cashId, debit: 0,   credit: amt, memo: row.description },
  ]);
  return entryId;
}

// PAYROLL (salary_runs): aggregated entry per run.
//   Dr  6311 Salaries gross     (total_gross)
//   Cr  2451 INSS payable        (total_inss_employee + total_inss_employer)
//   Cr  2452 IRPS payable        (total_irps)
//   Cr  6312 INSS employer expense -- inverse: actually Dr employer + Cr payable
// To keep it simple and balanced we book:
//   Dr Salaries gross (gross)
//   Dr INSS employer expense (inss employer)
//   Cr Net pay payable (net)
//   Cr INSS payable (inss employee + inss employer)
//   Cr IRPS payable (irps)
export async function postPayroll(client, run, opts = {}) {
  const gross = Number(run.total_gross || 0);
  const net   = Number(run.total_net   || 0);
  const inssE = Number(run.total_inss_employee || 0);
  const inssR = Number(run.total_inss_employer || 0);
  const irps  = Number(run.total_irps  || 0);
  if (!gross && !net) return null;

  const ids = {
    salaryExp: await resolveAccount(client, '6311'),
    inssExp:   await resolveAccount(client, '6312'),
    netPay:    await resolveAccount(client, '2511'),
    inssPay:   await resolveAccount(client, '2451'),
    irpsPay:   await resolveAccount(client, '2452'),
  };

  const entryDate = `${run.year}-${String(run.month).padStart(2, '0')}-28`;

  const entryId = await insertEntry(client, {
    entry_date:   entryDate,
    description:  `Payroll ${run.year}-${String(run.month).padStart(2,'0')}`,
    entry_type:   'payroll',
    reference:    run.id,
    source_table: 'salary_runs',
    source_id:    run.id,
    created_by:   opts.userId,
  });

  await insertLines(client, entryId, [
    { account_id: ids.salaryExp, debit: gross, credit: 0,           memo: 'Salaries gross' },
    { account_id: ids.inssExp,   debit: inssR, credit: 0,           memo: 'INSS employer 4%' },
    { account_id: ids.netPay,    debit: 0,     credit: net,         memo: 'Net pay payable' },
    { account_id: ids.inssPay,   debit: 0,     credit: inssE+inssR, memo: 'INSS payable' },
    { account_id: ids.irpsPay,   debit: 0,     credit: irps,        memo: 'IRPS payable' },
  ]);
  return entryId;
}

// ----- dispatcher --------------------------------------------------------

export const POSTERS = {
  income_transactions:      postIncome,
  expense_transactions:     postExpense,
  bank_transactions:        postBank,
  petty_cash_transactions:  postPettyCash,
  salary_runs:              postPayroll,
  landco_income:            postLandcoIncome,
};

// Update the source row's journal_entry_id back-reference.
export async function linkSourceToEntry(client, sourceTable, sourceId, entryId) {
  if (!entryId) return;
  await client.query(
    `UPDATE public.${sourceTable} SET journal_entry_id = $1 WHERE id = $2`,
    [entryId, sourceId]);
}

export const SUSPENSE_ACCOUNT_CODE = SUSPENSE_CODE;
