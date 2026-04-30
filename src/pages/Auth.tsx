import { useState } from "react";
import { supabase } from "@/integrations/supabase/client";
import { login as localLogin, getApiBase } from "@/lib/api";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Eye, EyeOff } from "lucide-react";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Label } from "@/components/ui/label";
import { useToast } from "@/hooks/use-toast";
import { ModeToggle } from "@/components/ModeToggle";
import { isLocalMode } from "@/lib/dbMode";

export default function Auth() {
  const [isLogin, setIsLogin] = useState(true);
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [pin, setPin] = useState("");
  const [showPassword, setShowPassword] = useState(false);
  const [loading, setLoading] = useState(false);
  const { toast } = useToast();

  async function doLogin() {
    if (isLocalMode()) {
      await localLogin(email, password);
      window.dispatchEvent(new CustomEvent("lanacc-auth-change"));
    } else {
      const { error } = await supabase.auth.signInWithPassword({ email, password });
      if (error) throw new Error(error.message);
    }
  }

  async function doAdminSignup() {
    if (!pin) throw new Error("Admin PIN required to create a new account");
    if (password.length < 8) throw new Error("Password must be at least 8 characters");

    if (isLocalMode()) {
      const r = await fetch(`${getApiBase()}/auth/signup-admin`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ email, password, pin }),
      });
      const data = await r.json().catch(() => ({}));
      if (!r.ok) throw new Error(data.error || "signup failed");
    } else {
      const { data, error } = await supabase.functions.invoke("signup-admin", {
        body: { email, password, pin },
      });
      if (error) throw new Error(error.message);
      if ((data as any)?.error) throw new Error((data as any).error);
    }
    // Auto sign-in after successful admin creation
    await doLogin();
  }

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    try {
      if (isLogin) {
        await doLogin();
      } else {
        await doAdminSignup();
        toast({ title: "Admin account ready", description: `${email} created with admin privileges.` });
      }
    } catch (err: any) {
      toast({
        title: isLogin ? "Login failed" : "Admin signup failed",
        description: err?.message || "Unknown error",
        variant: "destructive",
      });
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="flex min-h-screen items-center justify-center bg-muted/30 px-4">
      <Card className="w-full max-w-md">
        <CardHeader className="text-center">
          <CardTitle className="text-2xl font-bold">LANACC</CardTitle>
          <CardDescription>Landco Lda — Accounting Management</CardDescription>
          <div className="flex justify-center pt-2">
            <ModeToggle variant="pill" />
          </div>
        </CardHeader>
        <CardContent>
          <form onSubmit={handleSubmit} className="space-y-4">
            <div className="space-y-2">
              <Label htmlFor="email">Email</Label>
              <Input id="email" type="email" value={email} onChange={(e) => setEmail(e.target.value)} required placeholder="you@example.com" />
            </div>
            <div className="space-y-2">
              <Label htmlFor="password">Password</Label>
              <div className="relative">
                <Input
                  id="password"
                  type={showPassword ? "text" : "password"}
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  required
                  placeholder="••••••••"
                  minLength={isLogin ? 6 : 8}
                  className="pr-10"
                />
                <button
                  type="button"
                  onClick={() => setShowPassword(!showPassword)}
                  className="absolute right-3 top-1/2 -translate-y-1/2 text-muted-foreground hover:text-foreground"
                >
                  {showPassword ? <EyeOff size={18} /> : <Eye size={18} />}
                </button>
              </div>
            </div>

            {!isLogin && (
              <div className="space-y-2">
                <Label htmlFor="pin">Admin PIN</Label>
                <Input
                  id="pin"
                  type="password"
                  value={pin}
                  onChange={(e) => setPin(e.target.value)}
                  required
                  placeholder="Required to create an admin account"
                />
                <p className="text-xs text-muted-foreground">
                  New accounts are created with full admin privileges. Ask the system owner for the PIN.
                </p>
              </div>
            )}

            <Button type="submit" className="w-full" disabled={loading}>
              {loading ? "Loading..." : isLogin ? "Sign In" : "Create Admin Account"}
            </Button>
          </form>
          <p className="mt-4 text-center text-sm text-muted-foreground">
            {isLogin ? "Need to create an admin account?" : "Already have an account?"}{" "}
            <button
              type="button"
              className="text-primary underline"
              onClick={() => {
                setIsLogin(!isLogin);
                setPin("");
              }}
            >
              {isLogin ? "Admin Sign Up" : "Sign In"}
            </button>
          </p>
        </CardContent>
      </Card>
    </div>
  );
}
