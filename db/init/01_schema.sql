-- ============================================================
-- LANACC — Minimal Schema for Core Auth
-- ============================================================

CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ----- SUPABASE ROLES (Mock) -----
DO $$ BEGIN
  IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'authenticated') THEN
    CREATE ROLE authenticated;
  END IF;
  IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'anon') THEN
    CREATE ROLE anon;
  END IF;
  IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'service_role') THEN
    CREATE ROLE service_role;
  END IF;
END $$;

-- ----- ENUMS -----
DO $$ BEGIN
  CREATE TYPE public.app_role AS ENUM ('admin','viewer');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- ----- AUTH SCHEMAS -----
CREATE SCHEMA IF NOT EXISTS auth;

CREATE TABLE IF NOT EXISTS auth.users (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  email         text UNIQUE NOT NULL,
  password_hash text NOT NULL,
  display_name  text,
  created_at    timestamptz NOT NULL DEFAULT now(),
  updated_at    timestamptz NOT NULL DEFAULT now()
);

-- Mock auth.uid()
CREATE OR REPLACE FUNCTION auth.uid() RETURNS uuid AS $$
  SELECT NULL::uuid; -- Local API doesn't use DB-level RLS context like Supabase
$$ LANGUAGE sql STABLE;

-- Note: All other public tables will be created by the 02_data.sql dump.
