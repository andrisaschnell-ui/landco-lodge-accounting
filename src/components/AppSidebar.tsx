import {
  LayoutDashboard, ArrowLeftRight, Users, Building2, Briefcase,
  FileSpreadsheet, Upload, LogOut, BarChart3,
  BookOpen, ReceiptText, FileText, Settings2, BarChart, AlertTriangle,
  Wallet, Eye, ClipboardList, Database, Settings as SettingsIcon,
  Scale, BookOpenCheck, CalendarClock as CalendarLock,
  TrendingUp, Target, UserCheck,
  Package, Boxes, BookCheck, Coins, ShieldCheck, History,
  Landmark,
} from "lucide-react";
import { NavLink } from "@/components/NavLink";
import { useLocation } from "react-router-dom";
import { useEffect, useState } from "react";
import {
  Sidebar, SidebarContent, SidebarGroup, SidebarGroupContent,
  SidebarGroupLabel, SidebarMenu, SidebarMenuButton, SidebarMenuItem,
  SidebarFooter, useSidebar,
} from "@/components/ui/sidebar";
import { useAuth } from "@/hooks/useAuth";
import { useCompanySettings } from "@/hooks/useCompanySettings";
import { db } from "@/lib/db";
import { Button } from "@/components/ui/button";
import { SidebarModeIndicator } from "@/components/SidebarModeIndicator";
import { SyncPanel } from "@/components/SyncPanel";

const mainItems = [
  { title: "Dashboard", url: "/", icon: LayoutDashboard },
  { title: "Transactions", url: "/transactions", icon: ArrowLeftRight },
  { title: "Shareholders", url: "/shareholders", icon: Users },
  { title: "Employees", url: "/employees", icon: Briefcase },
  { title: "Payroll", url: "/payroll", icon: FileSpreadsheet },
  { title: "Properties", url: "/properties", icon: Building2 },
  { title: "Reports", url: "/reports", icon: BarChart3 },
  { title: "Upload", url: "/upload", icon: Upload },
];

const accountingItems = [
  { title: "Chart of Accounts", url: "/accounting/accounts", icon: BookOpen },
  { title: "Journal Entries", url: "/accounting/journal", icon: FileText },
  { title: "Landco Income", url: "/accounting/income", icon: Landmark },
  { title: "Account Ledger", url: "/accounting/ledger", icon: BookOpenCheck },
  { title: "Trial Balance", url: "/accounting/trial-balance", icon: Scale },
  { title: "Invoices", url: "/accounting/invoices", icon: ReceiptText },
  { title: "Expense Payments", url: "/accounting/expense-payments", icon: Wallet },
  { title: "Account Mapping", url: "/accounting/mapping", icon: Settings2 },
  { title: "Suspense Review", url: "/accounting/suspense", icon: AlertTriangle },
  { title: "Periods", url: "/accounting/periods", icon: CalendarLock },
  { title: "Financial Statements", url: "/accounting/statements", icon: TrendingUp },
  { title: "Budgets", url: "/accounting/budgets", icon: Target },
  { title: "Customer / Supplier Ledgers", url: "/accounting/party-ledgers", icon: UserCheck },
  { title: "Fixed Assets", url: "/accounting/fixed-assets", icon: Package },
  { title: "Inventory", url: "/accounting/inventory", icon: Boxes },
  { title: "Bank Reconciliation", url: "/accounting/bank-reconciliation", icon: BookCheck },
  { title: "FX Revaluation", url: "/accounting/fx-revaluation", icon: Coins },
  { title: "Approvals", url: "/accounting/approvals", icon: ShieldCheck },
  { title: "Audit Log", url: "/accounting/audit-log", icon: History },
  { title: "Accounting Reports", url: "/accounting/reports", icon: BarChart },
  { title: "Shareholder Statements", url: "/accounting/shareholders", icon: Users },
];

const cashControlItems = [
  { title: "Cash Control Uploaded", url: "/cash-control", icon: Wallet },
  { title: "Cash Control Display", url: "/cash-control/display", icon: Eye },
  { title: "Control Report", url: "/cash-control/reports", icon: ClipboardList },
];

const databaseBackupItems = [
  { title: "Dashboard", url: "/database-backup", icon: Database },
];

