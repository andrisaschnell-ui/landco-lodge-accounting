import { useQuery } from "@tanstack/react-query";
import { api } from "@/lib/api";
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { Badge } from "@/components/ui/badge";
import { TrendingUp, TrendingDown, Scale, PieChart } from "lucide-react";

export default function FinancialReports() {
  const { data: trialBalance, isLoading: loadingTB } = useQuery({
    queryKey: ["trial-balance"],
    queryFn: () => api("/api/journal/trial-balance"),
  });

  const { data: incomeStatement, isLoading: loadingPL } = useQuery({
    queryKey: ["income-statement"],
    queryFn: () => api("/api/journal/income-statement"),
  });

  const totalDebits = trialBalance?.reduce((acc: number, r: any) => acc + Number(r.total_debit || 0), 0) || 0;
  const totalCredits = trialBalance?.reduce((acc: number, r: any) => acc + Number(r.total_credit || 0), 0) || 0;
  const isBalanced = Math.abs(totalDebits - totalCredits) < 0.01;

  const revenues = incomeStatement?.filter((r: any) => r.category === 'Revenues') || [];
  const expenses = incomeStatement?.filter((r: any) => r.category === 'Expenses') || [];
  const totalRev = revenues.reduce((acc: number, r: any) => acc + Number(r.balance), 0);
  const totalExp = expenses.reduce((acc: number, r: any) => acc - Number(r.balance), 0); // Expenses are negative balances in credit-heavy sum
  const netIncome = totalRev - totalExp;

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-end">
        <div>
          <h1 className="text-3xl font-bold">Financial Reports</h1>
          <p className="text-muted-foreground">Certified PGC-NIRF reporting for Landco Lodge Lda.</p>
        </div>
        <div className="flex gap-4">
          <Card className="px-4 py-2 border-none bg-muted/30">
            <span className="text-xs text-muted-foreground block">Ledger Balance</span>
            <div className="flex items-center gap-2">
              <Scale size={16} className={isBalanced ? "text-green-500" : "text-amber-500"} />
              <span className="font-bold">{isBalanced ? "Balanced" : "Out of Balance"}</span>
            </div>
          </Card>
        </div>
      </div>

      <Tabs defaultValue="trial-balance" className="w-full">
        <TabsList className="grid w-full grid-cols-2 max-w-md">
          <TabsTrigger value="trial-balance">Trial Balance</TabsTrigger>
          <TabsTrigger value="income-statement">Income Statement</TabsTrigger>
        </TabsList>

        <TabsContent value="trial-balance" className="mt-6">
          <Card>
            <CardHeader>
              <CardTitle>Trial Balance (Balancete de Verificação)</CardTitle>
              <CardDescription>Consolidated debit and credit totals for all accounts.</CardDescription>
            </CardHeader>
            <CardContent>
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead>Code</TableHead>
                    <TableHead>Account Name</TableHead>
                    <TableHead className="text-right">Debit</TableHead>
                    <TableHead className="text-right">Credit</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {trialBalance?.filter((r: any) => r.total_debit > 0 || r.total_credit > 0).map((row: any) => (
                    <TableRow key={row.code}>
                      <TableCell className="font-mono text-sm">{row.code}</TableCell>
                      <TableCell>{row.name}</TableCell>
                      <TableCell className="text-right">{Number(row.total_debit).toLocaleString(undefined, {minimumFractionDigits: 2})}</TableCell>
                      <TableCell className="text-right">{Number(row.total_credit).toLocaleString(undefined, {minimumFractionDigits: 2})}</TableCell>
                    </TableRow>
                  ))}
                  <TableRow className="font-bold bg-muted/30">
                    <TableCell colSpan={2} className="text-right">TOTALS</TableCell>
                    <TableCell className="text-right">{totalDebits.toLocaleString(undefined, {minimumFractionDigits: 2})}</TableCell>
                    <TableCell className="text-right">{totalCredits.toLocaleString(undefined, {minimumFractionDigits: 2})}</TableCell>
                  </TableRow>
                </TableBody>
              </Table>
            </CardContent>
          </Card>
        </TabsContent>

        <TabsContent value="income-statement" className="mt-6 space-y-6">
          <div className="grid grid-cols-3 gap-6">
            <Card className="bg-green-50 border-green-100">
              <CardContent className="pt-6">
                <div className="flex justify-between items-start">
                  <div>
                    <p className="text-sm text-green-600 font-medium">Total Revenues</p>
                    <h3 className="text-2xl font-bold text-green-900">{totalRev.toLocaleString()} MZN</h3>
                  </div>
                  <TrendingUp className="text-green-500" />
                </div>
              </CardContent>
            </Card>
            <Card className="bg-red-50 border-red-100">
              <CardContent className="pt-6">
                <div className="flex justify-between items-start">
                  <div>
                    <p className="text-sm text-red-600 font-medium">Total Expenses</p>
                    <h3 className="text-2xl font-bold text-red-900">{totalExp.toLocaleString()} MZN</h3>
                  </div>
                  <TrendingDown className="text-red-500" />
                </div>
              </CardContent>
            </Card>
            <Card className={netIncome >= 0 ? "bg-blue-50 border-blue-100" : "bg-amber-50 border-amber-100"}>
              <CardContent className="pt-6">
                <div className="flex justify-between items-start">
                  <div>
                    <p className={`text-sm font-medium ${netIncome >= 0 ? "text-blue-600" : "text-amber-600"}`}>Net Income / (Loss)</p>
                    <h3 className={`text-2xl font-bold ${netIncome >= 0 ? "text-blue-900" : "text-amber-900"}`}>{netIncome.toLocaleString()} MZN</h3>
                  </div>
                  <PieChart className={netIncome >= 0 ? "text-blue-500" : "text-amber-500"} />
                </div>
              </CardContent>
            </Card>
          </div>

          <Card>
            <CardHeader>
              <CardTitle>Income Statement (Demonstração de Resultados)</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="space-y-8">
                <div>
                  <h4 className="font-bold text-green-700 mb-2 px-2 border-l-4 border-green-500">7. Revenues</h4>
                  <Table>
                    <TableBody>
                      {revenues.map((r: any) => (
                        <TableRow key={r.code}>
                          <TableCell className="font-mono text-xs w-20">{r.code}</TableCell>
                          <TableCell>{r.name}</TableCell>
                          <TableCell className="text-right font-medium">{Number(r.balance).toLocaleString(undefined, {minimumFractionDigits: 2})}</TableCell>
                        </TableRow>
                      ))}
                    </TableBody>
                  </Table>
                </div>

                <div>
                  <h4 className="font-bold text-red-700 mb-2 px-2 border-l-4 border-red-500">6. Expenses</h4>
                  <Table>
                    <TableBody>
                      {expenses.map((r: any) => (
                        <TableRow key={r.code}>
                          <TableCell className="font-mono text-xs w-20">{r.code}</TableCell>
                          <TableCell>{r.name}</TableCell>
                          <TableCell className="text-right font-medium">({Math.abs(Number(r.balance)).toLocaleString(undefined, {minimumFractionDigits: 2})})</TableCell>
                        </TableRow>
                      ))}
                    </TableBody>
                  </Table>
                </div>
              </div>
            </CardContent>
          </Card>
        </TabsContent>
      </Tabs>
    </div>
  );
}
