import { importSalary } from './src/lib/importService.ts';
import { parseSalarySheet } from './src/lib/parsers/salaryParser.ts';
import fs from 'fs';
import { db } from './src/lib/db.ts';

async function test() {
    const filePath = 'Accounts 2026/Salaries Landco 2026/Landco Salaries 2026/01 Salary sheet for Landco.xlsx';
    const file = fs.readFileSync(filePath);
    const buffer = file.buffer.slice(file.byteOffset, file.byteOffset + file.byteLength);

    console.log('Parsing...');
    const result = parseSalarySheet(buffer, 1, 2026);
    
    console.log('Importing (replaceExisting: true)...');
    try {
        const stats = await importSalary(result, '01 Salary sheet for Landco.xlsx', { replaceExisting: true });
        console.log('Import successful:', stats);
        
        // Verify a NUIT was saved
        const { data: emp } = await db.from('employees').select('name, nuit').eq('name', 'ALMEIDA ANTONIO VILANCULO').single();
        console.log('Verified Employee ALMEIDA:', emp);
    } catch (e) {
        console.error('Import failed:', e);
    }
}

test();
