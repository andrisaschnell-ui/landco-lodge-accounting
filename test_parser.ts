import { parseSalarySheet } from './src/lib/parsers/salaryParser.ts';
import fs from 'fs';
import XLSX from 'xlsx';

// Mock XLSX for the parser which expects it to be available
// The parser uses XLSX.read and XLSX.utils.sheet_to_json

const filePath = 'Accounts 2026/Salaries Landco 2026/Landco Salaries 2026/01 Salary sheet for Landco.xlsx';
const file = fs.readFileSync(filePath);
const buffer = file.buffer.slice(file.byteOffset, file.byteOffset + file.byteLength);

try {
    const result = parseSalarySheet(buffer, 1, 2026);
    console.log(`Parsed ${result.lines.length} lines.`);
    console.log('Sample Line 0:', JSON.stringify(result.lines[0], null, 2));
    
    const withNuit = result.lines.filter(l => l.nuit && l.nuit !== '');
    console.log(`Lines with NUIT: ${withNuit.length}`);
    if (withNuit.length > 0) {
        console.log('Sample NUIT Line:', JSON.stringify(withNuit[0], null, 2));
    }
} catch (e) {
    console.error('Parsing failed:', e);
}
