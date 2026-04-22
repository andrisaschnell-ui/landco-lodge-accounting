import { supabase } from "@/integrations/supabase/client";
import type { ParsedSalaryResult } from "./parsers/salaryParser";
import type { ParsedBimResult } from "./parsers/bimTransferParser";
import type { ParsedMonthEndResult } from "./parsers/monthEndParser";
import type { ParsedBdoResult } from "./parsers/bdoBankParser";
import type { ParsedPettyCashResult } from "./parsers/pettyCashParser";
import type { ParsedExpensesResult } from "./parsers/expensesParser";
import type { ParsedInvoicesResult } from "./parsers/invoicesParser";

// Properties we never write expenses against (excluded by business rule).
const EXCLUDED_PROPERTY_CODES = new Set(["NEGU"]);


async function getEmployeeMap(): Promise<Map<string, string>> {
  const { data } = await supabase.from("employees").select("id, name");
  const map = new Map<string, string>();
  data?.forEach((e) => map.set(e.name.toUpperCase(), e.id));
  return map;
}

async function getPropertyMap(): Promise<Map<string, string>> {
  const { data } = await supabase.from("properties").select("id, code");
  const map = new Map<string, string>();
  data?.forEach((p) => {
    if (EXCLUDED_PROPERTY_CODES.has(p.code)) return;
    map.set(p.code, p.id);
  });
  return map;
}

async function getCategoryMap(): Promise<Map<string, string>> {
  const { data } = await supabase.from("expense_categories").select("id, name");
  const map = new Map<string, string>();
  data?.forEach((c) => map.set(c.name.toUpperCase(), c.id));
  return map;
}

async function getBankAccountMap(): Promise<Map<string, string>> {
  const { data } = await supabase.from("bank_accounts").select("id, name");
  const map = new Map<string, string>();
  data?.forEach((b) => map.set(b.name.toUpperCase(), b.id));
  return map;
}

export async function importSalary(result: ParsedSalaryResult, filename: string) {
  const empMap = await getEmployeeMap();

  // Create salary run
  const { data: run, error: runErr } = await supabase
    .from("salary_runs")
    .insert({ month: result.month, year: result.year, status: "imported" })
    .select("id")
    .single();
  if (runErr) throw runErr;

  // Track unmatched employees for debugging
  const unmatched: string[] = [];

  const salaryLines = result.lines.map((l) => {
    const empId = empMap.get(l.employee_name.toUpperCase());
    if (!empId) unmatched.push(l.employee_name);
    return {
      salary_run_id: run.id,
      employee_id: empId || null,
      base_salary: l.base_salary,
      food_allowance: l.food_allowance,
      back_payment: l.back_payment,
      days_worked: l.days_worked,
      monthly_salary: l.monthly_salary,
      nightshift_hours: l.nightshift_hours,
      guardas_25: l.guardas_25,
      overtime_15x_hours: l.overtime_15x_hours,
      overtime_15x_amount: l.overtime_15x_amount,
      overtime_2x_hours: l.overtime_2x_hours,
      overtime_2x_amount: l.overtime_2x_amount,
      gratification: l.gratification,
      holiday_days: l.holiday_days,
      holiday_amount: l.holiday_amount,
      gross_total: l.gross_total,
      advance: l.advance,
      irps: l.irps,
      debt: l.debt,
      inss_employee: l.inss_employee,
      sind: l.sind,
      total_deductions: l.total_deductions,
      net_salary: l.net_salary,
      nib: l.nib,
      category: l.category,
    };
  }).filter((l) => l.employee_id);

  if (unmatched.length > 0) {
    console.warn(`Salary import: ${unmatched.length} employees not matched:`, unmatched);
  }

  const { error } = await supabase.from("salary_lines").insert(salaryLines);
  if (error) throw error;

  // Update run totals
  const totals = {
    total_gross: salaryLines.reduce((s, l) => s + (l.gross_total || 0), 0),
    total_net: salaryLines.reduce((s, l) => s + (l.net_salary || 0), 0),
    total_irps: salaryLines.reduce((s, l) => s + (l.irps || 0), 0),
    total_inss_employee: salaryLines.reduce((s, l) => s + (l.inss_employee || 0), 0),
  };
  await supabase.from("salary_runs").update(totals).eq("id", run.id);

  await logImport(filename, "salary", result.month, result.year, salaryLines.length);
  return { imported: salaryLines.length, unmatched };
}

