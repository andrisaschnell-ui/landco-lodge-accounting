import * as XLSX from 'xlsx';

export interface ParsedSalaryLine {
  employee_name: string;
  house_code: string;
  category: string;
  nuit: string;
  engagement_date: string | null;
  discharge_date: string | null;
  base_salary: number;
  food_allowance: number;
  back_payment: number;
  days_worked: number;
  monthly_salary: number;
  nightshift_hours: number;
  guardas_25: number;
  overtime_15x_hours: number;
  overtime_15x_amount: number;
  overtime_2x_hours: number;
  overtime_2x_amount: number;
  premios: number;
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

const date = (v: unknown): string | null => {
  if (v == null || v === '' || v === 'null') return null;
  // If it's a number (Excel date)
  if (typeof v === 'number') {
    const d = new Date((v - 25569) * 86400 * 1000);
    return d.toISOString().split('T')[0];
  }
  // If it's a string, try to parse it
  const s = String(v).trim();
  if (!s || s.toLowerCase() === 'engagement date' || s.toLowerCase() === 'discharge date') return null;
  return s;
};

function findSheet(wb: XLSX.WorkBook, candidates: string[]): XLSX.WorkSheet | null {
  for (const name of candidates) {
    if (wb.Sheets[name]) return wb.Sheets[name];
    const lower = name.toLowerCase();
    const match = wb.SheetNames.find(
      (s) => s.toLowerCase() === lower || s.toLowerCase().trim() === lower
    );
    if (match) return wb.Sheets[match];
  }
  for (const name of candidates) {
    const lower = name.toLowerCase();
    const match = wb.SheetNames.find((s) => s.toLowerCase().includes(lower));
    if (match) return wb.Sheets[match];
  }
  return null;
}

export function parseSalarySheet(file: ArrayBuffer, month: number, year: number): ParsedSalaryResult {
  const wb = XLSX.read(file, { type: 'array' });

  const ws = findSheet(wb, ['Folha de salarios', 'Folha de Salarios', 'FOLHA DE SALARIOS', 'Folha']);
  if (!ws) throw new Error('Could not find "Folha de salarios" sheet in this workbook');

  const rows: unknown[][] = XLSX.utils.sheet_to_json(ws, { header: 1, defval: null });

  let headerIdx = -1;
  for (let i = 0; i < Math.min(rows.length, 15); i++) {
    const r = rows[i];
    if (!r) continue;
    const col0 = str(r[0]).toUpperCase();
    const col2 = str(r[2]).toUpperCase();
    if (col0 === 'NO' && (col2.includes('NOME') || col2.includes('TRABALHADOR'))) {
      headerIdx = i;
      break;
    }
  }
  if (headerIdx === -1) throw new Error('Could not find salary header row (NO / NOME DO TRABALHADOR)');

  const dataStart = headerIdx + 2;
  const lines: ParsedSalaryLine[] = [];

  for (let i = dataStart; i < rows.length; i++) {
    const row = rows[i];
    if (!row) continue;
    const no = num(row[0]);
    const name = str(row[2]);
    if (!no || !name) continue; 

    const line: ParsedSalaryLine = {
      employee_name: name,
      house_code: str(row[1]),
      category: str(row[6]),
      nuit: str(row[5]),
      engagement_date: date(row[3]),
      discharge_date: date(row[4]),
      base_salary: num(row[7]),
      food_allowance: num(row[9]),
      back_payment: num(row[10]),
      days_worked: num(row[11]),
      monthly_salary: num(row[12]),
      nightshift_hours: num(row[13]),
      guardas_25: num(row[14]),
      overtime_15x_hours: num(row[15]),
      overtime_15x_amount: num(row[16]),
      overtime_2x_hours: num(row[17]),
      overtime_2x_amount: num(row[18]),
      premios: num(row[19]),
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
      net_salary: num(row[30]),
      nib: str(row[31]),
    };

    if (line.net_salary === 0 && line.gross_total > 0) {
      line.net_salary = line.gross_total - line.total_deductions;
    }

    lines.push(line);
  }

  return { lines, month, year };
}
