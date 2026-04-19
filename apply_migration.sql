-- Add missing columns to salary_lines table
ALTER TABLE public.salary_lines ADD COLUMN IF NOT EXISTS guardas_25 numeric DEFAULT 0;
ALTER TABLE public.salary_lines ADD COLUMN IF NOT EXISTS category text DEFAULT NULL;
