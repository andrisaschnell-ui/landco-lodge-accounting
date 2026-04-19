import { useQuery } from "@tanstack/react-query";
import { supabase } from "@/integrations/supabase/client";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Badge } from "@/components/ui/badge";

function formatMZN(v: number) {
  return new Intl.NumberFormat("en-US", { minimumFractionDigits: 2 }).format(v);
}

export default function Employees() {
  const { data: employees } = useQuery({
    queryKey: ["employees"],
    queryFn: async () => {
      const { data } = await supabase.from("employees").select("*").order("house_assignment").order("name");
      return data ?? [];
    },
  });

  return (
    <div className="space-y-6">
      <h1 className="text-3xl font-bold">Employees</h1>
      <Card>
        <CardHeader><CardTitle>Staff Register — {employees?.length ?? 0} Employees</CardTitle></CardHeader>
        <CardContent>
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>#</TableHead>
                <TableHead>House</TableHead>
                <TableHead>Name</TableHead>
                <TableHead>Category</TableHead>
                <TableHead>NIB</TableHead>
                <TableHead className="text-right">Base Salary</TableHead>
                <TableHead className="text-right">Food Allow.</TableHead>
                <TableHead>Status</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {employees?.map((e, i) => (
                <TableRow key={e.id}>
                  <TableCell>{i + 1}</TableCell>
                  <TableCell><Badge variant="outline">{e.house_assignment ?? "—"}</Badge></TableCell>
                  <TableCell className="font-medium">{e.name}</TableCell>
                  <TableCell>{e.category}</TableCell>
                  <TableCell className="font-mono text-xs">{e.nib}</TableCell>
                  <TableCell className="text-right">{formatMZN(e.base_salary)}</TableCell>
                  <TableCell className="text-right">{formatMZN(e.food_allowance ?? 0)}</TableCell>
                  <TableCell>
                    <Badge variant={e.is_active ? "default" : "secondary"}>
                      {e.is_active ? "Active" : "Inactive"}
                    </Badge>
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </CardContent>
      </Card>
    </div>
  );
}
