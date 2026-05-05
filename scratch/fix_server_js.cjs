const fs = require('fs');
const filePath = 'd:/landco/api/server.js';
let content = fs.readFileSync(filePath, 'utf8');

const testLine = 'const body = req.body || {}; // test';
const testIndex = content.indexOf(testLine);

if (testIndex !== -1) {
    const funcStart = content.lastIndexOf('app.post("/api/:table"', testIndex);
    const funcEnd = content.indexOf('});', testIndex) + 3;
    
    const replacement = `app.post("/api/:table", requireAuth, async (req, res) => {
  const t = req.params.table;
  if (!TABLES.has(t)) return res.status(404).json({ error: "unknown table" });
  if (!req.user.roles?.includes("admin")) return res.status(403).json({ error: "admin only" });
  
  const body = req.body || {};
  const rowsToInsert = Array.isArray(body) ? body : [body].filter(Boolean);
  if (!rowsToInsert.length) return res.json(Array.isArray(body) ? [] : null);

  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    const results = [];
    const poster = POSTERS[t];

    for (const rowData of rowsToInsert) {
      const cols = Object.keys(rowData);
      if (!cols.length) continue;
      const params = cols.map((_, i) => \`\\\$\\\${i + 1}\`);
      const { rows } = await client.query(
        \`INSERT INTO public.\${t} (\${cols.join(",")}) VALUES (\${params.join(",")}) RETURNING *\`,
        cols.map(c => rowData[c])
      );
      const row = rows[0];

      if (poster && !row.journal_entry_id) {
        const jeId = await poster(client, row, { userId: req.user.sub });
        if (jeId) {
          await linkSourceToEntry(client, t, row.id, jeId);
          row.journal_entry_id = jeId;
        }
      }
      results.push(row);
    }

    await client.query('COMMIT');
    res.json(Array.isArray(body) ? results : results[0]);
  } catch (e) {
    await client.query('ROLLBACK');
    res.status(500).json({ error: e.message });
  } finally {
    client.release();
  }
});`;

    const oldFunc = content.substring(funcStart, funcEnd);
    content = content.replace(oldFunc, replacement);
    fs.writeFileSync(filePath, content);
    console.log('Successfully updated server.js');
} else {
    console.error('Could not find test line in server.js');
}
