import { useState } from "react";
import { useQuery } from "@tanstack/react-query";
import { supabase } from "@/integrations/supabase/client";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Button } from "@/components/ui/button";
import { Printer } from "lucide-react";

const MONTHS = ["", "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];

function fmt(v: number) {
  return new Intl.NumberFormat("en-US", { minimumFractionDigits: 2 }).format(v);
}

export default function Reports() {
  const [month, setMonth] = useState(String(new Date().getMonth() + 1));
  const [year, setYear] = useState(String(new Date().getFullYear()));
  const m = parseInt(month);
  const y = parseInt(year);

  const { data: income } = useQuery({
    queryKey: ["rpt-income", m, y],
    queryFn: async () => {
      const { data } = await supabase.from("income_transactions").select("*, properties(name)").eq("month", m).eq("year", y).order("date");
      return data ?? [];
    },
  });

  const { data: expenses } = useQuery({
    queryKey: ["rpt-expenses", m, y],
    queryFn: async () => {
      const { data } = await supabase.from("expense_transactions").select("*, properties(name), expense_categories(name)").eq("month", m).eq("year", y).order("date");
      return data ?? [];
    },
  });

  const { data: salaryRuns } = useQuery({
    queryKey: ["rpt-salary", m, y],
    queryFn: async () => {
      const { data } = await supabase.from("salary_runs").select("*").eq("month", m).eq("year", y);
      return data ?? [];
    },
  });

  const { data: salaryLines } = useQuery({
    queryKey: ["rpt-salary-lines", m, y],
    queryFn: async () => {
      const { data } = await supabase.from("salary_lines").select("*, employees(name, house_assignment)").order("created_at");
      return data ?? [];
    },
  });

  const { data: properties } = useQuery({
    queryKey: ["rpt-props"],
    queryFn: async () => {
      const { data } = await supabase.from("properties").select("*");
      return data ?? [];
    },
  });

  const { data: shareholders } = useQuery({
    queryKey: ["rpt-shareholders"],
    queryFn: async () => {
      const { data } = await supabase.from("shareholders").select("*");
      return data ?? [];
    },
  });

  const { data: balances } = useQuery({
    queryKey: ["rpt-balances", m, y],
    queryFn: async () => {
      const { data } = await supabase.from("shareholder_balances").select("*, shareholders(name), properties(name)").eq("month", m).eq("year", y);
      return data ?? [];
    },
  });

  const totalIncome = income?.reduce((s, t) => s + Number(t.accommodation_amount_mzn), 0) ?? 0;
  const totalExpenses = expenses?.reduce((s, t) => s + Number(t.amount_mzn), 0) ?? 0;

  const filteredLines = salaryLines?.filter((l: any) =>
    salaryRuns?.some((r) => r.id === l.salary_run_id)
  ) ?? [];

  const handlePrint = () => window.print();

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between print:hidden">
        <h1 className="text-3xl font-bold">Reports</h1>
        <Button variant="outline" size="sm" onClick={handlePrint}>
          <Printer className="mr-2 h-4 w-4" /> Print
        </Button>
      </div>

      <div className="flex gap-3 print:hidden">
        <Select value={month} onValueChange={setMonth}>
          <SelectTrigger className="w-40"><SelectValue /></SelectTrigger>
          <SelectContent>
            {MONTHS.slice(1).map((mn, i) => (
              <SelectItem key={i + 1} value={String(i + 1)}>{mn}</SelectItem>
            ))}
          </SelectContent>
        </Select>
        <Select value={year} onValueChange={setYear}>
          <SelectTrigger className="w-28"><SelectValue /></SelectTrigger>
          <SelectContent>
            {[2024, 2025, 2026, 2027].map((yr) => (
              <SelectItem key={yr} value={String(yr)}>{yr}</SelectItem>
            ))}
          </SelectContent>
        </Select>
      </div>

      <Tabs defaultValue="ledger">
        <TabsList className="print:hidden">
          <TabsTrigger value="ledger">Monthly Ledger</TabsTrigger>
          <TabsTrigger value="shareholder">Shareholder Statement</TabsTrigger>
          <TabsTrigger value="payroll">Payroll Report</TabsTrigger>
          <TabsTrigger value="property-pl">P&L per Property</TabsTrigger>
        </TabsList>

        {/* Monthly Ledger */}
        <TabsContent value="ledger">
          <Card>
            <CardHeader>
              <CardTitle>Monthly Ledger — {MONTHS[m]} {y}</CardTitle>
            </CardHeader>
            <CardContent className="space-y-6">
              <div>
                <h3 className="font-semibold mb-2">Income ({income?.length ?? 0} transactions)</h3>
                <Table>
                  <TableHeader>
                    <TableRow>
                      <TableHead>Date</TableHead>
                      <TableHead>Property</TableHead>
                      <TableHead>Guest</TableHead>
                      <TableHead className="text-right">Amount MZN</TableHead>
                    </TableRow>
                  </TableHeader>
                  <TableBody>
                    {income?.map((t: any) => (
                      <TableRow key={t.id}>
                        <TableCell>{t.date}</TableCell>
                        <TableCell>{t.properties?.name ?? "—"}</TableCell>
                        <TableCell>{t.guest_name ?? t.description ?? "—"}</TableCell>
                        <TableCell className="text-right">{fmt(t.accommodation_amount_mzn)}</TableCell>
                      </TableRow>
                    ))}
                    <TableRow className="font-bold border-t-2">
                      <TableCell colSpan={3}>Total Income</TableCell>
                      <TableCell className="text-right">MZN {fmt(totalIncome)}</TableCell>
                    </TableRow>
                  </TableBody>
                </Table>
              </div>

              <div>
                <h3 className="font-semibold mb-2">Expenses ({expenses?.length ?? 0} transactions)</h3>
                <Table>
                  <TableHeader>
                    <TableRow>
                      <TableHead>Date</TableHead>
                      <TableHead>Category</TableHead>
                      <TableHead>Description</TableHead>
                      <TableHead>Type</TableHead>
                      <TableHead className="text-right">Amount MZN</TableHead>
                    </TableRow>
                  </TableHeader>
                  <TableBody>
                    {expenses?.map((t: any) => (
                      <TableRow key={t.id}>
                        <TableCell>{t.date ?? "—"}</TableCell>
                        <TableCell>{t.expense_categories?.name ?? "—"}</TableCell>
                        <TableCell>{t.description}</TableCell>
                        <TableCell>{t.is_shared ? "Shared" : "Personal"}</TableCell>
                        <TableCell className="text-right">{fmt(t.amount_mzn)}</TableCell>
                      </TableRow>
                    ))}
                    <TableRow className="font-bold border-t-2">
                      <TableCell colSpan={4}>Total Expenses</TableCell>
                      <TableCell className="text-right">MZN {fmt(totalExpenses)}</TableCell>
                    </TableRow>
                  </TableBody>
                </Table>
              </div>

              <Card className="bg-muted/50">
                <CardContent className="py-4 flex justify-between items-center">
                  <span className="font-bold text-lg">Net Profit/Loss</span>
                  <span className={`font-bold text-lg ${totalIncome - totalExpenses >= 0 ? "text-green-600" : "text-red-600"}`}>
                    MZN {fmt(totalIncome - totalExpenses)}
                  </span>
                </CardContent>
              </Card>
            </CardContent>
          </Card>
        </TabsContent>

        {/* Shareholder Statement */}
        <TabsContent value="shareholder">
          <Card>
            <CardHeader>
              <CardTitle>Shareholder Statements — {MONTHS[m]} {y}</CardTitle>
            </CardHeader>
            <CardContent>
              {balances && balances.length > 0 ? (
                <Table>
                  <TableHeader>
                    <TableRow>
                      <TableHead>Shareholder</TableHead>
                      <TableHead>Property</TableHead>
                      <TableHead className="text-right">Opening</TableHead>
                      <TableHead className="text-right">Income</TableHead>
                      <TableHead className="text-right">Expenses</TableHead>
                      <TableHead className="text-right">Closing</TableHead>
                    </TableRow>
                  </TableHeader>
                  <TableBody>
                    {balances.map((b: any) => (
                      <TableRow key={b.id}>
                        <TableCell className="font-medium">{b.shareholders?.name}</TableCell>
                        <TableCell>{b.properties?.name}</TableCell>
                        <TableCell className="text-right">{fmt(b.opening_balance)}</TableCell>
                        <TableCell className="text-right">{fmt(b.income)}</TableCell>
                        <TableCell className="text-right">{fmt(b.expenses)}</TableCell>
                        <TableCell className="text-right font-bold">{fmt(b.closing_balance)}</TableCell>
                      </TableRow>
                    ))}
                  </TableBody>
                </Table>
              ) : (
                <p className="text-muted-foreground text-center py-8">No shareholder balance data for {MONTHS[m]} {y}.</p>
              )}
            </CardContent>
          </Card>
        </TabsContent>

        {/* Payroll Report */}
        <TabsContent value="payroll">
          <Card>
            <CardHeader>
              <CardTitle>Payroll Report — {MONTHS[m]} {y}</CardTitle>
              {salaryRuns && salaryRuns.length > 0 && (
                <div className="flex gap-4 text-sm text-muted-foreground">
                  <span>Gross: MZN {fmt(salaryRuns[0].total_gross ?? 0)}</span>
                  <span>Net: MZN {fmt(salaryRuns[0].total_net ?? 0)}</span>
                  <span>INSS (Emp): MZN {fmt(salaryRuns[0].total_inss_employee ?? 0)}</span>
                  <span>IRPS: MZN {fmt(salaryRuns[0].total_irps ?? 0)}</span>
                </div>
              )}
            </CardHeader>
            <CardContent>
              {filteredLines.length > 0 ? (
                <div className="overflow-x-auto">
                  <Table>
                    <TableHeader>
                      <TableRow>
                        <TableHead>#</TableHead>
                        <TableHead>House</TableHead>
                        <TableHead>Employee</TableHead>
                        <TableHead className="text-right">Base</TableHead>
                        <TableHead className="text-right">Food</TableHead>
                        <TableHead className="text-right">Gross</TableHead>
                        <TableHead className="text-right">IRPS</TableHead>
                        <TableHead className="text-right">INSS</TableHead>
                        <TableHead className="text-right">Advance</TableHead>
                        <TableHead className="text-right">Total Ded.</TableHead>
                        <TableHead className="text-right">Net</TableHead>
                      </TableRow>
                    </TableHeader>
                    <TableBody>
                      {filteredLines.map((l: any, i: number) => (
                        <TableRow key={l.id}>
                          <TableCell>{i + 1}</TableCell>
                          <TableCell>{l.employees?.house_assignment ?? "—"}</TableCell>
                          <TableCell className="font-medium">{l.employees?.name}</TableCell>
                          <TableCell className="text-right">{fmt(l.base_salary ?? 0)}</TableCell>
                          <TableCell className="text-right">{fmt(l.food_allowance ?? 0)}</TableCell>
                          <TableCell className="text-right">{fmt(l.gross_total ?? 0)}</TableCell>
                          <TableCell className="text-right">{fmt(l.irps ?? 0)}</TableCell>
                          <TableCell className="text-right">{fmt(l.inss_employee ?? 0)}</TableCell>
                          <TableCell className="text-right">{fmt(l.advance ?? 0)}</TableCell>
                          <TableCell className="text-right">{fmt(l.total_deductions ?? 0)}</TableCell>
                          <TableCell className="text-right font-bold">{fmt(l.net_salary ?? 0)}</TableCell>
                        </TableRow>
                      ))}
                    </TableBody>
                  </Table>
                </div>
              ) : (
                <p className="text-muted-foreground text-center py-8">No payroll data for {MONTHS[m]} {y}.</p>
              )}
            </CardContent>
          </Card>
        </TabsContent>

        {/* P&L per Property */}
        <TabsContent value="property-pl">
          <Card>
            <CardHeader>
              <CardTitle>P&L per Property — {y}</CardTitle>
            </CardHeader>
            <CardContent>
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead>Property</TableHead>
                    <TableHead className="text-right">Total Income</TableHead>
                    <TableHead className="text-right">Total Expenses</TableHead>
                    <TableHead className="text-right">Net P&L</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {properties?.map((p) => {
                    const propIncome = income?.filter((t: any) => t.property_id === p.id).reduce((s, t) => s + Number(t.accommodation_amount_mzn), 0) ?? 0;
                    const propExpenses = expenses?.filter((t: any) => t.property_id === p.id).reduce((s, t) => s + Number(t.amount_mzn), 0) ?? 0;
                    const net = propIncome - propExpenses;
                    return (
                      <TableRow key={p.id}>
                        <TableCell className="font-medium">{p.name} ({p.code})</TableCell>
                        <TableCell className="text-right">{fmt(propIncome)}</TableCell>
                        <TableCell className="text-right">{fmt(propExpenses)}</TableCell>
                        <TableCell className={`text-right font-bold ${net >= 0 ? "text-green-600" : "text-red-600"}`}>{fmt(net)}</TableCell>
                      </TableRow>
                    );
                  })}
                  <TableRow className="font-bold border-t-2">
                    <TableCell>TOTAL</TableCell>
                    <TableCell className="text-right">MZN {fmt(totalIncome)}</TableCell>
                    <TableCell className="text-right">MZN {fmt(totalExpenses)}</TableCell>
                    <TableCell className={`text-right ${totalIncome - totalExpenses >= 0 ? "text-green-600" : "text-red-600"}`}>
                      MZN {fmt(totalIncome - totalExpenses)}
                    </TableCell>
                  </TableRow>
                </TableBody>
              </Table>
            </CardContent>
          </Card>
        </TabsContent>
      </Tabs>
    </div>
  );
}
