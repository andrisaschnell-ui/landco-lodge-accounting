import { Cloud, Server } from "lucide-react";
import { getDbMode, setDbMode } from "@/lib/dbMode";
import { cn } from "@/lib/utils";

interface Props {
  variant?: "pill" | "chip";
  className?: string;
}

export function ModeToggle({ variant = "chip", className }: Props) {
  const mode = getDbMode();
  const toggle = () => setDbMode(mode === "cloud" ? "local" : "cloud");

  if (variant === "pill") {
    return (
      <div className={cn("inline-flex rounded-full border bg-muted p-1 text-xs font-medium", className)}>
        <button
          onClick={() => mode !== "cloud" && setDbMode("cloud")}
          className={cn(
            "flex items-center gap-1.5 rounded-full px-3 py-1 transition",
            mode === "cloud" ? "bg-background shadow text-foreground" : "text-muted-foreground"
          )}
        >
          <Cloud size={14} /> Cloud
        </button>
        <button
          onClick={() => mode !== "local" && setDbMode("local")}
          className={cn(
            "flex items-center gap-1.5 rounded-full px-3 py-1 transition",
            mode === "local" ? "bg-background shadow text-foreground" : "text-muted-foreground"
          )}
        >
          <Server size={14} /> Local
        </button>
      </div>
    );
  }

  return (
    <button
      onClick={toggle}
      title={`Currently: ${mode}. Click to switch.`}
      className={cn(
        "inline-flex items-center gap-1.5 rounded-md border px-2.5 py-1 text-xs font-medium hover:bg-accent",
        mode === "local" ? "border-amber-500/40 text-amber-700 dark:text-amber-400" : "border-blue-500/40 text-blue-700 dark:text-blue-400",
        className
      )}
    >
      {mode === "cloud" ? <Cloud size={14} /> : <Server size={14} />}
      {mode === "cloud" ? "Cloud" : "Local"}
    </button>
  );
}
