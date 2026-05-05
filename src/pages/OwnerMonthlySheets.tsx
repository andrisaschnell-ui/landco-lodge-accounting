import { useState } from "react";
import { useQuery } from "@tanstack/react-query";
import { api } from "@/lib/api";
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Badge } from "@/components/ui/badge";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { Button } from "@/components/ui/button";
import { Home, FileSpreadsheet, TrendingUp, TrendingDown, Users, Wallet } from "lucide-react";
import * as XLSX from "xlsx";

const HOUSES = [
  { code: "H1", name: "H1 — Casa Luz" },
  { code: "H2", name: "H2 — Casa Aurora" },
  { code: "H3", name: "H3 — Casa Caju" },
  { code: "H4", name: "H4 — Casa Coco" },
];

const MONTHS = [
  { value: "1", label: "January" }, { value: "2", label: "February" },
  { value: "3", label: "March" }, { value: "4", label: "April" },
  { value: "5", label: "May" }, { value: "6", label: "June" },
  { value: "7", label: "July" }, { value: "8", label: "August" },
  { value: "9", label: "September" }, { value: "10", label: "October" },
  { value: "11", label: "November" }, { value: "12", label: "December" },
];

function fmt(v: number) {
  return Number(v || 0).toLocaleString("pt-MZ", { minimumFractionDigits: 2, maximumFractionDigits: 2 });
}

