export type UserRole = "admin" | "seller";
export type KycStatus = "pending" | "approved" | "rejected";

export type NavigationKey =
  | "overview"
  | "investors"
  | "requests"
  | "products"
  | "invoices"
  | "fees"
  | "inventory"
  | "reports"
  | "notifications"
  | "logout";

export interface Seller {
  id: string;
  userId: number;
  name: string;
  code?: string;
  email: string;
  businessName: string;
  contactPhone?: string;
  country?: string;
  city?: string;
  street?: string;
  buildingNumber?: string;
  postalCode?: string;
  kycStatus: KycStatus;
  submittedAt: string;
  reviewNotes?: string;
}

export interface Investor {
  id: string;
  fullName: string;
  riskLevel: "low" | "medium" | "high";
  walletBalance: number;
  status: "active" | "review" | "blocked";
}

export interface InvestorRequest {
  id: string;
  investorId: string;
  type: "withdrawal" | "pickup" | "sell" | "transfer";
  amount: number;
  status: "pending" | "approved" | "rejected";
  createdAt: string;
}

export interface Product {
  id: string;
  sellerId: string;
  name: string;
  category: string;
  unitPrice: number;
  stock: number;
  marketPrice: number;
  updatedAt: string;
}

export interface Invoice {
  id: string;
  sellerId: string;
  investorName: string;
  totalAmount: number;
  issuedAt: string;
  status: "draft" | "sent" | "paid";
}

export interface FeeConfiguration {
  deliveryFee: number;
  storageFee: number;
  serviceChargePercent: number;
}

export interface NotificationItem {
  id: string;
  title: string;
  message: string;
  severity: "info" | "warning" | "critical";
  isRead: boolean;
  createdAt: string;
}

export interface ReportMetric {
  title: string;
  value: string;
  trend: string;
}

export interface UserSession {
  accessToken: string;
  userId: number;
  sellerId: number;
  role: UserRole;
  expiresAtUtc: string;
}

export interface MarketplaceState {
  sellers: Seller[];
  investors: Investor[];
  requests: InvestorRequest[];
  products: Product[];
  invoices: Invoice[];
  fees: FeeConfiguration;
  notifications: NotificationItem[];
  reports: ReportMetric[];
  currentUserName?: string;
}

export interface AuthCredentials {
  email: string;
  password: string;
}

export interface SellerRegistration {
  firstName: string;
  middleName: string;
  lastName: string;
  email: string;
  password: string;
  phoneNumber: string;
  country: string;
  city: string;
  street: string;
  buildingNumber: string;
  postalCode: string;
  companyName: string;
  tradeLicenseNumber: string;
  vatNumber: string;
  nationalIdNumber: string;
  bankName: string;
  iban: string;
  accountHolderName: string;
  nationalIdFrontPath: string;
  nationalIdBackPath: string;
  tradeLicensePath: string;
}
