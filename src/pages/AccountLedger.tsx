import { useEffect, useMemo, useState } from "react";
import { supabase as supabaseTyped } from "@/integrations/supabase/client";
const supabase: any = supabaseTyped;
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Loader2 } from "lucide-react";
import { format } from "date-fns";

const fmt = (n: number) =>
  Number(n || 0).toLocaleString(undefined, { minimumFractionDigits: 2, maximumFractionDigits: 2 });

export default function AccountLedger() {
  const [accounts, setAccounts] = useState<any[]>([]);
  const [accountId, setAccountId] = useState<string>("");
  const [lines, setLines] = useState<any[]>([]);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    (async () => {
      const { data } = await supabase.from("accounts").select("id, code, name, normal_side").order("code");
      setAccounts(data || []);
    })();
  }, []);

  useEffect(() => {
    if (!accountId) { setLines([]); return; }
    setLoading(true);
    (async () => {
      const { data } = await supabase
        .from("journal_lines")
        .select("id, debit, credit, memo, journal_entry_id, journal_entries!inner(entry_date, description, entry_type, reference, posted)")
        .eq("account_id", accountId)
        .eq("journal_entries.posted", true)
        .order("entry_date", { foreignTable: "journal_entries", ascending: true });
      setLines(data || []);
      setLoading(false);
    })();
  }, [accountId]);

  const account = useMemo(() => accounts.find(a => a.id === accountId), [accounts, accountId]);

  const enriched = useMemo(() => {
    let running = 0;
    return lines.map((l: any) => {
      const d = Number(l.debit || 0);
      const c = Number(l.credit || 0);
      const delta = account?.normal_side === "debit" ? d - c : c - d;
      running += delta;
      return { ...l, running };
    });
  }, [lines, account]);

  const totalD = lines.reduce((s, l) => s + Number(l.debit || 0), 0);
  const totalC = lines.reduce((s, l) => s + Number(l.credit || 0), 0);

  return (
    <div className="container mx-auto py-6 space-y-6">
      <div className="flex justify-between items-center">
        <h1 className="text-3xl font-bold tracking-tight">Account Ledger</h1>
      </div>

      <Card>
        <CardHeader>
          <CardTitle>Select an account</CardTitle>
        </CardHeader>
        <CardContent>
          <Select value={accountId} onValueChange={setAccountId}>
            <SelectTrigger className="max-w-md"><SelectValue placeholder="Pick a PGC account…" /></SelectTrigger>
            <SelectContent>
              {accounts.map(a => (
                <SelectItem key={a.id} value={a.id}>{a.code} — {a.name}</SelectItem>
              ))}
            </SelectContent>
          </Select>
        </CardContent>
      </Card>

      {accountId && (
        <Card>
          <CardHeader>
            <CardTitle>
              {account?.code} — {account?.name}{" "}
              <span className="text-sm font-normal text-muted-foreground capitalize ml-2">
                ({account?.normal_side} normal)
              </span>
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
                    <TableHead>Date</TableHead>
                    <TableHead>Description</TableHead>
                    <TableHead>Type</TableHead>
                    <TableHead>Memo</TableHead>
                    <TableHead className="text-right">Debit</TableHead>
                    <TableHead className="text-right">Credit</TableHead>
                    <TableHead className="text-right">Running</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {enriched.length === 0 ? (
                    <TableRow><TableCell colSpan={7} className="text-center py-10 text-muted-foreground">No posted lines for this account.</TableCell></TableRow>
                  ) : enriched.map((l: any) => (
                    <TableRow key={l.id}>
                      <TableCell>{l.journal_entries?.entry_date ? format(new Date(l.journal_entries.entry_date), "dd/MM/yyyy") : "—"}</TableCell>
                      <TableCell>{l.journal_entries?.description}</TableCell>
                      <TableCell className="capitalize text-muted-foreground">{l.journal_entries?.entry_type}</TableCell>
                      <TableCell className="text-muted-foreground">{l.memo || ""}</TableCell>
                      <TableCell className="text-right font-mono">{l.debit ? fmt(l.debit) : ""}</TableCell>
                      <TableCell className="text-right font-mono">{l.credit ? fmt(l.credit) : ""}</TableCell>
                      <TableCell className="text-right font-mono font-semibold">{fmt(l.running)}</TableCell>
                    </TableRow>
                  ))}
                  {enriched.length > 0 && (
                    <TableRow className="font-semibold border-t-2">
                      <TableCell colSpan={4}>Totals</TableCell>
                      <TableCell className="text-right font-mono">{fmt(totalD)}</TableCell>
                      <TableCell className="text-right font-mono">{fmt(totalC)}</TableCell>
                      <TableCell className="text-right font-mono">{fmt(enriched[enriched.length - 1].running)}</TableCell>
                    </TableRow>
                  )}
                </TableBody>
              </Table>
            )}
          </CardContent>
        </Card>
      )}
    </div>
  );
}
