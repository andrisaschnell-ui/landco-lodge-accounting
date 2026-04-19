import * as XLSX from 'xlsx';

export interface ParsedBimTransfer {
  name: string;
  nib: string;
  amount: number;
  description: string;
}

export interface ParsedBimResult {
  transfers: ParsedBimTransfer[];
  month: number;
  year: number;
}

const num = (v: unknown): number => {
  if (v == null || v === '') return 0;
  const n = Number(v);
  return isNaN(n) ? 0 : n;
};
const str = (v: unknown): string => (v == null ? '' : String(v).trim());

export function parseBimTransfers(file: ArrayBuffer, month: number, year: number): ParsedBimResult {
  const wb = XLSX.read(file, { type: 'array' });

  // Extract BIM salary transfers from the "Folha de salarios" sheet
  // Each employee row has their name (col 2), NIB (col 31), and net salary (col 30)
  const sheetName = wb.SheetNames.find(
    (s) => s.toLowerCase().includes('folha') || s.toLowerCase().includes('salario')
  );
  if (!sheetName) throw new Error('Could not find "Folha de salarios" sheet');

  const ws = wb.Sheets[sheetName];
  const rows: unknown[][] = XLSX.utils.sheet_to_json(ws, { header: 1, defval: null });

  // Find header row
  let dataStart = -1;
  for (let i = 0; i < Math.min(rows.length, 15); i++) {
    const r = rows[i];
    if (!r) continue;
    if (str(r[0]).toUpperCase() === 'NO' && str(r[2]).toUpperCase().includes('NOME')) {
      dataStart = i + 2;
      break;
    }
  }

  const transfers: ParsedBimTransfer[] = [];
  if (dataStart < 0) return { transfers, month, year };

  for (let i = dataStart; i < rows.length; i++) {
    const row = rows[i];
    if (!row) continue;
    const no = num(row[0]);
    const name = str(row[2]);
    if (!no || !name) continue;

    const netSalary = num(row[30]);
    const nib = str(row[31]);

    if (netSalary > 0 && nib) {
      transfers.push({
        name,
        nib,
        amount: netSalary,
        description: `Salary transfer ${month}/${year}`,
      });
    }
  }

  return { transfers, month, year };
}
