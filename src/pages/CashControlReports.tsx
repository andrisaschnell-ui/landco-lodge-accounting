import { useEffect, useMemo, useState } from "react";
import { db } from "@/lib/db";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Badge } from "@/components/ui/badge";

type CashType = "petty_cash" | "emola" | "mpesa";
const TITLES: Record<CashType, string> = { petty_cash: "Petty Cash", emola: "Emola", mpesa: "Mpesa" };
const fmt = (n: number) => n.toLocaleString(undefined, { minimumFractionDigits: 2, maximumFractionDigits: 2 });

interface TxRow { id: string; sheet_type: CashType; tx_date: string | null; description: string | null; funder: string | null; receiver: string | null; entrada: number | null; saida: number | null; month: number; year: number; allocation_column: string | null; allocation_amount: number | null; }

export default function CashControlReports() {
  const [options, setOptions] = useState<{ funders: string[]; receivers: string[] }>({ funders: [], receivers: [] });
  const [funder, setFunder] = useState<string>("");
  const [receiver, setReceiver] = useState<string>("");
  const [year, setYear] = useState<string>(String(new Date().getFullYear()));
  const [month, setMonth] = useState<string>("all");
  const [allTx, setAllTx] = useState<TxRow[]>([]);

  useEffect(() => {
    (async () => {
      const { data: f } = await db.from("cash_transactions").select("funder").not("funder", "is", null);
      const { data: r } = await db.from("cash_transactions").select("receiver").not("receiver", "is", null);
      setOptions({
        funders: (Array.from(new Set((f ?? []).map((x: any) => x.funder).filter((v: any): v is string => !!v))) as string[]).sort(),
        receivers: (Array.from(new Set((r ?? []).map((x: any) => x.receiver).filter((v: any): v is string => !!v))) as string[]).sort(),
      });
    })();
  }, []);

  useEffect(() => {
    (async () => {
      const { data } = await db.from("cash_transactions").select("*").order("tx_date", { ascending: true });
      setAllTx((data ?? []) as TxRow[]);
    })();
  }, []);

  const byFunder = useMemo(() => funder ? allTx.filter((t) => t.funder === funder) : [], [allTx, funder]);
  const byReceiver = useMemo(() => receiver ? allTx.filter((t) => t.receiver === receiver) : [], [allTx, receiver]);

  const periodFiltered = useMemo(() => {
    const y = parseInt(year);
    return allTx.filter((t) => t.year === y && (month === "all" || t.month === parseInt(month)));
  }, [allTx, year, month]);

  const periodTotals = useMemo(() => {
    const byType: Record<string, { entrada: number; saida: number; count: number }> = {};
    periodFiltered.forEach((t) => {
      const b = byType[t.sheet_type] ??= { entrada: 0, saida: 0, count: 0 };
      b.entrada += Number(t.entrada) || 0;
      b.saida += Number(t.saida) || 0;
      b.count += 1;
    });
    return byType;
  }, [periodFiltered]);

  const totalIn = (arr: TxRow[]) => arr.reduce((s, t) => s + (Number(t.entrada) || 0), 0);
  const totalOut = (arr: TxRow[]) => arr.reduce((s, t) => s + (Number(t.saida) || 0), 0);

  const years = Array.from(new Set(allTx.map((t) => t.year))).sort((a, b) => b - a);
  if (years.length === 0) years.push(new Date().getFullYear());

  return (
    <div className="space-y-6">
      <h1 className="text-3xl font-bold">Cash Control Reports</h1>

      <Tabs defaultValue="funder">
        <TabsList>
          <TabsTrigger value="funder">By Funder</TabsTrigger>
          <TabsTrigger value="receiver">By Receiver</TabsTrigger>
          <TabsTrigger value="period">Monthly / Yearly</TabsTrigger>
        </TabsList>

        <TabsContent value="funder" className="space-y-4">
          <div className="flex items-center gap-3">
            <Select value={funder} onValueChange={setFunder}>
              <SelectTrigger className="w-[280px]"><SelectValue placeholder="Pick a funder" /></SelectTrigger>
              <SelectContent>
                {options.funders.map((f) => <SelectItem key={f} value={f}>{f}</SelectItem>)}
              </SelectContent>
            </Select>
            {funder && <Badge>{byFunder.length} transactions</Badge>}
          </div>
          {funder && (
            <Card>
              <CardContent className="p-0">
                <Table>
                  <TableHeader><TableRow>
                    <TableHead>Date</TableHead><TableHead>Sheet</TableHead><TableHead>Description</TableHead><TableHead>Receiver</TableHead>
                    <TableHead className="text-right">In</TableHead><TableHead className="text-right">Out</TableHead>
                  </TableRow></TableHeader>
                  <TableBody>
                    {byFunder.map((t) => (
                      <TableRow key={t.id}>
                        <TableCell>{t.tx_date}</TableCell>
                        <TableCell>{TITLES[t.sheet_type]}</TableCell>
                        <TableCell>{t.description}</TableCell>
                        <TableCell>{t.receiver ?? "—"}</TableCell>
                        <TableCell className="text-right font-mono">{fmt(Number(t.entrada) || 0)}</TableCell>
                        <TableCell className="text-right font-mono">{fmt(Number(t.saida) || 0)}</TableCell>
                      </TableRow>
                    ))}
                    <TableRow className="font-semibold bg-muted/40">
                      <TableCell colSpan={4} className="text-right">Total</TableCell>
                      <TableCell className="text-right font-mono">{fmt(totalIn(byFunder))}</TableCell>
                      <TableCell className="text-right font-mono">{fmt(totalOut(byFunder))}</TableCell>
                    </TableRow>
                  </TableBody>
                </Table>
              </CardContent>
            </Card>
          )}
        </TabsContent>

        <TabsContent value="receiver" className="space-y-4">
          <div className="flex items-center gap-3">
            <Select value={receiver} onValueChange={setReceiver}>
              <SelectTrigger className="w-[280px]"><SelectValue placeholder="Pick a receiver" /></SelectTrigger>
              <SelectContent>
                {options.receivers.map((r) => <SelectItem key={r} value={r}>{r}</SelectItem>)}
              </SelectContent>
            </Select>
            {receiver && <Badge>{byReceiver.length} transactions</Badge>}
          </div>
          {receiver && (
            <Card>
              <CardContent className="p-0">
                <Table>
                  <TableHeader><TableRow>
                    <TableHead>Date</TableHead><TableHead>Sheet</TableHead><TableHead>Description</TableHead><TableHead>Funder</TableHead>
                    <TableHead className="text-right">In</TableHead><TableHead className="text-right">Out</TableHead>
                  </TableRow></TableHeader>
                  <TableBody>
                    {byReceiver.map((t) => (
                      <TableRow key={t.id}>
                        <TableCell>{t.tx_date}</TableCell>
                        <TableCell>{TITLES[t.sheet_type]}</TableCell>
                        <TableCell>{t.description}</TableCell>
                        <TableCell>{t.funder ?? "—"}</TableCell>
                        <TableCell className="text-right font-mono">{fmt(Number(t.entrada) || 0)}</TableCell>
                        <TableCell className="text-right font-mono">{fmt(Number(t.saida) || 0)}</TableCell>
                      </TableRow>
                    ))}
                    <TableRow className="font-semibold bg-muted/40">
                      <TableCell colSpan={4} className="text-right">Total</TableCell>
                      <TableCell className="text-right font-mono">{fmt(totalIn(byReceiver))}</TableCell>
                      <TableCell className="text-right font-mono">{fmt(totalOut(byReceiver))}</TableCell>
                    </TableRow>
                  </TableBody>
                </Table>
              </CardContent>
            </Card>
          )}
        </TabsContent>

        <TabsContent value="period" className="space-y-4">
          <div className="flex items-center gap-3">
            <Select value={year} onValueChange={setYear}>
              <SelectTrigger className="w-28"><SelectValue /></SelectTrigger>
              <SelectContent>{years.map((y) => <SelectItem key={y} value={String(y)}>{y}</SelectItem>)}</SelectContent>
            </Select>
            <Select value={month} onValueChange={setMonth}>
              <SelectTrigger className="w-32"><SelectValue /></SelectTrigger>
              <SelectContent>
                <SelectItem value="all">All months</SelectItem>
                {Array.from({ length: 12 }).map((_, i) => <SelectItem key={i + 1} value={String(i + 1)}>{String(i + 1).padStart(2, "0")}</SelectItem>)}
              </SelectContent>
            </Select>
          </div>
          <div className="grid gap-3 md:grid-cols-3">
            {(["petty_cash","emola","mpesa"] as CashType[]).map((t) => (
              <Card key={t}>
                <CardHeader className="pb-2"><CardTitle className="text-base">{TITLES[t]}</CardTitle></CardHeader>
                <CardContent className="space-y-1 text-sm">
                  <div className="flex justify-between"><span className="text-muted-foreground">Transactions</span><span>{periodTotals[t]?.count ?? 0}</span></div>
                  <div className="flex justify-between"><span className="text-muted-foreground">Total in</span><span className="font-mono">{fmt(periodTotals[t]?.entrada ?? 0)}</span></div>
                  <div className="flex justify-between"><span className="text-muted-foreground">Total out</span><span className="font-mono">{fmt(periodTotals[t]?.saida ?? 0)}</span></div>
                </CardContent>
              </Card>
            ))}
          </div>
          <Card>
            <CardHeader><CardTitle className="text-base">Transactions in period</CardTitle></CardHeader>
            <CardContent className="p-0">
              <Table>
                <TableHeader><TableRow>
                  <TableHead>Date</TableHead><TableHead>Sheet</TableHead><TableHead>Description</TableHead>
                  <TableHead>Funder</TableHead><TableHead>Receiver</TableHead>
                  <TableHead className="text-right">In</TableHead><TableHead className="text-right">Out</TableHead>
                </TableRow></TableHeader>
                <TableBody>
                  {periodFiltered.map((t) => (
                    <TableRow key={t.id}>
                      <TableCell>{t.tx_date}</TableCell>
                      <TableCell>{TITLES[t.sheet_type]}</TableCell>
                      <TableCell>{t.description}</TableCell>
                      <TableCell>{t.funder ?? "—"}</TableCell>
                      <TableCell>{t.receiver ?? "—"}</TableCell>
                      <TableCell className="text-right font-mono">{fmt(Number(t.entrada) || 0)}</TableCell>
                      <TableCell className="text-right font-mono">{fmt(Number(t.saida) || 0)}</TableCell>
                    </TableRow>
                  ))}
                  <TableRow className="font-semibold bg-muted/40">
                    <TableCell colSpan={5} className="text-right">Grand total</TableCell>
                    <TableCell className="text-right font-mono">{fmt(totalIn(periodFiltered))}</TableCell>
                    <TableCell className="text-right font-mono">{fmt(totalOut(periodFiltered))}</TableCell>
                  </TableRow>
                </TableBody>
              </Table>
            </CardContent>
          </Card>
        </TabsContent>
      </Tabs>
    </div>
  );
}
