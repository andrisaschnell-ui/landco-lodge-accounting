import { useEffect, useState } from "react";
import { useCompanySettings } from "@/hooks/useCompanySettings";
import { useAuth } from "@/hooks/useAuth";
import { supabase } from "@/integrations/supabase/client";
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Button } from "@/components/ui/button";
import { Textarea } from "@/components/ui/textarea";
import { toast } from "@/hooks/use-toast";
import { Loader2, Upload } from "lucide-react";

export default function Settings() {
  const { settings, loading, update, refresh } = useCompanySettings();
  const { user } = useAuth();
  const [isAdmin, setIsAdmin] = useState(false);
  const [checkingRole, setCheckingRole] = useState(true);
  const [saving, setSaving] = useState(false);
  const [form, setForm] = useState<any>({});

  useEffect(() => {
    (async () => {
      const uid = (user as any)?.id;
      if (!uid) { setIsAdmin(false); setCheckingRole(false); return; }
      const { data } = await supabase.from("user_roles").select("role").eq("user_id", uid);
      setIsAdmin(!!data?.some((r: any) => r.role === "admin"));
      setCheckingRole(false);
    })();
  }, [user]);

  useEffect(() => { if (settings) setForm(settings); }, [settings]);

  if (loading || checkingRole) {
    return <div className="flex items-center gap-2 p-6"><Loader2 className="h-4 w-4 animate-spin" /> Loading…</div>;
  }
  if (!isAdmin) {
    return (
      <Card><CardHeader><CardTitle>Access denied</CardTitle>
        <CardDescription>Only administrators can view Settings.</CardDescription>
      </CardHeader></Card>
    );
  }
  if (!settings) return <div className="p-6">No settings row found.</div>;

  const set = (k: string, v: any) => setForm((f: any) => ({ ...f, [k]: v }));

  const save = async (fields: string[]) => {
    setSaving(true);
    const patch: any = {};
    fields.forEach(k => { patch[k] = form[k]; });
    const { error } = await update(patch);
    setSaving(false);
    if (error) toast({ title: "Save failed", description: error, variant: "destructive" });
    else toast({ title: "Saved", description: "Settings updated." });
  };

  const handleLogoUpload = async (file: File) => {
    setSaving(true);
    const ext = file.name.split(".").pop();
    const path = `logo-${Date.now()}.${ext}`;
    const { error: upErr } = await supabase.storage.from("company-assets").upload(path, file, { upsert: true });
    if (upErr) { toast({ title: "Upload failed", description: upErr.message, variant: "destructive" }); setSaving(false); return; }
    const { data: pub } = supabase.storage.from("company-assets").getPublicUrl(path);
    await update({ logo_url: pub.publicUrl });
    await refresh();
    setSaving(false);
    toast({ title: "Logo uploaded" });
  };

  return (
    <div className="space-y-6 max-w-4xl">
      <div>
        <h1 className="text-2xl font-bold">Company Settings</h1>
        <p className="text-muted-foreground">Configure identity, financial defaults, branding, and operations for this installation.</p>
      </div>

      <Tabs defaultValue="identity">
        <TabsList>
          <TabsTrigger value="identity">Identity</TabsTrigger>
          <TabsTrigger value="financial">Financial</TabsTrigger>
          <TabsTrigger value="branding">Branding</TabsTrigger>
          <TabsTrigger value="operational">Operational</TabsTrigger>
        </TabsList>

        <TabsContent value="identity">
          <Card>
            <CardHeader><CardTitle>Company Identity</CardTitle>
              <CardDescription>Shown in sidebar, headers, invoices and reports.</CardDescription>
            </CardHeader>
            <CardContent className="space-y-4">
              <div><Label>Company name</Label><Input value={form.name || ""} onChange={e => set("name", e.target.value)} /></div>
              <div><Label>NUIT</Label><Input value={form.nuit || ""} onChange={e => set("nuit", e.target.value)} /></div>
              <div><Label>Address</Label><Textarea value={form.address || ""} onChange={e => set("address", e.target.value)} /></div>
              <div>
                <Label>Logo</Label>
                <div className="flex items-center gap-4">
                  {form.logo_url && <img src={form.logo_url} alt="Logo" className="h-16 w-16 object-contain border rounded" />}
                  <label className="inline-flex items-center gap-2 px-3 py-2 border rounded cursor-pointer hover:bg-muted">
                    <Upload className="h-4 w-4" /> Upload logo
                    <input type="file" accept="image/*" className="hidden"
                      onChange={e => e.target.files?.[0] && handleLogoUpload(e.target.files[0])} />
                  </label>
                </div>
              </div>
              <Button disabled={saving} onClick={() => save(["name", "nuit", "address"])}>Save Identity</Button>
            </CardContent>
          </Card>
        </TabsContent>

        <TabsContent value="financial">
          <Card>
            <CardHeader><CardTitle>Financial Defaults</CardTitle>
              <CardDescription>Currency, VAT rate, invoice series, fiscal year.</CardDescription>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="grid grid-cols-2 gap-4">
                <div><Label>Currency</Label><Input value={form.currency || ""} onChange={e => set("currency", e.target.value)} /></div>
                <div><Label>VAT rate (%)</Label><Input type="number" step="0.01" value={form.vat_rate ?? 0} onChange={e => set("vat_rate", parseFloat(e.target.value) || 0)} /></div>
                <div><Label>Invoice series prefix</Label><Input value={form.invoice_series_prefix || ""} onChange={e => set("invoice_series_prefix", e.target.value)} /></div>
                <div><Label>Fiscal year start month (1–12)</Label><Input type="number" min="1" max="12" value={form.fiscal_year_start_month ?? 1} onChange={e => set("fiscal_year_start_month", parseInt(e.target.value) || 1)} /></div>
              </div>
              <Button disabled={saving} onClick={() => save(["currency", "vat_rate", "invoice_series_prefix", "fiscal_year_start_month"])}>Save Financial</Button>
            </CardContent>
          </Card>
        </TabsContent>

        <TabsContent value="branding">
          <Card>
            <CardHeader><CardTitle>Branding</CardTitle>
              <CardDescription>Theme colors. Use HSL format like <code>142 71% 45%</code>. Persists for everyone.</CardDescription>
            </CardHeader>
            <CardContent className="space-y-4">
              <div>
                <Label>Primary color (HSL)</Label>
                <div className="flex gap-2 items-center">
                  <Input value={form.primary_color || ""} onChange={e => set("primary_color", e.target.value)} placeholder="142 71% 45%" />
                  <div className="h-10 w-10 rounded border" style={{ background: `hsl(${form.primary_color})` }} />
                </div>
              </div>
              <div>
                <Label>Accent color (HSL)</Label>
                <div className="flex gap-2 items-center">
                  <Input value={form.accent_color || ""} onChange={e => set("accent_color", e.target.value)} placeholder="210 40% 50%" />
                  <div className="h-10 w-10 rounded border" style={{ background: `hsl(${form.accent_color})` }} />
                </div>
              </div>
              <Button disabled={saving} onClick={() => save(["primary_color", "accent_color"])}>Save Branding</Button>
            </CardContent>
          </Card>
        </TabsContent>

        <TabsContent value="operational">
          <Card>
            <CardHeader><CardTitle>Operational</CardTitle>
              <CardDescription>Backup folder, sync target, default entities for blank entries.</CardDescription>
            </CardHeader>
            <CardContent className="space-y-4">
              <div><Label>Backup folder path (local)</Label><Input value={form.backup_folder_path || ""} onChange={e => set("backup_folder_path", e.target.value)} placeholder="E:\\landco_daily_backup" /></div>
              <div><Label>Sync target Cloud project ref</Label><Input value={form.sync_target_ref || ""} onChange={e => set("sync_target_ref", e.target.value)} /></div>
              <div><Label>Default property ID</Label><Input value={form.default_property_id || ""} onChange={e => set("default_property_id", e.target.value)} /></div>
              <div><Label>Default shareholder ID</Label><Input value={form.default_shareholder_id || ""} onChange={e => set("default_shareholder_id", e.target.value)} /></div>
              <Button disabled={saving} onClick={() => save(["backup_folder_path", "sync_target_ref", "default_property_id", "default_shareholder_id"])}>Save Operational</Button>
            </CardContent>
          </Card>
        </TabsContent>
      </Tabs>
    </div>
  );
}
