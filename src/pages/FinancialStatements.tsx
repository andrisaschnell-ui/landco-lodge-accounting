import { useEffect, useMemo, useState } from "react";
import { supabase as supabaseTyped } from "@/integrations/supabase/client";
const supabase: any = supabaseTyped;
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Button } from "@/components/ui/button";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Loader2, FileDown, FileSpreadsheet } from "lucide-react";
import {
  AccountRow, LineAgg, loadAccounts, loadAggregates,
  buildPL, buildBalanceSheet, buildCashFlow, fmtMoney, firstDay, lastDay,
} from "@/lib/statements";
import { exportToPdf, exportToExcel, Column } from "@/lib/exportUtils";

const months = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"];

export default function FinancialStatements() {
  const today = new Date();
  const [year, setYear] = useState<number>(today.getFullYear());
  const [month, setMonth] = useState<number>(today.getMonth() + 1);
  const [mode, setMode] = useState<"month" | "ytd" | "year">("month");
  const [propertyId, setPropertyId] = useState<string>("ALL");
  const [compare, setCompare] = useState<boolean>(false);

  const [properties, setProperties] = useState<any[]>([]);
  const [accounts, setAccounts] = useState<AccountRow[]>([]);
  const [agg, setAgg] = useState<LineAgg[]>([]);
  const [aggPrev, setAggPrev] = useState<LineAgg[]>([]);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    (async () => {
      const [{ data: props }, accts] = await Promise.all([
        db.from("properties").select("id, code, name").order("code"),
        loadAccounts(),
      ]);
      setProperties(props || []);
      setAccounts(accts);
    })();
  }, []);

  const range = useMemo(() => {
    if (mode === "month") return { from: firstDay(year, month), to: lastDay(year, month), label: `${months[month-1]} ${year}` };
    if (mode === "ytd")   return { from: firstDay(year, 1),     to: lastDay(year, month), label: `YTD ${months[month-1]} ${year}` };
    return                       { from: firstDay(year, 1),     to: lastDay(year, 12),    label: `Year ${year}` };
  }, [mode, year, month]);

  const prevRange = useMemo(() => {
    if (mode === "month") return { from: firstDay(year - 1, month), to: lastDay(year - 1, month), label: `${months[month-1]} ${year-1}` };
    if (mode === "ytd")   return { from: firstDay(year - 1, 1),     to: lastDay(year - 1, month), label: `YTD ${months[month-1]} ${year-1}` };
    return                       { from: firstDay(year - 1, 1),     to: lastDay(year - 1, 12),    label: `Year ${year-1}` };
  }, [mode, year, month]);

  useEffect(() => {
    setLoading(true);
    (async () => {
      const pid = propertyId === "ALL" ? null : propertyId;
      const tasks: Promise<LineAgg[]>[] = [loadAggregates({ from: range.from, to: range.to, propertyId: pid })];
      if (compare) tasks.push(loadAggregates({ from: prevRange.from, to: prevRange.to, propertyId: pid }));
      const results = await Promise.all(tasks);
      setAgg(results[0] || []);
      setAggPrev(results[1] || []);
      setLoading(false);
    })();
  }, [range.from, range.to, prevRange.from, prevRange.to, propertyId, compare]);

  const pl = useMemo(() => buildPL(accounts, agg), [accounts, agg]);
  const plPrev = useMemo(() => buildPL(accounts, aggPrev), [accounts, aggPrev]);
  const bs = useMemo(() => buildBalanceSheet(accounts, agg, pl), [accounts, agg, pl]);
  const cf = useMemo(() => buildCashFlow(accounts, agg, pl.netIncome), [accounts, agg, pl.netIncome]);

  const propertyLabel = propertyId === "ALL" ? "Consolidated" : (properties.find(p => p.id === propertyId)?.name || "");
  const subtitle = `${propertyLabel} • ${range.label}${compare ? ` vs ${prevRange.label}` : ""}`;

  return (
    <div className="container mx-auto py-6 space-y-6">
      <div className="flex flex-wrap justify-between items-start gap-4">
        <div>
          <h1 className="text-3xl font-bold tracking-tight">Financial Statements</h1>
          <p className="text-muted-foreground">{subtitle}</p>
        </div>
        <Filters
          {...{ year, setYear, month, setMonth, mode, setMode, propertyId, setPropertyId, compare, setCompare, properties }}
        />
      </div>

      {loading ? (
        <div className="flex items-center justify-center py-16 text-muted-foreground">
          <Loader2 className="mr-2 h-5 w-5 animate-spin" /> Loading…
        </div>
      ) : (
        <Tabs defaultValue="pl">
          <TabsList>
            <TabsTrigger value="pl">P&L</TabsTrigger>
            <TabsTrigger value="bs">Balance Sheet</TabsTrigger>
            <TabsTrigger value="cf">Cash Flow</TabsTrigger>
          </TabsList>

          <TabsContent value="pl" className="mt-4">
            <PLView pl={pl} plPrev={compare ? plPrev : null} subtitle={subtitle} prevLabel={prevRange.label} curLabel={range.label} />
          </TabsContent>
          <TabsContent value="bs" className="mt-4">
            <BSView bs={bs} subtitle={subtitle} />
          </TabsContent>
          <TabsContent value="cf" className="mt-4">
            <CFView cf={cf} subtitle={subtitle} />
          </TabsContent>
        </Tabs>
      )}
    </div>
  );
}

