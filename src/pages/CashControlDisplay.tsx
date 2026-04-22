import { Link, useParams } from "react-router-dom";
import { useEffect, useMemo, useState } from "react";
import { supabase } from "@/integrations/supabase/client";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Input } from "@/components/ui/input";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Download, ArrowLeft, Save } from "lucide-react";
import { DropdownListEditor } from "@/components/cash/DropdownListEditor";
import { exportCashSheetAsXlsx } from "@/lib/cashControlExport";
import { toast } from "@/hooks/use-toast";

type CashType = "petty_cash" | "emola" | "mpesa";
const TITLES: Record<CashType, string> = { petty_cash: "Petty Cash", emola: "Emola", mpesa: "Mpesa" };

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
        {(["petty_cash","emola","mpesa"] as CashType[]).map((t) => (
          <Link key={t} to={`/cash-control/display/${t}`}>
            <Card className="hover:shadow-md transition-shadow cursor-pointer">
              <CardHeader><CardTitle>{TITLES[t]}</CardTitle></CardHeader>
              <CardContent><p className="text-sm text-muted-foreground">Open {TITLES[t]} display</p></CardContent>
            </Card>
          </Link>
        ))}
      </div>
    </div>
  );
}

function SheetDisplay({ sheetType }: { sheetType: CashType }) {
  const [periods, setPeriods] = useState<{ id: string; month: number | null; year: number; opening_balance: number }[]>([]);
  const [sheetId, setSheetId] = useState<string>("");
  const [allocCols, setAllocCols] = useState<string[]>([]);
  const [newAllocCol, setNewAllocCol] = useState("");
  const [txs, setTxs] = useState<Tx[]>([]);
  const [dirty, setDirty] = useState<Record<string, Partial<Tx>>>({});

  const selected = periods.find((p) => p.id === sheetId);

  // Load periods
  useEffect(() => {
    (async () => {
      const { data } = await supabase.from("cash_sheets").select("id, month, year, opening_balance")
        .eq("sheet_type", sheetType).order("year", { ascending: false }).order("month", { ascending: false });
      setPeriods(data ?? []);
      if (data && data.length && !sheetId) setSheetId(data[0].id);
    })();
  }, [sheetType]);

  // Load allocation columns
  const loadAllocCols = async () => {
    const { data } = await supabase.from("cash_allocation_columns").select("column_name")
      .eq("sheet_type", sheetType).order("sort_order", { ascending: true });
    setAllocCols((data ?? []).map((d) => d.column_name));
  };
  useEffect(() => { loadAllocCols(); }, [sheetType]);

  // Load transactions
  useEffect(() => {
    if (!sheetId) { setTxs([]); return; }
    (async () => {
      const { data } = await supabase.from("cash_transactions").select("*").eq("sheet_id", sheetId)
        .order("tx_date", { ascending: true }).order("row_no", { ascending: true });
      setTxs((data ?? []) as Tx[]);
      setDirty({});
    })();
  }, [sheetId]);

  // Client-side running balance (opening + entradas - saídas)
  const withBalance = useMemo(() => {
    let bal = selected?.opening_balance ?? 0;
    return txs.map((t) => {
      bal = bal + (Number(t.entrada) || 0) - (Number(t.saida) || 0) - (Number(t.bank_charges) || 0);
      return { ...t, _balance: bal };
    });
  }, [txs, selected]);

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

  const addAllocCol = async () => {
    const v = newAllocCol.trim();
    if (!v) return;
    const { error } = await supabase.from("cash_allocation_columns").insert({ sheet_type: sheetType, column_name: v, sort_order: allocCols.length });
    if (error) { toast({ title: "Add failed", description: error.message, variant: "destructive" }); return; }
    setNewAllocCol("");
    loadAllocCols();
  };

  const doExport = () => {
    if (!selected) return;
    exportCashSheetAsXlsx({
      sheet_type: sheetType,
      title: TITLES[sheetType],
      month: selected.month,
      year: selected.year,
      opening_balance: selected.opening_balance,
      allocation_columns: allocCols,
      transactions: txs,
    });
  };

  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between flex-wrap gap-3">
        <div className="flex items-center gap-3">
          <Button variant="ghost" size="sm" asChild><Link to="/cash-control"><ArrowLeft className="h-4 w-4 mr-1" />Back</Link></Button>
          <h1 className="text-2xl font-bold">{TITLES[sheetType]} Display</h1>
        </div>
        <div className="flex items-center gap-2">
          <Select value={sheetId} onValueChange={setSheetId}>
            <SelectTrigger className="w-[200px]"><SelectValue placeholder="Select period" /></SelectTrigger>
            <SelectContent>
              {periods.map((p) => (
                <SelectItem key={p.id} value={p.id}>
                  {p.month ? `${String(p.month).padStart(2, "0")}/` : ""}{p.year}
                </SelectItem>
              ))}
            </SelectContent>
          </Select>
          <Button variant="outline" onClick={saveAll} disabled={Object.keys(dirty).length === 0}><Save className="h-4 w-4 mr-1" />Save{Object.keys(dirty).length > 0 ? ` (${Object.keys(dirty).length})` : ""}</Button>
          <Button onClick={doExport}><Download className="h-4 w-4 mr-1" />Excel</Button>
        </div>
      </div>

      {selected && (
        <Card>
          <CardHeader className="pb-3">
            <CardTitle className="text-base">Opening Balance: <span className="font-mono">{fmt(selected.opening_balance)}</span></CardTitle>
          </CardHeader>
        </Card>
      )}

      <div className="flex items-end gap-2 flex-wrap">
        <div className="text-xs text-muted-foreground">Allocation columns — click any header to edit options. Add new column:</div>
        <Input value={newAllocCol} onChange={(e) => setNewAllocCol(e.target.value)} placeholder="New column…" className="h-8 w-40" />
        <Button variant="outline" size="sm" onClick={addAllocCol}>Add column</Button>
      </div>

      <Card>
        <CardContent className="p-0 overflow-auto">
          <Table>
            <TableHeader>
              <TableRow>
                {sheetType === "petty_cash" ? (
                  <>
                    <TableHead className="w-12">Nº</TableHead>
                    <TableHead className="w-28">Data</TableHead>
                    <TableHead><DropdownListEditor headerMode sheetType={sheetType} columnKey="cheque_type" label="Nº Cheque" /></TableHead>
                    <TableHead><DropdownListEditor headerMode sheetType={sheetType} columnKey="company" label="Empresa" /></TableHead>
                    <TableHead>Descrição</TableHead>
                    <TableHead className="text-right">Entradas</TableHead>
                    <TableHead className="text-right">Saídas</TableHead>
                  </>
                ) : (
                  <>
                    <TableHead className="w-28">Date</TableHead>
                    <TableHead>Description</TableHead>
                    <TableHead><DropdownListEditor headerMode sheetType={sheetType} columnKey="funder" label="Funder" /></TableHead>
                    <TableHead>Cell No</TableHead>
                    <TableHead><DropdownListEditor headerMode sheetType={sheetType} columnKey="receiver" label="Receiver" /></TableHead>
                    <TableHead className="text-right">Deposit</TableHead>
                    <TableHead className="text-right">Payment</TableHead>
                    {sheetType === "mpesa" && <TableHead className="text-right">Bank charges</TableHead>}
                  </>
                )}
                {allocCols.map((c) => (
                  <TableHead key={c} className="text-right">
                    <DropdownListEditor headerMode sheetType={sheetType} columnKey={`alloc:${c}`} label={c} />
                  </TableHead>
                ))}
                <TableHead className="text-right font-semibold">Balance</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {withBalance.map((t) => (
                <TableRow key={t.id}>
                  {sheetType === "petty_cash" ? (
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
                      <TableCell className="text-right font-mono">{fmt(t.entrada)}</TableCell>
                      <TableCell className="text-right font-mono">{fmt(t.saida)}</TableCell>
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
                      <TableCell className="text-right font-mono">{fmt(t.entrada)}</TableCell>
                      <TableCell className="text-right font-mono">{fmt(t.saida)}</TableCell>
                      {sheetType === "mpesa" && <TableCell className="text-right font-mono">{fmt(t.bank_charges)}</TableCell>}
                    </>
                  )}
                  {allocCols.map((c) => (
                    <TableCell key={c} className="text-right font-mono text-xs">{fmt(t.allocations?.[c])}</TableCell>
                  ))}
                  <TableCell className="text-right font-mono font-semibold">{fmt((t as Tx & { _balance: number })._balance)}</TableCell>
                </TableRow>
              ))}
              {withBalance.length === 0 && (
                <TableRow><TableCell colSpan={20} className="text-center text-muted-foreground py-8">No transactions — upload via the Upload page</TableCell></TableRow>
              )}
            </TableBody>
          </Table>
        </CardContent>
      </Card>
    </div>
  );
}

export default function CashControlDisplay() {
  const { type } = useParams<{ type?: string }>();
  if (!type) return <PickerIndex />;
  if (type !== "petty_cash" && type !== "emola" && type !== "mpesa") return <PickerIndex />;
  return <SheetDisplay sheetType={type} />;
}
