import * as XLSX from 'xlsx';

// Per-line expense parser for the " EXPENSES" sheet inside MONTH END workbooks.
// Header row = 6. Columns:
//   A=DATE, B=SUPPLIER, C=DESCRIPTION, E=TOTAL, F..AA=category amounts.
// Each non-zero category cell on a data row produces one expense line.

export interface ParsedExpenseLine {
  date: string;            // ISO yyyy-mm-dd or ''
  supplier: string;
  description: string;
  amount_mzn: number;
  category: string;        // human-readable category name written to expense_categories.name
  is_shared: boolean;      // true → split 25% across 4 houses on the report side
  property_code: string | null;   // 'H1'..'H4' for house-specific columns; otherwise null
}

export interface ParsedExpensesResult {
  lines: ParsedExpenseLine[];
  month: number;
  year: number;
  totals: { perCategory: Record<string, number>; grand: number };
  unmappedColumns: string[];
}

interface ColMap {
  index: number;          // 0-based column index
  rawHeader: string;
  category: string;
  is_shared: boolean;
  property_code: string | null;
  skip: boolean;
}

// Map from normalised header text → mapping rule.
const HEADER_RULES: Array<{ match: RegExp; category: string; is_shared: boolean; property_code: string | null; skip?: boolean }> = [
  { match: /^LC SALARIES/i,                         category: 'Salaries',         is_shared: true,  property_code: null },
  { match: /CASUAL WORKERS/i,                       category: 'Casual Labour',    is_shared: true,  property_code: null },
  { match: /ADVANCE SALARIES/i,                     category: '',                 is_shared: false, property_code: null, skip: true },
  { match: /OFFICE AND BANK/i,                      category: 'Office',           is_shared: true,  property_code: null },
  { match: /ADMIN CHARGES/i,                        category: 'Admin',            is_shared: true,  property_code: null },
  { match: /GAS AND ELECTR/i,                       category: 'Utilities',        is_shared: true,  property_code: null },
  { match: /MAINTENANCE GENERAL/i,                  category: 'Maintenance',      is_shared: true,  property_code: null },
  { match: /MAINTENANCE GARDEN/i,                   category: 'Garden & Pool',    is_shared: true,  property_code: null },
  { match: /SMALL TOOLS/i,                          category: 'Small Tools',      is_shared: true,  property_code: null },
  { match: /^EQUIPMENT/i,                           category: 'Equipment',        is_shared: true,  property_code: null },
  { match: /MAINTENANCE VEHICLES/i,                 category: 'Vehicles',         is_shared: true,  property_code: null },
  { match: /INSURANCE/i,                            category: 'Insurance',        is_shared: true,  property_code: null },
  { match: /DIESEL|PETROL/i,                        category: 'Fuel',             is_shared: true,  property_code: null },
  { match: /HOUSE KEEPING|HOUSEKEEPING/i,           category: 'Housekeeping',     is_shared: true,  property_code: null },
  { match: /MUNICIPAL TAXES|IPRA|TAE|MARINTINE|MARITIME/i, category: 'Taxes',     is_shared: true,  property_code: null },
  { match: /COMMUNITY/i,                            category: 'Community',        is_shared: true,  property_code: null },
  { match: /EXPENSES LUZ|^LUZ$/i,                   category: 'House Expense',    is_shared: false, property_code: 'H1' },
  { match: /EXPENSES AURORA|^AURORA$/i,             category: 'House Expense',    is_shared: false, property_code: 'H2' },
  { match: /EXPENSES CAJU|^CAJU$/i,                 category: 'House Expense',    is_shared: false, property_code: 'H3' },
  { match: /EXPENSES COCO|^COCO$/i,                 category: 'House Expense',    is_shared: false, property_code: 'H4' },
  { match: /SUSPEN[CS]E/i,                          category: '',                 is_shared: false, property_code: null, skip: true },
  { match: /^BALANCE$/i,                            category: '',                 is_shared: false, property_code: null, skip: true },
  { match: /NEGU/i,                                 category: '',                 is_shared: false, property_code: null, skip: true },
  { match: /^TOTAL$/i,                              category: '',                 is_shared: false, property_code: null, skip: true },
];

