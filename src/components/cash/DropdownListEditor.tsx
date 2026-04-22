import { useEffect, useState } from "react";
import { supabase } from "@/integrations/supabase/client";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Popover, PopoverContent, PopoverTrigger } from "@/components/ui/popover";
import { Plus, Pencil, Trash2, Check, X, ChevronDown } from "lucide-react";
import { toast } from "@/hooks/use-toast";

interface Props {
  sheetType: "petty_cash" | "emola" | "mpesa";
  columnKey: string;
  label: string;
  /** Controlled current value (may be null) */
  value?: string | null;
  /** Called when a cell's value is picked from the dropdown */
  onPick?: (v: string) => void;
  /** Render as a column-header edit button (no picker) */
  headerMode?: boolean;
}

/**
 * Editable dropdown list: view/add/rename/delete items for a given (sheet_type, column_key).
 * - headerMode=true: renders a compact header-styled button opening the CRUD popover (no value picking).
 * - headerMode=false: picker + edit popover combined, for cell-level use.
 */
export function DropdownListEditor({ sheetType, columnKey, label, value, onPick, headerMode }: Props) {
  const [options, setOptions] = useState<{ id: string; value: string }[]>([]);
  const [loading, setLoading] = useState(false);
  const [newValue, setNewValue] = useState("");
  const [editingId, setEditingId] = useState<string | null>(null);
  const [editingValue, setEditingValue] = useState("");

  const load = async () => {
    setLoading(true);
    const { data } = await supabase
      .from("cash_dropdown_options")
      .select("id, value")
      .eq("sheet_type", sheetType)
      .eq("column_key", columnKey)
      .order("sort_order", { ascending: true })
      .order("value", { ascending: true });
    setOptions(data ?? []);
    setLoading(false);
  };

  useEffect(() => { load(); }, [sheetType, columnKey]);

  const add = async () => {
    const v = newValue.trim();
    if (!v) return;
    const { error } = await supabase.from("cash_dropdown_options").insert({ sheet_type: sheetType, column_key: columnKey, value: v });
    if (error) { toast({ title: "Add failed", description: error.message, variant: "destructive" }); return; }
    setNewValue("");
    load();
  };

  const save = async (id: string) => {
    const v = editingValue.trim();
    if (!v) return;
    const { error } = await supabase.from("cash_dropdown_options").update({ value: v }).eq("id", id);
    if (error) { toast({ title: "Update failed", description: error.message, variant: "destructive" }); return; }
    setEditingId(null);
    load();
  };

  const remove = async (id: string) => {
    const { error } = await supabase.from("cash_dropdown_options").delete().eq("id", id);
    if (error) { toast({ title: "Delete failed", description: error.message, variant: "destructive" }); return; }
    load();
  };

  return (
    <Popover>
      <PopoverTrigger asChild>
        {headerMode ? (
          <button className="flex items-center gap-1 text-xs font-medium text-muted-foreground hover:text-foreground">
            {label} <ChevronDown className="h-3 w-3" />
          </button>
        ) : (
          <button className="flex items-center gap-1 text-xs text-left hover:underline">
            {value || <span className="text-muted-foreground">— pick —</span>}
            <ChevronDown className="h-3 w-3" />
          </button>
        )}
      </PopoverTrigger>
      <PopoverContent align="start" className="w-72 p-3 space-y-2">
        <div className="text-xs font-semibold">{label} options</div>
        {!headerMode && onPick && (
          <div className="max-h-48 overflow-y-auto border rounded-md">
            {options.map((o) => (
              <button key={o.id} className="block w-full text-left px-2 py-1 text-sm hover:bg-muted"
                onClick={() => onPick(o.value)}>{o.value}</button>
            ))}
            {options.length === 0 && <div className="px-2 py-1 text-xs text-muted-foreground">No options yet</div>}
          </div>
        )}
        <div className="border-t pt-2 space-y-1 max-h-56 overflow-y-auto">
          {options.map((o) => (
            <div key={o.id} className="flex items-center gap-1">
              {editingId === o.id ? (
                <>
                  <Input value={editingValue} onChange={(e) => setEditingValue(e.target.value)} className="h-7 text-xs" />
                  <Button size="icon" variant="ghost" className="h-7 w-7" onClick={() => save(o.id)}><Check className="h-3 w-3" /></Button>
                  <Button size="icon" variant="ghost" className="h-7 w-7" onClick={() => setEditingId(null)}><X className="h-3 w-3" /></Button>
                </>
              ) : (
                <>
                  <span className="flex-1 text-xs truncate">{o.value}</span>
                  <Button size="icon" variant="ghost" className="h-7 w-7" onClick={() => { setEditingId(o.id); setEditingValue(o.value); }}><Pencil className="h-3 w-3" /></Button>
                  <Button size="icon" variant="ghost" className="h-7 w-7" onClick={() => remove(o.id)}><Trash2 className="h-3 w-3" /></Button>
                </>
              )}
            </div>
          ))}
          {loading && <div className="text-xs text-muted-foreground">Loading…</div>}
        </div>
        <div className="flex items-center gap-1 pt-2 border-t">
          <Input placeholder="Add new…" value={newValue} onChange={(e) => setNewValue(e.target.value)}
            onKeyDown={(e) => { if (e.key === "Enter") add(); }} className="h-7 text-xs" />
          <Button size="icon" variant="outline" className="h-7 w-7" onClick={add}><Plus className="h-3 w-3" /></Button>
        </div>
      </PopoverContent>
    </Popover>
  );
}
