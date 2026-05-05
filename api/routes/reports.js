import express from 'express';

const SHAREHOLDER_CODES = ['H1', 'H2', 'H3', 'H4'];
const NUM_SHAREHOLDERS = 4;

const shareholderFraction = (house_assignment, code) => {
  if (!house_assignment || house_assignment === 'AM') return 1 / NUM_SHAREHOLDERS;
  if (house_assignment === code) return 1.0; 
  if (house_assignment.includes('/')) {
    const parts = house_assignment.split('/');
    if (parts.includes(code)) return 1 / parts.length;
    return 0;
  }
  return 0;
};

export default function(pool, requireAuth) {
  const router = express.Router();
  console.log('--- Report Routes Initialized ---');

  router.get('/ping', (req, res) => res.json({ ok: true, msg: 'reports api is alive' }));

  router.get('/shareholders', requireAuth, async (req, res) => {
    const { year = 2026, month } = req.query;
    try {
      const results = await Promise.all(
        SHAREHOLDER_CODES.map(code => getShareholderStatement(pool, code, Number(year), month ? Number(month) : null))
      );
      res.json(results);
    } catch (e) { res.status(500).json({ error: e.message }); }
  });

  router.get('/shareholder/:code', requireAuth, async (req, res) => {
    const code = req.params.code.toUpperCase();
    const { year = 2026, month } = req.query;
    if (!SHAREHOLDER_CODES.includes(code)) {
      return res.status(400).json({ error: `Invalid shareholder code` });
    }
    try {
      const statement = await getShareholderStatement(pool, code, Number(year), month ? Number(month) : null);
      res.json(statement);
    } catch (e) { res.status(500).json({ error: e.message }); }
  });

  router.get('/shareholder-balances/:code', requireAuth, async (req, res) => {
    const code = req.params.code.toUpperCase();
    const { year = 2026 } = req.query;
    if (!SHAREHOLDER_CODES.includes(code)) return res.status(400).json({ error: `Invalid code` });
    try {
      const { rows: [initial] } = await pool.query(
        `SELECT opening_balance FROM shareholder_balances WHERE property_id = (SELECT id FROM properties WHERE code=$1) AND year=$2 AND month=1`,
        [code, year]
      );
      let runningBalance = Number(initial?.opening_balance || 0);
      const monthlyData = [];
      for (let m = 1; m <= 12; m++) {
        const stmt = await getShareholderStatement(pool, code, Number(year), m);
        const opening = runningBalance;
        runningBalance += stmt.net_position;
        monthlyData.push({ month: m, year: Number(year), opening_balance: opening, income: stmt.total_direct_income, expenses: stmt.total_direct_expenses + stmt.direct_salary_total + stmt.shared_salary_total + stmt.petty_cash_share, net_position: stmt.net_position, closing_balance: runningBalance });
      }
      res.json({ code, year, initial_balance: Number(initial?.opening_balance || 0), monthlyData });
    } catch (e) { res.status(500).json({ error: e.message }); }
  });

  router.get('/owner-monthly/:code', requireAuth, async (req, res) => {
    const code = req.params.code.toUpperCase();
    const { year = 2026, month } = req.query;
    if (!SHAREHOLDER_CODES.includes(code)) return res.status(400).json({ error: 'Invalid code' });
    if (!month) return res.status(400).json({ error: 'Month missing' });
    try {
      const { rows: [prop] } = await pool.query(`SELECT id, name FROM properties WHERE code = $1`, [code]);
      const y = Number(year);
      const m = Number(month);
      const yearlySummary = [];
      let runningBalance = 0;
      const { rows: [initial] } = await pool.query(`SELECT opening_balance FROM shareholder_balances WHERE property_id=$1 AND year=$2 AND month=1`, [prop.id, y]);
      runningBalance = Number(initial?.opening_balance || 0);
      for (let mi = 1; mi <= 12; mi++) {
        const s = await getShareholderStatement(pool, code, y, mi);
        const income = s.total_direct_income;
        const expenses = s.total_direct_expenses + s.direct_salary_total + s.shared_salary_total + s.petty_cash_share;
        const opening = runningBalance;
        runningBalance += (income - expenses);
        yearlySummary.push({ month: mi, income, expenses, closing: runningBalance, opening });
      }
      const { rows: incomeBreakdown } = await pool.query(`SELECT transaction_date as date, description, total_mzn as mzn, amount_usd as usd, exchange_rate_used as rate FROM landco_income WHERE property_id = $1 AND period_month = $2 AND period_year = $3 ORDER BY date`, [prop.id, m, y]);
      const { rows: personalExpenses } = await pool.query(`SELECT t.date, t.description, t.amount_mzn as amount, ec.name as category FROM expense_transactions t LEFT JOIN expense_categories ec ON ec.id = t.category_id WHERE t.property_id = $1 AND t.month = $2 AND t.year = $3 AND t.is_shared = false ORDER BY t.date`, [prop.id, m, y]);
      const { rows: sharedExpenses } = await pool.query(`SELECT t.date, t.description, t.amount_mzn as amount, ec.name as category FROM expense_transactions t LEFT JOIN expense_categories ec ON ec.id = t.category_id WHERE t.month = $1 AND t.year = $2 AND t.is_shared = true ORDER BY t.date`, [m, y]);
      const stmt = await getShareholderStatement(pool, code, y, m);
      res.json({ property: prop, month: m, year: y, summary: yearlySummary, incomeBreakdown, expenses: { personal: personalExpenses, shared: sharedExpenses.map(r => ({ ...r, share: Number(r.amount) / NUM_SHAREHOLDERS })), salaries: { direct: stmt.direct_salary_lines, shared: stmt.shared_salary_lines }, pettyCash: stmt.petty_cash_lines.map(r => ({ ...r, share: Number(r.amount) / NUM_SHAREHOLDERS })) }, analysis: { totalIncome: stmt.total_direct_income, totalExpenses: stmt.total_direct_expenses + stmt.direct_salary_total + stmt.shared_salary_total + stmt.petty_cash_share, sharedTotal: stmt.shared_salary_total + stmt.petty_cash_share + (sharedExpenses.reduce((s, r) => s + Number(r.amount), 0) / NUM_SHAREHOLDERS), personalTotal: stmt.total_direct_expenses + stmt.direct_salary_total } });
    } catch (e) { res.status(500).json({ error: e.message }); }
  });

  return router;
}

