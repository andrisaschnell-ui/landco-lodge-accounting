import fs from "node:fs";
import path from "node:path";
import { execFileSync } from "node:child_process";
import pkg from "../api/node_modules/pg/lib/index.js";
import { generateATHash, generateQRString } from "../api/lib/atHash.js";

const { Client } = pkg;

const ROOT = path.resolve("C:/Users/Andrisa/Documents/Projects/landco");
const DATABASE_URL =
  process.env.RECOVERY_DATABASE_URL ||
  "postgres://postgres:root@127.0.0.1:5432/landco_v2_db";
const VAT_RATE = Number(process.env.RECOVERY_VAT_RATE || 0.16);

function parseDateValue(value) {
  if (!value) return null;
  if (value instanceof Date && !Number.isNaN(value.getTime())) {
    return value.toISOString().slice(0, 10);
  }
  const asDate = new Date(value);
  if (!Number.isNaN(asDate.getTime())) {
    return asDate.toISOString().slice(0, 10);
  }
  return null;
}

function toNumber(value) {
  if (value == null || value === "") return 0;
  if (typeof value === "number") return value;
  const normalized = String(value).replace(/,/g, "").trim();
  if (!normalized) return 0;
  const parsed = Number(normalized);
  return Number.isFinite(parsed) ? parsed : 0;
}

function loadRecoveryPayload() {
  const cachedPayloadPath = path.join(ROOT, "scripts", "bdo_recovery_payload.json");
  if (fs.existsSync(cachedPayloadPath)) {
    return JSON.parse(fs.readFileSync(cachedPayloadPath, "utf8"));
  }
  const python =
    process.env.CODEX_BUNDLED_PYTHON ||
    "C:\\Users\\Andrisa\\.cache\\codex-runtimes\\codex-primary-runtime\\dependencies\\python\\python.exe";
  const extractor = path.join(ROOT, "scripts", "extract_bdo_recovery.py");
  const stdout = execFileSync(python, [extractor], {
    cwd: ROOT,
    encoding: "utf8",
    maxBuffer: 20 * 1024 * 1024,
  });
  return JSON.parse(stdout);
}

function buildInvoiceNumber(index) {
  return `FT 2026/${String(index).padStart(3, "0")}`;
}

function clampInvoiceDate(dateValue, month, year) {
  const parsed = dateValue ? new Date(dateValue) : null;
  const day = parsed && !Number.isNaN(parsed.getTime()) ? parsed.getUTCDate() : 1;
  const maxDay = new Date(Date.UTC(year, month, 0)).getUTCDate();
  const safeDay = Math.max(1, Math.min(day, maxDay));
  return new Date(Date.UTC(year, month - 1, safeDay)).toISOString().slice(0, 10);
}

async function ensurePettyCashColumns(client) {
  await client.query(`
    ALTER TABLE public.petty_cash_transactions
      ADD COLUMN IF NOT EXISTS reference text,
      ADD COLUMN IF NOT EXISTS supplier text,
      ADD COLUMN IF NOT EXISTS allocation text,
      ADD COLUMN IF NOT EXISTS vat_amount numeric DEFAULT 0,
      ADD COLUMN IF NOT EXISTS net_amount numeric DEFAULT 0,
      ADD COLUMN IF NOT EXISTS source_file text
  `);
}

async function getAndrisaUserId(client) {
  const { rows } = await client.query(`
    SELECT id
    FROM auth.users
    WHERE lower(email) = 'andrisa.schnell@gmail.com'
    ORDER BY created_at
    LIMIT 1
  `);
  if (!rows[0]) throw new Error("Could not find Andrisa user in auth.users.");
  return rows[0].id;
}

