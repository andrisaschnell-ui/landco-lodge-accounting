import { useEffect, useMemo, useState } from "react";
import { supabase } from "@/integrations/supabase/client";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Checkbox } from "@/components/ui/checkbox";
import { useToast } from "@/hooks/use-toast";
import { Sparkles, CheckCircle2 } from "lucide-react";

type Bank = { id: string; name: string; bank_name: string };
type Tx = {
  id: string; date: string; description: string;
  debit: number | null; credit: number | null;
  reconciled: boolean; matched_je_id: string | null;
};

const fmt = (n: number) => new Intl.NumberFormat("pt-MZ", { minimumFractionDigits: 2 }).format(n || 0);

export default function BankReconciliation() {
  const today = new Date();
  const [banks, setBanks] = useState<Bank[]>([]);
  const [bankId, setBankId] = useState<string>("");
  const [year, setYear] = useState(today.getFullYear());
  const [month, setMonth] = useState(today.getMonth() + 1);
  const [txs, setTxs] = useState<Tx[]>([]);
  const [statementBalance, setStatementBalance] = useState(0);
  const [selected, setSelected] = useState<Set<string>>(new Set());
  const { toast } = useToast();

  useEffect(() => {
    supabase.from("bank_accounts").select("id,name,bank_name").then(({ data }) => {
      setBanks(data || []);
      if (data?.[0]) setBankId(data[0].id);
    });
  }, []);

  async function loadTxs() {
    if (!bankId) return;
    const { data } = await supabase
      .from("bank_transactions")
      .select("id,date,description,debit,credit,reconciled,matched_je_id")
      .eq("bank_account_id", bankId).eq("year", year).eq("month", month)
      .order("date");
    setTxs(((data as Tx[]) || []));
  }
  useEffect(() => { loadTxs(); /* eslint-disable-next-line */ }, [bankId, year, month]);

  const bookBalance = useMemo(() =>
    txs.filter(t => t.reconciled || selected.has(t.id))
      .reduce((s, t) => s + (Number(t.debit) || 0) - (Number(t.credit) || 0), 0),
    [txs, selected]);

  const difference = statementBalance - bookBalance;

  function toggle(id: string) {
    const next = new Set(selected);
    if (next.has(id)) next.delete(id); else next.add(id);
    setSelected(next);
  }

  function autoMatch() {
    // Suggest: select all unreconciled txs whose net moves the running total
    // toward statementBalance. Simple heuristic: pick ones not yet reconciled.
    const next = new Set(selected);
    txs.filter(t => !t.reconciled).forEach(t => next.add(t.id));
    setSelected(next);
    toast({ title: "Auto-suggested", description: "All unreconciled transactions selected. Untick any that don't appear on your bank statement." });
  }

  async function saveReconciliation() {
    if (!bankId) return;
    // Header
    const { data: rec, error } = await supabase
      .from("bank_reconciliations")
      .upsert({
        bank_account_id: bankId, year, month,
        statement_balance: statementBalance, book_balance: bookBalance,
        status: Math.abs(difference) < 0.01 ? "reconciled" : "open",
        reconciled_at: Math.abs(difference) < 0.01 ? new Date().toISOString() : null,
      } as any, { onConflict: "bank_account_id,year,month" })
      .select().single();
    if (error) return toast({ title: "Save failed", description: error.message, variant: "destructive" });

    // Mark selected txs as reconciled
    const ids = [...selected];
    if (ids.length) {
      await supabase.from("bank_transactions").update({
        reconciled: true, reconciliation_id: (rec as any).id,
      }).in("id", ids);
    }

    toast({
      title: Math.abs(difference) < 0.01 ? "Reconciled ✓" : "Saved (still open)",
      description: `Difference: ${fmt(difference)} MZN`,
    });
    loadTxs();
  }

  return (
    <div className="space-y-4 p-6">
      <h1 className="text-2xl font-bold">Bank Reconciliation</h1>

      <Card>
        <CardContent className="pt-6 grid grid-cols-2 md:grid-cols-5 gap-3">
          <div>
            <Label>Bank Account</Label>
            <Select value={bankId} onValueChange={setBankId}>
              <SelectTrigger><SelectValue /></SelectTrigger>
              <SelectContent>{banks.map(b => <SelectItem key={b.id} value={b.id}>{b.name} ({b.bank_name})</SelectItem>)}</SelectContent>
            </Select>
          </div>
          <div><Label>Year</Label><Input type="number" value={year} onChange={(e) => setYear(+e.target.value)} /></div>
          <div><Label>Month</Label><Input type="number" min={1} max={12} value={month} onChange={(e) => setMonth(+e.target.value)} /></div>
          <div><Label>Statement Balance</Label><Input type="number" step="0.01" value={statementBalance} onChange={(e) => setStatementBalance(+e.target.value)} /></div>
          <div className="flex items-end gap-2">
            <Button onClick={autoMatch} variant="outline" className="flex-1"><Sparkles className="h-4 w-4 mr-1" />Auto-suggest</Button>
          </div>
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle>
            Book balance (selected/reconciled): MZN {fmt(bookBalance)} ·
            Difference: <span className={Math.abs(difference) < 0.01 ? "text-green-600" : "text-orange-600"}>{fmt(difference)}</span>
          </CardTitle>
        </CardHeader>
        <CardContent>
          <Table>
            <TableHeader><TableRow>
              <TableHead className="w-10">✓</TableHead>
              <TableHead>Date</TableHead><TableHead>Description</TableHead>
              <TableHead className="text-right">Debit</TableHead>
              <TableHead className="text-right">Credit</TableHead>
              <TableHead>Status</TableHead>
            </TableRow></TableHeader>
            <TableBody>
              {txs.map(t => (
                <TableRow key={t.id} className={t.reconciled ? "bg-green-50" : ""}>
                  <TableCell>
                    <Checkbox
                      checked={t.reconciled || selected.has(t.id)}
                      disabled={t.reconciled}
                      onCheckedChange={() => toggle(t.id)}
                    />
                  </TableCell>
                  <TableCell>{t.date}</TableCell>
                  <TableCell>{t.description}</TableCell>
                  <TableCell className="text-right">{t.debit ? fmt(t.debit) : ""}</TableCell>
                  <TableCell className="text-right">{t.credit ? fmt(t.credit) : ""}</TableCell>
                  <TableCell>{t.reconciled ? <span className="text-green-600 inline-flex items-center"><CheckCircle2 className="h-4 w-4 mr-1" />Reconciled</span> : "Open"}</TableCell>
                </TableRow>
              ))}
              {txs.length === 0 && <TableRow><TableCell colSpan={6} className="text-center text-muted-foreground">No transactions for this period.</TableCell></TableRow>}
            </TableBody>
          </Table>

          <div className="mt-4 flex justify-end">
            <Button onClick={saveReconciliation}><CheckCircle2 className="h-4 w-4 mr-2" />Save reconciliation</Button>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}
