import pkg from "pg";
import fs from "fs";
const { Pool } = pkg;

const pool = new Pool({
  connectionString: process.env.DATABASE_URL || "postgres://postgres:root@localhost:5432/landco_v2_db"
});

const payload = JSON.parse(fs.readFileSync("./scripts/bdo_recovery_payload.json", "utf8"));
const ADMIN_ID = '1e6a9107-e40e-4416-8443-7bfa5e0b00ba';

async function recover() {
  const client = await pool.connect();
  try {
    await client.query('BEGIN');

    // 1. Process Bank Outflows (as Supplier Invoices + Payments)
    const mtnOut = payload.bank_outflows?.mtn || [];
    console.log(`Processing ${mtnOut.length} MZN bank outflows...`);

    for (const tx of mtnOut) {
      if (!tx.recipient || !tx.amount_incl) continue;

      // Ensure supplier
      const { rows: [supplier] } = await client.query(
        "INSERT INTO public.suppliers (name) VALUES ($1) ON CONFLICT (name) DO UPDATE SET name = EXCLUDED.name RETURNING id",
        [tx.recipient]
      );

      // A. The Bill (Invoice)
      const invDesc = `BDO Recovery: Bill from ${tx.recipient} - ${tx.description || tx.allocation}`;
      const { rows: [invEntry] } = await client.query(`
        INSERT INTO public.journal_entries (entry_date, description, entry_type, posted, created_by)
        VALUES ($1, $2, 'supplier_invoice', true, $3) RETURNING id
      `, [tx.date || '2026-01-01', invDesc, ADMIN_ID]);

      let expenseCode = '621'; 
      const alloc = (tx.allocation || '').toLowerCase();
      if (alloc.includes('edm')) expenseCode = '622';
      else if (alloc.includes('fuel')) expenseCode = '623';

      await client.query(`
        INSERT INTO public.journal_lines (journal_entry_id, account_id, debit, credit, memo)
        VALUES 
          ($1, (SELECT id FROM public.accounts WHERE code=$2), $3, 0, $4),
          ($1, (SELECT id FROM public.accounts WHERE code='221'), 0, $3, $4)
      `, [invEntry.id, expenseCode, tx.amount_incl, tx.reference]);

      // B. The Payment
      const payDesc = `BDO Recovery: Payment to ${tx.recipient} (BIM MZN)`;
      const { rows: [payEntry] } = await client.query(`
        INSERT INTO public.journal_entries (entry_date, description, entry_type, posted, created_by)
        VALUES ($1, $2, 'supplier_payment', true, $3) RETURNING id
      `, [tx.date || '2026-01-01', payDesc, ADMIN_ID]);

      await client.query(`
        INSERT INTO public.journal_lines (journal_entry_id, account_id, debit, credit, memo)
        VALUES 
          ($1, (SELECT id FROM public.accounts WHERE code='221'), $2, 0, $3),
          ($1, (SELECT id FROM public.accounts WHERE code='122'), 0, $2, $3)
      `, [payEntry.id, tx.amount_incl, tx.reference]);

      // Save to supplier_invoices
      await client.query(`
        INSERT INTO public.supplier_invoices 
          (supplier_id, invoice_number, invoice_date, description, allocation, amount_excl, vat_amount, total_amount, journal_entry_id)
        VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
      `, [supplier.id, tx.reference, tx.date, tx.description, tx.allocation, tx.amount_excl, tx.vat_amount, tx.amount_incl, invEntry.id]);
    }

    // 2. Process Equity (Shareholders)
    const equity = payload.equity || [];
    console.log(`Processing ${equity.length} equity entries...`);
    for (const eq of equity) {
      if (!eq.shareholder || !eq.debit) continue; // Debit in equity sheet is the inflow amount

      const desc = `Equity Contribution: ${eq.shareholder} - ${eq.description}`;
      const { rows: [entry] } = await client.query(`
        INSERT INTO public.journal_entries (entry_date, description, entry_type, posted, created_by)
        VALUES ($1, $2, 'equity', true, $3) RETURNING id
      `, [eq.date || '2026-01-01', desc, ADMIN_ID]);

      await client.query(`
        INSERT INTO public.journal_lines (journal_entry_id, account_id, debit, credit)
        VALUES 
          ($1, (SELECT id FROM public.accounts WHERE code='122'), $2, 0),
          ($1, (SELECT id FROM public.accounts WHERE code='51'), 0, $2)
      `, [entry.id, eq.debit]);

      console.log(`Posted Equity for ${eq.shareholder}: ${eq.debit} MZN`);
    }

    await client.query('COMMIT');
    console.log("Bank and Equity recovery complete.");
  } catch (e) {
    await client.query('ROLLBACK');
    console.error("Recovery failed:", e);
  } finally {
    client.release();
    process.exit();
  }
}

recover();
