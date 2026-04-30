export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export type Database = {
  // Allows to automatically instantiate createClient with right options
  // instead of createClient<Database, { PostgrestVersion: 'XX' }>(URL, KEY)
  __InternalSupabase: {
    PostgrestVersion: "14.5"
  }
  public: {
    Tables: {
      accounting_periods: {
        Row: {
          closed_at: string | null
          closed_by: string | null
          id: string
          is_closed: boolean
          month: number
          year: number
        }
        Insert: {
          closed_at?: string | null
          closed_by?: string | null
          id?: string
          is_closed?: boolean
          month: number
          year: number
        }
        Update: {
          closed_at?: string | null
          closed_by?: string | null
          id?: string
          is_closed?: boolean
          month?: number
          year?: number
        }
        Relationships: []
      }
      accounts: {
        Row: {
          account_class: number
          account_type: string
          code: string
          created_at: string
          id: string
          is_active: boolean
          name: string
          normal_side: string
          parent_code: string | null
          pgc_class: string | null
        }
        Insert: {
          account_class: number
          account_type: string
          code: string
          created_at?: string
          id?: string
          is_active?: boolean
          name: string
          normal_side: string
          parent_code?: string | null
          pgc_class?: string | null
        }
        Update: {
          account_class?: number
          account_type?: string
          code?: string
          created_at?: string
          id?: string
          is_active?: boolean
          name?: string
          normal_side?: string
          parent_code?: string | null
          pgc_class?: string | null
        }
        Relationships: []
      }
      bank_accounts: {
        Row: {
          account_number: string | null
          bank_name: string
          created_at: string
          currency: string
          id: string
          name: string
          pgc_account_code: string | null
          updated_at: string
        }
        Insert: {
          account_number?: string | null
          bank_name: string
          created_at?: string
          currency?: string
          id?: string
          name: string
          pgc_account_code?: string | null
          updated_at?: string
        }
        Update: {
          account_number?: string | null
          bank_name?: string
          created_at?: string
          currency?: string
          id?: string
          name?: string
          pgc_account_code?: string | null
          updated_at?: string
        }
        Relationships: []
      }
      bank_opening_balances: {
        Row: {
          bank_account_id: string
          created_at: string
          id: string
          month: number
          opening_balance: number
          source_file: string | null
          updated_at: string
          year: number
        }
        Insert: {
          bank_account_id: string
          created_at?: string
          id?: string
          month: number
          opening_balance?: number
          source_file?: string | null
          updated_at?: string
          year: number
        }
        Update: {
          bank_account_id?: string
          created_at?: string
          id?: string
          month?: number
          opening_balance?: number
          source_file?: string | null
          updated_at?: string
          year?: number
        }
        Relationships: [
          {
            foreignKeyName: "bank_opening_balances_bank_account_id_fkey"
            columns: ["bank_account_id"]
            isOneToOne: false
            referencedRelation: "bank_accounts"
            referencedColumns: ["id"]
          },
        ]
      }
      bank_transactions: {
        Row: {
          balance: number | null
          bank_account_id: string | null
          created_at: string
          credit: number | null
          date: string | null
          debit: number | null
          description: string
          id: string
          journal_entry_id: string | null
          month: number
          reference: string | null
          year: number
        }
        Insert: {
          balance?: number | null
          bank_account_id?: string | null
          created_at?: string
          credit?: number | null
          date?: string | null
          debit?: number | null
          description: string
          id?: string
          journal_entry_id?: string | null
          month: number
          reference?: string | null
          year: number
        }
        Update: {
          balance?: number | null
          bank_account_id?: string | null
          created_at?: string
          credit?: number | null
          date?: string | null
          debit?: number | null
          description?: string
          id?: string
          journal_entry_id?: string | null
          month?: number
          reference?: string | null
          year?: number
        }
        Relationships: [
          {
            foreignKeyName: "bank_transactions_bank_account_id_fkey"
            columns: ["bank_account_id"]
            isOneToOne: false
            referencedRelation: "bank_accounts"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "bank_transactions_journal_entry_id_fkey"
            columns: ["journal_entry_id"]
            isOneToOne: false
            referencedRelation: "journal_entries"
            referencedColumns: ["id"]
          },
        ]
      }
      bim_salary_transfers: {
        Row: {
          amount: number
          created_at: string
          description: string | null
          employee_id: string | null
          id: string
          month: number
          name: string
          nib: string | null
          salary_run_id: string | null
          year: number
        }
        Insert: {
          amount: number
          created_at?: string
          description?: string | null
          employee_id?: string | null
          id?: string
          month: number
          name: string
          nib?: string | null
          salary_run_id?: string | null
          year: number
        }
        Update: {
          amount?: number
          created_at?: string
          description?: string | null
          employee_id?: string | null
          id?: string
          month?: number
          name?: string
          nib?: string | null
          salary_run_id?: string | null
          year?: number
        }
        Relationships: [
          {
            foreignKeyName: "bim_salary_transfers_employee_id_fkey"
            columns: ["employee_id"]
            isOneToOne: false
            referencedRelation: "employees"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "bim_salary_transfers_salary_run_id_fkey"
            columns: ["salary_run_id"]
            isOneToOne: false
            referencedRelation: "salary_runs"
            referencedColumns: ["id"]
          },
        ]
      }
      cash_allocation_columns: {
        Row: {
          column_name: string
          created_at: string
          id: string
          sheet_type: string
          sort_order: number
        }
        Insert: {
          column_name: string
          created_at?: string
          id?: string
          sheet_type: string
          sort_order?: number
        }
        Update: {
          column_name?: string
          created_at?: string
          id?: string
          sheet_type?: string
          sort_order?: number
        }
        Relationships: []
      }
      cash_dropdown_options: {
        Row: {
          column_key: string
          created_at: string
          id: string
          sheet_type: string
          sort_order: number
          value: string
        }
        Insert: {
          column_key: string
          created_at?: string
          id?: string
          sheet_type: string
          sort_order?: number
          value: string
        }
        Update: {
          column_key?: string
          created_at?: string
          id?: string
          sheet_type?: string
          sort_order?: number
          value?: string
        }
        Relationships: []
      }
      cash_sheets: {
        Row: {
          created_at: string
          id: string
          month: number | null
          opening_balance: number
          opening_description: string | null
          sheet_type: string
          source_file: string | null
          updated_at: string
          year: number
        }
        Insert: {
          created_at?: string
          id?: string
          month?: number | null
          opening_balance?: number
          opening_description?: string | null
          sheet_type: string
          source_file?: string | null
          updated_at?: string
          year: number
        }
        Update: {
          created_at?: string
          id?: string
          month?: number | null
          opening_balance?: number
          opening_description?: string | null
          sheet_type?: string
          source_file?: string | null
          updated_at?: string
          year?: number
        }
        Relationships: []
      }
      cash_transactions: {
        Row: {
          allocation_amount: number | null
          allocation_column: string | null
          allocations: Json
          balance: number | null
          bank_charges: number | null
          cell_no: string | null
          cheque_no: string | null
          company: string | null
          created_at: string
          description: string | null
          entrada: number | null
          funder: string | null
          id: string
          month: number
          receiver: string | null
          row_no: number | null
          saida: number | null
          sheet_id: string | null
          sheet_type: string
          source_file: string | null
          tx_date: string | null
          updated_at: string
          year: number
        }
        Insert: {
          allocation_amount?: number | null
          allocation_column?: string | null
          allocations?: Json
          balance?: number | null
          bank_charges?: number | null
          cell_no?: string | null
          cheque_no?: string | null
          company?: string | null
          created_at?: string
          description?: string | null
          entrada?: number | null
          funder?: string | null
          id?: string
          month: number
          receiver?: string | null
          row_no?: number | null
          saida?: number | null
          sheet_id?: string | null
          sheet_type: string
          source_file?: string | null
          tx_date?: string | null
          updated_at?: string
          year: number
        }
        Update: {
          allocation_amount?: number | null
          allocation_column?: string | null
          allocations?: Json
          balance?: number | null
          bank_charges?: number | null
          cell_no?: string | null
          cheque_no?: string | null
          company?: string | null
          created_at?: string
          description?: string | null
          entrada?: number | null
          funder?: string | null
          id?: string
          month?: number
          receiver?: string | null
          row_no?: number | null
          saida?: number | null
          sheet_id?: string | null
          sheet_type?: string
          source_file?: string | null
          tx_date?: string | null
          updated_at?: string
          year?: number
        }
        Relationships: [
          {
            foreignKeyName: "cash_transactions_sheet_id_fkey"
            columns: ["sheet_id"]
            isOneToOne: false
            referencedRelation: "cash_sheets"
            referencedColumns: ["id"]
          },
        ]
      }
      company_settings: {
        Row: {
          accent_color: string
          address: string | null
          backup_folder_path: string | null
          created_at: string
          currency: string
          default_property_id: string | null
          default_shareholder_id: string | null
          fiscal_year_start_month: number
          id: string
          invoice_series_prefix: string
          logo_url: string | null
          name: string
          nuit: string | null
          primary_color: string
          singleton: boolean
          sync_target_ref: string | null
          updated_at: string
          updated_by: string | null
          vat_rate: number
        }
        Insert: {
          accent_color?: string
          address?: string | null
          backup_folder_path?: string | null
          created_at?: string
          currency?: string
          default_property_id?: string | null
          default_shareholder_id?: string | null
          fiscal_year_start_month?: number
          id?: string
          invoice_series_prefix?: string
          logo_url?: string | null
          name?: string
          nuit?: string | null
          primary_color?: string
          singleton?: boolean
          sync_target_ref?: string | null
          updated_at?: string
          updated_by?: string | null
          vat_rate?: number
        }
        Update: {
          accent_color?: string
          address?: string | null
          backup_folder_path?: string | null
          created_at?: string
          currency?: string
          default_property_id?: string | null
          default_shareholder_id?: string | null
          fiscal_year_start_month?: number
          id?: string
          invoice_series_prefix?: string
          logo_url?: string | null
          name?: string
          nuit?: string | null
          primary_color?: string
          singleton?: boolean
          sync_target_ref?: string | null
          updated_at?: string
          updated_by?: string | null
          vat_rate?: number
        }
        Relationships: []
      }
      employees: {
        Row: {
          base_salary: number
          category: string | null
          created_at: string
          food_allowance: number | null
          house_assignment: string | null
          id: string
          is_active: boolean
          name: string
          nib: string | null
          nuit: string | null
          updated_at: string
        }
        Insert: {
          base_salary?: number
          category?: string | null
          created_at?: string
          food_allowance?: number | null
          house_assignment?: string | null
          id?: string
          is_active?: boolean
          name: string
          nib?: string | null
          nuit?: string | null
          updated_at?: string
        }
        Update: {
          base_salary?: number
          category?: string | null
          created_at?: string
          food_allowance?: number | null
          house_assignment?: string | null
          id?: string
          is_active?: boolean
          name?: string
          nib?: string | null
          nuit?: string | null
          updated_at?: string
        }
        Relationships: []
      }
      exchange_rates: {
        Row: {
          created_at: string
          id: string
          month: number
          mzn_per_usd: number
          mzn_per_zar: number | null
          year: number
        }
        Insert: {
          created_at?: string
          id?: string
          month: number
          mzn_per_usd: number
          mzn_per_zar?: number | null
          year: number
        }
        Update: {
          created_at?: string
          id?: string
          month?: number
          mzn_per_usd?: number
          mzn_per_zar?: number | null
          year?: number
        }
        Relationships: []
      }
      expense_categories: {
        Row: {
          category_type: string | null
          created_at: string
          id: string
          is_shared: boolean
          name: string
          name_en: string | null
          name_pt: string | null
          parent_id: string | null
          pgc_account_code: string | null
        }
        Insert: {
          category_type?: string | null
          created_at?: string
          id?: string
          is_shared?: boolean
          name: string
          name_en?: string | null
          name_pt?: string | null
          parent_id?: string | null
          pgc_account_code?: string | null
        }
        Update: {
          category_type?: string | null
          created_at?: string
          id?: string
          is_shared?: boolean
          name?: string
          name_en?: string | null
          name_pt?: string | null
          parent_id?: string | null
          pgc_account_code?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "expense_categories_parent_id_fkey"
            columns: ["parent_id"]
            isOneToOne: false
            referencedRelation: "expense_categories"
            referencedColumns: ["id"]
          },
        ]
      }
      expense_transactions: {
        Row: {
          amount_mzn: number
          category_id: string | null
          created_at: string
          date: string | null
          description: string
          id: string
          is_shared: boolean
          journal_entry_id: string | null
          month: number
          property_id: string | null
          shareholder_id: string | null
          updated_at: string
          year: number
        }
        Insert: {
          amount_mzn?: number
          category_id?: string | null
          created_at?: string
          date?: string | null
          description: string
          id?: string
          is_shared?: boolean
          journal_entry_id?: string | null
          month: number
          property_id?: string | null
          shareholder_id?: string | null
          updated_at?: string
          year: number
        }
        Update: {
          amount_mzn?: number
          category_id?: string | null
          created_at?: string
          date?: string | null
          description?: string
          id?: string
          is_shared?: boolean
          journal_entry_id?: string | null
          month?: number
          property_id?: string | null
          shareholder_id?: string | null
          updated_at?: string
          year?: number
        }
        Relationships: [
          {
            foreignKeyName: "expense_transactions_category_id_fkey"
            columns: ["category_id"]
            isOneToOne: false
            referencedRelation: "expense_categories"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "expense_transactions_journal_entry_id_fkey"
            columns: ["journal_entry_id"]
            isOneToOne: false
            referencedRelation: "journal_entries"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "expense_transactions_property_id_fkey"
            columns: ["property_id"]
            isOneToOne: false
            referencedRelation: "properties"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "expense_transactions_shareholder_id_fkey"
            columns: ["shareholder_id"]
            isOneToOne: false
            referencedRelation: "shareholders"
            referencedColumns: ["id"]
          },
        ]
      }
      import_log: {
        Row: {
          created_at: string
          error_details: string | null
          file_type: string
          filename: string
          id: string
          imported_by: string | null
          month: number | null
          records_imported: number | null
          status: string
          year: number | null
        }
        Insert: {
          created_at?: string
          error_details?: string | null
          file_type: string
          filename: string
          id?: string
          imported_by?: string | null
          month?: number | null
          records_imported?: number | null
          status?: string
          year?: number | null
        }
        Update: {
          created_at?: string
          error_details?: string | null
          file_type?: string
          filename?: string
          id?: string
          imported_by?: string | null
          month?: number | null
          records_imported?: number | null
          status?: string
          year?: number | null
        }
        Relationships: []
      }
      income_transactions: {
        Row: {
          accommodation_amount_mzn: number
          amount_usd: number | null
          created_at: string
          date: string
          description: string | null
          guest_name: string | null
          id: string
          journal_entry_id: string | null
          month: number
          property_id: string | null
          updated_at: string
          year: number
        }
        Insert: {
          accommodation_amount_mzn?: number
          amount_usd?: number | null
          created_at?: string
          date: string
          description?: string | null
          guest_name?: string | null
          id?: string
          journal_entry_id?: string | null
          month: number
          property_id?: string | null
          updated_at?: string
          year: number
        }
        Update: {
          accommodation_amount_mzn?: number
          amount_usd?: number | null
          created_at?: string
          date?: string
          description?: string | null
          guest_name?: string | null
          id?: string
          journal_entry_id?: string | null
          month?: number
          property_id?: string | null
          updated_at?: string
          year?: number
        }
        Relationships: [
          {
            foreignKeyName: "income_transactions_journal_entry_id_fkey"
            columns: ["journal_entry_id"]
            isOneToOne: false
            referencedRelation: "journal_entries"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "income_transactions_property_id_fkey"
            columns: ["property_id"]
            isOneToOne: false
            referencedRelation: "properties"
            referencedColumns: ["id"]
          },
        ]
      }
      inss_payments: {
        Row: {
          amount: number
          created_at: string
          id: string
          month: number
          payment_date: string | null
          reference: string | null
          year: number
        }
        Insert: {
          amount: number
          created_at?: string
          id?: string
          month: number
          payment_date?: string | null
          reference?: string | null
          year: number
        }
        Update: {
          amount?: number
          created_at?: string
          id?: string
          month?: number
          payment_date?: string | null
          reference?: string | null
          year?: number
        }
        Relationships: []
      }
      invoices: {
        Row: {
          at_hash: string | null
          at_qr_code: string | null
          client_address: string | null
          client_name: string
          client_nuit: string | null
          created_at: string
          currency: string
          due_date: string | null
          exchange_rate: number | null
          id: string
          income_tx_id: string | null
          invoice_date: string
          invoice_number: string
          invoice_series: string
          issued_by: string | null
          journal_entry_id: string | null
          line_items: Json
          property_id: string | null
          status: string
          subtotal_mzn: number
          total_mzn: number
          updated_at: string
          vat_amount_mzn: number
        }
        Insert: {
          at_hash?: string | null
          at_qr_code?: string | null
          client_address?: string | null
          client_name: string
          client_nuit?: string | null
          created_at?: string
          currency?: string
          due_date?: string | null
          exchange_rate?: number | null
          id?: string
          income_tx_id?: string | null
          invoice_date: string
          invoice_number: string
          invoice_series?: string
          issued_by?: string | null
          journal_entry_id?: string | null
          line_items?: Json
          property_id?: string | null
          status?: string
          subtotal_mzn?: number
          total_mzn?: number
          updated_at?: string
          vat_amount_mzn?: number
        }
        Update: {
          at_hash?: string | null
          at_qr_code?: string | null
          client_address?: string | null
          client_name?: string
          client_nuit?: string | null
          created_at?: string
          currency?: string
          due_date?: string | null
          exchange_rate?: number | null
          id?: string
          income_tx_id?: string | null
          invoice_date?: string
          invoice_number?: string
          invoice_series?: string
          issued_by?: string | null
          journal_entry_id?: string | null
          line_items?: Json
          property_id?: string | null
          status?: string
          subtotal_mzn?: number
          total_mzn?: number
          updated_at?: string
          vat_amount_mzn?: number
        }
        Relationships: [
          {
            foreignKeyName: "invoices_journal_entry_id_fkey"
            columns: ["journal_entry_id"]
            isOneToOne: false
            referencedRelation: "journal_entries"
            referencedColumns: ["id"]
          },
        ]
      }
      irps_payments: {
        Row: {
          amount: number
          created_at: string
          id: string
          month: number
          payment_date: string | null
          reference: string | null
          year: number
        }
        Insert: {
          amount: number
          created_at?: string
          id?: string
          month: number
          payment_date?: string | null
          reference?: string | null
          year: number
        }
        Update: {
          amount?: number
          created_at?: string
          id?: string
          month?: number
          payment_date?: string | null
          reference?: string | null
          year?: number
        }
        Relationships: []
      }
      journal_entries: {
        Row: {
          created_at: string
          created_by: string | null
          description: string
          entry_date: string
          entry_type: string
          id: string
          posted: boolean
          posted_at: string | null
          posted_by: string | null
          property_id: string | null
          reference: string | null
        }
        Insert: {
          created_at?: string
          created_by?: string | null
          description: string
          entry_date: string
          entry_type: string
          id?: string
          posted?: boolean
          posted_at?: string | null
          posted_by?: string | null
          property_id?: string | null
          reference?: string | null
        }
        Update: {
          created_at?: string
          created_by?: string | null
          description?: string
          entry_date?: string
          entry_type?: string
          id?: string
          posted?: boolean
          posted_at?: string | null
          posted_by?: string | null
          property_id?: string | null
          reference?: string | null
        }
        Relationships: []
      }
      journal_lines: {
        Row: {
          account_id: string
          credit: number
          debit: number
          id: string
          journal_entry_id: string
          memo: string | null
        }
        Insert: {
          account_id: string
          credit?: number
          debit?: number
          id?: string
          journal_entry_id: string
          memo?: string | null
        }
        Update: {
          account_id?: string
          credit?: number
          debit?: number
          id?: string
          journal_entry_id?: string
          memo?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "journal_lines_account_id_fkey"
            columns: ["account_id"]
            isOneToOne: false
            referencedRelation: "accounts"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "journal_lines_journal_entry_id_fkey"
            columns: ["journal_entry_id"]
            isOneToOne: false
            referencedRelation: "journal_entries"
            referencedColumns: ["id"]
          },
        ]
      }
      petty_cash_transactions: {
        Row: {
          allocation: string | null
          balance: number | null
          created_at: string
          credit: number | null
          date: string | null
          debit: number | null
          description: string
          id: string
          journal_entry_id: string | null
          month: number
          net_amount: number | null
          reference: string | null
          source_file: string | null
          supplier: string | null
          vat_amount: number | null
          year: number
        }
        Insert: {
          allocation?: string | null
          balance?: number | null
          created_at?: string
          credit?: number | null
          date?: string | null
          debit?: number | null
          description: string
          id?: string
          journal_entry_id?: string | null
          month: number
          net_amount?: number | null
          reference?: string | null
          source_file?: string | null
          supplier?: string | null
          vat_amount?: number | null
          year: number
        }
        Update: {
          allocation?: string | null
          balance?: number | null
          created_at?: string
          credit?: number | null
          date?: string | null
          debit?: number | null
          description?: string
          id?: string
          journal_entry_id?: string | null
          month?: number
          net_amount?: number | null
          reference?: string | null
          source_file?: string | null
          supplier?: string | null
          vat_amount?: number | null
          year?: number
        }
        Relationships: [
          {
            foreignKeyName: "petty_cash_transactions_journal_entry_id_fkey"
            columns: ["journal_entry_id"]
            isOneToOne: false
            referencedRelation: "journal_entries"
            referencedColumns: ["id"]
          },
        ]
      }
      profiles: {
        Row: {
          created_at: string
          display_name: string | null
          email: string | null
          id: string
          updated_at: string
          user_id: string
        }
        Insert: {
          created_at?: string
          display_name?: string | null
          email?: string | null
          id?: string
          updated_at?: string
          user_id: string
        }
        Update: {
          created_at?: string
          display_name?: string | null
          email?: string | null
          id?: string
          updated_at?: string
          user_id?: string
        }
        Relationships: []
      }
      properties: {
        Row: {
          code: string
          created_at: string
          description: string | null
          id: string
          name: string
          updated_at: string
        }
        Insert: {
          code: string
          created_at?: string
          description?: string | null
          id?: string
          name: string
          updated_at?: string
        }
        Update: {
          code?: string
          created_at?: string
          description?: string | null
          id?: string
          name?: string
          updated_at?: string
        }
        Relationships: []
      }
      salary_advances: {
        Row: {
          amount: number
          created_at: string
          date: string
          description: string | null
          employee_id: string
          id: string
          month: number
          year: number
        }
        Insert: {
          amount: number
          created_at?: string
          date: string
          description?: string | null
          employee_id: string
          id?: string
          month: number
          year: number
        }
        Update: {
          amount?: number
          created_at?: string
          date?: string
          description?: string | null
          employee_id?: string
          id?: string
          month?: number
          year?: number
        }
        Relationships: [
          {
            foreignKeyName: "salary_advances_employee_id_fkey"
            columns: ["employee_id"]
            isOneToOne: false
            referencedRelation: "employees"
            referencedColumns: ["id"]
          },
        ]
      }
      salary_lines: {
        Row: {
          advance: number | null
          back_payment: number | null
          base_salary: number | null
          category: string | null
          created_at: string
          days_worked: number | null
          debt: number | null
          employee_id: string
          food_allowance: number | null
          gratification: number | null
          gross_total: number | null
          guardas_25: number | null
          holiday_amount: number | null
          holiday_days: number | null
          id: string
          inss_employee: number | null
          irps: number | null
          monthly_salary: number | null
          net_salary: number | null
          nib: string | null
          nightshift_hours: number | null
          overtime_15x_amount: number | null
          overtime_15x_hours: number | null
          overtime_25_percent: number | null
          overtime_2x_amount: number | null
          overtime_2x_hours: number | null
          salary_run_id: string
          sind: number | null
          total_deductions: number | null
        }
        Insert: {
          advance?: number | null
          back_payment?: number | null
          base_salary?: number | null
          category?: string | null
          created_at?: string
          days_worked?: number | null
          debt?: number | null
          employee_id: string
          food_allowance?: number | null
          gratification?: number | null
          gross_total?: number | null
          guardas_25?: number | null
          holiday_amount?: number | null
          holiday_days?: number | null
          id?: string
          inss_employee?: number | null
          irps?: number | null
          monthly_salary?: number | null
          net_salary?: number | null
          nib?: string | null
          nightshift_hours?: number | null
          overtime_15x_amount?: number | null
          overtime_15x_hours?: number | null
          overtime_25_percent?: number | null
          overtime_2x_amount?: number | null
          overtime_2x_hours?: number | null
          salary_run_id: string
          sind?: number | null
          total_deductions?: number | null
        }
        Update: {
          advance?: number | null
          back_payment?: number | null
          base_salary?: number | null
          category?: string | null
          created_at?: string
          days_worked?: number | null
          debt?: number | null
          employee_id?: string
          food_allowance?: number | null
          gratification?: number | null
          gross_total?: number | null
          guardas_25?: number | null
          holiday_amount?: number | null
          holiday_days?: number | null
          id?: string
          inss_employee?: number | null
          irps?: number | null
          monthly_salary?: number | null
          net_salary?: number | null
          nib?: string | null
          nightshift_hours?: number | null
          overtime_15x_amount?: number | null
          overtime_15x_hours?: number | null
          overtime_25_percent?: number | null
          overtime_2x_amount?: number | null
          overtime_2x_hours?: number | null
          salary_run_id?: string
          sind?: number | null
          total_deductions?: number | null
        }
        Relationships: [
          {
            foreignKeyName: "salary_lines_employee_id_fkey"
            columns: ["employee_id"]
            isOneToOne: false
            referencedRelation: "employees"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "salary_lines_salary_run_id_fkey"
            columns: ["salary_run_id"]
            isOneToOne: false
            referencedRelation: "salary_runs"
            referencedColumns: ["id"]
          },
        ]
      }
      salary_runs: {
        Row: {
          created_at: string
          id: string
          journal_entry_id: string | null
          month: number
          status: string
          total_gross: number | null
          total_inss_employee: number | null
          total_inss_employer: number | null
          total_irps: number | null
          total_net: number | null
          updated_at: string
          year: number
        }
        Insert: {
          created_at?: string
          id?: string
          journal_entry_id?: string | null
          month: number
          status?: string
          total_gross?: number | null
          total_inss_employee?: number | null
          total_inss_employer?: number | null
          total_irps?: number | null
          total_net?: number | null
          updated_at?: string
          year: number
        }
        Update: {
          created_at?: string
          id?: string
          journal_entry_id?: string | null
          month?: number
          status?: string
          total_gross?: number | null
          total_inss_employee?: number | null
          total_inss_employer?: number | null
          total_irps?: number | null
          total_net?: number | null
          updated_at?: string
          year?: number
        }
        Relationships: [
          {
            foreignKeyName: "salary_runs_journal_entry_id_fkey"
            columns: ["journal_entry_id"]
            isOneToOne: false
            referencedRelation: "journal_entries"
            referencedColumns: ["id"]
          },
        ]
      }
      shareholder_balances: {
        Row: {
          closing_balance: number | null
          created_at: string
          expenses: number | null
          id: string
          income: number | null
          month: number
          opening_balance: number | null
          property_id: string
          shareholder_id: string
          updated_at: string
          year: number
        }
        Insert: {
          closing_balance?: number | null
          created_at?: string
          expenses?: number | null
          id?: string
          income?: number | null
          month: number
          opening_balance?: number | null
          property_id: string
          shareholder_id: string
          updated_at?: string
          year: number
        }
        Update: {
          closing_balance?: number | null
          created_at?: string
          expenses?: number | null
          id?: string
          income?: number | null
          month?: number
          opening_balance?: number | null
          property_id?: string
          shareholder_id?: string
          updated_at?: string
          year?: number
        }
        Relationships: [
          {
            foreignKeyName: "shareholder_balances_property_id_fkey"
            columns: ["property_id"]
            isOneToOne: false
            referencedRelation: "properties"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "shareholder_balances_shareholder_id_fkey"
            columns: ["shareholder_id"]
            isOneToOne: false
            referencedRelation: "shareholders"
            referencedColumns: ["id"]
          },
        ]
      }
      shareholders: {
        Row: {
          created_at: string
          email: string | null
          id: string
          name: string
          ownership_percentage: number | null
          property_code: string | null
          updated_at: string
        }
        Insert: {
          created_at?: string
          email?: string | null
          id?: string
          name: string
          ownership_percentage?: number | null
          property_code?: string | null
          updated_at?: string
        }
        Update: {
          created_at?: string
          email?: string | null
          id?: string
          name?: string
          ownership_percentage?: number | null
          property_code?: string | null
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "shareholders_property_code_fkey"
            columns: ["property_code"]
            isOneToOne: false
            referencedRelation: "properties"
            referencedColumns: ["code"]
          },
        ]
      }
      supplier_invoices: {
        Row: {
          allocation: string | null
          amount_excl: number | null
          created_at: string | null
          description: string | null
          id: string
          invoice_date: string | null
          invoice_number: string | null
          journal_entry_id: string | null
          supplier_id: string | null
          total_amount: number | null
          vat_amount: number | null
        }
        Insert: {
          allocation?: string | null
          amount_excl?: number | null
          created_at?: string | null
          description?: string | null
          id?: string
          invoice_date?: string | null
          invoice_number?: string | null
          journal_entry_id?: string | null
          supplier_id?: string | null
          total_amount?: number | null
          vat_amount?: number | null
        }
        Update: {
          allocation?: string | null
          amount_excl?: number | null
          created_at?: string | null
          description?: string | null
          id?: string
          invoice_date?: string | null
          invoice_number?: string | null
          journal_entry_id?: string | null
          supplier_id?: string | null
          total_amount?: number | null
          vat_amount?: number | null
        }
        Relationships: [
          {
            foreignKeyName: "supplier_invoices_journal_entry_id_fkey"
            columns: ["journal_entry_id"]
            isOneToOne: false
            referencedRelation: "journal_entries"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "supplier_invoices_supplier_id_fkey"
            columns: ["supplier_id"]
            isOneToOne: false
            referencedRelation: "suppliers"
            referencedColumns: ["id"]
          },
        ]
      }
      suppliers: {
        Row: {
          created_at: string | null
          id: string
          name: string
        }
        Insert: {
          created_at?: string | null
          id?: string
          name: string
        }
        Update: {
          created_at?: string | null
          id?: string
          name?: string
        }
        Relationships: []
      }
      user_roles: {
        Row: {
          id: string
          role: Database["public"]["Enums"]["app_role"]
          user_id: string
        }
        Insert: {
          id?: string
          role: Database["public"]["Enums"]["app_role"]
          user_id: string
        }
        Update: {
          id?: string
          role?: Database["public"]["Enums"]["app_role"]
          user_id?: string
        }
        Relationships: []
      }
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      has_role: {
        Args: {
          _role: Database["public"]["Enums"]["app_role"]
          _user_id: string
        }
        Returns: boolean
      }
    }
    Enums: {
      app_role: "admin" | "viewer"
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
}

