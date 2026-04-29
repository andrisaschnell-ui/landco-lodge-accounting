# LANACC — Development Plan & Codebase Audit
## Based on Landco_DevDoc.md Cross-Referenced Against Actual Source Code

**Generated:** 13 April 2026  
**Project:** Landco Lda — Vilanculos, Mozambique  
**Stack:** React 18 + Vite + TypeScript + Tailwind CSS + Supabase (Lovable Cloud)  
**Local Docker Stack:** `landco_lovable_frontend` (port 8088) + `landco_lovable_db` PostgreSQL 15 (port 5433)

---

## 1. Codebase Verification — DevDoc vs Actual Files

Every item documented in `Landco_DevDoc.md` sections 1–5 has been verified against the source tree.

### 1.1 Pages & Routes

| Doc Route | Page File | Exists | Size |
|-----------|-----------|--------|------|
| `/auth` | `src/pages/Auth.tsx` | ✅ | 2.8KB |
| `/` | `src/pages/Dashboard.tsx` | ✅ | 9.9KB |
| `/transactions` | `src/pages/Transactions.tsx` | ✅ | 8.6KB |
| `/shareholders` | `src/pages/Shareholders.tsx` | ✅ | 3.7KB |
| `/employees` | `src/pages/Employees.tsx` | ✅ | 2.5KB |
| `/payroll` | `src/pages/Payroll.tsx` | ✅ | 5.0KB |
| `/properties` | `src/pages/Properties.tsx` | ✅ | 2.8KB |
| `/upload` | `src/pages/UploadData.tsx` | ✅ | 12.5KB |
| `*` (404) | `src/pages/NotFound.tsx` | ✅ | 0.7KB |

All routes confirmed in `src/App.tsx` (lines 53–62) inside `<Route element={<ProtectedRoutes />}>`.

### 1.2 Layout & Navigation

| Component | File | Exists |
|-----------|------|--------|
| App Layout (Sidebar wrapper) | `src/components/AppLayout.tsx` | ✅ |
| Sidebar Navigation | `src/components/AppSidebar.tsx` | ✅ |
| Nav Link helper | `src/components/NavLink.tsx` | ✅ |
| shadcn/ui components | `src/components/ui/` | ✅ (directory) |

### 1.3 Authentication & Hooks

| Component | File | Exists |
|-----------|------|--------|
| Auth context & provider | `src/hooks/useAuth.tsx` | ✅ |
| Toast notifications | `src/hooks/use-toast.ts` | ✅ |
| Mobile detection | `src/hooks/use-mobile.tsx` | ✅ |

### 1.4 Excel Import System

| Parser | File | Exists | Size |
|--------|------|--------|------|
| Salary Sheet | `src/lib/parsers/salaryParser.ts` | ✅ | 3.6KB |
| BIM Salary Transfers | `src/lib/parsers/bimTransferParser.ts` | ✅ | 1.5KB |
| Month End (Income + Expenses) | `src/lib/parsers/monthEndParser.ts` | ✅ | 4.2KB |
| BDO Bank Control | `src/lib/parsers/bdoBankParser.ts` | ✅ | 2.2KB |
| Petty Cash | `src/lib/parsers/pettyCashParser.ts` | ✅ | 2.2KB |
| Import Service (DB insertion) | `src/lib/importService.ts` | ✅ | 7.3KB |
| Utility functions | `src/lib/utils.ts` | ✅ | 0.2KB |

### 1.5 Supabase Integration

| Component | File/Location | Exists |
|-----------|--------------|--------|
| Supabase client | `src/integrations/supabase/` | ✅ |
| Environment config | `.env` (Supabase Cloud URL + anon key) | ✅ |
| Database migration | `supabase/migrations/` (1 file, 16.8KB) | ✅ |

### 1.6 Verdict

> **100% match.** Every file and structure described in the DevDoc exists in the codebase. The documentation is accurate and trustworthy.

---

## 2. Current Architecture — Important Note

The application currently connects to **Supabase Cloud**:

```
VITE_SUPABASE_URL = https://neakxehuonsrlvjrxhnd.supabase.co
```

