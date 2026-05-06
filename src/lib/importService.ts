import { db } from "@/lib/db";
import type { ParsedSalaryResult } from "./parsers/salaryParser";
import type { ParsedBimResult } from "./parsers/bimTransferParser";
import type { ParsedMonthEndResult } from "./parsers/monthEndParser";
import type { ParsedBdoResult } from "./parsers/bdoBankParser";
import type { ParsedPettyCashResult } from "./parsers/pettyCashParser";
import type { ParsedExpensesResult } from "./parsers/expensesParser";
import type { ParsedInvoicesResult } from "./parsers/invoicesParser";
import type { ParsedLandcoIncomeResult } from "./parsers/landcoIncomeParser";
import type { ParsedShareholderResult } from "./parsers/shareholderParser";
import { supabase } from "@/integrations/supabase/client";

// Properties we never write expenses against (excluded by business rule).
const EXCLUDED_PROPERTY_CODES = new Set(["NEGU"]);

interface EmployeeRecord {
  id: string;
  name: string;
  nuit: string | null;
  engagement_date: string | null;
  discharge_date: string | null;
  category: string | null;
}

async function getEmployeeData(): Promise<{ byName: Map<string, EmployeeRecord>, byNuit: Map<string, EmployeeRecord> }> {
  const { data } = await db.from("employees").select("id, name, nuit, engagement_date, discharge_date, category");
  const byName = new Map<string, EmployeeRecord>();
  const byNuit = new Map<string, EmployeeRecord>();
  
  data?.forEach((e) => {
    const record = { ...e };
    byName.set(e.name.toUpperCase(), record);
    if (e.nuit) byNuit.set(String(e.nuit).trim(), record);
  });
  return { byName, byNuit };
}

async function getEmployeeMap(): Promise<Map<string, string>> {
  const { byName } = await getEmployeeData();
  const map = new Map<string, string>();
  byName.forEach((v, k) => map.set(k, v.id));
  return map;
}

async function getPropertyMap(): Promise<Map<string, string>> {
  const { data } = await db.from("properties").select("id, code");
  const map = new Map<string, string>();
  data?.forEach((p) => {
    if (EXCLUDED_PROPERTY_CODES.has(p.code)) return;
    map.set(p.code, p.id);
  });
  return map;
}

async function getCategoryMap(): Promise<Map<string, string>> {
  const { data } = await db.from("expense_categories").select("id, name");
  const map = new Map<string, string>();
  data?.forEach((c) => map.set(c.name.toUpperCase(), c.id));
  return map;
}

async function getShareholderMap(): Promise<Map<string, string>> {
  const { data } = await db.from("shareholders").select("id, property_code");
  const map = new Map<string, string>();
  data?.forEach((s) => map.set(s.property_code, s.id));
  return map;
}

async function getBankAccountMap(): Promise<Map<string, string>> {
  const { data } = await db.from("bank_accounts").select("id, name");
  const map = new Map<string, string>();
  data?.forEach((b) => map.set(b.name.toUpperCase(), b.id));
  return map;
}

export class DuplicateMonthError extends Error {
  code = "DUPLICATE_MONTH" as const;
  existingRunId: string;
  month: number;
  year: number;
  constructor(existingRunId: string, month: number, year: number) {
    super(`A payroll run already exists for ${month}/${year}.`);
    this.existingRunId = existingRunId;
    this.month = month;
    this.year = year;
  }
}

export async function deleteSalaryRun(runId: string) {
  const { error: linesErr } = await db.from("salary_lines").delete().eq("salary_run_id", runId);
  if (linesErr) throw linesErr;
  const { error: runErr } = await db.from("salary_runs").delete().eq("id", runId);
  if (runErr) throw runErr;
}

