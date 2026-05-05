import { useEffect, useState } from "react";
import { db } from "@/lib/db";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { useToast } from "@/hooks/use-toast";
import { Paperclip, FileText, Trash2, Sparkles } from "lucide-react";
import { isLocalMode } from "@/lib/dbMode";
import { supabase } from "@/integrations/supabase/client";

type Att = {
  id: string; filename: string; storage_path: string; mime_type: string | null;
  ocr_status: string; ocr_text: string | null;
};

export function AttachmentManager({ sourceTable, sourceId }: { sourceTable: string; sourceId: string }) {
  const [items, setItems] = useState<Att[]>([]);
  const [uploading, setUploading] = useState(false);
  const { toast } = useToast();
  const localMode = isLocalMode();

  async function load() {
    const { data } = await db
      .from("document_attachments").select("*")
      .eq("source_table", sourceTable).eq("source_id", sourceId)
      .order("created_at", { ascending: false });
    setItems((data as Att[]) || []);
  }
  useEffect(() => { if (sourceId) load(); /* eslint-disable-next-line */ }, [sourceId]);

  async function onUpload(file: File) {
    if (localMode) {
      toast({ title: "Local mode", description: "Attachment file storage is not configured in the local stack yet." });
      return;
    }
    setUploading(true);
    const path = `${sourceTable}/${sourceId}/${Date.now()}_${file.name}`;
    const { error } = await supabase.storage.from("attachments").upload(path, file);
    if (error) { setUploading(false); return toast({ title: "Upload failed", description: error.message, variant: "destructive" }); }
    const { data: ins, error: insErr } = await db.from("document_attachments").insert({
      source_table: sourceTable, source_id: sourceId, storage_path: path,
      filename: file.name, mime_type: file.type, file_size_bytes: file.size,
    }).select().single();
    if (insErr) { setUploading(false); return toast({ title: "DB insert failed", description: insErr.message, variant: "destructive" }); }

    // Trigger OCR
    supabase.functions.invoke("ocr-attachment", { body: { attachment_id: (ins as any).id } })
      .then(() => load())
      .catch(() => {});
    setUploading(false);
    toast({ title: "Uploaded", description: "OCR running in background." });
    load();
  }

  async function remove(att: Att) {
    if (!confirm(`Delete ${att.filename}?`)) return;
    if (!localMode) {
      await supabase.storage.from("attachments").remove([att.storage_path]);
    }
    await db.from("document_attachments").delete().eq("id", att.id);
    load();
  }

  async function reRunOcr(id: string) {
    if (localMode) {
      toast({ title: "Local mode", description: "OCR background processing is only available in cloud mode right now." });
      return;
    }
    toast({ title: "Re-running OCR..." });
    await supabase.functions.invoke("ocr-attachment", { body: { attachment_id: id } });
    load();
  }

  return (
    <div className="space-y-2">
      <div className="flex items-center gap-2">
        <Paperclip className="h-4 w-4" />
        <span className="text-sm font-medium">Attachments</span>
        <Input type="file" className="max-w-xs" disabled={uploading}
          onChange={(e) => e.target.files?.[0] && onUpload(e.target.files[0])} />
      </div>
      {localMode && (
        <p className="text-xs text-muted-foreground">
          Local mode can list attachment records, but file storage and OCR are still cloud-only.
        </p>
      )}
      <div className="space-y-1">
        {items.map(a => (
          <div key={a.id} className="flex items-center gap-2 text-xs border rounded p-2">
            <FileText className="h-4 w-4 shrink-0" />
            <span className="flex-1 truncate">{a.filename}</span>
            <span className={
              a.ocr_status === "done" ? "text-green-600" :
              a.ocr_status === "failed" ? "text-red-600" :
              "text-muted-foreground"
            }>OCR: {a.ocr_status}</span>
            <Button size="sm" variant="ghost" onClick={() => reRunOcr(a.id)} title="Re-run OCR"><Sparkles className="h-3 w-3" /></Button>
            <Button size="sm" variant="ghost" onClick={() => remove(a)}><Trash2 className="h-3 w-3" /></Button>
          </div>
        ))}
        {items.length === 0 && <p className="text-xs text-muted-foreground">No files attached.</p>}
      </div>
    </div>
  );
}
