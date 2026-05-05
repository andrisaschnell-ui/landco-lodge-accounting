import * as XLSX from "xlsx";

export interface ParsedLandcoIncomeRow {
  sourceRowNumber: number;
  transactionDate: string;
  periodMonth: number;
  periodYear: number;
  houseNumber: number | null;
  propertyCode: "H1" | "H2" | "H3" | "H4";
  description: string;
  accommodationAmountMzn: number;
  h1AmountMzn: number;
  h2AmountMzn: number;
  h3AmountMzn: number;
  h4AmountMzn: number;
  totalMzn: number;
  amountUsd: number;
  monthlyTotalMznSource: number | null;
  importNotes: string | null;
}

export interface ParsedLandcoIncomeResult {
  records: ParsedLandcoIncomeRow[];
  warnings: string[];
  month: number;
  year: number;
}

const HEADER_ROW = ["DATE", "HOUSE", "NAME", "ACCOMODATION", "H1", "H2", "H3", "H4", "TOTAL MTS", "DOLLARS", "TOTAL PER MONTH"];
const PROPERTY_CODES = ["H1", "H2", "H3", "H4"] as const;

function str(value: unknown): string {
  return value == null ? "" : String(value).trim();
}

function num(value: unknown): number {
  if (value == null || value === "") return 0;
  const parsed = Number(value);
  return Number.isFinite(parsed) ? parsed : 0;
}

function sameHeader(row: unknown[]): boolean {
  return HEADER_ROW.every((header, index) => str(row[index]).toUpperCase() === header);
}

function normalizeDate(value: unknown, fallbackMonth: number, fallbackYear: number): { iso: string; month: number; year: number } {
  let dateObj: Date | null = null;

  if (value instanceof Date && !Number.isNaN(value.getTime())) {
    dateObj = value;
  } else if (typeof value === "number" && value > 30000) {
    const parsed = XLSX.SSF.parse_date_code(value);
    if (parsed) {
      dateObj = new Date(parsed.y, parsed.m - 1, parsed.d);
    }
  } else {
    const text = str(value);
    if (text) {
      const parsed = new Date(text);
      if (!Number.isNaN(parsed.getTime())) {
        dateObj = parsed;
      }
    }
  }

  if (dateObj) {
    const month = dateObj.getMonth() + 1;
    const day = dateObj.getDate();
    
    // Logic: Favor the fallbackYear, but allow a 1-year dip for December rows in a January import.
    let year = fallbackYear;
    if (month === 12 && fallbackMonth === 1) {
      year = fallbackYear - 1;
    }
    
    return {
      iso: `${year}-${String(month).padStart(2, "0")}-${String(day).padStart(2, "0")}`,
      month,
      year,
    };
  }

  return {
    iso: `${fallbackYear}-${String(fallbackMonth).padStart(2, "0")}-01`,
    month: fallbackMonth,
    year: fallbackYear,
  };
}

function inferHouseNumber(rawHouse: unknown): number | null {
  const text = str(rawHouse).toUpperCase();
  if (!text) return null;
  if (/^H[1-4]$/.test(text)) return Number(text.slice(1));
  const numeric = Number(text);
  if (Number.isInteger(numeric) && numeric >= 1 && numeric <= 4) return numeric;
  return null;
}

function inferPropertyCode(houseNumber: number | null, allocations: number[]): "H1" | "H2" | "H3" | "H4" | null {
  if (houseNumber && PROPERTY_CODES[houseNumber - 1]) return PROPERTY_CODES[houseNumber - 1];
  const nonZeroIndexes = allocations
    .map((value, index) => (value > 0 ? index : -1))
    .filter((index) => index >= 0);
  if (nonZeroIndexes.length === 1) return PROPERTY_CODES[nonZeroIndexes[0]];
  return null;
}

export function parseLandcoIncome(file: ArrayBuffer, fallbackMonth: number, fallbackYear: number): ParsedLandcoIncomeResult {
  const workbook = XLSX.read(file, { type: "array", cellDates: true });
  const sheet = workbook.Sheets.INCOME;
  if (!sheet) throw new Error("Workbook is missing the 'INCOME' sheet.");

  const rows = XLSX.utils.sheet_to_json<unknown[]>(sheet, { header: 1, defval: null, raw: true });
  const headerIndex = rows.findIndex((row) => sameHeader(row));
  if (headerIndex < 0) throw new Error("Could not find the INCOME sheet header row.");

  const records: ParsedLandcoIncomeRow[] = [];
  const warnings: string[] = [];

  for (let rowIndex = headerIndex + 1; rowIndex < rows.length; rowIndex += 1) {
    const row = rows[rowIndex];
    if (!row || row.every((cell) => str(cell) === "")) continue;

    const description = str(row[2]);
    const accommodationAmountMzn = num(row[3]);
    if (!description && accommodationAmountMzn === 0) continue;

    const date = normalizeDate(row[0], fallbackMonth, fallbackYear);
    const houseNumber = inferHouseNumber(row[1]);
    const allocations = [num(row[4]), num(row[5]), num(row[6]), num(row[7])];
    const propertyCode = inferPropertyCode(houseNumber, allocations);

    if (!propertyCode) {
      warnings.push(`Row ${rowIndex + 1}: could not infer property code from HOUSE/H1-H4 columns.`);
      continue;
    }

    const allocationPropertyCode = inferPropertyCode(null, allocations);
    const notes: string[] = [];
    if (allocationPropertyCode && houseNumber && allocationPropertyCode !== PROPERTY_CODES[houseNumber - 1]) {
      notes.push(`HOUSE=${PROPERTY_CODES[houseNumber - 1]} but allocation columns point to ${allocationPropertyCode}`);
      warnings.push(`Row ${rowIndex + 1}: HOUSE column and H1-H4 allocation columns do not match.`);
    }

    const totalMzn = num(row[8]) || allocations.reduce((sum, value) => sum + value, 0) || accommodationAmountMzn;
    const amountUsd = num(row[9]);
    const monthlyTotalMznSource = row[10] == null || row[10] === "" ? null : num(row[10]);

    records.push({
      sourceRowNumber: rowIndex + 1,
      transactionDate: date.iso,
      periodMonth: date.month,
      periodYear: date.year,
      houseNumber,
      propertyCode,
      description,
      accommodationAmountMzn,
      h1AmountMzn: allocations[0],
      h2AmountMzn: allocations[1],
      h3AmountMzn: allocations[2],
      h4AmountMzn: allocations[3],
      totalMzn,
      amountUsd,
      monthlyTotalMznSource,
      importNotes: notes.length > 0 ? notes.join("; ") : null,
    });
  }

  return { records, warnings, month: fallbackMonth, year: fallbackYear };
}
