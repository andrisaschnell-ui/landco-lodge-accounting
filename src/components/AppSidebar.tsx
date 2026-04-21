import {
  LayoutDashboard, ArrowLeftRight, Users, Building2, Briefcase,
  FileSpreadsheet, Upload, LogOut, BarChart3,
  BookOpen, ReceiptText, FileText, Settings2, BarChart, AlertTriangle,
} from "lucide-react";
import { NavLink } from "@/components/NavLink";
import { useLocation } from "react-router-dom";
import {
  Sidebar, SidebarContent, SidebarGroup, SidebarGroupContent,
  SidebarGroupLabel, SidebarMenu, SidebarMenuButton, SidebarMenuItem,
  SidebarFooter, useSidebar,
} from "@/components/ui/sidebar";
import { useAuth } from "@/hooks/useAuth";
import { Button } from "@/components/ui/button";

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
  { title: "Invoices", url: "/accounting/invoices", icon: ReceiptText },
  { title: "Account Mapping", url: "/accounting/mapping", icon: Settings2 },
  { title: "Suspense Review", url: "/accounting/suspense", icon: AlertTriangle },
  { title: "Accounting Reports", url: "/accounting/reports", icon: BarChart },
  { title: "Shareholder Statements", url: "/accounting/shareholders", icon: Users },
];

export function AppSidebar() {
  const { state } = useSidebar();
  const collapsed = state === "collapsed";
  const location = useLocation();
  const { signOut } = useAuth();

  return (
    <Sidebar collapsible="icon">
      <SidebarContent>
        <SidebarGroup>
          <SidebarGroupLabel>
            {!collapsed && <span className="font-bold text-lg">LANACC</span>}
          </SidebarGroupLabel>
          <SidebarGroupContent>
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