export async function importBimTransfers(result: ParsedBimResult, filename: string) {
  const empMap = await getEmployeeMap();

  const transfers = result.transfers.map((t) => ({
    name: t.name,
    nib: t.nib,
    amount: t.amount,
    description: t.description,
    month: result.month,
    year: result.year,
    employee_id: empMap.get(t.name.toUpperCase()) || null,
  }));

  const { error } = await supabase.from("bim_salary_transfers").insert(transfers);
  if (error) throw error;

  await logImport(filename, "bim_transfer", result.month, result.year, transfers.length);
  return transfers.length;
}

export async function importMonthEnd(result: ParsedMonthEndResult, filename: string) {
  const propMap = await getPropertyMap();
  let count = 0;

  // Import income
  if (result.income.length > 0) {
    const incRows = result.income.map((i) => ({
      date: i.date || `${result.year}-${String(result.month).padStart(2, "0")}-01`,
      property_id: propMap.get(i.house) || null,
      guest_name: i.guest_name,
      accommodation_amount_mzn: i.accommodation_amount_mzn,
      amount_usd: i.amount_usd,
      description: i.description,
      month: result.month,
      year: result.year,
    }));
    const { error } = await supabase.from("income_transactions").insert(incRows);
    if (error) throw error;
    count += incRows.length;
  }

  // Import expenses
  if (result.expenses.length > 0) {
    const catMap = await getCategoryMap();
    const expRows = result.expenses.map((e) => ({
      date: e.date || `${result.year}-${String(result.month).padStart(2, "0")}-01`,
      description: e.description,
      amount_mzn: e.amount_mzn,
      is_shared: e.is_shared,
      month: result.month,
      year: result.year,
      category_id: catMap.get(e.category.toUpperCase()) || null,
    }));
    const { error } = await supabase.from("expense_transactions").insert(expRows);
    if (error) throw error;
    count += expRows.length;
  }

  await logImport(filename, "month_end", result.month, result.year, count);
  return count;
}

/**
 * Import BIM Bank Control sheets (MZN + USD).
 * - Each transaction links to the matching bank account by currency.
 * - Re-importing the same month wipes prior bank rows for those BIM accounts.
 */
export async function importBdoBank(result: ParsedBdoResult, filename: string) {
  const bankMap = await getBankAccountMap();
  const bimMzn = bankMap.get("BIM MZN") || null;
  const bimUsd = bankMap.get("BIM USD") || null;

  // Idempotency: clear prior month rows for BIM accounts only.
  const bimIds = [bimMzn, bimUsd].filter(Boolean) as string[];
  if (bimIds.length) {
    await supabase
      .from("bank_transactions")
      .delete()
      .eq("month", result.month)
      .eq("year", result.year)
      .in("bank_account_id", bimIds);
  }

  const rows = result.transactions.map((t) => ({
    date: t.date || null,
    description: t.description,
    reference: t.reference,
    debit: t.debit,
    credit: t.credit,
    balance: t.balance,
    bank_account_id: t.currency === "USD" ? bimUsd : bimMzn,
    month: result.month,
    year: result.year,
  }));

  if (rows.length > 0) {
    const { error } = await supabase.from("bank_transactions").insert(rows);
    if (error) throw error;
  }

  await logImport(filename, "bdo_bank", result.month, result.year, rows.length);
  return rows.length;
}

/**
 * Import Petty Cash + Pre-paid sheets — both treated as suspense payments
 * (no actual outgoing payment to a third party yet). Full row context
 * (supplier, allocation, ref, source sheet) is preserved for the
 * Suspense Review screen.
 */
export async function importPettyCash(results: ParsedPettyCashResult[], filename: string) {
  // Idempotency: wipe prior month rows for these source files.
  const m0 = results[0]?.month;
  const y0 = results[0]?.year;
  if (m0 && y0) {
    await supabase
      .from("petty_cash_transactions")
      .delete()
      .eq("month", m0)
      .eq("year", y0);
  }

  let total = 0;
  for (const result of results) {
    const rows = result.transactions.map((t) => ({
      date: t.date || null,
      description: t.description,
      reference: t.ref || null,
      supplier: t.supplier || null,
      allocation: t.allocation || null,
      credit: t.credit,
      debit: t.debit,
      balance: t.balance,
      month: result.month,
      year: result.year,
      source_file: result.sheetName,
    }));

    if (rows.length > 0) {
      const { error } = await supabase.from("petty_cash_transactions").insert(rows);
      if (error) throw error;
      total += rows.length;
    }
  }

  const m = results[0]?.month || 1;
  const y = results[0]?.year || 2026;
  await logImport(filename, "petty_cash", m, y, total);
  return total;
}

