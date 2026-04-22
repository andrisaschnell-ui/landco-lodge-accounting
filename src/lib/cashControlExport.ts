import * as XLSX from "xlsx";
import type { CashSheetType } from "./parsers/cashControlParser";

interface Tx {
  row_no: number | null;
  tx_date: string | null;
  description: string | null;
  funder: string | null;
  receiver: string | null;
  cell_no: string | null;
  cheque_no: string | null;
  company: string | null;
  entrada: number | null;
  saida: number | null;
  bank_charges: number | null;
  allocations: Record<string, number> | null;
}

interface ExportInput {
  sheet_type: CashSheetType;
  title: string;
  month: number | null;
  year: number;
  opening_balance: number;
  allocation_columns: string[];
  transactions: Tx[];
}

const colLetter = (n: number): string => {
  let s = "";
  while (n > 0) { const m = (n - 1) % 26; s = String.fromCharCode(65 + m) + s; n = Math.floor((n - 1) / 26); }
  return s;
};

export function exportCashSheetAsXlsx(input: ExportInput): void {
  const wb = XLSX.utils.book_new();
  const aoa: (string | number | null)[][] = [];

  let headers: string[];
  if (input.sheet_type === "petty_cash") {
    headers = ["Nº", "Data", "Nº Cheque / Documento", "Empresa", "Descrição", "Entradas", "Saídas", ...input.allocation_columns, "Balance"];
  } else {
    headers = ["Date", "Description", "Funder", "Cell No", "Receiver", "Deposit", "Payments",
      ...(input.sheet_type === "mpesa" ? ["Bank charges"] : []),
      ...input.allocation_columns, "Balance"];
  }

  // Title rows
  aoa.push([input.title]);
  aoa.push([`${input.month ? `Month ${input.month} / ` : ""}${input.year}`]);
  aoa.push([]);
  // Opening balance row
  const openingRow: (string | number | null)[] = new Array(headers.length).fill(null);
  openingRow[0] = input.sheet_type === "petty_cash" ? null : input.year + "-01-01";
  openingRow[input.sheet_type === "petty_cash" ? 4 : 1] = "BALANCE B/F";
  const entradaCol = input.sheet_type === "petty_cash" ? 5 : 5;
  openingRow[entradaCol] = input.opening_balance;
  const balCol = headers.length - 1;
  openingRow[balCol] = input.opening_balance;
  const headerRowIdx = aoa.length; // 0-based
  aoa.push(headers);
  const openingDataRowIdx = aoa.length;
  aoa.push(openingRow);

  // Data rows with formulas for balance
  input.transactions.forEach((t, i) => {
    const row: (string | number | null)[] = new Array(headers.length).fill(null);
    if (input.sheet_type === "petty_cash") {
      row[0] = t.row_no ?? i + 1;
      row[1] = t.tx_date;
      row[2] = t.cheque_no;
      row[3] = t.company;
      row[4] = t.description;
      row[5] = t.entrada || null;
      row[6] = t.saida || null;
      input.allocation_columns.forEach((c, k) => { row[7 + k] = t.allocations?.[c] ?? null; });
    } else {
      row[0] = t.tx_date;
      row[1] = t.description;
      row[2] = t.funder;
      row[3] = t.cell_no;
      row[4] = t.receiver;
      row[5] = t.entrada || null;
      row[6] = t.saida || null;
      let offset = 7;
      if (input.sheet_type === "mpesa") { row[offset] = t.bank_charges || null; offset++; }
      input.allocation_columns.forEach((c, k) => { row[offset + k] = t.allocations?.[c] ?? null; });
    }
    aoa.push(row);
  });

  // Build worksheet from AOA
  const ws = XLSX.utils.aoa_to_sheet(aoa);

  // Insert balance formulas on data rows (running: prev + entrada - saida)
  const entradaColLetter = colLetter(entradaCol + 1);
  const saidaColLetter = colLetter(entradaCol + 2);
  const balColLetter = colLetter(balCol + 1);
  for (let i = 0; i < input.transactions.length; i++) {
    const rowNum = openingDataRowIdx + 1 + i + 1; // 1-based excel row
    const prev = rowNum - 1;
    const cellAddr = `${balColLetter}${rowNum}`;
    ws[cellAddr] = { t: "n", f: `${balColLetter}${prev}+IFERROR(${entradaColLetter}${rowNum},0)-IFERROR(${saidaColLetter}${rowNum},0)` };
  }

  // Totals row
  const totalRowNum = aoa.length + 1;
  const totals: (string | number | null)[] = new Array(headers.length).fill(null);
  totals[entradaCol - 1] = "Totals";
  aoa.push(totals);
  XLSX.utils.sheet_add_aoa(ws, [totals], { origin: -1 });
  const firstDataRow = openingDataRowIdx + 2;
  const lastDataRow = openingDataRowIdx + 1 + input.transactions.length;
  ws[`${entradaColLetter}${totalRowNum}`] = { t: "n", f: `SUM(${entradaColLetter}${firstDataRow}:${entradaColLetter}${lastDataRow})` };
  ws[`${saidaColLetter}${totalRowNum}`] = { t: "n", f: `SUM(${saidaColLetter}${firstDataRow}:${saidaColLetter}${lastDataRow})` };

  // Column widths
  ws["!cols"] = headers.map((h) => ({ wch: Math.max(10, h.length + 2) }));

  XLSX.utils.book_append_sheet(wb, ws, `${input.sheet_type}`.slice(0, 31));
  const filename = `${input.title.replace(/\s+/g, "_")}_${input.year}${input.month ? `_${String(input.month).padStart(2, "0")}` : ""}.xlsx`;
  XLSX.writeFile(wb, filename);
}
