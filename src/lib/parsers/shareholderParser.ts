import * as XLSX from 'xlsx';

export interface ParsedShareholderBalance {
  shareholder_name: string; // From file name or sheet
  property_code: string;     // H1, H2, H3, H4
  month: number;
  year: number;
  opening_balance: number;
  income: number;
  expenses: number;
  closing_balance: number;
}

export interface ParsedShareholderResult {
  balances: ParsedShareholderBalance[];
  month: number;
  year: number;
}

export function parseShareholderWorkbook(file: ArrayBuffer, month: number, year: number, filename: string): ParsedShareholderResult {
  const wb = XLSX.read(file, { type: 'array' });
  const sheetName = wb.SheetNames.find(s => s.trim().toUpperCase() === 'SUMMERY');
  if (!sheetName) throw new Error('Could not find "SUMMERY" sheet in this workbook');
  const ws = wb.Sheets[sheetName];
  const rows: any[][] = XLSX.utils.sheet_to_json(ws, { header: 1, defval: null });

  // Determine property code from filename
  const upperFile = filename.toUpperCase();
  let property_code = '';
  if (upperFile.includes('LUZ')) property_code = 'H1';
  else if (upperFile.includes('AURORA')) property_code = 'H2';
  else if (upperFile.includes('CAJU')) property_code = 'H3';
  else if (upperFile.includes('COCO')) property_code = 'H4';
  
  if (!property_code) {
      // Try parsing from Row 0
      const row0 = String(rows[0]?.[0] || '').toUpperCase();
      if (row0.includes('LUZ')) property_code = 'H1';
      else if (row0.includes('AURORA')) property_code = 'H2';
      else if (row0.includes('CAJU')) property_code = 'H3';
      else if (row0.includes('COCO')) property_code = 'H4';
  }

  if (!property_code) throw new Error('Could not determine Property Code (H1-H4) from workbook or filename');

  // Row 2 (index 2): [ 'Opening Balance', value ]
  const initial_balance = Number(rows[2]?.[1] || 0);

  // Calculate opening balance for the selected month by summing all prior months
  let prior_income = 0;
  let prior_expenses = 0;
  for (let m = 1; m < month; m++) {
    const rIdx = m + 2;
    const r = rows[rIdx];
    if (r) {
      prior_income += Number(r[1] || 0);
      prior_expenses += Number(r[4] || 0);
    }
  }

  const opening_balance = initial_balance + prior_income - prior_expenses;

  // Row month+2: [ 'MonthName', income, null, 'MonthName', expenses ]
  const rowIndex = month + 2;
  const row = rows[rowIndex];
  if (!row) throw new Error(`Could not find data for month ${month} (Row ${rowIndex + 1})`);

  const income = Number(row[1] || 0);
  const expenses = Number(row[4] || 0);

  // Closing balance = Opening + Income - Expenses
  const closing_balance = opening_balance + income - expenses;

  return {
    balances: [{
      shareholder_name: String(rows[0]?.[0] || 'Unknown'),
      property_code,
      month,
      year,
      opening_balance,
      income,
      expenses,
      closing_balance
    }],
    month,
    year
  };
}
