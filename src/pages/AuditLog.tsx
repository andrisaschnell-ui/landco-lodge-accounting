import { useEffect, useState } from "react";
import { db } from "@/lib/db";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Button } from "@/components/ui/button";
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogTrigger } from "@/components/ui/dialog";
import { Eye } from "lucide-react";

type Row = {
  id: number; occurred_at: string; actor_email: string | null;
  action: string; table_name: string | null; row_id: string | null;
  old_data: any; new_data: any; details: any;
};

export default function AuditLog() {
  const [rows, setRows] = useState<Row[]>([]);
  const [tableName, setTableName] = useState<string>("all");
  const [action, setAction] = useState<string>("all");
  const [search, setSearch] = useState("");
  const [loading, setLoading] = useState(true);

  async function load() {
    setLoading(true);
    let q = db.from("audit_log").select("*").order("occurred_at", { ascending: false }).limit(500);
    if (tableName !== "all") q = q.eq("table_name", tableName);
    if (action !== "all") q = q.eq("action", action);
    const { data } = await q;
    let result = (data as Row[]) || [];
    if (search) {
      const s = search.toLowerCase();
      result = result.filter(r =>
        r.actor_email?.toLowerCase().includes(s) ||
        r.row_id?.toLowerCase().includes(s) ||
        JSON.stringify(r.new_data || r.old_data || r.details || "").toLowerCase().includes(s)
      );
    }
    setRows(result);
    setLoading(false);
  }
  useEffect(() => { load(); /* eslint-disable-next-line */ }, [tableName, action]);

  const tables = ["all", "journal_entries", "journal_lines", "expense_transactions", "income_transactions",
    "bank_transactions", "salary_runs", "invoices", "supplier_invoices", "accounts", "user_roles",
    "fixed_assets", "inventory_movements", "company_settings"];
  const actions = ["all", "INSERT", "UPDATE", "DELETE", "LOGIN", "LOGIN_FAILED", "LOGOUT", "ROLE_GRANT", "READ"];

  return (
    <div className="space-y-4 p-6">
      <h1 className="text-2xl font-bold">Audit Log</h1>
      <Card>
        <CardContent className="pt-6 grid grid-cols-1 md:grid-cols-4 gap-3">
          <div>
            <Label>Table</Label>
            <Select value={tableName} onValueChange={setTableName}>
              <SelectTrigger><SelectValue /></SelectTrigger>
              <SelectContent>{tables.map(t => <SelectItem key={t} value={t}>{t}</SelectItem>)}</SelectContent>
            </Select>
          </div>
          <div>
            <Label>Action</Label>
            <Select value={action} onValueChange={setAction}>
              <SelectTrigger><SelectValue /></SelectTrigger>
              <SelectContent>{actions.map(t => <SelectItem key={t} value={t}>{t}</SelectItem>)}</SelectContent>
            </Select>
          </div>
          <div className="md:col-span-2">
            <Label>Search (email, row id, content)</Label>
            <div className="flex gap-2"><Input value={search} onChange={(e) => setSearch(e.target.value)} /><Button onClick={load}>Apply</Button></div>
          </div>
        </CardContent>
      </Card>

      <Card>
        <CardHeader><CardTitle>{loading ? "Loading..." : `${rows.length} entries`}</CardTitle></CardHeader>
        <CardContent>
          <Table>
            <TableHeader><TableRow>
              <TableHead>When</TableHead><TableHead>Who</TableHead><TableHead>Action</TableHead>
              <TableHead>Table</TableHead><TableHead>Row</TableHead><TableHead className="w-12">Detail</TableHead>
            </TableRow></TableHeader>
            <TableBody>
              {rows.map(r => (
                <TableRow key={r.id}>
                  <TableCell className="text-xs">{new Date(r.occurred_at).toLocaleString()}</TableCell>
                  <TableCell className="text-xs">{r.actor_email || "system"}</TableCell>
                  <TableCell><span className="font-mono text-xs">{r.action}</span></TableCell>
                  <TableCell className="text-xs">{r.table_name}</TableCell>
                  <TableCell className="text-xs font-mono">{r.row_id?.slice(0, 8)}</TableCell>
                  <TableCell>
                    <Dialog>
                      <DialogTrigger asChild><Button size="sm" variant="ghost"><Eye className="h-4 w-4" /></Button></DialogTrigger>
                      <DialogContent className="max-w-3xl max-h-[80vh] overflow-auto">
                        <DialogHeader><DialogTitle>Audit entry #{r.id}</DialogTitle></DialogHeader>
                        <div className="space-y-3 text-xs font-mono">
                          {r.old_data && <div><b>OLD:</b><pre className="bg-muted p-2 rounded overflow-auto">{JSON.stringify(r.old_data, null, 2)}</pre></div>}
                          {r.new_data && <div><b>NEW:</b><pre className="bg-muted p-2 rounded overflow-auto">{JSON.stringify(r.new_data, null, 2)}</pre></div>}
                          {r.details && <div><b>DETAILS:</b><pre className="bg-muted p-2 rounded overflow-auto">{JSON.stringify(r.details, null, 2)}</pre></div>}
                        </div>
                      </DialogContent>
                    </Dialog>
                  </TableCell>
                </TableRow>
              ))}
              {rows.length === 0 && !loading && <TableRow><TableCell colSpan={6} className="text-center text-muted-foreground">No entries.</TableCell></TableRow>}
            </TableBody>
          </Table>
        </CardContent>
      </Card>
    </div>
  );
}
