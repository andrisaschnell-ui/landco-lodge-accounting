import express from 'express';

const router = express.Router();

export default function(pool, requireAuth) {
  // List sheets
  router.get('/sheets', requireAuth, async (req, res) => {
    try {
      const { sheet_type, year, month } = req.query;
      const where = [];
      const params = [];
      if (sheet_type) { params.push(sheet_type); where.push(`sheet_type=$${params.length}`); }
      if (year)       { params.push(year);       where.push(`year=$${params.length}`); }
      if (month)      { params.push(month);      where.push(`month=$${params.length}`); }
      const sql = `SELECT * FROM public.cash_sheets ${where.length ? 'WHERE ' + where.join(' AND ') : ''} ORDER BY year DESC, month DESC`;
      const { rows } = await pool.query(sql, params);
      res.json(rows);
    } catch (e) { res.status(500).json({ error: e.message }); }
  });

  // Upsert a sheet (opening balance)
  router.post('/sheets', requireAuth, async (req, res) => {
    const { sheet_type, year, month, opening_balance, opening_description, source_file } = req.body || {};
    try {
      const { rows } = await pool.query(`
        INSERT INTO public.cash_sheets (sheet_type, year, month, opening_balance, opening_description, source_file)
        VALUES ($1,$2,$3,$4,$5,$6)
        ON CONFLICT (sheet_type, year, month) DO UPDATE SET
          opening_balance=EXCLUDED.opening_balance,
          opening_description=EXCLUDED.opening_description,
          source_file=EXCLUDED.source_file,
          updated_at=now()
        RETURNING *`,
        [sheet_type, year, month ?? null, opening_balance ?? 0, opening_description ?? null, source_file ?? null]
      );
      res.json(rows[0]);
    } catch (e) { res.status(500).json({ error: e.message }); }
  });

  // List transactions
  router.get('/transactions', requireAuth, async (req, res) => {
    try {
      const { sheet_type, year, month } = req.query;
      const where = [];
      const params = [];
      if (sheet_type) { params.push(sheet_type); where.push(`sheet_type=$${params.length}`); }
      if (year)       { params.push(year);       where.push(`year=$${params.length}`); }
      if (month)      { params.push(month);      where.push(`month=$${params.length}`); }
      const sql = `SELECT * FROM public.cash_transactions ${where.length ? 'WHERE ' + where.join(' AND ') : ''} ORDER BY tx_date, row_no`;
      const { rows } = await pool.query(sql, params);
      res.json(rows);
    } catch (e) { res.status(500).json({ error: e.message }); }
  });

  // Bulk insert transactions
  router.post('/transactions/bulk', requireAuth, async (req, res) => {
    const rows = req.body?.rows || [];
    if (!rows.length) return res.json({ inserted: 0 });
    const client = await pool.connect();
    try {
      await client.query('BEGIN');
      for (const r of rows) {
        const cols = Object.keys(r);
        const params = cols.map((_, i) => `$${i + 1}`);
        await client.query(
          `INSERT INTO public.cash_transactions (${cols.join(',')}) VALUES (${params.join(',')})`,
          cols.map(c => r[c])
        );
      }
      await client.query('COMMIT');
      res.json({ inserted: rows.length });
    } catch (e) {
      await client.query('ROLLBACK');
      res.status(500).json({ error: e.message });
    } finally { client.release(); }
  });

  // Dropdown options CRUD
  router.get('/dropdowns', requireAuth, async (req, res) => {
    const { rows } = await pool.query('SELECT * FROM public.cash_dropdown_options ORDER BY sheet_type, column_key, sort_order, value');
    res.json(rows);
  });

  router.post('/dropdowns', requireAuth, async (req, res) => {
    const { sheet_type, column_key, value, sort_order } = req.body || {};
    try {
      const { rows } = await pool.query(`
        INSERT INTO public.cash_dropdown_options (sheet_type, column_key, value, sort_order)
        VALUES ($1,$2,$3,$4)
        ON CONFLICT (sheet_type, column_key, value) DO NOTHING
        RETURNING *`, [sheet_type, column_key, value, sort_order ?? 0]);
      res.json(rows[0] || {});
    } catch (e) { res.status(500).json({ error: e.message }); }
  });

  router.delete('/dropdowns/:id', requireAuth, async (req, res) => {
    try {
      await pool.query('DELETE FROM public.cash_dropdown_options WHERE id=$1', [req.params.id]);
      res.json({ ok: true });
    } catch (e) { res.status(500).json({ error: e.message }); }
  });

  // Allocation columns
  router.get('/allocation-columns', requireAuth, async (req, res) => {
    const { rows } = await pool.query('SELECT * FROM public.cash_allocation_columns ORDER BY sheet_type, sort_order, column_name');
    res.json(rows);
  });

  router.post('/allocation-columns', requireAuth, async (req, res) => {
    const { sheet_type, column_name, sort_order } = req.body || {};
    try {
      const { rows } = await pool.query(`
        INSERT INTO public.cash_allocation_columns (sheet_type, column_name, sort_order)
        VALUES ($1,$2,$3)
        ON CONFLICT (sheet_type, column_name) DO NOTHING
        RETURNING *`, [sheet_type, column_name, sort_order ?? 0]);
      res.json(rows[0] || {});
    } catch (e) { res.status(500).json({ error: e.message }); }
  });

  return router;
}
