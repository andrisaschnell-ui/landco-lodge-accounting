import XLSX from 'xlsx';
import fs from 'fs';

const filePath = 'Accounts 2026/Salaries Landco 2026/Landco Salaries 2026/02 Salary sheet for Landco.xlsx';
if (fs.existsSync(filePath)) {
    const file = fs.readFileSync(filePath);
    const wb = XLSX.read(file, { type: 'buffer' });
    const wsName = wb.SheetNames.find(n => n.toLowerCase().includes('folha'));
    const ws = wb.Sheets[wsName];
    const rows = XLSX.utils.sheet_to_json(ws, { header: 1, defval: null });
    for (let i = 0; i < 20; i++) {
        const r = rows[i];
        if (r && (r[3] || r[4] || r[5])) {
            console.log(`Row ${i}: Eng=${r[3]}, Disc=${r[4]}, NUIT=${r[5]}`);
        }
    }
}
