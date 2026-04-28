export type ReportAudience = "Admin" | "Seller";

export interface ReportTypeCard {
  key: string;
  label: string;
  description: string;
  audience: ReportAudience | "Both";
}

export type DatePreset = "today" | "yesterday" | "thisWeek" | "thisMonth" | "custom";

export interface ReportFilters {
  reportType: string;
  datePreset: DatePreset;
  customFrom: string;
  customTo: string;
  sellerId: string;
  investorId: string;
  productId: string;
  materialType: string;
  formType: string;
  requestType: string;
  transactionStatus: string;
  paymentStatus: string;
  walletActionType: string;
  feeType: string;
  invoiceNumber: string;
  orderNumber: string;
  userName: string;
  phone: string;
  email: string;
  sortBy: string;
  sortDir: "asc" | "desc";
  page: number;
  pageSize: number;
}

export interface SummaryCard {
  title: string;
  value: string;
  hint: string;
}

export interface ReportTableData {
  headers: string[];
  rows: Array<Record<string, string | number>>;
  totalsRow: Record<string, string | number>;
}
