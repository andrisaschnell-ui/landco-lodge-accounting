# Project Roadmap: Following Up on Lovable

## Overview
This document outlines the transition of the Landco Payroll and Lodge Accounting system from the legacy PHP/MySQL implementation (`lanacc_project`) to the modern React/Supabase architecture (`landco-lodge-accounting`).

## 1. Architectural Understanding
The new project represents a significant modernization of the Landco ecosystem:
- **Frontend Stack**: React 18, TypeScript, Vite.
- **UI Framework**: Tailwind CSS + shadcn/ui (Radix UI primitives).
- **Backend & Persistence**: Supabase (PostgreSQL, Row Level Security, Real-time).
- **Data Management**: TanStack Query (React Query) for efficient caching and synchronization.
- **State Flow**: Fully client-side routing (React Router) with asynchronous background updates.

## 2. Key Objectives for Completion
The goal is to reach parity with the `lanacc` system while leveraging the new stack's benefits (real-time updates, better UX, and modularity).

### A. Payroll Engine Porting & Expansion
- [ ] **Formula Engine**: Port the PHP logic from `payroll_sheet.php` into a dedicated TypeScript service.
- [ ] **Folha de Salários Grid**: Implement an editable data grid (using shadcn/ui Table) that supports the complex calculations and color-coding.
- [ ] **New Columns**:
    - [ ] **CONTA DO BANCO**: Integrated from the Employee database.
    - [ ] **TOTAL PER CASA**: Real-time summary grouping by property house code.
- [ ] **House Filters**: Implement the H1-H4 and LC filters using React State and Supabase queries.

### B. Financial Features & Ledger Replication
- [ ] **Excel Replication**: Re-implement the Excel import/export logic to match the "Folha de salários" example sheet exactly.
- [ ] **Legacy Parity**: Ensure all functionalities from the PHP `lanacc_project` (BDO imports, spreadsheet-style persistence) are fully replicated.
- [ ] **Automated Sync**: Set up Supabase Triggers or Edge Functions to replicate the logic that creates expense transactions automatically.

### C. Exports & Infrastructure
- [ ] **Bank List Export**: Use the `xlsx` library to generate the bank-ready Excel file directly in the browser.
- [ ] **Payslip Generation**: Implement a PDF/Word generator for individual worker payslips.
- [ ] **Supabase Transitions**: Ensure the SQL schema in Supabase matches the `01_schema.sql` requirements from the original project.

## 3. How Antigravity Will Carry Out Development
I will follow the "Modern Web Application Development" standards:
1. **Design First**: Every new component will match the premium aesthetics established by Lovable.
2. **Type Safety**: Use TypeScript interfaces to ensure data consistency between Supabase and React.
3. **Containerized Workflow**: Continue using the Docker setup to keep the environment clean.

---
**Status**: Planning Phase  
**Next Step**: Analysis of existing Supabase tables to plan the migration of Property and Employee data.
