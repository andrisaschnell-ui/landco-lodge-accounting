import { useMemo, useState } from "react";
import { useQuery, useQueryClient } from "@tanstack/react-query";
import { db } from "@/lib/db";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Trash2, Undo2, Save, XCircle, AlertCircle } from "lucide-react";
import { toast } from "sonner";
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
} from "@/components/ui/alert-dialog";

type LandcoIncomeRow = {
  id: string;
  transaction_date: string;
  period_month: number;
  period_year: number;
  property_code: "H1" | "H2" | "H3" | "H4";
  description: string;
  accommodation_amount_mzn: number | string;
  total_mzn: number | string;
  amount_usd: number | string;
  exchange_rate_used: number | string | null;
  monthly_total_mzn_source: number | string | null;
  import_notes: string | null;
};

const MONTH_NAMES = ["All", "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];

function fmt(value: number | string | null | undefined) {
  return new Intl.NumberFormat("en-US", { minimumFractionDigits: 2, maximumFractionDigits: 2 }).format(Number(value ?? 0));
}

export default function Income() {
  const queryClient = useQueryClient();
  const [yearFilter, setYearFilter] = useState<string>("all");
  const [monthFilter, setMonthFilter] = useState<string>("all");
  const [propertyFilter, setPropertyFilter] = useState<string>("all");
  const [markedForDeletion, setMarkedForDeletion] = useState<Set<string>>(new Set());
  const [showConfirm, setShowConfirm] = useState(false);
  const [isDeleting, setIsDeleting] = useState(false);

  const { data: rows } = useQuery({
    queryKey: ["landco-income"],
    queryFn: async () => {
      const { data } = await db.from("landco_income").select("*").order("transaction_date");
      return (data as LandcoIncomeRow[]) ?? [];
    },
  });

  const availableYears = useMemo(
    () => Array.from(new Set((rows ?? []).map((row) => String(row.period_year)))).sort(),
    [rows],
  );

  const filteredRows = useMemo(() => {
    return (rows ?? []).filter((row) => {
      if (yearFilter !== "all" && String(row.period_year) !== yearFilter) return false;
      if (monthFilter !== "all" && String(row.period_month) !== monthFilter) return false;
      if (propertyFilter !== "all" && row.property_code !== propertyFilter) return false;
      return true;
    });
  }, [monthFilter, propertyFilter, rows, yearFilter]);

  const summary = useMemo(() => {
    // We exclude marked rows from the summary totals so the user sees the "target" state
    const activeRows = filteredRows.filter(r => !markedForDeletion.has(r.id));
    const totalMzn = activeRows.reduce((sum, row) => sum + Number(row.total_mzn ?? 0), 0);
    const totalUsd = activeRows.reduce((sum, row) => sum + Number(row.amount_usd ?? 0), 0);
    const byProperty = ["H1", "H2", "H3", "H4"].map((code) => ({
      code,
      totalMzn: activeRows
        .filter((row) => row.property_code === code)
        .reduce((sum, row) => sum + Number(row.total_mzn ?? 0), 0),
    })).filter((item) => item.totalMzn > 0);
    return { totalMzn, totalUsd, byProperty };
  }, [filteredRows, markedForDeletion]);

  const toggleDelete = (id: string) => {
    setMarkedForDeletion(prev => {
      const next = new Set(prev);
      if (next.has(id)) next.delete(id);
      else next.add(id);
      return next;
    });
  };

  const handleApplyDeletions = async () => {
    setIsDeleting(true);
    try {
      const ids = Array.from(markedForDeletion);
      const { error } = await db.from("landco_income").delete().in("id", ids);
      if (error) throw error;
      
      toast.success(`Successfully deleted ${ids.length} records`);
      setMarkedForDeletion(new Set());
      queryClient.invalidateQueries({ queryKey: ["landco-income"] });
    } catch (e: any) {
      toast.error(`Deletion failed: ${e.message}`);
    } finally {
      setIsDeleting(false);
      setShowConfirm(false);
    }
  };

  return (
    <div className="space-y-6">
      <div className="flex flex-col gap-4 md:flex-row md:items-center md:justify-between">
        <div>
          <h1 className="text-3xl font-bold">Landco Income</h1>
          <p className="text-muted-foreground">
            Owner-linked lodge income imported from the `INCOME` worksheet on the month-end workbooks.
          </p>
        </div>
        
        {markedForDeletion.size > 0 && (
          <Card className="border-destructive/50 bg-destructive/5">
            <CardContent className="flex items-center gap-4 py-3">
              <div className="flex items-center gap-2 text-destructive">
                <AlertCircle className="h-5 w-5" />
                <span className="font-semibold">{markedForDeletion.size} rows marked for removal</span>
              </div>
              <div className="flex gap-2">
                <Button 
                  size="sm" 
                  variant="destructive" 
                  onClick={() => setShowConfirm(true)}
                  disabled={isDeleting}
                >
                  <Save className="mr-2 h-4 w-4" />
                  Save / Done
                </Button>
                <Button 
                  size="sm" 
                  variant="outline" 
                  onClick={() => setMarkedForDeletion(new Set())}
                  disabled={isDeleting}
                >
                  <XCircle className="mr-2 h-4 w-4" />
                  Cancel
                </Button>
              </div>
            </CardContent>
          </Card>
        )}
      </div>

      <div className="grid gap-4 md:grid-cols-4">
        <Card>
          <CardHeader><CardTitle className="text-sm font-medium">Rows</CardTitle></CardHeader>
          <CardContent><div className="text-2xl font-bold">{filteredRows.length - markedForDeletion.size}</div></CardContent>
        </Card>
        <Card>
          <CardHeader><CardTitle className="text-sm font-medium">Total MZN</CardTitle></CardHeader>
          <CardContent><div className="text-2xl font-bold">MZN {fmt(summary.totalMzn)}</div></CardContent>
        </Card>
        <Card>
          <CardHeader><CardTitle className="text-sm font-medium">Total USD</CardTitle></CardHeader>
          <CardContent><div className="text-2xl font-bold">USD {fmt(summary.totalUsd)}</div></CardContent>
        </Card>
        <Card>
          <CardHeader><CardTitle className="text-sm font-medium">Property Mix</CardTitle></CardHeader>
          <CardContent className="space-y-1">
            {summary.byProperty.length > 0 ? summary.byProperty.map((item) => (
              <div key={item.code} className="flex items-center justify-between text-sm">
                <Badge variant="outline">{item.code}</Badge>
                <span>{fmt(item.totalMzn)}</span>
              </div>
            )) : <p className="text-sm text-muted-foreground">No rows for this filter.</p>}
          </CardContent>
        </Card>
      </div>

      <Card>
        <CardHeader><CardTitle>Filters</CardTitle></CardHeader>
        <CardContent className="grid gap-4 md:grid-cols-3">
          <div>
            <p className="mb-2 text-sm font-medium">Year</p>
            <Select value={yearFilter} onValueChange={setYearFilter}>
              <SelectTrigger><SelectValue /></SelectTrigger>
              <SelectContent>
                <SelectItem value="all">All years</SelectItem>
                {availableYears.map((year) => <SelectItem key={year} value={year}>{year}</SelectItem>)}
              </SelectContent>
            </Select>
          </div>
          <div>
            <p className="mb-2 text-sm font-medium">Month</p>
            <Select value={monthFilter} onValueChange={setMonthFilter}>
              <SelectTrigger><SelectValue /></SelectTrigger>
              <SelectContent>
                <SelectItem value="all">All months</SelectItem>
                {MONTH_NAMES.slice(1).map((monthName, index) => (
                  <SelectItem key={monthName} value={String(index + 1)}>{monthName}</SelectItem>
                ))}
              </SelectContent>
            </Select>
          </div>
          <div>
            <p className="mb-2 text-sm font-medium">Property</p>
            <Select value={propertyFilter} onValueChange={setPropertyFilter}>
              <SelectTrigger><SelectValue /></SelectTrigger>
              <SelectContent>
                <SelectItem value="all">All properties</SelectItem>
                {["H1", "H2", "H3", "H4"].map((code) => <SelectItem key={code} value={code}>{code}</SelectItem>)}
              </SelectContent>
            </Select>
          </div>
        </CardContent>
      </Card>

      <Card>
        <CardHeader><CardTitle>Imported Rows</CardTitle></CardHeader>
        <CardContent>
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Date</TableHead>
                <TableHead>Property</TableHead>
                <TableHead>Description</TableHead>
                <TableHead className="text-right">Accommodation</TableHead>
                <TableHead className="text-right">Total MZN</TableHead>
                <TableHead className="text-right">USD</TableHead>
                <TableHead className="text-right">Rate</TableHead>
                <TableHead>Notes</TableHead>
                <TableHead className="text-right">Actions</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {filteredRows.length > 0 ? filteredRows.map((row) => {
                const isMarked = markedForDeletion.has(row.id);
                return (
                  <TableRow key={row.id} className={isMarked ? "bg-destructive/10 text-muted-foreground line-through opacity-60" : ""}>
                    <TableCell>{row.transaction_date}</TableCell>
                    <TableCell><Badge variant="outline">{row.property_code}</Badge></TableCell>
                    <TableCell className="max-w-[320px] truncate">{row.description}</TableCell>
                    <TableCell className="text-right">{fmt(row.accommodation_amount_mzn)}</TableCell>
                    <TableCell className="text-right">{fmt(row.total_mzn)}</TableCell>
                    <TableCell className="text-right">{fmt(row.amount_usd)}</TableCell>
                    <TableCell className="text-right">{row.exchange_rate_used ? fmt(row.exchange_rate_used) : "—"}</TableCell>
                    <TableCell className="text-xs text-muted-foreground">{row.import_notes || "—"}</TableCell>
                    <TableCell className="text-right">
                      <Button
                        variant="ghost"
                        size="icon"
                        className={isMarked ? "text-primary" : "text-destructive hover:bg-destructive/10 hover:text-destructive"}
                        onClick={() => toggleDelete(row.id)}
                        title={isMarked ? "Reverse Delete" : "Delete Row"}
                      >
                        {isMarked ? <Undo2 className="h-4 w-4" /> : <Trash2 className="h-4 w-4" />}
                      </Button>
                    </TableCell>
                  </TableRow>
                );
              }) : (
                <TableRow>
                  <TableCell colSpan={9} className="py-8 text-center text-muted-foreground">
                    No income rows have been imported for this filter yet.
                  </TableCell>
                </TableRow>
              )}
            </TableBody>
          </Table>
        </CardContent>
      </Card>

      <AlertDialog open={showConfirm} onOpenChange={setShowConfirm}>
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle>Confirm Permanent Deletion</AlertDialogTitle>
            <AlertDialogDescription>
              You are about to permanently delete {markedForDeletion.size} record(s) from the income table. 
              This action cannot be undone. Associated journal entries will also be affected.
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel disabled={isDeleting}>Cancel</AlertDialogCancel>
            <AlertDialogAction 
              onClick={handleApplyDeletions}
              className="bg-destructive text-destructive-foreground hover:bg-destructive/90"
              disabled={isDeleting}
            >
              {isDeleting ? "Deleting..." : "Delete Permanently"}
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </div>
  );
}
