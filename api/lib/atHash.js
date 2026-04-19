import crypto from 'crypto';

/**
 * Generates the validation hash required by the Mozambique Tax Authority (AT).
 * Chain hash implementation: Each invoice includes the hash of the previous one.
 */
export function generateATHash(invoice) {
  // Fields required by AT for hash: date, systemDate, invoiceNumber, grossTotal, previousHash
  const fields = [
    invoice.invoice_date,
    invoice.created_at,
    invoice.invoice_number,
    Number(invoice.total_mzn).toFixed(2),
    invoice.previous_hash || ''
  ].join(';');

  return crypto
    .createHmac('sha256', process.env.AT_SIGNING_KEY || 'default-secret-key-2026')
    .update(fields)
    .digest('base64')
    .slice(0, 8); // AT uses the first 8 characters of the hash
}

/**
 * Generates the QR code string according to AT Mozambique specification.
 */
export function generateQRString(invoice) {
  const companyNUIT = process.env.COMPANY_NUIT || '123456789';
  
  return [
    `A:${companyNUIT}`,
    `B:${invoice.client_nuit || '999999999'}`,
    `C:MZ`,                        // country
    `D:${invoice.invoice_series}`, // doc type (FT, FR, etc)
    `E:N`,                         // document status
    `F:${invoice.invoice_date.replace(/-/g,'')}`,
    `G:${invoice.invoice_number}`,
    `H:${invoice.at_hash}`,
    `I1:MZ`,
    `N:${Number(invoice.vat_amount_mzn).toFixed(2)}`,
    `O:${Number(invoice.total_mzn).toFixed(2)}`,
    `Q:${invoice.at_hash}`
  ].join('*');
}
