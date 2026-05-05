import { useEffect, useState } from "react";
import { db } from "@/lib/db";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogTrigger } from "@/components/ui/dialog";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { useToast } from "@/hooks/use-toast";
import { Plus, ArrowDownToLine, ArrowUpFromLine } from "lucide-react";

type Item = {
  id: string; sku: string; name: string; unit: string; category: string | null;
  current_qty: number; avg_cost: number;
  inventory_account_code: string; cogs_account_code: string;
};

type Movement = {
  id: string; item_id: string; movement_type: string; qty: number;
  unit_cost: number; total_value: number; movement_date: string; description: string | null;
};

const fmt = (n: number, dp = 2) => new Intl.NumberFormat("pt-MZ", { minimumFractionDigits: dp, maximumFractionDigits: dp }).format(n || 0);

export default function Inventory() {
  const [items, setItems] = useState<Item[]>([]);
  const [movements, setMovements] = useState<Movement[]>([]);
  const [openItem, setOpenItem] = useState(false);
  const [openMove, setOpenMove] = useState(false);
  const [moveType, setMoveType] = useState<"in" | "out">("in");
  const { toast } = useToast();

  const [itemForm, setItemForm] = useState<Partial<Item>>({
    sku: "", name: "", unit: "unit", inventory_account_code: "3211", cogs_account_code: "6111",
  });
  const [moveForm, setMoveForm] = useState({
    item_id: "", qty: 0, unit_cost: 0, description: "",
    movement_date: new Date().toISOString().slice(0, 10),
  });

  async function load() {
    const [{ data: i }, { data: m }] = await Promise.all([
      db.from("inventory_items").select("*").order("sku"),
      db.from("inventory_movements").select("*").order("created_at", { ascending: false }).limit(200),
    ]);
    setItems((i as Item[]) || []);
    setMovements((m as Movement[]) || []);
  }
  useEffect(() => { load(); }, []);

  async function saveItem() {
    const { error } = await db.from("inventory_items").insert(itemForm as any);
    if (error) return toast({ title: "Save failed", description: error.message, variant: "destructive" });
    toast({ title: "Item created" });
    setOpenItem(false);
    setItemForm({ sku: "", name: "", unit: "unit", inventory_account_code: "3211", cogs_account_code: "6111" });
    load();
  }

  async function saveMovement() {
    if (!moveForm.item_id || moveForm.qty <= 0) {
      return toast({ title: "Missing fields", description: "Item and quantity required", variant: "destructive" });
    }
    const payload: any = { ...moveForm, movement_type: moveType };
    if (moveType === "out") payload.unit_cost = 0; // engine overrides with WAC
    const { error } = await db.from("inventory_movements").insert(payload);
    if (error) return toast({ title: "Movement failed", description: error.message, variant: "destructive" });
    toast({ title: `Movement recorded (${moveType})` });
    setOpenMove(false);
    setMoveForm({ item_id: "", qty: 0, unit_cost: 0, description: "", movement_date: new Date().toISOString().slice(0, 10) });
    load();
  }

  const totalValue = items.reduce((s, i) => s + i.current_qty * i.avg_cost, 0);

  return (
    <div className="space-y-4 p-6">
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-bold">Inventory (Weighted Average Cost)</h1>
        <div className="flex gap-2">
          <Dialog open={openItem} onOpenChange={setOpenItem}>
            <DialogTrigger asChild><Button variant="outline"><Plus className="h-4 w-4 mr-2" />New Item</Button></DialogTrigger>
            <DialogContent>
              <DialogHeader><DialogTitle>New Inventory Item</DialogTitle></DialogHeader>
              <div className="space-y-3">
                <div><Label>SKU</Label><Input value={itemForm.sku || ""} onChange={(e) => setItemForm({ ...itemForm, sku: e.target.value })} /></div>
                <div><Label>Name</Label><Input value={itemForm.name || ""} onChange={(e) => setItemForm({ ...itemForm, name: e.target.value })} /></div>
                <div><Label>Unit</Label><Input value={itemForm.unit || ""} onChange={(e) => setItemForm({ ...itemForm, unit: e.target.value })} /></div>
                <div className="grid grid-cols-2 gap-3">
                  <div><Label>Inventory account</Label><Input value={itemForm.inventory_account_code || ""} onChange={(e) => setItemForm({ ...itemForm, inventory_account_code: e.target.value })} /></div>
                  <div><Label>COGS account</Label><Input value={itemForm.cogs_account_code || ""} onChange={(e) => setItemForm({ ...itemForm, cogs_account_code: e.target.value })} /></div>
                </div>
              </div>
              <div className="flex justify-end gap-2 mt-4">
                <Button variant="outline" onClick={() => setOpenItem(false)}>Cancel</Button>
                <Button onClick={saveItem}>Save</Button>
              </div>
            </DialogContent>
          </Dialog>

          <Dialog open={openMove} onOpenChange={setOpenMove}>
            <DialogTrigger asChild><Button><ArrowDownToLine className="h-4 w-4 mr-2" />Record movement</Button></DialogTrigger>
            <DialogContent>
              <DialogHeader><DialogTitle>Record Movement</DialogTitle></DialogHeader>
              <Tabs value={moveType} onValueChange={(v) => setMoveType(v as any)}>
                <TabsList className="grid w-full grid-cols-2">
                  <TabsTrigger value="in"><ArrowDownToLine className="h-4 w-4 mr-1" />In</TabsTrigger>
                  <TabsTrigger value="out"><ArrowUpFromLine className="h-4 w-4 mr-1" />Out</TabsTrigger>
                </TabsList>
              </Tabs>
              <div className="space-y-3 mt-3">
                <div>
                  <Label>Item</Label>
                  <Select value={moveForm.item_id} onValueChange={(v) => setMoveForm({ ...moveForm, item_id: v })}>
                    <SelectTrigger><SelectValue placeholder="Select item..." /></SelectTrigger>
                    <SelectContent>{items.map(i => <SelectItem key={i.id} value={i.id}>{i.sku} — {i.name} (qty: {fmt(i.current_qty, 3)})</SelectItem>)}</SelectContent>
                  </Select>
                </div>
                <div className="grid grid-cols-2 gap-3">
                  <div><Label>Quantity</Label><Input type="number" step="0.001" value={moveForm.qty} onChange={(e) => setMoveForm({ ...moveForm, qty: +e.target.value })} /></div>
                  {moveType === "in" && <div><Label>Unit cost (MZN)</Label><Input type="number" step="0.01" value={moveForm.unit_cost} onChange={(e) => setMoveForm({ ...moveForm, unit_cost: +e.target.value })} /></div>}
                </div>
                <div><Label>Date</Label><Input type="date" value={moveForm.movement_date} onChange={(e) => setMoveForm({ ...moveForm, movement_date: e.target.value })} /></div>
                <div><Label>Description</Label><Input value={moveForm.description} onChange={(e) => setMoveForm({ ...moveForm, description: e.target.value })} /></div>
              </div>
              <div className="flex justify-end gap-2 mt-4">
                <Button variant="outline" onClick={() => setOpenMove(false)}>Cancel</Button>
                <Button onClick={saveMovement}>Record</Button>
              </div>
            </DialogContent>
          </Dialog>
        </div>
      </div>

      <Card>
        <CardHeader><CardTitle>Stock on Hand — Total value: MZN {fmt(totalValue)}</CardTitle></CardHeader>
        <CardContent>
          <Table>
            <TableHeader><TableRow>
              <TableHead>SKU</TableHead><TableHead>Name</TableHead><TableHead>Unit</TableHead>
              <TableHead className="text-right">Qty</TableHead><TableHead className="text-right">Avg Cost</TableHead>
              <TableHead className="text-right">Value</TableHead>
            </TableRow></TableHeader>
            <TableBody>
              {items.map(i => (
                <TableRow key={i.id}>
                  <TableCell className="font-mono text-xs">{i.sku}</TableCell>
                  <TableCell>{i.name}</TableCell>
                  <TableCell>{i.unit}</TableCell>
                  <TableCell className="text-right">{fmt(i.current_qty, 3)}</TableCell>
                  <TableCell className="text-right">{fmt(i.avg_cost, 4)}</TableCell>
                  <TableCell className="text-right">{fmt(i.current_qty * i.avg_cost)}</TableCell>
                </TableRow>
              ))}
              {items.length === 0 && <TableRow><TableCell colSpan={6} className="text-center text-muted-foreground">No items yet.</TableCell></TableRow>}
            </TableBody>
          </Table>
        </CardContent>
      </Card>

      <Card>
        <CardHeader><CardTitle>Recent Movements</CardTitle></CardHeader>
        <CardContent>
          <Table>
            <TableHeader><TableRow>
              <TableHead>Date</TableHead><TableHead>Type</TableHead><TableHead>Item</TableHead>
              <TableHead className="text-right">Qty</TableHead><TableHead className="text-right">Unit Cost</TableHead>
              <TableHead className="text-right">Value</TableHead><TableHead>Note</TableHead>
            </TableRow></TableHeader>
            <TableBody>
              {movements.map(m => {
                const item = items.find(i => i.id === m.item_id);
                return (
                  <TableRow key={m.id}>
                    <TableCell>{m.movement_date}</TableCell>
                    <TableCell><span className={m.movement_type === "in" ? "text-green-600" : "text-orange-600"}>{m.movement_type}</span></TableCell>
                    <TableCell>{item?.sku} {item?.name}</TableCell>
                    <TableCell className="text-right">{fmt(m.qty, 3)}</TableCell>
                    <TableCell className="text-right">{fmt(m.unit_cost, 4)}</TableCell>
                    <TableCell className="text-right">{fmt(m.total_value)}</TableCell>
                    <TableCell className="text-xs text-muted-foreground">{m.description}</TableCell>
                  </TableRow>
                );
              })}
            </TableBody>
          </Table>
        </CardContent>
      </Card>
    </div>
  );
}
