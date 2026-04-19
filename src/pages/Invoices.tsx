import { useQuery } from "@tanstack/react-query";
import { api } from "@/lib/api";
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
import { Plus, FileDown, Eye, CheckCircle } from "lucide-react";
import { toast } from "sonner";
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogTrigger } from "@/components/ui/dialog";
import { useState } from "react";
import InvoiceForm from "@/components/InvoiceForm";
import { useQueryClient } from "@tanstack/react-query";

export default function Invoices() {
  const [open, setOpen] = useState(false);
  const queryClient = useQueryClient();
  const { data: invoices, isLoading } = useQuery({
    queryKey: ["invoices"],
    queryFn: () => api("/api/invoices"),
  });

  const downloadPDF = (id: string, number: string) => {
    const token = localStorage.getItem("lanacc_token");
    window.open(`http://localhost:4000/api/invoices/${id}/pdf?token=${token}`, '_blank');
  };

  const handleIssue = async (id: string) => {
    try {
      await api(`/api/invoices/${id}/issue`, { method: "POST" });
      toast.success("Invoice issued and certified!");
      queryClient.invalidateQueries({ queryKey: ["invoices"] });
    } catch (err: any) {
      toast.error(err.message || "Failed to issue invoice");
    }
  };

  return (
    <div className="container mx-auto py-6 space-y-6">
      <div className="flex justify-between items-center">
        <h1 className="text-3xl font-bold tracking-tight">Invoices (AT Certified)</h1>
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
            <InvoiceForm onSuccess={() => setOpen(false)} />
          </DialogContent>
        </Dialog>
      </div>

      <Card>
        <CardHeader>
          <CardTitle>Invoice History</CardTitle>
        </CardHeader>
        <CardContent>
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Number</TableHead>
                <TableHead>Date</TableHead>
                <TableHead>Client</TableHead>
                <TableHead>Total (MZN)</TableHead>
                <TableHead>Status</TableHead>
                <TableHead className="text-right">Actions</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {isLoading ? (
                <TableRow>
                  <TableCell colSpan={6} className="text-center py-10">Loading invoices...</TableCell>
                </TableRow>
              ) : (
                invoices?.map((inv: any) => (
                  <TableRow key={inv.id}>
                    <TableCell className="font-mono font-medium">
                      {inv.invoice_number.startsWith('DRAFT') ? 'Draft' : inv.invoice_number}
                    </TableCell>
                    <TableCell>{format(new Date(inv.invoice_date), "dd/MM/yyyy")}</TableCell>
                    <TableCell>{inv.client_name}</TableCell>
                    <TableCell className="font-bold">
                      {Number(inv.total_mzn).toLocaleString(undefined, { minimumFractionDigits: 2 })}
                    </TableCell>
                    <TableCell>
                      {inv.status === 'issued' ? (
                        <Badge className="bg-blue-100 text-blue-800 hover:bg-blue-100 border-none">Issued</Badge>
                      ) : inv.status === 'paid' ? (
                        <Badge className="bg-green-100 text-green-800 hover:bg-green-100 border-none">Paid</Badge>
                      ) : (
                        <Badge variant="outline">Draft</Badge>
                      )}
                    </TableCell>
                    <TableCell className="text-right space-x-2">
                      <Button variant="ghost" size="icon" title="View Detail">
                        <Eye className="h-4 w-4" />
                      </Button>
                      {inv.status === 'draft' && (
                        <Button 
                          variant="ghost" 
                          size="icon" 
                          title="Issue (Certify)" 
                          className="text-blue-600"
                          onClick={() => handleIssue(inv.id)}
                        >
                          <CheckCircle className="h-4 w-4" />
                        </Button>
                      )}
                      <Button 
                        variant="ghost" 
                        size="icon" 
                        title="Download PDF" 
                        disabled={inv.status === 'draft'}
                        onClick={() => downloadPDF(inv.id, inv.invoice_number)}
                      >
                        <FileDown className="h-4 w-4" />
                      </Button>
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
