import { useEffect, useState } from "react";
import { supabase } from "@/integrations/supabase/client";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { useToast } from "@/hooks/use-toast";
import { RefreshCw, Send } from "lucide-react";

const fmt = (n: number) => new Intl.NumberFormat("pt-MZ", { minimumFractionDigits: 2 }).format(n || 0);

type Reval = {
  id: string; year: number; month: number; currency: string;
  rate_used: number; total_adjustment: number; posted: boolean;
};

export default function FxRevaluation() {
  const today = new Date();
  const [year, setYear] = useState(today.getFullYear());
  const [month, setMonth] = useState(today.getMonth() + 1);
  const [currency, setCurrency] = useState("USD");
  const [rate, setRate] = useState(0);
  const [adjustment, setAdjustment] = useState(0);
  const [history, setHistory] = useState<Reval[]>([]);
  const { toast } = useToast();

  async function loadHistory() {
    const { data } = await supabase.from("fx_revaluations").select("*").order("year", { ascending: false }).order("month", { ascending: false });
    setHistory((data as Reval[]) || []);
  }
  useEffect(() => { loadHistory(); }, []);

  async function loadRate() {
    const { data } = await supabase.from("exchange_rates").select("*").eq("year", year).eq("month", month).maybeSingle();
    if (!data) { setRate(0); return toast({ title: "No rate", description: `No exchange rate for ${year}-${month}`, variant: "destructive" }); }
    setRate(currency === "USD" ? data.mzn_per_usd : (data.mzn_per_zar || 0));
  }

  async function postReval() {
    if (!rate || !adjustment) return toast({ title: "Missing", description: "Rate and adjustment amount required", variant: "destructive" });
    // 1. Create journal entry: gain or loss
    const acctCode = adjustment >= 0 ? "7811" : "6811"; // FX gain / FX loss
    const cashCode = currency === "USD" ? "1112" : "1113"; // FX cash sub-accounts (or fall to suspense)
    const accId = await supabase.rpc("fn_account_or_suspense", { _code: acctCode });
    const cashId = await supabase.rpc("fn_account_or_suspense", { _code: cashCode });
    const { data: je, error } = await supabase.from("journal_entries").insert({
      entry_date: `${year}-${String(month).padStart(2, "0")}-28`,
      description: `FX revaluation ${currency} @ ${rate}`,
      entry_type: "fx_revaluation", reference: `${year}-${month}-${currency}`,
      posted: true, posted_at: new Date().toISOString(),
      source_table: "fx_revaluations",
    }).select().single();
    if (error) return toast({ title: "Failed", description: error.message, variant: "destructive" });

    const amt = Math.abs(adjustment);
    const lines = adjustment >= 0
      ? [{ journal_entry_id: je.id, account_id: cashId.data, debit: amt, credit: 0, memo: "FX gain on cash" },
         { journal_entry_id: je.id, account_id: accId.data, debit: 0, credit: amt, memo: "FX gain" }]
      : [{ journal_entry_id: je.id, account_id: accId.data, debit: amt, credit: 0, memo: "FX loss" },
         { journal_entry_id: je.id, account_id: cashId.data, debit: 0, credit: amt, memo: "FX loss on cash" }];
    const { error: lineErr } = await supabase.from("journal_lines").insert(lines);
    if (lineErr) return toast({ title: "Lines failed", description: lineErr.message, variant: "destructive" });

    await supabase.from("fx_revaluations").upsert({
      year, month, currency, rate_used: rate, total_adjustment: adjustment,
      journal_entry_id: je.id, posted: true, posted_at: new Date().toISOString(),
    } as any, { onConflict: "year,month,currency" });

    toast({ title: "FX revaluation posted", description: `${currency} ${fmt(adjustment)} adjustment` });
    setAdjustment(0);
    loadHistory();
  }

  return (
    <div className="space-y-4 p-6">
      <h1 className="text-2xl font-bold">FX Revaluation (Month-end)</h1>

      <Card>
        <CardHeader><CardTitle>Post adjustment</CardTitle></CardHeader>
        <CardContent className="grid grid-cols-2 md:grid-cols-6 gap-3 items-end">
          <div><Label>Year</Label><Input type="number" value={year} onChange={(e) => setYear(+e.target.value)} /></div>
          <div><Label>Month</Label><Input type="number" min={1} max={12} value={month} onChange={(e) => setMonth(+e.target.value)} /></div>
          <div>
            <Label>Currency</Label>
            <Select value={currency} onValueChange={setCurrency}>
              <SelectTrigger><SelectValue /></SelectTrigger>
              <SelectContent>
                <SelectItem value="USD">USD</SelectItem><SelectItem value="ZAR">ZAR</SelectItem>
              </SelectContent>
            </Select>
          </div>
          <div className="flex gap-2">
            <div className="flex-1"><Label>Rate (MZN per 1)</Label><Input type="number" step="0.0001" value={rate} onChange={(e) => setRate(+e.target.value)} /></div>
            <Button variant="outline" size="icon" className="self-end" onClick={loadRate}><RefreshCw className="h-4 w-4" /></Button>
          </div>
          <div><Label>Adjustment (MZN, +gain/-loss)</Label><Input type="number" step="0.01" value={adjustment} onChange={(e) => setAdjustment(+e.target.value)} /></div>
          <Button onClick={postReval}><Send className="h-4 w-4 mr-2" />Post</Button>
        </CardContent>
      </Card>

      <Card>
        <CardHeader><CardTitle>History</CardTitle></CardHeader>
        <CardContent>
          <Table>
            <TableHeader><TableRow>
              <TableHead>Period</TableHead><TableHead>Currency</TableHead>
              <TableHead className="text-right">Rate</TableHead>
              <TableHead className="text-right">Adjustment (MZN)</TableHead>
              <TableHead>Status</TableHead>
            </TableRow></TableHeader>
            <TableBody>
              {history.map(h => (
                <TableRow key={h.id}>
                  <TableCell>{h.year}-{String(h.month).padStart(2, "0")}</TableCell>
                  <TableCell>{h.currency}</TableCell>
                  <TableCell className="text-right">{fmt(h.rate_used)}</TableCell>
                  <TableCell className={"text-right " + (h.total_adjustment >= 0 ? "text-green-600" : "text-red-600")}>{fmt(h.total_adjustment)}</TableCell>
                  <TableCell>{h.posted ? "Posted" : "Draft"}</TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </CardContent>
      </Card>
    </div>
  );
}
