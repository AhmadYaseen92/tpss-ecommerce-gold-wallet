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
  sellerId: number;
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
  investorName: string;
  type: "withdrawal" | "pickup" | "sell" | "transfer" | "buy" | "gift";
  productName: string;
  productImageUrl?: string;
  category: string;
  quantity: number;
  unitPrice: number;
  weight: number;
  unit: string;
  purity: number;
  amount: number;
  status: "pending" | "approved" | "rejected" | "pending_delivered" | "delivered" | "cancelled";
  currency: string;
  notes?: string;
  updatedAt?: string;
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
  status: "Draft" | "Issued" | "Completed" | "Cancelled";
  paymentStatus: "Pending" | "Paid" | "Failed" | "Cancelled";
  pdfUrl?: string;
}


export interface WalletAssetItem {
  id: number;
  assetType: string;
  category: string;
  sellerId?: number;
  sellerName: string;
  weight: number;
  unit: string;
  purity: number;
  quantity: number;
  averageBuyPrice: number;
  currentMarketPrice: number;
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
  userId: number | null;
  sellerId: number | null;
  role: UserRole;
  expiresAtUtc: string;
  displayName?: string | null;
}

export interface MarketplaceState {
  sellers: Seller[];
  investors: Investor[];
  requests: InvestorRequest[];
  products: Product[];
  walletAssets: WalletAssetItem[];
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
