const XLSX = require('xlsx');
const workbook = XLSX.readFile('Accounts 2026/Landco Accounts 2026/01 JAN ACCOUNTS/01 JAN MONTH END 2026.xlsx');
console.log('Sheets:', workbook.SheetNames);
const sheetName = workbook.SheetNames.find(s => s.trim() === 'EXPENSES');
if (sheetName) {
    const ws = workbook.Sheets[sheetName];
    const data = XLSX.utils.sheet_to_json(ws, { header: 1 });
    console.log('Row 6 (index 5):', data[5]);
    console.log('Data sample (Row 7):', data[6]);
    console.log('Data sample (Row 8):', data[7]);
    console.log('Data sample (Row 9):', data[8]);
    console.log('Data sample (Row 10):', data[9]);
}
