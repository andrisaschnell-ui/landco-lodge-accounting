# Payroll System Updates & Migration Guide

This guide describes the structural changes and data recovery processes implemented in May 2026 to unify the payroll system and resolve data inconsistencies across the Landco Lodge Accounting application.

## 1. Architecture: Data Source Unification

### The Problem
The application was in a "bifurcated" state:
- **Reads**: `Payroll.tsx` and `importService.ts` were using the legacy `supabase` client, fetching data from the Supabase Cloud project (`neakxehuonsrlvjrxhnd`).
- **Writes**: New saves and certain local operations were using the custom `db` client, writing to the local Dockerized PostgreSQL database (`lanacc-db`).
- **Result**: Data saved for February, March, and April was being written locally but was invisible in the UI because the page was still looking at the (empty) Cloud database.

### The Fix
- **Client Replacement**: All `supabase.from()` calls in `src/pages/Payroll.tsx` and `src/lib/importService.ts` were replaced with `db.from()`.
- **Logic**: The application now strictly reads and writes to the local PostgreSQL instance. January–April 2026 data is now fully synchronized and visible in the local environment.

## 2. Data Recovery & Import Process

To restore missing months and fix broken February data (which previously had 0 gross totals), a re-import process was executed using official Excel sources.

### Source Files
Located in: `d:/landco/Accounts 2026/Salaries Landco 2026/Landco Salaries 2026/`
- `01 Salary sheet for Landco.xlsx`
- `02 Salary sheet for Landco.xlsx`
- `03 Salary sheet for Landco.xlsx`
- `04 Salary sheet for Landco.xlsx`

### Parsing Strategy (Dynamic Column Detection)
A critical discovery was that the Excel sheets are not structurally identical:
- **January (01)**: Standard layout.
- **Feb–Apr (02-04)**: Contains an **extra empty column** (typically at index 5), shifting all subsequent data columns (Category, Base Salary, Gross Total, etc.) to the right by one index.

**The automated import process now uses dynamic mapping:**
1. Locate the header row by searching for the "NO" keyword in column 0.
2. Identify the index of "NOME DO TRABALHADOR" and "RETRIBUICAO" (Base Salary).
3. Calculate the `shift` (typically `0` or `1`) relative to the standard January template.
4. Apply this `shift` to all numerical column retrievals (Food Allowance, Days Worked, INSS, Net Salary, etc.).

### Database Writing
The import script follows this order to maintain referential integrity:
1. **Wipe Existing**: Deletes rows from `salary_lines` then `salary_runs` for the target month/year.
2. **Create Run**: Inserts a new header into `salary_runs` and retrieves the UUID.
3. **Employee Mapping**: Checks if the employee name exists in the `employees` table; if not, creates a new record.
4. **Bulk Insert**: Batches all `salary_lines` for the month into a single SQL insert.
5. **Rollup Totals**: Executes an `UPDATE` on `salary_runs` to sum up `total_gross`, `total_net`, `total_irps`, and `total_inss_employee` from the individual lines.

## 3. Calculation & Business Logic

### April Salary Increase
The system is configured to handle automated salary increases (defined in `Settings.tsx`).
- **Logic Location**: `src/pages/Payroll.tsx` -> `handleEditCell`.
- **Trigger**: Starting in the month specified in settings (default: April), the `base_salary` is multiplied by `(1 + increase_percentage / 100)`.
- **Note**: This logic applies during manual edits in the UI. For the initial import, the values were taken directly from the "audited" Excel sheets to ensure historical accuracy.

### Journal Integration
Payroll runs are linked to the General Ledger via `scripts/backfill-journal.mjs`.
- **Entry Type**: `payroll`.
- **Accounts**:
  - **Dr 6311**: Salaries Gross
  - **Cr 2511**: Net Pay Payable
  - **Cr 2451**: INSS Payable (Employee + Employer)
  - **Cr 2452**: IRPS Payable

## 4. Maintenance for Future Months

To ensure the system remains stable as new months are added:
1. **Always Use Local DB**: Ensure no new components import the legacy Supabase client for data fetching.
2. **Template Consistency**: Use the "Download Template" button on the Payroll page to provide Excel files for manual data entry; this ensures the columns match the application's expected layout.
3. **Cloud Sync**: Periodically run `Sync -> Push Local -> Cloud` from the app if a cloud backup is required. The API is configured with the `SERVICE_ROLE_KEY` to allow this.

---
*Guide generated on 2026-05-06 for Landco Accounting Unified System.*
