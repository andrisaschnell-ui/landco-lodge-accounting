const { Client } = require('pg');

async function run() {
    const client = new Client({
        connectionString: "postgresql://postgres:postgres@localhost:5432/landco_v2_db"
    });
    await client.connect();

    const month = 1;
    const year = 2026;

    console.log(`Reconciliation Report for ${month}/${year}`);
    console.log('==========================================\n');

    // 1. Get Properties
    const { rows: properties } = await client.query('SELECT id, name, code FROM properties');
    const propMap = new Map(properties.map(p => [p.id, p]));

    // 2. Get Shareholders
    const { rows: shareholders } = await client.query('SELECT id, name, property_code FROM shareholders');

    // 3. Get Income Totals
    const { rows: incomeRows } = await client.query(`
        SELECT property_id, SUM(total_mzn) as total 
        FROM landco_income 
        WHERE period_month = $1 AND period_year = $2 
        GROUP BY property_id
    `, [month, year]);
    const incomeMap = new Map(incomeRows.map(r => [r.property_id, Number(r.total || 0)]));

    // 4. Get Expense Totals
    const { rows: expenseRows } = await client.query(`
        SELECT 
            property_id, 
            is_shared,
            SUM(amount_mzn) as total 
        FROM expense_transactions 
        WHERE month = $1 AND year = $2 
        GROUP BY property_id, is_shared
    `, [month, year]);

    const sharedTotal = expenseRows.filter(r => r.is_shared).reduce((s, r) => s + Number(r.total || 0), 0);
    const personalMap = new Map(expenseRows.filter(r => !r.is_shared).map(r => [r.property_id, Number(r.total || 0)]));

    // 5. Get Imported Balances
    const { rows: importedBalances } = await client.query(`
        SELECT * FROM shareholder_balances WHERE month = $1 AND year = $2
    `, [month, year]);
    const impMap = new Map(importedBalances.map(b => [b.property_id, b]));

    for (const sh of shareholders) {
        const prop = properties.find(p => p.code === sh.property_code);
        if (!prop) continue;

        const income = incomeMap.get(prop.id) || 0;
        const personalExpense = personalMap.get(prop.id) || 0;
        const shareOfShared = sharedTotal * 0.25; // 25% allocation
        const totalExpenses = personalExpense + shareOfShared;

        const imported = impMap.get(prop.id);

        console.log(`Shareholder: ${sh.name} (${prop.name})`);
        console.log(`  - Calculated Income: ${income.toLocaleString()} MZN`);
        console.log(`  - Calculated Expenses: ${totalExpenses.toLocaleString()} MZN`);
        if (imported) {
            console.log(`  - Imported Income: ${Number(imported.income).toLocaleString()} MZN`);
            console.log(`  - Imported Expenses: ${Number(imported.expenses).toLocaleString()} MZN`);
            
            const incomeDiff = income - Number(imported.income);
            const expenseDiff = totalExpenses - Number(imported.expenses);

            console.log(`  - INCOME MATCH: ${Math.abs(incomeDiff) < 1 ? 'YES' : 'NO (Diff: ' + incomeDiff.toLocaleString() + ')'}`);
            console.log(`  - EXPENSE MATCH: ${Math.abs(expenseDiff) < 1 ? 'YES' : 'NO (Diff: ' + expenseDiff.toLocaleString() + ')'}`);
        } else {
            console.log('  - No imported balance found for comparison.');
        }
        console.log('');
    }

    await client.end();
}

run().catch(console.error);
