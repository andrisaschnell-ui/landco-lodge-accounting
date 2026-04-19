import express from 'express';

const router = express.Router();

const SHAREHOLDER_CODES = ['H1', 'H2', 'H3', 'H4'];
const NUM_SHAREHOLDERS = 4;

// Houses that are treated as communal (shared 25% each)
// AM = Administration/Management, anything not H1/H2/H3/H4 specifically
const isCommunal = (house_assignment) => {
  if (!house_assignment) return true;
  // Exact single-house match
  if (SHAREHOLDER_CODES.includes(house_assignment)) return false;
  return true; // AM, H1/H4, LC, etc. are all communal or split
};

// What fraction of this employee's salary does `code` owe?
const shareholderFraction = (house_assignment, code) => {
  if (!house_assignment || house_assignment === 'AM') return 1 / NUM_SHAREHOLDERS;
  if (house_assignment === code) return 1.0; // Direct assignment
  if (house_assignment.includes('/')) {
    // e.g. "H1/H4" — split equally among named houses
    const parts = house_assignment.split('/');
    if (parts.includes(code)) return 1 / parts.length;
    return 0;
  }
  return 0;
};

export default function(pool, requireAuth) {

  // GET /api/reports/shareholders — all 4 summaries
  router.get('/shareholders', requireAuth, async (req, res) => {
    const { year = 2026, month } = req.query;
    try {
      const results = await Promise.all(
        SHAREHOLDER_CODES.map(code => getShareholderStatement(pool, code, Number(year), month ? Number(month) : null))
      );
      res.json(results);
    } catch (e) { res.status(500).json({ error: e.message }); }
  });

  // GET /api/reports/shareholder/:code — single shareholder full statement
  router.get('/shareholder/:code', requireAuth, async (req, res) => {
    const code = req.params.code.toUpperCase();
    const { year = 2026, month } = req.query;
    if (!SHAREHOLDER_CODES.includes(code)) {
      return res.status(400).json({ error: `Invalid shareholder code. Use: ${SHAREHOLDER_CODES.join(', ')}` });
    }
    try {
      const statement = await getShareholderStatement(pool, code, Number(year), month ? Number(month) : null);
      res.json(statement);
    } catch (e) { res.status(500).json({ error: e.message }); }
  });

  return router;
}

async function getShareholderStatement(pool, code, year, month) {

  // Property id for this shareholder
  const { rows: [prop] } = await pool.query(
    `SELECT id, name FROM public.properties WHERE code = $1`, [code]
  );
  if (!prop) return { code, error: 'Property not found' };

  // Date filter helper
  const dateWhere = month
    ? `AND EXTRACT(YEAR FROM t.date)=$Y AND EXTRACT(MONTH FROM t.date)=$M`
    : `AND EXTRACT(YEAR FROM t.date)=$Y`;

  // --- 1. Income (100% attributed to this house) ---
  const incomeParams = month ? [prop.id, year, month] : [prop.id, year];
  const incomeQ = `
    SELECT t.date, t.guest_name, t.description, t.accommodation_amount_mzn AS amount
    FROM public.income_transactions t
    WHERE t.property_id = $1
      AND EXTRACT(YEAR FROM t.date) = $2
      ${month ? 'AND EXTRACT(MONTH FROM t.date) = $3' : ''}
    ORDER BY t.date`;
  const { rows: directIncome } = await pool.query(incomeQ, incomeParams);

  // --- 2. Direct Expenses (100% for this house) ---
  const expParams = month ? [prop.id, year, month] : [prop.id, year];
  const expQ = `
    SELECT t.date, t.description, t.amount_mzn AS amount, ec.name AS category
    FROM public.expense_transactions t
    LEFT JOIN public.expense_categories ec ON ec.id = t.category_id
    WHERE t.property_id = $1
      AND EXTRACT(YEAR FROM t.date) = $2
      ${month ? 'AND EXTRACT(MONTH FROM t.date) = $3' : ''}
    ORDER BY t.date`;
  const { rows: directExpenses } = await pool.query(expQ, expParams);

  // --- 3. Petty Cash — all is communal (25% share) ---
  const pcParams = month ? [year, month] : [year];
  const pcQ = `
    SELECT t.date, t.description, t.supplier, t.allocation, t.debit AS amount
    FROM public.petty_cash_transactions t
    WHERE t.debit > 0
      AND EXTRACT(YEAR FROM t.date) = $1
      ${month ? 'AND EXTRACT(MONTH FROM t.date) = $2' : ''}
    ORDER BY t.date`;
  const { rows: pettyCash } = await pool.query(pcQ, pcParams);

  // --- 4. Salaries — fractional by house_assignment ---
  const salaryParams = month ? [year, month] : [year];
  const salaryQ = `
    SELECT sl.gross_total,
           sl.net_salary,
           sl.inss_employee,
           ROUND(sl.gross_total * 0.04, 2) AS inss_employer,
           e.name AS employee_name, e.house_assignment,
           sr.month, sr.year
    FROM public.salary_lines sl
    JOIN public.employees e ON e.id = sl.employee_id
    JOIN public.salary_runs sr ON sr.id = sl.salary_run_id
    WHERE sr.year = $1
      ${month ? 'AND sr.month = $2' : ''}
    ORDER BY e.house_assignment, e.name`;
  const { rows: allSalaryLines } = await pool.query(salaryQ, salaryParams);

  // Compute each employee's contribution for this shareholder
  const salaryDetail = allSalaryLines.map(r => {
    const totalCost = Number(r.gross_total || 0) + Number(r.inss_employer || 0);
    const fraction = shareholderFraction(r.house_assignment, code);
    return { ...r, total_cost: totalCost, fraction, owed: totalCost * fraction };
  }).filter(r => r.fraction > 0);

  const directSalaryLines = salaryDetail.filter(r => r.house_assignment === code);
  const sharedSalaryLines = salaryDetail.filter(r => r.house_assignment !== code);

  // --- Totals ---
  const totalIncome = directIncome.reduce((acc, r) => acc + Number(r.amount), 0);
  const totalDirectExp = directExpenses.reduce((acc, r) => acc + Number(r.amount), 0);
  const totalDirectSal = directSalaryLines.reduce((acc, r) => acc + r.owed, 0);
  const totalSharedSal = sharedSalaryLines.reduce((acc, r) => acc + r.owed, 0);
  const totalPCShare = pettyCash.reduce((acc, r) => acc + Number(r.amount) / NUM_SHAREHOLDERS, 0);

  const netPosition = totalIncome - totalDirectExp - totalDirectSal - totalSharedSal - totalPCShare;

  return {
    code,
    house_name: prop.name,
    period: month ? `${year}-${String(month).padStart(2, '0')}` : String(year),
    direct_income: directIncome,
    total_direct_income: totalIncome,
    direct_expenses: directExpenses,
    total_direct_expenses: totalDirectExp,
    direct_salary_lines: directSalaryLines,
    direct_salary_total: totalDirectSal,
    shared_salary_lines: sharedSalaryLines,
    shared_salary_total: totalSharedSal,
    petty_cash_lines: pettyCash,
    petty_cash_share: totalPCShare,
    net_position: netPosition,
  };
}
