export interface ApiResponse<T> {
  success: boolean;
  statusCode: number;
  message: string;
  errorCode?: string;
  data?: T;
  errors?: string[];
}

export interface PagedResult<T> {
  items: T[];
  totalCount: number;
  pageNumber: number;
  pageSize: number;
  totalPages: number;
}

export interface LoginResponseDto {
  accessToken: string;
  expiresAtUtc: string;
  userId: number;
  fullName: string;
  role: string;
  sellerId: number | null;
  sellerName?: string | null;
}

export interface RegisterResponseDto {
  userId: number;
  email: string;
  fullName: string;
  role: string;
  sellerId: number | null;
}

export interface WebSellerDto {
  id: string;
  name: string;
  email: string;
  businessName: string;
  kycStatus: string;
  companyCode: string;
  loginEmail: string;
  contactPhone: string;
  isActive: boolean;
  submittedAt: string;
  reviewedAt?: string;
  goldPrice?: number | null;
  silverPrice?: number | null;
  diamondPrice?: number | null;
}

export interface WebSellerAddressDto {
  country: string;
  city: string;
  street: string;
  buildingNumber: string;
  postalCode: string;
}

export interface WebSellerManagerDto {
  fullName: string;
  positionTitle: string;
  nationality: string;
  mobileNumber: string;
  emailAddress: string;
  idType: string;
  idNumber: string;
  idExpiryDate?: string;
  isPrimary: boolean;
}

export interface WebSellerBranchDto {
  branchName: string;
  country: string;
  city: string;
  fullAddress: string;
  buildingNumber: string;
  postalCode: string;
  phoneNumber: string;
  email: string;
  isMainBranch: boolean;
}

export interface WebSellerBankAccountDto {
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
}

export interface WebSellerDocumentDto {
  id: number;
  documentType: string;
  fileName: string;
  filePath: string;
  contentType: string;
  isRequired: boolean;
  uploadedAtUtc: string;
  relatedEntityType?: string;
}

export interface WebSellerDetailsDto {
  id: string;
  companyName: string;
  companyCode: string;
  commercialRegistrationNumber: string;
  vatNumber: string;
  businessActivity: string;
  establishedDate?: string;
  companyPhone: string;
  companyEmail: string;
  website?: string;
  description?: string;
  loginEmail: string;
  isActive: boolean;
  kycStatus: string;
  reviewNotes?: string;
  submittedAt: string;
  reviewedAt?: string;
  goldPrice?: number | null;
  silverPrice?: number | null;
  diamondPrice?: number | null;
  address?: WebSellerAddressDto;
  managers: WebSellerManagerDto[];
  branches: WebSellerBranchDto[];
  bankAccounts: WebSellerBankAccountDto[];
  documents: WebSellerDocumentDto[];
}

export interface DashboardDto {
  userId: number;
  fullName: string;
  walletBalance: number;
  cartItemsCount: number;
  unreadNotifications: number;
  monthlySpent: number;
}

export interface ProductDto {
  id: number;
  name: string;
  sku: string;
  description: string;
  imageUrl: string;
  category: string;
  materialType: string;
  formType: string;
  displayCategoryLabel: string;
  pricingMode: string;
  purityKarat: string;
  purityFactor: number;
  weightValue: number;
  weightUnit: string;
  baseMarketPrice: number;
  offerPercent: number;
  offerNewPrice: number;
  offerType: string;
  finalPrice: number;
  isHasOffer: boolean;
  availableStock: number;
  sellerId: number;
  sellerName: string;
}

export interface AuditLogDto {
  id: number;
  userId?: number;
  action: string;
  entityName: string;
  entityId?: number;
  details: string;
  createdAtUtc: string;
}

export interface WebNotificationDto {
  id: string;
  title: string;
  message: string;
  severity: "info" | "warning" | "critical";
  isRead: boolean;
  createdAt: string;
}

export interface WebRequestDto {
  id: string;
  sellerId?: string;
  sellerName?: string;
  investorId: string;
  investorName: string;
  type: string;
  productName: string;
  productImageUrl?: string;
  category: string;
  quantity: number;
  unitPrice: number;
  weight: number;
  unit: string;
  purity: number;
  amount: number;
  status: string;
  currency: string;
  notes: string;
  updatedAt?: string;
  createdAt: string;
}

export interface WebInvestorDto {
  id: string;
  fullName: string;
  email: string;
  phoneNumber: string;
  riskLevel: string;
  walletBalance: number;
  totalTransactions: number;
  createdAt: string;
  status: string;
}


export interface ProductManagementDto {
  id: number;
  name: string;
  sku: string;
  description: string;
  imageUrl: string;
  category: string;
  materialType: string;
  formType: string;
  displayCategoryLabel: string;
  pricingMode: string;
  purityKarat: string;
  purityFactor: number;
  weightValue: number;
  weightUnit: string;
  baseMarketPrice: number;
  manualSellPrice: number;
  offerType: string;
  isHasOffer: boolean;
  offerPercent: number;
  offerNewPrice: number;
  availableStock: number;
  isActive: boolean;
  sellerId: number;
  sellerName?: string;
}

export interface EnumItemDto {
  value: number;
  name: string;
}

export interface WebDashboardCardDto {
  title: string;
  value: string;
  trend: string;
}

export interface WebDashboardSegmentDto {
  key: string;
  label: string;
  value: number;
  percent: number;
}

export interface WebDashboardPointDto {
  label: string;
  value: number;
}

export interface WebRecentTransactionDto {
  id: string;
  sellerName?: string;
  investorName: string;
  productName: string;
  type: string;
  amount: number;
  status: string;
  createdAt: string;
}

export interface WebDashboardDto {
  cards: WebDashboardCardDto[];
  statusSegments: WebDashboardSegmentDto[];
  categorySegments: WebDashboardSegmentDto[];
  categoryTransactionSeries: WebDashboardPointDto[];
  categoryCartSeries: WebDashboardPointDto[];
  recentTransactions: WebRecentTransactionDto[];
}


export interface MarketPriceConfigDto {
  goldPerOunce: number;
  silverPerOunce: number;
  diamondPerCarat: number;
}


export interface WalletAssetDto {
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

export interface WalletDto {
  id: number;
  userId: number;
  cashBalance: number;
  currencyCode: string;
  assets: WalletAssetDto[];
}