function Filters(p: any) {
  return (
    <div className="flex flex-wrap gap-2 items-center">
      <Select value={p.mode} onValueChange={p.setMode}>
        <SelectTrigger className="w-[140px]"><SelectValue /></SelectTrigger>
        <SelectContent>
          <SelectItem value="month">Single month</SelectItem>
          <SelectItem value="ytd">Year to date</SelectItem>
          <SelectItem value="year">Full year</SelectItem>
        </SelectContent>
      </Select>
      {p.mode !== "year" && (
        <Select value={String(p.month)} onValueChange={(v) => p.setMonth(Number(v))}>
          <SelectTrigger className="w-[110px]"><SelectValue /></SelectTrigger>
          <SelectContent>
            {months.map((m, i) => <SelectItem key={i} value={String(i+1)}>{m}</SelectItem>)}
          </SelectContent>
        </Select>
      )}
      <Select value={String(p.year)} onValueChange={(v) => p.setYear(Number(v))}>
        <SelectTrigger className="w-[110px]"><SelectValue /></SelectTrigger>
        <SelectContent>
          {[2024,2025,2026,2027].map(y => <SelectItem key={y} value={String(y)}>{y}</SelectItem>)}
        </SelectContent>
      </Select>
      <Select value={p.propertyId} onValueChange={p.setPropertyId}>
        <SelectTrigger className="w-[180px]"><SelectValue /></SelectTrigger>
        <SelectContent>
          <SelectItem value="ALL">Consolidated (all)</SelectItem>
          {p.properties.map((pr: any) => <SelectItem key={pr.id} value={pr.id}>{pr.code} — {pr.name}</SelectItem>)}
        </SelectContent>
      </Select>
      <Button variant={p.compare ? "default" : "outline"} size="sm" onClick={() => p.setCompare(!p.compare)}>
        Compare prior year
      </Button>
    </div>
  );
}

