import fs from "node:fs";
import path from "node:path";
import { describe, expect, it } from "vitest";
import { parseLandcoIncome } from "@/lib/parsers/landcoIncomeParser";

describe("parseLandcoIncome", () => {
  it("parses the January workbook INCOME sheet into owner-linked rows", () => {
    const workbookPath = path.resolve(
      process.cwd(),
      "Accounts 2026",
      "Landco Accounts 2026",
      "01 JAN ACCOUNTS",
      "01 JAN MONTH END 2026.xlsx",
    );
    const buffer = fs.readFileSync(workbookPath);
    const parsed = parseLandcoIncome(
      buffer.buffer.slice(buffer.byteOffset, buffer.byteOffset + buffer.byteLength),
      1,
      2026,
    );

    expect(parsed.records.length).toBeGreaterThan(5);
    expect(parsed.records[0]).toMatchObject({
      transactionDate: "2026-01-02",
      propertyCode: "H3",
      description: "ALEX",
      totalMzn: 594297,
    });
    expect(parsed.warnings.length).toBeGreaterThan(0);
  });
});
