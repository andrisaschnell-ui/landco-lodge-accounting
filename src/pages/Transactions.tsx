import { useQuery } from "@tanstack/react-query";
import { supabase } from "@/integrations/supabase/client";
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
      const { data } = await supabase.from("income_transactions").select("*, properties(name, code)").order("date", { ascending: false });
      return data ?? [];
    },
  });

  const { data: expenses } = useQuery({
    queryKey: ["expense-transactions"],
    queryFn: async () => {
      const { data } = await supabase.from("expense_transactions").select("*, properties(name), expense_categories(name), shareholders(name)").order("date", { ascending: false });
      return data ?? [];
    },
  });

  const { data: bankTx } = useQuery({
    queryKey: ["bank-transactions"],
    queryFn: async () => {
      const { data } = await supabase.from("bank_transactions").select("*, bank_accounts(name)").order("date", { ascending: false });
      return data ?? [];
    },
  });

  const { data: pettyCash } = useQuery({
    queryKey: ["petty-cash"],
    queryFn: async () => {
      const { data } = await supabase.from("petty_cash_transactions").select("*").order("date", { ascending: false });
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
          <Card>
            <CardHeader><CardTitle>Income Transactions</CardTitle></CardHeader>
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
                        <TableCell>{t.bank_accounts?.name ?? "—"}</TableCell>
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
                      <TableHead>Description</TableHead>
                      <TableHead className="text-right">Credit</TableHead>
                      <TableHead className="text-right">Debit</TableHead>
                      <TableHead className="text-right">Balance</TableHead>
                    </TableRow>
                  </TableHeader>
                  <TableBody>
                    {pettyCash.map((t: any) => (
                      <TableRow key={t.id}>
                        <TableCell>{t.date ?? "—"}</TableCell>
                        <TableCell>{t.description}</TableCell>
                        <TableCell className="text-right">{formatMZN(t.credit ?? 0)}</TableCell>
                        <TableCell className="text-right">{formatMZN(t.debit ?? 0)}</TableCell>
                        <TableCell className="text-right">{formatMZN(t.balance ?? 0)}</TableCell>
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
