import { useEffect, useState } from "react";
import { Link } from "react-router-dom";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Wallet, Smartphone, CreditCard, Banknote } from "lucide-react";
import { supabase } from "@/integrations/supabase/client";

interface Summary { count: number; sheets: number; lastMonth: string; opening: number; }

const fmt = (n: number) => n.toLocaleString(undefined, { minimumFractionDigits: 2, maximumFractionDigits: 2 });

const CARDS = [
  { key: "petty_cash",  title: "Cash Ebony",   desc: "Money Box Ebony — cheques & cash",   icon: Wallet },
  { key: "cash_landco", title: "Cash Landco",  desc: "Money Box Landco — cheques & cash",  icon: Banknote },
  { key: "emola",       title: "Emola One",    desc: "Mobile payments (account 1)",        icon: Smartphone },
  { key: "emola_two",   title: "Emola Two",    desc: "Mobile payments (account 2)",        icon: Smartphone },
  { key: "mpesa",       title: "Mpesa One",    desc: "Mobile payments (account 1)",        icon: CreditCard },
  { key: "mpesa_two",   title: "Mpesa Two",    desc: "Mobile payments (account 2)",        icon: CreditCard },
  { key: "bim",         title: "BIM",          desc: "BIM bank account — cheques & transfers", icon: CreditCard },
  { key: "bci",         title: "BCI",          desc: "BCI bank account — cheques & transfers", icon: CreditCard },
] as const;

export default function CashControl() {
  const [summaries, setSummaries] = useState<Record<string, Summary>>({});
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    (async () => {
      const out: Record<string, Summary> = {};
      for (const c of CARDS) {
        const { data: sheets } = await supabase
          .from("cash_sheets")
          .select("id, month, year, opening_balance")
          .eq("sheet_type", c.key)
          .order("year", { ascending: false })
          .order("month", { ascending: false });
        const { count } = await supabase
          .from("cash_transactions")
          .select("id", { count: "exact", head: true })
          .eq("sheet_type", c.key);
        const latest = sheets?.[0];
        out[c.key] = {
          count: count ?? 0,
          sheets: sheets?.length ?? 0,
          lastMonth: latest ? `${latest.month ? String(latest.month).padStart(2, "0") + "/" : ""}${latest.year}` : "—",
          opening: latest?.opening_balance ?? 0,
        };
      }
      setSummaries(out);
      setLoading(false);
    })();
  }, []);

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold">Cash Control Uploaded</h1>
        <p className="text-muted-foreground">Personal notebook for cash and mobile payments. Not linked to accounting.</p>
      </div>

      <div className="grid gap-4 md:grid-cols-3">
        {CARDS.map((c) => {
          const s = summaries[c.key];
          return (
            <Link key={c.key} to={`/cash-control/display/${c.key}`}>
              <Card className="hover:shadow-md transition-shadow cursor-pointer h-full">
                <CardHeader>
                  <div className="flex items-center justify-between">
                    <CardTitle className="flex items-center gap-2"><c.icon className="h-5 w-5 text-primary" /> {c.title}</CardTitle>
                    <Badge variant="secondary">{s?.sheets ?? 0} sheets</Badge>
                  </div>
                  <CardDescription>{c.desc}</CardDescription>
                </CardHeader>
                <CardContent className="space-y-1 text-sm">
                  <div className="flex justify-between"><span className="text-muted-foreground">Transactions</span><span className="font-medium">{s?.count ?? 0}</span></div>
                  <div className="flex justify-between"><span className="text-muted-foreground">Latest period</span><span className="font-medium">{s?.lastMonth ?? "—"}</span></div>
                  <div className="flex justify-between"><span className="text-muted-foreground">Latest opening</span><span className="font-medium">{loading ? "…" : fmt(s?.opening ?? 0)}</span></div>
                </CardContent>
              </Card>
            </Link>
          );
        })}
      </div>
    </div>
  );
}
