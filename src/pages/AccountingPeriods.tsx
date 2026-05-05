import { useEffect, useState } from "react";
import { supabase as supabaseTyped } from "@/integrations/supabase/client";
const supabase: any = supabaseTyped;
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Badge } from "@/components/ui/badge";
import { Lock, Unlock, Loader2 } from "lucide-react";
import { toast } from "sonner";

const MONTHS = [
  "January","February","March","April","May","June",
  "July","August","September","October","November","December",
];

export default function AccountingPeriods() {
  const [periods, setPeriods] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [busy, setBusy] = useState<string | null>(null);
  const [year, setYear] = useState(new Date().getFullYear());

  const load = async () => {
    setLoading(true);
    const { data } = await db.from("accounting_periods").select("*").eq("year", year).order("month");
    setPeriods(data || []);
    setLoading(false);
  };

  useEffect(() => { load(); }, [year]);

  // Ensure 12 rows for the year
  const byMonth = new Map<number, any>();
  periods.forEach(p => byMonth.set(p.month, p));

  const toggle = async (month: number, current: boolean) => {
    setBusy(`${year}-${month}`);
    const existing = byMonth.get(month);
    try {
      if (existing) {
        const { error } = await supabase
          .from("accounting_periods")
          .update({ is_closed: !current, closed_at: !current ? new Date().toISOString() : null })
          .eq("id", existing.id);
        if (error) throw error;
      } else {
        const { error } = await supabase
          .from("accounting_periods")
          .insert({ year, month, is_closed: true, closed_at: new Date().toISOString() });
        if (error) throw error;
      }
      toast.success(current ? `Reopened ${MONTHS[month-1]} ${year}` : `Closed ${MONTHS[month-1]} ${year}`);
      await load();
    } catch (e: any) {
      toast.error(e.message);
    } finally {
      setBusy(null);
    }
  };

  return (
    <div className="container mx-auto py-6 space-y-6">
      <div className="flex justify-between items-center">
        <h1 className="text-3xl font-bold tracking-tight">Accounting Periods</h1>
        <div className="flex items-center gap-2">
          <Button variant="outline" size="sm" onClick={() => setYear(year - 1)}>‹</Button>
          <span className="font-mono text-lg w-16 text-center">{year}</span>
          <Button variant="outline" size="sm" onClick={() => setYear(year + 1)}>›</Button>
        </div>
      </div>

      <Card>
        <CardHeader>
          <CardTitle>Close or reopen monthly periods</CardTitle>
          <CardDescription>
            Once a month is closed, no journal entries can be posted to dates in that month —
            for anyone, admins included. Reopen to post corrections.
          </CardDescription>
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
                  <TableHead className="w-[80px]">Month</TableHead>
                  <TableHead>Name</TableHead>
                  <TableHead>Status</TableHead>
                  <TableHead>Closed at</TableHead>
                  <TableHead className="text-right">Action</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {Array.from({ length: 12 }, (_, i) => i + 1).map(m => {
                  const p = byMonth.get(m);
                  const closed = !!p?.is_closed;
                  const id = `${year}-${m}`;
                  return (
                    <TableRow key={m}>
                      <TableCell className="font-mono">{String(m).padStart(2, "0")}</TableCell>
                      <TableCell>{MONTHS[m-1]}</TableCell>
                      <TableCell>
                        {closed
                          ? <Badge variant="destructive">Closed</Badge>
                          : <Badge variant="secondary">Open</Badge>}
                      </TableCell>
                      <TableCell className="text-muted-foreground text-sm">
                        {p?.closed_at ? new Date(p.closed_at).toLocaleString() : "—"}
                      </TableCell>
                      <TableCell className="text-right">
                        <Button
                          size="sm"
                          variant={closed ? "outline" : "default"}
                          disabled={busy === id}
                          onClick={() => toggle(m, closed)}
                        >
                          {busy === id
                            ? <Loader2 className="h-4 w-4 animate-spin" />
                            : closed
                              ? <><Unlock className="h-4 w-4 mr-1"/> Reopen</>
                              : <><Lock className="h-4 w-4 mr-1"/> Close</>}
                        </Button>
                      </TableCell>
                    </TableRow>
                  );
                })}
              </TableBody>
            </Table>
          )}
        </CardContent>
      </Card>
    </div>
  );
}
