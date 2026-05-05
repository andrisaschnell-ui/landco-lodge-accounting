import { useQuery, useQueryClient } from "@tanstack/react-query";
import { db } from "@/lib/db";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { format } from "date-fns";
import { Button } from "@/components/ui/button";
import { Plus } from "lucide-react";
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogTrigger } from "@/components/ui/dialog";
import { useState } from "react";
import InvoiceForm from "@/components/InvoiceForm";
import { supabase } from "@/integrations/supabase/client";

function fmt(v: number | null | undefined) {
  return new Intl.NumberFormat("en-US", { minimumFractionDigits: 2 }).format(Number(v ?? 0));
}

export default function Invoices() {
  const [open, setOpen] = useState(false);
  const queryClient = useQueryClient();

  const { data: invoices, isLoading } = useQuery({
    queryKey: ["invoices"],
    queryFn: async () => {
      const { data, error } = await supabase
        .from("invoices")
        .select("*")
        .order("invoice_date", { ascending: false });
      if (error) throw error;
      return data ?? [];
    },
  });

  return (
    <div className="container mx-auto py-6 space-y-6">
      <div className="flex justify-between items-center">
        <h1 className="text-3xl font-bold tracking-tight">Invoices</h1>
        <Dialog open={open} onOpenChange={setOpen}>
          <DialogTrigger asChild>
            <Button>
              <Plus className="mr-2 h-4 w-4" />
              New Invoice
            </Button>
          </DialogTrigger>
          <DialogContent className="max-w-3xl">
            <DialogHeader>
              <DialogTitle>Create New Draft Invoice</DialogTitle>
            </DialogHeader>
            <InvoiceForm onSuccess={() => {
              setOpen(false);
              queryClient.invalidateQueries({ queryKey: ["invoices"] });
            }} />
          </DialogContent>
        </Dialog>
      </div>

      <Card>
        <CardHeader>
          <CardTitle>Invoice History ({invoices?.length ?? 0})</CardTitle>
        </CardHeader>
        <CardContent>
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Number</TableHead>
                <TableHead>Date</TableHead>
                <TableHead>Client / Description</TableHead>
                <TableHead className="text-right">Subtotal (MZN)</TableHead>
                <TableHead className="text-right">IVA (MZN)</TableHead>
                <TableHead className="text-right">Total (MZN)</TableHead>
                <TableHead>Status</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {isLoading ? (
                <TableRow>
                  <TableCell colSpan={7} className="text-center py-10">Loading invoices…</TableCell>
                </TableRow>
              ) : !invoices || invoices.length === 0 ? (
                <TableRow>
                  <TableCell colSpan={7} className="text-center py-10 text-muted-foreground">
                    No invoices yet — upload the Invoices sheet from the BDO workbook on the Upload page.
                  </TableCell>
                </TableRow>
              ) : (
                invoices.map((inv) => (
                  <TableRow key={inv.id}>
                    <TableCell className="font-mono font-medium text-xs">
                      {inv.invoice_number.startsWith("DRAFT") ? "Draft" : inv.invoice_number}
                    </TableCell>
                    <TableCell>{format(new Date(inv.invoice_date), "dd/MM/yyyy")}</TableCell>
                    <TableCell className="max-w-[300px] truncate">{inv.client_name}</TableCell>
                    <TableCell className="text-right">{fmt(inv.subtotal_mzn)}</TableCell>
                    <TableCell className="text-right">{fmt(inv.vat_amount_mzn)}</TableCell>
                    <TableCell className="text-right font-bold">{fmt(inv.total_mzn)}</TableCell>
                    <TableCell>
                      {inv.status === "issued" ? (
                        <Badge>Issued</Badge>
                      ) : inv.status === "paid" ? (
                        <Badge variant="secondary">Paid</Badge>
                      ) : inv.status === "imported" ? (
                        <Badge variant="outline">Imported</Badge>
                      ) : (
                        <Badge variant="outline">Draft</Badge>
                      )}
                    </TableCell>
                  </TableRow>
                ))
              )}
            </TableBody>
          </Table>
        </CardContent>
      </Card>
    </div>
  );
}
