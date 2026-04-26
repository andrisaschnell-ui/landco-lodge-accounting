import { useEffect, useState } from "react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Checkbox } from "@/components/ui/checkbox";
import {
  Select, SelectContent, SelectItem, SelectTrigger, SelectValue,
} from "@/components/ui/select";
import { useToast } from "@/hooks/use-toast";
import { api, getApiBase } from "@/lib/api";
import { Database, Download, Upload, RefreshCw, Trash2, HardDrive } from "lucide-react";

type Scope = "landco" | "cash" | "complete";

const SCOPES: { key: Scope; label: string; description: string }[] = [
  { key: "landco",   label: "Landco",   description: "Accounting, journal, invoices, payroll, properties, shareholders, banks." },
  { key: "cash",     label: "Cash",     description: "Cash Control sheets, transactions, dropdowns and columns." },
  { key: "complete", label: "Complete", description: "Entire database (everything in the public schema)." },
];

interface BackupFile { filename: string; size: number; mtime: string; }
interface Target { key: string; label: string; available: boolean; }

function formatSize(b: number) {
  if (b < 1024) return `${b} B`;
  if (b < 1024 * 1024) return `${(b / 1024).toFixed(1)} KB`;
  return `${(b / 1024 / 1024).toFixed(2)} MB`;
}

function useTargets() {
  const [targets, setTargets] = useState<Target[]>([
    { key: "local", label: "Local container folder", available: true },
  ]);
  const refresh = async () => {
    try {
      const r = await api<Target[]>(`/api/backup/targets`);
      setTargets(r);
    } catch { /* keep last */ }
  };
  useEffect(() => {
    refresh();
    const id = setInterval(refresh, 10000); // re-poll every 10s for USB plug/unplug
    return () => clearInterval(id);
  }, []);
  return { targets, refresh };
}

function TargetSelect({
  targets, value, onChange,
}: { targets: Target[]; value: string; onChange: (v: string) => void }) {
  return (
    <Select value={value} onValueChange={onChange}>
      <SelectTrigger>
        <SelectValue />
      </SelectTrigger>
      <SelectContent>
        {targets.map((t) => (
          <SelectItem key={t.key} value={t.key} disabled={!t.available}>
            <span className="flex items-center gap-2">
              {t.key === "local"
                ? <Database className="h-3 w-3" />
                : <HardDrive className="h-3 w-3" />}
              {t.label}
              {!t.available && <span className="text-xs text-muted-foreground">(not connected)</span>}
            </span>
          </SelectItem>
        ))}
      </SelectContent>
    </Select>
  );
}

function BackupCard({
  scope, label, description, targets,
}: { scope: Scope; label: string; description: string; targets: Target[] }) {
  const { toast } = useToast();
  const [note, setNote] = useState("");
  const [target, setTarget] = useState<string>("local");
  const [busy, setBusy] = useState(false);

  async function create() {
    setBusy(true);
    try {
      const r = await api<{ filename: string; size: number; target: string }>(
        `/api/backup/create`,
        { method: "POST", body: JSON.stringify({ scope, note, target }) }
      );
      toast({
        title: `Backup created`,
        description: `${r.filename} (${formatSize(r.size)}) → ${r.target}`,
      });
      setNote("");
      window.dispatchEvent(new CustomEvent(`backup-list-refresh-${scope}`));
    } catch (e: any) {
      toast({ title: "Backup failed", description: e.message, variant: "destructive" });
    } finally {
      setBusy(false);
    }
  }

  return (
    <Card>
      <CardHeader>
        <CardTitle className="flex items-center gap-2">
          <Download className="h-5 w-5" /> Backup {label}
        </CardTitle>
        <p className="text-sm text-muted-foreground">{description}</p>
      </CardHeader>
      <CardContent className="space-y-3">
        <div className="space-y-1">
          <Label>Backup target</Label>
          <TargetSelect targets={targets} value={target} onChange={setTarget} />
          <p className="text-[11px] text-muted-foreground">
            USB drives appear here once plugged in. They are saved to <code>Lanco Backup/{scope}/</code> on the drive.
          </p>
        </div>
        <div className="space-y-1">
          <Label htmlFor={`note-${scope}`}>Optional note (appended to filename)</Label>
          <Input
            id={`note-${scope}`}
            value={note}
            onChange={(e) => setNote(e.target.value)}
            placeholder="e.g. before-march-reimport"
            maxLength={40}
          />
          <p className="text-xs text-muted-foreground">
            Filename: <code>{scope}_YYYY-MM-DD_HHMM{note ? `_${note.replace(/[^a-zA-Z0-9_-]+/g, "-")}` : ""}.sql</code>
          </p>
        </div>
        <Button onClick={create} disabled={busy} className="w-full">
          {busy ? "Creating…" : "Create backup now"}
        </Button>
      </CardContent>
    </Card>
  );
}

