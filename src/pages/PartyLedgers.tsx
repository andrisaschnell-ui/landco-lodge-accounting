import { useEffect, useMemo, useState } from "react";
import { supabase as supabaseTyped } from "@/integrations/supabase/client";
const supabase: any = supabaseTyped;
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Button } from "@/components/ui/button";
import { Loader2, FileDown, FileSpreadsheet } from "lucide-react";
import { format, differenceInDays } from "date-fns";
import { exportToPdf, exportToExcel, Column } from "@/lib/exportUtils";
import { fmtMoney } from "@/lib/statements";

type Bucket = "current" | "1-30" | "31-60" | "61-90" | "90+";
const BUCKETS: Bucket[] = ["current", "1-30", "31-60", "61-90", "90+"];

function bucketOf(daysOverdue: number): Bucket {
  if (daysOverdue <= 0) return "current";
  if (daysOverdue <= 30) return "1-30";
  if (daysOverdue <= 60) return "31-60";
  if (daysOverdue <= 90) return "61-90";
  return "90+";
}

export default function PartyLedgers() {
  return (
    <div className="container mx-auto py-6 space-y-6">
      <h1 className="text-3xl font-bold tracking-tight">Customer & Supplier Ledgers</h1>
      <Tabs defaultValue="customers">
        <TabsList>
          <TabsTrigger value="customers">Customers</TabsTrigger>
          <TabsTrigger value="suppliers">Suppliers</TabsTrigger>
        </TabsList>
        <TabsContent value="customers" className="mt-4"><CustomerLedger /></TabsContent>
        <TabsContent value="suppliers" className="mt-4"><SupplierLedger /></TabsContent>
      </Tabs>
    </div>
  );
}

function CustomerLedger() {
  const [rows, setRows] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const today = new Date();

  useEffect(() => {
    (async () => {
      const { data } = await supabase
        .from("invoices")
        .select("id, invoice_number, invoice_date, due_date, client_name, client_nuit, total_mzn, paid_amount, status")
        .order("invoice_date", { ascending: false });
      setRows(data || []);
      setLoading(false);
    })();
  }, []);

  const enriched = useMemo(() => rows.map(r => {
    const outstanding = Number(r.total_mzn || 0) - Number(r.paid_amount || 0);
    const dueDate = r.due_date ? new Date(r.due_date) : (r.invoice_date ? new Date(r.invoice_date) : null);
    const daysOver = dueDate ? differenceInDays(today, dueDate) : 0;
    return { ...r, outstanding, daysOver, bucket: outstanding > 0.005 ? bucketOf(daysOver) : "paid" };
  }), [rows]);

  const grouped = useMemo(() => {
    const m = new Map<string, { name: string; nuit: string; invoices: any[]; totals: Record<Bucket, number>; outstanding: number }>();
    for (const r of enriched) {
      const key = (r.client_name || "Unknown") + "|" + (r.client_nuit || "");
      let g = m.get(key);
      if (!g) {
        g = { name: r.client_name || "Unknown", nuit: r.client_nuit || "", invoices: [], outstanding: 0,
              totals: { "current":0, "1-30":0, "31-60":0, "61-90":0, "90+":0 } };
        m.set(key, g);
      }
      g.invoices.push(r);
      if (r.outstanding > 0.005) {
        g.outstanding += r.outstanding;
        g.totals[r.bucket as Bucket] += r.outstanding;
      }
    }
    return Array.from(m.values()).sort((a, b) => b.outstanding - a.outstanding);
  }, [enriched]);

  return <PartyView title="Customer Aging" parties={grouped} loading={loading} kind="customer" />;
}

