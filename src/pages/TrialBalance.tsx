import { useEffect, useState } from "react";
import { supabase as supabaseTyped } from "@/integrations/supabase/client";
const supabase: any = supabaseTyped;
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Loader2 } from "lucide-react";

interface Row {
  account_id: string;
  code: string;
  name: string;
  account_type: string;
  pgc_class: string | null;
  total_debit: number;
  total_credit: number;
  balance: number;
}

const fmt = (n: number) =>
  Number(n || 0).toLocaleString(undefined, { minimumFractionDigits: 2, maximumFractionDigits: 2 });

export default function TrialBalance() {
  const [rows, setRows] = useState<Row[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    (async () => {
      setLoading(true);
      const [{ data: accs }, { data: lines }] = await Promise.all([
        db.from("accounts").select("id, code, name, account_type, pgc_class, normal_side").order("code"),
        // join lines with entries to filter posted only
        supabase
          .from("journal_lines")
          .select("account_id, debit, credit, journal_entry_id, journal_entries!inner(posted)")
          .eq("journal_entries.posted", true),
      ]);

      const byAcc = new Map<string, { d: number; c: number }>();
      (lines || []).forEach((l: any) => {
        const cur = byAcc.get(l.account_id) || { d: 0, c: 0 };
        cur.d += Number(l.debit || 0);
        cur.c += Number(l.credit || 0);
        byAcc.set(l.account_id, cur);
      });

      const out: Row[] = (accs || []).map((a: any) => {
        const t = byAcc.get(a.id) || { d: 0, c: 0 };
        const balance = a.normal_side === "debit" ? t.d - t.c : t.c - t.d;
        return {
          account_id: a.id,
          code: a.code,
          name: a.name,
          account_type: a.account_type,
          pgc_class: a.pgc_class,
          total_debit: t.d,
          total_credit: t.c,
          balance,
        };
      }).filter(r => r.total_debit > 0 || r.total_credit > 0);

      setRows(out);
      setLoading(false);
    })();
  }, []);

  const totalDebit  = rows.reduce((s, r) => s + r.total_debit,  0);
  const totalCredit = rows.reduce((s, r) => s + r.total_credit, 0);
  const diff = Math.round((totalDebit - totalCredit) * 100) / 100;

  return (
    <div className="container mx-auto py-6 space-y-6">
      <div className="flex justify-between items-center">
        <h1 className="text-3xl font-bold tracking-tight">Trial Balance</h1>
      </div>

      <Card>
        <CardHeader>
          <CardTitle>
            All posted journal lines{" "}
            {!loading && (
              <span className={`ml-3 text-sm font-normal ${diff === 0 ? "text-green-600" : "text-red-600"}`}>
                {diff === 0 ? "✓ Balanced" : `Out by ${fmt(diff)}`}
              </span>
            )}
          </CardTitle>
        </CardHeader>
        <CardContent>
          {loading ? (
            <div className="flex items-center justify-center py-10 text-muted-foreground">
              <Loader2 className="mr-2 h-4 w-4 animate-spin" /> Loading…
            </div>
          ) : (
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead className="w-[80px]">Code</TableHead>
                  <TableHead>Account</TableHead>
                  <TableHead>Type</TableHead>
                  <TableHead className="text-right">Total Debit</TableHead>
                  <TableHead className="text-right">Total Credit</TableHead>
                  <TableHead className="text-right">Balance</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {rows.map(r => (
                  <TableRow key={r.account_id}>
                    <TableCell className="font-mono font-bold">{r.code}</TableCell>
                    <TableCell>{r.name}</TableCell>
                    <TableCell className="capitalize text-muted-foreground">{r.account_type}</TableCell>
                    <TableCell className="text-right font-mono">{r.total_debit ? fmt(r.total_debit) : ""}</TableCell>
                    <TableCell className="text-right font-mono">{r.total_credit ? fmt(r.total_credit) : ""}</TableCell>
                    <TableCell className="text-right font-mono font-semibold">{fmt(r.balance)}</TableCell>
                  </TableRow>
                ))}
                <TableRow className="font-semibold border-t-2">
                  <TableCell colSpan={3}>Totals</TableCell>
                  <TableCell className="text-right font-mono">{fmt(totalDebit)}</TableCell>
                  <TableCell className="text-right font-mono">{fmt(totalCredit)}</TableCell>
                  <TableCell className="text-right font-mono">{fmt(diff)}</TableCell>
                </TableRow>
              </TableBody>
            </Table>
          )}
        </CardContent>
      </Card>
    </div>
  );
}
