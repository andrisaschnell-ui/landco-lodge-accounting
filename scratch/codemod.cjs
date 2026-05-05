const fs = require('fs');
const ts = require('typescript');
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
  if (!code.includes('supabase.from')) continue;

  // We will do a regex replacement that transforms the chain into a fetch call.
  // Since AST manipulation without ts-morph is very verbose, we'll use a regex that matches the whole statement.
  
  // Replace import
  code = code.replace(/import\s+\{\s*supabase\s*\}\s+from\s+['"]@\/integrations\/supabase\/client['"];?/, "import { api } from '@/lib/api';");

  // Regex to match supabase.from("table").select("cols")...
  // This is a naive regex but works for most single-line chained calls.
  code = code.replace(/await\s+supabase\.from\((['"])(.*?)\1\)(\.[a-zA-Z0-9_]+\([^)]*\))*/g, (match, q1, table) => {
    // extract all method calls
    const methods = [...match.matchAll(/\.([a-zA-Z0-9_]+)\(([^)]*)\)/g)];
    let queryParams = [];
    let isSelect = false;
    let isInsert = false;
    let isUpdate = false;
    let isDelete = false;
    let payload = null;
    let isSingle = false;
    
    for (const m of methods) {
      const name = m[1];
      const args = m[2];
      if (name === 'select') {
         isSelect = true;
         // ignore cols for now since local API returns all
      } else if (name === 'eq') {
         const parts = args.split(',').map(s => s.trim().replace(/^['"]|['"]$/g, ''));
         if (parts.length === 2) queryParams.push(`${parts[0]}=\${${parts[1]}}`);
      } else if (name === 'order') {
         const parts = args.split(',').map(s => s.trim().replace(/^['"]|['"]$/g, ''));
         if (parts.length >= 1) {
             queryParams.push(`order=${parts[0]}`);
             if (parts.length > 1 && parts[1].includes('ascending: false')) {
                 queryParams.push(`ascending=false`);
             }
         }
      } else if (name === 'insert') {
         isInsert = true;
         payload = args;
      } else if (name === 'update') {
         isUpdate = true;
         payload = args;
      } else if (name === 'delete') {
         isDelete = true;
      } else if (name === 'single' || name === 'maybeSingle') {
         isSingle = true;
      }
    }
    
    let url = `\`/api/${table}`;
    if (queryParams.length > 0) {
      url += `?` + queryParams.join('&');
    }
    url += `\``;
    
    if (isInsert) {
      return `await api(${url}, { method: 'POST', body: JSON.stringify(${payload}) })`;
    } else if (isUpdate) {
      return `await api(${url}, { method: 'PATCH', body: JSON.stringify(${payload}) })`;
    } else if (isDelete) {
      return `await api(${url}, { method: 'DELETE' })`;
    } else {
      // it's a GET
      if (isSingle) {
        return `await api(${url}).then(res => res[0] || null)`;
      } else {
        return `await api(${url})`;
      }
    }
  });

  // some might return { data, error }. We need to strip that if we replaced it with direct api returns
  // const { data } = await api(...) -> const data = await api(...)
  code = code.replace(/const\s+\{\s*data\s*\}\s*=\s*await\s+api/g, "const data = await api");
  code = code.replace(/const\s+\{\s*data\s*:\s*([^,]+)\s*\}\s*=\s*await\s+api/g, "const $1 = await api");

  fs.writeFileSync(file, code);
}
console.log('Codemod complete.');