export default function OwnerMonthlySheets() {
  const [selectedHouse, setSelectedHouse] = useState("H1");
  const [selectedYear, setSelectedYear] = useState("2026");
  const [selectedMonth, setSelectedMonth] = useState("1");

  const { data: report, isLoading, error } = useQuery({
    queryKey: ["owner-monthly", selectedHouse, selectedYear, selectedMonth],
    queryFn: () => api(`/api/reports/owner-monthly/${selectedHouse}?year=${selectedYear}&month=${selectedMonth}`),
  });

  const downloadExcel = () => {
    if (!report) return;

    const workbook = XLSX.utils.book_new();

    // 1. SUMMARY
    const summaryData = report.summary.map((s: any) => ({
      Month: MONTHS.find(m => m.value === String(s.month))?.label,
      "Income": s.income,
      "Expenses": s.expenses,
      "Closing Balance": s.closing
    }));
    const summaryWS = XLSX.utils.json_to_sheet(summaryData);
    XLSX.utils.book_append_sheet(workbook, summaryWS, "SUMMERY");

    // 2. Breakdown of Income
    const incomeData = report.incomeBreakdown.map((i: any) => ({
      Date: i.date,
      Description: i.description,
      "Amount MZN": i.mzn,
      "Amount USD": i.usd,
      Rate: i.rate
    }));
    const incomeWS = XLSX.utils.json_to_sheet(incomeData);
    XLSX.utils.book_append_sheet(workbook, incomeWS, "Breakdown of Income");

    // 3. INCOME VS EXPENSES
    const analysisData = [
      { Category: "Total Income", Amount: report.analysis.totalIncome },
      { Category: "Total Expenses", Amount: report.analysis.totalExpenses },
      { Category: "Shared Total (25%)", Amount: report.analysis.sharedTotal },
      { Category: "Personal Total (100%)", Amount: report.analysis.personalTotal },
      { Category: "Net Position", Amount: report.analysis.totalIncome - report.analysis.totalExpenses }
    ];
    const analysisWS = XLSX.utils.json_to_sheet(analysisData);
    XLSX.utils.book_append_sheet(workbook, analysisWS, "INCOME VS EXPENSES");

    // 4. Expenses
    const personalRows = report.expenses.personal.map((e: any) => ({ Type: "PERSONAL", Description: e.description, Amount: e.amount }));
    const sharedRows = report.expenses.shared.map((e: any) => ({ Type: "SHARED (100%)", Description: e.description, Amount: e.amount, "Your Share (25%)": e.share }));
    const expenseWS = XLSX.utils.json_to_sheet([...personalRows, ...sharedRows]);
    XLSX.utils.book_append_sheet(workbook, expenseWS, "Expenses");

    XLSX.writeFile(workbook, `Shareholder_Report_${selectedHouse}_${selectedMonth}_${selectedYear}.xlsx`);
  };

  if (isLoading) return <div className="p-8 text-center text-muted-foreground">Generating live report...</div>;
  if (error) return <div className="p-8 text-center text-red-500">Failed to generate report. {String(error)}</div>;

  const house = HOUSES.find(h => h.code === selectedHouse);
  const monthName = MONTHS.find(m => m.value === selectedMonth)?.label;

  return (
    <div className="space-y-6">
      <div className="flex flex-col gap-4 md:flex-row md:items-end md:justify-between">
        <div>
          <h1 className="text-3xl font-bold flex items-center gap-2">
            <Home size={28} /> Owner Monthly Sheets
          </h1>
          <p className="text-muted-foreground text-sm mt-1">
            Mimicking shareholder Excel workbooks with live data.
          </p>
        </div>
        <div className="flex gap-3 flex-wrap">
          <Button variant="outline" onClick={downloadExcel}>
            <FileSpreadsheet className="mr-2 h-4 w-4" /> Download Excel
          </Button>
          <Select value={selectedHouse} onValueChange={setSelectedHouse}>
            <SelectTrigger className="w-48"><SelectValue /></SelectTrigger>
            <SelectContent>
              {HOUSES.map(h => <SelectItem key={h.code} value={h.code}>{h.name}</SelectItem>)}
            </SelectContent>
          </Select>
          <Select value={selectedYear} onValueChange={setSelectedYear}>
            <SelectTrigger className="w-28"><SelectValue /></SelectTrigger>
            <SelectContent>
              <SelectItem value="2026">2026</SelectItem>
              <SelectItem value="2025">2025</SelectItem>
            </SelectContent>
          </Select>
          <Select value={selectedMonth} onValueChange={setSelectedMonth}>
            <SelectTrigger className="w-40"><SelectValue /></SelectTrigger>
            <SelectContent>
              {MONTHS.map(m => <SelectItem key={m.value} value={m.value}>{m.label}</SelectItem>)}
            </SelectContent>
          </Select>
        </div>
      </div>

      <Tabs defaultValue="summary" className="w-full">
        <TabsList>
          <TabsTrigger value="summary">SUMMERY</TabsTrigger>
          <TabsTrigger value="income">Breakdown of Income</TabsTrigger>
          <TabsTrigger value="analysis">INCOME VS EXPENSES</TabsTrigger>
          <TabsTrigger value="expenses">Expenses Detail</TabsTrigger>
        </TabsList>

        <TabsContent value="summary" className="mt-4">
          <Card>
            <CardHeader><CardTitle>SUMMERY — Yearly Overview ({selectedYear})</CardTitle></CardHeader>
            <CardContent>
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead>Month</TableHead>
                    <TableHead className="text-right">Income</TableHead>
                    <TableHead className="text-right">Expenses</TableHead>
                    <TableHead className="text-right font-bold">Closing Balance</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {report.summary.map((s: any) => (
                    <TableRow key={s.month} className={String(s.month) === selectedMonth ? "bg-muted/50 font-medium" : ""}>
                      <TableCell>{MONTHS.find(m => m.value === String(s.month))?.label}</TableCell>
                      <TableCell className="text-right text-green-600">{fmt(s.income)}</TableCell>
                      <TableCell className="text-right text-red-600">({fmt(s.expenses)})</TableCell>
                      <TableCell className="text-right font-mono">{fmt(s.closing)}</TableCell>
                    </TableRow>
                  ))}
                </TableBody>
              </Table>
            </CardContent>
          </Card>
        </TabsContent>

        <TabsContent value="income" className="mt-4">
          <Card>
            <CardHeader><CardTitle>Breakdown of Income — {monthName} {selectedYear}</CardTitle></CardHeader>
            <CardContent>
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead>Date</TableHead>
                    <TableHead>Description</TableHead>
                    <TableHead className="text-right">MZN</TableHead>
                    <TableHead className="text-right">USD</TableHead>
                    <TableHead className="text-right">Rate</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {report.incomeBreakdown.map((i: any, idx: number) => (
                    <TableRow key={idx}>
                      <TableCell className="text-xs">{i.date?.slice(0, 10)}</TableCell>
                      <TableCell>{i.description}</TableCell>
                      <TableCell className="text-right font-mono text-green-700">{fmt(i.mzn)}</TableCell>
                      <TableCell className="text-right font-mono text-blue-700">${fmt(i.usd)}</TableCell>
                      <TableCell className="text-right text-muted-foreground">{i.rate}</TableCell>
                    </TableRow>
                  ))}
                  {!report.incomeBreakdown.length && <TableRow><TableCell colSpan={5} className="text-center py-8 text-muted-foreground">No income recorded for this period.</TableCell></TableRow>}
                </TableBody>
              </Table>
            </CardContent>
          </Card>
        </TabsContent>

        <TabsContent value="analysis" className="mt-4">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <Card>
              <CardHeader><CardTitle>Income vs Expenses Comparison</CardTitle></CardHeader>
              <CardContent className="space-y-4">
                <div className="flex justify-between items-center border-b pb-2">
                  <span>Total Funds Available</span>
                  <span className="font-bold text-green-700">{fmt(report.analysis.totalIncome)} MZN</span>
                </div>
                <div className="flex justify-between items-center border-b pb-2">
                  <span>Total Monthly Expenses</span>
                  <span className="font-bold text-red-600">{fmt(report.analysis.totalExpenses)} MZN</span>
                </div>
                <div className="flex justify-between items-center pt-2 text-lg font-bold">
                  <span>Net Monthly Position</span>
                  <span className={report.analysis.totalIncome - report.analysis.totalExpenses >= 0 ? "text-blue-700" : "text-red-700"}>
                    {fmt(report.analysis.totalIncome - report.analysis.totalExpenses)} MZN
                  </span>
                </div>
              </CardContent>
            </Card>
            <Card>
              <CardHeader><CardTitle>Expense Split</CardTitle></CardHeader>
              <CardContent className="space-y-4">
                <div className="flex justify-between items-center border-b pb-2">
                  <span className="flex items-center gap-2"><Users size={16} /> Shared Expenses (Your 25% Share)</span>
                  <span className="font-mono text-purple-700">{fmt(report.analysis.sharedTotal)} MZN</span>
                </div>
                <div className="flex justify-between items-center border-b pb-2">
                  <span className="flex items-center gap-2"><Wallet size={16} /> Personal Expenses (100%)</span>
                  <span className="font-mono text-orange-700">{fmt(report.analysis.personalTotal)} MZN</span>
                </div>
              </CardContent>
            </Card>
          </div>
        </TabsContent>

        <TabsContent value="expenses" className="mt-4 space-y-4">
          <Card>
            <CardHeader><CardTitle>Detailed Ledger — {monthName} {selectedYear}</CardTitle></CardHeader>
            <CardContent>
              <div className="space-y-6">
                {/* Salaries Section */}
                <div>
                  <h3 className="font-semibold text-purple-700 border-b mb-2 flex items-center gap-2">
                    <Users size={18} /> Payroll (Retrieved from Database)
                  </h3>
                  <Table>
                    <TableHeader>
                      <TableRow>
                        <TableHead>Employee</TableHead>
                        <TableHead>Type</TableHead>
                        <TableHead className="text-right">Full Cost</TableHead>
                        <TableHead className="text-right">Your Share</TableHead>
                      </TableRow>
                    </TableHeader>
                    <TableBody>
                      {report.expenses.salaries.direct.map((s: any, idx: number) => (
                        <TableRow key={`d-${idx}`}>
                          <TableCell>{s.employee_name}</TableCell>
                          <TableCell><Badge variant="outline">Personal Staff (100%)</Badge></TableCell>
                          <TableCell className="text-right">{fmt(s.total_cost)}</TableCell>
                          <TableCell className="text-right font-mono">{fmt(s.owed)}</TableCell>
                        </TableRow>
                      ))}
                      {report.expenses.salaries.shared.map((s: any, idx: number) => (
                        <TableRow key={`s-${idx}`}>
                          <TableCell>{s.employee_name}</TableCell>
                          <TableCell><Badge variant="secondary">Communal Staff (25%)</Badge></TableCell>
                          <TableCell className="text-right">{fmt(s.total_cost)}</TableCell>
                          <TableCell className="text-right font-mono text-purple-700">{fmt(s.owed)}</TableCell>
                        </TableRow>
                      ))}
                    </TableBody>
                  </Table>
                </div>

                {/* Petty Cash */}
                <div>
                  <h3 className="font-semibold text-orange-600 border-b mb-2 flex items-center gap-2">
                    <Wallet size={18} /> Petty Cash Share (25%)
                  </h3>
                  <Table>
                    <TableHeader>
                      <TableRow>
                        <TableHead>Date</TableHead>
                        <TableHead>Description</TableHead>
                        <TableHead className="text-right">Full Amount</TableHead>
                        <TableHead className="text-right">Your Share</TableHead>
                      </TableRow>
                    </TableHeader>
                    <TableBody>
                      {report.expenses.pettyCash.map((p: any, idx: number) => (
                        <TableRow key={idx}>
                          <TableCell className="text-xs">{p.date?.slice(0,10)}</TableCell>
                          <TableCell>{p.supplier || p.description}</TableCell>
                          <TableCell className="text-right">{fmt(p.amount)}</TableCell>
                          <TableCell className="text-right font-mono text-orange-600">{fmt(p.share)}</TableCell>
                        </TableRow>
                      ))}
                    </TableBody>
                  </Table>
                </div>

                {/* Personal Expenses */}
                <div>
                  <h3 className="font-semibold text-blue-700 border-b mb-2">Direct House Expenses (100%)</h3>
                  <Table>
                    <TableHeader>
                      <TableRow>
                        <TableHead>Date</TableHead>
                        <TableHead>Description</TableHead>
                        <TableHead className="text-right">Amount</TableHead>
                      </TableRow>
                    </TableHeader>
                    <TableBody>
                      {report.expenses.personal.map((e: any, idx: number) => (
                        <TableRow key={idx}>
                          <TableCell className="text-xs">{e.date?.slice(0,10)}</TableCell>
                          <TableCell>{e.description}</TableCell>
                          <TableCell className="text-right font-mono text-red-600">{fmt(e.amount)}</TableCell>
                        </TableRow>
                      ))}
                    </TableBody>
                  </Table>
                </div>
              </div>
            </CardContent>
          </Card>
        </TabsContent>
      </Tabs>
    </div>
  );
}
