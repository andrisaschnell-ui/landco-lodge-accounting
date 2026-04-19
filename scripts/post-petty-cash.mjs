import pkg from "pg";
const { Pool } = pkg;

const pool = new Pool({
  connectionString: process.env.DATABASE_URL || "postgres://postgres:root@localhost:5432/landco_v2_db"
});

async function postPettyCash() {
  const client = await pool.connect();
  try {
    await client.query('BEGIN');

    // 1. Get unposted petty cash rows
    const { rows: transactions } = await client.query(`
      SELECT * FROM public.petty_cash_transactions 
      WHERE journal_entry_id IS NULL
      AND (credit > 0 OR debit > 0)
    `);

    console.log(`Found ${transactions.length} unposted petty cash transactions.`);

    for (const tx of transactions) {
      const description = `Petty Cash: ${tx.description || tx.allocation}`;
      const amount = tx.debit > 0 ? tx.debit : tx.credit;
      const date = tx.date || `${tx.year}-${tx.month.toString().padStart(2, '0')}-01`;

      // Create Journal Entry
      const { rows: [entry] } = await client.query(`
        INSERT INTO public.journal_entries (entry_date, description, entry_type, posted, created_by)
        VALUES ($1, $2, 'petty_cash', true, '1e6a9107-e40e-4416-8443-7bfa5e0b00ba')
        RETURNING id
      `, [date, description]);

      // Determine Debit/Credit accounts
      let debitAccCode, creditAccCode;

      if (tx.debit > 0) {
        // Logic: Expense (Class 6) or Suspense vs Petty Cash (11)
        creditAccCode = '11'; // Credits Petty Cash
        
        // Try to map allocation to an account
        const alloc = (tx.allocation || '').toLowerCase();
        if (alloc.includes('fine') || alloc.includes('tax')) debitAccCode = '631'; // Impostos e Taxas
        else if (alloc.includes('suspense')) debitAccCode = '12'; // Default to Bank for now if unsure
        else {
          // Check for expense category match
          const { rows: [cat] } = await client.query(
            "SELECT pgc_account_code FROM public.expense_categories WHERE LOWER(name) = $1",
            [alloc]
          );
          debitAccCode = cat?.pgc_account_code || '621'; // Default to 621 (External Services)
        }
      } else {
        // Cash In (Credit column > 0): Usually from Bank
        debitAccCode = '11'; // Debits Petty Cash
        creditAccCode = '12'; // Credits Bank (12)
      }

      // Final check: confirm account codes exist
      if (!debitAccCode || !creditAccCode) {
        console.error(`Skipping tx ${tx.id}: missing account codes.`);
        continue;
      }

      // Insert Journal Lines
      await client.query(`
        INSERT INTO public.journal_lines (journal_entry_id, account_id, debit, credit, memo)
        VALUES 
          ($1, (SELECT id FROM public.accounts WHERE code=$2), $3, 0, $5),
          ($1, (SELECT id FROM public.accounts WHERE code=$4), 0, $3, $5)
      `, [entry.id, debitAccCode, amount, creditAccCode, tx.reference]);

      // Link Transaction to Journal Entry
      await client.query(
        "UPDATE public.petty_cash_transactions SET journal_entry_id = $1 WHERE id = $2",
        [entry.id, tx.id]
      );

      console.log(`Posted transaction ${tx.id} (${tx.allocation}) to Journal ${entry.id}`);
    }

    await client.query('COMMIT');
    console.log("Petty cash journaling complete.");
  } catch (e) {
    await client.query('ROLLBACK');
    console.error("Failed to post petty cash:", e);
  } finally {
    client.release();
    process.exit();
  }
}

postPettyCash();
