# Web (React) container

Drop the entire LANACC React source tree into this `web/` folder, replacing
the placeholder. It must contain `package.json`, `vite.config.ts`, `index.html`,
the `src/` directory, etc.

The container builds with `npm run build` and is served by Nginx.

## Pointing the app at the local API

The Vite build receives `VITE_API_URL` (default `http://localhost:4000`) from
docker-compose. To use it in the React app, replace the Supabase client calls
with `fetch(`${import.meta.env.VITE_API_URL}/api/<table>`, ...)` or keep the
Supabase client pointing at the cloud project — both modes work.

A drop-in replacement for `src/integrations/supabase/client.ts` is provided in
`scripts/local-api-client.ts` of the package root.
