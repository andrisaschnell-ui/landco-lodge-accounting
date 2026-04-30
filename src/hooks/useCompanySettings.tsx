import { createContext, useContext, useEffect, useState, ReactNode, useCallback } from "react";
import { supabase } from "@/integrations/supabase/client";

export interface CompanySettings {
  id: string;
  name: string;
  nuit: string | null;
  address: string | null;
  logo_url: string | null;
  currency: string;
  vat_rate: number;
  invoice_series_prefix: string;
  fiscal_year_start_month: number;
  primary_color: string;
  accent_color: string;
  backup_folder_path: string | null;
  sync_target_ref: string | null;
  default_property_id: string | null;
  default_shareholder_id: string | null;
  updated_at: string;
}

interface Ctx {
  settings: CompanySettings | null;
  loading: boolean;
  refresh: () => Promise<void>;
  update: (patch: Partial<CompanySettings>) => Promise<{ error: string | null }>;
}

const CompanySettingsContext = createContext<Ctx>({
  settings: null,
  loading: true,
  refresh: async () => {},
  update: async () => ({ error: null }),
});

function applyTheme(s: CompanySettings | null) {
  if (!s) return;
  const root = document.documentElement;
  if (s.primary_color) root.style.setProperty("--primary", s.primary_color);
  if (s.accent_color) root.style.setProperty("--accent", s.accent_color);
  if (s.name) document.title = s.name;
}

export function CompanySettingsProvider({ children }: { children: ReactNode }) {
  const [settings, setSettings] = useState<CompanySettings | null>(null);
  const [loading, setLoading] = useState(true);

  const refresh = useCallback(async () => {
    const { data, error } = await supabase
      .from("company_settings")
      .select("*")
      .limit(1)
      .maybeSingle();
    if (!error && data) {
      setSettings(data as CompanySettings);
      applyTheme(data as CompanySettings);
    }
    setLoading(false);
  }, []);

  const update = useCallback(async (patch: Partial<CompanySettings>) => {
    if (!settings) return { error: "No settings loaded" };
    const { data, error } = await supabase
      .from("company_settings")
      .update(patch)
      .eq("id", settings.id)
      .select()
      .single();
    if (error) return { error: error.message };
    setSettings(data as CompanySettings);
    applyTheme(data as CompanySettings);
    return { error: null };
  }, [settings]);

  useEffect(() => { refresh(); }, [refresh]);

  return (
    <CompanySettingsContext.Provider value={{ settings, loading, refresh, update }}>
      {children}
    </CompanySettingsContext.Provider>
  );
}

export const useCompanySettings = () => useContext(CompanySettingsContext);