export async function importSalary(result: ParsedSalaryResult, filename: string, opts: { replaceExisting?: boolean } = {}) {
  const { byName, byNuit } = await getEmployeeData();

  // Duplicate check
  const { data: existing } = await supabase
    .from("salary_runs")
    .select("id")
    .eq("month", result.month)
    .eq("year", result.year)
    .maybeSingle();

  if (existing) {
    if (!opts.replaceExisting) {
      throw new DuplicateMonthError(existing.id, result.month, result.year);
    }
    await deleteSalaryRun(existing.id);
  }

  // Create salary run
  const { data: run, error: runErr } = await supabase
    .from("salary_runs")
    .insert({ month: result.month, year: result.year, status: "imported" })
    .select("id")
    .single();
  if (runErr) throw runErr;

  // Track unmatched employees for debugging
  const unmatched: string[] = [];
  const updates: { id: string, payload: any }[] = [];

  const salaryLines = result.lines.map((l) => {
    // 1. Try matching by NUIT
    let emp = l.nuit ? byNuit.get(l.nuit) : null;
    
    // 2. If no NUIT match, try matching by Name
    if (!emp) {
      emp = byName.get(l.employee_name.toUpperCase());
    }

    if (!emp) {
      unmatched.push(l.employee_name);
      return null;
    }

    // 3. Check for HR data updates (NUIT, Dates, Category)
    const payload: any = {};
    if (l.nuit && emp.nuit !== l.nuit) payload.nuit = l.nuit;
    if (l.category && emp.category !== l.category) payload.category = l.category;
    if (l.engagement_date && emp.engagement_date !== l.engagement_date) payload.engagement_date = l.engagement_date;
    if (l.discharge_date && emp.discharge_date !== l.discharge_date) payload.discharge_date = l.discharge_date;

    if (Object.keys(payload).length > 0) {
      updates.push({ id: emp.id, payload });
    }

    return {
      salary_run_id: run.id,
      employee_id: emp.id,
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
  }).filter((l): l is NonNullable<typeof l> => l !== null);

  // Sync employee updates
  for (const update of updates) {
    await db.from("employees").update(update.payload).eq("id", update.id);
  }

  if (unmatched.length > 0) {
    console.warn(`Salary import: ${unmatched.length} employees not matched:`, unmatched);
  }

  const { error } = await db.from("salary_lines").insert(salaryLines);
  if (error) throw error;

  // Update run totals
  const totals = {
    total_gross: salaryLines.reduce((s, l) => s + (l.gross_total || 0), 0),
    total_net: salaryLines.reduce((s, l) => s + (l.net_salary || 0), 0),
    total_irps: salaryLines.reduce((s, l) => s + (l.irps || 0), 0),
    total_inss_employee: salaryLines.reduce((s, l) => s + (l.inss_employee || 0), 0),
  };
  await db.from("salary_runs").update(totals).eq("id", run.id);

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

  const { error } = await db.from("bim_salary_transfers").insert(transfers);
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
    const { error } = await db.from("income_transactions").insert(incRows);
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
    const { error } = await db.from("expense_transactions").insert(expRows);
    if (error) throw error;
    count += expRows.length;
  }

  await logImport(filename, "month_end", result.month, result.year, count);
  return count;
}

