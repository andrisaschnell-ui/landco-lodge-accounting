const fs = require('fs');
const filePath = 'd:/landco/api/server.js';
let lines = fs.readFileSync(filePath, 'utf8').split('\\n');

// We want to remove lines that were duplicated.
// The new function ends at line 346 (in the previous view_file output).
// The duplication started at 347 and ended at 378.
// Since line numbers shift, I'll search for the duplication.

const content = fs.readFileSync(filePath, 'utf8');
const searchStr = '  const params = cols.map((_, i) => \`$\${i + 1}\`);';
// Find the SECOND occurrence of this string, as the first one is now inside the loop.
const firstIndex = content.indexOf(searchStr);
const secondIndex = content.indexOf(searchStr, firstIndex + 1);

if (secondIndex !== -1) {
    const startOfDupe = secondIndex;
    const endOfDupe = content.indexOf('});', secondIndex) + 3;
    const dupe = content.substring(startOfDupe, endOfDupe);
    const newContent = content.replace(dupe, '');
    fs.writeFileSync(filePath, newContent);
    console.log('Successfully cleaned up server.js');
} else {
    console.log('Could not find duplication');
}