function SupplierLedger() {
  const [rows, setRows] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const today = new Date();

  useEffect(() => {
    (async () => {
      const { data } = await supabase
        .from("supplier_invoices")
        .select("id, invoice_number, invoice_date, due_date, supplier_id, total_amount, paid_amount, status, suppliers(name)")
        .order("invoice_date", { ascending: false });
      setRows(data || []);
      setLoading(false);
    })();
  }, []);

  const enriched = useMemo(() => rows.map(r => {
    const outstanding = Number(r.total_amount || 0) - Number(r.paid_amount || 0);
    const dueDate = r.due_date ? new Date(r.due_date) : (r.invoice_date ? new Date(r.invoice_date) : null);
    const daysOver = dueDate ? differenceInDays(today, dueDate) : 0;
    return { ...r, outstanding, daysOver, bucket: outstanding > 0.005 ? bucketOf(daysOver) : "paid", supplier_name: r.suppliers?.name || "Unknown" };
  }), [rows]);

  const grouped = useMemo(() => {
    const m = new Map<string, { name: string; nuit: string; invoices: any[]; totals: Record<Bucket, number>; outstanding: number }>();
    for (const r of enriched) {
      const key = r.supplier_name;
      let g = m.get(key);
      if (!g) {
        g = { name: r.supplier_name, nuit: "", invoices: [], outstanding: 0,
              totals: { "current":0, "1-30":0, "31-60":0, "61-90":0, "90+":0 } };
        m.set(key, g);
      }
      g.invoices.push(r);
      if (r.outstanding > 0.005) {
        g.outstanding += r.outstanding;
        g.totals[r.bucket as Bucket] += r.outstanding;
      }
    }
    return Array.from(m.values()).sort((a, b) => b.outstanding - a.outstanding);
  }, [enriched]);

  return <PartyView title="Supplier Aging" parties={grouped} loading={loading} kind="supplier" />;
}

function PartyView({ title, parties, loading, kind }: any) {
  const totals: Record<Bucket, number> = { "current":0, "1-30":0, "31-60":0, "61-90":0, "90+":0 };
  let grandOutstanding = 0;
  parties.forEach((p: any) => {
    BUCKETS.forEach(b => totals[b] += p.totals[b]);
    grandOutstanding += p.outstanding;
  });

  const cols: Column[] = [
    { header: kind === "supplier" ? "Supplier" : "Customer", key: "name" },
    { header: "Current", key: "current", align: "right" },
    { header: "1-30 days", key: "b1", align: "right" },
    { header: "31-60 days", key: "b2", align: "right" },
    { header: "61-90 days", key: "b3", align: "right" },
    { header: "90+ days", key: "b4", align: "right" },
    { header: "Outstanding", key: "outstanding", align: "right" },
  ];
  const exportRows = parties.map((p: any) => ({
    name: p.name,
    current: p.totals.current, b1: p.totals["1-30"], b2: p.totals["31-60"], b3: p.totals["61-90"], b4: p.totals["90+"],
    outstanding: p.outstanding,
  }));
  exportRows.push({
    name: "TOTAL",
    current: totals.current, b1: totals["1-30"], b2: totals["31-60"], b3: totals["61-90"], b4: totals["90+"],
    outstanding: grandOutstanding,
  });

  return (
    <Card>
      <CardHeader className="flex flex-row items-center justify-between">
        <CardTitle>{title}</CardTitle>
        <div className="flex gap-2">
          <Button variant="outline" size="sm" onClick={() => exportToPdf({ title, columns: cols, rows: exportRows, filename: title.toLowerCase().replace(/ /g,"_") })}>
            <FileDown className="mr-1 h-4 w-4" /> PDF
          </Button>
          <Button variant="outline" size="sm" onClick={() => exportToExcel({ sheetName: title, columns: cols, rows: exportRows, filename: title.toLowerCase().replace(/ /g,"_") })}>
            <FileSpreadsheet className="mr-1 h-4 w-4" /> Excel
          </Button>
        </div>
      </CardHeader>
      <CardContent>
        {loading ? (
          <div className="flex items-center justify-center py-10 text-muted-foreground"><Loader2 className="mr-2 h-4 w-4 animate-spin" /> Loading…</div>
        ) : parties.length === 0 ? (
          <p className="text-muted-foreground py-8 text-center">No invoices recorded yet.</p>
        ) : (
          <>
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>{kind === "supplier" ? "Supplier" : "Customer"}</TableHead>
                  <TableHead className="text-right">Current</TableHead>
                  <TableHead className="text-right">1-30</TableHead>
                  <TableHead className="text-right">31-60</TableHead>
                  <TableHead className="text-right">61-90</TableHead>
                  <TableHead className="text-right">90+</TableHead>
                  <TableHead className="text-right">Outstanding</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {parties.map((p: any, i: number) => (
                  <PartyRow key={i} p={p} />
                ))}
                <TableRow className="font-bold bg-primary/5 border-t-2">
                  <TableCell>TOTAL</TableCell>
                  <TableCell className="text-right font-mono">{fmtMoney(totals.current)}</TableCell>
                  <TableCell className="text-right font-mono">{fmtMoney(totals["1-30"])}</TableCell>
                  <TableCell className="text-right font-mono">{fmtMoney(totals["31-60"])}</TableCell>
                  <TableCell className="text-right font-mono">{fmtMoney(totals["61-90"])}</TableCell>
                  <TableCell className="text-right font-mono text-red-600">{fmtMoney(totals["90+"])}</TableCell>
                  <TableCell className="text-right font-mono">{fmtMoney(grandOutstanding)}</TableCell>
                </TableRow>
              </TableBody>
            </Table>
          </>
        )}
      </CardContent>
    </Card>
  );
}

