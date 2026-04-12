import * as XLSX from 'xlsx';
import { calculatePayrollLine, AdminData } from "../payrollEngine";

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

const num = (v: unknown): number => {
  if (v == null || v === '' || v === '#REF!') return 0;
  const n = Number(v);
  return isNaN(n) ? 0 : n;
};

const str = (v: unknown): string => (v == null ? '' : String(v).trim());

export const parseSalarySheet = async (file: File): Promise<ParsedSalaryLine[]> => {
  const data = await file.arrayBuffer();
  const wb = XLSX.read(data);
  
  const targetSheet = wb.SheetNames.find(name => {
    const n = name.toLowerCase().normalize("NFD").replace(/[\u0300-\u036f]/g, "");
    return n.includes("folha") && n.includes("salario");
  }) || wb.SheetNames[0]; // Fallback to first sheet

  const ws = wb.Sheets[targetSheet];
  const rows: unknown[][] = XLSX.utils.sheet_to_json(ws, { header: 1, defval: null });

  const dataStart = 9; 
  const lines: ParsedSalaryLine[] = [];

  for (let i = dataStart; i < rows.length; i++) {
    const row = rows[i];
    if (!row) continue;

    const name = str(row[2]); // Column C (Worker Name)
    if (!name || name.toLowerCase().includes("total") || name.length < 2) continue;

    const adminData: AdminData = {
      employee_name: name,
      house_code: str(row[1]),     // Column B
      category: str(row[3]),       // Column D
      base_salary: num(row[7]),    // Column H
      food_allowance: num(row[9]), // Column J
      back_payment: num(row[10]),  // Column K
      days_worked: num(row[11]),   // Column L
      nightshift_hours: num(row[13]), // Column N
      overtime_15x_hours: num(row[15]), // Column P
      overtime_2x_hours: num(row[17]),  // Column R
      gratification: num(row[19]),      // Column T
      holiday_days: num(row[20]),       // Column U
      advance: num(row[23]),            // Column X
      irps: num(row[24]),               // Column Y
      debt: num(row[25]),               // Column Z
      nib: str(row[27]),                // Column AB
    };

    const calculated = calculatePayrollLine(adminData);

    lines.push({
      ...calculated,
      employee_name: adminData.employee_name!,
      nib: adminData.nib!,
    });
  }

  return lines;
};
