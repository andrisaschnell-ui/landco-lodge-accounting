import { createClient } from '@supabase/supabase-js';
import * as XLSX from 'xlsx';
import { readFileSync } from 'node:fs';

const url = process.env.VITE_SUPABASE_URL;
const key = process.env.SUPABASE_SERVICE_ROLE_KEY;
const supabase = createClient(url, key);

// --- inline copy of parser rules (kept in sync with src/lib/parsers/expensesParser.ts) ---
const HEADER_RULES = [
  { match: /^LC SALARIES|^SALARIES\s*&\s*WAGES/i, category: 'SALARIES & WAGES', is_shared: true, property_code: null },
  { match: /CASUAL WORKERS/i, category: 'CASUAL WORKERS AND FOOD ALLOWANCE', is_shared: true, property_code: null },
  { match: /ADVANCE SALARIES/i, category: '', is_shared: false, property_code: null, skip: true },
  { match: /OFFICE AND BANK/i, category: 'OFFICE AND BANK CHARGES', is_shared: true, property_code: null },
  { match: /ADMIN CHARGES/i, category: 'ADMIN CHARGES (BDO & ANDRISA)', is_shared: true, property_code: null },
  { match: /GAS AND ELECTR/i, category: 'GAS AND ELECTRICITY', is_shared: true, property_code: null },
  { match: /MAINTENANCE GENERAL/i, category: 'MAINTENANCE GENERAL', is_shared: true, property_code: null },
  { match: /MAINTENANCE GARDEN/i, category: 'MAINTENANCE GARDEN & POOL', is_shared: true, property_code: null },
  { match: /SMALL TOOLS/i, category: 'SMALL TOOLS', is_shared: true, property_code: null },
  { match: /^EQUIPMENT/i, category: 'EQUIPMENT', is_shared: true, property_code: null },
  { match: /MAINTENANCE VEHICLES/i, category: 'MAINTENANCE VEHICLES', is_shared: true, property_code: null },
  { match: /INSURANCE/i, category: 'INSURANCE & LICENSE', is_shared: true, property_code: null },
  { match: /DIESEL|PETROL/i, category: 'DIESEL AND PETROL', is_shared: true, property_code: null },
  { match: /HOUSE KEEPING|HOUSEKEEPING/i, category: 'HOUSE KEEPING', is_shared: true, property_code: null },
  { match: /MUNICIPAL TAXES|IPRA|TAE|MARINTINE|MARITIME/i, category: 'MARITIME & MUNICIPAL TAXES IPRA & TAE', is_shared: true, property_code: null },
  { match: /COMMUNITY/i, category: 'COMMUNITY', is_shared: true, property_code: null },
  { match: /EXPENSES LUZ|^LUZ$/i, category: 'EXPENSES LUZ', is_shared: false, property_code: 'H1' },
  { match: /EXPENSES AURORA|^AURORA$/i, category: 'EXPENSES AURORA', is_shared: false, property_code: 'H2' },
  { match: /EXPENSES CAJU|^CAJU$/i, category: 'EXPENSES CAJU', is_shared: false, property_code: 'H3' },
  { match: /EXPENSES COCO|^COCO$/i, category: 'EXPENSES COCO', is_shared: false, property_code: 'H4' },
  { match: /SUSPEN[CS]E/i, category: 'SUSPENSE', is_shared: true, property_code: null },
  { match: /^BALANCE$/i, category: '', is_shared: false, property_code: null, skip: true },
  { match: /NEGU/i, category: '', is_shared: false, property_code: null, skip: true },
  { match: /^TOTAL$/i, category: '', is_shared: false, property_code: null, skip: true },
];

const num = (v) => { if (v == null || v === '') return 0; const n = Number(v); return isNaN(n) ? 0 : n; };
const str = (v) => v == null ? '' : String(v).trim();
const excelDateToISO = (v) => {
  if (v == null || v === '') return '';
  if (v instanceof Date) return v.toISOString().slice(0,10);
  if (typeof v === 'number') return new Date(Math.round((v - 25569) * 86400 * 1000)).toISOString().slice(0,10);
  const d = new Date(String(v));
  return isNaN(d.getTime()) ? '' : d.toISOString().slice(0,10);
};

