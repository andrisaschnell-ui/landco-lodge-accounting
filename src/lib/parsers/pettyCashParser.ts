import * as XLSX from 'xlsx';

export interface ParsedPettyCash {
  date: string;
  description: string;
  credit: number;
  debit: number;
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

export function parsePettyCash(file: ArrayBuffer, month: number, year: number): ParsedPettyCashResult[] {
  const wb = XLSX.read(file, { type: 'array', cellDates: true });
  const results: ParsedPettyCashResult[] = [];

  // Parse the main MET cash sheet (LANDCO MET CASH) which has monthly summaries
  // Also parse individual sheets like RSDFuel, Warren Cohen, etc.
  for (const sheetName of wb.SheetNames) {
    const ws = wb.Sheets[sheetName];
    const rows: unknown[][] = XLSX.utils.sheet_to_json(ws, { header: 1, defval: null, raw: false });

    // Find header row with DATE, DETAILS, CR, DR, BAL pattern
    let dataStart = -1;
    for (let i = 0; i < Math.min(rows.length, 10); i++) {
      const r = rows[i];
      if (!r) continue;
      if (str(r[0]).toUpperCase() === 'DATE' && str(r[1]).toUpperCase().includes('DETAIL')) {
        dataStart = i + 1;
        break;
      }
    }

    if (dataStart === -1) continue;

    const transactions: ParsedPettyCash[] = [];
    for (let i = dataStart; i < rows.length; i++) {
      const row = rows[i];
      if (!row) continue;
      const dateStr = str(row[0]);
      const desc = str(row[1]);
      if (!dateStr && !desc) continue;
      const cr = num(row[2]);
      const dr = num(row[3]);
      const bal = num(row[4]);
      if (cr === 0 && dr === 0) continue;

      transactions.push({
        date: dateStr || `${year}-${String(month).padStart(2, '0')}-01`,
        description: desc,
        credit: cr,
        debit: dr,
        balance: bal,
      });
    }

    if (transactions.length > 0) {
      results.push({ transactions, month, year, sheetName });
    }
  }

  return results;
}
