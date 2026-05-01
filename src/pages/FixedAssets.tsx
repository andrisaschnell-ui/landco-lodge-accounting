import { useEffect, useState } from "react";
import { supabase } from "@/integrations/supabase/client";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogTrigger } from "@/components/ui/dialog";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { useToast } from "@/hooks/use-toast";
import { Plus, Calculator, Send } from "lucide-react";
import { HelpPopover } from "@/components/HelpPopover";

type Asset = {
  id: string; asset_code: string; name: string; category: string;
  acquisition_date: string; acquisition_cost: number; salvage_value: number;
  useful_life_months: number; status: string;
  asset_account_code: string; accum_depr_account_code: string; depr_expense_account_code: string;
  property_id: string | null;
};

const fmt = (n: number) => new Intl.NumberFormat("pt-MZ", { minimumFractionDigits: 2 }).format(n || 0);

export default function FixedAssets() {
  const [assets, setAssets] = useState<Asset[]>([]);
  const [loading, setLoading] = useState(true);
  const [open, setOpen] = useState(false);
  const [properties, setProperties] = useState<{ id: string; name: string }[]>([]);
  const { toast } = useToast();
  const today = new Date();
  const [period, setPeriod] = useState({ year: today.getFullYear(), month: today.getMonth() + 1 });

  const [form, setForm] = useState<Partial<Asset>>({
    asset_code: "", name: "", category: "equipment",
    acquisition_date: today.toISOString().slice(0, 10),
    acquisition_cost: 0, salvage_value: 0, useful_life_months: 60,
    asset_account_code: "4321", accum_depr_account_code: "4328", depr_expense_account_code: "6421",
  });

  const load = async () => {
    setLoading(true);
    const [{ data: a }, { data: p }] = await Promise.all([
      supabase.from("fixed_assets").select("*").order("asset_code"),
      supabase.from("properties").select("id,name"),
    ]);
    setAssets((a as Asset[]) || []);
    setProperties(p || []);
    setLoading(false);
  };
  useEffect(() => { load(); }, []);

  async function save() {
    const payload: any = { ...form };
    const { data, error } = await supabase.from("fixed_assets").insert(payload).select().single();
    if (error) return toast({ title: "Save failed", description: error.message, variant: "destructive" });
    // generate schedule
    await supabase.rpc("fn_generate_depreciation_schedule", { _asset_id: data.id });
    toast({ title: "Asset saved", description: "Depreciation schedule generated." });
    setOpen(false);
    load();
  }

  async function postMonth() {
    const { data, error } = await supabase.rpc("fn_post_depreciation_month", { _year: period.year, _month: period.month });
    if (error) return toast({ title: "Posting failed", description: error.message, variant: "destructive" });
    toast({ title: "Depreciation posted", description: `${data} entries posted for ${period.year}-${String(period.month).padStart(2, "0")}.` });
  }

  return (
    <div className="space-y-4 p-6">
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-2"><h1 className="text-2xl font-bold">Fixed Assets</h1><HelpPopover route="/accounting/fixed-assets" size={18} /></div>
        <div className="flex gap-2 items-end">
          <div>
            <Label className="text-xs">Year</Label>
            <Input type="number" className="w-24" value={period.year} onChange={(e) => setPeriod({ ...period, year: +e.target.value })} />
          </div>
          <div>
            <Label className="text-xs">Month</Label>
            <Input type="number" min={1} max={12} className="w-20" value={period.month} onChange={(e) => setPeriod({ ...period, month: +e.target.value })} />
          </div>
          <Button onClick={postMonth} variant="secondary"><Send className="h-4 w-4 mr-2" />Post depreciation</Button>
          <Dialog open={open} onOpenChange={setOpen}>
            <DialogTrigger asChild><Button><Plus className="h-4 w-4 mr-2" />New Asset</Button></DialogTrigger>
            <DialogContent className="max-w-2xl">
              <DialogHeader><DialogTitle>New Fixed Asset</DialogTitle></DialogHeader>
              <div className="grid grid-cols-2 gap-3">
                <div><Label>Code</Label><Input value={form.asset_code || ""} onChange={(e) => setForm({ ...form, asset_code: e.target.value })} /></div>
                <div><Label>Name</Label><Input value={form.name || ""} onChange={(e) => setForm({ ...form, name: e.target.value })} /></div>
                <div>
                  <Label>Category</Label>
                  <Select value={form.category} onValueChange={(v) => setForm({ ...form, category: v })}>
                    <SelectTrigger><SelectValue /></SelectTrigger>
                    <SelectContent>
                      <SelectItem value="building">Building</SelectItem>
                      <SelectItem value="vehicle">Vehicle</SelectItem>
                      <SelectItem value="furniture">Furniture</SelectItem>
                      <SelectItem value="equipment">Equipment</SelectItem>
                      <SelectItem value="other">Other</SelectItem>
                    </SelectContent>
                  </Select>
                </div>
                <div>
                  <Label>Property</Label>
                  <Select value={form.property_id || ""} onValueChange={(v) => setForm({ ...form, property_id: v })}>
                    <SelectTrigger><SelectValue placeholder="(none)" /></SelectTrigger>
                    <SelectContent>
                      {properties.map(p => <SelectItem key={p.id} value={p.id}>{p.name}</SelectItem>)}
                    </SelectContent>
                  </Select>
                </div>
                <div><Label>Acquisition date</Label><Input type="date" value={form.acquisition_date as string} onChange={(e) => setForm({ ...form, acquisition_date: e.target.value })} /></div>
                <div><Label>Cost (MZN)</Label><Input type="number" value={form.acquisition_cost ?? 0} onChange={(e) => setForm({ ...form, acquisition_cost: +e.target.value })} /></div>
                <div><Label>Salvage value</Label><Input type="number" value={form.salvage_value ?? 0} onChange={(e) => setForm({ ...form, salvage_value: +e.target.value })} /></div>
                <div><Label>Useful life (months)</Label><Input type="number" value={form.useful_life_months ?? 60} onChange={(e) => setForm({ ...form, useful_life_months: +e.target.value })} /></div>
                <div><Label>Asset account</Label><Input value={form.asset_account_code || ""} onChange={(e) => setForm({ ...form, asset_account_code: e.target.value })} /></div>
                <div><Label>Accum. depr. account</Label><Input value={form.accum_depr_account_code || ""} onChange={(e) => setForm({ ...form, accum_depr_account_code: e.target.value })} /></div>
                <div><Label>Depr. expense account</Label><Input value={form.depr_expense_account_code || ""} onChange={(e) => setForm({ ...form, depr_expense_account_code: e.target.value })} /></div>
              </div>
              <div className="flex justify-end gap-2 mt-4">
                <Button variant="outline" onClick={() => setOpen(false)}>Cancel</Button>
                <Button onClick={save}><Calculator className="h-4 w-4 mr-2" />Save & generate schedule</Button>
              </div>
            </DialogContent>
          </Dialog>
        </div>
      </div>

      <Card>
        <CardHeader><CardTitle>Asset Register</CardTitle></CardHeader>
        <CardContent>
          {loading ? <p>Loading...</p> : (
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Code</TableHead><TableHead>Name</TableHead><TableHead>Category</TableHead>
                  <TableHead>Acquired</TableHead><TableHead className="text-right">Cost</TableHead>
                  <TableHead className="text-right">Salvage</TableHead><TableHead className="text-right">Life (mo)</TableHead>
                  <TableHead>Status</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {assets.map(a => (
                  <TableRow key={a.id}>
                    <TableCell className="font-mono text-xs">{a.asset_code}</TableCell>
                    <TableCell>{a.name}</TableCell>
                    <TableCell>{a.category}</TableCell>
                    <TableCell>{a.acquisition_date}</TableCell>
                    <TableCell className="text-right">{fmt(a.acquisition_cost)}</TableCell>
                    <TableCell className="text-right">{fmt(a.salvage_value)}</TableCell>
                    <TableCell className="text-right">{a.useful_life_months}</TableCell>
                    <TableCell>{a.status}</TableCell>
                  </TableRow>
                ))}
                {assets.length === 0 && <TableRow><TableCell colSpan={8} className="text-center text-muted-foreground">No assets yet.</TableCell></TableRow>}
              </TableBody>
            </Table>
          )}
        </CardContent>
      </Card>
    </div>
  );
}
