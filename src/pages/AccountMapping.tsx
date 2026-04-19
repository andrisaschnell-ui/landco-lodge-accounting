import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { supabase } from "@/integrations/supabase/client";
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { useToast } from "@/hooks/use-toast";
import { Search } from "lucide-react";
import { useState } from "react";
import { Input } from "@/components/ui/input";

export default function AccountMapping() {
  const { toast } = useToast();
  const queryClient = useQueryClient();
  const [filter, setFilter] = useState("");

  const { data: categories, isLoading: loadingCats } = useQuery({
    queryKey: ["expense_categories"],
    queryFn: async () => {
      const { data } = await supabase.from("expense_categories").select("*").order("name");
      return data ?? [];
    },
  });

  const { data: accounts, isLoading: loadingAccs } = useQuery({
    queryKey: ["accounts"],
    queryFn: async () => {
      const { data } = await supabase.from("accounts").select("code, name").order("code");
      return data ?? [];
    },
  });

  const updateMappingMutation = useMutation({
    mutationFn: async ({ categoryId, code }: { categoryId: string; code: string }) => {
      const { error } = await supabase
        .from("expense_categories")
        .update({ pgc_account_code: code })
        .eq("id", categoryId);
      if (error) throw error;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["expense_categories"] });
      toast({ title: "Mapping updated", description: "Expense category mapped successfully." });
    },
    onError: (err: any) => {
      toast({ title: "Failed to update", description: err.message, variant: "destructive" });
    },
  });

  const filteredCategories = categories?.filter(c => 
    c.name.toLowerCase().includes(filter.toLowerCase())
  );

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-3xl font-bold">Expense Mapping</h1>
          <p className="text-muted-foreground">Map legacy expense categories to NIRF Accounting Codes.</p>
        </div>
        <div className="relative w-64">
          <Search className="absolute left-2 top-2.5 h-4 w-4 text-muted-foreground" />
          <Input 
            placeholder="Search categories..." 
            className="pl-8" 
            value={filter} 
            onChange={(e) => setFilter(e.target.value)} 
          />
        </div>
      </div>

      <Card>
        <CardHeader>
          <CardTitle>Category to Account Mapping</CardTitle>
          <CardDescription>
            This ensures that every time you log an expense, the system automatically posts it to the correct ledger account.
          </CardDescription>
        </CardHeader>
        <CardContent>
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Expense Category</TableHead>
                <TableHead>Target NIRF Account</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {filteredCategories?.map((cat) => (
                <TableRow key={cat.id}>
                  <TableCell className="font-medium">{cat.name}</TableCell>
                  <TableCell>
                    <Select 
                      value={cat.pgc_account_code || ""} 
                      onValueChange={(code) => updateMappingMutation.mutate({ categoryId: cat.id, code })}
                    >
                      <SelectTrigger className="w-full max-w-md">
                        <SelectValue placeholder="Unmapped (Manual entry only)" />
                      </SelectTrigger>
                      <SelectContent>
                        {accounts?.map((acc) => (
                          <SelectItem key={acc.code} value={acc.code}>
                            <span className="font-mono text-xs mr-2">{acc.code}</span>
                            {acc.name}
                          </SelectItem>
                        ))}
                      </SelectContent>
                    </Select>
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