This means:
- ✅ **Frontend** runs locally in Docker container `landco_lovable_frontend` on **port 8088**
- ☁️ **Database & Auth** are hosted on Lovable/Supabase cloud (not the local PostgreSQL)
- ⏳ The local `landco_lovable_db` PostgreSQL container (port 5433) is **running but not yet wired up**

### Decision Required

| Option | Pros | Cons |
|--------|------|------|
| **A. Keep Supabase Cloud** | Zero migration work, auth works immediately, data already seeded | Requires internet, depends on Lovable subscription |
| **B. Go Fully Local** | Offline capable, full control, no external dependency | Requires local Supabase setup or direct Postgres wiring, auth migration needed |
| **C. Hybrid** | Dev locally, deploy to cloud | More complex config management |

---

## 3. What Still Needs to Be Built

### Phase 1: High Priority — Core Functionality Gaps

| # | Feature | Description | Complexity | Est. Effort |
|---|---------|-------------|------------|-------------|
| 1 | **Data Editing** | Tables are currently read-only. Need inline editing / modal forms for CRUD on all data tables | Medium | 2–3 days |
| 2 | **Duplicate Import Detection** | Warn if same month/year data already imported before allowing re-import | Low | 0.5 day |
| 3 | **Salary Run Totals Auto-Update** | After salary line import, recalculate and update salary_runs totals | Low | 0.5 day |

### Phase 2: Shareholder Management (Partially Done)

| # | Feature | Description | Complexity | Est. Effort |
|---|---------|-------------|------------|-------------|
| 4 | **Shareholder Detail Page** | Per-shareholder view showing property P&L breakdown | Medium | 1–2 days |
| 5 | **Monthly Balance Calculations** | Opening/closing balance logic per shareholder per property per month | Medium | 1–2 days |
| 6 | **Shareholder Drawings** | Track cash withdrawals / capital contributions per shareholder | Low | 1 day |
| 7 | **Per-Shareholder Filtered Reports** | Filter all financial data by shareholder context | Low | 0.5 day |

### Phase 3: Additional Data Features

| # | Feature | Description | Complexity | Est. Effort |
|---|---------|-------------|------------|-------------|
| 8 | **BDO Bank Import Testing** | Parser exists — needs testing with actual BDO statement Excel files | Low | 0.5 day |
| 9 | **Petty Cash Import Testing** | Parser exists — needs testing with actual petty cash Excel files | Low | 0.5 day |
| 10 | **Exchange Rate Management UI** | Page/modal to input monthly MZN/USD and MZN/ZAR rates | Low | 0.5 day |
| 11 | **INSS/IRPS Payment Recording UI** | Forms to record statutory payment submissions with dates & references | Low | 1 day |

### Phase 4: Reports

| # | Feature | Description | Complexity | Est. Effort |
|---|---------|-------------|------------|-------------|
| 12 | **Monthly Ledger Report** | Full month-end ledger showing all income, expenses, bank movements | Medium | 1–2 days |
| 13 | **Shareholder Statement** | Per-shareholder P&L for a selected period | Medium | 1–2 days |
| 14 | **Payroll Report** | Full salary breakdown table by month (print-ready) | Medium | 1 day |
| 15 | **P&L per Property (Annual)** | Year-to-date profit & loss broken down by property (H1–H4, NEGU) | Medium–High | 2 days |
| 16 | **PDF Export** | Print-friendly styling and/or PDF generation for all reports | Medium | 1–2 days |

### Phase 5: Polish & Security

| # | Feature | Description | Complexity | Est. Effort |
|---|---------|-------------|------------|-------------|
| 17 | **Admin Auto-Assignment** | First user to sign up automatically gets admin role | Low | 0.5 day |
| 18 | **Google OAuth Login** | Add Google sign-in as alternative to email/password | Low | 0.5 day |
| 19 | **Expense Category Auto-Matching** | Improve month-end parser to auto-match categories from descriptions | Medium | 1 day |
| 20 | **Property Expense Allocation** | Logic for splitting shared expenses vs house-specific expenses | Medium | 1–2 days |

