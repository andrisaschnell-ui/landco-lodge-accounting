import { useEffect, useMemo, useState } from "react";
import { supabase as supabaseTyped } from "@/integrations/supabase/client";
const supabase: any = supabaseTyped;
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Textarea } from "@/components/ui/textarea";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Badge } from "@/components/ui/badge";
import { toast } from "sonner";
import { format } from "date-fns";
import { Loader2, Wallet } from "lucide-react";

const PETTY_CASH_VALUE = "petty_cash";
const SUSPENSE_CODE = "2999";
const PETTY_CODE = "1111";

interface Bank { id: string; name: string; bank_name: string; pgc_account_code: string | null; }
interface Category { id: string; name: string; pgc_account_code: string | null; }
interface Account { id: string; code: string; name: string; }

export default function ExpensePayments() {
  const [banks, setBanks] = useState<Bank[]>([]);
  const [categories, setCategories] = useState<Category[]>([]);
  const [accounts, setAccounts] = useState<Account[]>([]);
  const [recent, setRecent] = useState<any[]>([]);

  const [date, setDate] = useState(format(new Date(), "yyyy-MM-dd"));
  const [categoryId, setCategoryId] = useState<string>("");
  const [source, setSource] = useState<string>(PETTY_CASH_VALUE);
  const [amount, setAmount] = useState<string>("");
  const [description, setDescription] = useState<string>("");
  const [reference, setReference] = useState<string>("");
  const [saving, setSaving] = useState(false);

  const accByCode = useMemo(() => {
    const m = new Map<string, Account>();
    accounts.forEach(a => m.set(a.code, a));
    return m;
  }, [accounts]);

  const load = async () => {
    const [{ data: bks }, { data: cats }, { data: accs }] = await Promise.all([
      db.from("bank_accounts").select("id, name, bank_name, pgc_account_code").order("name"),
      db.from("expense_categories").select("id, name, pgc_account_code").order("name"),
      db.from("accounts").select("id, code, name").order("code"),
    ]);
    setBanks(bks || []);
    setCategories(cats || []);
    setAccounts(accs || []);
    await loadRecent();
  };

  const loadRecent = async () => {
    const { data: jes } = await supabase
      .from("journal_entries")
      .select("id, entry_date, description, reference, entry_type")
      .eq("entry_type", "expense_payment")
      .order("entry_date", { ascending: false })
      .limit(20);
    setRecent(jes || []);
  };

  useEffect(() => { load(); }, []);

  const reset = () => {
    setDate(format(new Date(), "yyyy-MM-dd"));
    setCategoryId(""); setAmount(""); setDescription(""); setReference("");
    setSource(PETTY_CASH_VALUE);
  };

  const submit = async () => {
    const amt = Number(amount);
    if (!amt || amt <= 0) return toast.error("Amount must be > 0");
    if (!categoryId) return toast.error("Select an expense category");
    if (!description.trim()) return toast.error("Description is required");

    setSaving(true);
    try {
      const cat = categories.find(c => c.id === categoryId);
      const suspense = accByCode.get(SUSPENSE_CODE);
      if (!suspense) throw new Error(`Suspense account ${SUSPENSE_CODE} missing`);

      const expAcc = (cat?.pgc_account_code && accByCode.get(cat.pgc_account_code)) || suspense;

      let creditAccount: Account | undefined;
      let bankId: string | null = null;
      if (source === PETTY_CASH_VALUE) {
        creditAccount = accByCode.get(PETTY_CODE) || suspense;
      } else {
        const bank = banks.find(b => b.id === source);
        if (!bank) throw new Error("Selected bank account not found");
        bankId = bank.id;
        creditAccount = (bank.pgc_account_code && accByCode.get(bank.pgc_account_code)) || suspense;
      }

      const d = new Date(date);
      const month = d.getMonth() + 1;
      const year = d.getFullYear();

      // 1. Journal entry + lines
      const { data: je, error: jeErr } = await supabase
        .from("journal_entries")
        .insert({
          entry_date: date,
          description,
          entry_type: "expense_payment",
          reference: reference || null,
          posted: true,
          posted_at: new Date().toISOString(),
        })
        .select().single();
      if (jeErr) throw jeErr;

      const { error: jlErr } = await db.from("journal_lines").insert([
        { journal_entry_id: je.id, account_id: expAcc.id, debit: amt, credit: 0, memo: description },
        { journal_entry_id: je.id, account_id: creditAccount!.id, debit: 0, credit: amt, memo: `Paid via ${source === PETTY_CASH_VALUE ? "Petty Cash" : banks.find(b => b.id === source)?.name}` },
      ]);
      if (jlErr) throw jlErr;

      // 2. Source-side transaction
      if (source === PETTY_CASH_VALUE) {
        await db.from("petty_cash_transactions").insert({
          date, description, credit: amt, debit: 0,
          month, year, reference: reference || null,
          allocation: cat?.name || null,
          journal_entry_id: je.id,
        });
      } else {
        await db.from("bank_transactions").insert({
          date, description, credit: amt, debit: 0,
          month, year, reference: reference || null,
          bank_account_id: bankId,
          journal_entry_id: je.id,
        });
      }

      // 3. Expense transaction record
      await db.from("expense_transactions").insert({
        date, description, amount_mzn: amt,
        category_id: categoryId, month, year,
        is_shared: true,
        journal_entry_id: je.id,
      });

      toast.success("Expense payment recorded");
      reset();
      loadRecent();
    } catch (e: any) {
      toast.error(e.message || "Failed to record payment");
    } finally {
      setSaving(false);
    }
  };

  return (
    <div className="container mx-auto py-6 space-y-6">
      <div>
        <h1 className="text-3xl font-bold tracking-tight flex items-center gap-2">
          <Wallet className="h-7 w-7 text-primary" /> Expense Payments
        </h1>
        <p className="text-muted-foreground">Record an expense payment. Posts to the journal using your Account Mapping.</p>
      </div>

      <Card>
        <CardHeader>
          <CardTitle>New Payment</CardTitle>
          <CardDescription>Debit: mapped expense account · Credit: bank or petty cash</CardDescription>
        </CardHeader>
        <CardContent className="grid gap-4 md:grid-cols-2">
          <div className="space-y-1.5">
            <Label>Date</Label>
            <Input type="date" value={date} onChange={(e) => setDate(e.target.value)} />
          </div>
          <div className="space-y-1.5">
            <Label>Amount (MZN)</Label>
            <Input type="number" step="0.01" value={amount} onChange={(e) => setAmount(e.target.value)} placeholder="0.00" />
          </div>
          <div className="space-y-1.5">
            <Label>Expense Category</Label>
            <Select value={categoryId} onValueChange={setCategoryId}>
              <SelectTrigger><SelectValue placeholder="Select category…" /></SelectTrigger>
              <SelectContent>
                {categories.map(c => (
                  <SelectItem key={c.id} value={c.id}>
                    {c.name} {c.pgc_account_code ? `· ${c.pgc_account_code}` : "· (unmapped)"}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
          </div>
          <div className="space-y-1.5">
            <Label>Payment Source</Label>
            <Select value={source} onValueChange={setSource}>
              <SelectTrigger><SelectValue /></SelectTrigger>
              <SelectContent>
                <SelectItem value={PETTY_CASH_VALUE}>Petty Cash</SelectItem>
                {banks.map(b => (
                  <SelectItem key={b.id} value={b.id}>{b.bank_name} — {b.name}</SelectItem>
                ))}
              </SelectContent>
            </Select>
          </div>
          <div className="space-y-1.5 md:col-span-2">
            <Label>Description</Label>
            <Textarea value={description} onChange={(e) => setDescription(e.target.value)} placeholder="What was paid…" />
          </div>
          <div className="space-y-1.5">
            <Label>Reference (optional)</Label>
            <Input value={reference} onChange={(e) => setReference(e.target.value)} placeholder="Cheque / receipt #" />
          </div>
          <div className="md:col-span-2 flex justify-end">
            <Button onClick={submit} disabled={saving}>
              {saving && <Loader2 className="mr-2 h-4 w-4 animate-spin" />}
              Record Payment
            </Button>
          </div>
        </CardContent>
      </Card>

      <Card>
        <CardHeader><CardTitle>Recent Expense Payments</CardTitle></CardHeader>
        <CardContent>
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Date</TableHead>
                <TableHead>Description</TableHead>
                <TableHead>Reference</TableHead>
                <TableHead>Status</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {recent.length === 0 ? (
                <TableRow><TableCell colSpan={4} className="text-center py-8 text-muted-foreground">No payments yet.</TableCell></TableRow>
              ) : recent.map((r) => (
                <TableRow key={r.id}>
                  <TableCell>{r.entry_date ? format(new Date(r.entry_date), "dd/MM/yyyy") : "—"}</TableCell>
                  <TableCell>{r.description}</TableCell>
                  <TableCell className="font-mono text-xs">{r.reference || "—"}</TableCell>
                  <TableCell><Badge className="bg-green-100 text-green-800 hover:bg-green-100 border-none">Posted</Badge></TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </CardContent>
      </Card>
    </div>
  );
}
