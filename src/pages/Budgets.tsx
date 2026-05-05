import { useEffect, useMemo, useState } from "react";
import { supabase as supabaseTyped } from "@/integrations/supabase/client";
const supabase: any = supabaseTyped;
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Loader2, Save, FileDown, FileSpreadsheet } from "lucide-react";
import { toast } from "sonner";
import { loadAccounts, loadAggregates, balanceFor, AccountRow, fmtMoney, firstDay, lastDay } from "@/lib/statements";
import { exportToPdf, exportToExcel, Column } from "@/lib/exportUtils";

const months = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"];

export default function Budgets() {
  return (
    <div className="container mx-auto py-6 space-y-6">
      <h1 className="text-3xl font-bold tracking-tight">Budgets</h1>
      <Tabs defaultValue="entry">
        <TabsList>
          <TabsTrigger value="entry">Budget Entry</TabsTrigger>
          <TabsTrigger value="vs-actual">Budget vs Actual</TabsTrigger>
        </TabsList>
        <TabsContent value="entry" className="mt-4"><BudgetEntry /></TabsContent>
        <TabsContent value="vs-actual" className="mt-4"><BudgetVsActual /></TabsContent>
      </Tabs>
    </div>
  );
}

function BudgetEntry() {
  const [year, setYear] = useState<number>(new Date().getFullYear());
  const [accounts, setAccounts] = useState<AccountRow[]>([]);
  const [budgets, setBudgets] = useState<Record<string, number>>({}); // key: accountId-month
  const [dirty, setDirty] = useState<Set<string>>(new Set());
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);

  useEffect(() => {
    setLoading(true);
    (async () => {
      const accts = await loadAccounts();
      const filtered = accts.filter(a => a.account_type === "revenue" || a.account_type === "expense");
      setAccounts(filtered);

      const { data } = await db.from("budgets").select("account_id, month, amount").eq("year", year).is("property_id", null);
      const map: Record<string, number> = {};
      (data || []).forEach((b: any) => { map[`${b.account_id}-${b.month}`] = Number(b.amount); });
      setBudgets(map);
      setDirty(new Set());
      setLoading(false);
    })();
  }, [year]);

  const update = (acctId: string, month: number, val: string) => {
    const key = `${acctId}-${month}`;
    const num = Number(val) || 0;
    setBudgets(prev => ({ ...prev, [key]: num }));
    setDirty(prev => new Set(prev).add(key));
  };

  const save = async () => {
    setSaving(true);
    const rows = Array.from(dirty).map(k => {
      const [account_id, m] = k.split("-");
      return { account_id, month: Number(m), year, amount: budgets[k] || 0 };
    });
    const { error } = await db.from("budgets").upsert(rows, { onConflict: "account_id,year,month,property_id" });
    if (error) { toast.error(error.message); }
    else { toast.success(`Saved ${rows.length} budget cells.`); setDirty(new Set()); }
    setSaving(false);
  };

  return (
    <Card>
      <CardHeader className="flex flex-row items-center justify-between">
        <CardTitle>Annual Budget — {year}</CardTitle>
        <div className="flex gap-2">
          <Select value={String(year)} onValueChange={(v) => setYear(Number(v))}>
            <SelectTrigger className="w-[110px]"><SelectValue /></SelectTrigger>
            <SelectContent>
              {[2024,2025,2026,2027].map(y => <SelectItem key={y} value={String(y)}>{y}</SelectItem>)}
            </SelectContent>
          </Select>
          <Button onClick={save} disabled={!dirty.size || saving}>
            <Save className="mr-1 h-4 w-4" /> Save {dirty.size > 0 && `(${dirty.size})`}
          </Button>
        </div>
      </CardHeader>
      <CardContent className="overflow-auto">
        {loading ? (
          <div className="flex items-center justify-center py-10 text-muted-foreground">
            <Loader2 className="mr-2 h-4 w-4 animate-spin" /> Loading…
          </div>
        ) : (
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead className="w-20">Code</TableHead>
                <TableHead className="min-w-[200px]">Account</TableHead>
                {months.map(m => <TableHead key={m} className="text-right">{m}</TableHead>)}
                <TableHead className="text-right">Total</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {accounts.map(a => {
                const total = months.reduce((s, _, i) => s + (budgets[`${a.id}-${i+1}`] || 0), 0);
                return (
                  <TableRow key={a.id}>
                    <TableCell className="font-mono text-xs">{a.code}</TableCell>
                    <TableCell className="text-sm">{a.name}</TableCell>
                    {months.map((_, i) => (
                      <TableCell key={i} className="p-1">
                        <Input
                          type="number"
                          className="h-8 w-24 text-right font-mono text-xs"
                          value={budgets[`${a.id}-${i+1}`] ?? ""}
                          onChange={e => update(a.id, i+1, e.target.value)}
                        />
                      </TableCell>
                    ))}
                    <TableCell className="text-right font-mono font-semibold">{fmtMoney(total)}</TableCell>
                  </TableRow>
                );
              })}
            </TableBody>
          </Table>
        )}
      </CardContent>
    </Card>
  );
}

