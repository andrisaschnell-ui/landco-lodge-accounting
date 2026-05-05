import XLSX from 'xlsx';
import fs from 'fs';

const filePath = 'Accounts 2026/Salaries Landco 2026/Landco Salaries 2026/02 Salary sheet for Landco.xlsx';
if (fs.existsSync(filePath)) {
    const file = fs.readFileSync(filePath);
    const wb = XLSX.read(file, { type: 'buffer' });
    console.log('Sheet Names for 02:', wb.SheetNames);
} else {
    console.log('File 02 not found');
}
