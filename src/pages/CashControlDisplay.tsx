import { Link, useParams } from "react-router-dom";
import { useEffect, useMemo, useState } from "react";
import { supabase } from "@/integrations/supabase/client";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Dialog, DialogContent, DialogFooter, DialogHeader, DialogTitle, DialogTrigger } from "@/components/ui/dialog";
import { Download, ArrowLeft, Save, Plus, CalendarPlus } from "lucide-react";
import { DropdownListEditor } from "@/components/cash/DropdownListEditor";
import { ZoomControl } from "@/components/cash/ZoomControl";
import { exportCashSheetAsXlsx } from "@/lib/cashControlExport";
import { toast } from "@/hooks/use-toast";

type CashType = "petty_cash" | "cash_landco" | "emola" | "emola_two" | "mpesa" | "mpesa_two";

const TITLES: Record<CashType, string> = {
  petty_cash:  "Cash Display Ebony",
  cash_landco: "Cash Display Landco",
  emola:       "Emola One Display",
  emola_two:   "Emola Two Display",
  mpesa:       "Mpesa One Display",
  mpesa_two:   "Mpesa Two Display",
};

const CARD_LABELS: Record<CashType, string> = {
  petty_cash: "Cash Ebony", cash_landco: "Cash Landco",
  emola: "Emola One", emola_two: "Emola Two",
  mpesa: "Mpesa One", mpesa_two: "Mpesa Two",
};

const CASH_TYPES: CashType[] = ["petty_cash", "cash_landco", "emola", "emola_two", "mpesa", "mpesa_two"];
const isPettyLike = (t: CashType) => t === "petty_cash" || t === "cash_landco";
const isMpesaLike = (t: CashType) => t === "mpesa" || t === "mpesa_two";

interface Tx {
  id: string; row_no: number | null; tx_date: string | null; description: string | null;
  funder: string | null; receiver: string | null; cell_no: string | null;
  cheque_no: string | null; company: string | null;
  entrada: number | null; saida: number | null; bank_charges: number | null; balance: number | null;
  allocation_column: string | null; allocation_amount: number | null;
  allocations: Record<string, number> | null;
}

const fmt = (n: number | null | undefined) => n == null || n === 0 ? "" : n.toLocaleString(undefined, { maximumFractionDigits: 2 });

function PickerIndex() {
  return (
    <div className="space-y-6">
      <h1 className="text-3xl font-bold">Cash Control Display</h1>
      <p className="text-muted-foreground">Pick which sheet to view, edit, and download.</p>
      <div className="grid gap-4 md:grid-cols-3">
        {CASH_TYPES.map((t) => (
          <Link key={t} to={`/cash-control/display/${t}`}>
            <Card className="hover:shadow-md transition-shadow cursor-pointer">
              <CardHeader><CardTitle>{CARD_LABELS[t]}</CardTitle></CardHeader>
              <CardContent><p className="text-sm text-muted-foreground">Open {CARD_LABELS[t]} display</p></CardContent>
            </Card>
          </Link>
        ))}
      </div>
    </div>
  );
}

const MONTHS = [
  { v: 1, label: "Jan" }, { v: 2, label: "Feb" }, { v: 3, label: "Mar" }, { v: 4, label: "Apr" },
  { v: 5, label: "May" }, { v: 6, label: "Jun" }, { v: 7, label: "Jul" }, { v: 8, label: "Aug" },
  { v: 9, label: "Sep" }, { v: 10, label: "Oct" }, { v: 11, label: "Nov" }, { v: 12, label: "Dec" },
];

