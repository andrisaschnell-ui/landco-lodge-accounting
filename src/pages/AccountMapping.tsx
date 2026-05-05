import { useState } from "react";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { db } from "@/lib/db";
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogFooter } from "@/components/ui/dialog";
import { toast } from "sonner";
import { Search, Plus, Edit2, Trash2, Info, Languages } from "lucide-react";
import { Tooltip, TooltipContent, TooltipTrigger, TooltipProvider } from "@/components/ui/tooltip";

export default function AccountMapping() {
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
      const { data } = await db.from("expense_categories").select("*").order("name_pt");
      return Array.isArray(data) ? data : [];
    },
  });

  const { data: accounts, isLoading: loadingAccs } = useQuery({
    queryKey: ["accounts"],
    queryFn: async () => {
      const { data } = await db.from("accounts").select("code, name").order("code");
      return Array.isArray(data) ? data : [];
    },
  });

  const saveMutation = useMutation({
    mutationFn: async (payload: any) => {
      if (editingCat) {
        const { error } = await db.from("expense_categories").update(payload).eq("id", editingCat.id);
        if (error) throw error;
      } else {
        const { error } = await db.from("expense_categories").insert([payload]);
        if (error) throw error;
      }
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["expense_categories"] });
      toast.success("Expense category saved.");
      setIsDialogOpen(false);
    },
    onError: (err: any) => {
      toast.error(err.message);
    },
  });

  const updateAccountMutation = useMutation({
    mutationFn: async ({ categoryId, code }: { categoryId: string; code: string }) => {
      const { error } = await db.from("expense_categories").update({ pgc_account_code: code }).eq("id", categoryId);
      if (error) throw error;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["expense_categories"] });
      toast.success("Mapping updated");
    },
    onError: (err: any) => {
      toast.error(err.message);
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
    if (!namePt) {
      toast.error("Portuguese name is required");
      return;
    }
    const payload = {
      name: namePt, 
      name_pt: namePt,
      name_en: nameEn,
      category_type: catType,
      parent_id: catType === "sub" ? parentId : null,
      is_shared: isShared,
    };
    saveMutation.mutate(payload);
  };

  const filteredCategories = categories?.filter(c => 
    (c.name_pt || c.name || "")?.toLowerCase().includes(filter.toLowerCase()) || 
    (c.name_en || "")?.toLowerCase().includes(filter.toLowerCase())
  );

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-3xl font-bold text-primary">Expense Mapping Dictionary</h1>
          <p className="text-muted-foreground">Manage and translate Portuguese-to-English expense categories.</p>
        </div>
        <div className="flex gap-4">
          <div className="relative w-64">
            <Search className="absolute left-2 top-2.5 h-4 w-4 text-muted-foreground" />
            <Input placeholder="Search dictionary..." className="pl-8" value={filter} onChange={(e) => setFilter(e.target.value)} />
          </div>
          <Button onClick={() => handleOpenDialog()} className="bg-primary hover:bg-primary/90">
            <Plus className="h-4 w-4 mr-2"/> Add Category
          </Button>
        </div>
      </div>

      <Card className="border-primary/20 shadow-lg">
        <CardHeader className="bg-primary/5 border-b border-primary/10">
          <CardTitle className="text-xl">Expense Dictionary & Ledger Mapping</CardTitle>
          <CardDescription>
            <span className="flex items-center gap-2">
              <Languages className="h-4 w-4 text-primary" />
              Hover over Portuguese terms to view English translations.
            </span>
          </CardDescription>
        </CardHeader>
        <CardContent className="p-0">
          <TooltipProvider delayDuration={200}>
            <Table>
              <TableHeader>
                <TableRow className="hover:bg-transparent bg-muted/50">
                  <TableHead className="font-bold">Category (Portuguese)</TableHead>
                  <TableHead className="font-bold">Type</TableHead>
                  <TableHead className="font-bold">Parent Category</TableHead>
                  <TableHead className="font-bold">Target NIRF Account</TableHead>
                  <TableHead className="text-right font-bold">Actions</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {loadingCats ? (
                   <TableRow><TableCell colSpan={5} className="text-center py-8">Loading dictionary...</TableCell></TableRow>
                ) : filteredCategories?.length === 0 ? (
                  <TableRow><TableCell colSpan={5} className="text-center py-8">No categories found matching your search.</TableCell></TableRow>
                ) : filteredCategories?.map((cat) => (
                  <TableRow key={cat.id} className="hover:bg-primary/5 transition-colors">
                    <TableCell className="font-medium">
                      <Tooltip>
                        <TooltipTrigger className="cursor-help border-b border-dashed border-primary/50 text-left">
                          {cat.name_pt || cat.name}
                        </TooltipTrigger>
                        <TooltipContent side="right" className="bg-primary text-primary-foreground p-2">
                          <p className="font-semibold">{cat.name_en || "No English translation available"}</p>
                        </TooltipContent>
                      </Tooltip>
                    </TableCell>
                    <TableCell>
                      <Badge variant={cat.category_type === 'sub' ? 'secondary' : 'outline'}>
                        {cat.category_type === 'sub' ? 'Sub' : 'Main'}
                      </Badge>
                    </TableCell>
                    <TableCell className="text-muted-foreground italic">
                      {cat.category_type === 'sub' && categories?.find(c => c.id === cat.parent_id)?.name_pt}
                    </TableCell>
                    <TableCell>
                      <Select 
                        value={cat.pgc_account_code || "unmapped"} 
                        onValueChange={(code) => updateAccountMutation.mutate({ categoryId: cat.id, code: code === "unmapped" ? null : code })}
                      >
                        <SelectTrigger className="w-full max-w-[220px] border-primary/20 hover:border-primary">
                          <SelectValue placeholder="Select account..." />
                        </SelectTrigger>
                        <SelectContent className="max-h-[300px]">
                          <SelectItem value="unmapped" className="text-muted-foreground italic">-- Unmapped --</SelectItem>
                          {accounts?.map((acc) => (
                            <SelectItem key={acc.code} value={acc.code}>
                              <div className="flex flex-col">
                                <span className="font-mono text-xs text-primary">{acc.code}</span>
                                <span className="text-sm">{acc.name}</span>
                              </div>
                            </SelectItem>
                          ))}
                        </SelectContent>
                      </Select>
                    </TableCell>
                    <TableCell className="text-right">
                      <Button variant="ghost" size="icon" onClick={() => handleOpenDialog(cat)} className="hover:text-primary">
                        <Edit2 className="h-4 w-4" />
                      </Button>
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          </TooltipProvider>
        </CardContent>
      </Card>

      <Dialog open={isDialogOpen} onOpenChange={setIsDialogOpen}>
        <DialogContent className="sm:max-w-[500px]">
          <DialogHeader>
            <DialogTitle className="text-2xl font-bold text-primary flex items-center gap-2">
              <Plus className="h-6 w-6" />
              {editingCat ? "Edit Dictionary Entry" : "Add New Dictionary Entry"}
            </DialogTitle>
            <CardDescription>Map Portuguese terms to English translations and accounting codes.</CardDescription>
          </DialogHeader>
          <div className="grid gap-6 py-4">
            <div className="grid gap-2">
              <label className="text-sm font-semibold flex items-center gap-2">
                Portuguese Term
                <span className="text-destructive text-xs">*</span>
              </label>
              <Input placeholder="e.g. Despesas Luz" value={namePt} onChange={e => setNamePt(e.target.value)} />
            </div>
            <div className="grid gap-2">
              <label className="text-sm font-semibold">English Translation</label>
              <Input placeholder="e.g. Electricity Expenses" value={nameEn} onChange={e => setNameEn(e.target.value)} />
            </div>
            <div className="grid grid-cols-2 gap-4">
              <div className="grid gap-2">
                <label className="text-sm font-semibold">Hierarchy Type</label>
                <Select value={catType} onValueChange={setCatType}>
                  <SelectTrigger><SelectValue/></SelectTrigger>
                  <SelectContent>
                    <SelectItem value="main">Main Category</SelectItem>
                    <SelectItem value="sub">Sub-Category</SelectItem>
                  </SelectContent>
                </Select>
              </div>
              
              {catType === "sub" && (
                <div className="grid gap-2">
                  <label className="text-sm font-semibold">Parent Category</label>
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
          </div>
          <DialogFooter className="gap-2">
            <Button variant="ghost" onClick={() => setIsDialogOpen(false)} className="hover:bg-muted">Cancel</Button>
            <Button onClick={handleSave} className="bg-primary hover:bg-primary/90">
              <Save className="h-4 w-4 mr-2" />
              Save Dictionary Entry
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}

function Badge({ children, variant = "default" }: { children: React.ReactNode; variant?: "default" | "secondary" | "outline" }) {
  const styles = {
    default: "bg-primary text-primary-foreground",
    secondary: "bg-secondary text-secondary-foreground",
    outline: "text-foreground border border-input bg-background"
  };
  return <span className={`inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-semibold transition-colors focus:outline-none focus:ring-2 focus:ring-ring focus:ring-offset-2 ${styles[variant]}`}>{children}</span>;
}

function Save({ className }: { className?: string }) {
  return <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" className={className}><path d="M19 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11l5 5v11a2 2 0 0 1-2 2z"/><polyline points="17 21 17 13 7 13 7 21"/><polyline points="7 3 7 8 15 8"/></svg>;
}
