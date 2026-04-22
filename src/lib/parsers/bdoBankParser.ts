import * as XLSX from 'xlsx';

export interface ParsedBankTransaction {
  date: string;
  description: string;
  reference: string;
  company: string;
  allocation: string;
  debit: number;   // Saídas (outflows)
  credit: number;  // Entradas (inflows)
  balance: number;
  iva: number;
  currency: string;
}

export interface ParsedOpeningBalance {
  currency: string;
  opening_balance: number;
  date: string;
}

export interface ParsedBdoResult {
  transactions: ParsedBankTransaction[];
  openingBalances: ParsedOpeningBalance[];
  month: number;
  year: number;
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

function parseSheetTransactions(
  wb: XLSX.WorkBook,
  sheetName: string,
  currency: string,
  month: number,
  year: number
): ParsedBankTransaction[] {
  const ws = wb.Sheets[sheetName];
  if (!ws) return [];

  const rows: unknown[][] = XLSX.utils.sheet_to_json(ws, {
    header: 1, defval: null, raw: false,
  });
  // Re-read with cellDates for proper date handling
  const rowsDates: unknown[][] = XLSX.utils.sheet_to_json(
    XLSX.read(XLSX.write(wb, { type: 'array', bookType: 'xlsx' }), { type: 'array', cellDates: true }).Sheets[sheetName],
    { header: 1, defval: null }
  );

  const transactions: ParsedBankTransaction[] = [];

  // BIM Bank Control layout:
  // Col 0: Nº Doc, Col 1: Data, Col 2: Nº Cheque/Documento
  // Col 3: Empresa, Col 4: Descrição, Col 5: Allocação
  // Col 6: Entradas (credits), Col 7: Saídas (debits), Col 8: Saldo
  // Col 9: IVA, Col 10: Nett expense/income

  // Find header row containing "Nº" or "Doc" in col 0 and "Data" in col 1
  let dataStart = -1;
  for (let i = 0; i < Math.min(rows.length, 15); i++) {
    const r = rows[i];
    if (!r) continue;
    const c0 = str(r[0]).toUpperCase();
    if (c0.includes('N') && (str(r[1]).toUpperCase().includes('DATA') || str(r[1]).toUpperCase().includes('DATE'))) {
      // Next row might be sub-header ("Doc"), skip it too
      dataStart = i + 2;
      break;
    }
  }

  if (dataStart === -1) {
    // Fallback: find first row with a date-like value in col 1
    for (let i = 0; i < rows.length; i++) {
      const v = rowsDates[i]?.[1];
      if (v instanceof Date || (typeof rows[i]?.[1] === 'string' && /^\d{4}/.test(str(rows[i]?.[1])))) {
        dataStart = i;
        break;
      }
    }
  }

  if (dataStart < 0) return transactions;

  for (let i = dataStart; i < rows.length; i++) {
    const row = rows[i];
    const rowD = rowsDates[i];
    if (!row) continue;

    const desc = str(row[4]);
    const company = str(row[3]);
    const entradas = num(row[6]); // credits (money in)
    const saidas = num(row[7]);   // debits (money out)
    const balance = num(row[8]);
    const iva = num(row[9]);

    // Skip empty rows
    if (entradas === 0 && saidas === 0 && !desc) continue;
    // Skip BALANCE CARRY FORWARD rows — these are opening balances from previous month, not transactions
    const descUp = desc.toUpperCase();
    if (descUp.includes('BALANCE CARRY FORWARD') || descUp.includes('BALANCE FORWARD') || descUp.includes('SALDO TRANSPORTE')) {
      continue;
    }

    const dateVal = rowD?.[1] ?? row[1];
    const dateStr = excelDateToISO(dateVal, year, month);

    transactions.push({
      date: dateStr,
      description: desc || company,
      reference: str(row[2]),
      company,
      allocation: str(row[5]),
      credit: entradas,
      debit: saidas,
      balance,
      iva,
      currency,
    });
  }

  return transactions;
}

export function parseBdoBank(file: ArrayBuffer, month: number, year: number): ParsedBdoResult {
  const wb = XLSX.read(file, { type: 'array', cellDates: true });

  const transactions: ParsedBankTransaction[] = [];

  // Parse both BIM Bank Control sheets
  const mtnNames = wb.SheetNames.filter(
    (s) => s.toLowerCase().includes('bank control') && s.toLowerCase().includes('mtn')
  );
  const usdNames = wb.SheetNames.filter(
    (s) => s.toLowerCase().includes('bank control') && s.toLowerCase().includes('usd')
  );

  for (const name of mtnNames) {
    transactions.push(...parseSheetTransactions(wb, name, 'MZN', month, year));
  }
  for (const name of usdNames) {
    transactions.push(...parseSheetTransactions(wb, name, 'USD', month, year));
  }

  return { transactions, month, year };
}