/**
 * Import the "Invoices" sheet of the BDO Bank Control workbook.
 * - Creates one `invoices` row per line (status = 'imported').
 * - Creates one journal entry per line: Dr 11 Debtors / Cr 71 Sales + Cr 4432 IVA.
 *   The exact accounts are looked up by code; if not found, the JE is skipped
 *   but the invoice row is still saved.
 * - Idempotent: deletes prior rows for the same month/year before re-importing.
 */
export async function importInvoices(result: ParsedInvoicesResult, filename: string) {
  const monthStart = `${result.year}-${String(result.month).padStart(2, "0")}-01`;
  const nextMonth = result.month === 12 ? 1 : result.month + 1;
  const nextYear = result.month === 12 ? result.year + 1 : result.year;
  const monthEndExclusive = `${nextYear}-${String(nextMonth).padStart(2, "0")}-01`;

  // Idempotency: clear prior imported invoices + their JEs for this month.
  const { data: priorInvs } = await supabase
    .from("invoices")
    .select("id, journal_entry_id")
    .gte("invoice_date", monthStart)
    .lt("invoice_date", monthEndExclusive)
    .eq("status", "imported");
  const priorJeIds = (priorInvs ?? [])
    .map((i: { journal_entry_id: string | null }) => i.journal_entry_id)
    .filter(Boolean) as string[];
  const priorInvIds = (priorInvs ?? []).map((i: { id: string }) => i.id);

  if (priorInvIds.length) {
    await supabase.from("invoices").delete().in("id", priorInvIds);
  }
  if (priorJeIds.length) {
    await supabase.from("journal_lines").delete().in("journal_entry_id", priorJeIds);
    await supabase.from("journal_entries").delete().in("id", priorJeIds);
  }

  if (result.invoices.length === 0) {
    await logImport(filename, "invoices", result.month, result.year, 0);
    return 0;
  }

  // Look up posting accounts (best effort).
  const accountIdByCode = await getAccountIdMap(["11", "71", "4432"]);
  const debtorsId = accountIdByCode.get("11");
  const salesId = accountIdByCode.get("71");
  const ivaId = accountIdByCode.get("4432");

  let inserted = 0;
  for (const inv of result.invoices) {
    let jeId: string | null = null;

    // Create a JE only if posting accounts exist.
    if (debtorsId && salesId) {
      const { data: je } = await supabase
        .from("journal_entries")
        .insert({
          entry_date: inv.date,
          description: `Invoice ${inv.invoice_no || ""} — ${inv.description}`.slice(0, 255),
          entry_type: "sales_invoice",
          reference: filename,
          posted: false,
        })
        .select("id")
        .single();
      jeId = je?.id ?? null;

      if (jeId) {
        const jLines = [
          { journal_entry_id: jeId, account_id: debtorsId, debit: inv.total_mzn, credit: 0, memo: inv.description },
          { journal_entry_id: jeId, account_id: salesId, debit: 0, credit: inv.amount_excl_mzn, memo: "Sales" },
        ];
        if (inv.iva_mzn > 0 && ivaId) {
          jLines.push({ journal_entry_id: jeId, account_id: ivaId, debit: 0, credit: inv.iva_mzn, memo: "IVA 16%" });
        } else if (inv.iva_mzn > 0) {
          // No IVA account → roll IVA into sales line so the JE balances.
          jLines[1] = { ...jLines[1], credit: inv.amount_excl_mzn + inv.iva_mzn };
        }
        await supabase.from("journal_lines").insert(jLines);
      }
    }

    await supabase.from("invoices").insert({
      invoice_number: inv.invoice_no
        ? `IMP ${result.year}/${inv.invoice_no}`
        : `IMP ${result.year}/${result.month}-${inserted + 1}`,
      invoice_series: "IMP",
      invoice_date: inv.date,
      client_name: inv.description.slice(0, 200) || "—",
      line_items: [{
        description: inv.description,
        qty: 1,
        unit: inv.amount_excl_mzn,
        vat_rate: inv.amount_excl_mzn ? inv.iva_mzn / inv.amount_excl_mzn : 0,
        amount: inv.total_mzn,
      }],
      subtotal_mzn: inv.amount_excl_mzn,
      vat_amount_mzn: inv.iva_mzn,
      total_mzn: inv.total_mzn,
      currency: "MZN",
      status: "imported",
      journal_entry_id: jeId,
    });
    inserted += 1;
  }

  await logImport(filename, "invoices", result.month, result.year, inserted);
  return inserted;
}

async function logImport(filename: string, fileType: string, month: number, year: number, recordsImported: number) {
  const { data: { user } } = await supabase.auth.getUser();
  await supabase.from("import_log").insert({
    filename,
    file_type: fileType,
    month,
    year,
    records_imported: recordsImported,
    status: "success",
    imported_by: user?.id || null,
  });
}

