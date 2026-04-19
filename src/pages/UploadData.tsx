import { useState, useCallback } from "react";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Badge } from "@/components/ui/badge";
import { Progress } from "@/components/ui/progress";
import { Upload, FileSpreadsheet, CheckCircle, AlertCircle, Loader2 } from "lucide-react";
import { toast } from "@/hooks/use-toast";
import { parseSalarySheet } from "@/lib/parsers/salaryParser";
import { parseBimTransfers } from "@/lib/parsers/bimTransferParser";
import { parseMonthEnd } from "@/lib/parsers/monthEndParser";
import { parseBdoBank } from "@/lib/parsers/bdoBankParser";
import { parsePettyCash } from "@/lib/parsers/pettyCashParser";
import {
  importSalary,
  importBimTransfers,
  importMonthEnd,
  importBdoBank,
  importPettyCash,
} from "@/lib/importService";

type FileType = "salary" | "bim_transfer" | "month_end" | "petty_cash" | "bdo_bank";
type UploadStatus = "idle" | "parsed" | "importing" | "success" | "error";

interface UploadState {
  file: File | null;
  status: UploadStatus;
  preview: string;
  recordCount: number;
  error: string;
}

const FILE_TYPES: { value: FileType; label: string; desc: string; sheet: string }[] = [
  { value: "month_end", label: "Month End (Invoices & Creditors)", desc: "Income from Invoices sheet, expenses from Creditors sheet", sheet: "Invoices + Creditors" },
  { value: "salary", label: "Salary Sheet (Folha de Salarios)", desc: "Employee salary data from Folha de salarios sheet", sheet: "Folha de salarios" },
  { value: "bim_transfer", label: "BIM Salary Transfers", desc: "Salary transfer list (name, NIB, net salary) from salary sheet", sheet: "Folha de salarios" },
  { value: "bdo_bank", label: "BIM Bank Control", desc: "Bank transactions from BIM Bank Control MZN + USD sheets", sheet: "BIM Bank Control Mtn + USD" },
  { value: "petty_cash", label: "Petty Cash + Pre-paid", desc: "Cash transactions from Petty cash and Pre-paid sheets", sheet: "Petty cash + Pre-paid" },
];

const MONTHS = [
  "January", "February", "March", "April", "May", "June",
  "July", "August", "September", "October", "November", "December",
];

