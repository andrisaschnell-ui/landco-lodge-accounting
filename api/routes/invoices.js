import express from 'express';
import PDFDocument from 'pdfkit';
import QRCode from 'qrcode';
import { generateATHash, generateQRString } from '../lib/atHash.js';

const router = express.Router();

export default function(pool, TABLES, requireAuth) {

  // GET /api/invoices - list invoices
  router.get('/', requireAuth, async (req, res) => {
    try {
      const { rows } = await pool.query(`
        SELECT i.*, p.name as property_name
        FROM public.invoices i
        LEFT JOIN public.properties p ON p.id = i.property_id
        ORDER BY i.created_at DESC
      `);
      res.json(rows);
    } catch (e) { res.status(500).json({ error: e.message }); }
  });

  // POST /api/invoices - create draft
  router.post('/', requireAuth, async (req, res) => {
    if (!req.user.roles?.includes("admin")) return res.status(403).json({ error: "admin only" });
    const { invoice_date, property_id, client_name, client_nuit, client_address, line_items, currency } = req.body;
    
    // Calculate totals
    let subtotal = 0;
    let vat_total = 0;
    line_items.forEach(item => {
      subtotal += item.quantity * item.unit_price;
      vat_total += (item.vat_rate || 0) * (item.quantity * item.unit_price);
    });

    try {
      const { rows } = await pool.query(`
        INSERT INTO public.invoices 
          (invoice_number, invoice_date, property_id, client_name, client_nuit, client_address, 
           line_items, subtotal_mzn, vat_amount_mzn, total_mzn, currency, status, issued_by)
        VALUES ('DRAFT-' || gen_random_uuid(), $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, 'draft', $11)
        RETURNING *
      `, [invoice_date || new Date(), property_id || null, client_name, client_nuit, client_address || '', 
          JSON.stringify(line_items), subtotal_mzn || subtotal, vat_amount_mzn || vat_total, total_mzn || (subtotal + vat_total), currency || 'MZN', req.user.sub]);
      
      res.json(rows[0]);
    } catch (e) { res.status(500).json({ error: e.message }); }
  });

  // POST /api/invoices/:id/issue - finalize and assign AT hash
  router.post('/:id/issue', requireAuth, async (req, res) => {
    const client = await pool.connect();
    try {
      await client.query('BEGIN');
      
      const { rows: [inv] } = await client.query('SELECT * FROM public.invoices WHERE id = $1 FOR UPDATE', [req.params.id]);
      if (!inv) throw new Error("invoice not found");
      if (inv.status !== 'draft') throw new Error("only draft invoices can be issued");

      const year = new Date(inv.invoice_date).getFullYear();
      const { rows: [numPart] } = await client.query("SELECT public.next_invoice_number('FT', $1) as num", [year]);
      const nextNum = numPart.num;

      // Get previous hash for chain
      const { rows: [prev] } = await client.query('SELECT at_hash FROM public.invoices WHERE status != $1 ORDER BY created_at DESC LIMIT 1', ['draft']);
      const prevHash = prev ? prev.at_hash : '';

      const updatedInv = { ...inv, invoice_number: nextNum, previous_hash: prevHash };
      const hash = generateATHash(updatedInv);
      const qr = generateQRString({ ...updatedInv, at_hash: hash });

      await client.query(`
        UPDATE public.invoices 
        SET status = 'issued', invoice_number = $2, at_hash = $3, at_qr_code = $4, updated_at = now()
        WHERE id = $1
      `, [req.params.id, nextNum, hash, qr]);

      await client.query('COMMIT');
      res.json({ id: inv.id, invoice_number: nextNum, status: 'issued' });
    } catch (e) {
      await client.query('ROLLBACK');
      res.status(500).json({ error: e.message });
    } finally {
      client.release();
    }
  });

  // GET /api/invoices/:id/pdf
  router.get('/:id/pdf', requireAuth, async (req, res) => {
    try {
      const { rows: [inv] } = await pool.query('SELECT * FROM public.invoices WHERE id = $1', [req.params.id]);
      if (!inv) return res.status(404).json({ error: "not found" });

      const doc = new PDFDocument({ margin: 50 });
      res.setHeader('Content-Type', 'application/pdf');
      res.setHeader('Content-Disposition', `attachment; filename="Invoice_${inv.invoice_number}.pdf"`);
      doc.pipe(res);

      // Header
      doc.fontSize(20).text(process.env.COMPANY_NAME || 'Landco Lodge Lda', { align: 'left' });
      doc.fontSize(10).text(`NUIT: ${process.env.COMPANY_NUIT || '123456789'}`);
      doc.text(process.env.COMPANY_ADDRESS || 'Vilanculos, Mozambique');
      doc.moveDown();

      doc.fontSize(16).text(`FATURA — ${inv.invoice_number}`, { align: 'right' });
      doc.fontSize(10).text(`Data: ${new Date(inv.invoice_date).toLocaleDateString()}`, { align: 'right' });
      doc.moveDown();

      doc.text(`Cliente: ${inv.client_name}`);
      if (inv.client_nuit) doc.text(`NUIT: ${inv.client_nuit}`);
      doc.text(inv.client_address || '');
      doc.moveDown();

      // Table Header
      const tableTop = 250;
      doc.font('Helvetica-Bold');
      doc.text('Descrição', 50, tableTop);
      doc.text('Qtd', 300, tableTop);
      doc.text('Preço Unit', 350, tableTop);
      doc.text('IVA', 430, tableTop);
      doc.text('Total', 500, tableTop);
      doc.moveDown();
      doc.font('Helvetica');

      let y = tableTop + 20;
      const items = inv.line_items; // JSONB is already parsed in pg
      items.forEach(item => {
        const lineTotal = item.quantity * item.unit_price * (1 + (item.vat_rate || 0));
        doc.text(item.description, 50, y);
        doc.text(item.quantity.toString(), 300, y);
        doc.text(item.unit_price.toFixed(2), 350, y);
        doc.text(`${((item.vat_rate || 0) * 100)}%`, 430, y);
        doc.text(lineTotal.toFixed(2), 500, y);
        y += 20;
      });

      doc.moveDown();
      doc.fontSize(12).text(`Subtotal: ${Number(inv.subtotal_mzn).toFixed(2)} MZN`, { align: 'right' });
      doc.text(`IVA Total: ${Number(inv.vat_amount_mzn).toFixed(2)} MZN`, { align: 'right' });
      doc.font('Helvetica-Bold').text(`TOTAL: ${Number(inv.total_mzn).toFixed(2)} MZN`, { align: 'right' });

      if (inv.at_hash) {
        doc.moveDown(2);
        const qrBuffer = await QRCode.toBuffer(inv.at_qr_code);
        doc.image(qrBuffer, 50, doc.y, { width: 100 });
        doc.fontSize(8).text(`Hash: ${inv.at_hash}`, 160, doc.y + 40);
        doc.text('Processado por programa certificado n.º 0000/AT', 160, doc.y + 10);
      }

      doc.end();
    } catch (e) { res.status(500).json({ error: e.message }); }
  });

  return router;
}