async function restorePettyCash(client) {
  const pettyCashRows = loadRecoveryPayload().petty_cash || [];

  await client.query("DELETE FROM public.petty_cash_transactions WHERE year = 2026");

  const insertSql = `
    INSERT INTO public.petty_cash_transactions
      (date, description, credit, debit, balance, month, year, reference, supplier, allocation, vat_amount, net_amount, source_file)
    VALUES
      ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13)
  `;

  for (const row of pettyCashRows) {
    await client.query(insertSql, [
      row.date,
      row.description,
      row.credit,
      row.debit,
      row.balance,
      row.month,
      row.year,
      row.reference,
      row.supplier,
      row.allocation,
      row.vat_amount,
      row.net_amount,
      row.source_file,
    ]);
  }

  return pettyCashRows.length;
}

async function repairIncomeDates(client) {
  await client.query(`
    UPDATE public.income_transactions
    SET date = make_date(
      year,
      month,
      LEAST(
        EXTRACT(day FROM date)::int,
        EXTRACT(day FROM ((make_date(year, month, 1) + INTERVAL '1 month - 1 day')))::int
      )
    )
    WHERE year = 2026
      AND (EXTRACT(year FROM date) <> year OR EXTRACT(month FROM date) <> month)
  `);
}

async function recreateInvoicesAndIncomeJournals(client, issuedBy) {
  await client.query(`
    DELETE FROM public.invoices
    WHERE invoice_date >= DATE '2026-01-01'
      AND invoice_date < DATE '2027-01-01'
  `);

  await client.query(`
    DELETE FROM public.journal_lines
    WHERE journal_entry_id IN (
      SELECT id FROM public.journal_entries
      WHERE entry_type = 'income'
        AND entry_date >= DATE '2026-01-01'
        AND entry_date < DATE '2027-01-01'
    )
  `);

  await client.query(`
    DELETE FROM public.journal_entries
    WHERE entry_type = 'income'
      AND entry_date >= DATE '2026-01-01'
      AND entry_date < DATE '2027-01-01'
  `);

  await client.query(`
    UPDATE public.income_transactions
    SET journal_entry_id = NULL
    WHERE year = 2026
  `);

  const { rows: incomeRows } = await client.query(`
    SELECT id, date, property_id, guest_name, description, accommodation_amount_mzn, amount_usd, month, year
    FROM public.income_transactions
    WHERE year = 2026
    ORDER BY month, date, created_at, id
  `);

  const { rows: accountRows } = await client.query(`
    SELECT code, id FROM public.accounts WHERE code IN ('211', '243', '711')
  `);
  const accountIds = Object.fromEntries(accountRows.map((row) => [row.code, row.id]));

  if (!accountIds["211"] || !accountIds["243"] || !accountIds["711"]) {
    throw new Error("Required accounts 211, 243, and 711 must exist before invoice recovery.");
  }

  let previousHash = "";
  let counter = 1;

  for (const tx of incomeRows) {
    const grossTotal = Number(tx.accommodation_amount_mzn || 0);
    const subtotal = Number((grossTotal / (1 + VAT_RATE)).toFixed(2));
    const vatAmount = Number((grossTotal - subtotal).toFixed(2));
    const invoiceDate = clampInvoiceDate(tx.date, tx.month, tx.year);
    const createdAt = new Date(`${invoiceDate}T12:00:00.000Z`).toISOString();
    const invoiceNumber = buildInvoiceNumber(counter);
    const clientName =
      (tx.guest_name && String(tx.guest_name).trim()) ||
      (tx.description && String(tx.description).trim()) ||
      "Accommodation client";
    const lineDescription =
      (tx.description && String(tx.description).trim()) ||
      (tx.guest_name && `Accommodation - ${String(tx.guest_name).trim()}`) ||
      "Accommodation services";

    const invoiceForHash = {
      invoice_date: invoiceDate,
      created_at: createdAt,
      invoice_number: invoiceNumber,
      total_mzn: grossTotal,
      previous_hash: previousHash,
    };
    const atHash = generateATHash(invoiceForHash);
    const qrString = generateQRString({
      ...invoiceForHash,
      invoice_series: "FT",
      client_nuit: null,
      vat_amount_mzn: vatAmount,
      at_hash: atHash,
    });

    const { rows: journalRows } = await client.query(
      `
        INSERT INTO public.journal_entries
          (entry_date, reference, description, entry_type, property_id, posted, posted_at, posted_by, created_by)
        VALUES
          ($1, $2, $3, 'income', $4, true, now(), $5, $5)
        RETURNING id
      `,
      [
        invoiceDate,
        invoiceNumber,
        `Invoice ${invoiceNumber}: ${clientName}`,
        tx.property_id,
        issuedBy,
      ]
    );

    const journalEntryId = journalRows[0].id;

    await client.query(
      `
        INSERT INTO public.journal_lines
          (journal_entry_id, account_id, debit, credit, memo)
        VALUES
          ($1, $2, $3, 0, $4),
          ($1, $5, 0, $6, $7),
          ($1, $8, 0, $9, $10)
      `,
      [
        journalEntryId,
        accountIds["211"],
        grossTotal,
        `Invoice receivable ${invoiceNumber}`,
        accountIds["711"],
        subtotal,
        lineDescription,
        accountIds["243"],
        vatAmount,
        `VAT ${Math.round(VAT_RATE * 100)}%`,
      ]
    );

    const lineItems = [
      {
        description: lineDescription,
        quantity: 1,
        unit_price: subtotal,
        vat_rate: VAT_RATE,
        vat_amount: vatAmount,
        line_total: grossTotal,
      },
    ];

    const { rows: invoiceRows } = await client.query(
      `
        INSERT INTO public.invoices
          (invoice_number, invoice_series, invoice_date, due_date, property_id, client_name, client_nuit, client_address,
           line_items, subtotal_mzn, vat_amount_mzn, total_mzn, currency, exchange_rate, status,
           at_hash, at_qr_code, journal_entry_id, income_tx_id, issued_by, created_at, updated_at)
        VALUES
          ($1, 'FT', $2, $2, $3, $4, NULL, NULL, $5::jsonb, $6, $7, $8, 'MZN', 1, 'issued',
           $9, $10, $11, $12, $13, $14, $14)
        RETURNING id
      `,
      [
        invoiceNumber,
        invoiceDate,
        tx.property_id,
        clientName,
        JSON.stringify(lineItems),
        subtotal,
        vatAmount,
        grossTotal,
        atHash,
        qrString,
        journalEntryId,
        tx.id,
        issuedBy,
        createdAt,
      ]
    );

    await client.query(
      `UPDATE public.income_transactions SET journal_entry_id = $1 WHERE id = $2`,
      [journalEntryId, tx.id]
    );

    previousHash = atHash;
    counter += 1;
  }

  return counter - 1;
}

async function main() {
  const client = new Client({ connectionString: DATABASE_URL });
  await client.connect();

  try {
    await client.query("BEGIN");
    await ensurePettyCashColumns(client);
    const issuedBy = await getAndrisaUserId(client);
    const pettyCashCount = await restorePettyCash(client);
    await repairIncomeDates(client);
    const invoiceCount = await recreateInvoicesAndIncomeJournals(client, issuedBy);
    await client.query("COMMIT");

    console.log(
      JSON.stringify(
        {
          pettyCashRestored: pettyCashCount,
          invoicesCreated: invoiceCount,
          journalEntriesCreated: invoiceCount,
          notes: [
            "Petty cash rows restored from BDO monthly control workbooks.",
            "2026 income dates realigned to their year/month fields before invoice generation.",
            "Invoices issued sequentially from FT 2026/001 and linked to balanced journal entries.",
          ],
        },
        null,
        2
      )
    );
  } catch (error) {
    await client.query("ROLLBACK");
    console.error(error);
    process.exitCode = 1;
  } finally {
    await client.end();
  }
}

await main();
