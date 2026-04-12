import * as XLSX from 'xlsx';

export interface ParsedIncome {
  date: string;
  house: string;
  guest_name: string;
  accommodation_amount_mzn: number;
  amount_usd: number;
  description: string;
}

export interface ParsedExpense {
  date: string;
  supplier: string;
  description: string;
  amount_mzn: number;
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

function excelDateToISO(v: unknown): string {
  if (!v) return '';
  if (v instanceof Date) return v.toISOString().split('T')[0];
  if (typeof v === 'number') {
    const d = new Date((v - 25569) * 86400 * 1000);
    return d.toISOString().split('T')[0];
  }
  return '';
}

// Expense category columns from the EXPENSES sheet (row 5 headers)
const EXPENSE_CATEGORIES = [
  'LC SALARIES & WAGES',
  'CASUAL WORKERS AND ALLOWANCE',
  'ADVANCE SALARIES',
  'OFFICE AND BANK CHARGES',
  'ADMIN CHARGES',
  'GAS AND ELECTRICITY',
  'MAINTENANCE GENERAL',
  'MAINTENANCE GARDEN & POOL',
  'SMALL TOOLS',
  'EQUIPMENT',
  'MAINTENANCE VEHICLES',
  'INSURANCE & LICENSE',
  'DIESEL AND PETROL',
  'HOUSE KEEPING',
  'MARITIME & MUNICIPAL TAXES',
];

export function parseMonthEnd(file: ArrayBuffer, month: number, year: number): ParsedMonthEndResult {
  const wb = XLSX.read(file, { type: 'array', cellDates: true });

  // === INCOME sheet ===
  const income: ParsedIncome[] = [];
  const incSheet = wb.Sheets['INCOME'];
  if (incSheet) {
    const rows: unknown[][] = XLSX.utils.sheet_to_json(incSheet, { header: 1, defval: null, raw: false });
    // Find data header row (DATE, HOUSE, NAME, ACCOMODATION...)
    let dataStart = -1;
    for (let i = 0; i < Math.min(rows.length, 10); i++) {
      if (str(rows[i]?.[0]) === 'DATE') { dataStart = i + 1; break; }
    }
    if (dataStart > 0) {
      for (let i = dataStart; i < rows.length; i++) {
        const row = rows[i];
        if (!row) continue;
        const dateVal = str(row[0]);
        const house = str(row[1]);
        const guest = str(row[2]);
        const accom = num(row[3]);
        if (!dateVal && !guest) continue;
        if (accom === 0 && !guest) continue;
        income.push({
          date: dateVal || `${year}-${String(month).padStart(2, '0')}-01`,
          house,
          guest_name: guest,
          accommodation_amount_mzn: accom,
          amount_usd: num(row[9]),
          description: `${guest} - ${house}`,
        });
      }
    }
  }

  // === EXPENSES sheet ===
  const expenses: ParsedExpense[] = [];
  const expSheet = wb.Sheets[' EXPENSES'] || wb.Sheets['EXPENSES'];
  if (expSheet) {
    const rows: unknown[][] = XLSX.utils.sheet_to_json(expSheet, { header: 1, defval: null, raw: false });
    // Find header row with DATE, SUPPLIER, DESCRIPTION
    let dataStart = -1;
    for (let i = 0; i < Math.min(rows.length, 10); i++) {
      if (str(rows[i]?.[0]) === 'DATE') { dataStart = i + 1; break; }
    }
    if (dataStart > 0) {
      for (let i = dataStart; i < rows.length; i++) {
        const row = rows[i];
        if (!row) continue;
        const total = num(row[4]);
        const supplier = str(row[1]);
        const desc = str(row[2]);
        if (!total && !supplier) continue;
        if (total === 0) continue;

        // Determine category from which column has a value
        let category = 'General';
        for (let c = 5; c < Math.min(row.length, 5 + EXPENSE_CATEGORIES.length); c++) {
          if (num(row[c]) !== 0) {
            category = EXPENSE_CATEGORIES[c - 5] || 'General';
            break;
          }
        }

        expenses.push({
          date: str(row[0]) || `${year}-${String(month).padStart(2, '0')}-01`,
          supplier,
          description: desc || supplier,
          amount_mzn: total,
          category,
          is_shared: true,
        });
      }
    }
  }

  return { income, expenses, month, year };
}
