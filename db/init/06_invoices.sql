CREATE TABLE IF NOT EXISTS public.invoices (
  id               uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  invoice_number   text NOT NULL UNIQUE,       -- sequential: FT 2026/001
  invoice_series   text NOT NULL DEFAULT 'FT', -- FT=Fatura, FR=Fatura-Recibo
  invoice_date     date NOT NULL,
  due_date         date,
  property_id      uuid REFERENCES public.properties(id),
  client_name      text NOT NULL,
  client_nuit      text,                       -- Tax ID of client
  client_address   text,
  line_items       jsonb NOT NULL DEFAULT '[]',-- [{desc, qty, unit, vat_rate, amount}]
  subtotal_mzn     numeric NOT NULL DEFAULT 0,
  vat_amount_mzn   numeric NOT NULL DEFAULT 0, -- IVA
  total_mzn        numeric NOT NULL DEFAULT 0,
  currency         text NOT NULL DEFAULT 'MZN',
  exchange_rate    numeric DEFAULT 1,
  status           text NOT NULL DEFAULT 'draft', -- draft, issued, paid, cancelled
  at_hash          text,                       -- AT validation hash
  at_qr_code       text,                       -- QR code string for AT
  journal_entry_id uuid REFERENCES public.journal_entries(id),
  income_tx_id     uuid REFERENCES public.income_transactions(id),
  issued_by        uuid REFERENCES auth.users(id),
  created_at       timestamptz NOT NULL DEFAULT now(),
  updated_at       timestamptz NOT NULL DEFAULT now()
);

-- Sequential invoice number generator
CREATE SEQUENCE IF NOT EXISTS invoice_seq START 1;

CREATE OR REPLACE FUNCTION public.next_invoice_number(series text, yr integer)
RETURNS text LANGUAGE sql AS $$
  SELECT series || ' ' || yr || '/' || LPAD(nextval('invoice_seq')::text, 3, '0')
$$;
