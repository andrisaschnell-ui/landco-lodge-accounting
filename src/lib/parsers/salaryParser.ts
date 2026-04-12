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
  });

  if (!targetSheet) throw new Error("No 'Folha de salarios' sheet found in Excel file.");
  
  const ws = wb.Sheets[targetSheet];
  const rows: unknown[][] = XLSX.utils.sheet_to_json(ws, { header: 1, defval: null });

  const headerMappings: Record<string, string> = {
    "no": "no",
    "house": "house_code",
    "nome do trabalhador": "employee_name",
    "nome": "employee_name",
    "categoria": "category",
    "role": "category",
    "salario base": "base_salary",
    "alimentacao": "food_allowance",
    "retroativos": "back_payment",
    "back pay": "back_payment",
    "dias de trabalho": "days_worked",
    "salario mensal": "monthly_salary",
    "nightshift": "nightshift_hours",
    "25%": "overtime_25_percent",
    "1.5x": "overtime_15x_amount",
    "2x": "overtime_2x_amount",
    "premios": "gratification",
    "gratificacoes": "gratification",
    "ferias": "holiday_amount",
    "total de remuneracao": "gross_total",
    "adiantado": "advance",
    "advance": "advance",
    "irps": "irps",
    "divida": "debt",
    "inss": "inss_employee",
    "sind": "sind",
    "deductions": "total_deductions",
    "liquido": "net_salary",
    "conta do banco": "nib",
    "nib": "nib"
  };

  let headerMap: Record<string, number> = {};
  const normalize = (s: string) => s.toLowerCase().trim()
    .normalize("NFD").replace(/[\u0300-\u036f]/g, "")
    .replace(/\s+/g, " ");

  for (let i = 0; i < Math.min(rows.length, 30); i++) {
    const row = rows[i];
    if (!row) continue;
    row.forEach((cell, colIdx) => {
      const cellVal = normalize(str(cell));
      if (!cellVal) return;
      for (const [key, field] of Object.entries(headerMappings)) {
        if (cellVal.includes(key)) {
          if (headerMap[field] === undefined) headerMap[field] = colIdx;
        }
      }
    });
  }

  if (headerMap.employee_name === undefined) headerMap.employee_name = 2; 

  const dataStart = 9; 
  const lines: ParsedSalaryLine[] = [];

  for (let i = dataStart; i < rows.length; i++) {
    const row = rows[i];
    if (!row) continue;

    const name = str(row[headerMap.employee_name]);
    if (!name || name.toLowerCase().includes("total") || name.length < 2) continue;

    const adminData: AdminData = {
      employee_name: name,
      house_code: str(row[headerMap.house_code || 1]),
      category: str(row[headerMap.category || 3]),
      base_salary: num(row[headerMap.base_salary || 7]),
      food_allowance: num(row[headerMap.food_allowance || 9]),
      back_payment: num(row[headerMap.back_payment || 10]),
      days_worked: num(row[headerMap.days_worked || 11]),
      nightshift_hours: num(row[headerMap.nightshift_hours || 13]),
      overtime_15x_hours: num(row[headerMap.overtime_15x_hours || 15]),
      overtime_2x_hours: num(row[headerMap.overtime_2x_hours || 17]),
      gratification: num(row[headerMap.gratification || 19]),
      holiday_days: num(row[headerMap.holiday_days || 20]),
      advance: num(row[headerMap.advance || 23]),
      irps: num(row[headerMap.irps || 24]),
      debt: num(row[headerMap.debt || 25]),
      nib: str(row[headerMap.nib || 30]),
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
