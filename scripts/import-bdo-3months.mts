import { readFileSync } from "node:fs";
import { createClient } from "@supabase/supabase-js";
import { parseBdoBank } from "../src/lib/parsers/bdoBankParser";
import { parseInvoices } from "../src/lib/parsers/invoicesParser";
import { parsePettyCash } from "../src/lib/parsers/pettyCashParser";

const url = process.env.SUPABASE_URL!;
const key = process.env.SUPABASE_SERVICE_ROLE_KEY!;
const supabase = createClient(url, key, { auth: { persistSession: false } });

// Replace the auto-imported `supabase` in importService — easiest path: re-implement
// the three needed import functions inline so we can use the service-role client.

async function getBankAccountMap() {
  const { data } = await supabase.from("bank_accounts").select("id, name");
  const m = new Map<string, string>();
  data?.forEach((b: any) => m.set(b.name.toUpperCase(), b.id));
  return m;
}

async function getAccountIdMap(codes: string[]) {
  const { data } = await supabase.from("accounts").select("id, code").in("code", codes);
  const m = new Map<string, string>();
  data?.forEach((a: any) => m.set(a.code, a.id));
  return m;
}

async function importBdoBank(result: ReturnType<typeof parseBdoBank>, filename: string) {
  const bankMap = await getBankAccountMap();
  const bimMzn = bankMap.get("BIM MZN") || null;
  const bimUsd = bankMap.get("BIM USD") || null;
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

  if (rows.length) {
    const { error } = await supabase.from("bank_transactions").insert(rows);
    if (error) throw error;
  }

  for (const ob of result.openingBalances) {
    const bankId = ob.currency === "USD" ? bimUsd : bimMzn;
    if (!bankId) continue;
    const { error } = await supabase.from("bank_opening_balances").upsert(
      {
        bank_account_id: bankId,
        month: result.month,
        year: result.year,
        opening_balance: ob.opening_balance,
        source_file: filename,
      },
      { onConflict: "bank_account_id,month,year" }
    );
    if (error) throw error;
  }

  return { txns: rows.length, openings: result.openingBalances.length };
}

async function importInvoices(result: ReturnType<typeof parseInvoices>, filename: string) {
  const monthStart = `${result.year}-${String(result.month).padStart(2, "0")}-01`;
  const nextMonth = result.month === 12 ? 1 : result.month + 1;
  const nextYear = result.month === 12 ? result.year + 1 : result.year;
  const monthEndExclusive = `${nextYear}-${String(nextMonth).padStart(2, "0")}-01`;

  const { data: priorInvs } = await supabase
    .from("invoices")
    .select("id, journal_entry_id")
    .gte("invoice_date", monthStart)
    .lt("invoice_date", monthEndExclusive)
    .eq("status", "imported");
  const priorJeIds = (priorInvs ?? []).map((i: any) => i.journal_entry_id).filter(Boolean) as string[];
  const priorInvIds = (priorInvs ?? []).map((i: any) => i.id);
  if (priorInvIds.length) await supabase.from("invoices").delete().in("id", priorInvIds);
  if (priorJeIds.length) {
    await supabase.from("journal_lines").delete().in("journal_entry_id", priorJeIds);
    await supabase.from("journal_entries").delete().in("id", priorJeIds);
  }

  if (!result.invoices.length) return 0;

  const accMap = await getAccountIdMap(["11", "71", "4432"]);
  const debtorsId = accMap.get("11");
  const salesId = accMap.get("71");
  const ivaId = accMap.get("4432");

  let n = 0;
  for (const inv of result.invoices) {
    let jeId: string | null = null;
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
        const jLines: any[] = [
          { journal_entry_id: jeId, account_id: debtorsId, debit: inv.total_mzn, credit: 0, memo: inv.description },
          { journal_entry_id: jeId, account_id: salesId, debit: 0, credit: inv.amount_excl_mzn, memo: "Sales" },
        ];
        if (inv.iva_mzn > 0 && ivaId) {
          jLines.push({ journal_entry_id: jeId, account_id: ivaId, debit: 0, credit: inv.iva_mzn, memo: "IVA 16%" });
        } else if (inv.iva_mzn > 0) {
          jLines[1].credit = inv.amount_excl_mzn + inv.iva_mzn;
        }
        await supabase.from("journal_lines").insert(jLines);
      }
    }
    await supabase.from("invoices").insert({
      invoice_number: inv.invoice_no
        ? `IMP ${result.year}/${inv.invoice_no}`
        : `IMP ${result.year}/${result.month}-${n + 1}`,
      invoice_series: "IMP",
      invoice_date: inv.date,
      client_name: inv.description.slice(0, 200) || "—",
      line_items: [{
        description: inv.description, qty: 1, unit: inv.amount_excl_mzn,
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
    n++;
  }
  return n;
}

async function importPettyCash(results: ReturnType<typeof parsePettyCash>, _filename: string) {
  const m0 = results[0]?.month;
  const y0 = results[0]?.year;
  if (m0 && y0) {
    await supabase.from("petty_cash_transactions").delete().eq("month", m0).eq("year", y0);
  }
  let total = 0;
  for (const r of results) {
    const rows = r.transactions.map((t) => ({
      date: t.date || null,
      description: t.description,
      reference: t.ref || null,
      supplier: t.supplier || null,
      allocation: t.allocation || null,
      credit: t.credit,
      debit: t.debit,
      balance: t.balance,
      month: r.month,
      year: r.year,
      source_file: r.sheetName,
    }));
    if (rows.length) {
      const { error } = await supabase.from("petty_cash_transactions").insert(rows);
      if (error) throw error;
      total += rows.length;
    }
  }
  return total;
}

const FILES: Array<{ month: number; year: number; path: string; filename: string }> = [
  { month: 1, year: 2026, path: "/tmp/bdo/01 BDO Bank Control 2026.xlsx", filename: "01 BDO Bank Control 2026.xlsx" },
  { month: 2, year: 2026, path: "/tmp/bdo/02 BDO Bank Control 2026.xlsx", filename: "02 BDO Bank Control 2026.xlsx" },
  { month: 3, year: 2026, path: "/tmp/bdo/03 BDO Bank Control 2026.xlsx", filename: "03 BDO Bank Control 2026.xlsx" },
];

for (const f of FILES) {
  const buf = readFileSync(f.path);
  const ab = buf.buffer.slice(buf.byteOffset, buf.byteOffset + buf.byteLength) as ArrayBuffer;

  const bdo = parseBdoBank(ab, f.month, f.year);
  const bdoRes = await importBdoBank(bdo, f.filename);

  const inv = parseInvoices(ab, f.month, f.year);
  const invN = await importInvoices(inv, f.filename);

  const pc = parsePettyCash(ab, f.month, f.year);
  const pcN = await importPettyCash(pc, f.filename);

  console.log(
    `M${f.month}/${f.year}: bank=${bdoRes.txns} (open=${bdoRes.openings}), invoices=${invN}, petty=${pcN}`
  );
}
console.log("Done.");