function BudgetVsActual() {
  const today = new Date();
  const [year, setYear] = useState<number>(today.getFullYear());
  const [month, setMonth] = useState<number>(today.getMonth() + 1);
  const [scope, setScope] = useState<"month" | "ytd">("ytd");
  const [accounts, setAccounts] = useState<AccountRow[]>([]);
  const [budgets, setBudgets] = useState<Record<string, number>>({}); // accountId -> sum
  const [actuals, setActuals] = useState<Record<string, number>>({});
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    setLoading(true);
    (async () => {
      const accts = await loadAccounts();
      const incomeExp = accts.filter(a => a.account_type === "revenue" || a.account_type === "expense");
      setAccounts(incomeExp);

      const fromMonth = scope === "month" ? month : 1;
      const toMonth = month;
      const from = firstDay(year, fromMonth);
      const to = lastDay(year, toMonth);

      const [{ data: budRows }, agg] = await Promise.all([
        db.from("budgets").select("account_id, amount, month").eq("year", year).gte("month", fromMonth).lte("month", toMonth).is("property_id", null),
        loadAggregates({ from, to }),
      ]);

      const b: Record<string, number> = {};
      (budRows || []).forEach((r: any) => { b[r.account_id] = (b[r.account_id] || 0) + Number(r.amount); });
      setBudgets(b);

      const aMap = new Map(agg.map(x => [x.account_id, x]));
      const a: Record<string, number> = {};
      incomeExp.forEach(acc => { a[acc.id] = balanceFor(acc, aMap.get(acc.id)); });
      setActuals(a);
      setLoading(false);
    })();
  }, [year, month, scope]);

  const rows = useMemo(() => {
    return accounts
      .map(a => {
        const budget = budgets[a.id] || 0;
        const actual = actuals[a.id] || 0;
        const variance = actual - budget;
        const pct = budget !== 0 ? (variance / Math.abs(budget)) * 100 : (actual !== 0 ? 100 : 0);
        return { account: a, budget, actual, variance, pct };
      })
      .filter(r => r.budget !== 0 || Math.abs(r.actual) > 0.005);
  }, [accounts, budgets, actuals]);

  const subtitle = `${scope === "month" ? months[month-1] : `YTD ${months[month-1]}`} ${year}`;

  const cols: Column[] = [
    { header: "Code", key: "code" },
    { header: "Account", key: "name" },
    { header: "Type", key: "type" },
    { header: "Budget", key: "budget", align: "right" },
    { header: "Actual", key: "actual", align: "right" },
    { header: "Variance", key: "variance", align: "right" },
    { header: "%", key: "pct", align: "right" },
  ];
  const exportRows = rows.map(r => ({
    code: r.account.code, name: r.account.name, type: r.account.account_type,
    budget: r.budget, actual: r.actual, variance: r.variance, pct: r.pct.toFixed(1) + "%",
  }));

  return (
    <Card>
      <CardHeader className="flex flex-row items-center justify-between flex-wrap gap-3">
        <CardTitle>Budget vs Actual — {subtitle}</CardTitle>
        <div className="flex gap-2 flex-wrap">
          <Select value={scope} onValueChange={(v: any) => setScope(v)}>
            <SelectTrigger className="w-[140px]"><SelectValue /></SelectTrigger>
            <SelectContent>
              <SelectItem value="month">Single month</SelectItem>
              <SelectItem value="ytd">Year to date</SelectItem>
            </SelectContent>
          </Select>
          <Select value={String(month)} onValueChange={v => setMonth(Number(v))}>
            <SelectTrigger className="w-[110px]"><SelectValue /></SelectTrigger>
            <SelectContent>{months.map((m,i) => <SelectItem key={i} value={String(i+1)}>{m}</SelectItem>)}</SelectContent>
          </Select>
          <Select value={String(year)} onValueChange={v => setYear(Number(v))}>
            <SelectTrigger className="w-[110px]"><SelectValue /></SelectTrigger>
            <SelectContent>{[2024,2025,2026,2027].map(y => <SelectItem key={y} value={String(y)}>{y}</SelectItem>)}</SelectContent>
          </Select>
          <Button variant="outline" size="sm" onClick={() => exportToPdf({ title: "Budget vs Actual", subtitle, columns: cols, rows: exportRows, filename: "budget_vs_actual" })}>
            <FileDown className="mr-1 h-4 w-4" /> PDF
          </Button>
          <Button variant="outline" size="sm" onClick={() => exportToExcel({ sheetName: "BvA", columns: cols, rows: exportRows, filename: "budget_vs_actual" })}>
            <FileSpreadsheet className="mr-1 h-4 w-4" /> Excel
          </Button>
        </div>
      </CardHeader>
      <CardContent>
        {loading ? (
          <div className="flex items-center justify-center py-10 text-muted-foreground"><Loader2 className="mr-2 h-4 w-4 animate-spin" /> Loading…</div>
        ) : (
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead className="w-20">Code</TableHead>
                <TableHead>Account</TableHead>
                <TableHead className="text-right">Budget</TableHead>
                <TableHead className="text-right">Actual</TableHead>
                <TableHead className="text-right">Variance</TableHead>
                <TableHead className="text-right w-20">%</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {rows.length === 0 ? (
                <TableRow><TableCell colSpan={6} className="text-center py-10 text-muted-foreground">No budget data for this period.</TableCell></TableRow>
              ) : rows.map(r => {
                const isExpense = r.account.account_type === "expense";
                const overBudget = isExpense ? r.actual > r.budget : r.actual < r.budget;
                return (
                  <TableRow key={r.account.id}>
                    <TableCell className="font-mono text-xs">{r.account.code}</TableCell>
                    <TableCell>{r.account.name} <span className="text-xs text-muted-foreground capitalize">({r.account.account_type})</span></TableCell>
                    <TableCell className="text-right font-mono">{fmtMoney(r.budget)}</TableCell>
                    <TableCell className="text-right font-mono">{fmtMoney(r.actual)}</TableCell>
                    <TableCell className={`text-right font-mono ${overBudget ? "text-red-600" : "text-green-600"}`}>{fmtMoney(r.variance)}</TableCell>
                    <TableCell className={`text-right font-mono text-xs ${overBudget ? "text-red-600" : "text-green-600"}`}>{r.pct.toFixed(1)}%</TableCell>
                  </TableRow>
                );
              })}
            </TableBody>
          </Table>
        )}
      </CardContent>
    </Card>
  );
}
