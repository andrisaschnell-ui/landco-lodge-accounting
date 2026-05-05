import { useParams, Link } from "react-router-dom";
import { useQuery } from "@tanstack/react-query";
import { db } from "@/lib/db";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Button } from "@/components/ui/button";
import { ArrowLeft, Printer } from "lucide-react";

function fmt(v: number) {
  return new Intl.NumberFormat("en-US", { minimumFractionDigits: 2 }).format(v);
}

const MONTHS = ["", "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];

export default function ShareholderDetail() {
  const { id } = useParams<{ id: string }>();

  const { data: shareholder } = useQuery({
    queryKey: ["shareholder", id],
    queryFn: async () => {
      const { data } = await db.from("shareholders").select("*").eq("id", id!).single();
      return data;
    },
    enabled: !!id,
  });

  const { data: balances } = useQuery({
    queryKey: ["sh-balances", id],
    queryFn: async () => {
      const { data } = await db.from("shareholder_balances").select("*, properties(name)").eq("shareholder_id", id!).order("year").order("month");
      return data ?? [];
    },
    enabled: !!id,
  });

  const { data: expenses } = useQuery({
    queryKey: ["sh-expenses", id],
    queryFn: async () => {
      const { data } = await db.from("expense_transactions").select("*, expense_categories(name)").eq("shareholder_id", id!).order("date", { ascending: false }).limit(50);
      return data ?? [];
    },
    enabled: !!id,
  });

  if (!shareholder) return <p className="p-6 text-muted-foreground">Loading...</p>;

  const totalIncome = balances?.reduce((s, b) => s + Number(b.income ?? 0), 0) ?? 0;
  const totalExpenses = balances?.reduce((s, b) => s + Number(b.expenses ?? 0), 0) ?? 0;

  return (
    <div className="space-y-6">
      <div className="flex items-center gap-3 print:hidden">
        <Link to="/shareholders"><Button variant="ghost" size="icon"><ArrowLeft className="h-4 w-4" /></Button></Link>
        <h1 className="text-3xl font-bold">{shareholder.name}</h1>
        <Button variant="outline" size="sm" className="ml-auto" onClick={() => window.print()}>
          <Printer className="mr-2 h-4 w-4" /> Print
        </Button>
      </div>

      <div className="grid gap-4 md:grid-cols-3">
        <Card><CardContent className="pt-6"><p className="text-sm text-muted-foreground">Property</p><p className="text-xl font-bold">{shareholder.property_code ?? "—"}</p></CardContent></Card>
        <Card><CardContent className="pt-6"><p className="text-sm text-muted-foreground">Ownership</p><p className="text-xl font-bold">{shareholder.ownership_percentage ?? 0}%</p></CardContent></Card>
        <Card><CardContent className="pt-6"><p className="text-sm text-muted-foreground">Net P&L</p><p className={`text-xl font-bold ${totalIncome - totalExpenses >= 0 ? "text-green-600" : "text-red-600"}`}>MZN {fmt(totalIncome - totalExpenses)}</p></CardContent></Card>
      </div>

      <Card>
        <CardHeader><CardTitle>Monthly Balances</CardTitle></CardHeader>
        <CardContent>
          {balances && balances.length > 0 ? (
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Period</TableHead>
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
                    <TableCell>{MONTHS[b.month]} {b.year}</TableCell>
                    <TableCell>{b.properties?.name}</TableCell>
                    <TableCell className="text-right">{fmt(b.opening_balance ?? 0)}</TableCell>
                    <TableCell className="text-right">{fmt(b.income ?? 0)}</TableCell>
                    <TableCell className="text-right">{fmt(b.expenses ?? 0)}</TableCell>
                    <TableCell className="text-right font-bold">{fmt(b.closing_balance ?? 0)}</TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          ) : (
            <p className="text-muted-foreground text-center py-8">No balance data yet.</p>
          )}
        </CardContent>
      </Card>

      <Card>
        <CardHeader><CardTitle>Personal Expenses (last 50)</CardTitle></CardHeader>
        <CardContent>
          {expenses && expenses.length > 0 ? (
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Date</TableHead>
                  <TableHead>Category</TableHead>
                  <TableHead>Description</TableHead>
                  <TableHead className="text-right">Amount MZN</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {expenses.map((e: any) => (
                  <TableRow key={e.id}>
                    <TableCell>{e.date ?? "—"}</TableCell>
                    <TableCell>{e.expense_categories?.name ?? "—"}</TableCell>
                    <TableCell>{e.description}</TableCell>
                    <TableCell className="text-right">{fmt(e.amount_mzn)}</TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          ) : (
            <p className="text-muted-foreground text-center py-8">No personal expenses recorded.</p>
          )}
        </CardContent>
      </Card>
    </div>
  );
}
