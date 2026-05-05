import { useQuery } from "@tanstack/react-query";
import { db } from "@/lib/db";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";

function formatMZN(v: number) {
  return new Intl.NumberFormat("en-US", { minimumFractionDigits: 2 }).format(v);
}

export default function Transactions() {
  const { data: income } = useQuery({
    queryKey: ["income-transactions"],
    queryFn: async () => {
      const { data } = await db
        .from("income_transactions")
        .select("*, properties(name, code), invoices(id, invoice_number, status)")
        .order("date", { ascending: false });
      return data ?? [];
    },
  });

  const { data: invoiceIncome } = useQuery({
    queryKey: ["invoice-income"],
    queryFn: async () => {
      const { data } = await db
        .from("invoices")
        .select("id, invoice_number, invoice_date, client_name, subtotal_mzn, vat_amount_mzn, total_mzn, status")
        .order("invoice_date", { ascending: false });
      return data ?? [];
    },
  });

  const { data: expenses } = useQuery({
    queryKey: ["expense-transactions"],
    queryFn: async () => {
      const { data } = await db.from("expense_transactions").select("*, properties(name), expense_categories(name), shareholders(name)").order("date", { ascending: false });
      return data ?? [];
    },
  });

  const { data: bankTx } = useQuery({
    queryKey: ["bank-transactions"],
    queryFn: async () => {
      const { data } = await db.from("bank_transactions").select("*, bank_accounts(name, currency)").order("date", { ascending: false });
      return data ?? [];
    },
  });

  const { data: pettyCash } = useQuery({
    queryKey: ["petty-cash"],
    queryFn: async () => {
      const { data } = await db.from("petty_cash_transactions").select("*").order("date", { ascending: false });
      return data ?? [];
    },
  });

  const { data: openingBalances } = useQuery({
    queryKey: ["bank-opening-balances"],
    queryFn: async () => {
      const { data } = await db
        .from("bank_opening_balances")
        .select("*, bank_accounts(name, currency)")
        .order("year", { ascending: false })
        .order("month", { ascending: false });
      return data ?? [];
    },
  });

  return (
    <div className="space-y-6">
      <h1 className="text-3xl font-bold">Transactions</h1>
      <Tabs defaultValue="income">
        <TabsList>
          <TabsTrigger value="income">Income ({income?.length ?? 0})</TabsTrigger>
          <TabsTrigger value="expenses">Expenses ({expenses?.length ?? 0})</TabsTrigger>
          <TabsTrigger value="bank">Bank ({bankTx?.length ?? 0})</TabsTrigger>
          <TabsTrigger value="petty">Petty Cash ({pettyCash?.length ?? 0})</TabsTrigger>
        </TabsList>

        <TabsContent value="income">
          <div className="space-y-6">
            <Card>
              <CardHeader><CardTitle>Sales Invoices ({invoiceIncome?.length ?? 0})</CardTitle></CardHeader>
              <CardContent>
                {invoiceIncome && invoiceIncome.length > 0 ? (
                  <Table>
                    <TableHeader>
                      <TableRow>
                        <TableHead>Number</TableHead>
                        <TableHead>Date</TableHead>
                        <TableHead>Client / Description</TableHead>
                        <TableHead className="text-right">Subtotal MZN</TableHead>
                        <TableHead className="text-right">IVA MZN</TableHead>
                        <TableHead className="text-right">Total MZN</TableHead>
                        <TableHead>Status</TableHead>
                      </TableRow>
                    </TableHeader>
                    <TableBody>
                      {invoiceIncome.map((i: any) => (
                        <TableRow key={i.id}>
                          <TableCell className="font-mono text-xs">{i.invoice_number}</TableCell>
                          <TableCell>{i.invoice_date}</TableCell>
                          <TableCell className="max-w-[300px] truncate">{i.client_name}</TableCell>
                          <TableCell className="text-right">{formatMZN(i.subtotal_mzn)}</TableCell>
                          <TableCell className="text-right">{formatMZN(i.vat_amount_mzn)}</TableCell>
                          <TableCell className="text-right font-bold">{formatMZN(i.total_mzn)}</TableCell>
                          <TableCell><span className="text-xs uppercase text-muted-foreground">{i.status}</span></TableCell>
                        </TableRow>
                      ))}
                    </TableBody>
                  </Table>
                ) : (
                  <p className="text-muted-foreground py-8 text-center">No invoices yet — upload via the Invoices sheet.</p>
                )}
              </CardContent>
            </Card>

            <Card>
              <CardHeader><CardTitle>Income Transactions (legacy)</CardTitle></CardHeader>
              <CardContent>
                {income && income.length > 0 ? (
                  <Table>
                    <TableHeader>
                      <TableRow>
                        <TableHead>Date</TableHead>
                        <TableHead>Property</TableHead>
                        <TableHead>Guest</TableHead>
                        <TableHead className="text-right">Amount MZN</TableHead>
                        <TableHead className="text-right">Amount USD</TableHead>
                      </TableRow>
                    </TableHeader>
                    <TableBody>
                      {income.map((t: any) => (
                        <TableRow key={t.id}>
                          <TableCell>{t.date}</TableCell>
                          <TableCell>{t.properties?.name ?? "—"}</TableCell>
                          <TableCell>{t.guest_name ?? t.description ?? "—"}</TableCell>
                          <TableCell className="text-right">{formatMZN(t.accommodation_amount_mzn)}</TableCell>
                          <TableCell className="text-right">${formatMZN(t.amount_usd ?? 0)}</TableCell>
                        </TableRow>
                      ))}
                    </TableBody>
                  </Table>
                ) : (
                  <p className="text-muted-foreground py-8 text-center">No income transactions yet.</p>
                )}
              </CardContent>
            </Card>
          </div>
        </TabsContent>

        <TabsContent value="expenses">
          <Card>
            <CardHeader><CardTitle>Expense Transactions</CardTitle></CardHeader>
            <CardContent>
              {expenses && expenses.length > 0 ? (
                <Table>
                  <TableHeader>
                    <TableRow>
                      <TableHead>Date</TableHead>
                      <TableHead>Property</TableHead>
                      <TableHead>Category</TableHead>
                      <TableHead>Description</TableHead>
                      <TableHead>Type</TableHead>
                      <TableHead className="text-right">Amount MZN</TableHead>
                    </TableRow>
                  </TableHeader>
                  <TableBody>
                    {expenses.map((t: any) => (
                      <TableRow key={t.id}>
                        <TableCell>{t.date ?? "—"}</TableCell>
                        <TableCell>{t.properties?.name ?? "—"}</TableCell>
                        <TableCell>{t.expense_categories?.name ?? "—"}</TableCell>
                        <TableCell>{t.description}</TableCell>
                        <TableCell>{t.is_shared ? "Shared" : "Personal"}</TableCell>
                        <TableCell className="text-right">{formatMZN(t.amount_mzn)}</TableCell>
                      </TableRow>
                    ))}
                  </TableBody>
                </Table>
              ) : (
                <p className="text-muted-foreground py-8 text-center">No expense transactions yet.</p>
              )}
            </CardContent>
          </Card>
        </TabsContent>

        <TabsContent value="bank">
          <div className="space-y-6">
            <Card>
              <CardHeader>
                <CardTitle>Opening Balances (Carry Forward)</CardTitle>
              </CardHeader>
              <CardContent>
                {openingBalances && openingBalances.length > 0 ? (
                  <Table>
                    <TableHeader>
                      <TableRow>
                        <TableHead>Period</TableHead>
                        <TableHead>Account</TableHead>
                        <TableHead className="text-right">Opening Balance</TableHead>
                        <TableHead>Source</TableHead>
                      </TableRow>
                    </TableHeader>
                    <TableBody>
                      {openingBalances.map((o: any) => (
                        <TableRow key={o.id}>
                          <TableCell>{String(o.year)}-{String(o.month).padStart(2, "0")}</TableCell>
                          <TableCell>
                            {o.bank_accounts?.name ?? "—"}
                            {o.bank_accounts?.currency && (
                              <span className="ml-1 text-[10px] text-muted-foreground">{o.bank_accounts.currency}</span>
                            )}
                          </TableCell>
                          <TableCell className="text-right font-semibold">{formatMZN(o.opening_balance ?? 0)}</TableCell>
                          <TableCell className="text-xs text-muted-foreground max-w-[300px] truncate">{o.source_file ?? "—"}</TableCell>
                        </TableRow>
                      ))}
                    </TableBody>
                  </Table>
                ) : (
                  <p className="text-muted-foreground py-4 text-center text-sm">
                    No opening balances recorded yet. They are captured automatically from "BALANCE CARRY FORWARD" rows when uploading BIM Bank Control sheets.
                  </p>
                )}
              </CardContent>
            </Card>

            <Card>
              <CardHeader><CardTitle>Bank Transactions</CardTitle></CardHeader>
              <CardContent>
                {bankTx && bankTx.length > 0 ? (
                  <Table>
                    <TableHeader>
                      <TableRow>
                        <TableHead>Date</TableHead>
                        <TableHead>Account</TableHead>
                        <TableHead>Description</TableHead>
                        <TableHead className="text-right">Debit</TableHead>
                        <TableHead className="text-right">Credit</TableHead>
                        <TableHead className="text-right">Balance</TableHead>
                      </TableRow>
                    </TableHeader>
                    <TableBody>
                      {bankTx.map((t: any) => (
                        <TableRow key={t.id}>
                          <TableCell>{t.date ?? "—"}</TableCell>
                          <TableCell>
                            {t.bank_accounts?.name ?? "—"}
                            {t.bank_accounts?.currency && (
                              <span className="ml-1 text-[10px] text-muted-foreground">{t.bank_accounts.currency}</span>
                            )}
                          </TableCell>
                          <TableCell>{t.description}</TableCell>
                          <TableCell className="text-right">{formatMZN(t.debit ?? 0)}</TableCell>
                          <TableCell className="text-right">{formatMZN(t.credit ?? 0)}</TableCell>
                          <TableCell className="text-right">{formatMZN(t.balance ?? 0)}</TableCell>
                        </TableRow>
                      ))}
                    </TableBody>
                  </Table>
                ) : (
                  <p className="text-muted-foreground py-8 text-center">No bank transactions yet.</p>
                )}
              </CardContent>
            </Card>
          </div>
        </TabsContent>

        <TabsContent value="petty">
          <Card>
            <CardHeader><CardTitle>Petty Cash</CardTitle></CardHeader>
            <CardContent>
              {pettyCash && pettyCash.length > 0 ? (
                <Table>
                  <TableHeader>
                    <TableRow>
                      <TableHead>Date</TableHead>
                      <TableHead>Supplier / Description</TableHead>
                      <TableHead>Allocation</TableHead>
                      <TableHead className="text-right">In</TableHead>
                      <TableHead className="text-right">Out</TableHead>
                      <TableHead className="text-right">Balance</TableHead>
                      <TableHead>Status</TableHead>
                    </TableRow>
                  </TableHeader>
                  <TableBody>
                    {pettyCash.map((t: any) => (
                      <TableRow key={t.id}>
                        <TableCell className="text-xs">{t.date ?? "—"}</TableCell>
                        <TableCell>
                          <div className="font-medium text-sm">{t.supplier || "—"}</div>
                          <div className="text-xs text-muted-foreground">{t.description}</div>
                        </TableCell>
                        <TableCell><span className="text-xs uppercase text-muted-foreground">{t.allocation || "—"}</span></TableCell>
                        <TableCell className="text-right text-xs">{formatMZN(t.credit ?? 0)}</TableCell>
                        <TableCell className="text-right text-xs">{formatMZN(t.debit ?? 0)}</TableCell>
                        <TableCell className="text-right text-xs font-mono">{formatMZN(t.balance ?? 0)}</TableCell>
                        <TableCell>
                          {t.journal_entry_id ? (
                            <span className="text-[10px] bg-green-100 text-green-700 px-1 rounded uppercase font-bold">Posted</span>
                          ) : (
                            <span className="text-[10px] bg-gray-100 text-gray-400 px-1 rounded uppercase font-bold">Draft</span>
                          )}
                        </TableCell>
                      </TableRow>
                    ))}
                  </TableBody>
                </Table>
              ) : (
                <p className="text-muted-foreground py-8 text-center">No petty cash transactions yet.</p>
              )}
            </CardContent>
          </Card>
        </TabsContent>
      </Tabs>
    </div>
  );
}
