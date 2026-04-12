import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Upload, FileSpreadsheet } from "lucide-react";

export default function UploadData() {
  return (
    <div className="space-y-6">
      <h1 className="text-3xl font-bold">Upload Data</h1>
      <p className="text-muted-foreground">Upload Excel spreadsheets to import accounting data into LANACC.</p>

      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
        {[
          { title: "Month End Accounts", desc: "01 JAN MONTH END 2026.xlsx", type: "month_end" },
          { title: "Petty Cash", desc: "01 Petty Cash PETTY CASH 2026.xlsx", type: "petty_cash" },
          { title: "Salary Sheets", desc: "01 Salary sheet for Landco.xlsx", type: "salary" },
          { title: "BIM Salary Transfers", desc: "01 BIM SALARIOS 2026.xlsx", type: "bim_transfer" },
          { title: "BDO Bank Control", desc: "01 BDO Bank Control 2026.xlsx", type: "bdo_bank" },
          { title: "Shareholder Worksheets", desc: "01 COCO COHEN New Worksheet 2026.xlsx", type: "shareholder" },
        ].map((item) => (
          <Card key={item.type} className="hover:border-primary/50 transition-colors cursor-pointer">
            <CardHeader>
              <div className="flex items-center gap-3">
                <FileSpreadsheet className="h-8 w-8 text-primary" />
                <div>
                  <CardTitle className="text-base">{item.title}</CardTitle>
                  <CardDescription className="text-xs">{item.desc}</CardDescription>
                </div>
              </div>
            </CardHeader>
            <CardContent>
              <div className="flex items-center justify-center border-2 border-dashed rounded-lg p-8 text-muted-foreground hover:border-primary/30 transition-colors">
                <div className="text-center">
                  <Upload className="h-6 w-6 mx-auto mb-2" />
                  <p className="text-sm">Coming soon</p>
                  <p className="text-xs">Drag & drop or click to upload</p>
                </div>
              </div>
            </CardContent>
          </Card>
        ))}
      </div>
    </div>
  );
}
