import * as XLSX from 'xlsx';

export interface ParsedIncome {
  date: string;
  invoice_no: string;
  guest_name: string;
  house: string;
  accommodation_amount_mzn: number;
  iva_amount: number;
  total_incl_iva: number;
  amount_usd: number;
  description: string;
}

export interface ParsedExpense {
  date: string;
  invoice_no: string;
  supplier: string;
  description: string;
  allocation: string;
  amount_mzn: number;
  iva_amount: number;
  total_incl_iva: number;
  category: string;
  is_shared: boolean;
}

export interface ParsedMonthEndResult {
  income: ParsedIncome[];
  expenses: ParsedExpense[];
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

export function parseMonthEnd(file: ArrayBuffer, month: number, year: number): ParsedMonthEndResult {
  const wb = XLSX.read(file, { type: 'array', cellDates: true });

  // === INCOME: Parse "Invoices" sheet ===
  const income: ParsedIncome[] = [];
  const invSheetName = wb.SheetNames.find(
    (s) => s.toLowerCase().trim() === 'invoices'
  );

  if (invSheetName) {
    const ws = wb.Sheets[invSheetName];
    const rows: unknown[][] = XLSX.utils.sheet_to_json(ws, { header: 1, defval: null });

    // Invoices layout:
    // Row 12: No, DATE, INV, (blank), AMOUNT VALOR, IVA AT, FACTURA
    // Row 13: (blank), DATA, FAC, DESCRIPTION/DESCRICAO, EXCL IVA, 0.16, TOTAL
    // Row 14: (blank), (blank), No, (blank), (blank), (blank), INCL IVA
    // Data starts row 15: [No, date, inv_no, description, amount_excl, iva, total_incl]

    // Find the header area (look for "No" in col 0 and "DATE" in col 1)
    let dataStart = -1;
    for (let i = 0; i < Math.min(rows.length, 20); i++) {
      const r = rows[i];
      if (!r) continue;
      const c0 = str(r[0]).toUpperCase();
      const c1 = str(r[1]).toUpperCase();
      if ((c0 === 'NO' || c0 === 'Nº') && (c1.includes('DATE') || c1.includes('DATA'))) {
        // Data starts 3 rows after (skip 2 sub-header rows)
        dataStart = i + 3;
        break;
      }
    }

    if (dataStart > 0) {
      for (let i = dataStart; i < rows.length; i++) {
        const row = rows[i];
        if (!row) continue;
        const no = num(row[0]);
        const desc = str(row[3]);
        const amountExcl = num(row[4]);
        if (!no && !desc) continue;
        if (amountExcl === 0 && !desc) continue;

        income.push({
          date: excelDateToISO(row[1], year, month),
          invoice_no: str(row[2]),
          guest_name: desc,
          house: '', // Not in this sheet
          accommodation_amount_mzn: amountExcl,
          iva_amount: num(row[5]),
          total_incl_iva: num(row[6]),
          amount_usd: 0,
          description: desc,
        });
      }
    }
  }

  // === EXPENSES: Parse "Creditors" sheet ===
  const expenses: ParsedExpense[] = [];
  const credSheetName = wb.SheetNames.find(
    (s) => s.toLowerCase().trim() === 'creditors'
  );

  if (credSheetName) {
    const ws = wb.Sheets[credSheetName];
    const rows: unknown[][] = XLSX.utils.sheet_to_json(ws, { header: 1, defval: null });

    // Creditors layout:
    // Row 12: No, DATE, INV, SUPPLIER, DESCRIPTION, ALLOCATION, EXCL AMOUNT, IVA@16%, INCL AMOUNT
    let dataStart = -1;
    for (let i = 0; i < Math.min(rows.length, 20); i++) {
      const r = rows[i];
      if (!r) continue;
      const c0 = str(r[0]).toUpperCase();
      if ((c0 === 'NO' || c0 === 'Nº') && str(r[1]).toUpperCase().includes('DATE')) {
        dataStart = i + 1;
        break;
      }
    }

    if (dataStart > 0) {
      for (let i = dataStart; i < rows.length; i++) {
        const row = rows[i];
        if (!row) continue;

        const supplier = str(row[3]);
        const desc = str(row[4]);
        const allocation = str(row[5]);
        const amountExcl = num(row[6]);
        const iva = num(row[7]);
        const totalIncl = num(row[8]);

        // Skip empty rows and total rows
        if (!supplier && !desc && amountExcl === 0) continue;
        if (allocation.toUpperCase().includes('TOTAL')) continue;

        expenses.push({
          date: excelDateToISO(row[1], year, month),
          invoice_no: str(row[2]),
          supplier,
          description: desc || supplier,
          allocation,
          amount_mzn: amountExcl,
          iva_amount: iva,
          total_incl_iva: totalIncl,
          category: allocation || 'General',
          is_shared: true,
        });
      }
    }
  }

  return { income, expenses, month, year };
}
