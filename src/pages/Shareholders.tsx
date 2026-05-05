import { useQuery } from "@tanstack/react-query";
import { Link } from "react-router-dom";
import { db } from "@/lib/db";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";

function formatMZN(v: number) {
  return new Intl.NumberFormat("en-US", { minimumFractionDigits: 2 }).format(v);
}

export default function Shareholders() {
  const { data: shareholders } = useQuery({
    queryKey: ["shareholders"],
    queryFn: async () => {
      const { data } = await db.from("shareholders").select("*, properties:property_code(name)");
      return data ?? [];
    },
  });

  const { data: balances } = useQuery({
    queryKey: ["shareholder-balances-all"],
    queryFn: async () => {
      const { data } = await db.from("shareholder_balances").select("*, shareholders(name), properties(name)").order("year", { ascending: false }).order("month", { ascending: false });
      return data ?? [];
    },
  });

  return (
    <div className="space-y-6">
      <h1 className="text-3xl font-bold">Shareholders</h1>

      <Card>
        <CardHeader><CardTitle>Shareholders</CardTitle></CardHeader>
        <CardContent>
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Name</TableHead>
                <TableHead>Property</TableHead>
                <TableHead>Ownership %</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {shareholders?.map((s: any) => (
                <TableRow key={s.id} className="cursor-pointer hover:bg-muted/50">
                  <TableCell className="font-medium">
                    <Link to={`/shareholders/${s.id}`} className="text-primary underline-offset-4 hover:underline">{s.name}</Link>
                  </TableCell>
                  <TableCell>{s.property_code}</TableCell>
                  <TableCell>{s.ownership_percentage}%</TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </CardContent>
      </Card>

      <Card>
        <CardHeader><CardTitle>Monthly Balances</CardTitle></CardHeader>
        <CardContent>
          {balances && balances.length > 0 ? (
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Shareholder</TableHead>
                  <TableHead>Property</TableHead>
                  <TableHead>Month/Year</TableHead>
                  <TableHead className="text-right">Opening</TableHead>
                  <TableHead className="text-right">Income</TableHead>
                  <TableHead className="text-right">Expenses</TableHead>
                  <TableHead className="text-right">Closing</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {balances.map((b: any) => (
                  <TableRow key={b.id}>
                    <TableCell>{b.shareholders?.name}</TableCell>
                    <TableCell>{b.properties?.name}</TableCell>
                    <TableCell>{b.month}/{b.year}</TableCell>
                    <TableCell className="text-right">{formatMZN(b.opening_balance)}</TableCell>
                    <TableCell className="text-right">{formatMZN(b.income)}</TableCell>
                    <TableCell className="text-right">{formatMZN(b.expenses)}</TableCell>
                    <TableCell className="text-right font-medium">{formatMZN(b.closing_balance)}</TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          ) : (
            <p className="text-muted-foreground py-8 text-center">No balance data yet. Upload shareholder Excel files to populate.</p>
          )}
        </CardContent>
      </Card>
    </div>
  );
}