function RestoreCard({
  scope, label, targets,
}: { scope: Scope; label: string; targets: Target[] }) {
  const { toast } = useToast();
  const [files, setFiles] = useState<BackupFile[]>([]);
  const [target, setTarget] = useState<string>("local");
  const [selected, setSelected] = useState<string>("");
  const [confirm, setConfirm] = useState(false);
  const [busy, setBusy] = useState(false);

  async function loadFiles() {
    try {
      const r = await api<BackupFile[]>(`/api/backup/list?scope=${scope}&target=${target}`);
      setFiles(r);
      if (!r.find((f) => f.filename === selected)) setSelected("");
    } catch {
      // Silent: empty folder, USB unplugged, or API unreachable.
      // The card already shows "Available backups (0)" which is enough signal.
      setFiles([]);
      setSelected("");
    }
  }

  useEffect(() => {
    loadFiles();
    const handler = () => loadFiles();
    window.addEventListener(`backup-list-refresh-${scope}`, handler);
    return () => window.removeEventListener(`backup-list-refresh-${scope}`, handler);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [scope, target]);

  async function restore() {
    if (!selected) return;
    setBusy(true);
    try {
      await api(`/api/backup/restore`, {
        method: "POST",
        body: JSON.stringify({ scope, filename: selected, target }),
      });
      toast({ title: "Restore complete", description: `${selected} (from ${target})` });
      setConfirm(false);
    } catch (e: any) {
      toast({ title: "Restore failed", description: e.message, variant: "destructive" });
    } finally {
      setBusy(false);
    }
  }

  async function download() {
    if (!selected) return;
    const url = `${getApiBase()}/api/backup/download?scope=${scope}&target=${target}&filename=${encodeURIComponent(selected)}`;
    const tk = localStorage.getItem("lanacc_token") || "";
    try {
      const r = await fetch(url, { headers: { Authorization: `Bearer ${tk}` } });
      if (!r.ok) throw new Error(`${r.status} ${r.statusText}`);
      const blob = await r.blob();
      const a = document.createElement("a");
      a.href = URL.createObjectURL(blob);
      a.download = selected;
      document.body.appendChild(a);
      a.click();
      a.remove();
      URL.revokeObjectURL(a.href);
    } catch (e: any) {
      toast({ title: "Download failed", description: e.message, variant: "destructive" });
    }
  }

  async function remove() {
    if (!selected) return;
    if (!window.confirm(`Delete ${selected}? This cannot be undone.`)) return;
    try {
      await api(`/api/backup/file?scope=${scope}&target=${target}&filename=${encodeURIComponent(selected)}`, {
        method: "DELETE",
      });
      toast({ title: "Backup deleted", description: selected });
      setSelected("");
      loadFiles();
    } catch (e: any) {
      toast({ title: "Delete failed", description: e.message, variant: "destructive" });
    }
  }

  return (
    <Card>
      <CardHeader>
        <CardTitle className="flex items-center gap-2">
          <Upload className="h-5 w-5" /> Restore {label}
        </CardTitle>
        <p className="text-sm text-muted-foreground">
          Replaces current {label.toLowerCase()} data with the selected backup.
        </p>
      </CardHeader>
      <CardContent className="space-y-3">
        <div className="space-y-1">
          <Label>Restore source</Label>
          <TargetSelect targets={targets} value={target} onChange={setTarget} />
        </div>

        <div className="space-y-1">
          <div className="flex items-center justify-between">
            <Label>Available backups ({files.length})</Label>
            <Button variant="ghost" size="sm" onClick={loadFiles}>
              <RefreshCw className="h-3 w-3" />
            </Button>
          </div>
          <Select value={selected} onValueChange={setSelected}>
            <SelectTrigger>
              <SelectValue placeholder="Select a backup file…" />
            </SelectTrigger>
            <SelectContent>
              {files.map((f) => (
                <SelectItem key={f.filename} value={f.filename}>
                  {f.filename} — {formatSize(f.size)}
                </SelectItem>
              ))}
            </SelectContent>
          </Select>
        </div>

        <div className="flex items-center gap-2">
          <Checkbox id={`cf-${scope}`} checked={confirm} onCheckedChange={(v) => setConfirm(v === true)} />
          <Label htmlFor={`cf-${scope}`} className="text-sm cursor-pointer">
            I understand this overwrites current data
          </Label>
        </div>

        <div className="flex gap-2">
          <Button
            onClick={restore}
            disabled={!selected || !confirm || busy}
            variant="destructive"
            className="flex-1"
          >
            {busy ? "Restoring…" : "Restore now"}
          </Button>
          <Button onClick={download} disabled={!selected} variant="outline" size="icon" title="Download">
            <Download className="h-4 w-4" />
          </Button>
          <Button onClick={remove} disabled={!selected} variant="outline" size="icon" title="Delete">
            <Trash2 className="h-4 w-4" />
          </Button>
        </div>
      </CardContent>
    </Card>
  );
}

interface DiagResponse {
  connection: {
    DATABASE_URL_host: string | null;
    db: string; user: string; server_host: string; server_port: string;
    pg_version: string;
  };
  tableCount: number;
  totalRows: number;
  tables: { table: string; rows: number }[];
}

export default function DatabaseBackup() {
  const { targets } = useTargets();
  const { toast } = useToast();
  const [repairing, setRepairing] = useState(false);
  const [diag, setDiag] = useState<DiagResponse | null>(null);
  const [diagBusy, setDiagBusy] = useState(false);
  const usbCount = targets.filter((t) => t.key !== "local" && t.available).length;

  const repairUsers = async () => {
    if (!confirm("Recreate the two admin users (cwschnell@gmail.com / andrisa.schnell@gmail.com) with their default passwords and grant admin role?")) return;
    setRepairing(true);
    try {
      const base = getApiBase();
      const r = await fetch(`${base}/auth/repair-users`, { method: "POST" });
      const data = await r.json();
      if (!r.ok) throw new Error(data.error || "repair failed");
      toast({
        title: "Admin users repaired",
        description: `Restored ${data.repaired.length} accounts. You can now log in with the default passwords.`,
      });
    } catch (e: any) {
      toast({ title: "Repair failed", description: e.message, variant: "destructive" });
    } finally {
      setRepairing(false);
    }
  };

  const runDiag = async () => {
    setDiagBusy(true);
    try {
      const r = await api<DiagResponse>(`/api/backup/diag`);
      setDiag(r);
      toast({
        title: "Diagnostics complete",
        description: `${r.tableCount} tables, ${r.totalRows.toLocaleString()} rows in ${r.connection.db}`,
      });
    } catch (e: any) {
      toast({ title: "Diagnostics failed", description: e.message, variant: "destructive" });
    } finally {
      setDiagBusy(false);
    }
  };

  return (
    <div className="container mx-auto p-6 space-y-6">
      <div className="flex items-start justify-between gap-3">
        <div className="flex items-center gap-3">
          <Database className="h-7 w-7 text-primary" />
          <div>
            <h1 className="text-2xl font-bold">Database Backup</h1>
            <p className="text-sm text-muted-foreground">
              Create or restore PostgreSQL backups for Landco accounting, Cash Control, or the complete database — to local storage or a connected USB drive.
            </p>
            <p className="text-xs text-muted-foreground mt-1">
              <HardDrive className="inline h-3 w-3 mr-1" />
              {usbCount === 0 ? "No USB drive detected." : `${usbCount} USB drive(s) connected.`}
            </p>
          </div>
        </div>
        <div className="flex gap-2">
          <Button variant="outline" onClick={runDiag} disabled={diagBusy} title="Show what database and tables the backup API can see">
            <RefreshCw className={`h-4 w-4 mr-2 ${diagBusy ? "animate-spin" : ""}`} />
            {diagBusy ? "Checking…" : "Run Diagnostics"}
          </Button>
          <Button variant="outline" onClick={repairUsers} disabled={repairing} title="Recreate the two admin users with default passwords">
            <RefreshCw className={`h-4 w-4 mr-2 ${repairing ? "animate-spin" : ""}`} />
            {repairing ? "Repairing…" : "Repair Users"}
          </Button>
        </div>
      </div>

      {diag && (
        <Card>
          <CardHeader>
            <CardTitle className="text-base">Backup API Diagnostics</CardTitle>
          </CardHeader>
          <CardContent className="space-y-2 text-sm">
            <div className="grid grid-cols-2 gap-2">
              <div><b>DATABASE_URL host:</b> {diag.connection.DATABASE_URL_host || "—"}</div>
              <div><b>Connected DB:</b> {diag.connection.db}</div>
              <div><b>Server host:</b> {diag.connection.server_host || "(socket)"}</div>
              <div><b>Server port:</b> {diag.connection.server_port}</div>
              <div className="col-span-2"><b>Version:</b> <span className="text-xs">{diag.connection.pg_version}</span></div>
              <div><b>Tables:</b> {diag.tableCount}</div>
              <div><b>Total rows:</b> {diag.totalRows.toLocaleString()}</div>
            </div>
            <details className="mt-2">
              <summary className="cursor-pointer text-xs text-muted-foreground">Per-table row counts</summary>
              <div className="mt-2 max-h-64 overflow-auto border rounded p-2 text-xs font-mono">
                {diag.tables.map((t) => (
                  <div key={t.table} className={t.rows === 0 ? "text-muted-foreground" : ""}>
                    {t.table.padEnd(30, ".")} {t.rows.toLocaleString()}
                  </div>
                ))}
              </div>
            </details>
            {diag.totalRows === 0 && (
              <p className="text-xs text-destructive">
                ⚠️ The API sees 0 rows. Your backups will be empty. The API container is connected
                to a different / empty database than your app uses. Check <code>DATABASE_URL</code>
                in <code>docker-compose.yml</code>.
              </p>
            )}
          </CardContent>
        </Card>
      )}

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-4">
        {SCOPES.map((s) => (
          <div key={s.key} className="contents">
            <BackupCard scope={s.key} label={s.label} description={s.description} targets={targets} />
            <RestoreCard scope={s.key} label={s.label} targets={targets} />
          </div>
        ))}
      </div>
    </div>
  );
}
