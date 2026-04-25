// Paired Cell No + Receiver picker for the mobile-banking cash sheets.
// Stores each contact as a single row in cash_dropdown_options:
//   sheet_type  = '_shared_mobile'
//   column_key  = 'receiver_contact'
//   value       = 'NAME|NUMBER'
//
// The same contact list is shared across Emola One, Emola Two,
// Mpesa One, Mpesa Two — no DB schema change required.
//
// Behaviour:
//  - Typing or picking a name auto-fills the matching number.
//  - Typing or picking a number auto-fills the matching name.
//  - If the pair doesn't exist yet, the user can add it inline; the new
//    contact then becomes available across all 4 mobile sheets.
//  - Edit / delete is also available inline.

import { useEffect, useMemo, useState } from "react";
import { supabase } from "@/integrations/supabase/client";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Popover, PopoverContent, PopoverTrigger } from "@/components/ui/popover";
import { ChevronDown, Plus, Pencil, Trash2, Check, X } from "lucide-react";
import { toast } from "@/hooks/use-toast";

const SHARED_SHEET = "_shared_mobile";
const COLUMN_KEY = "receiver_contact";

interface Contact { id: string; name: string; number: string; }

function parse(value: string): { name: string; number: string } {
  const [name = "", number = ""] = value.split("|");
  return { name: name.trim(), number: number.trim() };
}
function pack(name: string, number: string) {
  return `${name.trim()}|${number.trim()}`;
}

interface Props {
  cellNo: string | null;
  receiver: string | null;
  onChange: (v: { cell_no: string; receiver: string }) => void;
  /** Which field this instance renders (one component per cell, but shares the list). */
  field: "cell_no" | "receiver";
}

