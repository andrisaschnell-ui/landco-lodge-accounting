import { SidebarProvider, SidebarTrigger } from "@/components/ui/sidebar";
import { AppSidebar } from "@/components/AppSidebar";
import { Outlet } from "react-router-dom";
import { ModeToggle } from "@/components/ModeToggle";
import { SyncPanel } from "@/components/SyncPanel";

export function AppLayout() {
  return (
    <SidebarProvider>
      <div className="min-h-screen flex w-full">
        <AppSidebar />
        <div className="flex-1 flex flex-col">
          <header className="h-12 flex items-center border-b px-4 gap-3">
            <SidebarTrigger />
            <span className="ml-1 text-sm font-medium text-muted-foreground">Landco Lda — Vilanculos, Mozambique</span>
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
