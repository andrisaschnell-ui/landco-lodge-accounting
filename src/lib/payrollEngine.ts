/**
 * Landco Payroll Engine
 * Implementation of the "Program Scripts" used to calculate the Folha de Salários.
 * This ensures the app behaves exactly like the Excel template formulas.
 */

export interface AdminData {
  base_salary: number;
  food_allowance: number;
  back_payment: number;
  days_worked: number;
  nightshift_hours: number;
  overtime_15x_hours: number;
  overtime_2x_hours: number;
  gratification: number;
  holiday_days: number;
  advance: number;
  irps: number;
  debt: number;
  category?: string;
  house_code?: string;
  employee_name?: string;
  nib?: string;
}

export interface CalculatedPayrollLine extends AdminData {
  monthly_salary: number;
  guardas_25: number;
  overtime_15x_amount: number;
  overtime_2x_amount: number;
  holiday_amount: number;
  gross_total: number;
  inss_employee: number;
  sind: number;
  total_deductions: number;
  net_salary: number;
}

export function calculatePayrollLine(input: AdminData): CalculatedPayrollLine {
  const {
    base_salary = 0,
    food_allowance = 0,
    back_payment = 0,
    days_worked = 30,
    nightshift_hours = 0,
    overtime_15x_hours = 0,
    overtime_2x_hours = 0,
    gratification = 0,
    holiday_days = 0,
    advance = 0,
    irps = 0,
    debt = 0
  } = input;

  // 1. Monthly Salary (adjusted for days worked)
  // Formula: (Base / 30 * Days) + Food + BackPay
  const monthly_salary = Number(((base_salary / 30) * (days_worked || 30)).toFixed(2)) + food_allowance + back_payment;

  // 2. Guardas 25% (Nightshift)
  // Formula: (DailyRate / 8) * NightHours * 0.25
  const dailyRate = monthly_salary / (days_worked || 30);
  const guardas_25 = Number(((dailyRate / 8) * nightshift_hours * 0.25).toFixed(2));

  // 3. Extra Hours 1.5x
  // Formula: (Base / 192) * Hours * 1.5
  const overtime_15x_amount = Number(((base_salary / 192) * overtime_15x_hours * 1.5).toFixed(2));

  // 4. Extra Hours 2x
  // Formula: (MonthlySalary / 192) * Hours * 2.0
  const overtime_2x_amount = Number(((monthly_salary / 192) * overtime_2x_hours * 2.0).toFixed(2));

  // 5. Holiday Amount
  const holiday_amount = Number(((monthly_salary / 30) * holiday_days).toFixed(2));

  // 6. Gross Total
  const gross_total = monthly_salary + guardas_25 + overtime_15x_amount + overtime_2x_amount + gratification + holiday_amount;

  // 7. Deductions
  const inss_employee = Number((gross_total * 0.03).toFixed(2));
  const sind = Number((gross_total * 0.01).toFixed(2));
  const total_deductions = Number((advance + irps + debt + inss_employee + sind).toFixed(2));

  // 8. Net Salary
  const net_salary = Number((gross_total - total_deductions).toFixed(2));

  return {
    ...input,
    monthly_salary,
    guardas_25,
    overtime_15x_amount,
    overtime_2x_amount,
    holiday_amount,
    gross_total,
    inss_employee,
    sind,
    total_deductions,
    net_salary
  };
}
