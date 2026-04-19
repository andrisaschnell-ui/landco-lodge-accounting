# LANACC — Landco Accounts Management System
## Development Documentation & Technical Reference

**Generated:** April 2026  
**Project:** Landco Lda — Vilanculos, Mozambique  
**Stack:** React 18 + Vite + TypeScript + Tailwind CSS + Supabase (Lovable Cloud)

---

## 1. What Was Built

### 1.1 Architecture
- **Frontend:** Single-page React app with client-side routing (react-router-dom)
- **Backend:** Supabase (Lovable Cloud) providing PostgreSQL database, authentication, and Row Level Security
- **Styling:** Tailwind CSS with shadcn/ui component library
- **State:** TanStack React Query for server state management

### 1.2 Authentication & Authorization
- Email/password authentication via Supabase Auth
- User roles table (`user_roles`) with enum `app_role`: `admin` | `viewer`
- `has_role()` security definer function for RLS policy checks
- Auto-profile creation on signup via `handle_new_user()` trigger
- All data tables protected by RLS — admins can CRUD, authenticated users can read

### 1.3 Pages & Navigation
| Route | Page | Description |
|-------|------|-------------|
| `/auth` | Auth | Login/signup form |
| `/` | Dashboard | KPI cards, charts (income vs expenses, by property) |
| `/transactions` | Transactions | Tabbed view: income, expenses, bank, petty cash |
| `/shareholders` | Shareholders | Shareholder list with balances |
| `/employees` | Employees | Staff register with salary details |
| `/payroll` | Payroll | Monthly salary runs and breakdowns |
| `/properties` | Properties | Property (house) management |
| `/upload` | Upload Data | Excel file import with preview |

### 1.4 Sidebar Navigation
- `AppLayout.tsx` wraps all protected routes with `<SidebarProvider>`
- `AppSidebar.tsx` renders navigation links with icons
- Responsive: collapsible on mobile

---

## 2. Database Schema

### 2.1 Reference Data Tables
| Table | Key Fields | Seeded |
|-------|-----------|--------|
| `properties` | code (H1-H4, NEGU), name | ✅ 5 properties |
| `shareholders` | name, property_code, ownership_percentage, email | ✅ 4 shareholders |
| `employees` | name, nib, nuit, base_salary, food_allowance, category, house_assignment | ✅ 21 employees |
| `bank_accounts` | name, bank_name, currency, account_number | ✅ BDO MZN, BDO USD, BIM MZN |
| `expense_categories` | name, is_shared | ✅ 20 categories |
| `exchange_rates` | month, year, mzn_per_usd, mzn_per_zar | — |

### 2.2 Transaction Tables
| Table | Key Fields |
|-------|-----------|
| `income_transactions` | date, guest_name, accommodation_amount_mzn, amount_usd, property_id, month, year |
| `expense_transactions` | date, description, amount_mzn, is_shared, category_id, property_id, shareholder_id, month, year |
| `bank_transactions` | date, description, reference, debit, credit, balance, bank_account_id, month, year |
| `petty_cash_transactions` | date, description, credit, debit, balance, month, year |

### 2.3 Payroll Tables
| Table | Key Fields |
|-------|-----------|
| `salary_runs` | month, year, status, total_gross, total_net, total_irps, total_inss_employee, total_inss_employer |
| `salary_lines` | salary_run_id, employee_id, base_salary, food_allowance, days_worked, monthly_salary, overtime fields, gross_total, irps, inss_employee, net_salary, nib |
| `salary_advances` | employee_id, date, amount, month, year |
| `bim_salary_transfers` | name, nib, amount, employee_id, salary_run_id, month, year |
| `inss_payments` | amount, month, year, payment_date, reference |
| `irps_payments` | amount, month, year, payment_date, reference |

### 2.4 Shareholder Tables
| Table | Key Fields |
|-------|-----------|
| `shareholder_balances` | shareholder_id, property_id, month, year, opening_balance, income, expenses, closing_balance |

### 2.5 System Tables
| Table | Key Fields |
|-------|-----------|
| `profiles` | user_id, email, display_name |
| `user_roles` | user_id, role (admin/viewer) |
| `import_log` | filename, file_type, month, year, records_imported, status, imported_by |

---

## 3. Excel Import System

