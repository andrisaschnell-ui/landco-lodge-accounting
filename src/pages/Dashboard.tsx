import { useQuery } from "@tanstack/react-query";
import { db } from "@/lib/db";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { DollarSign, TrendingUp, TrendingDown, RefreshCw } from "lucide-react";
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, PieChart, Pie, Cell } from "recharts";

const COLORS = ["hsl(var(--primary))", "hsl(var(--destructive))", "hsl(var(--accent))", "hsl(210,60%,50%)", "hsl(150,60%,40%)"];

function formatMZN(value: number) {
  return new Intl.NumberFormat("en-US", { style: "decimal", minimumFractionDigits: 2 }).format(value);
}

export default function Dashboard() {
  const { data: income } = useQuery({
    queryKey: ["income-total"],
    queryFn: async () => {
      const { data } = await db.from("income_transactions").select("accommodation_amount_mzn, property_id, month");
      return Array.isArray(data) ? data : [];
    },
  });

  const { data: expenses } = useQuery({
    queryKey: ["expense-total"],
    queryFn: async () => {
      const { data } = await db.from("expense_transactions").select("amount_mzn, is_shared, month");
      return Array.isArray(data) ? data : [];
    },
  });

  const { data: exchangeRate } = useQuery({
    queryKey: ["exchange-rate"],
    queryFn: async () => {
      const { data } = await db.from("exchange_rates").select("*").order("year", { ascending: false }).order("month", { ascending: false }).limit(1);
      return Array.isArray(data) ? data[0] : null;
    },
  });

  const { data: properties } = useQuery({
    queryKey: ["properties"],
    queryFn: async () => {
      const { data } = await db.from("properties").select("*");
      return Array.isArray(data) ? data : [];
    },
  });

  const { data: shareholders } = useQuery({
    queryKey: ["shareholders-balances"],
    queryFn: async () => {
      const { data } = await db.from("shareholder_balances").select("*, shareholders(name), properties(name)");
      return Array.isArray(data) ? data : [];
    },
  });

  const { data: recentImports } = useQuery({
    queryKey: ["recent-imports"],
    queryFn: async () => {
      const { data } = await db.from("import_log").select("*").order("created_at", { ascending: false }).limit(5);
      return Array.isArray(data) ? data : [];
    },
  });

  const totalIncome = income?.reduce((sum, t) => sum + Number(t.accommodation_amount_mzn), 0) ?? 0;
  const totalExpenses = expenses?.reduce((sum, t) => sum + Number(t.amount_mzn), 0) ?? 0;
  const netProfit = totalIncome - totalExpenses;

  // Income by property for pie chart
  const incomeByProperty = (properties || []).map((p) => ({
    name: p.name,
    value: (income || []).filter((t) => t.property_id === p.id).reduce((sum, t) => sum + Number(t.accommodation_amount_mzn), 0),
  })).filter((d) => d.value > 0);

  // Monthly data for bar chart
  const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
  const monthlyData = months.map((name, i) => ({
    name,
    income: (income || []).filter((t) => t.month === i + 1).reduce((sum, t) => sum + Number(t.accommodation_amount_mzn), 0),
    expenses: (expenses || []).filter((t) => t.month === i + 1).reduce((sum, t) => sum + Number(t.amount_mzn), 0),
  }));

  return (
    <div className="space-y-6">
      <h1 className="text-3xl font-bold">Dashboard</h1>

      {/* KPI Cards */}
      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Total Income</CardTitle>
            <TrendingUp className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">MZN {formatMZN(totalIncome)}</div>
          </CardContent>
        </Card>
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Total Expenses</CardTitle>
            <TrendingDown className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">MZN {formatMZN(totalExpenses)}</div>
          </CardContent>
        </Card>
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Net Profit</CardTitle>
            <DollarSign className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className={`text-2xl font-bold ${netProfit >= 0 ? "text-green-600" : "text-red-600"}`}>
              MZN {formatMZN(netProfit)}
            </div>
          </CardContent>
        </Card>
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Exchange Rate</CardTitle>
            <RefreshCw className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{exchangeRate?.mzn_per_usd ?? "—"}</div>
            <p className="text-xs text-muted-foreground">MZN / USD</p>
          </CardContent>
        </Card>
      </div>

      {/* Charts */}
      <div className="grid gap-6 lg:grid-cols-2">
        <Card>
          <CardHeader>
            <CardTitle>Income vs Expenses by Month</CardTitle>
          </CardHeader>
          <CardContent>
            <ResponsiveContainer width="100%" height={300}>
              <BarChart data={monthlyData}>
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis dataKey="name" />
                <YAxis />
                <Tooltip formatter={(v: number) => `MZN ${formatMZN(v)}`} />
                <Bar dataKey="income" fill="hsl(150,60%,40%)" name="Income" />
                <Bar dataKey="expenses" fill="hsl(0,70%,55%)" name="Expenses" />
              </BarChart>
            </ResponsiveContainer>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>Income by Property</CardTitle>
          </CardHeader>
          <CardContent>
            {incomeByProperty.length > 0 ? (
              <ResponsiveContainer width="100%" height={300}>
                <PieChart>
                  <Pie data={incomeByProperty} dataKey="value" nameKey="name" cx="50%" cy="50%" outerRadius={100} label={({ name, percent }) => `${name} ${(percent * 100).toFixed(0)}%`}>
                    {incomeByProperty.map((_, i) => (
                      <Cell key={i} fill={COLORS[i % COLORS.length]} />
                    ))}
                  </Pie>
                  <Tooltip formatter={(v: number) => `MZN ${formatMZN(v)}`} />
                </PieChart>
              </ResponsiveContainer>
            ) : (
              <p className="text-muted-foreground text-center py-12">No income data yet. Upload data to see charts.</p>
            )}
          </CardContent>
        </Card>
      </div>

      {/* Shareholder Balances */}
      <Card>
        <CardHeader>
          <CardTitle>Shareholder Balances</CardTitle>
        </CardHeader>
        <CardContent>
          {shareholders && shareholders.length > 0 ? (
            <div className="overflow-x-auto">
              <table className="w-full text-sm">
                <thead>
                  <tr className="border-b">
                    <th className="text-left p-2">Shareholder</th>
                    <th className="text-left p-2">Property</th>
                    <th className="text-right p-2">Opening</th>
                    <th className="text-right p-2">Income</th>
                    <th className="text-right p-2">Expenses</th>
                    <th className="text-right p-2">Closing</th>
                  </tr>
                </thead>
                <tbody>
                  {shareholders.map((b: any) => (
                    <tr key={b.id} className="border-b">
                      <td className="p-2">{b.shareholders?.name}</td>
                      <td className="p-2">{b.properties?.name}</td>
                      <td className="p-2 text-right">{formatMZN(b.opening_balance)}</td>
                      <td className="p-2 text-right">{formatMZN(b.income)}</td>
                      <td className="p-2 text-right">{formatMZN(b.expenses)}</td>
                      <td className="p-2 text-right font-medium">{formatMZN(b.closing_balance)}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          ) : (
            <p className="text-muted-foreground">No balance data yet.</p>
          )}
        </CardContent>
      </Card>

      {/* Recent Imports */}
      <Card>
        <CardHeader>
          <CardTitle>Recent Imports</CardTitle>
        </CardHeader>
        <CardContent>
          {recentImports && recentImports.length > 0 ? (
            <div className="space-y-2">
              {recentImports.map((log) => (
                <div key={log.id} className="flex items-center justify-between border-b py-2">
                  <div>
                    <p className="font-medium text-sm">{log.filename}</p>
                    <p className="text-xs text-muted-foreground">{log.file_type} • {log.records_imported} records</p>
                  </div>
                  <span className={`text-xs px-2 py-1 rounded ${log.status === "success" ? "bg-green-100 text-green-700" : "bg-yellow-100 text-yellow-700"}`}>
                    {log.status}
                  </span>
                </div>
              ))}
            </div>
          ) : (
            <p className="text-muted-foreground">No imports yet. Go to Upload to import your Excel files.</p>
          )}
        </CardContent>
      </Card>
    </div>
  );
}
