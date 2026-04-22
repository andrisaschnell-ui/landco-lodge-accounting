import * as XLSX from 'xlsx';

export interface ParsedInvoiceLine {
  date: string;
  invoice_no: string;
  description: string;
  amount_excl_mzn: number;
  iva_mzn: number;
  total_mzn: number;
}

export interface ParsedInvoicesResult {
  invoices: ParsedInvoiceLine[];
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
  if (!v) return `${year}-${String(month).padStart(2, '0')}-01`;
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

/**
 * Parse the "Invoices" sheet of the BDO Bank Control workbook.
 * Layout (row 12-14 = composite header):
 *   Col 0: No, Col 1: DATE, Col 2: INV no
 *   Col 3: DESCRIPTION, Col 4: AMOUNT EXCL IVA
 *   Col 5: IVA AT 16%, Col 6: FACTURA TOTAL INCL IVA
 * Data rows start at row 15. Stops at the row labelled "TOTAL SALES".
 */
export function parseInvoices(file: ArrayBuffer, month: number, year: number): ParsedInvoicesResult {
  const wb = XLSX.read(file, { type: 'array', cellDates: true });
  const sheetName = wb.SheetNames.find((s) => s.toLowerCase().trim() === 'invoices');
  if (!sheetName) return { invoices: [], month, year };

  const ws = wb.Sheets[sheetName];
  const rows: unknown[][] = XLSX.utils.sheet_to_json(ws, { header: 1, defval: null });

  const invoices: ParsedInvoiceLine[] = [];
  for (let i = 0; i < rows.length; i++) {
    const row = rows[i];
    if (!row) continue;

    const desc = str(row[3]).toUpperCase();
    if (desc.startsWith('TOTAL SALES') || desc.startsWith('TOTAL VENDAS')) break;

    const total = num(row[6]);
    const amount = num(row[4]);
    const invNo = str(row[2]);
    if (total === 0 && amount === 0) continue;
    if (!invNo && !str(row[3])) continue;

    invoices.push({
      date: excelDateToISO(row[1], year, month),
      invoice_no: invNo,
      description: str(row[3]),
      amount_excl_mzn: amount,
      iva_mzn: num(row[5]),
      total_mzn: total,
    });
  }

  return { invoices, month, year };
}