### 3.1 Supported File Types
| File Type | Parser File | Source Spreadsheet |
|-----------|------------|-------------------|
| Salary Sheet | `src/lib/parsers/salaryParser.ts` | "Folha de salarios" sheet — reads employee name (col C), base salary (col H), all earnings/deductions through to net salary (col ~AE). NIBs from "Sindicate" sheet. |
| BIM Salary Transfers | `src/lib/parsers/bimTransferParser.ts` | "Single File - Salary" sheet — name (col C), NIB (col B), amount (col D) |
| Month End Accounts | `src/lib/parsers/monthEndParser.ts` | "INCOME" sheet: date, house, guest, accommodation. " EXPENSES" sheet: date, supplier, description, total, category columns |
| BDO Bank Control | `src/lib/parsers/bdoBankParser.ts` | Bank statement rows with date, description, reference, debit, credit, balance |
| Petty Cash | `src/lib/parsers/pettyCashParser.ts` | Multiple sheets (MET cash, fuel, etc.) with DATE, DETAILS, CR, DR, BAL columns |

### 3.2 Import Service (`src/lib/importService.ts`)
- Maps employee names → UUIDs via `getEmployeeMap()`
- Maps property codes → UUIDs via `getPropertyMap()`
- Maps expense category names → UUIDs via `getCategoryMap()`
- Maps bank account names → UUIDs via `getBankAccountMap()`
- Logs every import to `import_log` table
- Returns count of imported records

### 3.3 Upload UI (`src/pages/UploadData.tsx`)
- File type selector (5 types)
- Month/year selectors
- Drag-and-drop file upload
- Preview parsed data before importing
- Progress indicator during import
- Success/error feedback with record counts

---

## 4. Data Populated

The following data was imported from the `Landco_Accounts_2026.zip` spreadsheets:

| Data Type | Records | Months |
|-----------|---------|--------|
| Salary runs | 4 | Jan–Apr 2026 |
| Salary lines | 84 (21 × 4 months) | Jan–Apr 2026 |
| BIM salary transfers | 62 | Jan–Mar 2026 |
| Income transactions | 100 | Jan–Mar 2026 |
| Expense transactions | 185 | Jan–Mar 2026 |
| Employees | 21 | — |
| Properties | 5 (H1–H4 + Negu) | — |
| Shareholders | 4 (Tafy, Stead/Warren, Kevin/Alex, Cohen) | — |
| Expense categories | 20 | — |
| Bank accounts | 3 (BDO MZN, BDO USD, BIM MZN) | — |

### 4.1 Employees (Seeded)
| # | Name | Category | House |
|---|------|----------|-------|
| 1 | MARCO BEBE GIMO | GERENTE | AM |
| 2 | ARMINDO QUETANE HOU | GUARDA | AM |
| 3 | CONSTANTINO JOSE PENGA | GUARDA | AM |
| 4 | ANSELMO LUCAS HUO | GUARDA | AM |
| 5 | CISTORA JOAO TANGUNE | EMPREGADA | AM |
| 6 | EMILIO GELSON ZIBANE | JARDINERO | AM |
| 7 | ALMEIDA ANTONIO VILANCULO | JARDINERO | AM |
| 8 | FELIX CARLOS MASSUANGANHE | JARDINERO | AM |
| 9 | GILDA DALARIO FALACO MUABASA | EMPREGADA | H1 |
| 10 | SERGIO FENIASSE BUANE | COZINHEIRA | H1 |
| 11 | AMINOSSE ARNALDO TANGUNE | CAPITÃO DE BARCO | H1/H4 |
| 12 | SERGIO FRANCISCO TANGUNE ZITO | GHILLIE | H2 |
| 13 | VITORIA FRANCISCO ZIBANE | EMPREGADA | H2 |
| 14 | INACIO FABIAO TIMBE | CAPITÃO DE BARCO | H2 |
| 15 | CALDERONE AGOSTINHO CHIVALE | COZINHEIRA | H2 |
| 16 | PEDRO SEBASTIAO NHAMIRE | JARDINERO/GHILLIE | H3 |
| 17 | ROCINA CAHIWANE TIMBE | EMPREGADA | H3 |
| 18 | ALEXANDRE LUCAS MASSUANGANHE | COZINHEIRA | H3 |
| 19 | JELSON QUALDADE ZIVANE | JARDINERO/COZINHA | H4 |
| 20 | MONIS TSANZIUANE CHIVALE | COZINHEIRA | H4 |
| 21 | EVELIN NELSON BERNARDO | EMPREGADA | H4 |

### 4.2 Properties
| Code | Name |
|------|------|
| H1 | Casa Luz |
| H2 | Casa Aurora |
| H3 | Casa Caju |
| H4 | Casa Coco |
| NEGU | Negu |