export async function importLandcoIncome(result: ParsedLandcoIncomeResult, filename: string) {
  const propMap = await getPropertyMap();
  const uniquePeriods = Array.from(
    new Set(result.records.map((record) => `${record.periodYear}-${record.periodMonth}`)),
  ).map((key) => {
    const [year, month] = key.split("-").map(Number);
    return { year, month };
  });

  for (const period of uniquePeriods) {
    await db.from("landco_income").delete().eq("period_year", period.year).eq("period_month", period.month);
  }

  const { data: rates } = await db.from("exchange_rates").select("*");
  const rateMap = new Map<string, number>();
  (rates ?? []).forEach((rate: { year: number; month: number; mzn_per_usd: string | number }) => {
    rateMap.set(`${rate.year}-${rate.month}`, Number(rate.mzn_per_usd));
  });

  const rows = result.records.map((record) => {
    const exchangeRate = record.amountUsd > 0
      ? record.totalMzn / record.amountUsd
      : rateMap.get(`${record.periodYear}-${record.periodMonth}`) ?? null;
    const amountUsd = record.amountUsd > 0
      ? record.amountUsd
      : exchangeRate && exchangeRate > 0
        ? record.totalMzn / exchangeRate
        : 0;

    return {
      transaction_date: record.transactionDate,
      period_month: record.periodMonth,
      period_year: record.periodYear,
      property_id: propMap.get(record.propertyCode) || null,
      property_code: record.propertyCode,
      house_number: record.houseNumber,
      description: record.description,
      accommodation_amount_mzn: record.accommodationAmountMzn,
      h1_amount_mzn: record.h1AmountMzn,
      h2_amount_mzn: record.h2AmountMzn,
      h3_amount_mzn: record.h3AmountMzn,
      h4_amount_mzn: record.h4AmountMzn,
      total_mzn: record.totalMzn,
      amount_usd: amountUsd,
      exchange_rate_used: exchangeRate,
      monthly_total_mzn_source: record.monthlyTotalMznSource,
      source_file: filename,
      source_sheet: "INCOME",
      source_row_number: record.sourceRowNumber,
      import_notes: record.importNotes,
    };
  });

  if (rows.length > 0) {
    const { error } = await db.from("landco_income").insert(rows);
    if (error) throw error;
  }

  await logImport(filename, "landco_income", result.month, result.year, rows.length);
  return rows.length;
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
    const { error } = await db.from("bank_transactions").insert(rows);
    if (error) throw error;
  }

  // Persist opening balances (carry-forward) per BIM account.
  for (const ob of result.openingBalances) {
    const bankId = ob.currency === "USD" ? bimUsd : bimMzn;
    if (!bankId) continue;
    await db.from("bank_opening_balances").upsert(
      {
        bank_account_id: bankId,
        month: result.month,
        year: result.year,
        opening_balance: ob.opening_balance,
        source_file: filename,
      },
      { onConflict: "bank_account_id,month,year" }
    );
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
      const { error } = await db.from("petty_cash_transactions").insert(rows);
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
    await db.from("invoices").delete().in("id", priorInvIds);
  }
  if (priorJeIds.length) {
    await db.from("journal_lines").delete().in("journal_entry_id", priorJeIds);
    await db.from("journal_entries").delete().in("id", priorJeIds);
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
        await db.from("journal_lines").insert(jLines);
      }
    }

    await db.from("invoices").insert({
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
  await db.from("import_log").insert({
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
  const { data } = await db.from("accounts").select("id, code").in("code", unique);
  const map = new Map<string, string>();
  data?.forEach((a: { id: string; code: string }) => map.set(a.code, a.id));
  return map;
}

// Get-or-create supplier by name (case-insensitive).
async function ensureSuppliers(names: string[]): Promise<Map<string, string>> {
  const unique = Array.from(new Set(names.map((n) => n.trim()).filter(Boolean)));
  const { data: existing } = await db.from("suppliers").select("id, name");
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

  await db.from("expense_transactions").delete().eq("month", result.month).eq("year", result.year);
  if (priorJeIds.length) {
    await db.from("supplier_invoices").delete().in("journal_entry_id", priorJeIds);
    await db.from("journal_lines").delete().in("journal_entry_id", priorJeIds);
    await db.from("journal_entries").delete().in("id", priorJeIds);
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

  // Fetch payroll totals for this period to override Excel values if needed
  const { data: salaryRun } = await supabase
    .from("salary_runs")
    .select("id")
    .eq("month", result.month)
    .eq("year", result.year)
    .maybeSingle();
  
  const payrollTotals = new Map<string, number>();
  if (salaryRun) {
    const { data: lines } = await supabase
      .from("salary_lines")
      .select("net_salary, employees(house_assignment)")
      .eq("salary_run_id", salaryRun.id);
    
    lines?.forEach((l: any) => {
      let house = (l.employees?.house_assignment || "LC").toUpperCase();
      // Normalize: pick the first one if multiple listed (e.g. H1/H4 -> H1)
      if (house.includes("/")) house = house.split("/")[0].trim();
      // Map common variants if needed, else use as-is
      payrollTotals.set(house, (payrollTotals.get(house) || 0) + Number(l.net_salary || 0));
    });
  }

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
      const { error: jlErr } = await db.from("journal_lines").insert(jLines);
      if (jlErr) throw jlErr;
    }

    // 3) supplier_invoice header (one per group).
    await db.from("supplier_invoices").insert({
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
    const expRows = lines.map((l) => {
      let finalAmount = l.amount_mzn;
      if (l.is_salary && salaryRun) {
        const houseCode = l.property_code || "LC";
        if (payrollTotals.has(houseCode)) {
           finalAmount = payrollTotals.get(houseCode)!;
        }
      }

      return {
        date,
        description: l.supplier ? `${l.supplier} — ${l.description}` : l.description,
        amount_mzn: finalAmount,
        is_shared: l.is_shared,
        month: result.month,
        year: result.year,
        category_id: catMap.get(l.category.toUpperCase()) || null,
        property_id: l.property_code ? propMap.get(l.property_code) || null : null,
        journal_entry_id: je.id,
      };
    });
    const { error: expErr } = await db.from("expense_transactions").insert(expRows);
    if (expErr) throw expErr;
    inserted += expRows.length;
  }

  await logImport(filename, "expenses", result.month, result.year, inserted);
  return inserted;
}

export async function importShareholderBalances(result: ParsedShareholderResult, filename: string) {
  const propMap = await getPropertyMap();
  const shMap = await getShareholderMap();

  const rows = result.balances.map((b) => ({
    shareholder_id: shMap.get(b.property_code) || null,
    property_id: propMap.get(b.property_code) || null,
    month: b.month,
    year: b.year,
    opening_balance: b.opening_balance,
    income: b.income,
    expenses: b.expenses,
    closing_balance: b.closing_balance,
  }));

  if (rows.length > 0) {
    const { error } = await db.from("shareholder_balances").upsert(rows, {
      onConflict: "shareholder_id,property_id,month,year",
    });
    if (error) throw error;
  }

  await logImport(filename, "shareholder_balance", result.month, result.year, rows.length);
  return rows.length;
}