---

## 4. Suggested Priority Order

```
┌─────────────────────────────────────────────────────┐
│  IMMEDIATE (This Week)                               │
│  ► Decide: Cloud Supabase vs Local Postgres          │
│  ► Data Editing (CRUD on tables)                     │
│  ► Duplicate Import Detection                        │
├─────────────────────────────────────────────────────┤
│  SHORT TERM (Next 1–2 Weeks)                         │
│  ► Shareholder Detail Page + Balances                │
│  ► Monthly Ledger Report                             │
│  ► Payroll Report                                    │
│  ► Test BDO Bank + Petty Cash parsers                │
├─────────────────────────────────────────────────────┤
│  MEDIUM TERM (Weeks 3–4)                             │
│  ► Shareholder Statement Report                      │
│  ► P&L per Property (Annual)                         │
│  ► Exchange Rate + INSS/IRPS UIs                     │
│  ► PDF Export                                        │
├─────────────────────────────────────────────────────┤
│  NICE TO HAVE                                        │
│  ► Google OAuth                                      │
│  ► Expense auto-matching                             │
│  ► Property expense allocation engine                │
│  ► Admin auto-assignment on first signup              │
└─────────────────────────────────────────────────────┘
```

---

## 5. Docker Setup Reference

### Container Isolation (vs existing `landco-lodge-accounting` app)

| Resource | Existing App | New Lovable App |
|----------|-------------|-----------------|
| **Folder** | `landco-lodge-accounting/` | `landco/` |
| **Web Port** | varies | **8088** |
| **DB Port** | 5432 (default) | **5433** |
| **Docker Network** | default | **landco_lovable_network** |
| **DB Volume** | separate | **landco_lovable_pgdata_volume** |
| **Frontend Container** | `landco-lodge-accounting-*` | **landco_lovable_frontend** |
| **DB Container** | — | **landco_lovable_db** |

### Access URLs

| From | URL |
|------|-----|
| This machine | `http://localhost:8088` |
| Other devices on WiFi | `http://192.168.0.206:8088` |
| Database client (pgAdmin etc.) | Host: `localhost`, Port: `5433`, User: `postgres`, Pass: `root`, DB: `landco_v2_db` |

### Docker Commands (run from `C:\Users\Andrisa\Documents\Projects\landco`)

```bash
# Start containers
docker compose up -d

# Stop containers
docker compose down

# Rebuild after code changes
docker compose up -d --build

# View frontend logs
docker logs landco_lovable_frontend

# View database logs
docker logs landco_lovable_db
```

### Windows Firewall

Port 8088 has been opened for inbound TCP connections:
```powershell
# Rule name: "Landco Lovable App (port 8088)"
# To remove later:
netsh advfirewall firewall delete rule name="Landco Lovable App (port 8088)"
```

---

## 6. Key Files Quick Reference

```
landco/
├── .env                              # Supabase Cloud credentials
├── Dockerfile                        # Frontend container definition
├── docker-compose.yml                # Full stack (frontend + postgres)
├── Landco_DevDoc.md                  # Original development documentation
├── Landco_DevDocPlan.md              # THIS FILE — development plan
├── package.json                      # Dependencies (React 18, Vite 5, etc.)
├── vite.config.ts                    # Dev server config (port 8080 internal)
├── supabase/
│   └── migrations/                   # Database schema SQL (16.8KB)
└── src/
    ├── App.tsx                       # Router + auth guards
    ├── components/
    │   ├── AppLayout.tsx             # Sidebar wrapper
    │   ├── AppSidebar.tsx            # Navigation links
    │   └── ui/                       # shadcn/ui library
    ├── hooks/
    │   ├── useAuth.tsx               # Auth context
    │   └── use-toast.ts              # Toast notifications
    ├── integrations/supabase/        # Auto-generated client + types
    ├── lib/
    │   ├── importService.ts          # DB insertion for imports
    │   └── parsers/                  # 5 Excel parsers
    └── pages/                        # 9 page components
```

---

*This plan will be updated as features are completed.*
