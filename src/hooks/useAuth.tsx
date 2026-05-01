import { createContext, useContext, useEffect, useState, ReactNode } from "react";
import { Session, User } from "@supabase/supabase-js";
import { supabase } from "@/integrations/supabase/client";
import { getLocalUser, logout } from "@/lib/api";

interface AuthContextType {
  session: Session | null;
  user: User | { id: string; email: string; display_name?: string; roles?: string[] } | null;
  loading: boolean;
  signOut: () => Promise<void>;
}

const AuthContext = createContext<AuthContextType>({
  session: null,
  user: null,
  loading: true,
  signOut: async () => {},
});

export function AuthProvider({ children }: { children: ReactNode }) {
  const [session, setSession] = useState<Session | null>(null);
  const [localUser, setLocalUser] = useState(getLocalUser());
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const { data: { subscription } } = supabase.auth.onAuthStateChange(
      (_event, newSession) => {
        setSession(newSession);
        setLoading(false);
      }
    );

    supabase.auth.getSession().then(({ data: { session: existing } }) => {
      setSession(existing);
      setLocalUser(getLocalUser());
      setLoading(false);
    });

    const syncLocalUser = () => setLocalUser(getLocalUser());
    window.addEventListener("lanacc-auth-change", syncLocalUser);

    return () => {
      subscription.unsubscribe();
      window.removeEventListener("lanacc-auth-change", syncLocalUser);
    };
  }, []);

  const signOut = async () => {
    // Log LOGOUT before clearing auth so actor_id can still be resolved.
    try {
      const email =
        (localUser as any)?.email ??
        (session?.user as any)?.email ??
        null;
      await supabase.rpc("fn_audit_event", {
        _action: "LOGOUT",
        _table_name: "auth",
        _row_id: email,
        _details: { email } as any,
      });
    } catch {
      // never block sign-out on audit failure
    }
    logout();
    setLocalUser(null);
    await supabase.auth.signOut();
  };

  return (
    <AuthContext.Provider value={{ session, user: localUser ?? session?.user ?? null, loading, signOut }}>
      {children}
    </AuthContext.Provider>
  );
}

export const useAuth = () => useContext(AuthContext);
