import jsPDF from "jspdf";
import autoTable from "jspdf-autotable";
import * as XLSX from "xlsx";

export type Column = { header: string; key: string; align?: "left" | "right" | "center" };

export function exportToPdf(opts: {
  title: string;
  subtitle?: string;
  columns: Column[];
  rows: any[];
  filename: string;
  totals?: Record<string, number | string>;
}) {
  const doc = new jsPDF({ orientation: "landscape" });
  doc.setFontSize(14);
  doc.text(opts.title, 14, 16);
  if (opts.subtitle) {
    doc.setFontSize(10);
    doc.setTextColor(100);
    doc.text(opts.subtitle, 14, 22);
  }
  const head = [opts.columns.map(c => c.header)];
  const body = opts.rows.map(r => opts.columns.map(c => formatCell(r[c.key])));
  if (opts.totals) {
    body.push(opts.columns.map(c => (opts.totals![c.key] !== undefined ? formatCell(opts.totals![c.key]) : "")));
  }
  autoTable(doc, {
    head,
    body,
    startY: opts.subtitle ? 26 : 20,
    styles: { fontSize: 8 },
    headStyles: { fillColor: [40, 80, 120] },
    columnStyles: opts.columns.reduce((acc, c, i) => {
      if (c.align) acc[i] = { halign: c.align };
      return acc;
    }, {} as any),
  });
  doc.save(opts.filename.endsWith(".pdf") ? opts.filename : `${opts.filename}.pdf`);
}

export function exportToExcel(opts: {
  sheetName: string;
  columns: Column[];
  rows: any[];
  filename: string;
  totals?: Record<string, number | string>;
}) {
  const data: any[] = opts.rows.map(r => {
    const o: any = {};
    opts.columns.forEach(c => (o[c.header] = r[c.key]));
    return o;
  });
  if (opts.totals) {
    const t: any = {};
    opts.columns.forEach(c => (t[c.header] = opts.totals![c.key] ?? ""));
    data.push(t);
  }
  const ws = XLSX.utils.json_to_sheet(data);
  const wb = XLSX.utils.book_new();
  XLSX.utils.book_append_sheet(wb, ws, opts.sheetName.slice(0, 30));
  XLSX.writeFile(wb, opts.filename.endsWith(".xlsx") ? opts.filename : `${opts.filename}.xlsx`);
}

function formatCell(v: any): string {
  if (v === null || v === undefined || v === "") return "";
  if (typeof v === "number") return v.toLocaleString(undefined, { minimumFractionDigits: 2, maximumFractionDigits: 2 });
  return String(v);
}
