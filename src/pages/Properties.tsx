import { useQuery } from "@tanstack/react-query";
import { supabase } from "@/integrations/supabase/client";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Badge } from "@/components/ui/badge";
import { HelpPopover } from "@/components/HelpPopover";

export default function Properties() {
  const { data: properties } = useQuery({
    queryKey: ["properties"],
    queryFn: async () => {
      const { data } = await supabase.from("properties").select("*").order("code");
      return data ?? [];
    },
  });

  const { data: exchangeRates } = useQuery({
    queryKey: ["exchange-rates"],
    queryFn: async () => {
      const { data } = await supabase.from("exchange_rates").select("*").order("year", { ascending: false }).order("month", { ascending: false });
      return data ?? [];
    },
  });

  return (
    <div className="space-y-6">
      <div className="flex items-center gap-2"><h1 className="text-3xl font-bold">Properties & Settings</h1><HelpPopover route="/properties" size={18} /></div>

      <Card>
        <CardHeader><CardTitle>Properties</CardTitle></CardHeader>
        <CardContent>
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Code</TableHead>
                <TableHead>Name</TableHead>
                <TableHead>Description</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {properties?.map((p) => (
                <TableRow key={p.id}>
                  <TableCell><Badge variant="outline">{p.code}</Badge></TableCell>
                  <TableCell className="font-medium">{p.name}</TableCell>
                  <TableCell>{p.description ?? "—"}</TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </CardContent>
      </Card>

      <Card>
        <CardHeader><CardTitle>Exchange Rates</CardTitle></CardHeader>
        <CardContent>
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Month</TableHead>
                <TableHead>Year</TableHead>
                <TableHead className="text-right">MZN / USD</TableHead>
                <TableHead className="text-right">MZN / ZAR</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {exchangeRates?.map((r) => (
                <TableRow key={r.id}>
                  <TableCell>{r.month}</TableCell>
                  <TableCell>{r.year}</TableCell>
                  <TableCell className="text-right">{r.mzn_per_usd}</TableCell>
                  <TableCell className="text-right">{r.mzn_per_zar ?? "—"}</TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </CardContent>
      </Card>
    </div>
  );
}
