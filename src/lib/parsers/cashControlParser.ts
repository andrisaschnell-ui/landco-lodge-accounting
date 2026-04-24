/**
 * Cash Control parser — handles Money Box (Petty Cash), Emola, and Mpesa workbooks.
 * All three kept fully isolated from the accounting system.
 */
import * as XLSX from "xlsx";
import JSZip from "jszip";

export type CashSheetType = "petty_cash" | "cash_landco" | "emola" | "emola_two" | "mpesa" | "mpesa_two";

export interface CashTransaction {
  row_no: number | null;
  tx_date: string | null;   // yyyy-mm-dd
  description: string;
  funder: string | null;
  receiver: string | null;
  cell_no: string | null;
  cheque_no: string | null;
  company: string | null;
  entrada: number;
  saida: number;
  bank_charges: number;
  balance: number | null;
  allocation_column: string | null;  // first non-zero category column hit
  allocation_amount: number;
  allocations: Record<string, number>;
}

export interface ParsedCashSheet {
  sheet_type: CashSheetType;
  source_file: string;
  sheet_name: string;       // worksheet tab name
  month: number | null;
  year: number;
  opening_balance: number;
  opening_description: string | null;
  allocation_columns: string[];
  transactions: CashTransaction[];
}

const MONTH_MAP: Record<string, number> = {
  jan: 1, janeiro: 1, janeirio: 1, january: 1,
  feb: 2, fev: 2, fevereiro: 2, february: 2,
  mar: 3, mrt: 3, march: 3, marco: 3, "março": 3,
  apr: 4, abr: 4, april: 4, abril: 4,
  may: 5, mai: 5, maio: 5,
  jun: 6, june: 6, junho: 6,
  jul: 7, july: 7, julho: 7,
  aug: 8, ago: 8, august: 8, agosto: 8,
  sep: 9, set: 9, september: 9, setembro: 9,
  oct: 10, out: 10, october: 10, outubro: 10,
  nov: 11, november: 11, novembro: 11,
  dec: 12, dez: 12, december: 12, dezembro: 12,
};

const num = (v: unknown): number => {
  if (v == null || v === "") return 0;
  const cleaned = typeof v === "string"
    ? v.replace(/[,$\s]/g, "").replace(/USD|MZN|MT/gi, "").trim()
    : v;
  const n = Number(cleaned);
  return isNaN(n) ? 0 : n;
};

const str = (v: unknown): string => (v == null ? "" : String(v).trim());

const isBalanceRow = (desc: string): boolean => {
  const d = desc.toUpperCase();
  return (
    d.includes("BALANCE B/F") ||
    d.includes("BALANCE BF") ||
    d === "BALANCE" ||
    d.includes("BALANCE END") ||
    d.includes("BALANCE CARRY") ||
    d.includes("CARRY FORWARD") ||
    d.includes("SALDO TRANSPORTE") ||
    d.includes("SALDO ANTERIOR")
  );
};

const excelDateToISO = (v: unknown): string | null => {
  if (!v) return null;
  if (v instanceof Date) return v.toISOString().slice(0, 10);
  if (typeof v === "number") {
    // Excel epoch
    const d = new Date(Math.round((v - 25569) * 86400 * 1000));
    return isNaN(d.getTime()) ? null : d.toISOString().slice(0, 10);
  }
  const s = String(v).trim();
  if (!s) return null;
  const d = new Date(s);
  return isNaN(d.getTime()) ? null : d.toISOString().slice(0, 10);
};

