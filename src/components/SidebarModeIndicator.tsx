import { Cloud, Server } from "lucide-react";
import { getDbMode, setDbMode } from "@/lib/dbMode";
import { cn } from "@/lib/utils";
import { useSidebar } from "@/components/ui/sidebar";

export function SidebarModeIndicator() {
  const mode = getDbMode();
  const { state } = useSidebar();
  const collapsed = state === "collapsed";
  const toggle = () => setDbMode(mode === "cloud" ? "local" : "cloud");
  const isCloud = mode === "cloud";

  return (
    <button
      onClick={toggle}
      title={`Currently: ${mode}. Click to switch.`}
      className={cn(
        "flex items-center gap-2 rounded-md px-3 py-2 text-xs font-semibold text-white shadow-sm transition hover:opacity-90 w-full justify-center",
        isCloud ? "bg-green-600 hover:bg-green-700" : "bg-red-600 hover:bg-red-700"
      )}
    >
      {isCloud ? <Cloud size={14} /> : <Server size={14} />}
      {!collapsed && <span>{isCloud ? "Cloud (Supabase)" : "Local (Postgres)"}</span>}
    </button>
  );
}
