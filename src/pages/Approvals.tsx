import { useEffect, useState } from "react";
import { supabase } from "@/integrations/supabase/client";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { useToast } from "@/hooks/use-toast";
import { Check, X } from "lucide-react";
import { HelpPopover } from "@/components/HelpPopover";

const fmt = (n: number) => new Intl.NumberFormat("pt-MZ", { minimumFractionDigits: 2 }).format(n || 0);

type PendingExp = {
  id: string; date: string; description: string; amount_mzn: number;
  property_id: string | null; category_id: string | null;
};

export default function Approvals() {
  const [items, setItems] = useState<PendingExp[]>([]);
  const [threshold, setThreshold] = useState<number>(50000);
  const { toast } = useToast();

  async function load() {
    const [{ data: pend }, { data: cs }] = await Promise.all([
      supabase.from("expense_transactions").select("id,date,description,amount_mzn,property_id,category_id").eq("approval_status", "pending").order("date"),
      supabase.from("company_settings").select("approval_threshold_mzn").maybeSingle(),
    ]);
    setItems((pend as PendingExp[]) || []);
    setThreshold(Number((cs as any)?.approval_threshold_mzn ?? 50000));
  }
  useEffect(() => { load(); }, []);

  async function approve(id: string) {
    const { error } = await supabase.rpc("fn_approve_expense", { _id: id });
    if (error) return toast({ title: "Approve failed", description: error.message, variant: "destructive" });
    toast({ title: "Approved & posted" });
    load();
  }
  async function reject(id: string) {
    const { error } = await supabase.rpc("fn_reject_expense", { _id: id, _reason: "" });
    if (error) return toast({ title: "Reject failed", description: error.message, variant: "destructive" });
    toast({ title: "Rejected" });
    load();
  }

  return (
    <div className="space-y-4 p-6">
      <div className="flex items-center gap-2"><h1 className="text-2xl font-bold">Approval Queue</h1><HelpPopover route="/accounting/approvals" size={18} /></div>
      <Card>
        <CardHeader>
          <CardTitle>Pending expenses (≥ MZN {fmt(threshold)}) — {items.length} item(s)</CardTitle>
        </CardHeader>
        <CardContent>
          <Table>
            <TableHeader><TableRow>
              <TableHead>Date</TableHead><TableHead>Description</TableHead>
              <TableHead className="text-right">Amount (MZN)</TableHead><TableHead>Action</TableHead>
            </TableRow></TableHeader>
            <TableBody>
              {items.map(e => (
                <TableRow key={e.id}>
                  <TableCell>{e.date}</TableCell>
                  <TableCell>{e.description}</TableCell>
                  <TableCell className="text-right">{fmt(e.amount_mzn)}</TableCell>
                  <TableCell>
                    <Button size="sm" onClick={() => approve(e.id)} className="mr-2"><Check className="h-4 w-4 mr-1" />Approve</Button>
                    <Button size="sm" variant="destructive" onClick={() => reject(e.id)}><X className="h-4 w-4 mr-1" />Reject</Button>
                  </TableCell>
                </TableRow>
              ))}
              {items.length === 0 && <TableRow><TableCell colSpan={4} className="text-center text-muted-foreground">No pending approvals.</TableCell></TableRow>}
            </TableBody>
          </Table>
        </CardContent>
      </Card>
    </div>
  );
}