// ---------------- Petty Cash ----------------
// Header row: row 9 (index 8). Sub-header row 10. BALANCE row follows.
function parsePettyCashSheet(
  ws: XLSX.WorkSheet,
  sheetName: string,
  fallbackYear: number,
  sourceFile: string,
): ParsedCashSheet {
  const rows = XLSX.utils.sheet_to_json<unknown[]>(ws, { header: 1, raw: false, defval: null });

  // Detect month from tab name or header cell
  let month: number | null = MONTH_MAP[sheetName.toLowerCase().slice(0, 5)] ?? MONTH_MAP[sheetName.toLowerCase().slice(0, 3)] ?? null;
  let year = fallbackYear;
  for (let r = 0; r < Math.min(rows.length, 10); r++) {
    for (const cell of rows[r] ?? []) {
      const s = str(cell).toLowerCase();
      const key = s.slice(0, 5);
      if (!month && (MONTH_MAP[key] || MONTH_MAP[s.slice(0, 3)])) {
        month = MONTH_MAP[key] ?? MONTH_MAP[s.slice(0, 3)];
      }
      const yrMatch = String(cell).match(/20\d{2}/);
      if (yrMatch) year = parseInt(yrMatch[0]);
    }
  }

  // Find header row by scanning for "Data" & "Entradas"
  let headerRow = -1;
  for (let r = 0; r < Math.min(rows.length, 15); r++) {
    const cells = (rows[r] ?? []).map((c) => str(c).toLowerCase());
    if (cells.some((c) => c === "data") && cells.some((c) => c.startsWith("entrada"))) {
      headerRow = r;
      break;
    }
  }
  if (headerRow === -1) {
    return { sheet_type: "petty_cash", source_file: sourceFile, sheet_name: sheetName, month, year, opening_balance: 0, opening_description: null, allocation_columns: [], transactions: [] };
  }

  const headers = (rows[headerRow] ?? []).map((c) => str(c));
  // Map column indices
  const colIdx = {
    no: headers.findIndex((h) => h.toLowerCase() === "nº" || h.toLowerCase() === "no"),
    date: headers.findIndex((h) => h.toLowerCase() === "data"),
    cheque: headers.findIndex((h) => /cheque/i.test(h)),
    empresa: headers.findIndex((h) => /empresa/i.test(h)),
    desc: headers.findIndex((h) => /descri/i.test(h)),
    entradas: headers.findIndex((h) => /entrada/i.test(h)),
    saidas: headers.findIndex((h) => /sa[ií]da/i.test(h)),
    total: headers.findIndex((h) => h.toLowerCase().trim() === "total"),
  };

  // Allocation columns = columns after Saídas up to (but not including) Total
  const allocStart = colIdx.saidas >= 0 ? colIdx.saidas + 1 : -1;
  const allocEnd = colIdx.total >= 0 ? colIdx.total : headers.length;
  const allocation_columns: string[] = [];
  const allocCols: { idx: number; name: string }[] = [];
  if (allocStart > 0) {
    for (let c = allocStart; c < allocEnd; c++) {
      const name = str(headers[c]);
      if (name && name.toLowerCase() !== "total") {
        allocation_columns.push(name);
        allocCols.push({ idx: c, name });
      }
    }
  }

  let opening_balance = 0;
  let opening_description: string | null = null;
  const transactions: CashTransaction[] = [];

  for (let r = headerRow + 1; r < rows.length; r++) {
    const row = rows[r] ?? [];
    const desc = str(row[colIdx.desc]);
    const dateVal = row[colIdx.date];
    // skip empty rows
    if (!desc && !dateVal && num(row[colIdx.entradas]) === 0 && num(row[colIdx.saidas]) === 0) continue;
    // skip the sub-header "Doc" row
    if (!dateVal && str(row[colIdx.no]).toLowerCase() === "doc") continue;

    if (isBalanceRow(desc)) {
      opening_balance = num(row[colIdx.entradas]) || num(row[colIdx.saidas]) * -1 || 0;
      opening_description = desc;
      continue;
    }

    const allocations: Record<string, number> = {};
    let firstAllocCol: string | null = null;
    let firstAllocAmt = 0;
    for (const a of allocCols) {
      const v = num(row[a.idx]);
      if (v !== 0) {
        allocations[a.name] = v;
        if (!firstAllocCol) { firstAllocCol = a.name; firstAllocAmt = v; }
      }
    }

    transactions.push({
      row_no: colIdx.no >= 0 && row[colIdx.no] != null ? Number(row[colIdx.no]) || null : null,
      tx_date: excelDateToISO(dateVal),
      description: desc,
      funder: null,
      receiver: null,
      cell_no: null,
      cheque_no: str(row[colIdx.cheque]) || null,
      company: str(row[colIdx.empresa]) || null,
      entrada: num(row[colIdx.entradas]),
      saida: num(row[colIdx.saidas]),
      bank_charges: 0,
      balance: null,
      allocation_column: firstAllocCol,
      allocation_amount: firstAllocAmt,
      allocations,
    });
  }

  return { sheet_type: "petty_cash", source_file: sourceFile, sheet_name: sheetName, month, year, opening_balance, opening_description, allocation_columns, transactions };
}