function parseExpenses(buffer, month, year) {
  const wb = XLSX.read(buffer, { type: 'buffer', cellDates: true });
  const sheetName = wb.SheetNames.find(n => n.trim().toUpperCase() === 'EXPENSES');
  if (!sheetName) throw new Error('No EXPENSES sheet. Have: ' + wb.SheetNames.join(','));
  const aoa = XLSX.utils.sheet_to_json(wb.Sheets[sheetName], { header: 1, defval: null, raw: true });
  const HEADER_ROW = 5;
  const header = aoa[HEADER_ROW] ?? [];
  const cols = [];
  for (let i = 0; i < header.length; i++) {
    const raw = str(header[i]);
    if (!raw || i < 5) continue;
    const rule = HEADER_RULES.find(r => r.match.test(raw));
    if (!rule) continue;
    cols.push({ index: i, rawHeader: raw, category: rule.category, is_shared: rule.is_shared, property_code: rule.property_code, skip: !!rule.skip });
  }
  const lines = [];
  for (let r = HEADER_ROW + 1; r < aoa.length; r++) {
    const row = aoa[r];
    if (!row) continue;
    const dateRaw = row[0]; const supplier = str(row[1]); const description = str(row[2]);
    if (!dateRaw && !supplier && !description) continue;
    const upperDesc = description.toUpperCase();
    if (!dateRaw && !supplier && /^(TOTAL|GRAND TOTAL|SUB TOTAL|SUBTOTAL)$/.test(upperDesc)) continue;
    const date = excelDateToISO(dateRaw);
    for (const col of cols) {
      if (col.skip) continue;
      const amt = num(row[col.index]);
      if (amt === 0) continue;
      lines.push({ date, supplier, description: description || col.rawHeader, amount_mzn: amt, category: col.category, is_shared: col.is_shared, property_code: col.property_code });
    }
  }
  return { lines, month, year };
}

// --- importer (mirrors src/lib/importService.ts importExpenses) ---
async function ensureCategories(names) {
  const unique = [...new Set(names.filter(Boolean))];
  const { data: existing } = await supabase.from('expense_categories').select('id, name');
  const map = new Map();
  existing?.forEach(c => map.set(c.name.toUpperCase(), c.id));
  const missing = unique.filter(n => !map.has(n.toUpperCase()));
  if (missing.length) {
    const { data: ins, error } = await supabase.from('expense_categories').insert(missing.map(name => ({ name, is_shared: true }))).select('id, name');
    if (error) throw error;
    ins?.forEach(c => map.set(c.name.toUpperCase(), c.id));
  }
  return map;
}
async function ensureSuppliers(names) {
  const unique = [...new Set(names.map(n => n.trim()).filter(Boolean))];
  const { data: ex } = await supabase.from('suppliers').select('id, name');
  const map = new Map();
  ex?.forEach(s => map.set(s.name.toUpperCase(), s.id));
  const missing = unique.filter(n => !map.has(n.toUpperCase()));
  if (missing.length) {
    const { data: ins, error } = await supabase.from('suppliers').insert(missing.map(name => ({ name }))).select('id, name');
    if (error) throw error;
    ins?.forEach(s => map.set(s.name.toUpperCase(), s.id));
  }
  return map;
}

