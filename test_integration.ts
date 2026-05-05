import { parseSalarySheet } from './src/lib/parsers/salaryParser.ts';
import fs from 'fs';
import pkg from 'pg';
const { Client } = pkg;

async function test() {
    const client = new Client({
        user: 'postgres',
        host: 'localhost',
        database: 'landco_v2_db',
        password: 'root',
        port: 5432,
    });

    await client.connect();
    console.log('Connected to Postgres');

    const filePath = 'Accounts 2026/Salaries Landco 2026/Landco Salaries 2026/01 Salary sheet for Landco.xlsx';
    const file = fs.readFileSync(filePath);
    const buffer = file.buffer.slice(file.byteOffset, file.byteOffset + file.byteLength);

    console.log('Parsing...');
    const result = parseSalarySheet(buffer, 1, 2026);
    
    // Simulate matching logic from importService.ts
    const employees = await client.query('SELECT id, name, nuit, engagement_date, discharge_date FROM employees');
    const byName = new Map();
    const byNuit = new Map();
    employees.rows.forEach(e => {
        byName.set(e.name.toUpperCase(), e);
        if (e.nuit) byNuit.set(String(e.nuit).trim(), e);
    });

    console.log(`Matched ${employees.rows.length} employees from DB.`);

    let matched = 0;
    let nMatchedByNuit = 0;
    const updates = [];

    for (const l of result.lines) {
        let emp = l.nuit ? byNuit.get(l.nuit) : null;
        if (emp) nMatchedByNuit++;
        if (!emp) emp = byName.get(l.employee_name.toUpperCase());

        if (emp) {
            matched++;
            const payload = {};
            if (l.nuit && emp.nuit !== l.nuit) payload.nuit = l.nuit;
            if (l.engagement_date && emp.engagement_date !== l.engagement_date) payload.engagement_date = l.engagement_date;
            
            if (Object.keys(payload).length > 0) {
                updates.push({ id: emp.id, name: emp.name, payload });
            }
        }
    }

    console.log(`Total lines in Excel: ${result.lines.length}`);
    console.log(`Matched: ${matched}`);
    console.log(`Matched by NUIT: ${nMatchedByNuit}`);
    console.log(`Updates found: ${updates.length}`);
    if (updates.length > 0) {
        console.log('Sample Update:', JSON.stringify(updates[0], null, 2));
        
        // Actually apply one update as a test
        const up = updates[0];
        console.log(`Applying test update for ${up.name}...`);
        await client.query('UPDATE employees SET nuit = $1 WHERE id = $2', [up.payload.nuit, up.id]);
        console.log('Update applied.');
    }

    await client.end();
}

test().catch(console.error);