const num = (v: unknown): number => {
  if (v == null || v === '') return 0;
  const n = Number(v);
  return isNaN(n) ? 0 : n;
};
const str = (v: unknown): string => (v == null ? '' : String(v).trim());

function excelDateToISO(v: unknown): string {
  if (v == null || v === '') return '';
  if (v instanceof Date) return v.toISOString().slice(0, 10);
  if (typeof v === 'number') {
    // Excel serial → JS date
    const ms = Math.round((v - 25569) * 86400 * 1000);
    return new Date(ms).toISOString().slice(0, 10);
  }
  const s = String(v).trim();
  const d = new Date(s);
  return isNaN(d.getTime()) ? '' : d.toISOString().slice(0, 10);
}

function findExpensesSheet(wb: XLSX.WorkBook): string | null {
  // Sheet name in source workbooks is " EXPENSES" (leading space). Tolerant match.
  const target = wb.SheetNames.find((n) => n.trim().toUpperCase() === 'EXPENSES');
  return target ?? null;
}

function buildColumnMap(headerRow: unknown[]): { cols: ColMap[]; unmapped: string[] } {
  const cols: ColMap[] = [];
  const unmapped: string[] = [];
  for (let i = 0; i < headerRow.length; i++) {
    const raw = str(headerRow[i]);
    if (!raw) continue;
    if (i < 5) continue; // A..D + E (TOTAL) handled separately
    const rule = HEADER_RULES.find((r) => r.match.test(raw));
    if (!rule) {
      unmapped.push(`col ${i + 1}: ${raw}`);
      continue;
    }
    cols.push({
      index: i,
      rawHeader: raw,
      category: rule.category,
      is_shared: rule.is_shared,
      property_code: rule.property_code,
      skip: rule.skip ?? false,
    });
  }
  return { cols, unmapped };
}

export function parseExpenses(buffer: ArrayBuffer, month: number, year: number): ParsedExpensesResult {
  const wb = XLSX.read(buffer, { type: 'array', cellDates: true });
  const sheetName = findExpensesSheet(wb);
  if (!sheetName) {
    throw new Error(`Sheet "EXPENSES" not found. Available: ${wb.SheetNames.join(', ')}`);
  }
  const ws = wb.Sheets[sheetName];
  const aoa = XLSX.utils.sheet_to_json<unknown[]>(ws, { header: 1, defval: null, raw: true });

  // Header is on row 6 (1-indexed) → index 5
  const HEADER_ROW = 5;
  const header = (aoa[HEADER_ROW] as unknown[]) ?? [];
  const { cols, unmapped } = buildColumnMap(header);

  const lines: ParsedExpenseLine[] = [];
  const perCategory: Record<string, number> = {};
  let grand = 0;

  for (let r = HEADER_ROW + 1; r < aoa.length; r++) {
    const row = aoa[r] as unknown[];
    if (!row) continue;
    const dateRaw = row[0];
    const supplier = str(row[1]);
    const description = str(row[2]);
    // skip blank rows
    if (!dateRaw && !supplier && !description) continue;
    // skip footer/section rows that have no date AND no numeric data
    const date = excelDateToISO(dateRaw);

    for (const col of cols) {
      if (col.skip) continue;
      const amt = num(row[col.index]);
      if (amt === 0) continue;
      const line: ParsedExpenseLine = {
        date,
        supplier,
        description: description || col.rawHeader,
        amount_mzn: amt,
        category: col.category,
        is_shared: col.is_shared,
        property_code: col.property_code,
      };
      lines.push(line);
      perCategory[col.category] = (perCategory[col.category] ?? 0) + amt;
      grand += amt;
    }
  }

  return {
    lines,
    month,
    year,
    totals: { perCategory, grand },
    unmappedColumns: unmapped,
  };
}