function SheetDisplay({ sheetType }: { sheetType: CashType }) {
  const [periods, setPeriods] = useState<{ id: string; month: number | null; year: number; opening_balance: number }[]>([]);
  const [sheetId, setSheetId] = useState<string>("");
  const [allocCols, setAllocCols] = useState<string[]>([]);
  const [newAllocCol, setNewAllocCol] = useState("");
  const [txs, setTxs] = useState<Tx[]>([]);
  const [dirty, setDirty] = useState<Record<string, Partial<Tx>>>({});

  // Cascade-derived opening (read-only for non-Jan months)
  const [derivedOpening, setDerivedOpening] = useState<number | null>(null);
  // Local-edit state for January opening
  const [janOpeningInput, setJanOpeningInput] = useState<string>("");

  // Add-period dialog state
  const [addOpen, setAddOpen] = useState(false);
  const [newYear, setNewYear] = useState<number>(new Date().getFullYear());
  const [newMonth, setNewMonth] = useState<number>(1);
  const [newOpening, setNewOpening] = useState<string>("0");

  const selected = periods.find((p) => p.id === sheetId);
  const isJanuary = selected?.month === 1;

  // Load periods
  const loadPeriods = async () => {
    const { data } = await supabase
      .from("cash_sheets")
      .select("id, month, year, opening_balance")
      .eq("sheet_type", sheetType)
      .order("year", { ascending: false })
      .order("month", { ascending: false });
    setPeriods(data ?? []);
    return data ?? [];
  };

  useEffect(() => {
    (async () => {
      const data = await loadPeriods();
      if (data.length && !sheetId) setSheetId(data[0].id);
    })();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [sheetType]);

  // Load allocation columns
  const loadAllocCols = async () => {
    const { data } = await supabase
      .from("cash_allocation_columns")
      .select("column_name")
      .eq("sheet_type", sheetType)
      .order("sort_order", { ascending: true });
    setAllocCols((data ?? []).map((d) => d.column_name));
  };
  useEffect(() => { loadAllocCols(); }, [sheetType]);

  // Load transactions
  useEffect(() => {
    if (!sheetId) { setTxs([]); return; }
    (async () => {
      const { data } = await supabase
        .from("cash_transactions")
        .select("*")
        .eq("sheet_id", sheetId)
        .order("tx_date", { ascending: true })
        .order("row_no", { ascending: true });
      setTxs((data ?? []) as Tx[]);
      setDirty({});
    })();
  }, [sheetId]);

  // Compute derived opening for the selected period: previous month's closing balance
  useEffect(() => {
    if (!selected) { setDerivedOpening(null); return; }
    setJanOpeningInput(String(selected.opening_balance ?? 0));
    if (selected.month === 1 || selected.month == null) {
      setDerivedOpening(null);
      return;
    }
    (async () => {
      // Look up previous month's sheet (rolling over years)
      const prevMonth = selected.month! - 1;
      const prevYear  = selected.year;
      const { data: prevSheet } = await supabase
        .from("cash_sheets")
        .select("id, opening_balance")
        .eq("sheet_type", sheetType)
        .eq("year", prevYear)
        .eq("month", prevMonth)
        .maybeSingle();
      if (!prevSheet) { setDerivedOpening(null); return; }
      const { data: prevTxs } = await supabase
        .from("cash_transactions")
        .select("entrada, saida, bank_charges")
        .eq("sheet_id", prevSheet.id);
      const closing = (prevSheet.opening_balance ?? 0) + (prevTxs ?? []).reduce(
        (acc, r) => acc + (Number(r.entrada) || 0) - (Number(r.saida) || 0) - (Number(r.bank_charges) || 0),
        0,
      );
      setDerivedOpening(closing);
    })();
  }, [selected, sheetType]);

  // Effective opening to display + use for the running balance
  const effectiveOpening = useMemo(() => {
    if (!selected) return 0;
    if (selected.month === 1 || selected.month == null) return Number(selected.opening_balance ?? 0);
    return derivedOpening ?? Number(selected.opening_balance ?? 0);
  }, [selected, derivedOpening]);

  // Client-side running balance
  const withBalance = useMemo(() => {
    let bal = effectiveOpening;
    return txs.map((t) => {
      bal = bal + (Number(t.entrada) || 0) - (Number(t.saida) || 0) - (Number(t.bank_charges) || 0);
      return { ...t, _balance: bal };
    });
  }, [txs, effectiveOpening]);

  const updateLocal = (id: string, patch: Partial<Tx>) => {
    setTxs((prev) => prev.map((t) => (t.id === id ? { ...t, ...patch } : t)));
    setDirty((d) => ({ ...d, [id]: { ...(d[id] ?? {}), ...patch } }));
  };

  const saveAll = async () => {
    const ids = Object.keys(dirty);
    if (ids.length === 0) { toast({ title: "Nothing to save" }); return; }
    for (const id of ids) {
      const patch = dirty[id];
      const { error } = await supabase.from("cash_transactions").update(patch).eq("id", id);
      if (error) { toast({ title: "Save failed", description: error.message, variant: "destructive" }); return; }
    }
    toast({ title: "Saved", description: `${ids.length} rows updated` });
    setDirty({});
  };

  const saveJanOpening = async () => {
    if (!selected || !isJanuary) return;
    const val = Number(janOpeningInput);
    if (Number.isNaN(val)) { toast({ title: "Invalid number", variant: "destructive" }); return; }
    const { error } = await supabase.from("cash_sheets").update({ opening_balance: val }).eq("id", selected.id);
    if (error) { toast({ title: "Save failed", description: error.message, variant: "destructive" }); return; }
    toast({ title: "Opening saved" });
    await loadPeriods();
  };

  const addAllocCol = async () => {
    const v = newAllocCol.trim();
    if (!v) return;
    const { error } = await supabase.from("cash_allocation_columns").insert({ sheet_type: sheetType, column_name: v, sort_order: allocCols.length });
    if (error) { toast({ title: "Add failed", description: error.message, variant: "destructive" }); return; }
    setNewAllocCol("");
    loadAllocCols();
  };

  const addTransaction = async () => {
    if (!selected) { toast({ title: "Pick a period first" }); return; }
    const nextRowNo = (txs.reduce((m, t) => Math.max(m, t.row_no ?? 0), 0)) + 1;
    const { data, error } = await supabase.from("cash_transactions").insert({
      sheet_id: selected.id,
      sheet_type: sheetType,
      row_no: nextRowNo,
      month: selected.month ?? 1,
      year: selected.year,
      tx_date: null,
      description: "",
      entrada: 0,
      saida: 0,
      bank_charges: 0,
      allocations: {},
    }).select("*").single();
    if (error) { toast({ title: "Add row failed", description: error.message, variant: "destructive" }); return; }
    setTxs((prev) => [...prev, data as Tx]);
    toast({ title: "Row added" });
  };

  const addPeriod = async () => {
    // Pre-compute opening if a previous month exists
    let opening = Number(newOpening) || 0;
    if (newMonth > 1) {
      const { data: prev } = await supabase
        .from("cash_sheets")
        .select("id, opening_balance")
        .eq("sheet_type", sheetType)
        .eq("year", newYear)
        .eq("month", newMonth - 1)
        .maybeSingle();
      if (prev) {
        const { data: prevTxs } = await supabase
          .from("cash_transactions")
          .select("entrada, saida, bank_charges")
          .eq("sheet_id", prev.id);
        opening = (prev.opening_balance ?? 0) + (prevTxs ?? []).reduce(
          (acc, r) => acc + (Number(r.entrada) || 0) - (Number(r.saida) || 0) - (Number(r.bank_charges) || 0),
          0,
        );
      }
    }
    const { data, error } = await supabase
      .from("cash_sheets")
      .insert({ sheet_type: sheetType, year: newYear, month: newMonth, opening_balance: opening })
      .select("id, month, year, opening_balance")
      .single();
    if (error) { toast({ title: "Create failed", description: error.message, variant: "destructive" }); return; }
    toast({ title: "Period created" });
    setAddOpen(false);
    setNewOpening("0");
    await loadPeriods();
    setSheetId(data.id);
  };

  const doExport = () => {
    if (!selected) return;
    exportCashSheetAsXlsx({
      sheet_type: sheetType,
      title: TITLES[sheetType],
      month: selected.month,
      year: selected.year,
      opening_balance: effectiveOpening,
      allocation_columns: allocCols,
      transactions: txs,
    });
  };
  const [zoom, setZoom] = useState<number>(100);

  return (
    <div className="relative">
      {/* Sticky top region: toolbar + opening-balance card + table-controls row */}
      <div className="sticky top-0 z-30 -mx-2 bg-background/95 px-2 pb-2 pt-1 backdrop-blur supports-[backdrop-filter]:bg-background/80 border-b">
        <div className="flex items-center justify-between flex-wrap gap-3 py-2">
          <div className="flex items-center gap-3">
            <Button variant="ghost" size="sm" asChild><Link to="/cash-control"><ArrowLeft className="h-4 w-4 mr-1" />Back</Link></Button>
            <h1 className="text-2xl font-bold">{TITLES[sheetType]}</h1>
          </div>
          <div className="flex items-center gap-2">
            <Select
              value={sheetId}
              onValueChange={(v) => { if (v === "__add__") { setAddOpen(true); } else { setSheetId(v); } }}
            >
              <SelectTrigger className="w-[220px]"><SelectValue placeholder="Select period" /></SelectTrigger>
              <SelectContent>
                {periods.map((p) => (
                  <SelectItem key={p.id} value={p.id}>
                    {p.month ? `${String(p.month).padStart(2, "0")}/` : ""}{p.year}
                  </SelectItem>
                ))}
                <SelectItem value="__add__">➕ Add period…</SelectItem>
              </SelectContent>
            </Select>

            <Dialog open={addOpen} onOpenChange={setAddOpen}>
              <DialogTrigger asChild>
                <Button variant="outline" size="sm"><CalendarPlus className="h-4 w-4 mr-1" />New period</Button>
              </DialogTrigger>
              <DialogContent>
                <DialogHeader><DialogTitle>Add new period</DialogTitle></DialogHeader>
                <div className="grid grid-cols-2 gap-3">
                  <div className="space-y-1">
                    <Label>Year</Label>
                    <Input type="number" value={newYear} onChange={(e) => setNewYear(Number(e.target.value))} />
                  </div>
                  <div className="space-y-1">
                    <Label>Month</Label>
                    <Select value={String(newMonth)} onValueChange={(v) => setNewMonth(Number(v))}>
                      <SelectTrigger><SelectValue /></SelectTrigger>
                      <SelectContent>
                        {MONTHS.map((m) => <SelectItem key={m.v} value={String(m.v)}>{String(m.v).padStart(2, "0")} — {m.label}</SelectItem>)}
                      </SelectContent>
                    </Select>
                  </div>
                </div>
                {newMonth === 1 && (
                  <div className="space-y-1">
                    <Label>Opening balance (January)</Label>
                    <Input type="number" step="0.01" value={newOpening} onChange={(e) => setNewOpening(e.target.value)} />
                  </div>
                )}
                {newMonth > 1 && (
                  <p className="text-xs text-muted-foreground">Opening balance will roll from the previous month's closing automatically (if it exists).</p>
                )}
                <DialogFooter>
                  <Button variant="outline" onClick={() => setAddOpen(false)}>Cancel</Button>
                  <Button onClick={addPeriod}>Create</Button>
                </DialogFooter>
              </DialogContent>
            </Dialog>

            <Button variant="outline" size="sm" onClick={addTransaction} disabled={!selected}><Plus className="h-4 w-4 mr-1" />Add row</Button>
            <Button variant="outline" onClick={saveAll} disabled={Object.keys(dirty).length === 0}><Save className="h-4 w-4 mr-1" />Save{Object.keys(dirty).length > 0 ? ` (${Object.keys(dirty).length})` : ""}</Button>
            <Button onClick={doExport}><Download className="h-4 w-4 mr-1" />Excel</Button>
          </div>
        </div>

        {selected && (
          <Card className="mb-2">
            <CardHeader className="py-3">
              {isJanuary ? (
                <div className="flex items-center gap-3 flex-wrap">
                  <CardTitle className="text-base">Opening Balance (January, editable):</CardTitle>
                  <Input
                    type="number"
                    step="0.01"
                    value={janOpeningInput}
                    onChange={(e) => setJanOpeningInput(e.target.value)}
                    className="h-8 w-40 font-mono"
                  />
                  <Button size="sm" variant="outline" onClick={saveJanOpening}>Save opening</Button>
                </div>
              ) : (
                <CardTitle className="text-base">
                  Opening Balance: <span className="font-mono">{fmt(effectiveOpening)}</span>
                  <span className="ml-2 text-xs text-muted-foreground">(rolled from previous month's closing)</span>
                </CardTitle>
              )}
            </CardHeader>
          </Card>
        )}

        <div className="flex items-end gap-2 flex-wrap pb-1">
          <div className="text-xs text-muted-foreground">Allocation columns — click any header to edit options. Add new column:</div>
          <Input value={newAllocCol} onChange={(e) => setNewAllocCol(e.target.value)} placeholder="New column…" className="h-8 w-40" />
          <Button variant="outline" size="sm" onClick={addAllocCol}>Add column</Button>
        </div>
      </div>

      {/* Zoomable content area — no inner scroll container so page scroll drives sticky thead */}
      <div
        className="mt-3"
        style={{ zoom: `${zoom}%` }}
      >
        <div className="rounded-md border bg-card">
          <Table>
            <TableHeader className="sticky top-[var(--cash-sticky-offset,0px)] z-20 bg-background shadow-sm">
              <TableRow>
                  {isPettyLike(sheetType) ? (
                    <>
                      <TableHead className="w-12 bg-background">Nº</TableHead>
                      <TableHead className="w-28 bg-background">Data</TableHead>
                      <TableHead className="bg-background"><DropdownListEditor headerMode sheetType={sheetType} columnKey="cheque_type" label="Nº Cheque" /></TableHead>
                      <TableHead className="bg-background"><DropdownListEditor headerMode sheetType={sheetType} columnKey="company" label="Empresa" /></TableHead>
                      <TableHead className="bg-background">Descrição</TableHead>
                      <TableHead className="text-right bg-background">Entradas</TableHead>
                      <TableHead className="text-right bg-background">Saídas</TableHead>
                    </>
                  ) : (
                    <>
                      <TableHead className="w-28 bg-background">Date</TableHead>
                      <TableHead className="bg-background">Description</TableHead>
                      <TableHead className="bg-background"><DropdownListEditor headerMode sheetType={sheetType} columnKey="funder" label="Funder" /></TableHead>
                      <TableHead className="bg-background">Cell No</TableHead>
                      <TableHead className="bg-background"><DropdownListEditor headerMode sheetType={sheetType} columnKey="receiver" label="Receiver" /></TableHead>
                      <TableHead className="text-right bg-background">Deposit</TableHead>
                      <TableHead className="text-right bg-background">Payment</TableHead>
                      {isMpesaLike(sheetType) && <TableHead className="text-right bg-background">Bank charges</TableHead>}
                    </>
                  )}
                  {allocCols.map((c) => (
                    <TableHead key={c} className="text-right bg-background">
                      <DropdownListEditor headerMode sheetType={sheetType} columnKey={`alloc:${c}`} label={c} />
                    </TableHead>
                  ))}
                  <TableHead className="text-right font-semibold bg-background">Balance</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {withBalance.map((t) => (
                  <TableRow key={t.id}>
                    {isPettyLike(sheetType) ? (
                      <>
                        <TableCell>{t.row_no}</TableCell>
                        <TableCell><Input type="date" value={t.tx_date ?? ""} onChange={(e) => updateLocal(t.id, { tx_date: e.target.value })} className="h-7 text-xs w-32" /></TableCell>
                        <TableCell>
                          <DropdownListEditor sheetType={sheetType} columnKey="cheque_type" label="Nº Cheque" value={t.cheque_no} onPick={(v) => updateLocal(t.id, { cheque_no: v })} />
                        </TableCell>
                        <TableCell>
                          <DropdownListEditor sheetType={sheetType} columnKey="company" label="Empresa" value={t.company} onPick={(v) => updateLocal(t.id, { company: v })} />
                        </TableCell>
                        <TableCell><Input value={t.description ?? ""} onChange={(e) => updateLocal(t.id, { description: e.target.value })} className="h-7 text-xs min-w-[180px]" /></TableCell>
                        <TableCell className="text-right">
                          <Input type="number" step="0.01" value={t.entrada ?? ""} onChange={(e) => updateLocal(t.id, { entrada: e.target.value === "" ? null : Number(e.target.value) })} className="h-7 text-xs w-24 text-right font-mono" />
                        </TableCell>
                        <TableCell className="text-right">
                          <Input type="number" step="0.01" value={t.saida ?? ""} onChange={(e) => updateLocal(t.id, { saida: e.target.value === "" ? null : Number(e.target.value) })} className="h-7 text-xs w-24 text-right font-mono" />
                        </TableCell>
                      </>
                    ) : (
                      <>
                        <TableCell><Input type="date" value={t.tx_date ?? ""} onChange={(e) => updateLocal(t.id, { tx_date: e.target.value })} className="h-7 text-xs w-32" /></TableCell>
                        <TableCell><Input value={t.description ?? ""} onChange={(e) => updateLocal(t.id, { description: e.target.value })} className="h-7 text-xs min-w-[180px]" /></TableCell>
                        <TableCell>
                          <DropdownListEditor sheetType={sheetType} columnKey="funder" label="Funder" value={t.funder} onPick={(v) => updateLocal(t.id, { funder: v })} />
                        </TableCell>
                        <TableCell><Input value={t.cell_no ?? ""} onChange={(e) => updateLocal(t.id, { cell_no: e.target.value })} className="h-7 text-xs w-28" /></TableCell>
                        <TableCell>
                          <DropdownListEditor sheetType={sheetType} columnKey="receiver" label="Receiver" value={t.receiver} onPick={(v) => updateLocal(t.id, { receiver: v })} />
                        </TableCell>
                        <TableCell className="text-right">
                          <Input type="number" step="0.01" value={t.entrada ?? ""} onChange={(e) => updateLocal(t.id, { entrada: e.target.value === "" ? null : Number(e.target.value) })} className="h-7 text-xs w-24 text-right font-mono" />
                        </TableCell>
                        <TableCell className="text-right">
                          <Input type="number" step="0.01" value={t.saida ?? ""} onChange={(e) => updateLocal(t.id, { saida: e.target.value === "" ? null : Number(e.target.value) })} className="h-7 text-xs w-24 text-right font-mono" />
                        </TableCell>
                        {isMpesaLike(sheetType) && (
                          <TableCell className="text-right">
                            <Input type="number" step="0.01" value={t.bank_charges ?? ""} onChange={(e) => updateLocal(t.id, { bank_charges: e.target.value === "" ? null : Number(e.target.value) })} className="h-7 text-xs w-24 text-right font-mono" />
                          </TableCell>
                        )}
                      </>
                    )}
                    {allocCols.map((c) => (
                      <TableCell key={c} className="text-right font-mono text-xs">{fmt(t.allocations?.[c])}</TableCell>
                    ))}
                    <TableCell className="text-right font-mono font-semibold">{fmt((t as Tx & { _balance: number })._balance)}</TableCell>
                  </TableRow>
                ))}
                {withBalance.length === 0 && (
                  <TableRow><TableCell colSpan={20} className="text-center text-muted-foreground py-8">No transactions — use "Add row" or upload via the Upload page</TableCell></TableRow>
                )}
              </TableBody>
            </Table>
        </div>
      </div>

      <ZoomControl storageKey={`cash-zoom:${sheetType}`} onChange={setZoom} />
    </div>
  );
}

export default function CashControlDisplay() {
  const { type } = useParams<{ type?: string }>();
  if (!type) return <PickerIndex />;
  if (!CASH_TYPES.includes(type as CashType)) return <PickerIndex />;
  return <SheetDisplay sheetType={type as CashType} />;
}
