const XLSX = require('xlsx');
const workbook = XLSX.readFile('Accounts 2026/Landco Accounts 2026/01 JAN ACCOUNTS/01 JAN MONTH END 2026.xlsx');
const sheetName = workbook.SheetNames.find(s => s.trim() === 'EXPENSES');
if (sheetName) {
    const ws = workbook.Sheets[sheetName];
    const data = XLSX.utils.sheet_to_json(ws, { header: 1 });
    const salaryRows = data.filter(r => r && r.some(c => String(c).includes('SALARIES')));
    console.log('Salary Rows:', JSON.stringify(salaryRows, null, 2));
}
