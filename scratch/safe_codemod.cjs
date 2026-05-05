const fs = require('fs');
let code = fs.readFileSync('D:/landco/src/pages/Payroll.tsx', 'utf8');

// The new body of handleEditCell
const newHandle = `  const handleEditCell = (tempId: string, field: string, value: any) => {
    setLocalLines(prev => prev.map(l => {
      if (l.tempId === tempId) {
        let newLine = { ...l };
        if (field === 'house_assignment_temp') {
          newLine = { ...newLine, employees: { ...newLine.employees, house_assignment: value }, house_assignment_temp: value };
        } else if (field === 'name') {
          newLine = { ...newLine, employees: { ...newLine.employees, name: value } };
        } else if (field === 'nib') {
          newLine = { ...newLine, employees: { ...newLine.employees, nib: value }, nib: value };
        } else {
          newLine = { ...newLine, [field]: value };
        }
        
        const increaseMult = (run.month >= (settings?.salary_increase_month || 4)) 
          ? (1 + (settings?.salary_increase_percentage || 0) / 100) 
          : 1;

        const bs = Number(newLine.base_salary || 0);
        const effectiveBs = bs * increaseMult;
        const dw = Number(newLine.days_worked ?? 30);
        const food = Number(newLine.food_allowance || 0);
        const back = Number(newLine.back_payment || 0);
        
        newLine.monthly_salary = (effectiveBs / 30) * dw + food + back;
        
        const nsHours = Number(newLine.nightshift_hours || 0);
        newLine.guardas_25 = dw > 0 ? (newLine.monthly_salary / dw / 8) * nsHours * 0.25 : 0;
        
        const ot15Hours = Number(newLine.overtime_15x_hours || 0);
        newLine.overtime_15x_amount = (effectiveBs / 192) * ot15Hours * 1.5;
        
        const ot2Hours = Number(newLine.overtime_2x_hours || 0);
        newLine.overtime_2x_amount = (newLine.monthly_salary / 192) * ot2Hours * 2.0;
        
        const holDays = Number(newLine.holiday_days || 0);
        newLine.holiday_amount = (newLine.monthly_salary / 30) * holDays;
        
        const premios = Number(newLine.premios || 0);
        const grat = Number(newLine.gratification || 0);
        
        newLine.gross_total = newLine.monthly_salary + newLine.guardas_25 + newLine.overtime_15x_amount + newLine.overtime_2x_amount + premios + grat + newLine.holiday_amount;
        
        newLine.inss_employee = newLine.gross_total * 0.03;
        newLine.sind = newLine.gross_total * 0.01;
        
        const adv = Number(newLine.advance || 0);
        const irps = Number(newLine.irps || 0);
        const debt = Number(newLine.debt || 0);
        
        newLine.total_deductions = adv + irps + debt + newLine.inss_employee + newLine.sind;
        newLine.net_salary = newLine.gross_total - newLine.total_deductions;
        
        return newLine;
      }
      return l;
    }));
  };`;

// Regex replacement for handleEditCell
code = code.replace(/const handleEditCell = \(tempId: string, field: string, value: any\) => \{[\s\S]*?\n  \};\r?\n/, newHandle + '\n');

// Update DB Inserts (first occurrence)
code = code.replace(/overtime_2x_amount: l\.overtime_2x_amount,\s+gratification: l\.gratification,/, 'overtime_2x_amount: l.overtime_2x_amount,\n          premios: l.premios,\n          gratification: l.gratification,');

// Update DB Inserts (second occurrence)
code = code.replace(/overtime_2x_amount: l\.overtime_2x_amount,\s+gratification: l\.gratification,/, 'overtime_2x_amount: l.overtime_2x_amount,\n        premios: l.premios,\n        gratification: l.gratification,');

// Update uploadExcel mapping
code = code.replace(/overtime_2x_amount: row\["Overtime 2x \(Amt\)"\] \|\| 0,\s+gratification: row\["Gratification"\] \|\| 0,/, 'overtime_2x_amount: row["Overtime 2x (Amt)"] || 0,\n        premios: row["Premios"] || 0,\n        gratification: row["Gratification"] || 0,');

// Update template headers
code = code.replace(/"Overtime 2x \(Amt\)", "Gratification",/, '"Overtime 2x (Amt)", "Premios", "Gratification",');

// Update downloadExcel mapping
code = code.replace(/l\.overtime_2x_amount \|\| 0,\s+l\.gratification \|\| 0,/, 'l.overtime_2x_amount || 0,\n        l.premios || 0,\n        l.gratification || 0,');

// Update downloadExcel Formulas
code = code.replace(/const monthlySalaryFormula = \{ t: 'n', f: \`E\$\{rowNum\}\+F\$\{rowNum\}\+G\$\{rowNum\}\` \};/, 'const monthlySalaryFormula = { t: \'n\', f: `E${rowNum}/30*H${rowNum}+F${rowNum}+G${rowNum}` };');
code = code.replace(/const grossTotalFormula = \{ t: 'n', f: \`I\$\{rowNum\}\+K\$\{rowNum\}\+M\$\{rowNum\}\+O\$\{rowNum\}\+P\$\{rowNum\}\+R\$\{rowNum\}\` \};/, 'const grossTotalFormula = { t: \'n\', f: `I${rowNum}+K${rowNum}+M${rowNum}+O${rowNum}+P${rowNum}+Q${rowNum}+S${rowNum}` };');
code = code.replace(/const deductionsFormula = \{ t: 'n', f: \`T\$\{rowNum\}\+U\$\{rowNum\}\+V\$\{rowNum\}\+W\$\{rowNum\}\+X\$\{rowNum\}\` \};/, 'const deductionsFormula = { t: \'n\', f: `U${rowNum}+V${rowNum}+W${rowNum}+X${rowNum}+Y${rowNum}` };');
code = code.replace(/const netSalaryFormula = \{ t: 'n', f: \`S\$\{rowNum\}-Y\$\{rowNum\}\` \};/, 'const netSalaryFormula = { t: \'n\', f: `T${rowNum}-Z${rowNum}` };');

// Update table headers
code = code.replace(/<TableHead className="text-right p-2 sticky top-0 bg-slate-100 z-40 border-r border-b border-t">GRATIFIC\.<\/TableHead>/, '<TableHead className="text-right p-2 sticky top-0 bg-slate-100 z-40 border-r border-b border-t">PREMIOS</TableHead>\n                  <TableHead className="text-right p-2 sticky top-0 bg-slate-100 z-40 border-r border-b border-t">GRATIFIC.</TableHead>');

// Update mapped fields array
code = code.replace(/\{ field: 'gratification' \},/, '{ field: \'premios\' },\n                      { field: \'gratification\' },');

// Update totals footer
code = code.replace(/<TableCell className="p-2 text-right border-r border-b border-slate-700">\{formatMZN\(displayedLines\.reduce\(\(s: any, c: any\) => s \+ Number\(c\.gratification \|\| 0\), 0\)\)\}<\/TableCell>/, '<TableCell className="p-2 text-right border-r border-b border-slate-700">{formatMZN(displayedLines.reduce((s: any, c: any) => s + Number(c.premios || 0), 0))}</TableCell>\n                  <TableCell className="p-2 text-right border-r border-b border-slate-700">{formatMZN(displayedLines.reduce((s: any, c: any) => s + Number(c.gratification || 0), 0))}</TableCell>');

fs.writeFileSync('D:/landco/src/pages/Payroll.tsx', code);
console.log('Replaced successfully');
