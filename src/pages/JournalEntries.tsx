import { useEffect, useMemo, useState } from "react";
import { supabase as supabaseTyped } from "@/integrations/supabase/client";
const supabase: any = supabaseTyped;
import {
  Table, TableBody, TableCell, TableHead, TableHeader, TableRow,
} from "@/components/ui/table";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Alert, AlertDescription, AlertTitle } from "@/components/ui/alert";
import { Button } from "@/components/ui/button";
import { Collapsible, CollapsibleContent, CollapsibleTrigger } from "@/components/ui/collapsible";
import { ChevronDown, ChevronRight, AlertTriangle, Loader2 } from "lucide-react";
import { format } from "date-fns";
import { toast } from "sonner";

interface AccountRow { id: string; code: string; name: string; }
interface JLine { id: string; journal_entry_id: string; account_id: string; debit: number; credit: number; memo: string | null; }
interface JEntry {
  id: string; entry_date: string; description: string; entry_type: string;
  reference: string | null; posted: boolean; property_id: string | null;
  lines?: JLine[];
}

const SUSPENSE_CODE = "2999";

export default function JournalEntries() {
  const [accounts, setAccounts] = useState<AccountRow[]>([]);
  const [entries, setEntries] = useState<JEntry[]>([]);
  const [unpostedCount, setUnpostedCount] = useState(0);
  const [loading, setLoading] = useState(true);
  const [posting, setPosting] = useState(false);
  const [expanded, setExpanded] = useState<Record<string, boolean>>({});

  const accountById = useMemo(() => {
    const m = new Map<string, AccountRow>();
    accounts.forEach(a => m.set(a.id, a));
    return m;
  }, [accounts]);

  const load = async () => {
    setLoading(true);
    const [{ data: accs }, { data: jes }, { data: jls }] = await Promise.all([
      supabase.from("accounts").select("id, code, name").order("code"),
      supabase.from("journal_entries").select("*").order("entry_date", { ascending: false }).limit(500),
      supabase.from("journal_lines").select("*"),
    ]);
    const linesByEntry = new Map<string, JLine[]>();
    (jls || []).forEach((l: JLine) => {
      const arr = linesByEntry.get(l.journal_entry_id as any) || [];
      arr.push(l);
      linesByEntry.set((l as any).journal_entry_id, arr);
    });
    const enriched: JEntry[] = (jes || []).map((e: any) => ({ ...e, lines: linesByEntry.get(e.id) || [] }));
    setAccounts(accs || []);
    setEntries(enriched);

    // Count unposted source transactions (no journal_entry_id)
    const counts = await Promise.all([
      supabase.from("income_transactions").select("id", { count: "exact", head: true }).is("journal_entry_id", null),
      supabase.from("expense_transactions").select("id", { count: "exact", head: true }).is("journal_entry_id", null),
      supabase.from("bank_transactions").select("id", { count: "exact", head: true }).is("journal_entry_id", null),
      supabase.from("petty_cash_transactions").select("id", { count: "exact", head: true }).is("journal_entry_id", null),
    ]);
    const total = counts.reduce((s, r: any) => s + (r.count || 0), 0);
    setUnpostedCount(total);
    setLoading(false);
  };

  useEffect(() => { load(); }, []);

  const postAll = async () => {
    setPosting(true);
    try {
      // Resolve suspense + bank/cash accounts
      const suspense = accounts.find(a => a.code === SUSPENSE_CODE);
      if (!suspense) {
        toast.error(`Suspense account ${SUSPENSE_CODE} not found in Chart of Accounts.`);
        return;
      }

      // Load expense category mapping
      const { data: cats } = await supabase
        .from("expense_categories").select("id, pgc_account_code");
      const catToCode = new Map<string, string>();
      (cats || []).forEach((c: any) => { if (c.pgc_account_code) catToCode.set(c.id, c.pgc_account_code); });
      const codeToAcc = new Map<string, AccountRow>();
      accounts.forEach(a => codeToAcc.set(a.code, a));
      const accFor = (code?: string | null): AccountRow => {
        if (code && codeToAcc.has(code)) return codeToAcc.get(code)!;
        return suspense;
      };

      // Bank accounts -> account row
      const { data: banks } = await supabase.from("bank_accounts").select("id, name, pgc_account_code");
      const bankAccCode = new Map<string, string | null>();
      (banks || []).forEach((b: any) => bankAccCode.set(b.id, b.pgc_account_code || null));

      // Generic income revenue account fallback: 7111 if exists, else suspense
      const revenue = codeToAcc.get("7111") || suspense;
      const pettyCashAcc = codeToAcc.get("1111") || suspense;

      let posted = 0;

      // INCOME
      const { data: incomes } = await supabase
        .from("income_transactions").select("*").is("journal_entry_id", null);
      for (const it of (incomes || [])) {
        const total = Number(it.accommodation_amount_mzn || 0);
        if (!total) continue;
        const { data: je, error } = await supabase
          .from("journal_entries")
          .insert({
            entry_date: it.date,
            description: it.description || `Income: ${it.guest_name || ""}`.trim(),
            entry_type: "income",
            reference: it.id,
            posted: true,
            posted_at: new Date().toISOString(),
            property_id: it.property_id,
          })
          .select().single();
        if (error || !je) continue;
        await supabase.from("journal_lines").insert([
          { journal_entry_id: je.id, account_id: pettyCashAcc.id, debit: total, credit: 0, memo: "Cash received" },
          { journal_entry_id: je.id, account_id: revenue.id, debit: 0, credit: total, memo: "Accommodation income" },
        ]);
        await supabase.from("income_transactions").update({ journal_entry_id: je.id }).eq("id", it.id);
        posted++;
      }

      // EXPENSES
      const { data: exps } = await supabase
        .from("expense_transactions").select("*").is("journal_entry_id", null);
      for (const ex of (exps || [])) {
        const total = Number(ex.amount_mzn || 0);
        if (!total) continue;
        const expCode = ex.category_id ? catToCode.get(ex.category_id) : null;
        const expAcc = accFor(expCode);
        const { data: je, error } = await supabase
          .from("journal_entries")
          .insert({
            entry_date: ex.date,
            description: ex.description,
            entry_type: "expense",
            reference: ex.id,
            posted: true,
            posted_at: new Date().toISOString(),
            property_id: ex.property_id,
          })
          .select().single();
        if (error || !je) continue;
        await supabase.from("journal_lines").insert([
          { journal_entry_id: je.id, account_id: expAcc.id, debit: total, credit: 0, memo: ex.description },
          { journal_entry_id: je.id, account_id: pettyCashAcc.id, debit: 0, credit: total, memo: "Paid" },
        ]);
        await supabase.from("expense_transactions").update({ journal_entry_id: je.id }).eq("id", ex.id);
        posted++;
      }

      // BANK
      const { data: bks } = await supabase
        .from("bank_transactions").select("*").is("journal_entry_id", null);
      for (const b of (bks || [])) {
        const debit = Number(b.debit || 0);
        const credit = Number(b.credit || 0);
        if (!debit && !credit) continue;
        const code = b.bank_account_id ? bankAccCode.get(b.bank_account_id) : null;
        const bankAcc = accFor(code || undefined);
        const { data: je, error } = await supabase
          .from("journal_entries")
          .insert({
            entry_date: b.date,
            description: b.description,
            entry_type: "bank",
            reference: b.reference || b.id,
            posted: true,
            posted_at: new Date().toISOString(),
          })
          .select().single();
        if (error || !je) continue;
        const amt = debit || credit;
        await supabase.from("journal_lines").insert([
          { journal_entry_id: je.id, account_id: debit ? bankAcc.id : suspense.id, debit: amt, credit: 0, memo: b.description },
          { journal_entry_id: je.id, account_id: debit ? suspense.id : bankAcc.id, debit: 0, credit: amt, memo: b.description },
        ]);
        await supabase.from("bank_transactions").update({ journal_entry_id: je.id }).eq("id", b.id);
        posted++;
      }

      // PETTY CASH
      const { data: pcs } = await supabase
        .from("petty_cash_transactions").select("*").is("journal_entry_id", null);
      for (const p of (pcs || [])) {
        const debit = Number(p.debit || 0);
        const credit = Number(p.credit || 0);
        if (!debit && !credit) continue;
        const expAcc = suspense; // allocation text not mapped; goes to suspense for review
        const { data: je, error } = await supabase
          .from("journal_entries")
          .insert({
            entry_date: p.date,
            description: p.description,
            entry_type: "petty_cash",
            reference: p.reference || p.id,
            posted: true,
            posted_at: new Date().toISOString(),
          })
          .select().single();
        if (error || !je) continue;
        const amt = debit || credit;
        await supabase.from("journal_lines").insert([
          { journal_entry_id: je.id, account_id: debit ? pettyCashAcc.id : expAcc.id, debit: amt, credit: 0, memo: p.description },
          { journal_entry_id: je.id, account_id: debit ? expAcc.id : pettyCashAcc.id, debit: 0, credit: amt, memo: p.description },
        ]);
        await supabase.from("petty_cash_transactions").update({ journal_entry_id: je.id }).eq("id", p.id);
        posted++;
      }

      toast.success(`Posted ${posted} entries to the journal.`);
      await load();
    } catch (e: any) {
      toast.error(e.message || "Failed to post entries");
    } finally {
      setPosting(false);
    }
  };

  const fmt = (n: number) => Number(n || 0).toLocaleString(undefined, { minimumFractionDigits: 2, maximumFractionDigits: 2 });

  return (
    <div className="container mx-auto py-6 space-y-6">
      <div className="flex justify-between items-center">
        <h1 className="text-3xl font-bold tracking-tight">Journal Entries</h1>
      </div>

      {unpostedCount > 0 && (
        <Alert>
          <AlertTriangle className="h-4 w-4" />
          <AlertTitle>{unpostedCount} transactions are unposted</AlertTitle>
          <AlertDescription className="flex items-center justify-between gap-4">
            <span>Income, expense, bank or petty-cash rows without a journal entry yet.</span>
            <Button onClick={postAll} disabled={posting}>
              {posting && <Loader2 className="mr-2 h-4 w-4 animate-spin" />}
              Post all to Journal
            </Button>
          </AlertDescription>
        </Alert>
      )}

      <Card>
        <CardHeader>
          <CardTitle>Recent Entries ({entries.length})</CardTitle>
        </CardHeader>
        <CardContent>
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead className="w-8"></TableHead>
                <TableHead>Date</TableHead>
                <TableHead>Description</TableHead>
                <TableHead>Type</TableHead>
                <TableHead>Reference</TableHead>
                <TableHead>Status</TableHead>
                <TableHead className="text-right">Total</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {loading ? (
                <TableRow><TableCell colSpan={7} className="text-center py-10">Loading journal…</TableCell></TableRow>
              ) : entries.length === 0 ? (
                <TableRow><TableCell colSpan={7} className="text-center py-10 text-muted-foreground">No journal entries yet.</TableCell></TableRow>
              ) : (
                entries.map((entry) => {
                  const total = (entry.lines || []).reduce((s, l) => s + Number(l.debit || 0), 0);
                  const isOpen = !!expanded[entry.id];
                  return (
                    <Collapsible key={entry.id} asChild open={isOpen} onOpenChange={(o) => setExpanded(s => ({ ...s, [entry.id]: o }))}>
                      <>
                        <TableRow>
                          <TableCell>
                            <CollapsibleTrigger asChild>
                              <Button variant="ghost" size="icon" className="h-6 w-6">
                                {isOpen ? <ChevronDown className="h-4 w-4" /> : <ChevronRight className="h-4 w-4" />}
                              </Button>
                            </CollapsibleTrigger>
                          </TableCell>
                          <TableCell>{entry.entry_date ? format(new Date(entry.entry_date), "dd/MM/yyyy") : "—"}</TableCell>
                          <TableCell className="font-medium">{entry.description}</TableCell>
                          <TableCell><Badge variant="secondary" className="capitalize">{entry.entry_type}</Badge></TableCell>
                          <TableCell className="font-mono text-xs">{entry.reference || "—"}</TableCell>
                          <TableCell>
                            {entry.posted ? (
                              <Badge className="bg-green-100 text-green-800 hover:bg-green-100 border-none">Posted</Badge>
                            ) : (
                              <Badge variant="outline">Draft</Badge>
                            )}
                          </TableCell>
                          <TableCell className="text-right font-mono">{fmt(total)}</TableCell>
                        </TableRow>
                        <CollapsibleContent asChild>
                          <TableRow>
                            <TableCell colSpan={7} className="bg-muted/30">
                              <Table>
                                <TableHeader>
                                  <TableRow>
                                    <TableHead>Account</TableHead>
                                    <TableHead>Memo</TableHead>
                                    <TableHead className="text-right">Debit</TableHead>
                                    <TableHead className="text-right">Credit</TableHead>
                                  </TableRow>
                                </TableHeader>
                                <TableBody>
                                  {(entry.lines || []).map(l => {
                                    const a = accountById.get(l.account_id);
                                    return (
                                      <TableRow key={l.id}>
                                        <TableCell>{a ? `${a.code} — ${a.name}` : l.account_id}</TableCell>
                                        <TableCell className="text-muted-foreground">{l.memo || ""}</TableCell>
                                        <TableCell className="text-right font-mono">{l.debit ? fmt(l.debit) : ""}</TableCell>
                                        <TableCell className="text-right font-mono">{l.credit ? fmt(l.credit) : ""}</TableCell>
                                      </TableRow>
                                    );
                                  })}
                                  <TableRow className="font-semibold border-t-2">
                                    <TableCell colSpan={2}>Totals</TableCell>
                                    <TableCell className="text-right font-mono">{fmt((entry.lines || []).reduce((s, l) => s + Number(l.debit || 0), 0))}</TableCell>
                                    <TableCell className="text-right font-mono">{fmt((entry.lines || []).reduce((s, l) => s + Number(l.credit || 0), 0))}</TableCell>
                                  </TableRow>
                                </TableBody>
                              </Table>
                            </TableCell>
                          </TableRow>
                        </CollapsibleContent>
                      </>
                    </Collapsible>
                  );
                })
              )}
            </TableBody>
          </Table>
        </CardContent>
      </Card>
    </div>
  );
}
