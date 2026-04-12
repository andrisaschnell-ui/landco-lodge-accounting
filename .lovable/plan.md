
# LANACC — Landco Accounts Management System
## Modern React + Supabase rebuild for Landco Lda, Mozambique

---

### Overview
Rebuild the Landco accounting application as a modern web app with authentication, role-based access, and all core accounting features from your README. During implementation, we'll extract and analyze the uploaded Excel files to model the database schema accurately.

---

### Phase 1: Database & Authentication
- **Set up Supabase** with Lovable Cloud
- **Create all database tables** based on your README's 22-table schema:
  - `shareholders`, `properties`, `employees`, `bank_accounts`, `expense_categories`
  - `income_transactions`, `expense_transactions`, `bank_transactions`, `petty_cash_transactions`
  - `shareholder_transactions`, `shareholder_balances`
  - `salary_runs`, `salary_lines`, `salary_advances`, `bim_salary_transfers`
  - `inss_payments`, `irps_payments`
  - `monthly_recon`, `annual_expenses`, `exchange_rates`, `import_log`
- **Authentication** with email/password login
- **User roles** (admin, viewer) in a separate `user_roles` table with RLS policies
- **Seed reference data**: 4 shareholders, 4 properties, expense categories, bank accounts

### Phase 2: Core UI & Navigation
- **Sidebar navigation** with all main sections: Dashboard, Transactions, Payroll, Shareholders, Employees, Reports, Upload
- **Responsive layout** that works on desktop and tablet

### Phase 3: Dashboard & KPIs
- **Summary cards**: Total income, total expenses, net profit, exchange rate
- **Charts**: Income vs expenses by month, income by property, expense breakdown by category
- **Recent import log** showing last data uploads

### Phase 4: Shareholder Management
- **Shareholder list** with balances overview
- **Shareholder detail page**: P&L statement, transaction history, drawings, opening/closing balances
- **Add/edit transactions** (income allocations, expense charges, drawings)
- **Per-shareholder reports** filtered by month/year

### Phase 5: Payroll Management
- **Payroll runs** by month with employee salary breakdown
- **Salary lines**: gross salary, INSS (employee + employer), IRPS, deductions, net pay
- **Salary advances** tracking
- **INSS/IRPS payment** recording
- **Employee management**: CRUD with NIB, NUIT, salary details

### Phase 6: Transactions & Data Entry
- **Income transactions**: per property, per month, with MZN amounts
- **Expense transactions**: categorized, shared/personal flag, linked to shareholders
- **Bank transactions**: BDO/BIM statement lines
- **Petty cash** transactions

### Phase 7: Excel Upload & Import
- **File upload page** to import Excel spreadsheets
- **Parser** that reads your Excel format (salary sheets, BIM transfers, monthly accounts, petty cash, shareholder P&L, BDO bank control)
- **Import log** tracking what was imported and when
- **Validation** showing errors before committing data

### Phase 8: Reports
- **Monthly Ledger**: all transactions for a given month
- **Shareholder Statement**: per-shareholder P&L for a period
- **Payroll Report**: full salary breakdown by month
- **P&L per Property**: annual profit & loss across all properties
- **Print-friendly** styling for PDF export via browser print