async function getShareholderStatement(pool, code, year, month) {
  const { rows: [prop] } = await pool.query(`SELECT id, name FROM public.properties WHERE code = $1`, [code]);
  const incomeParams = month ? [prop.id, year, month] : [prop.id, year];
  const { rows: directIncome } = await pool.query(`SELECT t.date, t.guest_name, t.description, t.accommodation_amount_mzn AS amount FROM public.income_transactions t WHERE t.property_id = $1 AND EXTRACT(YEAR FROM t.date) = $2 ${month ? 'AND EXTRACT(MONTH FROM t.date) = $3' : ''} ORDER BY t.date`, incomeParams);
  const expParams = month ? [prop.id, year, month] : [prop.id, year];
  const { rows: directExpenses } = await pool.query(`SELECT t.date, t.description, t.amount_mzn AS amount, ec.name AS category FROM public.expense_transactions t LEFT JOIN public.expense_categories ec ON ec.id = t.category_id WHERE t.property_id = $1 AND EXTRACT(YEAR FROM t.date) = $2 ${month ? 'AND EXTRACT(MONTH FROM t.date) = $3' : ''} ORDER BY t.date`, expParams);
  const pcParams = month ? [year, month] : [year];
  const { rows: pettyCash } = await pool.query(`SELECT t.date, t.description, t.supplier, t.allocation, t.debit AS amount FROM public.petty_cash_transactions t WHERE t.debit > 0 AND EXTRACT(YEAR FROM t.date) = $1 ${month ? 'AND EXTRACT(MONTH FROM t.date) = $2' : ''} ORDER BY t.date`, pcParams);
  const salaryParams = month ? [year, month] : [year];
  const { rows: allSalaryLines } = await pool.query(`SELECT sl.gross_total, sl.net_salary, sl.inss_employee, ROUND(sl.gross_total * 0.04, 2) AS inss_employer, e.name AS employee_name, e.house_assignment, sr.month, sr.year FROM public.salary_lines sl JOIN public.employees e ON e.id = sl.employee_id JOIN public.salary_runs sr ON sr.id = sl.salary_run_id WHERE sr.year = $1 ${month ? 'AND sr.month = $2' : ''} ORDER BY e.house_assignment, e.name`, salaryParams);
  const salaryDetail = allSalaryLines.map(r => {
    const totalCost = Number(r.gross_total || 0) + Number(r.inss_employer || 0);
    const fraction = shareholderFraction(r.house_assignment, code);
    return { ...r, total_cost: totalCost, fraction, owed: totalCost * fraction };
  }).filter(r => r.fraction > 0);
  const directSalaryLines = salaryDetail.filter(r => r.house_assignment === code);
  const sharedSalaryLines = salaryDetail.filter(r => r.house_assignment !== code);
  const totalIncome = directIncome.reduce((acc, r) => acc + Number(r.amount), 0);
  const totalDirectExp = directExpenses.reduce((acc, r) => acc + Number(r.amount), 0);
  const totalDirectSal = directSalaryLines.reduce((acc, r) => acc + r.owed, 0);
  const totalSharedSal = sharedSalaryLines.reduce((acc, r) => acc + r.owed, 0);
  const totalPCShare = pettyCash.reduce((acc, r) => acc + Number(r.amount) / NUM_SHAREHOLDERS, 0);
  const netPosition = totalIncome - totalDirectExp - totalDirectSal - totalSharedSal - totalPCShare;
  return { code, house_name: prop.name, period: month ? `${year}-${String(month).padStart(2, '0')}` : String(year), direct_income: directIncome, total_direct_income: totalIncome, direct_expenses: directExpenses, total_direct_expenses: totalDirectExp, direct_salary_lines: directSalaryLines, direct_salary_total: totalDirectSal, shared_salary_lines: sharedSalaryLines, shared_salary_total: totalSharedSal, petty_cash_lines: pettyCash, petty_cash_share: totalPCShare, net_position: netPosition };
}
