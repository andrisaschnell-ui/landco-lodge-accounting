const XLSX = require('xlsx');
const workbook = XLSX.readFile('Accounts 2026/Landco Accounts 2026/01 JAN ACCOUNTS/01 JAN MONTH END 2026.xlsx');
const sheetName = workbook.SheetNames.find(s => s.trim() === 'EXPENSES');
const ws = workbook.Sheets[sheetName];
const data = XLSX.utils.sheet_to_json(ws, { header: 1 });
const headers = data[5];
headers.forEach((h, i) => console.log(`${i}: ${h}`));
const salaryRow = data.find(r => r && String(r[1]).includes('SALARIES'));
console.log('Salary Row:', salaryRow);
