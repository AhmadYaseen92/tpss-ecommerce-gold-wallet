export type UserRole = "Admin" | "Seller";
export type KycStatus = "pending" | "underreview" | "approved" | "rejected" | "blocked";

export type NavigationKey =
  | "overview"
  | "admin"
  | "investors"
  | "sellers"
  | "settings"
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
  companyCode?: string;
  loginEmail?: string;
  contactPhone?: string;
  isActive?: boolean;
  reviewedAt?: string;
  country?: string;
  city?: string;
  street?: string;
  buildingNumber?: string;
  postalCode?: string;
  kycStatus: KycStatus;
  submittedAt: string;
  reviewNotes?: string;
  goldPrice?: number | null;
  silverPrice?: number | null;
  diamondPrice?: number | null;
}

export interface Investor {
  id: string;
  fullName: string;
  email?: string;
  phoneNumber?: string;
  totalTransactions?: number;
  createdAt?: string;
  riskLevel: "low" | "medium" | "high";
  walletBalance: number;
  status: "active" | "review" | "blocked";
}

export interface InvestorRequest {
  id: string;
  sellerId?: string;
  sellerName?: string;
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
  subTotalAmount?: number;
  totalFeesAmount?: number;
  discountAmount?: number;
  finalAmount?: number;
  feeBreakdowns?: Array<{
    feeCode: string;
    feeName: string;
    calculationMode: string;
    baseAmount: number;
    quantity: number;
    appliedRate?: number | null;
    appliedValue: number;
    isDiscount: boolean;
    currency: string;
    sourceType: string;
    displayOrder: number;
  }>;
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
  materialType?: string;
  formType?: string;
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
  emailOrPhone: string;
  password: string;
}

export interface SellerRegistration {
  firstName: string;
  middleName: string;
  lastName: string;
  email: string;
  password: string;
  role: "Seller";
  companyInfo: {
    companyName: string;
    companyCode: string;
    commercialRegistrationNumber: string;
    vatNumber: string;
    businessActivity: string;
    establishedDate?: string;
    country: string;
    city: string;
    street: string;
    buildingNumber: string;
    postalCode: string;
    companyPhone: string;
    companyEmail: string;
    website?: string;
    description?: string;
  };
  manager: {
    fullName: string;
    positionTitle: string;
    nationality: string;
    mobileNumber: string;
    emailAddress: string;
    idType: string;
    idNumber: string;
    idExpiryDate?: string;
  };
  branches: Array<{
    branchName: string;
    country: string;
    city: string;
    fullAddress: string;
    buildingNumber: string;
    postalCode: string;
    phoneNumber: string;
    email: string;
    isMainBranch: boolean;
  }>;
  bankAccounts: Array<{
    bankName: string;
    accountHolderName: string;
    accountNumber: string;
    iban: string;
    swiftCode: string;
    bankCountry: string;
    bankCity: string;
    branchName: string;
    branchAddress: string;
    currency: string;
    isMainAccount: boolean;
  }>;
  documents: Array<{
    documentType: string;
    fileName: string;
    filePath: string;
    contentType: string;
    isRequired: boolean;
    relatedEntityType?: string;
  }>;
}
