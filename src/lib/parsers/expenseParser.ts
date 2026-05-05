import * as XLSX from 'xlsx';

export interface ParsedExpenseTransaction {
  date: string;
  supplier: string;
  description: string;
  amount_mzn: number;
  category_name: string;
  house_code: string; // 'LC', 'H1', 'H2', 'H3', 'H4'
  is_shared: boolean;
  is_salary: boolean;
}

export interface ParsedExpenseResult {
  transactions: ParsedExpenseTransaction[];
  month: number;
  year: number;
}

const CATEGORY_MAP: Record<string, string> = {
  'LC SALARIES & WAGES': 'SALARIES & WAGES',
  'CASUAL WORKERS AND ALLOWANCE': 'CASUAL WORKERS AND FOOD ALLOWANCE',
  'FOOD AND BEVERAGES': 'FOOD & PROVISIONS',
  'OFFICE AND BANK CHARGES': 'OFFICE AND BANK CHARGES',
  'ADMIN CHARGES (BDO & ANDRISA )': 'ADMIN CHARGES (BDO & ANDRISA)',
  'GAS AND ELECTRISITY': 'GAS AND ELECTRICITY',
  'MAINTENANCE GENERAL': 'MAINTENANCE GENERAL',
  'MAINTENANCE GARDEN & POOL': 'MAINTENANCE GARDEN & POOL',
  'SMALL TOOLS': 'SMALL TOOLS',
  'EQUIPMENT': 'EQUIPMENT',
  'MAINTENANCE VEHICLES': 'MAINTENANCE VEHICLES',
  'INSURANCE & LICENSE': 'INSURANCE & LICENSE',
  'DIESEL AND PETROL': 'DIESEL AND PETROL',
  'HOUSE KEEPING': 'HOUSE KEEPING',
  'MARINTINE & MUNICIPAL TAXES IPRA &TAE': 'MARITIME & MUNICIPAL TAXES IPRA & TAE',
  'COMMUNITY': 'COMMUNITY',
  'EXPENSES LUZ': 'EXPENSES LUZ',
  'EXPENSES AURORA': 'EXPENSES AURORA',
  'EXPENSES CAJU': 'EXPENSES CAJU',
  'EXPENSES COCO': 'EXPENSES COCO',
  'SUSPENCE': 'SUSPENSE',
};

const HOUSE_COLS = {
  'LC': 5,
  'H1': 21,
  'H2': 22,
  'H3': 23,
  'H4': 24
};

export function parseExpenseSheet(file: ArrayBuffer, month: number, year: number): ParsedExpenseResult {
  const wb = XLSX.read(file, { type: 'array' });
  const sheetName = wb.SheetNames.find(s => s.trim() === 'EXPENSES');
  if (!sheetName) throw new Error('Could not find "EXPENSES" sheet in this workbook');
  const ws = wb.Sheets[sheetName];
  const rows: any[][] = XLSX.utils.sheet_to_json(ws, { header: 1, defval: null });

  const headers = rows[5];
  if (!headers || !headers[0] || String(headers[0]).toUpperCase() !== 'DATE') {
    throw new Error('Could not find header row at row 6 (Column A must be DATE)');
  }

  const transactions: ParsedExpenseTransaction[] = [];

  for (let i = 6; i < rows.length; i++) {
    const row = rows[i];
    if (!row || !row[0]) continue; // Skip empty date

    const dateVal = row[0];
    let dateStr = '';
    if (typeof dateVal === 'number') {
      const d = new Date((dateVal - 25569) * 86400 * 1000);
      dateStr = d.toISOString().split('T')[0];
    } else {
      dateStr = String(dateVal);
    }

    const supplier = String(row[1] || '').trim();
    const description = String(row[2] || '').trim();
    const total = Number(row[4] || 0);

    if (total === 0 && !supplier.includes('SALARIES')) continue;

    const isSalaryRow = supplier.toUpperCase().includes('SALARIES');

    if (isSalaryRow) {
      // For Salaries, we create a placeholder that the service will expand using DB data
      transactions.push({
        date: dateStr,
        supplier,
        description,
        amount_mzn: total,
        category_name: 'SALARIES & WAGES',
        house_code: 'LC', // Default to LC, service will split
        is_shared: true,
        is_salary: true
      });
    } else {
      // Find which category column has the value
      let foundCategory = false;
      for (let j = 5; j <= 25; j++) {
        const val = Number(row[j] || 0);
        if (val !== 0) {
          const rawHeader = String(headers[j] || '');
          const catName = CATEGORY_MAP[rawHeader] || rawHeader;
          
          let houseCode = 'LC';
          let isShared = true;

          if (j === 21) { houseCode = 'H1'; isShared = false; }
          else if (j === 22) { houseCode = 'H2'; isShared = false; }
          else if (j === 23) { houseCode = 'H3'; isShared = false; }
          else if (j === 24) { houseCode = 'H4'; isShared = false; }

          transactions.push({
            date: dateStr,
            supplier,
            description,
            amount_mzn: val,
            category_name: catName,
            house_code: houseCode,
            is_shared: isShared,
            is_salary: false
          });
          foundCategory = true;
          // We break after first found category per row to avoid duplicates if multiple cols filled
          // (though usually only one is filled)
          break;
        }
      }
      
      // Fallback if total is set but no specific category column is filled (goes to SUSPENSE)
      if (!foundCategory && total !== 0) {
        transactions.push({
          date: dateStr,
          supplier,
          description,
          amount_mzn: total,
          category_name: 'SUSPENSE',
          house_code: 'LC',
          is_shared: true,
          is_salary: false
        });
      }
    }
  }

  return { transactions, month, year };
}