type DatabaseWithoutInternals = Omit<Database, "__InternalSupabase">

type DefaultSchema = DatabaseWithoutInternals[Extract<keyof Database, "public">]

export type Tables<
  DefaultSchemaTableNameOrOptions extends
    | keyof (DefaultSchema["Tables"] & DefaultSchema["Views"])
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
        DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
      DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])[TableName] extends {
      Row: infer R
    }
    ? R
    : never
  : DefaultSchemaTableNameOrOptions extends keyof (DefaultSchema["Tables"] &
        DefaultSchema["Views"])
    ? (DefaultSchema["Tables"] &
        DefaultSchema["Views"])[DefaultSchemaTableNameOrOptions] extends {
        Row: infer R
      }
      ? R
      : never
    : never

export type TablesInsert<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Insert: infer I
    }
    ? I
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Insert: infer I
      }
      ? I
      : never
    : never

export type TablesUpdate<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Update: infer U
    }
    ? U
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Update: infer U
      }
      ? U
      : never
    : never

export type Enums<
  DefaultSchemaEnumNameOrOptions extends
    | keyof DefaultSchema["Enums"]
    | { schema: keyof DatabaseWithoutInternals },
  EnumName extends DefaultSchemaEnumNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"]
    : never = never,
> = DefaultSchemaEnumNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"][EnumName]
  : DefaultSchemaEnumNameOrOptions extends keyof DefaultSchema["Enums"]
    ? DefaultSchema["Enums"][DefaultSchemaEnumNameOrOptions]
    : never

export type CompositeTypes<
  PublicCompositeTypeNameOrOptions extends
    | keyof DefaultSchema["CompositeTypes"]
    | { schema: keyof DatabaseWithoutInternals },
  CompositeTypeName extends PublicCompositeTypeNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"]
    : never = never,
> = PublicCompositeTypeNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"][CompositeTypeName]
  : PublicCompositeTypeNameOrOptions extends keyof DefaultSchema["CompositeTypes"]
    ? DefaultSchema["CompositeTypes"][PublicCompositeTypeNameOrOptions]
    : never

export const Constants = {
  public: {
    Enums: {
      app_role: ["admin", "viewer"],
    },
  },
} as const
