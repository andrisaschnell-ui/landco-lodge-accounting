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
import { api } from "@/lib/api";
import { Database, Download, Upload, RefreshCw, Trash2 } from "lucide-react";

type Scope = "landco" | "cash" | "complete";

const SCOPES: { key: Scope; label: string; description: string }[] = [
  { key: "landco",   label: "Landco",   description: "Accounting, journal, invoices, payroll, properties, shareholders, banks." },
  { key: "cash",     label: "Cash",     description: "Cash Control sheets, transactions, dropdowns and columns." },
  { key: "complete", label: "Complete", description: "Entire database (everything in the public schema)." },
];

interface BackupFile { filename: string; size: number; mtime: string; }

function formatSize(b: number) {
  if (b < 1024) return `${b} B`;
  if (b < 1024 * 1024) return `${(b / 1024).toFixed(1)} KB`;
  return `${(b / 1024 / 1024).toFixed(2)} MB`;
}

function BackupCard({ scope, label, description }: { scope: Scope; label: string; description: string }) {
  const { toast } = useToast();
  const [note, setNote] = useState("");
  const [busy, setBusy] = useState(false);

  async function create() {
    setBusy(true);
    try {
      const r = await api<{ filename: string; size: number }>(
        `/api/backup/create`,
        { method: "POST", body: JSON.stringify({ scope, note }) }
      );
      toast({ title: `Backup created`, description: `${r.filename} (${formatSize(r.size)})` });
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
          <Label htmlFor={`note-${scope}`}>Optional note (appended to filename)</Label>
          <Input
            id={`note-${scope}`}
            value={note}
            onChange={(e) => setNote(e.target.value)}
            placeholder="e.g. before-march-reimport"
            maxLength={40}
          />
          <p className="text-xs text-muted-foreground">
            Filename will be <code>{scope}_YYYY-MM-DD_HHMM{note ? `_${note.replace(/[^a-zA-Z0-9_-]+/g, "-")}` : ""}.sql</code>
          </p>
        </div>
        <Button onClick={create} disabled={busy} className="w-full">
          {busy ? "Creating…" : "Create backup now"}
        </Button>
      </CardContent>
    </Card>
  );
}

function RestoreCard({ scope, label }: { scope: Scope; label: string }) {
  const { toast } = useToast();
  const [files, setFiles] = useState<BackupFile[]>([]);
  const [selected, setSelected] = useState<string>("");
  const [confirm, setConfirm] = useState(false);
  const [busy, setBusy] = useState(false);

  async function loadFiles() {
    try {
      const r = await api<BackupFile[]>(`/api/backup/list?scope=${scope}`);
      setFiles(r);
      if (!r.find((f) => f.filename === selected)) setSelected("");
    } catch (e: any) {
      toast({ title: "Could not list backups", description: e.message, variant: "destructive" });
    }
  }

  useEffect(() => {
    loadFiles();
    const handler = () => loadFiles();
    window.addEventListener(`backup-list-refresh-${scope}`, handler);
    return () => window.removeEventListener(`backup-list-refresh-${scope}`, handler);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [scope]);

  async function restore() {
    if (!selected) return;
    setBusy(true);
    try {
      await api(`/api/backup/restore`, {
        method: "POST",
        body: JSON.stringify({ scope, filename: selected }),
      });
      toast({ title: "Restore complete", description: selected });
      setConfirm(false);
    } catch (e: any) {
      toast({ title: "Restore failed", description: e.message, variant: "destructive" });
    } finally {
      setBusy(false);
    }
  }

  function download() {
    if (!selected) return;
    const url = `${window.location.protocol}//${window.location.hostname}:4000/api/backup/download?scope=${scope}&filename=${encodeURIComponent(selected)}`;
    const token = localStorage.getItem("lanacc_token") || "";
    fetch(url, { headers: { Authorization: `Bearer ${token}` } })
      .then((r) => r.blob())
      .then((blob) => {
        const a = document.createElement("a");
        a.href = URL.createObjectURL(blob);
        a.download = selected;
        a.click();
        URL.revokeObjectURL(a.href);
      });
  }

  async function remove() {
    if (!selected) return;
    if (!window.confirm(`Delete ${selected}? This cannot be undone.`)) return;
    try {
      await api(`/api/backup/file?scope=${scope}&filename=${encodeURIComponent(selected)}`, {
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

export default function DatabaseBackup() {
  return (
    <div className="container mx-auto p-6 space-y-6">
      <div className="flex items-center gap-3">
        <Database className="h-7 w-7 text-primary" />
        <div>
          <h1 className="text-2xl font-bold">Database Backup</h1>
          <p className="text-sm text-muted-foreground">
            Create or restore PostgreSQL backups for the Landco accounting, Cash Control, or the complete database.
          </p>
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-4">
        {SCOPES.map((s) => (
          <div key={s.key} className="contents">
            <BackupCard scope={s.key} label={s.label} description={s.description} />
            <RestoreCard scope={s.key} label={s.label} />
          </div>
        ))}
      </div>
    </div>
  );
}
