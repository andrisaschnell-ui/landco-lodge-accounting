import * as XLSX from 'xlsx';

export interface ParsedSalaryLine {
  employee_name: string;
  house_code: string;
  category: string;
  base_salary: number;
  food_allowance: number;
  back_payment: number;
  days_worked: number;
  monthly_salary: number;
  nightshift_hours: number;
  overtime_25_percent: number;
  overtime_15x_hours: number;
  overtime_15x_amount: number;
  overtime_2x_hours: number;
  overtime_2x_amount: number;
  gratification: number;
  holiday_days: number;
  holiday_amount: number;
  gross_total: number;
  advance: number;
  irps: number;
  debt: number;
  inss_employee: number;
  sind: number;
  total_deductions: number;
  net_salary: number;
  nib: string;
}

export interface ParsedSalaryResult {
  lines: ParsedSalaryLine[];
  month: number;
  year: number;
}

const num = (v: unknown): number => {
  if (v == null || v === '' || v === '#REF!') return 0;
  const n = Number(v);
  return isNaN(n) ? 0 : n;
};

const str = (v: unknown): string => (v == null ? '' : String(v).trim());

export function parseSalarySheet(file: ArrayBuffer, month: number, year: number): ParsedSalaryResult {
  const wb = XLSX.read(file, { type: 'array' });
  // First sheet is "Folha de salarios"
  const ws = wb.Sheets[wb.SheetNames[0]];
  const rows: unknown[][] = XLSX.utils.sheet_to_json(ws, { header: 1, defval: null });

  // Find header row (row with "NO" in col A and "NOME DO TRABALHADOR" in col C)
  let headerIdx = -1;
  for (let i = 0; i < Math.min(rows.length, 15); i++) {
    if (str(rows[i]?.[0]) === 'NO' && str(rows[i]?.[2]).includes('NOME')) {
      headerIdx = i;
      break;
    }
  }
  if (headerIdx === -1) throw new Error('Could not find salary header row');

  // Data starts 2 rows after header (skip sub-header)
  const dataStart = headerIdx + 2;
  const lines: ParsedSalaryLine[] = [];

  // Second sheet "Sindicate" has NIBs - build lookup
  const nibMap = new Map<string, string>();
  if (wb.SheetNames.length > 1) {
    const ws2 = wb.Sheets[wb.SheetNames[1]];
    const rows2: unknown[][] = XLSX.utils.sheet_to_json(ws2, { header: 1, defval: null });
    for (const row of rows2) {
      const name = str(row[2]);
      const nib = str(row[8]);
      if (name && nib && /^\d+$/.test(nib)) {
        nibMap.set(name.toUpperCase(), nib);
      }
    }
  }

  for (let i = dataStart; i < rows.length; i++) {
    const row = rows[i];
    if (!row) continue;
    const no = num(row[0]);
    const name = str(row[2]);
    if (!no || !name) continue; // skip non-employee rows

    const line: ParsedSalaryLine = {
      employee_name: name,
      house_code: str(row[1]),
      category: str(row[6]),
      base_salary: num(row[7]),
      food_allowance: num(row[9]),
      back_payment: num(row[10]),
      days_worked: num(row[11]),
      monthly_salary: num(row[12]),
      nightshift_hours: num(row[13]),
      overtime_25_percent: num(row[14]),
      overtime_15x_hours: num(row[15]),
      overtime_15x_amount: num(row[16]),
      overtime_2x_hours: num(row[17]),
      overtime_2x_amount: num(row[18]),
      gratification: num(row[20]),
      holiday_days: num(row[21]),
      holiday_amount: num(row[22]),
      gross_total: num(row[23]),
      advance: num(row[24]),
      irps: num(row[25]),
      debt: num(row[26]),
      inss_employee: num(row[27]),
      sind: num(row[28]),
      total_deductions: num(row[29]),
      net_salary: 0,
      nib: nibMap.get(name.toUpperCase()) || '',
    };
    // net = gross - deductions
    line.net_salary = line.gross_total - line.total_deductions;
    lines.push(line);
  }

  return { lines, month, year };
}
