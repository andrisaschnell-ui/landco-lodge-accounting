import { supabase as supabaseTyped } from "@/integrations/supabase/client";
const supabase: any = supabaseTyped;

export type AccountRow = {
  id: string;
  code: string;
  name: string;
  account_type: string; // asset | liability | equity | revenue | expense
  pgc_class: string | null;
  normal_side: string;  // debit | credit
};

export type LineAgg = {
  account_id: string;
  debit: number;
  credit: number;
};

/**
 * Pull aggregated debits/credits per account for posted journal entries
 * inside [from, to] (inclusive), optionally filtered by property_id.
 */
export async function loadAggregates(opts: {
  from: string;            // YYYY-MM-DD
  to: string;              // YYYY-MM-DD
  propertyId?: string | null;
}): Promise<LineAgg[]> {
  // Step 1: get matching journal_entry ids
  let q = supabase
    .from("journal_entries")
    .select("id")
    .eq("posted", true)
    .gte("entry_date", opts.from)
    .lte("entry_date", opts.to);
  if (opts.propertyId) q = q.eq("property_id", opts.propertyId);
  const { data: entries, error: e1 } = await q;
  if (e1) throw e1;
  const ids = (entries || []).map((e: any) => e.id);
  if (!ids.length) return [];

  // Step 2: pull all lines in chunks (Supabase IN limit safety)
  const chunks: string[][] = [];
  for (let i = 0; i < ids.length; i += 500) chunks.push(ids.slice(i, i + 500));

  const totals = new Map<string, { debit: number; credit: number }>();
  for (const c of chunks) {
    const { data, error } = await supabase
      .from("journal_lines")
      .select("account_id, debit, credit")
      .in("journal_entry_id", c);
    if (error) throw error;
    for (const l of data || []) {
      const t = totals.get(l.account_id) || { debit: 0, credit: 0 };
      t.debit += Number(l.debit || 0);
      t.credit += Number(l.credit || 0);
      totals.set(l.account_id, t);
    }
  }
  return Array.from(totals.entries()).map(([account_id, v]) => ({ account_id, ...v }));
}

export async function loadAccounts(): Promise<AccountRow[]> {
  const { data, error } = await supabase
    .from("accounts")
    .select("id, code, name, account_type, pgc_class, normal_side")
    .order("code");
  if (error) throw error;
  return data || [];
}

/** Signed balance using account's normal side (positive = "natural" direction). */
export function balanceFor(acct: AccountRow, agg?: LineAgg): number {
  if (!agg) return 0;
  if (acct.normal_side === "debit") return agg.debit - agg.credit;
  return agg.credit - agg.debit;
}

export type StatementSection = {
  label: string;
  accounts: { account: AccountRow; balance: number }[];
  total: number;
};

export function buildPL(accounts: AccountRow[], agg: LineAgg[]) {
  const map = new Map(agg.map(a => [a.account_id, a]));
  const revenues: StatementSection = { label: "Revenues", accounts: [], total: 0 };
  const expenses: StatementSection = { label: "Expenses", accounts: [], total: 0 };
  for (const a of accounts) {
    const bal = balanceFor(a, map.get(a.id));
    if (Math.abs(bal) < 0.005) continue;
    if (a.account_type === "revenue") {
      revenues.accounts.push({ account: a, balance: bal });
      revenues.total += bal;
    } else if (a.account_type === "expense") {
      expenses.accounts.push({ account: a, balance: bal });
      expenses.total += bal;
    }
  }
  return { revenues, expenses, netIncome: revenues.total - expenses.total };
}

export function buildBalanceSheet(accounts: AccountRow[], agg: LineAgg[], pl: { netIncome: number }) {
  const map = new Map(agg.map(a => [a.account_id, a]));
  const assets: StatementSection = { label: "Assets", accounts: [], total: 0 };
  const liabilities: StatementSection = { label: "Liabilities", accounts: [], total: 0 };
  const equity: StatementSection = { label: "Equity", accounts: [], total: 0 };
  for (const a of accounts) {
    const bal = balanceFor(a, map.get(a.id));
    if (Math.abs(bal) < 0.005) continue;
    if (a.account_type === "asset") {
      assets.accounts.push({ account: a, balance: bal });
      assets.total += bal;
    } else if (a.account_type === "liability") {
      liabilities.accounts.push({ account: a, balance: bal });
      liabilities.total += bal;
    } else if (a.account_type === "equity") {
      equity.accounts.push({ account: a, balance: bal });
      equity.total += bal;
    }
  }
  // Net income from PL flows into equity
  equity.accounts.push({
    account: { id: "ni", code: "—", name: "Net Income (period)", account_type: "equity", pgc_class: null, normal_side: "credit" },
    balance: pl.netIncome,
  });
  equity.total += pl.netIncome;

  return {
    assets,
    liabilities,
    equity,
    totalLiabEquity: liabilities.total + equity.total,
    diff: assets.total - (liabilities.total + equity.total),
  };
}

/**
 * Indirect cash flow approximation:
 *  Net income (from PL)
 *   - change in current asset accounts (excluding cash)
 *   + change in current liability accounts
 *   = operating cash flow.
 * Movement on cash accounts (PGC 11xx) is reported separately.
 */
export function buildCashFlow(accounts: AccountRow[], agg: LineAgg[], netIncome: number) {
  const map = new Map(agg.map(a => [a.account_id, a]));
  let cashMove = 0;
  let workingCapital = 0;
  const cashLines: { account: AccountRow; balance: number }[] = [];
  const wcLines: { account: AccountRow; balance: number }[] = [];

  for (const a of accounts) {
    const bal = balanceFor(a, map.get(a.id));
    if (Math.abs(bal) < 0.005) continue;
    const isCash = a.code.startsWith("11");
    if (isCash) {
      cashMove += bal;
      cashLines.push({ account: a, balance: bal });
    } else if (a.account_type === "asset") {
      workingCapital -= bal; // increase in non-cash asset uses cash
      wcLines.push({ account: a, balance: -bal });
    } else if (a.account_type === "liability") {
      workingCapital += bal; // increase in liability provides cash
      wcLines.push({ account: a, balance: bal });
    }
  }
  return {
    netIncome,
    workingCapital,
    operatingCash: netIncome + workingCapital,
    cashMove,
    cashLines,
    wcLines,
  };
}

export const fmtMoney = (n: number) =>
  Number(n || 0).toLocaleString(undefined, { minimumFractionDigits: 2, maximumFractionDigits: 2 });

/** Returns first day of month (YYYY-MM-DD) */
export const firstDay = (year: number, month: number) =>
  `${year}-${String(month).padStart(2, "0")}-01`;

/** Returns last day of month (YYYY-MM-DD) */
export const lastDay = (year: number, month: number) => {
  const d = new Date(year, month, 0);
  return `${year}-${String(month).padStart(2, "0")}-${String(d.getDate()).padStart(2, "0")}`;
};
