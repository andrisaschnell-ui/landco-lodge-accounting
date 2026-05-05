import fs from "node:fs";
import path from "node:path";
import { parseLandcoIncome } from "../src/lib/parsers/landcoIncomeParser";

type PropertyRow = { id: string; code: string };
type ExchangeRateRow = { year: number; month: number; mzn_per_usd: number | string };

const API = "http://localhost:4000";

async function api<T>(token: string, pathName: string, init: RequestInit = {}): Promise<T> {
  const response = await fetch(`${API}${pathName}`, {
    ...init,
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${token}`,
      ...(init.headers ?? {}),
    },
  });
  if (!response.ok) throw new Error(`${pathName}: ${response.status} ${await response.text()}`);
  return response.json() as Promise<T>;
}

async function main() {
  const loginResponse = await fetch(`${API}/auth/login`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ email: "cwschnell@gmail.com", password: "Abcd7654$" }),
  });
  const loginPayload = await loginResponse.json();
  if (!loginResponse.ok) throw new Error(`login failed: ${JSON.stringify(loginPayload)}`);
  const token = loginPayload.token as string;

  const workbookPath = path.resolve(
    process.cwd(),
    "Accounts 2026",
    "Landco Accounts 2026",
    "01 JAN ACCOUNTS",
    "01 JAN MONTH END 2026.xlsx",
  );
  const file = fs.readFileSync(workbookPath);
  const parsed = parseLandcoIncome(
    file.buffer.slice(file.byteOffset, file.byteOffset + file.byteLength),
    1,
    2026,
  );

  const properties = await api<PropertyRow[]>(token, "/api/properties");
  const rates = await api<ExchangeRateRow[]>(token, "/api/exchange_rates");
  const propertyMap = new Map(properties.map((row) => [row.code, row.id]));
  const rateMap = new Map(rates.map((row) => [`${row.year}-${row.month}`, Number(row.mzn_per_usd)]));

  const uniquePeriods = Array.from(new Set(parsed.records.map((row) => `${row.periodYear}-${row.periodMonth}`)));
  for (const period of uniquePeriods) {
    const [year, month] = period.split("-");
    await api(token, `/api/landco_income?period_year=${year}&period_month=${month}`, { method: "DELETE" });
  }

  let inserted = 0;
  for (const row of parsed.records) {
    const exchangeRate = row.amountUsd > 0 ? row.totalMzn / row.amountUsd : rateMap.get(`${row.periodYear}-${row.periodMonth}`) ?? null;
    const amountUsd = row.amountUsd > 0
      ? row.amountUsd
      : exchangeRate && exchangeRate > 0
        ? row.totalMzn / exchangeRate
        : 0;

    await api(token, "/api/landco_income", {
      method: "POST",
      body: JSON.stringify({
        transaction_date: row.transactionDate,
        period_month: row.periodMonth,
        period_year: row.periodYear,
        property_id: propertyMap.get(row.propertyCode) ?? null,
        property_code: row.propertyCode,
        house_number: row.houseNumber,
        description: row.description,
        accommodation_amount_mzn: row.accommodationAmountMzn,
        h1_amount_mzn: row.h1AmountMzn,
        h2_amount_mzn: row.h2AmountMzn,
        h3_amount_mzn: row.h3AmountMzn,
        h4_amount_mzn: row.h4AmountMzn,
        total_mzn: row.totalMzn,
        amount_usd: amountUsd,
        exchange_rate_used: exchangeRate,
        monthly_total_mzn_source: row.monthlyTotalMznSource,
        source_file: path.basename(workbookPath),
        source_sheet: "INCOME",
        source_row_number: row.sourceRowNumber,
        import_notes: row.importNotes,
      }),
    });
    inserted += 1;
  }

  const insertedRows = await api<any[]>(token, "/api/landco_income");
  console.log(JSON.stringify({
    parsed: parsed.records.length,
    inserted,
    warnings: parsed.warnings.length,
    rowsInDb: insertedRows.length,
    firstRow: insertedRows[0] ?? null,
  }, null, 2));
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
