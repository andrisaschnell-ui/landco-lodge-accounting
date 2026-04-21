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
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead className="w-[100px]">Code</TableHead>
                <TableHead>Name</TableHead>
                <TableHead>Type</TableHead>
                <TableHead>Normal Side</TableHead>
                <TableHead>Class</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {isLoading ? (
                <TableRow>
                  <TableCell colSpan={5} className="text-center py-10">Loading accounts...</TableCell>
                </TableRow>
              ) : (
                accounts?.map((account: any) => (
                  <TableRow key={account.id}>
                    <TableCell className="font-mono font-bold">{account.code}</TableCell>
                    <TableCell>{account.name}</TableCell>
                    <TableCell>
                      <Badge variant="outline" className="capitalize">
                        {account.account_type}
                      </Badge>
                    </TableCell>
                    <TableCell className="capitalize">{account.normal_side}</TableCell>
                    <TableCell className="text-muted-foreground">{account.pgc_class}</TableCell>
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