export function ReceiverContactPicker({ cellNo, receiver, onChange, field }: Props) {
  const [contacts, setContacts] = useState<Contact[]>([]);
  const [loading, setLoading] = useState(false);
  const [newName, setNewName] = useState("");
  const [newNumber, setNewNumber] = useState("");
  const [editingId, setEditingId] = useState<string | null>(null);
  const [editName, setEditName] = useState("");
  const [editNumber, setEditNumber] = useState("");

  const load = async () => {
    setLoading(true);
    const { data } = await supabase
      .from("cash_dropdown_options")
      .select("id, value")
      .eq("sheet_type", SHARED_SHEET)
      .eq("column_key", COLUMN_KEY)
      .order("value", { ascending: true });
    setContacts((data ?? []).map((r) => {
      const p = parse(r.value);
      return { id: r.id, name: p.name, number: p.number };
    }));
    setLoading(false);
  };

  useEffect(() => { load(); }, []);

  const byNumber = useMemo(() => {
    const m = new Map<string, Contact>();
    for (const c of contacts) if (c.number) m.set(c.number, c);
    return m;
  }, [contacts]);
  const byName = useMemo(() => {
    const m = new Map<string, Contact>();
    for (const c of contacts) if (c.name) m.set(c.name.toLowerCase(), c);
    return m;
  }, [contacts]);

  // When the user types into the cell, look up the partner value automatically.
  function handleInlineChange(v: string) {
    if (field === "cell_no") {
      const hit = byNumber.get(v.trim());
      onChange({ cell_no: v, receiver: hit ? hit.name : (receiver ?? "") });
    } else {
      const hit = byName.get(v.trim().toLowerCase());
      onChange({ cell_no: hit ? hit.number : (cellNo ?? ""), receiver: v });
    }
  }

  function pick(c: Contact) {
    onChange({ cell_no: c.number, receiver: c.name });
  }

  async function add() {
    const n = newName.trim();
    const num = newNumber.trim();
    if (!n || !num) {
      toast({ title: "Both fields required", description: "Enter a name AND a cell number.", variant: "destructive" });
      return;
    }
    const { error } = await supabase.from("cash_dropdown_options").insert({
      sheet_type: SHARED_SHEET, column_key: COLUMN_KEY, value: pack(n, num),
    });
    if (error) { toast({ title: "Add failed", description: error.message, variant: "destructive" }); return; }
    setNewName(""); setNewNumber("");
    await load();
    onChange({ cell_no: num, receiver: n });
  }

  async function save(id: string) {
    const n = editName.trim();
    const num = editNumber.trim();
    if (!n || !num) return;
    const { error } = await supabase.from("cash_dropdown_options")
      .update({ value: pack(n, num) }).eq("id", id);
    if (error) { toast({ title: "Update failed", description: error.message, variant: "destructive" }); return; }
    setEditingId(null);
    load();
  }

  async function remove(id: string) {
    const { error } = await supabase.from("cash_dropdown_options").delete().eq("id", id);
    if (error) { toast({ title: "Delete failed", description: error.message, variant: "destructive" }); return; }
    load();
  }

  const currentValue = field === "cell_no" ? (cellNo ?? "") : (receiver ?? "");

  return (
    <div className="flex items-center gap-1">
      <Input
        value={currentValue}
        onChange={(e) => handleInlineChange(e.target.value)}
        className={`h-7 text-xs ${field === "cell_no" ? "w-28" : "w-36"}`}
        placeholder={field === "cell_no" ? "84…" : "Name"}
      />
      <Popover>
        <PopoverTrigger asChild>
          <button className="p-1 hover:bg-muted rounded" title="Pick / manage contacts">
            <ChevronDown className="h-3 w-3" />
          </button>
        </PopoverTrigger>
        <PopoverContent align="start" className="w-80 p-3 space-y-2">
          <div className="text-xs font-semibold">Mobile-banking contacts (shared)</div>

          <div className="max-h-48 overflow-y-auto border rounded-md">
            {contacts.map((c) => (
              <div key={c.id} className="flex items-center gap-1 px-1 py-0.5 hover:bg-muted">
                {editingId === c.id ? (
                  <>
                    <Input value={editName} onChange={(e) => setEditName(e.target.value)} className="h-6 text-xs" placeholder="Name" />
                    <Input value={editNumber} onChange={(e) => setEditNumber(e.target.value)} className="h-6 text-xs w-28" placeholder="Number" />
                    <Button size="icon" variant="ghost" className="h-6 w-6" onClick={() => save(c.id)}><Check className="h-3 w-3" /></Button>
                    <Button size="icon" variant="ghost" className="h-6 w-6" onClick={() => setEditingId(null)}><X className="h-3 w-3" /></Button>
                  </>
                ) : (
                  <>
                    <button className="flex-1 text-left text-xs" onClick={() => pick(c)}>
                      <span className="font-medium">{c.name}</span>
                      <span className="text-muted-foreground"> — {c.number}</span>
                    </button>
                    <Button size="icon" variant="ghost" className="h-6 w-6"
                      onClick={() => { setEditingId(c.id); setEditName(c.name); setEditNumber(c.number); }}>
                      <Pencil className="h-3 w-3" />
                    </Button>
                    <Button size="icon" variant="ghost" className="h-6 w-6" onClick={() => remove(c.id)}>
                      <Trash2 className="h-3 w-3" />
                    </Button>
                  </>
                )}
              </div>
            ))}
            {contacts.length === 0 && <div className="px-2 py-1 text-xs text-muted-foreground">No contacts yet</div>}
            {loading && <div className="px-2 py-1 text-xs text-muted-foreground">Loading…</div>}
          </div>

          <div className="border-t pt-2 space-y-1">
            <div className="text-xs font-semibold">Add new contact</div>
            <div className="flex items-center gap-1">
              <Input value={newName} onChange={(e) => setNewName(e.target.value)} placeholder="Receiver name" className="h-7 text-xs" />
              <Input value={newNumber} onChange={(e) => setNewNumber(e.target.value)} placeholder="Cell no" className="h-7 text-xs w-28" />
              <Button size="icon" variant="outline" className="h-7 w-7" onClick={add}><Plus className="h-3 w-3" /></Button>
            </div>
            <p className="text-[10px] text-muted-foreground">Saved once, reused across Emola 1/2 and Mpesa 1/2.</p>
          </div>
        </PopoverContent>
      </Popover>
    </div>
  );
}
