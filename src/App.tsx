import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { BrowserRouter, Route, Routes, Navigate } from "react-router-dom";
import { Toaster as Sonner } from "@/components/ui/sonner";
import { Toaster } from "@/components/ui/toaster";
import { TooltipProvider } from "@/components/ui/tooltip";
import { AuthProvider, useAuth } from "@/hooks/useAuth";
import { AppLayout } from "@/components/AppLayout";
import { ErrorBoundary } from "@/components/ErrorBoundary";
import Auth from "./pages/Auth";
import Dashboard from "./pages/Dashboard";
import Transactions from "./pages/Transactions";
import Shareholders from "./pages/Shareholders";
import Employees from "./pages/Employees";
import Payroll from "./pages/Payroll";
import Properties from "./pages/Properties";
import UploadData from "./pages/UploadData";
import Reports from "./pages/Reports";
import ShareholderDetail from "./pages/ShareholderDetail";
import ChartOfAccounts from "./pages/ChartOfAccounts";
import JournalEntries from "./pages/JournalEntries";
import Invoices from "./pages/Invoices";
import AccountMapping from "./pages/AccountMapping";
import FinancialReports from "./pages/FinancialReports";
import ShareholderReports from "./pages/ShareholderReports";
import NotFound from "./pages/NotFound";

const queryClient = new QueryClient();

function ProtectedRoutes() {
  const { user, loading } = useAuth();

  if (loading) {
    return (
      <div className="flex min-h-screen items-center justify-center">
        <p className="text-muted-foreground">Loading...</p>
      </div>
    );
  }

  if (!user) return <Navigate to="/auth" replace />;

  return (
    <ErrorBoundary>
      <AppLayout />
    </ErrorBoundary>
  );
}

function AuthRoute() {
  const { user, loading } = useAuth();
  if (loading) {
    return (
      <div className="flex min-h-screen items-center justify-center">
        <p className="text-muted-foreground">Loading...</p>
      </div>
    );
  }
  if (user) return <Navigate to="/" replace />;
  return <Auth />;
}

const App = () => (
  <QueryClientProvider client={queryClient}>
    <TooltipProvider>
      <Toaster />
      <Sonner />
      <BrowserRouter>
        <AuthProvider>
          <Routes>
            <Route path="/auth" element={<AuthRoute />} />
            <Route element={<ProtectedRoutes />}>
              <Route path="/" element={<Dashboard />} />
              <Route path="/transactions" element={<Transactions />} />
              <Route path="/shareholders" element={<Shareholders />} />
              <Route path="/employees" element={<Employees />} />
              <Route path="/payroll" element={<Payroll />} />
              <Route path="/properties" element={<Properties />} />
              <Route path="/reports" element={<Reports />} />
              <Route path="/shareholders/:id" element={<ShareholderDetail />} />
              <Route path="/upload" element={<UploadData />} />
              <Route path="/accounting/accounts" element={<ChartOfAccounts />} />
              <Route path="/accounting/journal" element={<JournalEntries />} />
              <Route path="/accounting/invoices" element={<Invoices />} />
              <Route path="/accounting/mapping" element={<AccountMapping />} />
              <Route path="/accounting/reports" element={<FinancialReports />} />
              <Route path="/accounting/shareholders" element={<ShareholderReports />} />
            </Route>
            <Route path="*" element={<NotFound />} />
          </Routes>
        </AuthProvider>
      </BrowserRouter>
    </TooltipProvider>
  </QueryClientProvider>
);

export default App;
