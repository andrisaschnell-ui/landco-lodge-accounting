// OCR attachment via Lovable AI Gateway (Gemini supports image inputs).
// Reads the file from the 'attachments' bucket, asks the model to extract
// text, and stores the result in document_attachments.ocr_text.

import { createClient } from "https://esm.sh/@supabase/supabase-js@2.49.4";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const LOVABLE_API_KEY = Deno.env.get("LOVABLE_API_KEY")!;

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });

  try {
    const { attachment_id } = await req.json();
    if (!attachment_id) {
      return new Response(JSON.stringify({ error: "attachment_id required" }), { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } });
    }

    const admin = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);
    const { data: att, error: aErr } = await admin.from("document_attachments").select("*").eq("id", attachment_id).single();
    if (aErr || !att) throw new Error("attachment not found");

    // Skip non-image / non-pdf
    const mime = (att.mime_type || "").toLowerCase();
    const isImage = mime.startsWith("image/");
    const isPdf = mime === "application/pdf";
    if (!isImage && !isPdf) {
      await admin.from("document_attachments").update({ ocr_status: "skipped", ocr_processed_at: new Date().toISOString() }).eq("id", attachment_id);
      return new Response(JSON.stringify({ ok: true, skipped: true }), { headers: { ...corsHeaders, "Content-Type": "application/json" } });
    }

    // Download file
    const { data: blob, error: dErr } = await admin.storage.from("attachments").download(att.storage_path);
    if (dErr || !blob) throw new Error(`download failed: ${dErr?.message}`);

    const buf = new Uint8Array(await blob.arrayBuffer());
    // base64
    let binary = "";
    for (let i = 0; i < buf.length; i++) binary += String.fromCharCode(buf[i]);
    const b64 = btoa(binary);
    const dataUrl = `data:${mime};base64,${b64}`;

    // Call Lovable AI Gateway
    const resp = await fetch("https://ai.gateway.lovable.dev/v1/chat/completions", {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${LOVABLE_API_KEY}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        model: "google/gemini-2.5-flash",
        messages: [
          { role: "system", content: "You extract all visible text from an image of a receipt or invoice. Output only the extracted text, preserving line breaks. Do not add commentary." },
          { role: "user", content: [
            { type: "text", text: "Extract all text from this document." },
            { type: "image_url", image_url: { url: dataUrl } },
          ]},
        ],
      }),
    });

    if (!resp.ok) {
      const errText = await resp.text();
      await admin.from("document_attachments").update({ ocr_status: "failed", ocr_processed_at: new Date().toISOString(), ocr_text: `Error: ${errText.slice(0, 500)}` }).eq("id", attachment_id);
      throw new Error(`AI gateway failed [${resp.status}]: ${errText}`);
    }

    const data = await resp.json();
    const text = data?.choices?.[0]?.message?.content || "";

    await admin.from("document_attachments").update({
      ocr_status: "done", ocr_text: text, ocr_processed_at: new Date().toISOString(),
    }).eq("id", attachment_id);

    return new Response(JSON.stringify({ ok: true, length: text.length }), { headers: { ...corsHeaders, "Content-Type": "application/json" } });
  } catch (e: any) {
    console.error("ocr-attachment error:", e);
    return new Response(JSON.stringify({ error: e.message }), { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } });
  }
});