### 4.3 Shareholders
| Name | Property | Ownership |
|------|----------|-----------|
| Tafy | H1 (Casa Luz) | 50% |
| Stead/Warren | H2 (Casa Aurora) | 50% |
| Kevin/Alex | H3 (Casa Caju) | 50% |
| Cohen | H4 (Casa Coco) | 50% |

---

## 5. Key Files Reference

### Source Code Structure
```
src/
├── App.tsx                    # Routes, auth guards
├── components/
│   ├── AppLayout.tsx          # Sidebar + Outlet wrapper
│   ├── AppSidebar.tsx         # Navigation sidebar
│   └── ui/                   # shadcn/ui components
├── hooks/
│   ├── useAuth.tsx            # Auth context & provider
│   └── use-toast.ts           # Toast notifications
├── integrations/supabase/
│   ├── client.ts              # Auto-generated Supabase client
│   └── types.ts               # Auto-generated TypeScript types
├── lib/
│   ├── importService.ts       # DB insertion logic for imports
│   ├── parsers/
│   │   ├── salaryParser.ts    # Salary sheet parser
│   │   ├── bimTransferParser.ts
│   │   ├── monthEndParser.ts  # Income + expenses
│   │   ├── bdoBankParser.ts   # Bank statements
│   │   └── pettyCashParser.ts
│   └── utils.ts
├── pages/
│   ├── Auth.tsx
│   ├── Dashboard.tsx
│   ├── Employees.tsx
│   ├── Payroll.tsx
│   ├── Properties.tsx
│   ├── Shareholders.tsx
│   ├── Transactions.tsx
│   └── UploadData.tsx
└── index.css                  # Tailwind + design tokens
```

### Database Migrations
- Located in `supabase/migrations/`
- Applied automatically via Lovable Cloud

---

## 6. What Still Needs to Be Built

### Phase 4: Shareholder Management (Partially Done)
- [ ] Shareholder detail page with per-property P&L
- [ ] Monthly opening/closing balance calculations
- [ ] Shareholder drawings tracking
- [ ] Per-shareholder filtered reports

### Phase 6: Additional Data Features
- [ ] BDO bank transaction import (parser exists, needs testing with actual BDO sheets)
- [ ] Petty cash import (parser exists, needs testing)
- [ ] Exchange rate management UI
- [ ] INSS/IRPS payment recording UI

### Phase 8: Reports
- [ ] Monthly Ledger report
- [ ] Shareholder Statement (per-shareholder P&L for a period)
- [ ] Payroll Report (full salary breakdown by month)
- [ ] P&L per Property (annual)
- [ ] Print-friendly / PDF export styling

### Other Enhancements
- [ ] Data editing (currently read-only display)
- [ ] Duplicate import detection (warn if same month/year already imported)
- [ ] Salary run totals auto-update after import
- [ ] Admin role auto-assignment for first signup
- [ ] Google OAuth login option
- [ ] Expense category auto-matching in month-end parser
- [ ] Property-level expense allocation (shared vs house-specific)

---

## 7. How to Continue Development

### Adding a New Page
1. Create `src/pages/NewPage.tsx`
2. Add route in `src/App.tsx` inside `<Route element={<ProtectedRoutes />}>`
3. Add nav link in `src/components/AppSidebar.tsx`

### Adding a New Database Table
1. Use the Lovable migration tool or write SQL migration
2. Types auto-regenerate in `src/integrations/supabase/types.ts`
3. Always add RLS policies for security

### Adding a New Excel Parser
1. Create `src/lib/parsers/newParser.ts`
2. Add import function in `src/lib/importService.ts`
3. Add file type option in `src/pages/UploadData.tsx` (FILE_TYPES array)
4. Add case to the switch statements in handleFileSelect and handleImport

### Environment
- Supabase client configured via `.env` (auto-managed)
- Never edit `src/integrations/supabase/client.ts` or `types.ts` manually
- Use `import { supabase } from "@/integrations/supabase/client"` everywhere

---

## 8. RLS Security Model

All tables use Row Level Security:
- **Admins** (role = 'admin'): Full CRUD on all data tables
- **Viewers** (role = 'viewer'): Read-only access to all data tables
- **Profiles**: Users can only read/update their own profile
- **User roles**: Users can view their own roles; admins can manage all roles

The `has_role()` function is a `SECURITY DEFINER` function that bypasses RLS to check the `user_roles` table, preventing recursive policy evaluation.

---

*End of documentation*
