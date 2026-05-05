import { useEffect, useState } from "react";
import { useQuery, useQueryClient } from "@tanstack/react-query";
import { list } from "@/lib/api";
import { supabase as supabaseTyped } from "@/integrations/supabase/client";
const supabase: any = supabaseTyped;
import {
  Table, TableBody, TableCell, TableHead, TableHeader, TableRow,
} from "@/components/ui/table";
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Plus, Loader2 } from "lucide-react";
import { toast } from "sonner";

interface NewAcc {
  code: string; name: string; account_type: string; normal_side: string;
  pgc_class: string; account_class: number;
}

const empty: NewAcc = {
  code: "", name: "", account_type: "expense", normal_side: "debit",
  pgc_class: "", account_class: 6,
};

export default function ChartOfAccounts() {
  const qc = useQueryClient();
  const { data: accounts, isLoading } = useQuery({
    queryKey: ["accounts"],
    queryFn: () => list("accounts"),
  });

  const [showForm, setShowForm] = useState(false);
  const [form, setForm] = useState<NewAcc>(empty);
  const [saving, setSaving] = useState(false);

  // Keep account_class in sync with leading digit of code
  useEffect(() => {
    if (form.code) {
      const c = parseInt(form.code[0]);
      if (!isNaN(c) && c >= 1 && c <= 9) setForm(f => ({ ...f, account_class: c }));
    }
  }, [form.code]);

  const save = async () => {
    if (!form.code || !form.name) {
      toast.error("Code and name are required");
      return;
    }
    setSaving(true);
    const { error } = await db.from("accounts").insert({
      code: form.code.trim(),
      name: form.name.trim(),
      account_type: form.account_type,
      normal_side: form.normal_side,
      pgc_class: form.pgc_class || null,
      account_class: form.account_class,
      is_active: true,
    });
    setSaving(false);
    if (error) {
      toast.error(error.message);
      return;
    }
    toast.success("Account added");
    setForm(empty);
    setShowForm(false);
    qc.invalidateQueries({ queryKey: ["accounts"] });
  };

  return (
    <div className="container mx-auto py-6 space-y-6">
      <div className="flex justify-between items-center">
        <h1 className="text-3xl font-bold tracking-tight">Chart of Accounts (PGC-NIRF)</h1>
        <Button onClick={() => setShowForm(s => !s)} variant={showForm ? "outline" : "default"}>
          <Plus className="h-4 w-4 mr-1" /> {showForm ? "Cancel" : "Add account"}
        </Button>
      </div>

      {showForm && (
        <Card>
          <CardHeader>
            <CardTitle>New PGC account</CardTitle>
            <CardDescription>Code follows PGC-NIRF (1=Assets, 2=Liabilities, 3=Equity, 4=Provisions, 5=Inv, 6=Expenses, 7=Income, 8=Results).</CardDescription>
          </CardHeader>
          <CardContent>
            <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
              <div>
                <Label>Code</Label>
                <Input value={form.code} onChange={e => setForm({...form, code: e.target.value})} placeholder="e.g. 6213" />
              </div>
              <div className="md:col-span-2">
                <Label>Name</Label>
                <Input value={form.name} onChange={e => setForm({...form, name: e.target.value})} placeholder="e.g. Cleaning supplies" />
              </div>
              <div>
                <Label>Type</Label>
                <Select value={form.account_type} onValueChange={v => setForm({...form, account_type: v})}>
                  <SelectTrigger><SelectValue /></SelectTrigger>
                  <SelectContent>
                    <SelectItem value="asset">Asset</SelectItem>
                    <SelectItem value="liability">Liability</SelectItem>
                    <SelectItem value="equity">Equity</SelectItem>
                    <SelectItem value="income">Income</SelectItem>
                    <SelectItem value="expense">Expense</SelectItem>
                  </SelectContent>
                </Select>
              </div>
              <div>
                <Label>Normal side</Label>
                <Select value={form.normal_side} onValueChange={v => setForm({...form, normal_side: v})}>
                  <SelectTrigger><SelectValue /></SelectTrigger>
                  <SelectContent>
                    <SelectItem value="debit">Debit</SelectItem>
                    <SelectItem value="credit">Credit</SelectItem>
                  </SelectContent>
                </Select>
              </div>
              <div>
                <Label>PGC class label (optional)</Label>
                <Input value={form.pgc_class} onChange={e => setForm({...form, pgc_class: e.target.value})} placeholder="e.g. Operating expenses" />
              </div>
            </div>
            <div className="mt-4 flex justify-end">
              <Button onClick={save} disabled={saving}>
                {saving && <Loader2 className="h-4 w-4 mr-2 animate-spin" />}
                Save account
              </Button>
            </div>
          </CardContent>
        </Card>
      )}

      <Card>
        <CardHeader>
          <CardTitle>Accounts ({accounts?.length || 0})</CardTitle>
        </CardHeader>
        <CardContent>
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead className="w-[100px]">Code</TableHead>
                <TableHead>Name</TableHead>
                <TableHead>Type</TableHead>
                <TableHead>Normal Side</TableHead>
                <TableHead>Class</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {isLoading ? (
                <TableRow><TableCell colSpan={5} className="text-center py-10">Loading accounts...</TableCell></TableRow>
              ) : (
                accounts?.map((account: any) => (
                  <TableRow key={account.id}>
                    <TableCell className="font-mono font-bold">{account.code}</TableCell>
                    <TableCell>{account.name}</TableCell>
                    <TableCell><Badge variant="outline" className="capitalize">{account.account_type}</Badge></TableCell>
                    <TableCell className="capitalize">{account.normal_side}</TableCell>
                    <TableCell className="text-muted-foreground">{account.pgc_class}</TableCell>
                  </TableRow>
                ))
              )}
            </TableBody>
          </Table>
        </CardContent>
      </Card>
    </div>
  );
}
