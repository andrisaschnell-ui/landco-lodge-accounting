const fs = require('fs');
const path = require('path');
function getFiles(dir) {
  let results = [];
  const list = fs.readdirSync(dir);
  for (const file of list) {
    const full = path.join(dir, file);
    const stat = fs.statSync(full);
    if (stat && stat.isDirectory()) {
      results = results.concat(getFiles(full));
    } else if (full.endsWith('.ts') || full.endsWith('.tsx')) {
      results.push(full);
    }
  }
  return results;
}
const files = getFiles('src');
for (let file of files) {
  let code = fs.readFileSync(file, 'utf8');
  let changed = false;

  code = code.replace(/supabase\.from\((['"])(.*?)\1\)(\.[a-zA-Z0-9_]+\([^)]*\))*/g, (match, q1, table) => {
    changed = true;
    const methods = [...match.matchAll(/\.([a-zA-Z0-9_]+)\(([^)]*)\)/g)];
    let queryParams = [];
    let isSingle = false;
    let isCount = false;
    for (const m of methods) {
      const name = m[1];
      const args = m[2];
      if (name === 'eq' || name === 'is') {
         const parts = args.split(',').map(s => s.trim().replace(/^['"]|['"]$/g, ''));
         if (parts.length === 2) queryParams.push(`${parts[0]}=\${${parts[1]}}`);
      } else if (name === 'order') {
         const parts = args.split(',').map(s => s.trim().replace(/^['"]|['"]$/g, ''));
         if (parts.length >= 1) queryParams.push(`order=${parts[0]}`);
      } else if (name === 'single' || name === 'maybeSingle') {
         isSingle = true;
      } else if (name === 'select') {
         if (args.includes('count')) isCount = true;
      }
    }
    
    if (isCount) return `api(\`/api/${table}/count\`)`;
    
    let url = `\`/api/${table}`;
    if (queryParams.length > 0) url += `?` + queryParams.join('&');
    url += `\``;
    
    if (isSingle) {
      return `api(${url}).then(res => res[0] || null)`;
    } else {
      return `api(${url})`;
    }
  });

  // Now, there are likely lines that look like: const { data } = await api(...)
  // We already ran a pass to fix these, but let's make sure any remaining without `await` inside Promise.all are okay.
  // Actually, if it's inside Promise.all, `api(...)` correctly returns a promise resolving to the Array.

  if (changed) {
    fs.writeFileSync(file, code);
  }
}
console.log('Second pass codemod complete.');
