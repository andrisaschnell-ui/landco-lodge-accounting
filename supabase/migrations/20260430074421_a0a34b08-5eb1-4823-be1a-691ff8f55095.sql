-- 1. company_settings table (singleton)
CREATE TABLE public.company_settings (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  singleton boolean NOT NULL DEFAULT true UNIQUE,
  name text NOT NULL DEFAULT 'Landco Lda',
  nuit text,
  address text,
  logo_url text,
  currency text NOT NULL DEFAULT 'MZN',
  vat_rate numeric NOT NULL DEFAULT 16,
  invoice_series_prefix text NOT NULL DEFAULT 'FT',
  fiscal_year_start_month integer NOT NULL DEFAULT 1 CHECK (fiscal_year_start_month BETWEEN 1 AND 12),
  primary_color text NOT NULL DEFAULT '142 71% 45%',
  accent_color text NOT NULL DEFAULT '210 40% 50%',
  backup_folder_path text,
  sync_target_ref text,
  default_property_id uuid,
  default_shareholder_id uuid,
  updated_by uuid,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT singleton_true CHECK (singleton = true)
);

ALTER TABLE public.company_settings ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Auth can view company_settings"
  ON public.company_settings FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Admins can insert company_settings"
  ON public.company_settings FOR INSERT
  TO authenticated
  WITH CHECK (has_role(auth.uid(), 'admin'::app_role));

CREATE POLICY "Admins can update company_settings"
  ON public.company_settings FOR UPDATE
  TO authenticated
  USING (has_role(auth.uid(), 'admin'::app_role))
  WITH CHECK (has_role(auth.uid(), 'admin'::app_role));

CREATE TRIGGER trg_company_settings_updated_at
  BEFORE UPDATE ON public.company_settings
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- Seed Landco defaults
INSERT INTO public.company_settings (name, nuit, address, currency, vat_rate, invoice_series_prefix)
VALUES ('Landco Lda', NULL, 'Vilanculos, Mozambique', 'MZN', 16, 'FT');

-- 2. Storage bucket for logo / branding assets
INSERT INTO storage.buckets (id, name, public)
VALUES ('company-assets', 'company-assets', true)
ON CONFLICT (id) DO NOTHING;

CREATE POLICY "Public can read company-assets"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'company-assets');

CREATE POLICY "Admins can upload company-assets"
  ON storage.objects FOR INSERT
  TO authenticated
  WITH CHECK (bucket_id = 'company-assets' AND has_role(auth.uid(), 'admin'::app_role));

CREATE POLICY "Admins can update company-assets"
  ON storage.objects FOR UPDATE
  TO authenticated
  USING (bucket_id = 'company-assets' AND has_role(auth.uid(), 'admin'::app_role));

CREATE POLICY "Admins can delete company-assets"
  ON storage.objects FOR DELETE
  TO authenticated
  USING (bucket_id = 'company-assets' AND has_role(auth.uid(), 'admin'::app_role));