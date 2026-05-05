# Shareholder Reconciliation for Jan 2026

## 1. Income (Lanco Income table)
echo "--- INCOME (Lanco Income) ---"
docker exec lanacc-db psql -U postgres -d landco_v2_db -c "SELECT p.code, SUM(i.total_mzn) FROM landco_income i JOIN properties p ON i.property_id = p.id WHERE period_month = 1 AND period_year = 2026 GROUP BY p.code"

## 2. Shared Expenses (Lodge / LC)
echo "--- SHARED EXPENSES (25% share) ---"
docker exec lanacc-db psql -U postgres -d landco_v2_db -c "SELECT SUM(amount_mzn) * 0.25 as share_per_house FROM expense_transactions WHERE month = 1 AND year = 2026 AND is_shared = true"

## 3. Personal Expenses
echo "--- PERSONAL EXPENSES ---"
docker exec lanacc-db psql -U postgres -d landco_v2_db -c "SELECT p.code, SUM(e.amount_mzn) FROM expense_transactions e JOIN properties p ON e.property_id = p.id WHERE month = 1 AND year = 2026 AND is_shared = false GROUP BY p.code"

## 4. Imported Balances
echo "--- IMPORTED BALANCES ---"
docker exec lanacc-db psql -U postgres -d landco_v2_db -c "SELECT p.code, income, expenses, closing_balance FROM shareholder_balances b JOIN properties p ON b.property_id = p.id WHERE month = 1 AND year = 2026"
