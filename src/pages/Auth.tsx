import { useState } from "react";
import { supabase } from "@/integrations/supabase/client";
import { login as localLogin } from "@/lib/api";
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
  const [showPassword, setShowPassword] = useState(false);
  const [loading, setLoading] = useState(false);
  const { toast } = useToast();

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);

    if (isLogin) {
      if (isLocalMode()) {
        try {
          await localLogin(email, password);
          window.dispatchEvent(new CustomEvent("lanacc-auth-change"));
        } catch (localError: any) {
          toast({ title: "Login failed", description: localError.message, variant: "destructive" });
          setLoading(false);
          return;
        }
      } else {
        const { error } = await supabase.auth.signInWithPassword({ email, password });
        if (error) {
          toast({ title: "Login failed", description: error.message, variant: "destructive" });
          setLoading(false);
          return;
        }
      }
    } else {
      const { error } = await supabase.auth.signUp({ email, password });
      if (error) toast({ title: "Sign up failed", description: error.message, variant: "destructive" });
      else toast({ title: "Account created", description: "Check your email for confirmation." });
    }
    setLoading(false);
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
                  minLength={6} 
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
            <Button type="submit" className="w-full" disabled={loading}>
              {loading ? "Loading..." : isLogin ? "Sign In" : "Sign Up"}
            </Button>
          </form>
          <p className="mt-4 text-center text-sm text-muted-foreground">
            {isLogin ? "Don't have an account?" : "Already have an account?"}{" "}
            <button className="text-primary underline" onClick={() => setIsLogin(!isLogin)}>
              {isLogin ? "Sign Up" : "Sign In"}
            </button>
          </p>
        </CardContent>
      </Card>
    </div>
  );
}
