import { useQuery } from "@tanstack/react-query";
import { supabase } from "@/integrations/supabase/client";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Badge } from "@/components/ui/badge";

function formatMZN(v: number) {
  return new Intl.NumberFormat("en-US", { minimumFractionDigits: 2 }).format(v);
}

const MONTH_NAMES = ["", "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];

import { Download, FileSpreadsheet } from "lucide-react";
import { Button } from "@/components/ui/button";

export default function Payroll() {
  const { data: salaryRuns } = useQuery({
    queryKey: ["salary-runs"],
    queryFn: async () => {
      const { data } = await supabase
        .from("salary_runs")
        .select("*")
        .order("year", { ascending: false })
        .order("month", { ascending: false });
      return data ?? [];
    },
  });

  const { data: salaryLines } = useQuery({
    queryKey: ["salary-lines"],
    queryFn: async () => {
      const { data } = await supabase
        .from("salary_lines")
        .select("*, employees(name, house_assignment, nib)")
        .order("created_at");
      return data ?? [];
    },
  });

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <h1 className="text-3xl font-bold tracking-tight">Folha de Salários</h1>
      </div>

      {salaryRuns && salaryRuns.length > 0 ? (
        salaryRuns.map((run) => {
          const lines = salaryLines?.filter((l: any) => l.salary_run_id === run.id) ?? [];
          
          // House Totals Summary (Matching the bottom logic)
          const totalsByHouse = lines.reduce((acc: any, curr: any) => {
            const house = curr.employees?.house_assignment || "LC";
            if (!acc[house]) acc[house] = 0;
            acc[house] += Number(curr.net_salary || 0);
            return acc;
          }, {});

          return (
            <Card key={run.id} className="overflow-hidden border-none shadow-xl">
              <CardHeader className="bg-slate-800 text-white py-4 px-6">
                <div className="flex items-center justify-between">
                  <div className="flex items-center gap-4">
                    <FileSpreadsheet className="h-6 w-6 text-green-400" />
                    <div>
                      <CardTitle className="text-xl font-bold">
                        {MONTH_NAMES[run.month].toUpperCase()} {run.year}
                      </CardTitle>
                      <p className="text-xs text-slate-400 uppercase tracking-widest font-medium">BDO Bank Control Logic</p>
                    </div>
                  </div>
                  <Badge className="bg-green-500 hover:bg-green-600 text-white border-none px-4" variant="default">
                    {run.status.toUpperCase()}
                  </Badge>
                </div>
              </CardHeader>
              <CardContent className="p-0">
                <div className="overflow-x-auto">
                  <Table className="border-collapse min-w-[2800px]">
                    <TableHeader>
                      <TableRow className="bg-slate-100 hover:bg-slate-100">
                        <TableHead className="w-12 text-center sticky left-0 bg-slate-100 z-20 border-r">NO</TableHead>
                        <TableHead className="w-24 text-center sticky left-12 bg-slate-100 z-20 border-r">HOUSE</TableHead>
                        <TableHead className="w-72 sticky left-36 bg-slate-100 z-20 border-r">NOME DO TRABALHADOR</TableHead>
                        <TableHead className="w-48 border-r">CATEGORIA</TableHead>
                        
                        <TableHead className="text-right border-r">SALARIO BASE (L.08)</TableHead>
                        <TableHead className="text-right border-r">ALIMENTACAO</TableHead>
                        <TableHead className="text-right border-r">RETROATIVOS</TableHead>
                        <TableHead className="text-center border-r">DIAS TRAB.</TableHead>
                        <TableHead className="text-right border-r bg-blue-50/30">SALARIO MENSAL</TableHead>
                        
                        <TableHead className="text-right border-r">NIGHTSHIFT</TableHead>
                        <TableHead className="text-right border-r bg-blue-50/30">25% GUARDA</TableHead>
                        <TableHead className="text-right border-r">HORAS 1.5</TableHead>
                        <TableHead className="text-right border-r bg-blue-50/30">VALOR 1.5</TableHead>
                        <TableHead className="text-right border-r">HORAS 2.0</TableHead>
                        <TableHead className="text-right border-r bg-blue-50/30">VALOR 2.0</TableHead>
                        
                        <TableHead className="text-right border-r">GRATIFIC.</TableHead>
                        <TableHead className="text-center border-r">DIAS FERIA</TableHead>
                        <TableHead className="text-right border-r bg-blue-50/30">MONTANTE FERIA</TableHead>
                        
                        <TableHead className="text-right border-r bg-green-50 font-bold text-green-900 italic">TOTAL REMUNERAÇÃO</TableHead>
                        
                        <TableHead className="text-right border-r text-red-700">ADVANCE</TableHead>
                        <TableHead className="text-right border-r text-red-700">IRPS (A)</TableHead>
                        <TableHead className="text-right border-r text-red-700">DIVIDA (A)</TableHead>
                        <TableHead className="text-right border-r text-red-700 font-medium">INSS (A)</TableHead>
                        <TableHead className="text-right border-r text-red-700">SIND (A)</TableHead>
                        
                        <TableHead className="text-right border-r bg-red-50 font-bold text-red-900 italic">TOTAL DEDUCTIONS</TableHead>
                        <TableHead className="text-right border-r bg-green-100 font-black text-green-950 text-base">SALÁRIO LÍQUIDO</TableHead>
                        
                        <TableHead className="w-64 border-r">CONTA DO BANCO</TableHead>
                        <TableHead className="w-48 text-right bg-slate-50">TOTAL PER CASA</TableHead>
                      </TableRow>
                    </TableHeader>
                    <TableBody>
                      {lines.map((l: any, i: number) => (
                        <TableRow key={l.id} className="hover:bg-slate-50 transition-colors border-b h-14">
                          <TableCell className="text-center font-mono text-slate-400 sticky left-0 bg-white z-10 border-r">{i + 1}</TableCell>
                          <TableCell className="text-center sticky left-12 bg-white z-10 border-r">
                            <span className="font-bold text-slate-600">{l.employees?.house_assignment || "AM"}</span>
                          </TableCell>
                          <TableCell className="font-bold text-slate-800 sticky left-36 bg-white z-10 border-r">{l.employees?.name}</TableCell>
                          <TableCell className="text-slate-500 border-r uppercase text-xs font-semibold">{l.category || "---"}</TableCell>
                          
                          <TableCell className="text-right border-r font-mono">{formatMZN(l.base_salary)}</TableCell>
                          <TableCell className="text-right border-r font-mono">{formatMZN(l.food_allowance)}</TableCell>
                          <TableCell className="text-right border-r font-mono">{formatMZN(l.back_payment)}</TableCell>
                          <TableCell className="text-center border-r font-bold">{l.days_worked || 30}</TableCell>
                          <TableCell className="text-right border-r font-mono bg-blue-50/20">{formatMZN(l.monthly_salary)}</TableCell>
                          
                          <TableCell className="text-right border-r font-mono">{l.nightshift_hours || 0}</TableCell>
                          <TableCell className="text-right border-r font-mono bg-blue-50/20 text-blue-800">{formatMZN(l.guardas_25)}</TableCell>
                          <TableCell className="text-right border-r font-mono">{l.overtime_15x_hours || 0}</TableCell>
                          <TableCell className="text-right border-r font-mono bg-blue-50/20 text-blue-800">{formatMZN(l.overtime_15x_amount)}</TableCell>
                          <TableCell className="text-right border-r font-mono">{l.overtime_2x_hours || 0}</TableCell>
                          <TableCell className="text-right border-r font-mono bg-blue-50/20 text-blue-800">{formatMZN(l.overtime_2x_amount)}</TableCell>
                          
                          <TableCell className="text-right border-r font-mono">{formatMZN(l.gratification)}</TableCell>
                          <TableCell className="text-center border-r font-bold">{l.holiday_days || 0}</TableCell>
                          <TableCell className="text-right border-r font-mono bg-blue-50/20 text-blue-800">{formatMZN(l.holiday_amount)}</TableCell>
                          
                          <TableCell className="text-right border-r bg-green-50 font-bold text-green-700 italic border-green-200">{formatMZN(l.gross_total)}</TableCell>
                          
                          <TableCell className="text-right border-r font-mono text-slate-600">{formatMZN(l.advance)}</TableCell>
                          <TableCell className="text-right border-r font-mono text-slate-600">{formatMZN(l.irps)}</TableCell>
                          <TableCell className="text-right border-r font-mono text-slate-600">{formatMZN(l.debt)}</TableCell>
                          <TableCell className="text-right border-r font-mono text-red-800 bg-red-50/10 font-medium italic">{formatMZN(l.inss_employee)}</TableCell>
                          <TableCell className="text-right border-r font-mono text-slate-600">{formatMZN(l.sind)}</TableCell>
                          
                          <TableCell className="text-right border-r bg-red-50 font-bold text-red-700 italic border-red-200">{formatMZN(l.total_deductions)}</TableCell>
                          <TableCell className="text-right border-r bg-green-200 font-black text-green-950 text-base">{formatMZN(l.net_salary)}</TableCell>
                          
                          <TableCell className="font-mono text-xs text-slate-400 border-r italic tracking-tighter truncate max-w-xs">{l.nib || l.employees?.nib || "---"}</TableCell>
                          <TableCell className="text-right font-bold text-slate-700 bg-slate-50 pr-4">MZN {formatMZN(l.net_salary)}</TableCell>
                        </TableRow>
                      ))}
                      
                      {/* RED CELL TOTALS ROW MATCHING EXCEL */}
                      <TableRow className="bg-slate-900 text-white font-bold h-12">
                        <TableCell colSpan={4} className="text-right pr-4 uppercase tracking-tighter sticky left-0 bg-slate-900 border-r border-slate-700">Totais da Folha</TableCell>
                        <TableCell className="text-right border-r border-slate-700">---</TableCell>
                        <TableCell className="text-right border-r border-slate-700">{formatMZN(lines.reduce((s: any, c: any) => s + Number(c.food_allowance), 0))}</TableCell>
                        <TableCell className="text-right border-r border-slate-700">{formatMZN(lines.reduce((s: any, c: any) => s + Number(c.back_payment), 0))}</TableCell>
                        <TableCell className="border-r border-slate-700">---</TableCell>
                        <TableCell className="text-right border-r border-slate-700 bg-slate-800">{formatMZN(lines.reduce((s: any, c: any) => s + Number(c.monthly_salary), 0))}</TableCell>
                        <TableCell className="border-r border-slate-700">---</TableCell>
                        <TableCell className="text-right border-r border-slate-700 bg-slate-800">{formatMZN(lines.reduce((s: any, c: any) => s + Number(c.guardas_25 || 0), 0))}</TableCell>
                        <TableCell className="border-r border-slate-700">---</TableCell>
                        <TableCell className="text-right border-r border-slate-700 bg-slate-800">{formatMZN(lines.reduce((s: any, c: any) => s + Number(c.overtime_15x_amount), 0))}</TableCell>
                        <TableCell className="border-r border-slate-700">---</TableCell>
                        <TableCell className="text-right border-r border-slate-700 bg-slate-800">{formatMZN(lines.reduce((s: any, c: any) => s + Number(c.overtime_2x_amount), 0))}</TableCell>
                        <TableCell className="text-right border-r border-slate-700">{formatMZN(lines.reduce((s: any, c: any) => s + Number(c.gratification), 0))}</TableCell>
                        <TableCell className="border-r border-slate-700">---</TableCell>
                        <TableCell className="text-right border-r border-slate-700 bg-slate-800">{formatMZN(lines.reduce((s: any, c: any) => s + Number(c.holiday_amount), 0))}</TableCell>
                        <TableCell className="text-right border-r border-slate-700 bg-green-900/50">{formatMZN(run.total_gross)}</TableCell>
                        <TableCell className="text-right border-r border-slate-700">{formatMZN(lines.reduce((s: any, c: any) => s + Number(c.advance), 0))}</TableCell>
                        <TableCell className="text-right border-r border-slate-700 text-red-300 font-medium">{formatMZN(run.total_irps)}</TableCell>
                        <TableCell className="text-right border-r border-slate-700">{formatMZN(lines.reduce((s: any, c: any) => s + Number(c.debt), 0))}</TableCell>
                        <TableCell className="text-right border-r border-slate-700">{formatMZN(lines.reduce((s: any, c: any) => s + Number(c.inss_employee), 0))}</TableCell>
                        <TableCell className="text-right border-r border-slate-700">{formatMZN(lines.reduce((s: any, c: any) => s + Number(c.sind), 0))}</TableCell>
                        <TableCell className="text-right border-r border-slate-700 bg-red-900/50 italic">{formatMZN(lines.reduce((s: any, c: any) => s + Number(c.total_deductions), 0))}</TableCell>
                        <TableCell className="text-right border-r border-slate-700 bg-green-500 text-slate-900 text-lg">{formatMZN(run.total_net)}</TableCell>
                        <TableCell className="border-r border-slate-700">---</TableCell>
                        <TableCell className="text-right pr-4 italic text-slate-300">Net Totals</TableCell>
                      </TableRow>
                    </TableBody>
                  </Table>
                </div>

                {/* TOTAL PER CASA SECTION - BOXES */}
                <div className="bg-slate-50 p-8 border-t">
                  <h3 className="text-sm font-bold uppercase tracking-[0.2em] text-slate-500 mb-6 flex items-center gap-2">
                    <div className="h-4 w-1 bg-slate-800"></div> Total per Casa / Property Summary
                  </h3>
                  <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-5 gap-6">
                    {Object.entries(totalsByHouse).sort().map(([house, total]: [string, any]) => (
                      <div key={house} className="relative overflow-hidden group">
                        <div className="p-5 rounded-xl bg-white border border-slate-200 shadow-sm transition-all hover:shadow-md hover:border-slate-300">
                          <div className="flex items-center justify-between mb-2">
                            <span className="text-xs font-bold text-slate-400 group-hover:text-slate-600">{house}</span>
                            <div className="h-2 w-2 rounded-full bg-green-500"></div>
                          </div>
                          <div className="text-xl font-black text-slate-800 tracking-tight">
                            MZN {formatMZN(total)}
                          </div>
                          <div className="mt-2 text-[10px] text-slate-400 font-semibold italic">Net Disbursement</div>
                        </div>
                      </div>
                    ))}
                  </div>
                </div>
              </CardContent>
            </Card>
          );
        })
      ) : (
        <Card className="border-2 border-dashed border-slate-200 bg-slate-50/50 group hover:border-slate-300 transition-colors">
          <CardContent className="flex flex-col items-center justify-center py-32 text-slate-400">
            <FileSpreadsheet className="h-16 w-16 mb-4 opacity-20 group-hover:opacity-40 transition-opacity" />
            <p className="text-xl font-semibold text-slate-500">No payroll data available.</p>
            <p className="text-sm">Upload a BDO folha de salários to generate the dashboard.</p>
          </CardContent>
        </Card>
      )}
    </div>
  );
}
