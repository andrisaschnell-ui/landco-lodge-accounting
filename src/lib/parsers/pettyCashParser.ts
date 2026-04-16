import * as XLSX from 'xlsx';

export interface ParsedPettyCash {
  date: string;
  ref: string;
  supplier: string;
  description: string;
  allocation: string;
  credit: number;   // Entradas
  debit: number;    // Saidas
  balance: number;
}

export interface ParsedPettyCashResult {
  transactions: ParsedPettyCash[];
  month: number;
  year: number;
  sheetName: string;
}

const num = (v: unknown): number => {
  if (v == null || v === '') return 0;
  const n = Number(v);
  return isNaN(n) ? 0 : n;
};
const str = (v: unknown): string => (v == null ? '' : String(v).trim());

function excelDateToISO(v: unknown, year: number, month: number): string {
  if (!v) return '';
  if (v instanceof Date) return v.toISOString().split('T')[0];
  if (typeof v === 'string') {
    if (/^\d{4}-\d{2}-\d{2}/.test(v)) return v.split('T')[0];
    const d = new Date(v);
    if (!isNaN(d.getTime())) return d.toISOString().split('T')[0];
  }
  if (typeof v === 'number' && v > 40000) {
    const d = new Date((v - 25569) * 86400 * 1000);
    return d.toISOString().split('T')[0];
  }
  return `${year}-${String(month).padStart(2, '0')}-01`;
}

export function parsePettyCash(file: ArrayBuffer, month: number, year: number): ParsedPettyCashResult[] {
  const wb = XLSX.read(file, { type: 'array', cellDates: true });

  // Find the "Petty cash" sheet (may have trailing space)
  const sheetName = wb.SheetNames.find(
    (s) => s.toLowerCase().trim() === 'petty cash'
  );
  if (!sheetName) return [];

  const ws = wb.Sheets[sheetName];
  const rows: unknown[][] = XLSX.utils.sheet_to_json(ws, { header: 1, defval: null });

  // Petty Cash layout:
  // Col 0: DATA (date), Col 1: REF, Col 2: SUPPLIER
  // Col 3: DESCRIPTION, Col 4: ALLOCATION
  // Col 5: ENTRADAS (credits/deposits), Col 6: SAIDAS (debits/expenses)
  // Col 7: Running balance, Col 8: IVA, Col 9: Nett Expenses

  // Find header row containing "DATA" in col 0
  let dataStart = -1;
  for (let i = 0; i < Math.min(rows.length, 15); i++) {
    const r = rows[i];
    if (!r) continue;
    const c0 = str(r[0]).toUpperCase();
    if (c0 === 'DATA' || c0 === 'DATE') {
      dataStart = i + 1;
      break;
    }
  }

  if (dataStart === -1) return [];

  const transactions: ParsedPettyCash[] = [];
  for (let i = dataStart; i < rows.length; i++) {
    const row = rows[i];
    if (!row) continue;

    const dateVal = row[0];
    const supplier = str(row[2]);
    const desc = str(row[3]);
    const allocation = str(row[4]);
    const entradas = num(row[5]);
    const saidas = num(row[6]);
    const balance = num(row[7]);

    // Skip empty rows
    if (entradas === 0 && saidas === 0 && !desc && !supplier) continue;
    // Skip balance-only rows (no date, no supplier, no desc)
    if (!dateVal && !supplier && !desc) continue;

    const dateStr = excelDateToISO(dateVal, year, month);

    transactions.push({
      date: dateStr,
      ref: str(row[1]),
      supplier,
      description: desc || supplier,
      allocation,
      credit: entradas,
      debit: saidas,
      balance,
    });
  }

  const results: ParsedPettyCashResult[] = [];
  if (transactions.length > 0) {
    results.push({ transactions, month, year, sheetName });
  }

  // Also check for "Pre-paid" sheet (same structure)
  const prepaidName = wb.SheetNames.find(
    (s) => s.toLowerCase().trim() === 'pre-paid'
  );
  if (prepaidName) {
    const ws2 = wb.Sheets[prepaidName];
    const rows2: unknown[][] = XLSX.utils.sheet_to_json(ws2, { header: 1, defval: null });

    let dataStart2 = -1;
    for (let i = 0; i < Math.min(rows2.length, 15); i++) {
      const c0 = str(rows2[i]?.[0]).toUpperCase();
      if (c0 === 'DATA' || c0 === 'DATE') {
        dataStart2 = i + 1;
        break;
      }
    }

    if (dataStart2 > 0) {
      const txns: ParsedPettyCash[] = [];
      for (let i = dataStart2; i < rows2.length; i++) {
        const row = rows2[i];
        if (!row) continue;
        const supplier = str(row[2]);
        const desc = str(row[3]);
        const entradas = num(row[5]);
        const saidas = num(row[6]);
        if (entradas === 0 && saidas === 0 && !desc && !supplier) continue;
        if (!row[0] && !supplier && !desc) continue;

        txns.push({
          date: excelDateToISO(row[0], year, month),
          ref: str(row[1]),
          supplier,
          description: desc || supplier,
          allocation: str(row[4]),
          credit: entradas,
          debit: saidas,
          balance: num(row[7]),
        });
      }
      if (txns.length > 0) {
        results.push({ transactions: txns, month, year, sheetName: prepaidName });
      }
    }
  }

  return results;
}
