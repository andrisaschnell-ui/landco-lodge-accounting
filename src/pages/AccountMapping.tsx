import { useState } from "react";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { supabase } from "@/integrations/supabase/client";
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogFooter } from "@/components/ui/dialog";
import { useToast } from "@/hooks/use-toast";
import { Search, Plus, Edit2, Trash2, Info } from "lucide-react";
import { Tooltip, TooltipContent, TooltipTrigger, TooltipProvider } from "@/components/ui/tooltip";

export default function AccountMapping() {
  const { toast } = useToast();
  const queryClient = useQueryClient();
  const [filter, setFilter] = useState("");
  const [isDialogOpen, setIsDialogOpen] = useState(false);
  const [editingCat, setEditingCat] = useState<any>(null);
  
  // Form State
  const [namePt, setNamePt] = useState("");
  const [nameEn, setNameEn] = useState("");
  const [catType, setCatType] = useState("main");
  const [parentId, setParentId] = useState("");
  const [isShared, setIsShared] = useState(true);

  const { data: categories, isLoading: loadingCats } = useQuery({
    queryKey: ["expense_categories"],
    queryFn: async () => {
      const { data } = await supabase.from("expense_categories").select("*").order("name");
      return Array.isArray(data) ? data : [];
    },
  });

  const { data: accounts, isLoading: loadingAccs } = useQuery({
    queryKey: ["accounts"],
    queryFn: async () => {
      const { data } = await supabase.from("accounts").select("code, name").order("code");
      return Array.isArray(data) ? data : [];
    },
  });

  const saveMutation = useMutation({
    mutationFn: async (payload: any) => {
      if (editingCat) {
        const { error } = await supabase.from("expense_categories").update(payload).eq("id", editingCat.id);
        if (error) throw error;
      } else {
        const { error } = await supabase.from("expense_categories").insert([payload]);
        if (error) throw error;
      }
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["expense_categories"] });
      toast({ title: "Success", description: "Expense category saved." });
      setIsDialogOpen(false);
    },
    onError: (err: any) => {
      toast({ title: "Error", description: err.message, variant: "destructive" });
    },
  });

  const deleteMutation = useMutation({
    mutationFn: async (id: string) => {
      const { error } = await supabase.from("expense_categories").update({ pgc_account_code: null }).eq("id", id); // Unmap if needed, but it's simpler to just map instead of full delete for now if relations exist. Wait, let's delete it.
      // We will perform an actual delete, but if it has transaction dependencies it might fail.
      const { error: delErr } = await supabase.from("expense_categories").update({}).eq("id", "0"); // mock
      // Local API is naive, we can just send a DELETE although generic API doesn't support DELETE yet!
      // Let's implement a safe generic patch API call here or just use supabase wrapper with a patch to a deleted flag if needed.
      // Wait, our backend server.js doesn't have app.delete("/api/:table")! 
    }
  });

  const handleOpenDialog = (cat: any = null) => {
    setEditingCat(cat);
    setNamePt(cat?.name_pt || cat?.name || "");
    setNameEn(cat?.name_en || "");
    setCatType(cat?.category_type || "main");
    setParentId(cat?.parent_id || "");
    setIsShared(cat?.is_shared ?? true);
    setIsDialogOpen(true);
  };

  const handleSave = () => {
    const payload = {
      name: namePt, // Fallback legacy name
      name_pt: namePt,
      name_en: nameEn,
      category_type: catType,
      parent_id: catType === "sub" ? parentId : null,
      is_shared: isShared,
    };
    saveMutation.mutate(payload);
  };

  const updateAccountMutation = useMutation({
    mutationFn: async ({ categoryId, code }: { categoryId: string; code: string }) => {
      const { error } = await supabase.from("expense_categories").update({ pgc_account_code: code }).eq("id", categoryId);
      if (error) throw error;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["expense_categories"] });
      toast({ title: "Mapping updated" });
    }
  });

  const filteredCategories = categories?.filter(c => 
    (c.name_pt || c.name)?.toLowerCase().includes(filter.toLowerCase()) || 
    c.name_en?.toLowerCase().includes(filter.toLowerCase())
  );

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-3xl font-bold">Expense Mapping Dictionary</h1>
          <p className="text-muted-foreground">Manage and translate Portuguese-to-English expense categories.</p>
        </div>
        <div className="flex gap-4">
          <div className="relative w-64">
            <Search className="absolute left-2 top-2.5 h-4 w-4 text-muted-foreground" />
            <Input placeholder="Search..." className="pl-8" value={filter} onChange={(e) => setFilter(e.target.value)} />
          </div>
          <Button onClick={() => handleOpenDialog()}><Plus className="h-4 w-4 mr-2"/> Add Category</Button>
        </div>
      </div>

      <Card>
        <CardHeader>
          <CardTitle>Expense Dictionary & Ledger Mapping</CardTitle>
          <CardDescription>Hover over Portuguese terms to view English translations.</CardDescription>
        </CardHeader>
        <CardContent>
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Category (PT)</TableHead>
                <TableHead>Type</TableHead>
                <TableHead>Parent Category</TableHead>
                <TableHead>Target NIRF Account</TableHead>
                <TableHead className="text-right">Actions</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {filteredCategories?.map((cat) => (
                <TableRow key={cat.id}>
                  <TableCell className="font-medium flex items-center gap-2">
                    <TooltipProvider>
                      <Tooltip>
                        <TooltipTrigger className="cursor-help border-b border-dashed border-primary/50">
                          {cat.name_pt || cat.name}
                        </TooltipTrigger>
                        <TooltipContent>
                          <p>{cat.name_en || "No English translation"}</p>
                        </TooltipContent>
                      </Tooltip>
                    </TooltipProvider>
                  </TableCell>
                  <TableCell>
                    <span className={`text-xs px-2 py-1 rounded ${cat.category_type === 'sub' ? 'bg-blue-100 text-blue-700' : 'bg-gray-100'}`}>
                      {cat.category_type === 'sub' ? 'Sub' : 'Main'}
                    </span>
                  </TableCell>
                  <TableCell>
                    {cat.category_type === 'sub' && categories?.find(c => c.id === cat.parent_id)?.name_pt}
                  </TableCell>
                  <TableCell>
                    <Select 
                      value={cat.pgc_account_code || ""} 
                      onValueChange={(code) => updateAccountMutation.mutate({ categoryId: cat.id, code })}
                    >
                      <SelectTrigger className="w-full max-w-[200px]">
                        <SelectValue placeholder="Unmapped" />
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
                  <TableCell className="text-right">
                    <Button variant="ghost" size="sm" onClick={() => handleOpenDialog(cat)}>
                      <Edit2 className="h-4 w-4" />
                    </Button>
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </CardContent>
      </Card>

      <Dialog open={isDialogOpen} onOpenChange={setIsDialogOpen}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>{editingCat ? "Edit Category" : "Add New Category"}</DialogTitle>
          </DialogHeader>
          <div className="space-y-4 py-4">
            <div className="space-y-2">
              <label className="text-sm font-medium">Portuguese Name (Required)</label>
              <Input placeholder="e.g. Despesas Luz" value={namePt} onChange={e => setNamePt(e.target.value)} />
            </div>
            <div className="space-y-2">
              <label className="text-sm font-medium">English Translation</label>
              <Input placeholder="e.g. Luz Expenses" value={nameEn} onChange={e => setNameEn(e.target.value)} />
            </div>
            <div className="space-y-2">
              <label className="text-sm font-medium">Hierarchy Type</label>
              <Select value={catType} onValueChange={setCatType}>
                <SelectTrigger><SelectValue/></SelectTrigger>
                <SelectContent>
                  <SelectItem value="main">Main Category</SelectItem>
                  <SelectItem value="sub">Sub-Category</SelectItem>
                </SelectContent>
              </Select>
            </div>
            
            {catType === "sub" && (
              <div className="space-y-2">
                <label className="text-sm font-medium">Parent Category</label>
                <Select value={parentId} onValueChange={setParentId}>
                  <SelectTrigger><SelectValue placeholder="Select Parent..."/></SelectTrigger>
                  <SelectContent>
                    {categories?.filter(c => c.category_type !== "sub" && c.id !== editingCat?.id).map((c) => (
                      <SelectItem key={c.id} value={c.id}>{c.name_pt || c.name}</SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>
            )}
          </div>
          <DialogFooter>
            <Button variant="outline" onClick={() => setIsDialogOpen(false)}>Cancel</Button>
            <Button onClick={handleSave}>Save Category</Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}
