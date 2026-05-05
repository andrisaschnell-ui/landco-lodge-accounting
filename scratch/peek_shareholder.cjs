const XLSX = require('xlsx');
const workbook = XLSX.readFile('Accounts 2026/Shareholders 2026/01 Shareholders/01 LUZ TAFY 2026.xlsx');
const sheetName = 'SUMMERY';
const ws = workbook.Sheets[sheetName];
const data = XLSX.utils.sheet_to_json(ws, { header: 1 });
data.slice(0, 20).forEach((row, i) => console.log(`${i}:`, row));