// Ensure each category in the parsed file exists in expense_categories;
// returns name → id map.
async function ensureCategories(names: string[]): Promise<Map<string, string>> {
  const unique = Array.from(new Set(names.filter(Boolean)));
  const { data: existing } = await supabase
    .from("expense_categories")
    .select("id, name");
  const map = new Map<string, string>();
  existing?.forEach((c) => map.set(c.name.toUpperCase(), c.id));

  const missing = unique.filter((n) => !map.has(n.toUpperCase()));
  if (missing.length > 0) {
    const { data: inserted, error } = await supabase
      .from("expense_categories")
      .insert(missing.map((name) => ({ name, is_shared: true })))
      .select("id, name");
    if (error) throw error;
    inserted?.forEach((c) => map.set(c.name.toUpperCase(), c.id));
  }
  return map;
}

// Resolve account UUIDs by code (e.g. '262', '221', '6111').
async function getAccountIdMap(codes: string[]): Promise<Map<string, string>> {
  const unique = Array.from(new Set(codes.filter(Boolean)));
  const { data } = await supabase.from("accounts").select("id, code").in("code", unique);
  const map = new Map<string, string>();
  data?.forEach((a: { id: string; code: string }) => map.set(a.code, a.id));
  return map;
}

// Get-or-create supplier by name (case-insensitive).
async function ensureSuppliers(names: string[]): Promise<Map<string, string>> {
  const unique = Array.from(new Set(names.map((n) => n.trim()).filter(Boolean)));
  const { data: existing } = await supabase.from("suppliers").select("id, name");
  const map = new Map<string, string>();
  existing?.forEach((s: { id: string; name: string }) => map.set(s.name.toUpperCase(), s.id));
  const missing = unique.filter((n) => !map.has(n.toUpperCase()));
  if (missing.length > 0) {
    const { data: inserted, error } = await supabase
      .from("suppliers")
      .insert(missing.map((name) => ({ name })))
      .select("id, name");
    if (error) throw error;
    inserted?.forEach((s: { id: string; name: string }) => map.set(s.name.toUpperCase(), s.id));
  }
  return map;
}

/**
 * Import EXPENSES sheet:
 *  1. Group lines by (supplier, date) → one supplier_invoice + one journal_entry per group.
 *  2. JE posts Dr <category PGC code> / Cr 262 Suspense (per user choice — to be reassigned later).
 *  3. Each expense_transaction row is linked back to its journal_entry.
 */
