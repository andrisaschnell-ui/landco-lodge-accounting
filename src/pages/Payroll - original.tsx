import { useQuery } from "@tanstack/react-query";
import { db } from "@/lib/db";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Badge } from "@/components/ui/badge";

function formatMZN(v: number) {
  return new Intl.NumberFormat("en-US", { minimumFractionDigits: 2 }).format(v);
}

const MONTH_NAMES = ["", "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];

export default function Payroll() {
  const { data: salaryRuns } = useQuery({
    queryKey: ["salary-runs"],
    queryFn: async () => {
      const { data } = await db.from("salary_runs").select("*").order("year", { ascending: false }).order("month", { ascending: false });
      return data ?? [];
    },
  });

  const { data: salaryLines } = useQuery({
    queryKey: ["salary-lines"],
    queryFn: async () => {
      const { data } = await db.from("salary_lines").select("*, employees(name, house_assignment)").order("created_at");
      return data ?? [];
    },
  });

  return (
    <div className="space-y-6">
      <h1 className="text-3xl font-bold">Payroll</h1>

      {salaryRuns && salaryRuns.length > 0 ? (
        salaryRuns.map((run) => {
          const lines = salaryLines?.filter((l: any) => l.salary_run_id === run.id) ?? [];
          return (
            <Card key={run.id}>
              <CardHeader>
                <div className="flex items-center justify-between">
                  <CardTitle>{MONTH_NAMES[run.month]} {run.year} — Folha de Salários</CardTitle>
                  <Badge variant={run.status === "final" ? "default" : "secondary"}>{run.status}</Badge>
                </div>
                <div className="flex gap-4 text-sm text-muted-foreground">
                  <span>Gross: MZN {formatMZN(run.total_gross)}</span>
                  <span>Net: MZN {formatMZN(run.total_net)}</span>
                  <span>INSS: MZN {formatMZN(run.total_inss_employee + run.total_inss_employer)}</span>
                  <span>IRPS: MZN {formatMZN(run.total_irps)}</span>
                </div>
              </CardHeader>
              <CardContent>
                {lines.length > 0 ? (
                  <div className="overflow-x-auto">
                    <Table>
                      <TableHeader>
                        <TableRow>
                          <TableHead>#</TableHead>
                          <TableHead>House</TableHead>
                          <TableHead>Name</TableHead>
                          <TableHead className="text-right">Base</TableHead>
                          <TableHead className="text-right">Gross</TableHead>
                          <TableHead className="text-right">IRPS</TableHead>
                          <TableHead className="text-right">INSS</TableHead>
                          <TableHead className="text-right">Advance</TableHead>
                          <TableHead className="text-right">Deductions</TableHead>
                          <TableHead className="text-right">Net</TableHead>
                        </TableRow>
                      </TableHeader>
                      <TableBody>
                        {lines.map((l: any, i: number) => (
                          <TableRow key={l.id}>
                            <TableCell>{i + 1}</TableCell>
                            <TableCell>{l.employees?.house_assignment ?? "—"}</TableCell>
                            <TableCell className="font-medium">{l.employees?.name}</TableCell>
                            <TableCell className="text-right">{formatMZN(l.base_salary)}</TableCell>
                            <TableCell className="text-right">{formatMZN(l.gross_total)}</TableCell>
                            <TableCell className="text-right">{formatMZN(l.irps)}</TableCell>
                            <TableCell className="text-right">{formatMZN(l.inss_employee)}</TableCell>
                            <TableCell className="text-right">{formatMZN(l.advance)}</TableCell>
                            <TableCell className="text-right">{formatMZN(l.total_deductions)}</TableCell>
                            <TableCell className="text-right font-bold">{formatMZN(l.net_salary)}</TableCell>
                          </TableRow>
                        ))}
                      </TableBody>
                    </Table>
                  </div>
                ) : (
                  <p className="text-muted-foreground text-center py-4">No salary lines.</p>
                )}
              </CardContent>
            </Card>
          );
        })
      ) : (
        <Card>
          <CardContent className="py-12 text-center text-muted-foreground">
            No payroll runs yet. Upload salary sheets to populate.
          </CardContent>
        </Card>
      )}
    </div>
  );
}
