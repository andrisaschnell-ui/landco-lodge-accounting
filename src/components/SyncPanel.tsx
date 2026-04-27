import { useState } from "react";
import { Button } from "@/components/ui/button";
import { Dialog, DialogContent, DialogDescription, DialogHeader, DialogTitle, DialogTrigger } from "@/components/ui/dialog";
import { useToast } from "@/hooks/use-toast";
import { ArrowDownToLine, ArrowUpToLine, RefreshCw } from "lucide-react";
import { getApiBase } from "@/lib/api";

async function callSync(direction: "push" | "pull") {
  const token = localStorage.getItem("lanacc_token") || "";
  const r = await fetch(`${getApiBase()}/api/sync/${direction}`, {
    method: "POST",
    headers: { "Content-Type": "application/json", Authorization: `Bearer ${token}` },
  });
  if (!r.ok) throw new Error((await r.json().catch(() => ({}))).error || r.statusText);
  return r.json();
}

export function SyncPanel() {
  const { toast } = useToast();
  const [busy, setBusy] = useState<null | "push" | "pull">(null);
  const [open, setOpen] = useState(false);

  const run = async (dir: "push" | "pull") => {
    setBusy(dir);
    try {
      const res = await callSync(dir);
      toast({ title: `Sync ${dir} complete`, description: `${res.tables ?? 0} tables, ${res.rows ?? 0} rows.` });
    } catch (e: any) {
      toast({ title: `Sync ${dir} failed`, description: e.message, variant: "destructive" });
    } finally {
      setBusy(null);
    }
  };

  return (
    <Dialog open={open} onOpenChange={setOpen}>
      <DialogTrigger asChild>
        <Button size="sm" variant="outline" className="gap-1.5">
          <RefreshCw size={14} /> Sync
        </Button>
      </DialogTrigger>
      <DialogContent>
        <DialogHeader>
          <DialogTitle>Manual database sync</DialogTitle>
          <DialogDescription>
            Conflict policy: <strong>Local wins</strong>. Both directions cover all business tables.
          </DialogDescription>
        </DialogHeader>
        <div className="flex flex-col gap-2 pt-2">
          <Button onClick={() => run("pull")} disabled={!!busy} className="justify-start gap-2">
            <ArrowDownToLine size={16} /> Pull Cloud → Local {busy === "pull" && "..."}
          </Button>
          <Button onClick={() => run("push")} disabled={!!busy} variant="secondary" className="justify-start gap-2">
            <ArrowUpToLine size={16} /> Push Local → Cloud {busy === "push" && "..."}
          </Button>
        </div>
      </DialogContent>
    </Dialog>
  );
}
