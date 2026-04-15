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
      bank_accounts: {
        Row: {
          account_number: string | null
          bank_name: string
          created_at: string
          currency: string
          id: string
          name: string
          updated_at: string
        }
        Insert: {
          account_number?: string | null
          bank_name: string
          created_at?: string
          currency?: string
          id?: string
          name: string
          updated_at?: string
        }
        Update: {
          account_number?: string | null
          bank_name?: string
          created_at?: string
          currency?: string
          id?: string
          name?: string
          updated_at?: string
        }
        Relationships: []
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
          created_at: string
          id: string
          is_shared: boolean
          name: string
        }
        Insert: {
          created_at?: string
          id?: string
          is_shared?: boolean
          name: string
        }
        Update: {
          created_at?: string
          id?: string
          is_shared?: boolean
          name?: string
        }
        Relationships: []
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
          month?: number
          property_id?: string | null
          updated_at?: string
          year?: number
        }
        Relationships: [
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
      petty_cash_transactions: {
        Row: {
          balance: number | null
          created_at: string
          credit: number | null
          date: string | null
          debit: number | null
          description: string
          id: string
          month: number
          year: number
        }
        Insert: {
          balance?: number | null
          created_at?: string
          credit?: number | null
          date?: string | null
          debit?: number | null
          description: string
          id?: string
          month: number
          year: number
        }
        Update: {
          balance?: number | null
          created_at?: string
          credit?: number | null
          date?: string | null
          debit?: number | null
          description?: string
          id?: string
          month?: number
          year?: number
        }
        Relationships: []
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
        Relationships: []
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
