import { useState } from "react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Card, CardContent } from "@/components/ui/card";
import { 
  Select, 
  SelectContent, 
  SelectItem, 
  SelectTrigger, 
  SelectValue 
} from "@/components/ui/select";
import { Trash2, Plus, Calculator } from "lucide-react";
import { api } from "@/lib/api";
import { useQueryClient } from "@tanstack/react-query";
import { toast } from "sonner";

interface InvoiceItem {
  id: string;
  description: string;
  quantity: number;
  unit_price: number;
  vat_rate: number;
}

export default function InvoiceForm({ onSuccess }: { onSuccess: () => void }) {
  const queryClient = useQueryClient();
  const [clientName, setClientName] = useState("");
  const [clientNuit, setClientNuit] = useState("");
  const [items, setItems] = useState<InvoiceItem[]>([
    { id: '1', description: "", quantity: 1, unit_price: 0, vat_rate: 16 }
  ]);
  const [loading, setLoading] = useState(false);

  const addItem = () => {
    setItems([...items, { id: Date.now().toString(), description: "", quantity: 1, unit_price: 0, vat_rate: 16 }]);
  };

  const removeItem = (id: string) => {
    setItems(items.filter(item => item.id !== id));
  };

  const updateItem = (id: string, field: keyof InvoiceItem, value: any) => {
    setItems(items.map(item => item.id === id ? { ...item, [field]: value } : item));
  };

  const subtotal = items.reduce((acc, item) => acc + (item.quantity * item.unit_price), 0);
  const totalVat = items.reduce((acc, item) => acc + (item.quantity * item.unit_price * (item.vat_rate / 100)), 0);
  const total = subtotal + totalVat;

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    try {
      await api("/api/invoices", {
        method: "POST",
        body: JSON.stringify({
          invoice_date: new Date().toISOString().split('T')[0],
          client_name: clientName,
          client_nuit: clientNuit,
          line_items: items.map(({ id, ...rest }) => ({
            ...rest,
            vat_rate: rest.vat_rate / 100 // Convert to decimal for backend
          })),
          total_mzn: total,
          subtotal_mzn: subtotal,
          vat_amount_mzn: totalVat
        })
      });
      toast.success("Invoice created successfully!");
      queryClient.invalidateQueries({ queryKey: ["invoices"] });
      onSuccess();
    } catch (err: any) {
      toast.error(err.message || "Failed to create invoice");
    } finally {
      setLoading(false);
    }
  };

  return (
    <form onSubmit={handleSubmit} className="space-y-6">
      <div className="grid grid-cols-2 gap-4">
        <div className="space-y-2">
          <Label>Client Name</Label>
          <Input 
            required 
            value={clientName} 
            onChange={(e) => setClientName(e.target.value)} 
            placeholder="e.g. Gordon Board"
          />
        </div>
        <div className="space-y-2">
          <Label>Client NUIT</Label>
          <Input 
            value={clientNuit} 
            onChange={(e) => setClientNuit(e.target.value)} 
            placeholder="Mozambique Tax ID"
          />
        </div>
      </div>

      <div className="space-y-4">
        <div className="flex justify-between items-center">
          <h3 className="text-lg font-semibold">Service Items</h3>
          <Button type="button" variant="outline" size="sm" onClick={addItem}>
            <Plus className="mr-2 h-4 w-4" /> Add Line
          </Button>
        </div>

        <div className="space-y-2">
          {items.map((item) => (
            <div key={item.id} className="flex gap-2 items-start">
              <div className="flex-[3]">
                <Input 
                  placeholder="Service description..." 
                  value={item.description} 
                  onChange={(e) => updateItem(item.id, 'description', e.target.value)}
                  required
                />
              </div>
              <div className="flex-1">
                <Input 
                  type="number" 
                  step="0.01"
                  placeholder="Qty" 
                  value={item.quantity} 
                  onChange={(e) => updateItem(item.id, 'quantity', parseFloat(e.target.value))}
                  required
                />
              </div>
              <div className="flex-[2]">
                <Input 
                  type="number" 
                  step="0.01"
                  placeholder="Price" 
                  value={item.unit_price} 
                  onChange={(e) => updateItem(item.id, 'unit_price', parseFloat(e.target.value))}
                  required
                />
              </div>
              <div className="w-20">
                <Select 
                  value={item.vat_rate.toString()} 
                  onValueChange={(v) => updateItem(item.id, 'vat_rate', parseInt(v))}
                >
                  <SelectTrigger><SelectValue /></SelectTrigger>
                  <SelectContent>
                    <SelectItem value="0">0%</SelectItem>
                    <SelectItem value="16">16%</SelectItem>
                  </SelectContent>
                </Select>
              </div>
              <Button type="button" variant="ghost" size="icon" onClick={() => removeItem(item.id)} disabled={items.length === 1}>
                <Trash2 className="h-4 w-4 text-destructive" />
              </Button>
            </div>
          ))}
        </div>
      </div>

      <Card className="bg-muted/50 border-none shadow-none">
        <CardContent className="pt-6 space-y-2">
          <div className="flex justify-between text-sm">
            <span>Subtotal</span>
            <span>{subtotal.toLocaleString()} MZN</span>
          </div>
          <div className="flex justify-between text-sm">
            <span>VAT (16%)</span>
            <span>{totalVat.toLocaleString()} MZN</span>
          </div>
          <div className="flex justify-between text-lg font-bold border-t pt-2">
            <span>Total</span>
            <span>{total.toLocaleString()} MZN</span>
          </div>
        </CardContent>
      </Card>

      <Button type="submit" className="w-full" disabled={loading}>
        {loading ? "Saving..." : "Create Draft Invoice"}
      </Button>
    </form>
  );
}