export async function importExpenses(result: ParsedExpensesResult, filename: string) {
  const propMap = await getPropertyMap();
  const catMap = await ensureCategories(result.lines.map((l) => l.category));

  // Idempotency: wipe any prior expense / supplier-invoice / JE rows for the same month
  // so re-uploading the same workbook cleanly replaces the data.
  const monthStart = `${result.year}-${String(result.month).padStart(2, "0")}-01`;
  const nextMonth = result.month === 12 ? 1 : result.month + 1;
  const nextYear = result.month === 12 ? result.year + 1 : result.year;
  const monthEndExclusive = `${nextYear}-${String(nextMonth).padStart(2, "0")}-01`;

  const { data: priorJEs } = await supabase
    .from("journal_entries")
    .select("id")
    .eq("entry_type", "supplier_invoice")
    .gte("entry_date", monthStart)
    .lt("entry_date", monthEndExclusive);
  const priorJeIds = (priorJEs ?? []).map((j: { id: string }) => j.id);

  await supabase.from("expense_transactions").delete().eq("month", result.month).eq("year", result.year);
  if (priorJeIds.length) {
    await supabase.from("supplier_invoices").delete().in("journal_entry_id", priorJeIds);
    await supabase.from("journal_lines").delete().in("journal_entry_id", priorJeIds);
    await supabase.from("journal_entries").delete().in("id", priorJeIds);
  }

  if (result.lines.length === 0) {
    await logImport(filename, "expenses", result.month, result.year, 0);
    return 0;
  }

  // Pull category → pgc_account_code map so JE lines can hit the right Dr account.
  const { data: catRows } = await supabase
    .from("expense_categories")
    .select("id, name, pgc_account_code");
  const catCodeById = new Map<string, string | null>();
  catRows?.forEach((c: { id: string; pgc_account_code: string | null }) =>
    catCodeById.set(c.id, c.pgc_account_code),
  );

  // Resolve all needed account UUIDs (262 suspense + every category Dr code).
  const wantedCodes = new Set<string>(["262"]);
  catRows?.forEach((c: { pgc_account_code: string | null }) => {
    if (c.pgc_account_code) wantedCodes.add(c.pgc_account_code);
  });
  const accountIdByCode = await getAccountIdMap(Array.from(wantedCodes));
  const suspenseAccountId = accountIdByCode.get("262");
  if (!suspenseAccountId) {
    throw new Error("Suspense account (code 262) not found in chart of accounts.");
  }

  // Suppliers — group by supplier name (blank → "UNKNOWN SUPPLIER").
  const suppliersForLookup = result.lines.map((l) => l.supplier?.trim() || "UNKNOWN SUPPLIER");
  const supplierMap = await ensureSuppliers(suppliersForLookup);

  // Group lines: key = supplier|date  → one JE + one supplier_invoice.
  type GroupKey = string;
  const groups = new Map<GroupKey, typeof result.lines>();
  for (const l of result.lines) {
    const supplier = (l.supplier?.trim() || "UNKNOWN SUPPLIER").toUpperCase();
    const date = l.date || `${result.year}-${String(result.month).padStart(2, "0")}-01`;
    const key = `${supplier}|${date}`;
    if (!groups.has(key)) groups.set(key, []);
    groups.get(key)!.push(l);
  }

  let inserted = 0;

  for (const [key, lines] of groups) {
    const [supplierUpper, date] = key.split("|");
    const supplierId = supplierMap.get(supplierUpper) ?? null;
    const total = lines.reduce((s, l) => s + (l.amount_mzn || 0), 0);
    if (total === 0) continue;

    // 1) Journal entry header.
    const { data: je, error: jeErr } = await supabase
      .from("journal_entries")
      .insert({
        entry_date: date,
        description: `Supplier invoice — ${supplierUpper} (${result.month}/${result.year})`,
        entry_type: "supplier_invoice",
        reference: filename,
        posted: false,
      })
      .select("id")
      .single();
    if (jeErr) throw jeErr;

    // 2) Journal lines: one Dr per line, one consolidated Cr Suspense.
    const jLines: Array<{ journal_entry_id: string; account_id: string; debit: number; credit: number; memo: string | null }> = [];
    for (const l of lines) {
      const catId = catMap.get(l.category.toUpperCase());
      const code = catId ? catCodeById.get(catId) : null;
      const drAccountId = code ? accountIdByCode.get(code) : null;
      if (!drAccountId) continue;
      // Negative amounts (refunds/corrections) flip to the credit side so DB
      // check constraints (debit >= 0, credit >= 0) stay satisfied.
      if (l.amount_mzn >= 0) {
        jLines.push({ journal_entry_id: je.id, account_id: drAccountId, debit: l.amount_mzn, credit: 0, memo: l.description });
      } else {
        jLines.push({ journal_entry_id: je.id, account_id: drAccountId, debit: 0, credit: -l.amount_mzn, memo: l.description });
      }
    }
    if (total >= 0) {
      jLines.push({ journal_entry_id: je.id, account_id: suspenseAccountId, debit: 0, credit: total, memo: `Suspense — awaiting payment account reclassification` });
    } else {
      jLines.push({ journal_entry_id: je.id, account_id: suspenseAccountId, debit: -total, credit: 0, memo: `Suspense reversal` });
    }
    if (jLines.length > 1) {
      const { error: jlErr } = await supabase.from("journal_lines").insert(jLines);
      if (jlErr) throw jlErr;
    }

    // 3) supplier_invoice header (one per group).
    await supabase.from("supplier_invoices").insert({
      supplier_id: supplierId,
      journal_entry_id: je.id,
      invoice_date: date,
      total_amount: total,
      amount_excl: total,
      vat_amount: 0,
      description: lines.map((l) => l.description).join("; ").slice(0, 500),
      allocation: lines[0].is_shared ? "shared" : lines[0].property_code ?? null,
    });

    // 4) expense_transactions linked to this JE.
    const expRows = lines.map((l) => ({
      date,
      description: l.supplier ? `${l.supplier} — ${l.description}` : l.description,
      amount_mzn: l.amount_mzn,
      is_shared: l.is_shared,
      month: result.month,
      year: result.year,
      category_id: catMap.get(l.category.toUpperCase()) || null,
      property_id: l.property_code ? propMap.get(l.property_code) || null : null,
      journal_entry_id: je.id,
    }));
    const { error: expErr } = await supabase.from("expense_transactions").insert(expRows);
    if (expErr) throw expErr;
    inserted += expRows.length;
  }

  await logImport(filename, "expenses", result.month, result.year, inserted);
  return inserted;
}

