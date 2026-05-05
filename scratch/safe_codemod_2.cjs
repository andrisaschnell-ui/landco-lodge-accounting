const fs = require('fs');
let code = fs.readFileSync('D:/landco/src/pages/Payroll.tsx', 'utf8');

code = code.replace(/overtime_2x_amount: row\["Overtime 2x \(Amt\)"\] \|\| 0,\s*gratification: row\["Gratification"\] \|\| 0,/, 'overtime_2x_amount: row["Overtime 2x (Amt)"] || 0,\n        premios: row["Premios"] || 0,\n        gratification: row["Gratification"] || 0,');
code = code.replace(/"Overtime 2x \(Amt\)", "Gratification",/, '"Overtime 2x (Amt)", "Premios", "Gratification",');
code = code.replace(/l\.overtime_2x_amount \|\| 0,\s*l\.gratification \|\| 0,/, 'l.overtime_2x_amount || 0,\n        l.premios || 0,\n        l.gratification || 0,');
code = code.replace(/\{\s*field: 'gratification'\s*\}/, '{ field: \'premios\' },\n                      { field: \'gratification\' }');

fs.writeFileSync('D:/landco/src/pages/Payroll.tsx', code);
console.log('Fixed the rest');
