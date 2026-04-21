import { useQuery } from "@tanstack/react-query";
import { list } from "@/lib/api";
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

export default function ChartOfAccounts() {
  const { data: accounts, isLoading } = useQuery({
    queryKey: ["accounts"],
    queryFn: () => list("accounts"),
  });

  return (
    <div className="container mx-auto py-6 space-y-6">
      <div className="flex justify-between items-center">
        <h1 className="text-3xl font-bold tracking-tight">Chart of Accounts (PGC-NIRF)</h1>
      </div>

      <Card>
        <CardHeader>
          <CardTitle>Accounts</CardTitle>
        </CardHeader>
        <CardContent>
          <BaseTable>
            <BaseHeader>
              <BaseRow>
                <BaseHead className="w-[100px]">Code</BaseHead>
                <BaseHead>Name</BaseHead>
                <BaseHead>Type</BaseHead>
                <BaseHead>Normal Side</BaseHead>
                <BaseHead>Class</BaseHead>
              </BaseRow>
            </BaseHeader>
            <BaseBody>
              {isLoading ? (
                <BaseRow>
                  <BaseCell colSpan={5} className="text-center py-10">Loading accounts...</BaseCell>
                </BaseRow>
              ) : (
                accounts?.map((account: any) => (
                  <BaseRow key={account.id}>
                    <BaseCell className="font-mono font-bold">{account.code}</BaseCell>
                    <BaseCell>{account.name}</BaseCell>
                    <BaseCell>
                      <Badge variant="outline" className="capitalize">
                        {account.account_type}
                      </Badge>
                    </BaseCell>
                    <BaseCell className="capitalize">{account.normal_side}</BaseCell>
                    <BaseCell className="text-muted-foreground">{account.pgc_class}</BaseCell>
                  </BaseRow>
                ))
              )}
            </BaseBody>
          </BaseTable>
        </CardContent>
      </Card>
    </div>
  );
}
