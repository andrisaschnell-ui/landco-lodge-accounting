// Bilingual (English + Portuguese) help content for the app.
// Edit copy here — all sidebar tooltips and page headers read from this file.

export type HelpEntry = {
  title: { en: string; pt: string };
  purpose: { en: string; pt: string };
  howTo: { en: string[]; pt: string[] };
  tips?: { en: string[]; pt: string[] };
};

export const helpContent: Record<string, HelpEntry> = {
  "/transactions": {
    title: { en: "Transactions", pt: "Transacções" },
    purpose: {
      en: "Browse, filter and edit every income and expense recorded in the system.",
      pt: "Consultar, filtrar e editar todas as receitas e despesas registadas no sistema.",
    },
    howTo: {
      en: [
        "Use the date / property / type filters at the top.",
        "Click a row to edit; changes auto-post to the journal.",
        "Use 'Add' to record a new transaction manually.",
      ],
      pt: [
        "Use os filtros de data / propriedade / tipo no topo.",
        "Clique numa linha para editar; alterações são lançadas automaticamente no diário.",
        "Use 'Adicionar' para registar manualmente uma nova transacção.",
      ],
    },
    tips: {
      en: ["Closed accounting periods reject any edit.", "Unmapped accounts post to suspense 2999."],
      pt: ["Períodos contabilísticos fechados rejeitam edições.", "Contas não mapeadas vão para a conta suspensa 2999."],
    },
  },
  "/shareholders": {
    title: { en: "Shareholders", pt: "Accionistas" },
    purpose: {
      en: "Maintain the list of shareholders and their ownership percentages per property.",
      pt: "Manter a lista de accionistas e respectivas percentagens de propriedade por imóvel.",
    },
    howTo: {
      en: ["Click a shareholder for full statement.", "Edit ownership % from the property page."],
      pt: ["Clique num accionista para ver extracto completo.", "Edite a % de propriedade na página do imóvel."],
    },
  },
  "/employees": {
    title: { en: "Employees", pt: "Funcionários" },
    purpose: {
      en: "Manage employee records, contracts, salaries and bank details used by Payroll.",
      pt: "Gerir registos de funcionários, contratos, salários e dados bancários usados pelo Processamento Salarial.",
    },
    howTo: {
      en: ["Add or edit an employee; INSS and IRPS fields drive payroll calculations.", "Mark inactive employees rather than deleting them."],
      pt: ["Adicione ou edite um funcionário; os campos INSS e IRPS controlam o processamento.", "Marque funcionários como inactivos em vez de os apagar."],
    },
  },
  "/payroll": {
    title: { en: "Payroll", pt: "Processamento Salarial" },
    purpose: {
      en: "Run monthly payroll: gross, INSS, IRPS, net and bank file generation.",
      pt: "Processar salários mensais: bruto, INSS, IRPS, líquido e geração de ficheiro bancário.",
    },
    howTo: {
      en: ["Pick the month, review each employee, then 'Post Salary Run'.", "A posted run auto-creates journal entries."],
      pt: ["Escolha o mês, reveja cada funcionário, depois clique 'Lançar Processamento'.", "Um processamento lançado cria automaticamente lançamentos no diário."],
    },
    tips: {
      en: ["You cannot re-post the same month twice — reverse the run first."],
      pt: ["Não é possível lançar o mesmo mês duas vezes — reverta primeiro o processamento."],
    },
  },
  "/properties": {
    title: { en: "Properties", pt: "Propriedades" },
    purpose: {
      en: "Houses owned/managed by the company. Used to attribute income and expenses.",
      pt: "Imóveis detidos/geridos pela empresa. Usado para atribuir receitas e despesas.",
    },
    howTo: {
      en: ["Add a property and assign shareholder ownership %."],
      pt: ["Adicione uma propriedade e atribua a % de propriedade aos accionistas."],
    },
  },
  "/upload": {
    title: { en: "Upload Data", pt: "Importar Dados" },
    purpose: {
      en: "Bulk-import Excel files (BDO bank, BIM transfers, expenses, invoices, salaries, petty cash).",
      pt: "Importação em massa de ficheiros Excel (BDO, transferências BIM, despesas, facturas, salários, caixa).",
    },
    howTo: {
      en: ["Pick the file type, drop the Excel file, review the preview, then confirm.", "Imports are idempotent — re-uploading the same file is safe."],
      pt: ["Escolha o tipo de ficheiro, arraste o Excel, reveja a pré-visualização e confirme.", "As importações são idempotentes — reenviar o mesmo ficheiro é seguro."],
    },
  },
  "/accounting/accounts": {
    title: { en: "Chart of Accounts", pt: "Plano de Contas" },
    purpose: { en: "The list of GL accounts used for double-entry bookkeeping.", pt: "Lista de contas do razão para contabilidade de partidas dobradas." },
    howTo: { en: ["Add new accounts with code + type (asset/liability/equity/income/expense)."], pt: ["Adicione contas com código + tipo (activo/passivo/capital/receita/despesa)."] },
  },
  "/accounting/journal": {
    title: { en: "Journal Entries", pt: "Lançamentos do Diário" },
    purpose: { en: "Every double-entry posting in the system, including auto-posted ones.", pt: "Todos os lançamentos de partidas dobradas, incluindo os automáticos." },
    howTo: {
      en: ["Filter by period or account.", "Use 'New Manual Entry' for adjustments. Debits must equal credits."],
      pt: ["Filtre por período ou conta.", "Use 'Novo Lançamento Manual' para ajustes. Débitos devem igualar créditos."],
    },
    tips: { en: ["Closed periods reject manual entries."], pt: ["Períodos fechados rejeitam lançamentos manuais."] },
  },
  "/accounting/ledger": {
    title: { en: "Account Ledger", pt: "Razão da Conta" },
    purpose: { en: "Read-only view of all postings to a single account, with running balance.", pt: "Vista só-leitura de todos os movimentos de uma conta, com saldo acumulado." },
    howTo: { en: ["Pick an account and a date range."], pt: ["Escolha uma conta e um intervalo de datas."] },
  },
  "/accounting/trial-balance": {
    title: { en: "Trial Balance", pt: "Balancete" },
    purpose: { en: "Sum of debits and credits per account at a chosen date.", pt: "Soma de débitos e créditos por conta numa data escolhida." },
    howTo: { en: ["Pick the as-of date and click Refresh."], pt: ["Escolha a data e clique Actualizar."] },
  },
  "/accounting/invoices": {
    title: { en: "Invoices", pt: "Facturas" },
    purpose: { en: "Issue customer invoices; auto-posts AR + revenue.", pt: "Emitir facturas de clientes; lança automaticamente Clientes + Proveitos." },
    howTo: { en: ["Create invoice → add lines → Save. Mark as paid when received."], pt: ["Crie a factura → adicione linhas → Guarde. Marque como paga quando recebida."] },
  },
  "/accounting/expense-payments": {
    title: { en: "Expense Payments", pt: "Pagamentos de Despesas" },
    purpose: { en: "Record supplier payments; auto-posts cash/bank vs expense.", pt: "Registar pagamentos a fornecedores; lança automaticamente caixa/banco vs despesa." },
    howTo: { en: ["Pick supplier, account, amount, date and source (bank/petty cash)."], pt: ["Escolha o fornecedor, conta, montante, data e origem (banco/caixa)."] },
  },
  "/accounting/mapping": {
    title: { en: "Account Mapping", pt: "Mapeamento de Contas" },
    purpose: { en: "Map source labels (bank narrations, expense categories) to GL accounts so auto-posting works.", pt: "Mapear etiquetas de origem (descritivos bancários, categorias) para contas do razão." },
    howTo: { en: ["Resolve any unmapped row → pick the GL account → Save.", "Unmapped items go to suspense 2999 until mapped."], pt: ["Resolva linhas não mapeadas → escolha a conta → Guarde.", "Itens não mapeados vão para a suspensa 2999."] },
  },
  "/accounting/suspense": {
    title: { en: "Suspense Review", pt: "Revisão da Conta Suspensa" },
    purpose: { en: "List of postings sitting in account 2999 because no mapping was found.", pt: "Lista de lançamentos na conta 2999 por falta de mapeamento." },
    howTo: { en: ["For each row, pick the correct account and apply — the journal is reposted."], pt: ["Para cada linha, escolha a conta correcta e aplique — o lançamento é refeito."] },
  },
  "/accounting/periods": {
    title: { en: "Accounting Periods", pt: "Períodos Contabilísticos" },
    purpose: { en: "Open/close monthly periods. Closed periods reject all writes.", pt: "Abrir/fechar períodos mensais. Períodos fechados rejeitam escritas." },
    howTo: { en: ["Close a period only after reconciling bank, payroll and reviewing suspense."], pt: ["Feche um período só após reconciliar banco, salários e rever a suspensa."] },
    tips: { en: ["Closing is enforced by DB triggers — even admins are blocked."], pt: ["O fecho é forçado por triggers — mesmo administradores são bloqueados."] },
  },
  "/accounting/statements": {
    title: { en: "Financial Statements", pt: "Demonstrações Financeiras" },
    purpose: { en: "P&L, Balance Sheet and Cash Flow for a date range.", pt: "DR, Balanço e Fluxo de Caixa para um intervalo de datas." },
    howTo: { en: ["Pick the period and export to PDF/Excel if needed."], pt: ["Escolha o período e exporte para PDF/Excel se necessário."] },
  },
  "/accounting/budgets": {
    title: { en: "Budgets", pt: "Orçamentos" },
    purpose: { en: "Set monthly budgets per account and track variance vs actuals.", pt: "Definir orçamentos mensais por conta e acompanhar desvios vs realizado." },
    howTo: { en: ["Create a budget for the year → enter amounts per account/month → Save."], pt: ["Crie um orçamento anual → introduza montantes por conta/mês → Guarde."] },
  },
  "/accounting/party-ledgers": {
    title: { en: "Customer / Supplier Ledgers", pt: "Razões de Clientes / Fornecedores" },
    purpose: { en: "Outstanding balances and movements per customer and supplier.", pt: "Saldos em aberto e movimentos por cliente e fornecedor." },
    howTo: { en: ["Pick a party to see all invoices and payments with running balance."], pt: ["Escolha uma entidade para ver facturas e pagamentos com saldo acumulado."] },
  },
  "/accounting/fixed-assets": {
    title: { en: "Fixed Assets", pt: "Imobilizado" },
    purpose: { en: "Register assets and run automatic monthly depreciation.", pt: "Registar bens e correr depreciação mensal automática." },
    howTo: { en: ["Add asset → cost, useful life, method (SL/DB) → Save.", "Run 'Depreciate Month' to post the period charge."], pt: ["Adicione bem → custo, vida útil, método (LR/SD) → Guarde.", "Corra 'Depreciar Mês' para lançar a quota do período."] },
  },
  "/accounting/inventory": {
    title: { en: "Inventory", pt: "Inventário" },
    purpose: { en: "Stock items valued by Weighted Average Cost (WAC).", pt: "Itens em stock valorizados pelo Custo Médio Ponderado (CMP)." },
    howTo: { en: ["Record receipts and issues; WAC is recalculated automatically."], pt: ["Registe entradas e saídas; o CMP é recalculado automaticamente."] },
  },
  "/accounting/bank-reconciliation": {
    title: { en: "Bank Reconciliation", pt: "Reconciliação Bancária" },
    purpose: { en: "Match GL bank-account postings against the bank statement.", pt: "Conciliar lançamentos da conta banco no razão com o extracto bancário." },
    howTo: { en: ["Pick bank + statement date.", "Tick matching items; the difference must reach zero before closing."], pt: ["Escolha banco + data do extracto.", "Marque itens correspondentes; a diferença deve ser zero antes de fechar."] },
  },
  "/accounting/fx-revaluation": {
    title: { en: "FX Revaluation", pt: "Reavaliação Cambial" },
    purpose: { en: "Revalue foreign-currency balances at month-end FX rate.", pt: "Reavaliar saldos em moeda estrangeira à taxa cambial de fim de mês." },
    howTo: { en: ["Enter FX rate(s) for the date → Run revaluation → review the gain/loss posting."], pt: ["Introduza taxa(s) cambiais → Corra a reavaliação → reveja o ganho/perda lançado."] },
  },
  "/accounting/approvals": {
    title: { en: "Approvals", pt: "Aprovações" },
    purpose: { en: "Pending items above the approval threshold (default 50,000 MZN).", pt: "Itens pendentes acima do limite de aprovação (por defeito 50.000 MZN)." },
    howTo: { en: ["Review each item; Approve to release the posting, Reject to cancel."], pt: ["Reveja cada item; Aprovar liberta o lançamento, Rejeitar cancela."] },
    tips: { en: ["Threshold is configured in Settings → Approval threshold."], pt: ["O limite configura-se em Definições → Limite de aprovação."] },
  },
  "/accounting/audit-log": {
    title: { en: "Audit Log", pt: "Registo de Auditoria" },
    purpose: { en: "Read-only history of every change to financial tables and login events.", pt: "Histórico só-leitura de todas as alterações em tabelas financeiras e eventos de login." },
    howTo: { en: ["Filter by user, table or date to investigate a change."], pt: ["Filtre por utilizador, tabela ou data para investigar uma alteração."] },
  },
  "/accounting/reports": {
    title: { en: "Accounting Reports", pt: "Relatórios Contabilísticos" },
    purpose: { en: "Pre-built management reports.", pt: "Relatórios de gestão pré-configurados." },
    howTo: { en: ["Pick a report and a date range, then export."], pt: ["Escolha um relatório e intervalo de datas, depois exporte."] },
  },
  "/accounting/shareholders": {
    title: { en: "Shareholder Statements", pt: "Extractos de Accionistas" },
    purpose: { en: "Per-property statement for a shareholder: income, expenses, salaries, petty cash.", pt: "Extracto por propriedade para um accionista: receitas, despesas, salários, caixa." },
    howTo: { en: ["Pick property + period → Excel/PDF buttons export the report."], pt: ["Escolha propriedade + período → os botões Excel/PDF exportam o relatório."] },
    tips: { en: ["Local mode only — relies on the local API."], pt: ["Apenas modo Local — depende da API local."] },
  },
  "/cash-control": {
    title: { en: "Cash Control (Upload)", pt: "Controlo de Caixa (Importar)" },
    purpose: { en: "Upload the cash-control notebook spreadsheet.", pt: "Importar a folha de cálculo do caderno de controlo de caixa." },
    howTo: { en: ["Drop the Excel file → review the preview → confirm."], pt: ["Arraste o Excel → reveja a pré-visualização → confirme."] },
  },
  "/cash-control/display": {
    title: { en: "Cash Control Display", pt: "Visualização do Controlo de Caixa" },
    purpose: { en: "Browse the imported cash-control notebook entries.", pt: "Consultar as entradas importadas do caderno de caixa." },
    howTo: { en: ["Use the type/date filters to narrow down."], pt: ["Use os filtros de tipo/data para restringir."] },
  },
  "/cash-control/reports": {
    title: { en: "Cash Control Report", pt: "Relatório de Controlo de Caixa" },
    purpose: { en: "Summary report of cash-control activity for a period.", pt: "Relatório resumo da actividade de caixa num período." },
    howTo: { en: ["Pick a period and export."], pt: ["Escolha um período e exporte."] },
  },
  "/database-backup": {
    title: { en: "Database Backup", pt: "Cópia de Segurança" },
    purpose: { en: "Manual cloud backup snapshots and restore.", pt: "Cópias de segurança manuais na nuvem e restauro." },
    howTo: { en: ["Create a snapshot before risky operations."], pt: ["Crie um snapshot antes de operações arriscadas."] },
    tips: { en: ["A daily local backup also runs at 22:00 to E:\\landco_daily_backup."], pt: ["Existe também uma cópia local diária às 22:00 para E:\\landco_daily_backup."] },
  },
  "/settings": {
    title: { en: "Settings", pt: "Definições" },
    purpose: { en: "Company info, approval threshold, user roles, system preferences.", pt: "Dados da empresa, limite de aprovação, papéis de utilizador, preferências." },
    howTo: { en: ["Admin only — edit and Save. Changes apply immediately."], pt: ["Apenas administrador — edite e Guarde. Aplica-se imediatamente."] },
  },
  "/reports": {
    title: { en: "Reports", pt: "Relatórios" },
    purpose: { en: "Operational reports across properties, shareholders and employees.", pt: "Relatórios operacionais por propriedades, accionistas e funcionários." },
    howTo: { en: ["Pick a report from the list."], pt: ["Escolha um relatório da lista."] },
  },
  "/": {
    title: { en: "Dashboard", pt: "Painel" },
    purpose: { en: "At-a-glance KPIs, recent activity and quick links.", pt: "Indicadores resumidos, actividade recente e atalhos." },
    howTo: { en: ["Click any tile to drill down."], pt: ["Clique num cartão para detalhar."] },
  },
};

export function getHelp(route: string): HelpEntry | undefined {
  return helpContent[route];
}
