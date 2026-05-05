import { db } from "@/lib/db";
import type { CashControlParseResult, ParsedCashSheet, CashSheetType } from "./parsers/cashControlParser";
import { supabase } from "@/integrations/supabase/client";

async function seedDropdownOptions(sheet_type: CashSheetType, column_key: string, values: string[]) {
  const clean = Array.from(new Set(values.map((v) => v?.trim()).filter((v): v is string => !!v)));
  if (clean.length === 0) return;
  const rows = clean.map((value, idx) => ({ sheet_type, column_key, value, sort_order: idx }));
  // upsert with ON CONFLICT DO NOTHING semantics
  await db.from("cash_dropdown_options").upsert(rows, { onConflict: "sheet_type,column_key,value", ignoreDuplicates: true });
}

async function seedAllocationColumns(sheet_type: CashSheetType, columns: string[]) {
  const clean = Array.from(new Set(columns.map((c) => c?.trim()).filter((c): c is string => !!c)));
  if (clean.length === 0) return;
  const rows = clean.map((column_name, idx) => ({ sheet_type, column_name, sort_order: idx }));
  await db.from("cash_allocation_columns").upsert(rows, { onConflict: "sheet_type,column_name", ignoreDuplicates: true });
}

async function importOneSheet(sheet: ParsedCashSheet): Promise<number> {
  // Delete existing data for this (sheet_type, month, year) so re-imports are idempotent
  const { data: existing } = await supabase
    .from("cash_sheets")
    .select("id")
    .eq("sheet_type", sheet.sheet_type)
    .eq("year", sheet.year)
    .eq("month", sheet.month as any);
  if (existing && existing.length > 0) {
    const ids = existing.map((e) => e.id);
    await db.from("cash_transactions").delete().in("sheet_id", ids);
    await db.from("cash_sheets").delete().in("id", ids);
  }

  // Insert sheet
  const { data: sheetRow, error: sErr } = await supabase
    .from("cash_sheets")
    .insert({
      sheet_type: sheet.sheet_type,
      month: sheet.month,
      year: sheet.year,
      opening_balance: sheet.opening_balance,
      opening_description: sheet.opening_description,
      source_file: sheet.source_file,
    })
    .select("id")
    .single();
  if (sErr || !sheetRow) throw new Error(`Failed to create cash sheet: ${sErr?.message}`);

  // Insert transactions
  if (sheet.transactions.length > 0) {
    const txRows = sheet.transactions.map((t) => ({
      sheet_type: sheet.sheet_type,
      sheet_id: sheetRow.id,
      row_no: t.row_no,
      tx_date: t.tx_date,
      month: sheet.month ?? (t.tx_date ? new Date(t.tx_date).getMonth() + 1 : 1),
      year: sheet.year,
      description: t.description,
      funder: t.funder,
      receiver: t.receiver,
      cell_no: t.cell_no,
      cheque_no: t.cheque_no,
      company: t.company,
      entrada: t.entrada,
      saida: t.saida,
      bank_charges: t.bank_charges,
      balance: t.balance,
      allocation_column: t.allocation_column,
      allocation_amount: t.allocation_amount,
      allocations: t.allocations,
      source_file: sheet.source_file,
    }));
    const { error: txErr } = await db.from("cash_transactions").insert(txRows);
    if (txErr) throw new Error(`Failed to insert transactions: ${txErr.message}`);
  }

  // Seed dropdown lists
  await seedAllocationColumns(sheet.sheet_type, sheet.allocation_columns);
  await seedDropdownOptions(sheet.sheet_type, "allocation", sheet.allocation_columns);
  await seedDropdownOptions(sheet.sheet_type, "funder", sheet.transactions.map((t) => t.funder || ""));
  await seedDropdownOptions(sheet.sheet_type, "receiver", sheet.transactions.map((t) => t.receiver || ""));
  await seedDropdownOptions(sheet.sheet_type, "company", sheet.transactions.map((t) => t.company || ""));
  await seedDropdownOptions(sheet.sheet_type, "cheque_type", sheet.transactions.map((t) => t.cheque_no || ""));

  return sheet.transactions.length;
}

export async function importCashControl(result: CashControlParseResult): Promise<{
  petty_cash: number;
  emola: number;
  mpesa: number;
}> {
  let petty_cash = 0, emola = 0, mpesa = 0;
  for (const s of result.petty_cash) petty_cash += await importOneSheet(s);
  for (const s of result.emola) emola += await importOneSheet(s);
  for (const s of result.mpesa) mpesa += await importOneSheet(s);
  return { petty_cash, emola, mpesa };
}