// ---------------- Emola / Mpesa ----------------
function parseMobileSheet(
  ws: XLSX.WorkSheet,
  sheetName: string,
  sheet_type: "emola" | "mpesa",
  fallbackYear: number,
  sourceFile: string,
): ParsedCashSheet {
  const rows = XLSX.utils.sheet_to_json<unknown[]>(ws, { header: 1, raw: false, defval: null });

  // Find header row: has "Date" and "Funder"
  let headerRow = -1;
  for (let r = 0; r < Math.min(rows.length, 10); r++) {
    const cells = (rows[r] ?? []).map((c) => str(c).toLowerCase());
    if (cells.some((c) => c === "date") && cells.some((c) => c === "funder")) {
      headerRow = r;
      break;
    }
  }
  if (headerRow === -1) {
    return { sheet_type, source_file: sourceFile, sheet_name: sheetName, month: null, year: fallbackYear, opening_balance: 0, opening_description: null, allocation_columns: [], transactions: [] };
  }

  const headers = (rows[headerRow] ?? []).map((c) => str(c));
  const col = (name: string | RegExp) => {
    if (typeof name === "string") return headers.findIndex((h) => h.toLowerCase() === name.toLowerCase());
    return headers.findIndex((h) => name.test(h));
  };

  const ci = {
    date: col("date"),
    bim: col(/^bim$/i) !== -1 ? col(/^bim$/i) : col(/^mpesa$|^emola$/i),
    funder: col("funder"),
    cell: col(/cel+\s*no/i),
    receiver: col("receiver"),
    deposit: col("deposit"),
    payment: col(/payment/i),
    bankCharges: col(/bank\s*charge/i),
    balance: col("balance"),
  };

  // Allocation columns: everything after Balance (if present) else after Deposit/Payment
  const lastCoreCol = Math.max(ci.balance, ci.bankCharges, ci.payment, ci.deposit);
  const allocation_columns: string[] = [];
  const allocCols: { idx: number; name: string }[] = [];
  for (let c = lastCoreCol + 1; c < headers.length; c++) {
    const name = str(headers[c]);
    if (name) {
      allocation_columns.push(name);
      allocCols.push({ idx: c, name });
    }
  }

  let year = fallbackYear;
  const yMatch = sheetName.match(/20\d{2}/);
  if (yMatch) year = parseInt(yMatch[0]);

  let opening_balance = 0;
  let opening_description: string | null = null;
  const transactions: CashTransaction[] = [];

  for (let r = headerRow + 1; r < rows.length; r++) {
    const row = rows[r] ?? [];
    const desc = str(row[ci.bim]);
    const dateVal = row[ci.date];
    if (!desc && !dateVal) continue;

    if (isBalanceRow(desc)) {
      opening_balance = num(row[ci.deposit]) || num(row[ci.balance]) || 0;
      opening_description = desc;
      continue;
    }

    const allocations: Record<string, number> = {};
    let firstAllocCol: string | null = null;
    let firstAllocAmt = 0;
    for (const a of allocCols) {
      const v = num(row[a.idx]);
      if (v !== 0) {
        allocations[a.name] = v;
        if (!firstAllocCol) { firstAllocCol = a.name; firstAllocAmt = v; }
      }
    }

    const iso = excelDateToISO(dateVal);
    if (iso) {
      const yr = parseInt(iso.slice(0, 4));
      if (!isNaN(yr)) year = yr;
    }

    transactions.push({
      row_no: null,
      tx_date: iso,
      description: desc,
      funder: str(row[ci.funder]) || null,
      receiver: str(row[ci.receiver]) || null,
      cell_no: str(row[ci.cell]) || null,
      cheque_no: null,
      company: null,
      entrada: num(row[ci.deposit]),
      saida: num(row[ci.payment]),
      bank_charges: ci.bankCharges >= 0 ? num(row[ci.bankCharges]) : 0,
      balance: ci.balance >= 0 ? num(row[ci.balance]) : null,
      allocation_column: firstAllocCol,
      allocation_amount: firstAllocAmt,
      allocations,
    });
  }

  return { sheet_type, source_file: sourceFile, sheet_name: sheetName, month: null, year, opening_balance, opening_description, allocation_columns, transactions };
}

