import * as XLSX from 'xlsx';

export interface ParsedBimTransfer {
  name: string;
  nib: string;
  amount: number;
  description: string;
}

export interface ParsedBimResult {
  transfers: ParsedBimTransfer[];
  month: number;
  year: number;
}

const num = (v: unknown): number => {
  if (v == null || v === '') return 0;
  const n = Number(v);
  return isNaN(n) ? 0 : n;
};
const str = (v: unknown): string => (v == null ? '' : String(v).trim());

export function parseBimTransfers(file: ArrayBuffer, month: number, year: number): ParsedBimResult {
  const wb = XLSX.read(file, { type: 'array' });
  const ws = wb.Sheets[wb.SheetNames[0]];
  const rows: unknown[][] = XLSX.utils.sheet_to_json(ws, { header: 1, defval: null });

  const transfers: ParsedBimTransfer[] = [];

  for (let i = 0; i < rows.length; i++) {
    const row = rows[i];
    if (!row) continue;
    const name = str(row[1] || row[2]);
    const nib = str(row[3] || row[4]);
    // Look for rows with a name, NIB-like number, and amount
    if (name && nib.length >= 6 && num(row[5] || row[4] || row[6]) > 0) {
      // Try to find amount column (usually last significant column)
      let amount = 0;
      for (let c = row.length - 1; c >= 3; c--) {
        const v = num(row[c]);
        if (v > 0) { amount = v; break; }
      }
      if (amount > 0) {
        transfers.push({ name, nib, amount, description: `Salary transfer ${month}/${year}` });
      }
    }
  }

  return { transfers, month, year };
}
