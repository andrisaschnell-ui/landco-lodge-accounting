import * as XLSX from 'xlsx';

export interface ParsedBankTransaction {
  date: string;
  description: string;
  reference: string;
  debit: number;
  credit: number;
  balance: number;
}

export interface ParsedBdoResult {
  transactions: ParsedBankTransaction[];
  month: number;
  year: number;
}

const num = (v: unknown): number => {
  if (v == null || v === '') return 0;
  const n = Number(v);
  return isNaN(n) ? 0 : n;
};
const str = (v: unknown): string => (v == null ? '' : String(v).trim());

export function parseBdoBank(file: ArrayBuffer, month: number, year: number): ParsedBdoResult {
  const wb = XLSX.read(file, { type: 'array', cellDates: true });
  const ws = wb.Sheets[wb.SheetNames[0]];
  const rows: unknown[][] = XLSX.utils.sheet_to_json(ws, { header: 1, defval: null, raw: false });

  const transactions: ParsedBankTransaction[] = [];

  // Find header row (DATE, DESCRIPTION/DETAILS, DEBIT, CREDIT, BALANCE)
  let dataStart = -1;
  for (let i = 0; i < Math.min(rows.length, 15); i++) {
    const r = rows[i];
    if (!r) continue;
    const first = str(r[0]).toUpperCase();
    if (first === 'DATE' || first === 'DATA') {
      dataStart = i + 1;
      break;
    }
  }

  if (dataStart === -1) {
    // Try scanning for first date-like value
    for (let i = 0; i < rows.length; i++) {
      const v = rows[i]?.[0];
      if (v && (v instanceof Date || (typeof v === 'string' && /^\d{4}-\d{2}-\d{2}/.test(v)))) {
        dataStart = i;
        break;
      }
    }
  }

  if (dataStart > 0) {
    for (let i = dataStart; i < rows.length; i++) {
      const row = rows[i];
      if (!row) continue;
      const dateStr = str(row[0]);
      const desc = str(row[1]) || str(row[2]);
      if (!dateStr && !desc) continue;
      const debit = num(row[3] ?? row[2]);
      const credit = num(row[4] ?? row[3]);
      const balance = num(row[5] ?? row[4]);
      if (debit === 0 && credit === 0 && !desc) continue;

      transactions.push({
        date: dateStr || `${year}-${String(month).padStart(2, '0')}-01`,
        description: desc,
        reference: str(row[2] || ''),
        debit,
        credit,
        balance,
      });
    }
  }

  return { transactions, month, year };
}