async function importExpenses(file, month, year) {
  const buf = readFileSync(file);
  const result = parseExpenses(buf, month, year);
  console.log(`\n=== ${file}  ${month}/${year} → ${result.lines.length} parsed lines ===`);

  // wipe prior
  const monthStart = `${year}-${String(month).padStart(2,'0')}-01`;
  const nm = month === 12 ? 1 : month + 1;
  const ny = month === 12 ? year + 1 : year;
  const monthEnd = `${ny}-${String(nm).padStart(2,'0')}-01`;
  const { data: priorJEs } = await supabase.from('journal_entries').select('id').eq('entry_type','supplier_invoice').gte('entry_date', monthStart).lt('entry_date', monthEnd);
  const ids = (priorJEs ?? []).map(j => j.id);
  await supabase.from('expense_transactions').delete().eq('month', month).eq('year', year);
  if (ids.length) {
    await supabase.from('supplier_invoices').delete().in('journal_entry_id', ids);
    await supabase.from('journal_lines').delete().in('journal_entry_id', ids);
    await supabase.from('journal_entries').delete().in('id', ids);
  }
  if (!result.lines.length) return 0;

  const { data: props } = await supabase.from('properties').select('id, code');
  const propMap = new Map(); props?.forEach(p => p.code !== 'NEGU' && propMap.set(p.code, p.id));
  const catMap = await ensureCategories(result.lines.map(l => l.category));
  const { data: catRows } = await supabase.from('expense_categories').select('id, name, pgc_account_code');
  const catCodeById = new Map(); catRows?.forEach(c => catCodeById.set(c.id, c.pgc_account_code));
  const wantedCodes = new Set(['262']); catRows?.forEach(c => c.pgc_account_code && wantedCodes.add(c.pgc_account_code));
  const { data: accs } = await supabase.from('accounts').select('id, code').in('code', [...wantedCodes]);
  const accIdByCode = new Map(); accs?.forEach(a => accIdByCode.set(a.code, a.id));
  const suspenseId = accIdByCode.get('262');
  if (!suspenseId) throw new Error('No 262 suspense account');

  const supplierMap = await ensureSuppliers(result.lines.map(l => l.supplier?.trim() || 'UNKNOWN SUPPLIER'));

  const groups = new Map();
  for (const l of result.lines) {
    const sup = (l.supplier?.trim() || 'UNKNOWN SUPPLIER').toUpperCase();
    const date = l.date || monthStart;
    const k = `${sup}|${date}`;
    if (!groups.has(k)) groups.set(k, []);
    groups.get(k).push(l);
  }

  let inserted = 0;
  for (const [key, lines] of groups) {
    const [supUpper, date] = key.split('|');
    const supplierId = supplierMap.get(supUpper) ?? null;
    const total = lines.reduce((s, l) => s + (l.amount_mzn || 0), 0);
    if (total === 0) continue;
    const { data: je, error: jeErr } = await supabase.from('journal_entries').insert({
      entry_date: date, description: `Supplier invoice — ${supUpper} (${month}/${year})`,
      entry_type: 'supplier_invoice', reference: file.split('/').pop(), posted: false,
    }).select('id').single();
    if (jeErr) throw jeErr;
    const jLines = [];
    for (const l of lines) {
      const catId = catMap.get(l.category.toUpperCase());
      const code = catId ? catCodeById.get(catId) : null;
      const drId = code ? accIdByCode.get(code) : null;
      if (!drId) continue;
      jLines.push({ journal_entry_id: je.id, account_id: drId, debit: l.amount_mzn, credit: 0, memo: l.description });
    }
    jLines.push({ journal_entry_id: je.id, account_id: suspenseId, debit: 0, credit: total, memo: 'Suspense — awaiting payment account reclassification' });
    if (jLines.length > 1) { const { error } = await supabase.from('journal_lines').insert(jLines); if (error) throw error; }
    await supabase.from('supplier_invoices').insert({
      supplier_id: supplierId, journal_entry_id: je.id, invoice_date: date,
      total_amount: total, amount_excl: total, vat_amount: 0,
      description: lines.map(l => l.description).join('; ').slice(0, 500),
      allocation: lines[0].is_shared ? 'shared' : (lines[0].property_code ?? null),
    });
    const expRows = lines.map(l => ({
      date, description: l.supplier ? `${l.supplier} — ${l.description}` : l.description,
      amount_mzn: l.amount_mzn, is_shared: l.is_shared, month, year,
      category_id: catMap.get(l.category.toUpperCase()) || null,
      property_id: l.property_code ? propMap.get(l.property_code) || null : null,
      journal_entry_id: je.id,
    }));
    const { error } = await supabase.from('expense_transactions').insert(expRows);
    if (error) throw error;
    inserted += expRows.length;
  }
  console.log(`  → ${groups.size} JEs / supplier invoices, ${inserted} expense_transactions`);
  return inserted;
}

await importExpenses('/tmp/jan26.xlsx', 1, 2026);
await importExpenses('/tmp/feb26.xlsx', 2, 2026);
await importExpenses('/tmp/mar26.xlsx', 3, 2026);
console.log('\nDone.');
