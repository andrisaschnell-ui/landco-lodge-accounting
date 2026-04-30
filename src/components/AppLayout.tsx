import { SidebarProvider, SidebarTrigger } from "@/components/ui/sidebar";
import { AppSidebar } from "@/components/AppSidebar";
import { Outlet } from "react-router-dom";
import { ModeToggle } from "@/components/ModeToggle";
import { SyncPanel } from "@/components/SyncPanel";
import { useCompanySettings } from "@/hooks/useCompanySettings";

export function AppLayout() {
  const { settings } = useCompanySettings();
  const headerLabel = settings?.name
    ? `${settings.name}${settings.address ? " — " + settings.address.split("\n")[0] : ""}`
    : "Landco Lda — Vilanculos, Mozambique";

  return (
    <SidebarProvider>
      <div className="min-h-screen flex w-full">
        <AppSidebar />
        <div className="flex-1 flex flex-col">
          <header className="h-12 flex items-center border-b px-4 gap-3">
            <SidebarTrigger />
            <span className="ml-1 text-sm font-medium text-muted-foreground">{headerLabel}</span>
            <div className="ml-auto flex items-center gap-2">
              <SyncPanel />
              <ModeToggle />
            </div>
          </header>
          <main className="flex-1 p-6 overflow-auto">
            <Outlet />
          </main>
        </div>
      </div>
    </SidebarProvider>
  );
}
