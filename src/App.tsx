import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { BrowserRouter, Route, Routes, Navigate } from "react-router-dom";
import { Toaster as Sonner } from "@/components/ui/sonner";
import { Toaster } from "@/components/ui/toaster";
import { TooltipProvider } from "@/components/ui/tooltip";
import { AuthProvider, useAuth } from "@/hooks/useAuth";
import { CompanySettingsProvider } from "@/hooks/useCompanySettings";
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
import Income from "./pages/Income";
import Invoices from "./pages/Invoices";
import ExpensePayments from "./pages/ExpensePayments";
import AccountMapping from "./pages/AccountMapping";
import FinancialReports from "./pages/FinancialReports";
import ShareholderReports from "./pages/ShareholderReports";
import OwnerMonthlySheets from "./pages/OwnerMonthlySheets";
import SuspenseReview from "./pages/SuspenseReview";
import CashControl from "./pages/CashControl";
import CashControlDisplay from "./pages/CashControlDisplay";
import CashControlReports from "./pages/CashControlReports";
import DatabaseBackup from "./pages/DatabaseBackup";
import Settings from "./pages/Settings";
import TrialBalance from "./pages/TrialBalance";
import AccountLedger from "./pages/AccountLedger";
import AccountingPeriods from "./pages/AccountingPeriods";
import FinancialStatements from "./pages/FinancialStatements";
import Budgets from "./pages/Budgets";
import PartyLedgers from "./pages/PartyLedgers";
import FixedAssets from "./pages/FixedAssets";
import Inventory from "./pages/Inventory";
import BankReconciliation from "./pages/BankReconciliation";
import FxRevaluation from "./pages/FxRevaluation";
import Approvals from "./pages/Approvals";
import AuditLog from "./pages/AuditLog";
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
  <ErrorBoundary>
    <QueryClientProvider client={queryClient}>
      <TooltipProvider>
        <Toaster />
        <Sonner />
        <BrowserRouter>
          <AuthProvider>
            <CompanySettingsProvider>
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
                <Route path="/accounting/income" element={<Income />} />
                <Route path="/accounting/invoices" element={<Invoices />} />
                <Route path="/accounting/mapping" element={<AccountMapping />} />
                <Route path="/accounting/expense-payments" element={<ExpensePayments />} />
                <Route path="/accounting/suspense" element={<SuspenseReview />} />
                <Route path="/accounting/reports" element={<FinancialReports />} />
                <Route path="/accounting/shareholders" element={<ShareholderReports />} />
                <Route path="/accounting/owner-monthly" element={<OwnerMonthlySheets />} />
                <Route path="/accounting/trial-balance" element={<TrialBalance />} />
                <Route path="/accounting/ledger" element={<AccountLedger />} />
                <Route path="/accounting/periods" element={<AccountingPeriods />} />
                <Route path="/accounting/statements" element={<FinancialStatements />} />
                <Route path="/accounting/budgets" element={<Budgets />} />
                <Route path="/accounting/party-ledgers" element={<PartyLedgers />} />
                <Route path="/accounting/fixed-assets" element={<FixedAssets />} />
                <Route path="/accounting/inventory" element={<Inventory />} />
                <Route path="/accounting/bank-reconciliation" element={<BankReconciliation />} />
                <Route path="/accounting/fx-revaluation" element={<FxRevaluation />} />
                <Route path="/accounting/approvals" element={<Approvals />} />
                <Route path="/accounting/audit-log" element={<AuditLog />} />
                <Route path="/cash-control" element={<CashControl />} />
                <Route path="/cash-control/display" element={<CashControlDisplay />} />
                <Route path="/cash-control/display/:type" element={<CashControlDisplay />} />
                <Route path="/cash-control/reports" element={<CashControlReports />} />
                <Route path="/database-backup" element={<DatabaseBackup />} />
                <Route path="/settings" element={<Settings />} />
              </Route>
              <Route path="*" element={<NotFound />} />
            </Routes>
            </CompanySettingsProvider>
          </AuthProvider>
        </BrowserRouter>
      </TooltipProvider>
    </QueryClientProvider>
  </ErrorBoundary>
);

export default App;
