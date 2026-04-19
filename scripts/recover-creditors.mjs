import pkg from "pg";
import fs from "fs";
const { Pool } = pkg;

const pool = new Pool({
  connectionString: process.env.DATABASE_URL || "postgres://postgres:root@localhost:5432/landco_v2_db"
});

const payload = JSON.parse(fs.readFileSync("./scripts/bdo_recovery_payload.json", "utf8"));

async function recoverCreditors() {
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    const creditors = payload.creditors || [];
    console.log(`Processing ${creditors.length} creditor entries...`);

    for (const c of creditors) {
      if (!c.supplier || !c.total_amount) continue;

      // 1. Ensure supplier exists
      const { rows: [supplier] } = await client.query(
        "INSERT INTO public.suppliers (name) VALUES ($1) ON CONFLICT (name) DO UPDATE SET name = EXCLUDED.name RETURNING id",
        [c.supplier]
      );

      // 2. Create Journal Entry
      const description = `Supplier Invoice: ${c.supplier} - ${c.description || c.allocation}`;
      const { rows: [entry] } = await client.query(`
        INSERT INTO public.journal_entries (entry_date, description, entry_type, posted, created_by)
        VALUES ($1, $2, 'supplier_invoice', true, '1e6a9107-e40e-4416-8443-7bfa5e0b00ba')
        RETURNING id
      `, [c.invoice_date || '2026-01-01', description]);

      // 3. Mapping: Debit Expense (621 or from allocation), Credit Accounts Payable (221)
      let debitAccCode = '621'; // Default
      const alloc = (c.allocation || '').toLowerCase();
      if (alloc.includes('electricity') || alloc.includes('edm')) debitAccCode = '622';
      else if (alloc.includes('fuel')) debitAccCode = '623';
      
      await client.query(`
        INSERT INTO public.journal_lines (journal_entry_id, account_id, debit, credit, memo)
        VALUES 
          ($1, (SELECT id FROM public.accounts WHERE code=$2), $3, 0, $5),
          ($1, (SELECT id FROM public.accounts WHERE code='221'), 0, $3, $5)
      `, [entry.id, debitAccCode, c.total_amount, '221', c.invoice_number]);

      // 4. Save to supplier_invoices
      await client.query(`
        INSERT INTO public.supplier_invoices 
          (supplier_id, invoice_number, invoice_date, description, allocation, amount_excl, vat_amount, total_amount, journal_entry_id)
        VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
      `, [supplier.id, c.invoice_number, c.invoice_date || '2026-01-01', c.description, c.allocation, c.amount_excl, c.vat_amount, c.total_amount, entry.id]);

      console.log(`Imported invoice ${c.invoice_number} from ${c.supplier} (${c.total_amount} MZN)`);
    }

    await client.query('COMMIT');
    console.log("Creditor recovery complete.");
  } catch (e) {
    await client.query('ROLLBACK');
    console.error("Creditor recovery failed:", e);
  } finally {
    client.release();
    process.exit();
  }
}

recoverCreditors();