function PLView({ pl, plPrev, subtitle, prevLabel, curLabel }: any) {
  const rows: any[] = [];
  rows.push({ section: "REVENUES" });
  pl.revenues.accounts.forEach((r: any) => rows.push({
    code: r.account.code, name: r.account.name,
    cur: r.balance,
    prev: plPrev?.revenues.accounts.find((x: any) => x.account.id === r.account.id)?.balance ?? 0,
  }));
  rows.push({ name: "Total Revenues", cur: pl.revenues.total, prev: plPrev?.revenues.total ?? 0, bold: true });
  rows.push({ section: "EXPENSES" });
  pl.expenses.accounts.forEach((r: any) => rows.push({
    code: r.account.code, name: r.account.name,
    cur: r.balance,
    prev: plPrev?.expenses.accounts.find((x: any) => x.account.id === r.account.id)?.balance ?? 0,
  }));
  rows.push({ name: "Total Expenses", cur: pl.expenses.total, prev: plPrev?.expenses.total ?? 0, bold: true });
  rows.push({ name: "NET INCOME", cur: pl.netIncome, prev: plPrev ? plPrev.revenues.total - plPrev.expenses.total : 0, bold: true, highlight: true });

  const baseCols: Column[] = [
    { header: "Code", key: "code" },
    { header: "Account", key: "name" },
    { header: curLabel, key: "cur", align: "right" },
  ];
  if (plPrev) baseCols.push({ header: prevLabel, key: "prev", align: "right" });

  const exportRows = rows.filter(r => !r.section).map(r => ({ code: r.code || "", name: r.name, cur: r.cur, prev: r.prev }));

  return (
    <Card>
      <CardHeader className="flex flex-row items-center justify-between">
        <CardTitle>Profit & Loss (Demonstração de Resultados)</CardTitle>
        <ExportButtons title="Profit & Loss" subtitle={subtitle} columns={baseCols} rows={exportRows} filename="profit_and_loss" />
      </CardHeader>
      <CardContent>
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead className="w-24">Code</TableHead>
              <TableHead>Account</TableHead>
              <TableHead className="text-right">{curLabel}</TableHead>
              {plPrev && <TableHead className="text-right">{prevLabel}</TableHead>}
            </TableRow>
          </TableHeader>
          <TableBody>
            {rows.map((r, i) => r.section ? (
              <TableRow key={i} className="bg-muted/40">
                <TableCell colSpan={plPrev ? 4 : 3} className="font-bold text-xs uppercase">{r.section}</TableCell>
              </TableRow>
            ) : (
              <TableRow key={i} className={`${r.bold ? "font-bold" : ""} ${r.highlight ? "bg-primary/5" : ""}`}>
                <TableCell className="font-mono text-xs">{r.code || ""}</TableCell>
                <TableCell>{r.name}</TableCell>
                <TableCell className="text-right font-mono">{fmtMoney(r.cur)}</TableCell>
                {plPrev && <TableCell className="text-right font-mono text-muted-foreground">{fmtMoney(r.prev)}</TableCell>}
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </CardContent>
    </Card>
  );
}

function BSView({ bs, subtitle }: any) {
  const renderSection = (s: any) => (
    <>
      <TableRow className="bg-muted/40">
        <TableCell colSpan={3} className="font-bold text-xs uppercase">{s.label}</TableCell>
      </TableRow>
      {s.accounts.map((r: any) => (
        <TableRow key={r.account.id}>
          <TableCell className="font-mono text-xs">{r.account.code}</TableCell>
          <TableCell>{r.account.name}</TableCell>
          <TableCell className="text-right font-mono">{fmtMoney(r.balance)}</TableCell>
        </TableRow>
      ))}
      <TableRow className="font-bold border-t-2">
        <TableCell colSpan={2}>Total {s.label}</TableCell>
        <TableCell className="text-right font-mono">{fmtMoney(s.total)}</TableCell>
      </TableRow>
    </>
  );

  const cols: Column[] = [
    { header: "Code", key: "code" },
    { header: "Account", key: "name" },
    { header: "Balance", key: "balance", align: "right" },
  ];
  const exportRows: any[] = [];
  for (const s of [bs.assets, bs.liabilities, bs.equity]) {
    s.accounts.forEach((r: any) => exportRows.push({ code: r.account.code, name: r.account.name, balance: r.balance }));
    exportRows.push({ code: "", name: `Total ${s.label}`, balance: s.total });
  }

  return (
    <Card>
      <CardHeader className="flex flex-row items-center justify-between">
        <CardTitle>
          Balance Sheet (Balanço){" "}
          {Math.abs(bs.diff) < 0.01
            ? <span className="text-xs ml-2 text-green-600">Balanced</span>
            : <span className="text-xs ml-2 text-amber-600">Diff: {fmtMoney(bs.diff)}</span>}
        </CardTitle>
        <ExportButtons title="Balance Sheet" subtitle={subtitle} columns={cols} rows={exportRows} filename="balance_sheet" />
      </CardHeader>
      <CardContent>
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead className="w-24">Code</TableHead>
              <TableHead>Account</TableHead>
              <TableHead className="text-right">Balance</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {renderSection(bs.assets)}
            {renderSection(bs.liabilities)}
            {renderSection(bs.equity)}
            <TableRow className="font-bold bg-primary/5">
              <TableCell colSpan={2}>Total Liabilities + Equity</TableCell>
              <TableCell className="text-right font-mono">{fmtMoney(bs.totalLiabEquity)}</TableCell>
            </TableRow>
          </TableBody>
        </Table>
      </CardContent>
    </Card>
  );
}

function CFView({ cf, subtitle }: any) {
  const cols: Column[] = [
    { header: "Item", key: "name" },
    { header: "Amount", key: "amount", align: "right" },
  ];
  const exportRows = [
    { name: "Net Income", amount: cf.netIncome },
    ...cf.wcLines.map((l: any) => ({ name: `Δ ${l.account.code} ${l.account.name}`, amount: l.balance })),
    { name: "Operating Cash Flow", amount: cf.operatingCash },
    ...cf.cashLines.map((l: any) => ({ name: `${l.account.code} ${l.account.name}`, amount: l.balance })),
    { name: "Net change in Cash", amount: cf.cashMove },
  ];

  return (
    <Card>
      <CardHeader className="flex flex-row items-center justify-between">
        <CardTitle>Cash Flow (Demonstração de Fluxos de Caixa) — Indirect</CardTitle>
        <ExportButtons title="Cash Flow Statement" subtitle={subtitle} columns={cols} rows={exportRows} filename="cash_flow" />
      </CardHeader>
      <CardContent>
        <Table>
          <TableBody>
            <TableRow className="bg-muted/40"><TableCell colSpan={2} className="font-bold uppercase text-xs">Operating Activities</TableCell></TableRow>
            <TableRow><TableCell>Net Income</TableCell><TableCell className="text-right font-mono">{fmtMoney(cf.netIncome)}</TableCell></TableRow>
            {cf.wcLines.map((l: any) => (
              <TableRow key={l.account.id}>
                <TableCell className="text-muted-foreground">Δ {l.account.code} — {l.account.name}</TableCell>
                <TableCell className="text-right font-mono">{fmtMoney(l.balance)}</TableCell>
              </TableRow>
            ))}
            <TableRow className="font-bold border-t-2">
              <TableCell>Operating Cash Flow</TableCell>
              <TableCell className="text-right font-mono">{fmtMoney(cf.operatingCash)}</TableCell>
            </TableRow>
            <TableRow className="bg-muted/40"><TableCell colSpan={2} className="font-bold uppercase text-xs">Cash Movement</TableCell></TableRow>
            {cf.cashLines.map((l: any) => (
              <TableRow key={l.account.id}>
                <TableCell>{l.account.code} — {l.account.name}</TableCell>
                <TableCell className="text-right font-mono">{fmtMoney(l.balance)}</TableCell>
              </TableRow>
            ))}
            <TableRow className="font-bold bg-primary/5">
              <TableCell>Net change in Cash</TableCell>
              <TableCell className="text-right font-mono">{fmtMoney(cf.cashMove)}</TableCell>
            </TableRow>
          </TableBody>
        </Table>
      </CardContent>
    </Card>
  );
}

function ExportButtons({ title, subtitle, columns, rows, filename }: any) {
  return (
    <div className="flex gap-2">
      <Button variant="outline" size="sm" onClick={() => exportToPdf({ title, subtitle, columns, rows, filename })}>
        <FileDown className="mr-1 h-4 w-4" /> PDF
      </Button>
      <Button variant="outline" size="sm" onClick={() => exportToExcel({ sheetName: title, columns, rows, filename })}>
        <FileSpreadsheet className="mr-1 h-4 w-4" /> Excel
      </Button>
    </div>
  );
}
