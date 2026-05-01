import { useState } from "react";
import { useQuery } from "@tanstack/react-query";
import { api } from "@/lib/api";
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Badge } from "@/components/ui/badge";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { Home, TrendingUp, TrendingDown, Users, Wallet, FileDown, FileSpreadsheet } from "lucide-react";
import { Button } from "@/components/ui/button";
import * as XLSX from "xlsx";
import jsPDF from "jspdf";
import autoTable from "jspdf-autotable";

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

function StatCard({ label, value, icon: Icon, color }: { label: string; value: number; icon: any; color: string }) {
  return (
    <Card className={`border-l-4 ${color}`}>
      <CardContent className="pt-5 pb-4">
        <div className="flex justify-between items-start">
          <div>
            <p className="text-xs text-muted-foreground uppercase tracking-wide">{label}</p>
            <p className="text-xl font-bold mt-1">{fmt(value)} <span className="text-xs font-normal text-muted-foreground">MZN</span></p>
          </div>
          <Icon size={20} className="text-muted-foreground mt-1" />
        </div>
      </CardContent>
    </Card>
  );
}

export default function ShareholderReports() {
  const [selectedHouse, setSelectedHouse] = useState("H1");
  const [selectedYear, setSelectedYear] = useState("2026");
  const [selectedMonth, setSelectedMonth] = useState<string>("all");

  const queryParams = new URLSearchParams({ year: selectedYear });
  if (selectedMonth && selectedMonth !== "all") queryParams.set("month", selectedMonth);

  const { data: stmt, isLoading, error } = useQuery({
    queryKey: ["shareholder-statement", selectedHouse, selectedYear, selectedMonth],
    queryFn: () => api(`/api/reports/shareholder/${selectedHouse}?${queryParams}`),
  });

  const periodLabel = selectedMonth && selectedMonth !== "all"
    ? `${MONTHS.find(m => m.value === selectedMonth)?.label} ${selectedYear}`
    : `Full Year ${selectedYear}`;

  const house = HOUSES.find(h => h.code === selectedHouse);

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col gap-4 md:flex-row md:items-end md:justify-between">
        <div>
          <h1 className="text-3xl font-bold flex items-center gap-2">
            <Home size={28} /> Shareholder Statements
          </h1>
          <p className="text-muted-foreground text-sm mt-1">
            Individual financial account per house. Communal (LC) costs are split 25% per shareholder.
          </p>
        </div>
        <div className="flex gap-3 flex-wrap">
          <Select value={selectedHouse} onValueChange={setSelectedHouse}>
            <SelectTrigger className="w-48" id="house-selector">
              <SelectValue placeholder="Select House" />
            </SelectTrigger>
            <SelectContent>
              {HOUSES.map(h => (
                <SelectItem key={h.code} value={h.code}>{h.name}</SelectItem>
              ))}
            </SelectContent>
          </Select>
          <Select value={selectedYear} onValueChange={setSelectedYear}>
            <SelectTrigger className="w-28" id="year-selector">
              <SelectValue />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="2026">2026</SelectItem>
              <SelectItem value="2025">2025</SelectItem>
            </SelectContent>
          </Select>
          <Select value={selectedMonth} onValueChange={setSelectedMonth}>
            <SelectTrigger className="w-36" id="month-selector">
              <SelectValue placeholder="All Months" />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="all">All Months</SelectItem>
              {MONTHS.map(m => (
                <SelectItem key={m.value} value={m.value}>{m.label}</SelectItem>
              ))}
            </SelectContent>
          </Select>
        </div>
      </div>

      {isLoading && <p className="text-muted-foreground">Loading statement…</p>}
      {error && <p className="text-red-500">Failed to load statement. {String(error)}</p>}

      {stmt && (
        <>
          {/* Summary Cards */}
          <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
            <StatCard label="Direct Income" value={stmt.total_direct_income} icon={TrendingUp} color="border-green-500" />
            <StatCard label="Direct Expenses" value={stmt.total_direct_expenses} icon={TrendingDown} color="border-orange-400" />
            <StatCard
              label="Total Salary Charge"
              value={stmt.direct_salary_total + stmt.shared_salary_total}
              icon={Users}
              color="border-purple-400"
            />
            <Card className={`border-l-4 ${stmt.net_position >= 0 ? "border-blue-500" : "border-red-500"}`}>
              <CardContent className="pt-5 pb-4">
                <div className="flex justify-between items-start">
                  <div>
                    <p className="text-xs text-muted-foreground uppercase tracking-wide">Net Position</p>
                    <p className={`text-xl font-bold mt-1 ${stmt.net_position >= 0 ? "text-blue-700" : "text-red-600"}`}>
                      {fmt(stmt.net_position)} <span className="text-xs font-normal text-muted-foreground">MZN</span>
                    </p>
                  </div>
                  <Wallet size={20} className="text-muted-foreground mt-1" />
                </div>
              </CardContent>
            </Card>
          </div>

          {/* Period + House badge */}
          <div className="flex gap-2 items-center">
            <Badge variant="outline" className="text-sm px-3 py-1">{house?.name}</Badge>
            <Badge variant="secondary" className="text-sm px-3 py-1">{periodLabel}</Badge>
          </div>

          {/* Detailed Tabs */}
          <Tabs defaultValue="income" className="w-full">
            <TabsList className="flex flex-wrap gap-1">
              <TabsTrigger value="income">Income ({stmt.direct_income?.length ?? 0})</TabsTrigger>
              <TabsTrigger value="expenses">Expenses ({stmt.direct_expenses?.length ?? 0})</TabsTrigger>
              <TabsTrigger value="salaries">Salaries</TabsTrigger>
              <TabsTrigger value="petty">Petty Cash Share</TabsTrigger>
              <TabsTrigger value="summary">Summary</TabsTrigger>
            </TabsList>

            {/* Income */}
            <TabsContent value="income" className="mt-4">
              <Card>
                <CardHeader><CardTitle>Direct Income — {house?.name}</CardTitle></CardHeader>
                <CardContent>
                  <Table>
                    <TableHeader><TableRow>
                      <TableHead>Date</TableHead>
                      <TableHead>Guest</TableHead>
                      <TableHead>Description</TableHead>
                      <TableHead className="text-right">Amount MZN</TableHead>
                    </TableRow></TableHeader>
                    <TableBody>
                      {stmt.direct_income?.map((r: any, i: number) => (
                        <TableRow key={i}>
                          <TableCell className="text-xs">{r.date?.slice(0, 10)}</TableCell>
                          <TableCell>{r.guest_name || "—"}</TableCell>
                          <TableCell className="text-xs text-muted-foreground">{r.description || "—"}</TableCell>
                          <TableCell className="text-right font-mono">{fmt(r.amount)}</TableCell>
                        </TableRow>
                      ))}
                      {!stmt.direct_income?.length && (
                        <TableRow><TableCell colSpan={4} className="text-center text-muted-foreground py-6">No income for this period.</TableCell></TableRow>
                      )}
                    </TableBody>
                  </Table>
                  <div className="mt-3 text-right font-bold text-green-700 pr-2">
                    Total: {fmt(stmt.total_direct_income)} MZN
                  </div>
                </CardContent>
              </Card>
            </TabsContent>

            {/* Expenses */}
            <TabsContent value="expenses" className="mt-4">
              <Card>
                <CardHeader><CardTitle>Direct Expenses — {house?.name}</CardTitle></CardHeader>
                <CardContent>
                  <Table>
                    <TableHeader><TableRow>
                      <TableHead>Date</TableHead>
                      <TableHead>Category</TableHead>
                      <TableHead>Description</TableHead>
                      <TableHead className="text-right">Amount MZN</TableHead>
                    </TableRow></TableHeader>
                    <TableBody>
                      {stmt.direct_expenses?.map((r: any, i: number) => (
                        <TableRow key={i}>
                          <TableCell className="text-xs">{r.date?.slice(0, 10)}</TableCell>
                          <TableCell><Badge variant="outline" className="text-xs">{r.category || "—"}</Badge></TableCell>
                          <TableCell className="text-xs">{r.description}</TableCell>
                          <TableCell className="text-right font-mono text-red-600">({fmt(r.amount)})</TableCell>
                        </TableRow>
                      ))}
                      {!stmt.direct_expenses?.length && (
                        <TableRow><TableCell colSpan={4} className="text-center text-muted-foreground py-6">No direct expenses for this period.</TableCell></TableRow>
                      )}
                    </TableBody>
                  </Table>
                </CardContent>
              </Card>
            </TabsContent>

            {/* Salaries */}
            <TabsContent value="salaries" className="mt-4 space-y-4">
              {stmt.direct_salary_lines?.length > 0 && (
                <Card>
                  <CardHeader><CardTitle>House Staff — {house?.name} (100%)</CardTitle></CardHeader>
                  <CardContent>
                    <Table>
                      <TableHeader><TableRow>
                        <TableHead>Employee</TableHead>
                        <TableHead>Month</TableHead>
                        <TableHead className="text-right">Gross</TableHead>
                        <TableHead className="text-right">INSS Employer</TableHead>
                        <TableHead className="text-right">Total Cost</TableHead>
                      </TableRow></TableHeader>
                      <TableBody>
                        {stmt.direct_salary_lines.map((r: any, i: number) => (
                        <TableRow key={i}>
                          <TableCell>{r.employee_name}</TableCell>
                          <TableCell>{r.month}/{r.year}</TableCell>
                          <TableCell className="text-right">{fmt(r.gross_total)}</TableCell>
                          <TableCell className="text-right">{fmt(r.inss_employer)}</TableCell>
                          <TableCell className="text-right font-mono">{fmt(Number(r.gross_total) + Number(r.inss_employer))}</TableCell>
                        </TableRow>
                      ))}
                      </TableBody>
                    </Table>
                    <div className="text-right font-bold mt-2 pr-2">Total: {fmt(stmt.direct_salary_total)} MZN</div>
                  </CardContent>
                </Card>
              )}
                <Card>
                  <CardHeader>
                    <CardTitle>Communal Staff (AM) — Your {(100/4).toFixed(0)}% Share</CardTitle>
                    <CardDescription>Administration/Management staff serve the whole lodge. Each shareholder contributes equally.</CardDescription>
                  </CardHeader>
                  <CardContent>
                    <Table>
                      <TableHeader><TableRow>
                        <TableHead>Employee</TableHead>
                        <TableHead>House</TableHead>
                        <TableHead>Month</TableHead>
                        <TableHead className="text-right">Full Cost</TableHead>
                        <TableHead className="text-right">Your Share</TableHead>
                      </TableRow></TableHeader>
                      <TableBody>
                        {stmt.shared_salary_lines?.map((r: any, i: number) => {
                          const full = Number(r.gross_total) + Number(r.inss_employer);
                        return (
                            <TableRow key={i}>
                              <TableCell>{r.employee_name}</TableCell>
                              <TableCell><span className="text-xs font-mono bg-muted px-1 rounded">{r.house_assignment}</span></TableCell>
                              <TableCell>{r.month}/{r.year}</TableCell>
                              <TableCell className="text-right">{fmt(full)}</TableCell>
                              <TableCell className="text-right font-mono text-purple-700">{fmt(r.owed)}</TableCell>
                            </TableRow>
                          );
                        })}
                        {!stmt.shared_salary_lines?.length && (
                          <TableRow><TableCell colSpan={5} className="text-center text-muted-foreground py-4">No shared salary data.</TableCell></TableRow>
                        )}
                      </TableBody>
                    </Table>
                    <div className="text-right font-bold mt-2 text-purple-700 pr-2">
                      Your Share: {fmt(stmt.shared_salary_total)} MZN
                    </div>
                </CardContent>
              </Card>
            </TabsContent>

            {/* Petty Cash */}
            <TabsContent value="petty" className="mt-4">
              <Card>
                <CardHeader>
                  <CardTitle>Petty Cash — 25% Communal Share</CardTitle>
                  <CardDescription>All lodge petty cash is treated as communal. Your share is 25%.</CardDescription>
                </CardHeader>
                <CardContent>
                  <Table>
                    <TableHeader><TableRow>
                      <TableHead>Date</TableHead>
                      <TableHead>Supplier / Description</TableHead>
                      <TableHead>Allocation</TableHead>
                      <TableHead className="text-right">Full Amount</TableHead>
                      <TableHead className="text-right">Your Share (25%)</TableHead>
                    </TableRow></TableHeader>
                    <TableBody>
                      {stmt.petty_cash_lines?.map((r: any, i: number) => (
                        <TableRow key={i}>
                          <TableCell className="text-xs">{r.date?.slice(0, 10)}</TableCell>
                          <TableCell className="text-xs">{r.supplier || r.description}</TableCell>
                          <TableCell className="text-xs uppercase text-muted-foreground">{r.allocation || "—"}</TableCell>
                          <TableCell className="text-right">{fmt(r.amount)}</TableCell>
                          <TableCell className="text-right font-mono text-orange-600">{fmt(Number(r.amount) / 4)}</TableCell>
                        </TableRow>
                      ))}
                      {!stmt.petty_cash_lines?.length && (
                        <TableRow><TableCell colSpan={5} className="text-center text-muted-foreground py-4">No petty cash data.</TableCell></TableRow>
                      )}
                    </TableBody>
                  </Table>
                  <div className="text-right font-bold mt-2 text-orange-600 pr-2">
                    Your 25% Share: {fmt(stmt.petty_cash_share)} MZN
                  </div>
                </CardContent>
              </Card>
            </TabsContent>

            {/* Summary */}
            <TabsContent value="summary" className="mt-4">
              <Card>
                <CardHeader>
                  <CardTitle>Account Summary — {house?.name} ({periodLabel})</CardTitle>
                  <CardDescription>Final statement of account for this shareholder.</CardDescription>
                </CardHeader>
                <CardContent>
                  <Table>
                    <TableBody>
                      <TableRow className="bg-green-50">
                        <TableCell className="font-semibold">Direct Income (100%)</TableCell>
                        <TableCell className="text-right font-mono text-green-700">{fmt(stmt.total_direct_income)}</TableCell>
                      </TableRow>
                      <TableRow>
                        <TableCell className="font-semibold text-red-600">Direct Expenses (100%)</TableCell>
                        <TableCell className="text-right font-mono text-red-600">({fmt(stmt.total_direct_expenses)})</TableCell>
                      </TableRow>
                      <TableRow>
                        <TableCell className="font-semibold text-purple-700">House Staff — Salary Cost (100%)</TableCell>
                        <TableCell className="text-right font-mono text-purple-700">({fmt(stmt.direct_salary_total)})</TableCell>
                      </TableRow>
                      <TableRow>
                        <TableCell className="font-semibold text-purple-500">Communal Staff (AM) — Your Share</TableCell>
                        <TableCell className="text-right font-mono text-purple-500">({fmt(stmt.shared_salary_total)})</TableCell>
                      </TableRow>
                      <TableRow>
                        <TableCell className="font-semibold text-orange-600">Petty Cash — 25% Communal Share</TableCell>
                        <TableCell className="text-right font-mono text-orange-600">({fmt(stmt.petty_cash_share)})</TableCell>
                      </TableRow>
                      <TableRow className={`font-bold text-lg border-t-2 ${stmt.net_position >= 0 ? "bg-blue-50" : "bg-red-50"}`}>
                        <TableCell>NET POSITION</TableCell>
                        <TableCell className={`text-right font-mono text-xl ${stmt.net_position >= 0 ? "text-blue-700" : "text-red-700"}`}>
                          {stmt.net_position >= 0 ? "" : "("}
                          {fmt(Math.abs(stmt.net_position))}
                          {stmt.net_position >= 0 ? "" : ")"}
                        </TableCell>
                      </TableRow>
                    </TableBody>
                  </Table>
                </CardContent>
              </Card>
            </TabsContent>
          </Tabs>
        </>
      )}
    </div>
  );
}
