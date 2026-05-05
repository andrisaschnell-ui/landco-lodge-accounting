import { api } from "./api";

// A minimal query builder that compiles to fetch calls for the local API.
// This replaces the Supabase client in component files.
export const db = {
  from: (table: string) => {
    let selectCols = '*';
    let isCount = false;
    const queryParams = new URLSearchParams();

    const wrap = async <T>(promise: Promise<T>) => {
      try {
        const data = await promise;
        return { data, error: null };
      } catch (error) {
        return { data: null, error: error as Error };
      }
    };

    const makeMutationResult = <T>(promise: Promise<T>) => {
      const wrapped = wrap(promise);
      const chainable = {
        select: () => chainable,
        single: () => wrapped,
        then: wrapped.then.bind(wrapped),
        catch: wrapped.catch.bind(wrapped),
        finally: wrapped.finally.bind(wrapped),
      };
      return chainable;
    };

    const chain = {
      select: (cols = '*', options: { count?: string } = {}) => {
        selectCols = cols;
        if (options.count) isCount = true;
        return chain;
      },
      eq: (column: string, value: unknown) => {
        queryParams.append(column, String(value));
        return chain;
      },
      is: (column: string, value: unknown) => {
        if (value === null) queryParams.append(`__isnull_${column}`, 'true');
        return chain;
      },
      in: (column: string, values: unknown[]) => {
        queryParams.append(`__in_${column}`, values.join(','));
        return chain;
      },
      order: (column: string, options: { ascending?: boolean } = {}) => {
        queryParams.append('order', column);
        if (options.ascending === false) queryParams.append('ascending', 'false');
        return chain;
      },
      limit: (count: number) => {
        queryParams.append('limit', String(count));
        return chain;
      },
      gte: (column: string, value: unknown) => {
        queryParams.append(`__gte_${column}`, String(value));
        return chain;
      },
      lte: (column: string, value: unknown) => {
        queryParams.append(`__lte_${column}`, String(value));
        return chain;
      },
      not: (column: string, op: string, value: unknown) => {
        queryParams.append(`__not_${column}_${op}`, String(value));
        return chain;
      },
      insert: (payload: unknown) =>
        makeMutationResult(api(`/api/${table}`, { method: 'POST', body: JSON.stringify(payload) })),
      update: (payload: unknown) => {
        const updateParams = new URLSearchParams();
        const updateChain = {
          eq: (col: string, val: unknown) => {
            updateParams.append(col, String(val));
            return updateChain;
          },
          in: (col: string, vals: unknown[]) => {
            updateParams.append(`__in_${col}`, vals.join(','));
            return updateChain;
          },
          then: (resolve: (value: { data: unknown; error: Error | null }) => unknown, reject?: (reason: unknown) => unknown) => {
            const id = updateParams.get('id');
            const qs = updateParams.toString();
            const url = `/api/${table}` + (qs ? `?${qs}` : '');
            const promise = wrap(api(url, { method: 'PATCH', body: JSON.stringify({ ...(payload as object), id }) }));
            return promise.then(resolve, reject);
          },
          catch: (reject: (reason: unknown) => unknown) => updateChain.then((value) => value, reject),
        };
        return updateChain;
      },
      delete: () => {
        const delParams = new URLSearchParams();
        const delChain = {
          eq: (col: string, val: unknown) => {
            delParams.append(col, String(val));
            return delChain;
          },
          in: (col: string, vals: unknown[]) => {
            delParams.append(`__in_${col}`, vals.join(','));
            return delChain;
          },
          then: (resolve: (value: { data: unknown; error: Error | null }) => unknown, reject?: (reason: unknown) => unknown) => {
            const id = delParams.get('id');
            const qs = delParams.toString();
            let url = `/api/${table}`;
            if (id && delParams.keys && Array.from(delParams.keys()).length === 1) url += `/${id}`;
            else if (qs) url += `?${qs}`;
            return wrap(api(url, { method: 'DELETE' })).then(resolve, reject);
          },
          catch: (reject: (reason: unknown) => unknown) => delChain.then((value) => value, reject),
        };
        return delChain;
      },
      upsert: (payload: unknown, options: unknown) =>
        wrap(api(`/api/${table}/upsert`, { method: 'POST', body: JSON.stringify({ payload, options }) })),
      single: () => {
        queryParams.append('limit', '1');
        return execute().then((res) => ({ data: res.data ? res.data[0] || null : null, error: res.error }));
      },
      maybeSingle: () => {
        queryParams.append('limit', '1');
        return execute().then((res) => ({ data: res.data ? res.data[0] || null : null, error: res.error }));
      },
      then: (resolve: (value: { data: unknown; error: Error | null }) => unknown, reject?: (reason: unknown) => unknown) => execute().then(resolve, reject)
    };

    async function execute() {
       try {
         let url = `/api/${table}`;
         if (isCount) url += `/count`;
         const qs = queryParams.toString();
         if (qs) url += `?${qs}`;

         const data = await api(url);
         if (!Array.isArray(data) || data.length === 0) return { data, error: null };

         // Simulation of Supabase joins for the local Express API
         if (selectCols.includes('shareholders(')) {
           const { data: rel } = await db.from('shareholders').select('*');
           if (rel) {
             data.forEach(row => {
               row.shareholders = rel.find(r => r.id === row.shareholder_id);
             });
           }
         }
         if (selectCols.includes('properties(')) {
           const { data: rel } = await db.from('properties').select('*');
           if (rel) {
             data.forEach(row => {
               row.properties = rel.find(r => r.id === row.property_id || r.code === row.property_code);
             });
           }
         }
         if (selectCols.includes('expense_categories(')) {
           const { data: rel } = await db.from('expense_categories').select('*');
           if (rel) {
             data.forEach(row => {
               row.expense_categories = rel.find(r => r.id === row.category_id);
             });
           }
         }
         if (selectCols.includes('employees(')) {
           const { data: rel } = await db.from('employees').select('*');
           if (rel) {
             data.forEach(row => {
               row.employees = rel.find(r => r.id === row.employee_id);
             });
           }
         }

         return { data, error: null };
       } catch (error) {
         return { data: null, error: error as Error };
       }
    }

    return chain;
  }
};