// ---------------- Entry points ----------------
export function parsePettyCashWorkbook(buffer: ArrayBuffer, sourceFile: string, defaultYear: number): ParsedCashSheet[] {
  const wb = XLSX.read(buffer, { type: "array", cellDates: true });
  const results: ParsedCashSheet[] = [];
  for (const name of wb.SheetNames) {
    const parsed = parsePettyCashSheet(wb.Sheets[name], name, defaultYear, sourceFile);
    // Only keep sheets that look like month sheets (have a month or transactions)
    if (parsed.month || parsed.transactions.length > 0) results.push(parsed);
  }
  return results;
}

export function parseMobileWorkbook(
  buffer: ArrayBuffer,
  sourceFile: string,
  sheet_type: "emola" | "mpesa",
  defaultYear: number,
): ParsedCashSheet[] {
  const wb = XLSX.read(buffer, { type: "array", cellDates: true });
  const results: ParsedCashSheet[] = [];
  for (const name of wb.SheetNames) {
    const parsed = parseMobileSheet(wb.Sheets[name], name, sheet_type, defaultYear, sourceFile);
    if (parsed.transactions.length > 0 || parsed.opening_balance !== 0) results.push(parsed);
  }
  return results;
}

export interface CashControlParseResult {
  petty_cash: ParsedCashSheet[];
  emola: ParsedCashSheet[];
  mpesa: ParsedCashSheet[];
  warnings: string[];
}

/** Parse a ZIP containing Money Box.xlsx / Petty Cash.xlsx, Emola.xlsx, Mpesa.xlsx (any subset). */
export async function parseCashControlZip(buffer: ArrayBuffer, defaultYear: number): Promise<CashControlParseResult> {
  const zip = await JSZip.loadAsync(buffer);
  const result: CashControlParseResult = { petty_cash: [], emola: [], mpesa: [], warnings: [] };

  for (const entry of Object.values(zip.files)) {
    if (entry.dir) continue;
    const name = entry.name.split("/").pop() || entry.name;
    const lower = name.toLowerCase();
    if (!lower.endsWith(".xlsx") && !lower.endsWith(".xls")) continue;
    if (lower.startsWith("._") || lower.startsWith("~$")) continue; // mac/office tmp

    const buf = await entry.async("arraybuffer");
    if (lower.includes("money") || lower.includes("petty")) {
      result.petty_cash.push(...parsePettyCashWorkbook(buf, name, defaultYear));
    } else if (lower.includes("emola")) {
      result.emola.push(...parseMobileWorkbook(buf, name, "emola", defaultYear));
    } else if (lower.includes("mpesa") || lower.includes("m-pesa")) {
      result.mpesa.push(...parseMobileWorkbook(buf, name, "mpesa", defaultYear));
    } else {
      result.warnings.push(`Unrecognised file in zip: ${name}`);
    }
  }
  return result;
}
