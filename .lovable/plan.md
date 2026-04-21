

## Goal
Sync the workspace with your local **v5** branch and finish the EXPENSES-sheet importer (NEGU excluded, LC = 25% split per house, house-specific columns mapped to owners).

## Step 1 — Ingest v5 source
After you approve, I switch to default mode and:
1. Unzip `LANACC_Project.zip` into `/tmp/v5_src`.
2. Diff against the current workspace and **overwrite** these folders with v5 contents:
   - `src/` (pages, components, parsers, lib, hooks)
   - `api/` (Express routes, server.js)
   - `db/init/` (schema + seed SQL)
   - `scripts/` (Windows .bat, recovery scripts)
   - `docker-compose.yml`, `Dockerfile`, `web/`, `.env.example`
3. Skip protected files: `src/integrations/supabase/client.ts`, `src/integrations/supabase/types.ts`, `.env`, `supabase/config.toml`, `package-lock.json`/`bun.lock`.
4. Run `tsc --noEmit` and `vite build` to confirm the v5 code compiles in the cloud workspace; fix any drift (e.g. Supabase types vs local-API client).

## Step 2 — Remove NEGU
- Delete NEGU from `properties` table via insert-tool DELETE.
- Add a hard-coded skip-list `["NEGU"]` in any property-resolving code in parsers/import service.
- Remove NEGU from `db/init/02_data.sql` so future on-prem rebuilds stay clean.

## Step 3 — New EXPENSES parser
Create `src/lib/parsers/expensesParser.ts` that reads the **EXPENSES** sheet, header on **row 6**, with this column map:

```text
LC SALARIES & WAGES                    → category=Salaries,        is_shared=true   (split 25% per house)
CASUAL WORKERS AND ALLOWANCE           → category=Casual Labour,   is_shared=true
ADVANCE SALARIES … (control col)       → SKIP (already in salaries)
OFFICE AND BANK CHARGES                → Office,                   is_shared=true
ADMIN CHARGES (BDO & ANDRISA)          → Admin,                    is_shared=true
GAS AND ELECTRICITY                    → Utilities,                is_shared=true
MAINTENANCE GENERAL                    → Maintenance,              is_shared=true
MAINTENANCE GARDEN & POOL              → Garden & Pool,            is_shared=true
SMALL TOOLS                            → Small Tools,              is_shared=true
EQUIPMENT                              → Equipment,                is_shared=true
MAINTENANCE VEHICLES                   → Vehicles,                 is_shared=true
INSURANCE & LICENSE                    → Insurance,                is_shared=true
DIESEL AND PETROL                      → Fuel,                     is_shared=true
HOUSE KEEPING                          → Housekeeping,             is_shared=true
MARITIME & MUNICIPAL TAXES (IPRA/TAE)  → Taxes,                    is_shared=true
COMMUNITY                              → Community,                is_shared=true
EXPENSES LUZ                           → property=H1 (Luz),        is_shared=false
EXPENSES AURORA                        → property=H2 (Aurora),     is_shared=false
EXPENSES CAJU                          → property=H3 (Caju),       is_shared=false
EXPENSES COCO                          → property=H4 (Coco),       is_shared=false
SUSPENCE                               → SKIP (control)
BALANCE                                → SKIP (control)
```

Each data row (date / supplier / description) emits **one expense_transactions row per non-zero amount column**. House-specific rows carry `property_id`; LC rows carry `is_shared=true` and no property_id (the existing 25%-split allocation logic on the report side handles distribution).

## Step 4 — Wire into Upload page
- Add an **"Expenses (Monthly)"** tile on `src/pages/UploadData.tsx`.
- Use the new parser; on import, call the existing `importMonthEnd`-style flow but write only to `expense_transactions`.
- Show a per-row preview with the resolved category + property before commit (matches the existing UI pattern).

## Step 5 — Deliverables
- Push everything to the connected branch (auto-syncs to GitHub).
- Generate a downloadable ZIP of the updated `src/lib/parsers/`, `src/lib/importService.ts`, `src/pages/UploadData.tsx`, plus a fresh `lanacc_full_db.sql` dump, dropped in `/mnt/documents/` as `lanacc_v5_patch.zip` and `lanacc_full_db.sql`.

## Notes / Risks
- I **cannot read the zip in plan mode** (no exec). Step 1 happens once you approve and I'm in default mode. If v5 has structural changes I didn't anticipate (e.g. renamed parsers), I'll reconcile before Step 3.
- I **cannot pull from GitHub `v5` directly** — the GitHub connector only syncs the branch this project is wired to (`v3-lovable`). The uploaded zip is the supported path.
- NEGU removal requires a DB write — I'll use the insert tool (DELETE) and you'll see an approval prompt.

