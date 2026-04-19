# LANACC Updates — Installation Instructions

## What's in this package
6 files to copy into your existing project at:
C:\Users\Andrisa\Documents\Projects\Landco\

## Files to copy (maintain folder structure)
- src/App.tsx                          (updated - adds /reports and /shareholders/:id routes)
- src/index.css                        (updated - adds print styles)
- src/components/AppSidebar.tsx        (updated - adds Reports nav item)
- src/pages/Shareholders.tsx           (updated - shareholder names now link to detail page)
- src/pages/Reports.tsx                (NEW - Monthly Ledger, Shareholder Statement, Payroll Report, P&L per Property)
- src/pages/ShareholderDetail.tsx      (NEW - individual shareholder P&L detail page)

## No database changes needed - schema is unchanged

## After copying files, rebuild the Docker container:
docker compose up -d --build

## Then test at http://localhost:8088:
- Sidebar should show "Reports" menu item
- /reports should show 4 report tabs with Print button
- /shareholders - click any name to open their detail page
