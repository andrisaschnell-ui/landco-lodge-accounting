import json
import os
from datetime import date, datetime

import openpyxl


ROOT = r"C:\Users\Andrisa\Documents\Projects\landco"
BDO_DIR = os.path.join(ROOT, "Accounts 2026", "BDO Accounts 2026")


def parse_date(value):
    if value is None:
        return None
    if isinstance(value, datetime):
        return value.date().isoformat()
    if isinstance(value, date):
        return value.isoformat()
    text = str(value).strip()
    if not text:
        return None
    for fmt in ("%Y-%m-%d", "%d/%m/%Y", "%m/%d/%Y"):
        try:
            return datetime.strptime(text, fmt).date().isoformat()
        except ValueError:
            pass
    try:
        return datetime.fromisoformat(text).date().isoformat()
    except ValueError:
        return None


def num(value):
    if value in (None, ""):
        return 0
    try:
        return float(value)
    except Exception:
        try:
            return float(str(value).replace(",", "").strip())
        except Exception:
            return 0


def extract_petty_cash(file_path):
    wb = openpyxl.load_workbook(file_path, read_only=True, data_only=True, keep_links=False)
    try:
        ws = wb["Petty cash "]
        month = int(os.path.basename(file_path)[:2])
        rows = []
        started = False

        for row in ws.iter_rows(min_row=11, values_only=True):
            date_value = parse_date(row[0] if len(row) > 0 else None)
            reference = str(row[1]).strip() if len(row) > 1 and row[1] not in (None, "") else None
            supplier = str(row[2]).strip() if len(row) > 2 and row[2] not in (None, "") else None
            description = str(row[3]).strip() if len(row) > 3 and row[3] not in (None, "") else None
            allocation = str(row[4]).strip() if len(row) > 4 and row[4] not in (None, "") else None
            credit = num(row[5] if len(row) > 5 else None)
            debit = num(row[6] if len(row) > 6 else None)
            balance = num(row[7] if len(row) > 7 else None)
            vat_amount = num(row[8] if len(row) > 8 else None)
            net_amount = num(row[9] if len(row) > 9 else None)

            if not any([date_value, supplier, description, credit, debit]):
                if started:
                    break
                continue

            if not date_value:
                continue

            started = True
            combined_description = " | ".join(part for part in [supplier, description, allocation] if part) or "Petty cash item"

            rows.append(
                {
                    "date": date_value,
                    "description": combined_description,
                    "credit": credit,
                    "debit": debit,
                    "balance": balance,
                    "month": month,
                    "year": 2026,
                    "reference": reference,
                    "supplier": supplier,
                    "allocation": allocation,
                    "vat_amount": vat_amount,
                    "net_amount": net_amount,
                    "source_file": os.path.basename(file_path),
                }
            )

        return rows
    finally:
        wb.close()


def main():
    files = sorted(
        os.path.join(BDO_DIR, name)
        for name in os.listdir(BDO_DIR)
        if name.lower().endswith(".xlsx") and not name.startswith("~$")
    )
    payload = {"petty_cash": []}
    for file_path in files:
        payload["petty_cash"].extend(extract_petty_cash(file_path))
    print(json.dumps(payload))


if __name__ == "__main__":
    main()
