/**
 * LANACC Local API Wrapper
 * This mock intercepts Supabase calls and redirects them to the local Port 4000 API.
 */
const API_URL = "http://localhost:4000";

const createMockQueryBuilder = (table: string) => {
  const state = { table };
  
  const builder: any = {
    select: () => builder,
    order: () => builder,
    eq: () => builder,
    single: () => builder,
    // Add more chainable methods as needed...
    
    then: async (onfulfilled: any) => {
      try {
        const token = localStorage.getItem("lanacc_token");
        const res = await fetch(`${API_URL}/api/${state.table}`, {
          headers: { 
            "Content-Type": "application/json",
            "Authorization": token ? `Bearer ${token}` : ""
          }
        });
        const data = await res.json();
        return onfulfilled({ data, error: null });
      } catch (e: any) {
        return onfulfilled({ data: null, error: { message: e.message } });
      }
    }
  };
  
  return builder;
};

export const supabase: any = {
  auth: {
    signInWithPassword: async ({ email, password }: any) => {
      try {
        const res = await fetch(`${API_URL}/auth/login`, {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({ email, password }),
        });
        const data = await res.json();
        if (!res.ok) throw data;
        
        localStorage.setItem("lanacc_token", data.token);
        localStorage.setItem("lanacc_user", JSON.stringify(data.user));
        
        // Mock a Supabase session structure
        const session = { access_token: data.token, user: data.user };
        
        // Dispatch event for other listeners
        window.dispatchEvent(new Event("storage"));
        
        return { data: { user: data.user, session }, error: null };
      } catch (e: any) {
        return { data: { user: null, session: null }, error: { message: e.error || e.message } };
      }
    },
    signOut: async () => {
      localStorage.removeItem("lanacc_token");
      localStorage.removeItem("lanacc_user");
      window.location.href = "/auth";
      return { error: null };
    },
    getSession: async () => {
      const token = localStorage.getItem("lanacc_token");
      const user = JSON.parse(localStorage.getItem("lanacc_user") || "null");
      if (token && user) return { data: { session: { access_token: token, user } }, error: null };
      return { data: { session: null }, error: null };
    },
    onAuthStateChange: (callback: any) => {
      const handler = () => {
        const token = localStorage.getItem("lanacc_token");
        const user = JSON.parse(localStorage.getItem("lanacc_user") || "null");
        callback("SIGNED_IN", token ? { access_token: token, user } : null);
      };
      window.addEventListener("storage", handler);
      // Initial trigger
      setTimeout(handler, 0);
      return { data: { subscription: { unsubscribe: () => window.removeEventListener("storage", handler) } } };
    }
  },
  from: (table: string) => createMockQueryBuilder(table)
};