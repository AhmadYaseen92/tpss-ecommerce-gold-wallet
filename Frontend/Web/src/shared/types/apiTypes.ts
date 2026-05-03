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
  marketType?: string;
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
  loginPhone: string;
  isActive: boolean;
  kycStatus: string;
  reviewNotes?: string;
  submittedAt: string;
  reviewedAt?: string;
  goldPrice?: number | null;
  silverPrice?: number | null;
  diamondPrice?: number | null;
  marketType?: string;
  address?: WebSellerAddressDto;
  managers: WebSellerManagerDto[];
  branches: WebSellerBranchDto[];
  bankAccounts: WebSellerBankAccountDto[];
  documents: WebSellerDocumentDto[];
}

export interface MarketTypeSettingsDto {
  marketType: string;
  currency: string;
  feesPercent: number;
  vatRatePercent: number;
  usdToLocalRate: number;
  paymentGateway: string;
  enableSellerManagerField: boolean;
  enableSellerBranchesField: boolean;
  enableSellerBankAccountsField: boolean;
  enableSellerCompanyInfoField: boolean;
  enableSellerLoginCredentialsField: boolean;
  enableCompanyNameField: boolean;
  enableCompanyCrNumberField: boolean;
  enableCompanyVatNumberField: boolean;
  enableCompanyBusinessActivityField: boolean;
  enableManagerNameField: boolean;
  enableManagerMobileField: boolean;
  enableManagerEmailField: boolean;
  enableBranchNameField: boolean;
  enableBranchAddressField: boolean;
  enableBranchPhoneField: boolean;
  enableBankNameField: boolean;
  enableBankAccountNumberField: boolean;
  enableBankIbanField: boolean;
  enableLoginEmailField: boolean;
  enableLoginPhoneField: boolean;
  enablePasswordField: boolean;
  sellersCount: number;
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
  videoUrl: string;
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
  autoPrice: number;
  fixedPrice: number;
  askPrice: number;
  currencyCode?: string;
  offerPercent: number;
  offerNewPrice: number;
  offerType: string;
  isHasOffer: boolean;
  isActive?: boolean;
  availableStock: number;
  sellerId: number;
  sellerName: string;
  finalPrice?: number;
  baseMarketPriceLocal?: number;
  askPriceLocal?: number;
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
  status: string;
  currency: string;
  notes: string;
  updatedAt?: string;
  createdAt: string;
}

export interface WebInvoiceDto {
  id: string;
  sellerId: string;
  investorName: string;
  totalAmount: number;
  issuedAt: string;
  status: "Draft" | "Issued" | "Completed" | "Cancelled";
  paymentStatus: "Pending" | "Paid" | "Failed" | "Cancelled";
  pdfUrl?: string;
  commissionFee?: number;
  deliveryFee?: number;
  serviceFee?: number;
  storageFee?: number;
  premiumDiscount?: number;
  subTotal?: number;
  feesAmount?: number;
  discountAmount?: number;
  taxAmount?: number;
}

export interface WebFeesDto {
  deliveryFee: number;
  storageFee: number;
  serviceChargePercent: number;
}

export interface WebFeeBreakdownReportRowDto {
  sellerId: string;
  sellerName: string;
  feeCode: string;
  feeName: string;
  calculationMode: string;
  appliedRate?: number | null;
  transactionsCount: number;
  collectedAmount: number;
  currency: string;
  transactionTypes: string;
  latestTransactionAt?: string | null;
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

export interface WebLinkedBankAccountDto {
  bankName: string;
  accountHolderName: string;
  accountNumber: string;
  ibanMasked: string;
  swiftCode: string;
  branchName: string;
  branchAddress: string;
  country: string;
  city: string;
  currency: string;
  isVerified: boolean;
  isDefault: boolean;
}

export interface WebPaymentMethodDto {
  type: string;
  maskedNumber: string;
  isDefault: boolean;
}

export interface WebInvestorProfileDto {
  id: string;
  fullName: string;
  email: string;
  phoneNumber: string;
  walletBalance: number;
  totalTransactions: number;
  createdAt: string;
  updatedAt?: string | null;
  status: string;
  dateOfBirth?: string | null;
  nationality: string;
  documentType: string;
  idNumber: string;
  profilePhotoUrl: string;
  preferredLanguage: string;
  preferredTheme: string;
  bankAccounts: WebLinkedBankAccountDto[];
  paymentMethods: WebPaymentMethodDto[];
}

export interface WebUserCredentialsDto {
  userId: string;
  loginEmail: string;
  loginPhone: string;
  updatedAt?: string | null;
}


export interface ProductManagementDto {
 id: number;
  name: string;
  sku: string;
  description: string;
  imageUrl: string;
  videoUrl: string;
  category: string;
  materialType: string;
  formType: string;
  pricingMode: string;
  purityKarat: string;
  purityFactor: number;
  weightValue: number;
  weightUnit: string;
  baseMarketPrice: number;

  autoPrice: number;
  fixedPrice: number;
  askPrice: number;
  currencyCode?: string;

  offerPercent: number;
  offerNewPrice: number;
  offerType: string;
  isHasOffer: boolean;
  isActive : boolean;

  availableStock: number;
  sellerId: number;
  sellerName: string;
  displayCategoryLabel: string;
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
  goldBidPerOunce: number;
  goldAskPerOunce: number;
  silverBidPerOunce: number;
  silverAskPerOunce: number;
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
