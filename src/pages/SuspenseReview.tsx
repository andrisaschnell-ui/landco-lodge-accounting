import { useState } from "react";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { supabase as supabaseTyped } from "@/integrations/supabase/client";
const supabase: any = supabaseTyped;
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Button } from "@/components/ui/button";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogFooter, DialogDescription } from "@/components/ui/dialog";
import { useToast } from "@/hooks/use-toast";
import { Badge } from "@/components/ui/badge";

/**
 * Suspense Review — every expense/JE that was posted to account 262 (Suspense)
 * during import. Operator picks the real cash/bank/AP account and we re-post
 * the credit side of the JE so the trial balance stays clean.
 */
export default function SuspenseReview() {
  const { toast } = useToast();
  const queryClient = useQueryClient();
  const [selected, setSelected] = useState<any>(null);
  const [targetAccountId, setTargetAccountId] = useState<string>("");

  const { data: suspenseAccount } = useQuery({
    queryKey: ["account-262"],
    queryFn: async () => {
      const { data } = await db.from("accounts").select("id, code, name").eq("code", "262").maybeSingle();
      return data;
    },
  });

  const { data: lines, isLoading } = useQuery({
    queryKey: ["suspense-lines", suspenseAccount?.id],
    enabled: !!suspenseAccount?.id,
    queryFn: async () => {
      // Pull every journal_line that credits Suspense, with parent JE + linked supplier_invoice.
      const { data } = await supabase
        .from("journal_lines")
        .select(`
          id, debit, credit, memo,
          journal_entry:journal_entries!journal_lines_journal_entry_id_fkey(
            id, entry_date, description, entry_type, reference, posted
          )
        `)
        .eq("account_id", suspenseAccount!.id)
        .gt("credit", 0)
        .order("id", { ascending: false });
      return Array.isArray(data) ? data : [];
    },
  });

  const { data: cashAccounts } = useQuery({
    queryKey: ["cash-bank-ap-accounts"],
    queryFn: async () => {
      const { data } = await supabase
        .from("accounts")
        .select("id, code, name")
        .in("account_class", [1, 2])
        .order("code");
      return Array.isArray(data) ? data : [];
    },
  });

  const reclassify = useMutation({
    mutationFn: async ({ jlId, newAccountId }: { jlId: string; newAccountId: string }) => {
      const { error } = await supabase
        .from("journal_lines")
        .update({ account_id: newAccountId, memo: "Reclassified from Suspense" })
        .eq("id", jlId);
      if (error) throw error;
    },
    onSuccess: () => {
      toast({ title: "Reclassified", description: "Credit moved out of Suspense." });
      queryClient.invalidateQueries({ queryKey: ["suspense-lines"] });
      setSelected(null);
      setTargetAccountId("");
    },
    onError: (e: any) => toast({ title: "Failed", description: e.message, variant: "destructive" }),
  });

  return (
    <div className="space-y-6 p-6">
      <Card>
        <CardHeader>
          <CardTitle>Suspense Review</CardTitle>
          <CardDescription>
            Entries currently parked on account 262 (Conta Suspensa). Reassign each credit to the
            actual cash, bank or supplier account it should hit.
          </CardDescription>
        </CardHeader>
        <CardContent>
          {isLoading && <p className="text-muted-foreground">Loading…</p>}
          {!isLoading && lines?.length === 0 && (
            <p className="text-muted-foreground">No entries waiting on Suspense. 🎉</p>
          )}
          {lines && lines.length > 0 && (
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Date</TableHead>
                  <TableHead>Description</TableHead>
                  <TableHead>Type</TableHead>
                  <TableHead>Reference</TableHead>
                  <TableHead className="text-right">Amount (MZN)</TableHead>
                  <TableHead></TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {lines.map((l: any) => (
                  <TableRow key={l.id}>
                    <TableCell>{l.journal_entry?.entry_date}</TableCell>
                    <TableCell>{l.journal_entry?.description}</TableCell>
                    <TableCell>
                      <Badge variant="secondary">{l.journal_entry?.entry_type}</Badge>
                    </TableCell>
                    <TableCell className="text-muted-foreground text-xs">
                      {l.journal_entry?.reference}
                    </TableCell>
                    <TableCell className="text-right font-mono">
                      {Number(l.credit).toLocaleString("en-US", { minimumFractionDigits: 2 })}
                    </TableCell>
                    <TableCell>
                      <Button size="sm" onClick={() => setSelected(l)}>
                        Reclassify
                      </Button>
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          )}
        </CardContent>
      </Card>

      <Dialog open={!!selected} onOpenChange={(o) => !o && setSelected(null)}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Reclassify Suspense Entry</DialogTitle>
            <DialogDescription>
              {selected?.journal_entry?.description} —{" "}
              {Number(selected?.credit ?? 0).toLocaleString("en-US", { minimumFractionDigits: 2 })} MZN
            </DialogDescription>
          </DialogHeader>
          <div className="space-y-2">
            <label className="text-sm font-medium">Target account</label>
            <Select value={targetAccountId} onValueChange={setTargetAccountId}>
              <SelectTrigger>
                <SelectValue placeholder="Choose cash, bank or supplier account…" />
              </SelectTrigger>
              <SelectContent>
                {cashAccounts?.map((a: any) => (
                  <SelectItem key={a.id} value={a.id}>
                    {a.code} — {a.name}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
          </div>
          <DialogFooter>
            <Button variant="ghost" onClick={() => setSelected(null)}>Cancel</Button>
            <Button
              disabled={!targetAccountId || reclassify.isPending}
              onClick={() => reclassify.mutate({ jlId: selected.id, newAccountId: targetAccountId })}
            >
              {reclassify.isPending ? "Saving…" : "Reclassify"}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}