export default function UploadData() {
  const [fileType, setFileType] = useState<FileType>("month_end");
  const [month, setMonth] = useState(String(new Date().getMonth() + 1));
  const [year, setYear] = useState(String(new Date().getFullYear()));
  const [state, setState] = useState<UploadState>({
    file: null, status: "idle", preview: "", recordCount: 0, error: "",
  });

  const handleFileSelect = useCallback(async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;

    setState({ file, status: "idle", preview: "", recordCount: 0, error: "" });

    try {
      const buffer = await file.arrayBuffer();
      const m = parseInt(month);
      const y = parseInt(year);
      let preview = "";
      let count = 0;

      switch (fileType) {
        case "salary": {
          const result = parseSalarySheet(buffer, m, y);
          count = result.lines.length;
          preview = result.lines
            .slice(0, 5)
            .map((l) => `${l.employee_name} (${l.category}) — Gross: ${l.gross_total.toLocaleString()} MZN, Net: ${l.net_salary.toLocaleString()} MZN`)
            .join("\n");
          break;
        }
        case "bim_transfer": {
          const result = parseBimTransfers(buffer, m, y);
          count = result.transfers.length;
          preview = result.transfers
            .slice(0, 5)
            .map((t) => `${t.name} — ${t.amount.toLocaleString()} MZN (NIB: ${t.nib})`)
            .join("\n");
          break;
        }
        case "month_end": {
          const result = parseMonthEnd(buffer, m, y);
          count = result.income.length + result.expenses.length;
          preview = `Income (Invoices): ${result.income.length} rows, Expenses (Creditors): ${result.expenses.length} rows\n`;
          if (result.income.length > 0) {
            preview += result.income
              .slice(0, 3)
              .map((i) => `  INV#${i.invoice_no} ${i.guest_name} — ${i.accommodation_amount_mzn.toLocaleString()} MZN`)
              .join("\n");
          }
          if (result.expenses.length > 0) {
            preview += "\n" + result.expenses
              .slice(0, 3)
              .map((e) => `  ${e.supplier}: ${e.description} — ${e.amount_mzn.toLocaleString()} MZN`)
              .join("\n");
          }
          break;
        }
        case "bdo_bank": {
          const result = parseBdoBank(buffer, m, y);
          count = result.transactions.length;
          preview = result.transactions
            .slice(0, 5)
            .map((t) => `${t.date} [${t.currency}] ${t.description} — In:${t.credit.toLocaleString()} Out:${t.debit.toLocaleString()}`)
            .join("\n");
          break;
        }
        case "petty_cash": {
          const results = parsePettyCash(buffer, m, y);
          count = results.reduce((s, r) => s + r.transactions.length, 0);
          preview = results
            .map((r) => `${r.sheetName}: ${r.transactions.length} transactions`)
            .join("\n");
          if (results.length > 0 && results[0].transactions.length > 0) {
            preview += "\n" + results[0].transactions
              .slice(0, 3)
              .map((t) => `  ${t.date} ${t.description} — In:${t.credit} Out:${t.debit}`)
              .join("\n");
          }
          break;
        }
      }

      setState({ file, status: "parsed", preview, recordCount: count, error: "" });
    } catch (err) {
      setState({
        file,
        status: "error",
        preview: "",
        recordCount: 0,
        error: err instanceof Error ? err.message : "Failed to parse file",
      });
    }
  }, [fileType, month, year]);

  const handleImport = useCallback(async () => {
    if (!state.file) return;
    setState((s) => ({ ...s, status: "importing" }));

    try {
      const buffer = await state.file.arrayBuffer();
      const m = parseInt(month);
      const y = parseInt(year);
      let imported = 0;

      switch (fileType) {
        case "salary": {
          const result = await importSalary(parseSalarySheet(buffer, m, y), state.file.name);
          imported = result.imported;
          if (result.unmatched.length > 0) {
            toast({
              title: `${result.unmatched.length} employees not matched`,
              description: result.unmatched.slice(0, 5).join(", "),
              variant: "destructive",
            });
          }
          break;
        }
        case "bim_transfer":
          imported = await importBimTransfers(parseBimTransfers(buffer, m, y), state.file.name);
          break;
        case "month_end":
          imported = await importMonthEnd(parseMonthEnd(buffer, m, y), state.file.name);
          break;
        case "bdo_bank":
          imported = await importBdoBank(parseBdoBank(buffer, m, y), state.file.name);
          break;
        case "petty_cash":
          imported = await importPettyCash(parsePettyCash(buffer, m, y), state.file.name);
          break;
      }

      setState((s) => ({ ...s, status: "success", recordCount: imported }));
      toast({ title: "Import complete", description: `${imported} records imported successfully.` });
    } catch (err) {
      const msg = err instanceof Error ? err.message : "Import failed";
      setState((s) => ({ ...s, status: "error", error: msg }));
      toast({ title: "Import failed", description: msg, variant: "destructive" });
    }
  }, [state.file, fileType, month, year]);

  const reset = () => {
    setState({ file: null, status: "idle", preview: "", recordCount: 0, error: "" });
  };

  const selectedType = FILE_TYPES.find((f) => f.value === fileType);

  return (
    <div className="space-y-6">
      <h1 className="text-3xl font-bold">Upload Data</h1>
      <p className="text-muted-foreground">
        Import data from BDO Bank Control Excel workbooks. Each file contains multiple sheets — select which data type to import.
      </p>

      <div className="grid gap-6 lg:grid-cols-3">
        <Card>
          <CardHeader>
            <CardTitle className="text-lg">Import Settings</CardTitle>
            <CardDescription>Select data type and period</CardDescription>
          </CardHeader>
          <CardContent className="space-y-4">
            <div className="space-y-2">
              <label className="text-sm font-medium">Data Type</label>
              <Select value={fileType} onValueChange={(v) => { setFileType(v as FileType); reset(); }}>
                <SelectTrigger><SelectValue /></SelectTrigger>
                <SelectContent>
                  {FILE_TYPES.map((ft) => (
                    <SelectItem key={ft.value} value={ft.value}>
                      <div>
                        <div>{ft.label}</div>
                        <div className="text-xs text-muted-foreground">{ft.desc}</div>
                      </div>
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>

            <div className="grid grid-cols-2 gap-3">
              <div className="space-y-2">
                <label className="text-sm font-medium">Month</label>
                <Select value={month} onValueChange={setMonth}>
                  <SelectTrigger><SelectValue /></SelectTrigger>
                  <SelectContent>
                    {MONTHS.map((m, i) => (
                      <SelectItem key={i + 1} value={String(i + 1)}>{m}</SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>
              <div className="space-y-2">
                <label className="text-sm font-medium">Year</label>
                <Select value={year} onValueChange={setYear}>
                  <SelectTrigger><SelectValue /></SelectTrigger>
                  <SelectContent>
                    {[2024, 2025, 2026, 2027].map((y) => (
                      <SelectItem key={y} value={String(y)}>{y}</SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>
            </div>

            {selectedType && (
              <div className="rounded-md bg-muted p-3 text-xs text-muted-foreground">
                <strong>Target sheets:</strong> {selectedType.sheet}
              </div>
            )}
          </CardContent>
        </Card>

        <Card className="lg:col-span-2">
          <CardHeader>
            <CardTitle className="text-lg flex items-center gap-2">
              <FileSpreadsheet className="h-5 w-5 text-primary" />
              {selectedType?.label}
            </CardTitle>
          </CardHeader>
          <CardContent className="space-y-4">
            {state.status === "idle" && (
              <label className="flex flex-col items-center justify-center border-2 border-dashed rounded-lg p-10 cursor-pointer hover:border-primary/50 transition-colors">
                <Upload className="h-10 w-10 text-muted-foreground mb-3" />
                <p className="text-sm font-medium">Drop your BDO Bank Control Excel file here or click to browse</p>
                <p className="text-xs text-muted-foreground mt-1">.xlsx files — e.g. "01 BDO Bank Control 2026.xlsx"</p>
                <Input
                  type="file"
                  accept=".xlsx,.xls"
                  className="hidden"
                  onChange={handleFileSelect}
                />
              </label>
            )}

            {state.status === "parsed" && (
              <div className="space-y-4">
                <div className="flex items-center justify-between">
                  <div className="flex items-center gap-2">
                    <CheckCircle className="h-5 w-5 text-green-500" />
                    <span className="font-medium">{state.file?.name}</span>
                  </div>
                  <Badge variant="secondary">{state.recordCount} records found</Badge>
                </div>
                <pre className="bg-muted p-4 rounded-lg text-sm font-mono whitespace-pre-wrap max-h-48 overflow-y-auto">
                  {state.preview}
                </pre>
                <div className="flex gap-3">
                  <Button onClick={handleImport}>
                    Import {state.recordCount} Records
                  </Button>
                  <Button variant="outline" onClick={reset}>Cancel</Button>
                </div>
              </div>
            )}

            {state.status === "importing" && (
              <div className="space-y-3 text-center py-8">
                <Loader2 className="h-8 w-8 animate-spin mx-auto text-primary" />
                <p className="text-sm text-muted-foreground">Importing {state.recordCount} records...</p>
                <Progress value={50} className="max-w-xs mx-auto" />
              </div>
            )}

            {state.status === "success" && (
              <div className="text-center py-8 space-y-3">
                <CheckCircle className="h-12 w-12 text-green-500 mx-auto" />
                <p className="font-medium">Successfully imported {state.recordCount} records</p>
                <p className="text-sm text-muted-foreground">
                  {MONTHS[parseInt(month) - 1]} {year} — {selectedType?.label}
                </p>
                <Button variant="outline" onClick={reset}>Upload Another File</Button>
              </div>
            )}

            {state.status === "error" && (
              <div className="text-center py-8 space-y-3">
                <AlertCircle className="h-12 w-12 text-destructive mx-auto" />
                <p className="font-medium">Import Failed</p>
                <p className="text-sm text-destructive">{state.error}</p>
                <Button variant="outline" onClick={reset}>Try Again</Button>
              </div>
            )}
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
