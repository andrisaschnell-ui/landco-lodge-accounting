import express from 'express';

const router = express.Router();

export default function(pool, TABLES, requireAuth) {
  
  // GET /api/journal - list journal entries
  router.get('/', requireAuth, async (req, res) => {
    try {
      const { rows } = await pool.query(`
        SELECT je.*, p.name as property_name
        FROM public.journal_entries je
        LEFT JOIN public.properties p ON p.id = je.property_id
        ORDER BY je.entry_date DESC, je.created_at DESC
        LIMIT 100
      `);
      res.json(rows);
    } catch (e) { res.status(500).json({ error: e.message }); }
  });

  // GET /api/journal/:id/lines - get lines for an entry
  router.get('/:id/lines', requireAuth, async (req, res) => {
    try {
      const { rows } = await pool.query(`
        SELECT jl.*, a.code as account_code, a.name as account_name
        FROM public.journal_lines jl
        JOIN public.accounts a ON a.id = jl.account_id
        WHERE jl.journal_entry_id = $1
        ORDER BY jl.debit DESC
      `, [req.params.id]);
      res.json(rows);
    } catch (e) { res.status(500).json({ error: e.message }); }
  });

  // POST /api/journal - create manual journal entry
  router.post('/', requireAuth, async (req, res) => {
    if (!req.user.roles?.includes("admin")) return res.status(403).json({ error: "admin only" });
    
    const { entry_date, description, property_id, lines } = req.body;
    
    if (!lines || lines.length < 2) return res.status(400).json({ error: "at least two lines required" });
    
    const client = await pool.connect();
    try {
      await client.query('BEGIN');
      
      const { rows } = await client.query(`
        INSERT INTO public.journal_entries 
          (entry_date, description, entry_type, property_id, posted, created_by)
        VALUES ($1, $2, 'manual', $4, true, $5)
        RETURNING id
      `, [entry_date, description, property_id, req.user.sub]);
      
      const entryId = rows[0].id;
      
      for (const line of lines) {
        await client.query(`
          INSERT INTO public.journal_lines 
            (journal_entry_id, account_id, debit, credit, memo)
          VALUES ($1, $2, $3, $4, $5)
        `, [entryId, line.account_id, line.debit || 0, line.credit || 0, line.memo]);
      }
      
      await client.query('COMMIT');
      res.json({ id: entryId, message: "journal entry created" });
    } catch (e) {
      await client.query('ROLLBACK');
      res.status(500).json({ error: e.message });
    } finally {
      client.release();
    }
  });

  // GET /api/ledger/:accountCode - account ledger
  router.get('/ledger/:accountCode', requireAuth, async (req, res) => {
    try {
      const { rows } = await pool.query(`
        SELECT jl.*, je.entry_date, je.description, je.reference
        FROM public.journal_lines jl
        JOIN public.journal_entries je ON je.id = jl.journal_entry_id
        JOIN public.accounts a ON a.id = jl.account_id
        WHERE a.code = $1 AND je.posted = true
        ORDER BY je.entry_date ASC, je.created_at ASC
      `, [req.params.accountCode]);
      res.json(rows);
    } catch (e) { res.status(500).json({ error: e.message }); }
  });

  // GET /api/trial-balance
  router.get('/trial-balance', requireAuth, async (req, res) => {
    const { year, month } = req.query;
    try {
      // Simplification: total balance of all accounts
      const { rows } = await pool.query(`
        SELECT a.code, a.name, a.account_type, a.normal_side,
               SUM(jl.debit) as total_debit, 
               SUM(jl.credit) as total_credit
        FROM public.accounts a
        LEFT JOIN public.journal_lines jl ON jl.account_id = a.id
        LEFT JOIN public.journal_entries je ON je.id = jl.journal_entry_id
        WHERE (je.posted = true OR je.id IS NULL)
        GROUP BY a.id, a.code, a.name, a.account_type, a.normal_side
        ORDER BY a.code ASC
      `);
      res.json(rows);
    } catch (e) { res.status(500).json({ error: e.message }); }
  });

  return router;
}