function PartyRow({ p }: { p: any }) {
  const [open, setOpen] = useState(false);
  return (
    <>
      <TableRow className="cursor-pointer hover:bg-muted/30" onClick={() => setOpen(!open)}>
        <TableCell className="font-medium">{open ? "▼" : "▶"} {p.name}</TableCell>
        <TableCell className="text-right font-mono">{fmtMoney(p.totals.current)}</TableCell>
        <TableCell className="text-right font-mono">{fmtMoney(p.totals["1-30"])}</TableCell>
        <TableCell className="text-right font-mono">{fmtMoney(p.totals["31-60"])}</TableCell>
        <TableCell className="text-right font-mono">{fmtMoney(p.totals["61-90"])}</TableCell>
        <TableCell className="text-right font-mono text-red-600">{fmtMoney(p.totals["90+"])}</TableCell>
        <TableCell className="text-right font-mono font-semibold">{fmtMoney(p.outstanding)}</TableCell>
      </TableRow>
      {open && (
        <TableRow>
          <TableCell colSpan={7} className="bg-muted/20 p-0">
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Invoice #</TableHead>
                  <TableHead>Date</TableHead>
                  <TableHead>Due</TableHead>
                  <TableHead className="text-right">Total</TableHead>
                  <TableHead className="text-right">Paid</TableHead>
                  <TableHead className="text-right">Outstanding</TableHead>
                  <TableHead className="text-right">Days</TableHead>
                  <TableHead>Status</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {p.invoices.map((inv: any) => (
                  <TableRow key={inv.id}>
                    <TableCell className="font-mono text-xs">{inv.invoice_number || inv.id.slice(0,8)}</TableCell>
                    <TableCell>{inv.invoice_date ? format(new Date(inv.invoice_date), "dd/MM/yyyy") : "—"}</TableCell>
                    <TableCell>{inv.due_date ? format(new Date(inv.due_date), "dd/MM/yyyy") : "—"}</TableCell>
                    <TableCell className="text-right font-mono">{fmtMoney(Number(inv.total_mzn ?? inv.total_amount ?? 0))}</TableCell>
                    <TableCell className="text-right font-mono">{fmtMoney(Number(inv.paid_amount || 0))}</TableCell>
                    <TableCell className="text-right font-mono font-semibold">{fmtMoney(inv.outstanding)}</TableCell>
                    <TableCell className={`text-right text-xs ${inv.daysOver > 0 ? "text-red-600" : "text-muted-foreground"}`}>
                      {inv.outstanding > 0.005 ? (inv.daysOver > 0 ? `+${inv.daysOver}` : inv.daysOver) : "—"}
                    </TableCell>
                    <TableCell className="text-xs capitalize">{inv.outstanding < 0.005 ? "paid" : (inv.status || "open")}</TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          </TableCell>
        </TableRow>
      )}
    </>
  );
}
