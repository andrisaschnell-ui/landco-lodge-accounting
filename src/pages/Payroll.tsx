import { useState, useEffect } from "react";
import { useQuery, useQueryClient } from "@tanstack/react-query";
import { supabase } from "@/integrations/supabase/client";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Download, FileSpreadsheet, Plus, Trash, FileText, Filter, Save, FileUp, ZoomIn, ZoomOut, ArrowUp, ArrowDown, Copy } from "lucide-react";
import * as XLSX from "xlsx";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import {
  AlertDialog, AlertDialogAction, AlertDialogCancel, AlertDialogContent,
  AlertDialogDescription, AlertDialogFooter, AlertDialogHeader, AlertDialogTitle,
} from "@/components/ui/alert-dialog";
import {
  Dialog, DialogContent, DialogDescription, DialogFooter, DialogHeader, DialogTitle,
} from "@/components/ui/dialog";
import { toast } from "@/hooks/use-toast";

function formatMZN(v: number) {
  return new Intl.NumberFormat("en-US", { minimumFractionDigits: 2 }).format(Number(v) || 0);
}

const MONTH_NAMES = ["", "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];

export const ADMIN_CATEGORIES = [
  "GERENTE",
  "GUARDA",
  "EMPREGADA",
  "JARDINERO",
  "COZINHEIRA",
  "CAPITÃO DE BARCO",
  "GHILLIE",
  "---" // Blank/fallback option
];

function PayrollRun({ run, initialLines, zoomLevel }: { run: any, initialLines: any[], zoomLevel: number }) {
  const [localLines, setLocalLines] = useState<any[]>([]);
  const [houseFilter, setHouseFilter] = useState("ALL");
  const [isSaving, setIsSaving] = useState(false);
  const [showDeleteDialog, setShowDeleteDialog] = useState(false);
  const [showDuplicateDialog, setShowDuplicateDialog] = useState(false);
  const [dupMonth, setDupMonth] = useState<number>(((run.month % 12) + 1));
  const [dupYear, setDupYear] = useState<number>(run.month === 12 ? run.year + 1 : run.year);
  const [isDuplicating, setIsDuplicating] = useState(false);
  const queryClient = useQueryClient();

  useEffect(() => {
    // Rely exclusively on true mapping array position
    setLocalLines(initialLines.map(l => ({ 
      ...l, 
      tempId: l.id || crypto.randomUUID()
    })));
  }, [initialLines]);

  // Displayed lines just reflect the physical array hierarchy, matching raw visual layout naturally
  const displayedLines = localLines.filter(l => {
    if (houseFilter === "ALL") return true;
    const house = l.employees?.house_assignment || l.house_assignment_temp || "AM";
    return house === houseFilter;
  });

  const handleEditCell = (tempId: string, field: string, value: any) => {
    setLocalLines(prev => prev.map(l => {
      if (l.tempId === tempId) {
        if (field === 'house_assignment_temp') return { ...l, employees: { ...l.employees, house_assignment: value }, house_assignment_temp: value };
        if (field === 'name') return { ...l, employees: { ...l.employees, name: value } };
        if (field === 'nib') return { ...l, employees: { ...l.employees, nib: value }, nib: value };
        return { ...l, [field]: value };
      }
      return l;
    }));
  };

  const fixAMtoLC = () => {
    setLocalLines(prev => prev.map(l => {
      const house = l.employees?.house_assignment || l.house_assignment_temp || "AM";
      if (house === "AM") {
        return { ...l, employees: { ...l.employees, house_assignment: "LC" }, house_assignment_temp: "LC" };
      }
      return l;
    }));
  };

  const addRow = () => {
    setLocalLines(prev => [...prev, {
      tempId: crypto.randomUUID(),
      salary_run_id: run.id,
      employees: { name: "NEW WORKER", house_assignment: "LC", nib: "" },
      category: "GUARDA",
      base_salary: 0, food_allowance: 0, net_salary: 0, total_deductions: 0, gross_total: 0
    }]);
  };

  const insertRowBefore = (tempId: string) => {
    setLocalLines(prev => {
      const idx = prev.findIndex(x => x.tempId === tempId);
      if (idx === -1) return prev;
      const copy = [...prev];
      copy.splice(idx, 0, {
        tempId: crypto.randomUUID(),
        salary_run_id: run.id,
        employees: { name: "NEW WORKER", house_assignment: "LC", nib: "" },
        category: "GUARDA",
        base_salary: 0, food_allowance: 0, net_salary: 0, total_deductions: 0, gross_total: 0
      });
      return copy;
    });
  };

  const insertRowAfter = (tempId: string) => {
    setLocalLines(prev => {
      const idx = prev.findIndex(x => x.tempId === tempId);
      if (idx === -1) return prev;
      const copy = [...prev];
      copy.splice(idx + 1, 0, {
        tempId: crypto.randomUUID(),
        salary_run_id: run.id,
        employees: { name: "NEW WORKER", house_assignment: "LC", nib: "" },
        category: "GUARDA",
        base_salary: 0, food_allowance: 0, net_salary: 0, total_deductions: 0, gross_total: 0
      });
      return copy;
    });
  };

  const removeRow = (tempId: string) => {
    setLocalLines(prev => prev.filter(l => l.tempId !== tempId));
  };

  const deleteEntireMonth = async () => {
    setIsSaving(true);
    try {
      const { error: linesErr } = await supabase.from("salary_lines").delete().eq("salary_run_id", run.id);
      if (linesErr) throw linesErr;
      const { error: runErr } = await supabase.from("salary_runs").delete().eq("id", run.id);
      if (runErr) throw runErr;
      toast({ title: "Month deleted", description: `${MONTH_NAMES[run.month]} ${run.year} payroll removed.` });
      await queryClient.invalidateQueries({ queryKey: ["salary-runs"] });
      await queryClient.invalidateQueries({ queryKey: ["salary-lines"] });
    } catch (e: any) {
      toast({ title: "Delete failed", description: e.message, variant: "destructive" });
    }
    setIsSaving(false);
    setShowDeleteDialog(false);
  };

  const duplicateMonth = async () => {
    setIsDuplicating(true);
    try {
      // Refuse if target month already exists
      const { data: existing } = await supabase
        .from("salary_runs")
        .select("id")
        .eq("month", dupMonth)
        .eq("year", dupYear)
        .maybeSingle();
      if (existing) {
        throw new Error(`A payroll run for ${MONTH_NAMES[dupMonth]} ${dupYear} already exists. Delete it first.`);
      }

      // Create new run (clone totals as-is)
      const { data: newRun, error: runErr } = await supabase
        .from("salary_runs")
        .insert({
          month: dupMonth,
          year: dupYear,
          status: "draft",
          total_gross: run.total_gross || 0,
          total_net: run.total_net || 0,
          total_irps: run.total_irps || 0,
          total_inss_employee: run.total_inss_employee || 0,
          total_inss_employer: run.total_inss_employer || 0,
        })
        .select("id")
        .single();
      if (runErr) throw runErr;

      // Clone every line as-is, pointing at the new run
      if (localLines.length > 0) {
        const now = Date.now();
        const cloned = localLines.map((l, idx) => ({
          salary_run_id: newRun.id,
          employee_id: l.employee_id,
          base_salary: l.base_salary,
          food_allowance: l.food_allowance,
          back_payment: l.back_payment,
          days_worked: l.days_worked,
          monthly_salary: l.monthly_salary,
          nightshift_hours: l.nightshift_hours,
          guardas_25: l.guardas_25,
          overtime_15x_hours: l.overtime_15x_hours,
          overtime_15x_amount: l.overtime_15x_amount,
          overtime_2x_hours: l.overtime_2x_hours,
          overtime_2x_amount: l.overtime_2x_amount,
          gratification: l.gratification,
          holiday_days: l.holiday_days,
          holiday_amount: l.holiday_amount,
          gross_total: l.gross_total,
          advance: l.advance,
          irps: l.irps,
          debt: l.debt,
          inss_employee: l.inss_employee,
          sind: l.sind,
          total_deductions: l.total_deductions,
          net_salary: l.net_salary,
          nib: l.nib || l.employees?.nib || null,
          category: l.category,
          created_at: new Date(now + idx * 1000).toISOString(),
        })).filter((l) => l.employee_id);

        if (cloned.length > 0) {
          const { error: insErr } = await supabase.from("salary_lines").insert(cloned);
          if (insErr) throw insErr;
        }
      }

      toast({ title: "Month duplicated", description: `Created ${MONTH_NAMES[dupMonth]} ${dupYear} from ${MONTH_NAMES[run.month]} ${run.year}.` });
      await queryClient.invalidateQueries({ queryKey: ["salary-runs"] });
      await queryClient.invalidateQueries({ queryKey: ["salary-lines"] });
      setShowDuplicateDialog(false);
    } catch (e: any) {
      toast({ title: "Duplicate failed", description: e.message, variant: "destructive" });
    }
    setIsDuplicating(false);
  };

  const saveChanges = async () => {
    setIsSaving(true);
    try {
      // 1. Identify and create any missing employees natively for new rows
      const processedLines = await Promise.all(localLines.map(async (l) => {
         let empId = l.employee_id;
         // If no employee_id exists (e.g., added via '+ Row')
         if (!empId) {
             const { data: newEmp, error: empErr } = await supabase
               .from("employees")
               .insert({ 
                 name: l.employees?.name || "New Employee", 
                 category: l.category || "GUARDA",
                 house_assignment: l.employees?.house_assignment || l.house_assignment_temp || "LC",
                 nib: l.nib || l.employees?.nib || "",
                 base_salary: l.base_salary || 0
               })
               .select("id")
               .single();
               
             if (empErr) throw new Error("Failed to generate master employee record: " + empErr.message);
             empId = newEmp.id;
         }
         return { ...l, employee_id: empId };
      }));

      // 2. Clear old lines for this run securely
      const { error: delErr } = await supabase.from("salary_lines").delete().eq("salary_run_id", run.id);
      if (delErr) throw new Error("Wipe failed: " + delErr.message);
      
      // 3. Insert fresh updated data sequentially using staggered timestamps to guarantee exact database query structural order
      const now = Date.now();
      const toInsert = processedLines.map((l, idx) => ({
        salary_run_id: run.id,
        employee_id: l.employee_id,
        base_salary: l.base_salary,
        food_allowance: l.food_allowance,
        back_payment: l.back_payment,
        days_worked: l.days_worked,
        monthly_salary: l.monthly_salary,
        nightshift_hours: l.nightshift_hours,
        guardas_25: l.guardas_25,
        overtime_15x_hours: l.overtime_15x_hours,
        overtime_15x_amount: l.overtime_15x_amount,
        overtime_2x_hours: l.overtime_2x_hours,
        overtime_2x_amount: l.overtime_2x_amount,
        gratification: l.gratification,
        holiday_days: l.holiday_days,
        holiday_amount: l.holiday_amount,
        gross_total: l.gross_total,
        advance: l.advance,
        irps: l.irps,
        debt: l.debt,
        inss_employee: l.inss_employee,
        sind: l.sind,
        total_deductions: l.total_deductions,
        net_salary: l.net_salary,
        nib: l.nib || l.employees?.nib || null,
        category: l.category,
        created_at: new Date(now + idx * 1000).toISOString()
      }));

      if (toInsert.length > 0) {
        const { error: insErr } = await supabase.from("salary_lines").insert(toInsert);
        if (insErr) throw new Error("Insert failed: " + insErr.message);
      }
      alert("Saved successfully! Data committed to database.");
      await queryClient.invalidateQueries({ queryKey: ["salary-lines"] });
    } catch (e: any) {
      alert("Database Synchronization Error: " + e.message);
    }
    setIsSaving(false);
  };

  const downloadExcel = (isTemplate = false) => {
    const header = [
      "No", "House", "Name", "Category", "Base Salary", "Food Allowance", "Back Payment", 
      "Days Worked", "Monthly Salary", "Nightshift", "25% Guarda", "Overtime 1.5x (Hrs)", 
      "Overtime 1.5x (Amt)", "Overtime 2x (Hrs)", "Overtime 2x (Amt)", "Gratification", 
      "Holiday Days", "Holiday Amount", "Gross Total", "Advance", "IRPS", "Debt", "INSS", 
      "SIND", "Total Deductions", "Net Salary", "Bank_Account"
    ];

    const dataRows = (isTemplate ? [{ row_no: 1, employees: { house_assignment: "LC", name: "Example Employee" }, base_salary: 10000 }] : displayedLines).map((l, i) => {
      const rowNum = i + 2; 
      const monthlySalaryFormula = { t: 'n', f: `E${rowNum}+F${rowNum}+G${rowNum}` };
      const grossTotalFormula = { t: 'n', f: `I${rowNum}+K${rowNum}+M${rowNum}+O${rowNum}+P${rowNum}+R${rowNum}` };
      const deductionsFormula = { t: 'n', f: `T${rowNum}+U${rowNum}+V${rowNum}+W${rowNum}+X${rowNum}` };
      const netSalaryFormula = { t: 'n', f: `S${rowNum}-Y${rowNum}` };

      return [
        (i + 1).toString(),
        l.employees?.house_assignment || l.house_assignment_temp || "LC",
        l.employees?.name || "",
        l.category || "",
        l.base_salary || 0,
        l.food_allowance || 0,
        l.back_payment || 0,
        l.days_worked || 30,
        monthlySalaryFormula,
        l.nightshift_hours || 0,
        l.guardas_25 || 0,
        l.overtime_15x_hours || 0,
        l.overtime_15x_amount || 0,
        l.overtime_2x_hours || 0,
        l.overtime_2x_amount || 0,
        l.gratification || 0,
        l.holiday_days || 0,
        l.holiday_amount || 0,
        grossTotalFormula,
        l.advance || 0,
        l.irps || 0,
        l.debt || 0,
        l.inss_employee || 0,
        l.sind || 0,
        deductionsFormula,
        netSalaryFormula,
        l.nib || l.employees?.nib || ""
      ];
    });

    const aoa = [header, ...dataRows];
    const ws = XLSX.utils.aoa_to_sheet(aoa);
    const wb = XLSX.utils.book_new();
    XLSX.utils.book_append_sheet(wb, ws, isTemplate ? "Template" : "Payroll");
    XLSX.writeFile(wb, `Payroll_${isTemplate ? "Template_" : ""}${MONTH_NAMES[run.month]}_${run.year}.xlsx`);
  };

  const uploadExcel = (e: any) => {
    const file = e.target.files[0];
    if (!file) return;
    const reader = new FileReader();
    reader.onload = (evt) => {
      const bstr = evt.target?.result;
      const wb = XLSX.read(bstr, { type: 'binary' });
      const wsname = wb.SheetNames[0];
      const ws = wb.Sheets[wsname];
      const data = XLSX.utils.sheet_to_json(ws);
      
      const newLines = data.map((row: any) => ({
        tempId: crypto.randomUUID(),
        row_no: Number(row["No"]) || 0,
        salary_run_id: run.id,
        employees: { name: row["Name"] || "", house_assignment: row["House"] || "LC", nib: row["Bank_Account"] || "" },
        category: row["Category"] || "",
        base_salary: row["Base Salary"] || 0,
        food_allowance: row["Food Allowance"] || 0,
        back_payment: row["Back Payment"] || 0,
        days_worked: row["Days Worked"] || 30,
        monthly_salary: row["Monthly Salary"] || 0,
        nightshift_hours: row["Nightshift"] || 0,
        guardas_25: row["25% Guarda"] || 0,
        overtime_15x_hours: row["Overtime 1.5x (Hrs)"] || 0,
        overtime_15x_amount: row["Overtime 1.5x (Amt)"] || 0,
        overtime_2x_hours: row["Overtime 2x (Hrs)"] || 0,
        overtime_2x_amount: row["Overtime 2x (Amt)"] || 0,
        gratification: row["Gratification"] || 0,
        holiday_days: row["Holiday Days"] || 0,
        holiday_amount: row["Holiday Amount"] || 0,
        gross_total: row["Gross Total"] || 0,
        advance: row["Advance"] || 0,
        irps: row["IRPS"] || 0,
        debt: row["Debt"] || 0,
        inss_employee: row["INSS"] || 0,
        sind: row["SIND"] || 0,
        total_deductions: row["Total Deductions"] || 0,
        net_salary: row["Net Salary"] || 0,
        nib: row["Bank_Account"] || ""
      }));
      setLocalLines(newLines);
    };
    reader.readAsBinaryString(file);
  };

  const downloadPayslip = (l: any) => {
    const monthName = MONTH_NAMES[run.month];
    const workerName = l.employees?.name || "N/A";
    const totalRemuneration = l.gross_total || 0;
    const totalDeductions = l.total_deductions || 0;
    const netSalary = l.net_salary || 0;
    const bankAccount = l.nib || l.employees?.nib || "N/A";

    const docContent = `
      <html xmlns:o='urn:schemas-microsoft-com:office:office' xmlns:w='urn:schemas-microsoft-com:office:word' xmlns='http://www.w3.org/TR/REC-html40'>
      <head><meta charset='utf-8'><title>Payslip</title></head>
      <body>
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; border: 1px solid #ccc; padding: 20px;">
          <h1 style="text-align: center; color: #333;">PAYSLIP</h1>
          <hr />
          <p><strong>Month:</strong> ${monthName} ${run.year}</p>
          <p><strong>Nome do Trabalhador:</strong> ${workerName}</p>
          <br/>
          <table style="width: 100%; border-collapse: collapse;">
            <tr>
              <td style="padding: 8px; border: 1px solid #ccc;"><strong>TOTAL REMUNERAÇÃO</strong></td>
              <td style="padding: 8px; border: 1px solid #ccc;">${formatMZN(totalRemuneration)} MZN</td>
            </tr>
            <tr>
              <td style="padding: 8px; border: 1px solid #ccc;"><strong>TOTAL DEDUCTIONS</strong></td>
              <td style="padding: 8px; border: 1px solid #ccc;">${formatMZN(totalDeductions)} MZN</td>
            </tr>
            <tr>
              <td style="padding: 8px; border: 1px solid #ccc; background-color: #f0fdf4;"><strong>SALÁRIO LÍQUIDO</strong></td>
              <td style="padding: 8px; border: 1px solid #ccc; background-color: #f0fdf4;"><strong>${formatMZN(netSalary)} MZN</strong></td>
            </tr>
          </table>
          <br/>
          <p><strong>CONTA DO BANCO:</strong> ${bankAccount}</p>
        </div>
      </body>
      </html>
    `;

    const blob = new Blob(['\ufeff', docContent], { type: 'application/msword' });
    const link = document.createElement('a');
    link.href = URL.createObjectURL(blob);
    link.download = `Payslip_${workerName.replace(/\\s+/g, '_')}_${monthName}.doc`;
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
  };

  const totalsByHouse = displayedLines.reduce((acc: any, curr: any) => {
    const house = curr.employees?.house_assignment || curr.house_assignment_temp || "LC";
    if (!acc[house]) acc[house] = 0;
    acc[house] += Number(curr.net_salary || 0);
    return acc;
  }, {});

  return (
    <Card className="shadow-xl mb-6 bg-white border border-slate-200">
      <CardHeader className="bg-slate-800 text-white p-4 lg:px-6">
        <div className="flex flex-col lg:flex-row lg:items-center justify-between gap-4">
          <div className="flex items-center gap-4">
            <FileSpreadsheet className="h-6 w-6 text-green-400 shrink-0" />
            <div>
              <CardTitle className="text-lg lg:text-xl font-bold">
                {MONTH_NAMES[run.month].toUpperCase()} {run.year}
              </CardTitle>
              <p className="text-xs text-slate-400 uppercase font-medium">Editable Payroll Control</p>
            </div>
          </div>
          <div className="flex flex-wrap items-center gap-2 lg:gap-3">
             <Select value={houseFilter} onValueChange={setHouseFilter}>
              <SelectTrigger className="w-[110px] bg-white text-slate-900 h-8 border-none">
                <Filter className="w-3 h-3 mr-2"/>
                <SelectValue placeholder="Filter House" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="ALL">All Houses</SelectItem>
                <SelectItem value="LC">LC</SelectItem>
                <SelectItem value="H1">H1</SelectItem>
                <SelectItem value="H2">H2</SelectItem>
                <SelectItem value="H3">H3</SelectItem>
                <SelectItem value="H4">H4</SelectItem>
              </SelectContent>
            </Select>

            <Button size="sm" onClick={fixAMtoLC} variant="secondary" className="h-8 text-xs font-semibold whitespace-nowrap">
              AM ➔ LC
            </Button>
            
            <div className="flex gap-1 border-r border-slate-600 pr-2 xl:pr-3">
              <Button size="sm" onClick={() => downloadExcel(false)} className="bg-green-600 hover:bg-green-500 h-8 text-xs whitespace-nowrap">
                <Download className="w-3 h-3 mr-1" /> Excel
              </Button>
              <Button size="sm" onClick={() => downloadExcel(true)} className="bg-slate-700 hover:bg-slate-600 h-8 text-xs whitespace-nowrap hidden sm:flex">
                <Download className="w-3 h-3 mr-1" /> Template
              </Button>
              <label>
               <Button asChild size="sm" variant="outline" className="h-8 text-xs text-slate-800 cursor-pointer whitespace-nowrap">
                 <div>
                    <FileUp className="w-3 h-3 mr-1" /> Upload 
                    <input type="file" className="hidden" accept=".xlsx, .xls" onChange={uploadExcel} />
                 </div>
               </Button>
              </label>
            </div>
            
            <Button size="sm" onClick={addRow} variant="secondary" className="h-8 text-xs whitespace-nowrap">
              <Plus className="w-3 h-3 mr-1" /> Row
            </Button>

            <Button size="sm" onClick={() => setShowDuplicateDialog(true)} variant="secondary" className="h-8 text-xs whitespace-nowrap hidden sm:flex">
              <Copy className="w-3 h-3 mr-1" /> Duplicate to…
            </Button>

            <Button size="sm" onClick={() => setShowDeleteDialog(true)} variant="destructive" className="h-8 text-xs whitespace-nowrap hidden sm:flex">
              <Trash className="w-3 h-3 mr-1" /> Delete Month
            </Button>

            <Button size="sm" onClick={saveChanges} disabled={isSaving} className="bg-blue-600 hover:bg-blue-500 h-8 text-xs font-bold shadow-md whitespace-nowrap">
              <Save className="w-3 h-3 mr-1" /> {isSaving ? "..." : "Save Data"}
            </Button>
          </div>
        </div>
      </CardHeader>
      
      <CardContent className="p-0">
        <div className="overflow-auto max-h-[70vh] relative bg-white">
          <div style={{ zoom: zoomLevel }}>
            <Table style={{ borderCollapse: 'separate', borderSpacing: 0 }} className="min-w-[3200px] w-full text-sm">
              <TableHeader className="bg-slate-100 shadow-sm relative z-40">
                <TableRow className="hover:bg-transparent">
                  <TableHead className="w-20 p-2 text-center bg-slate-200 z-50 sticky left-0 top-0 border-r border-b border-t shadow-[2px_2px_5px_-2px_rgba(0,0,0,0.1)]">NO</TableHead>
                  <TableHead className="w-24 p-2 text-center bg-slate-200 z-50 sticky left-[80px] top-0 border-r border-b border-t shadow-[2px_2px_5px_-2px_rgba(0,0,0,0.1)]">HOUSE</TableHead>
                  <TableHead className="w-64 p-2 bg-slate-200 z-50 sticky left-[176px] top-0 border-r border-b border-t shadow-[4px_2px_5px_-2px_rgba(0,0,0,0.1)]">NOME DO TRABALHADOR</TableHead>
                  <TableHead className="w-48 p-2 sticky top-0 bg-slate-100 z-40 border-r border-b border-t">CATEGORIA</TableHead>
                  
                  <TableHead className="text-right p-2 sticky top-0 bg-slate-100 z-40 border-r border-b border-t">SALARIO BASE</TableHead>
                  <TableHead className="text-right p-2 sticky top-0 bg-slate-100 z-40 border-r border-b border-t">ALIMENTACAO</TableHead>
                  <TableHead className="text-right p-2 sticky top-0 bg-slate-100 z-40 border-r border-b border-t">RETROATIVOS</TableHead>
                  <TableHead className="text-center p-2 sticky top-0 bg-slate-100 z-40 border-r border-b border-t">DIAS TRAB.</TableHead>
                  <TableHead className="text-right p-2 sticky top-0 bg-blue-50 z-40 border-r border-b border-t">SALARIO MENSAL</TableHead>
                  
                  <TableHead className="text-right p-2 sticky top-0 bg-slate-100 z-40 border-r border-b border-t">NIGHTSHIFT</TableHead>
                  <TableHead className="text-right p-2 sticky top-0 bg-blue-50 z-40 border-r border-b border-t">25% GUARDA</TableHead>
                  <TableHead className="text-right p-2 sticky top-0 bg-slate-100 z-40 border-r border-b border-t">HORAS 1.5</TableHead>
                  <TableHead className="text-right p-2 sticky top-0 bg-blue-50 z-40 border-r border-b border-t">VALOR 1.5</TableHead>
                  <TableHead className="text-right p-2 sticky top-0 bg-slate-100 z-40 border-r border-b border-t">HORAS 2.0</TableHead>
                  <TableHead className="text-right p-2 sticky top-0 bg-blue-50 z-40 border-r border-b border-t">VALOR 2.0</TableHead>
                  
                  <TableHead className="text-right p-2 sticky top-0 bg-slate-100 z-40 border-r border-b border-t">GRATIFIC.</TableHead>
                  <TableHead className="text-center p-2 sticky top-0 bg-slate-100 z-40 border-r border-b border-t">DIAS FERIA</TableHead>
                  <TableHead className="text-right p-2 sticky top-0 bg-blue-50 z-40 border-r border-b border-t">MONTANTE FERIA</TableHead>
                  
                  <TableHead className="text-right p-2 sticky top-0 bg-green-100 z-40 border-r border-b border-t font-bold text-green-900 italic">TOTAL REMUNERAÇÃO</TableHead>
                  
                  <TableHead className="text-right p-2 sticky top-0 bg-slate-100 z-40 border-r border-b border-t text-red-800">ADVANCE</TableHead>
                  <TableHead className="text-right p-2 sticky top-0 bg-slate-100 z-40 border-r border-b border-t text-red-800">IRPS (A)</TableHead>
                  <TableHead className="text-right p-2 sticky top-0 bg-slate-100 z-40 border-r border-b border-t text-red-800">DIVIDA (A)</TableHead>
                  <TableHead className="text-right p-2 sticky top-0 bg-slate-100 z-40 border-r border-b border-t text-red-800 font-medium">INSS (A)</TableHead>
                  <TableHead className="text-right p-2 sticky top-0 bg-slate-100 z-40 border-r border-b border-t text-red-800">SIND (A)</TableHead>
                  
                  <TableHead className="text-right p-2 sticky top-0 bg-red-100 z-40 border-r border-b border-t font-bold text-red-900 italic">TOTAL DEDUCTIONS</TableHead>
                  <TableHead className="text-right p-2 sticky top-0 bg-green-200 z-40 border-r border-b border-t font-black text-green-950 text-base">SALÁRIO LÍQUIDO</TableHead>
                  
                  <TableHead className="w-56 p-2 sticky top-0 bg-slate-100 z-40 border-r border-b border-t">CONTA DO BANCO</TableHead>
                  <TableHead className="w-48 text-center p-2 sticky right-0 top-0 bg-slate-200 z-50 border-b border-t shadow-[-2px_2px_5px_-2px_rgba(0,0,0,0.1)] border-l">ACTIONS</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {displayedLines.map((l: any, i: number) => (
                  <TableRow key={l.tempId} className="hover:bg-slate-50 transition-colors h-[48px] bg-white group">
                    <TableCell className="text-center font-mono text-slate-500 bg-white sticky left-0 z-30 border-r border-b group-hover:bg-slate-50 p-1 shadow-[2px_0_5px_-2px_rgba(0,0,0,0.05)]">
                       <span className="w-16 inline-block text-center font-bold text-slate-400">
                         {i + 1}
                       </span>
                    </TableCell>
                    <TableCell className="text-center bg-white sticky left-[80px] z-30 border-r border-b group-hover:bg-slate-50 p-1 shadow-[2px_0_5px_-2px_rgba(0,0,0,0.05)]">
                       <select 
                          className="w-full text-center font-bold text-slate-800 bg-transparent border-0 outline-none focus:ring-2 focus:ring-blue-500 rounded cursor-pointer"
                          value={l.employees?.house_assignment || l.house_assignment_temp || "LC"}
                          onChange={(e) => handleEditCell(l.tempId, "house_assignment_temp", e.target.value)}
                        >
                          <option value="LC">LC</option>
                          <option value="H1">H1</option>
                          <option value="H2">H2</option>
                          <option value="H3">H3</option>
                          <option value="H4">H4</option>
                       </select>
                    </TableCell>
                    <TableCell className="font-bold text-slate-800 bg-white sticky left-[176px] z-30 border-r border-b group-hover:bg-slate-50 p-1 shadow-[4px_0_5px_-3px_rgba(0,0,0,0.1)]">
                       <input 
                        type="text"
                        className="w-full font-bold text-slate-800 bg-transparent border-0 outline-none focus:ring-2 focus:ring-blue-500 rounded px-2 py-1"
                        value={l.employees?.name || ""}
                        onChange={(e) => handleEditCell(l.tempId, "name", e.target.value)}
                      />
                    </TableCell>
                    <TableCell className="text-slate-700 border-r border-b p-1">
                      <select 
                          className="w-full text-xs font-semibold bg-transparent border-0 outline-none focus:ring-2 focus:ring-blue-500 rounded cursor-pointer uppercase py-1"
                          value={l.category || "---"}
                          onChange={(e) => handleEditCell(l.tempId, "category", e.target.value)}
                        >
                          {ADMIN_CATEGORIES.map(cat => (
                            <option key={cat} value={cat}>{cat}</option>
                          ))}
                       </select>
                    </TableCell>
                    
                    {/* NUMERIC FIELDS */}
                    {[
                      { field: 'base_salary' },
                      { field: 'food_allowance' },
                      { field: 'back_payment' },
                      { field: 'days_worked', center: true },
                      { field: 'monthly_salary', bg: "bg-blue-50/30" },
                      
                      { field: 'nightshift_hours' },
                      { field: 'guardas_25', bg: "bg-blue-50/30" },
                      { field: 'overtime_15x_hours' },
                      { field: 'overtime_15x_amount', bg: "bg-blue-50/30" },
                      { field: 'overtime_2x_hours' },
                      { field: 'overtime_2x_amount', bg: "bg-blue-50/30" },
                      
                      { field: 'gratification' },
                      { field: 'holiday_days', center: true },
                      { field: 'holiday_amount', bg: "bg-blue-50/30" },
                      
                      { field: 'gross_total', bg: "bg-green-50 font-bold" },
                      
                      { field: 'advance' },
                      { field: 'irps' },
                      { field: 'debt' },
                      { field: 'inss_employee', bg: "bg-red-50/20 text-red-800" },
                      { field: 'sind' },
                      
                      { field: 'total_deductions', bg: "bg-red-50 font-bold" },
                      { field: 'net_salary', bg: "bg-green-100 font-bold text-green-900" },
                    ].map((cfg, j) => (
                      <TableCell key={j} className={`border-r border-b p-1 ${cfg.bg || ""} ${cfg.center ? "text-center" : "text-right"}`}>
                        <input 
                          type="number"
                          className={`w-full font-mono bg-transparent border-0 outline-none focus:ring-2 focus:ring-blue-500 rounded px-2 py-1 ${cfg.center ? "text-center" : "text-right"}`}
                          value={l[cfg.field] || ""}
                          onChange={(e) => handleEditCell(l.tempId, cfg.field, parseFloat(e.target.value) || 0)}
                        />
                      </TableCell>
                    ))}
  
                    <TableCell className="font-mono text-xs text-slate-600 border-r border-b p-1">
                      <input 
                        type="text"
                        className="w-full bg-transparent border-0 outline-none focus:ring-2 focus:ring-blue-500 rounded px-2 py-1"
                        value={l.nib || l.employees?.nib || ""}
                        onChange={(e) => handleEditCell(l.tempId, "nib", e.target.value)}
                      />
                    </TableCell>
                    <TableCell className="text-center p-1 bg-white sticky right-0 z-30 shadow-[-2px_0_5px_-2px_rgba(0,0,0,0.1)] border-b border-l group-hover:bg-slate-50">
                      <div className="flex items-center justify-center gap-1">
                        <Button size="icon" onClick={() => insertRowBefore(l.tempId)} variant="ghost" className="h-7 w-7 text-indigo-500 hover:bg-indigo-50 rounded" title="Insert Worker Above">
                          <ArrowUp className="w-4 h-4" />
                        </Button>
                        <Button size="icon" onClick={() => insertRowAfter(l.tempId)} variant="ghost" className="h-7 w-7 text-indigo-500 hover:bg-indigo-50 rounded" title="Insert Worker Below">
                          <ArrowDown className="w-4 h-4" />
                        </Button>
                        <Button size="sm" onClick={() => downloadPayslip(l)} className="h-7 text-[10px] bg-indigo-600 hover:bg-indigo-700 text-white px-2 rounded">
                          <FileText className="w-3 h-3 mr-1" /> PDF/Doc
                        </Button>
                        <Button size="icon" onClick={() => removeRow(l.tempId)} variant="ghost" className="h-7 w-7 text-red-500 hover:bg-red-50 rounded" title="Delete Row">
                          <Trash className="w-4 h-4" />
                        </Button>
                      </div>
                    </TableCell>
                  </TableRow>
                ))}
                
                {/* TOTAIS */}
                <TableRow className="bg-slate-900 text-white font-bold h-12">
                  <TableCell colSpan={4} className="p-2 text-right pr-4 uppercase tracking-tighter sticky left-0 z-40 bg-slate-900 border-r border-slate-700 border-b">Totais Displayed</TableCell>
                  <TableCell className="p-2 text-right border-r border-b border-slate-700">{formatMZN(displayedLines.reduce((s: any, c: any) => s + Number(c.base_salary || 0), 0))}</TableCell>
                  <TableCell className="p-2 text-right border-r border-b border-slate-700">{formatMZN(displayedLines.reduce((s: any, c: any) => s + Number(c.food_allowance || 0), 0))}</TableCell>
                  <TableCell className="p-2 text-right border-r border-b border-slate-700">{formatMZN(displayedLines.reduce((s: any, c: any) => s + Number(c.back_payment || 0), 0))}</TableCell>
                  <TableCell className="p-2 border-r border-b border-slate-700">---</TableCell>
                  <TableCell className="p-2 text-right border-r border-b border-slate-700 bg-slate-800">{formatMZN(displayedLines.reduce((s: any, c: any) => s + Number(c.monthly_salary || 0), 0))}</TableCell>
                  
                  <TableCell className="p-2 border-r border-b border-slate-700">---</TableCell>
                  <TableCell className="p-2 text-right border-r border-b border-slate-700 bg-slate-800">{formatMZN(displayedLines.reduce((s: any, c: any) => s + Number(c.guardas_25 || 0), 0))}</TableCell>
                  <TableCell className="p-2 border-r border-b border-slate-700">---</TableCell>
                  <TableCell className="p-2 text-right border-r border-b border-slate-700 bg-slate-800">{formatMZN(displayedLines.reduce((s: any, c: any) => s + Number(c.overtime_15x_amount || 0), 0))}</TableCell>
                  <TableCell className="p-2 border-r border-b border-slate-700">---</TableCell>
                  <TableCell className="p-2 text-right border-r border-b border-slate-700 bg-slate-800">{formatMZN(displayedLines.reduce((s: any, c: any) => s + Number(c.overtime_2x_amount || 0), 0))}</TableCell>
                  
                  <TableCell className="p-2 text-right border-r border-b border-slate-700">{formatMZN(displayedLines.reduce((s: any, c: any) => s + Number(c.gratification || 0), 0))}</TableCell>
                  <TableCell className="p-2 border-r border-b border-slate-700">---</TableCell>
                  <TableCell className="p-2 text-right border-r border-b border-slate-700 bg-slate-800">{formatMZN(displayedLines.reduce((s: any, c: any) => s + Number(c.holiday_amount || 0), 0))}</TableCell>
                  
                  <TableCell className="p-2 text-right border-r border-b border-slate-700 bg-green-900/50">{formatMZN(displayedLines.reduce((s: any, c: any) => s + Number(c.gross_total || 0), 0))}</TableCell>
                  
                  <TableCell className="p-2 text-right border-r border-b border-slate-700">{formatMZN(displayedLines.reduce((s: any, c: any) => s + Number(c.advance || 0), 0))}</TableCell>
                  <TableCell className="p-2 text-right border-r border-b border-slate-700">{formatMZN(displayedLines.reduce((s: any, c: any) => s + Number(c.irps || 0), 0))}</TableCell>
                  <TableCell className="p-2 text-right border-r border-b border-slate-700">{formatMZN(displayedLines.reduce((s: any, c: any) => s + Number(c.debt || 0), 0))}</TableCell>
                  <TableCell className="p-2 text-right border-r border-b border-slate-700 text-red-300">{formatMZN(displayedLines.reduce((s: any, c: any) => s + Number(c.inss_employee || 0), 0))}</TableCell>
                  <TableCell className="p-2 text-right border-r border-b border-slate-700">{formatMZN(displayedLines.reduce((s: any, c: any) => s + Number(c.sind || 0), 0))}</TableCell>
                  
                  <TableCell className="p-2 text-right border-r border-b border-slate-700 bg-red-900/50 italic">{formatMZN(displayedLines.reduce((s: any, c: any) => s + Number(c.total_deductions || 0), 0))}</TableCell>
                  <TableCell className="p-2 text-right border-r border-b border-slate-700 bg-green-600 text-white text-lg font-black">{formatMZN(displayedLines.reduce((s: any, c: any) => s + Number(c.net_salary || 0), 0))}</TableCell>
                  
                  <TableCell className="p-2 border-r border-b border-slate-700">---</TableCell>
                  <TableCell className="p-2 border-r border-b border-l border-slate-700 bg-slate-800 text-center text-slate-400 font-normal sticky right-0 z-40 shadow-[-2px_0_5px_-2px_rgba(0,0,0,0.5)]">Totals</TableCell>
                </TableRow>
              </TableBody>
            </Table>
          </div>
        </div>

        <div className="bg-slate-50 p-6 z-10 relative">
          <h3 className="text-sm font-bold uppercase tracking-[0.2em] text-slate-500 mb-4 flex items-center gap-2">
            <div className="h-4 w-1 bg-slate-800"></div> Total per Casa / Property Summary (Filtered)
          </h3>
          <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-6 gap-4">
            {Object.keys(totalsByHouse).length > 0 ? (
              Object.entries(totalsByHouse).sort().map(([house, total]: [string, any]) => (
                <div key={house} className="relative overflow-hidden group">
                  <div className="p-4 rounded-xl bg-white border border-slate-200 shadow-sm transition-all hover:shadow-md hover:border-slate-300">
                    <div className="flex items-center justify-between mb-1">
                      <span className="text-[10px] font-bold text-slate-400 group-hover:text-slate-600">{house}</span>
                      <div className="h-1.5 w-1.5 rounded-full bg-green-500"></div>
                    </div>
                    <div className="text-lg font-black text-slate-800 tracking-tight whitespace-nowrap">
                      {formatMZN(total)}
                    </div>
                  </div>
                </div>
              ))
            ) : (
               <div className="text-xs text-slate-500 italic py-2">No data available.</div>
            )}
          </div>
        </div>
      </CardContent>
    </Card>
  );
}

export default function Payroll() {
  const [zoomLevel, setZoomLevel] = useState(1);

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
    <div className="space-y-6 relative pb-24">
      
      {/* Floating Zoom Controls */}
      <div className="fixed bottom-6 right-6 z-[100] flex flex-col gap-2 p-2 bg-white rounded-full shadow-2xl border border-slate-200">
        <Button size="icon" variant="ghost" className="rounded-full" onClick={() => setZoomLevel(prev => Math.min(prev + 0.1, 1.5))}>
           <ZoomIn className="h-5 w-5 text-slate-700" />
        </Button>
        <div className="w-full h-px bg-slate-100"></div>
        <Button size="icon" variant="ghost" className="rounded-full" onClick={() => setZoomLevel(prev => Math.max(prev - 0.1, 0.5))}>
           <ZoomOut className="h-5 w-5 text-slate-700" />
        </Button>
      </div>

      <div className="flex items-center justify-between pl-2">
        <h1 className="text-3xl font-bold tracking-tight text-slate-800">Folha de Salários</h1>
      </div>

      {salaryRuns && salaryRuns.length > 0 ? (
        salaryRuns.map((run) => {
          const lines = salaryLines?.filter((l: any) => l.salary_run_id === run.id) ?? [];
          return <PayrollRun key={run.id} run={run} initialLines={lines} zoomLevel={zoomLevel} />;
        })
      ) : (
        <Card className="border-2 border-dashed border-slate-200 bg-slate-50/50 group hover:border-slate-300 transition-colors">
          <CardContent className="flex flex-col items-center justify-center py-32 text-slate-400">
            <FileSpreadsheet className="h-16 w-16 mb-4 opacity-20 group-hover:opacity-40 transition-opacity" />
            <p className="text-xl font-semibold text-slate-500">No payroll data available.</p>
            <p className="text-sm">Please generate or import payroll data.</p>
          </CardContent>
        </Card>
      )}
    </div>
  );
}