export function AppSidebar() {
  const { state } = useSidebar();
  const collapsed = state === "collapsed";
  const location = useLocation();
  const { signOut, user } = useAuth();
  const { settings } = useCompanySettings();
  const [isAdmin, setIsAdmin] = useState(false);

  useEffect(() => {
    (async () => {
      const uid = (user as any)?.id;
      if (!uid) { setIsAdmin(false); return; }
      const { data } = await db.from("user_roles").select("role").eq("user_id", uid);
      setIsAdmin(!!data?.some((r: any) => r.role === "admin"));
    })();
  }, [user]);

  const companyName = settings?.name || "LANACC";

  return (
    <Sidebar collapsible="icon">
      <SidebarContent>
        <SidebarGroup>
          <SidebarGroupLabel>
            {!collapsed && <span className="font-bold text-lg">{companyName}</span>}
          </SidebarGroupLabel>
          <SidebarGroupContent>
            <div className="px-2 pb-2 space-y-2">
              <SidebarModeIndicator />
              {!collapsed && (
                <div className="flex justify-center">
                  <SyncPanel />
                </div>
              )}
            </div>
            <SidebarMenu>
              {mainItems.map((item) => (
                <SidebarMenuItem key={item.title}>
                  <SidebarMenuButton asChild>
                    <NavLink
                      to={item.url}
                      end={item.url === "/"}
                      className="hover:bg-muted/50"
                      activeClassName="bg-muted text-primary font-medium"
                    >
                      <item.icon className="mr-2 h-4 w-4" />
                      {!collapsed && <span>{item.title}</span>}
                    </NavLink>
                  </SidebarMenuButton>
                </SidebarMenuItem>
              ))}
            </SidebarMenu>
          </SidebarGroupContent>
        </SidebarGroup>

        <SidebarGroup>
          <SidebarGroupLabel>
            {!collapsed && <span className="font-bold">Accounting</span>}
          </SidebarGroupLabel>
          <SidebarGroupContent>
            <SidebarMenu>
              {accountingItems.map((item) => (
                <SidebarMenuItem key={item.title}>
                  <SidebarMenuButton asChild>
                    <NavLink
                      to={item.url}
                      className="hover:bg-muted/50"
                      activeClassName="bg-muted text-primary font-medium"
                    >
                      <item.icon className="mr-2 h-4 w-4" />
                      {!collapsed && <span>{item.title}</span>}
                    </NavLink>
                  </SidebarMenuButton>
                </SidebarMenuItem>
              ))}
            </SidebarMenu>
          </SidebarGroupContent>
        </SidebarGroup>

        {/* Spacer + Cash Control (isolated notebook module) */}
        <div className="h-4" aria-hidden />
        <SidebarGroup>
          <SidebarGroupLabel>
            {!collapsed && <span className="font-bold">Cash Control</span>}
          </SidebarGroupLabel>
          <SidebarGroupContent>
            <SidebarMenu>
              {cashControlItems.map((item) => (
                <SidebarMenuItem key={item.title}>
                  <SidebarMenuButton asChild>
                    <NavLink
                      to={item.url}
                      end={item.url === "/cash-control"}
                      className="hover:bg-muted/50"
                      activeClassName="bg-muted text-primary font-medium"
                    >
                      <item.icon className="mr-2 h-4 w-4" />
                      {!collapsed && <span>{item.title}</span>}
                    </NavLink>
                  </SidebarMenuButton>
                </SidebarMenuItem>
              ))}
            </SidebarMenu>
          </SidebarGroupContent>
        </SidebarGroup>

        {/* Spacer + Database Backup (admin tooling) */}
        <div className="h-4" aria-hidden />
        <SidebarGroup>
          <SidebarGroupLabel>
            {!collapsed && <span className="font-bold">Database Backup</span>}
          </SidebarGroupLabel>
          <SidebarGroupContent>
            <SidebarMenu>
              {databaseBackupItems.map((item) => (
                <SidebarMenuItem key={item.title}>
                  <SidebarMenuButton asChild>
                    <NavLink
                      to={item.url}
                      className="hover:bg-muted/50"
                      activeClassName="bg-muted text-primary font-medium"
                    >
                      <item.icon className="mr-2 h-4 w-4" />
                      {!collapsed && <span>{item.title}</span>}
                    </NavLink>
                  </SidebarMenuButton>
                </SidebarMenuItem>
              ))}
            </SidebarMenu>
          </SidebarGroupContent>
        </SidebarGroup>

        {isAdmin && (
          <>
            <div className="h-4" aria-hidden />
            <SidebarGroup>
              <SidebarGroupLabel>
                {!collapsed && <span className="font-bold">Administration</span>}
              </SidebarGroupLabel>
              <SidebarGroupContent>
                <SidebarMenu>
                  <SidebarMenuItem>
                    <SidebarMenuButton asChild>
                      <NavLink to="/settings" className="hover:bg-muted/50" activeClassName="bg-muted text-primary font-medium">
                        <SettingsIcon className="mr-2 h-4 w-4" />
                        {!collapsed && <span>Settings</span>}
                      </NavLink>
                    </SidebarMenuButton>
                  </SidebarMenuItem>
                </SidebarMenu>
              </SidebarGroupContent>
            </SidebarGroup>
          </>
        )}

      </SidebarContent>
      <SidebarFooter>
        <Button variant="ghost" size="sm" className="w-full justify-start" onClick={signOut}>
          <LogOut className="mr-2 h-4 w-4" />
          {!collapsed && "Sign Out"}
        </Button>
      </SidebarFooter>
    </Sidebar>
  );
}
