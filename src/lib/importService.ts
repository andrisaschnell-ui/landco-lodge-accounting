import { supabase } from "@/integrations/supabase/client";
import type { ParsedSalaryResult } from "./parsers/salaryParser";
import type { ParsedBimResult } from "./parsers/bimTransferParser";
import type { ParsedMonthEndResult } from "./parsers/monthEndParser";
import type { ParsedBdoResult } from "./parsers/bdoBankParser";
import type { ParsedPettyCashResult } from "./parsers/pettyCashParser";

async function getEmployeeMap(): Promise<Map<string, string>> {
  const { data } = await supabase.from("employees").select("id, name");
  const map = new Map<string, string>();
  data?.forEach((e) => map.set(e.name.toUpperCase(), e.id));
  return map;
}

async function getPropertyMap(): Promise<Map<string, string>> {
  const { data } = await supabase.from("properties").select("id, code");
  const map = new Map<string, string>();
  data?.forEach((p) => map.set(p.code, p.id));
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

export async function importBdoBank(result: ParsedBdoResult, filename: string) {
  const bankMap = await getBankAccountMap();
  const bdoId = bankMap.get("BDO CURRENT") || bankMap.get("BDO") || null;

  const rows = result.transactions.map((t) => ({
    date: t.date || null,
    description: t.description,
    reference: t.reference,
    debit: t.debit,
    credit: t.credit,
    balance: t.balance,
    bank_account_id: bdoId,
    month: result.month,
    year: result.year,
  }));

  const { error } = await supabase.from("bank_transactions").insert(rows);
  if (error) throw error;

  await logImport(filename, "bdo_bank", result.month, result.year, rows.length);
  return rows.length;
}

export async function importPettyCash(results: ParsedPettyCashResult[], filename: string) {
  let total = 0;
  for (const result of results) {
    const rows = result.transactions.map((t) => ({
      date: t.date || null,
      description: `[${result.sheetName}] ${t.description}`,
      credit: t.credit,
      debit: t.debit,
      balance: t.balance,
      month: result.month,
      year: result.year,
    }));

    const { error } = await supabase.from("petty_cash_transactions").insert(rows);
    if (error) throw error;
    total += rows.length;
  }

  const m = results[0]?.month || 1;
  const y = results[0]?.year || 2026;
  await logImport(filename, "petty_cash", m, y, total);
  return total;
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
