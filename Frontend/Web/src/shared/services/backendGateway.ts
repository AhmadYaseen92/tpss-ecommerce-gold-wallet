import {
  type AuthCredentials,
  type Investor,
  type InvestorRequest,
  type MarketplaceState,
  type NotificationItem,
  type Product,
  type ReportMetric,
  type Seller,
  type SellerRegistration,
  type UserSession,
  type WalletAssetItem
} from "../types/models";
import { HttpError, deleteJson, getJson, postForm, postJson, putForm, putJson } from "./httpClient";
import type {
  DashboardDto,
  LoginResponseDto,
  PagedResult,
  ProductDto,
  ProductManagementDto,
  MarketPriceConfigDto,
  RegisterResponseDto,
  EnumItemDto,
  WebDashboardDto,
  WebInvestorDto,
  WebNotificationDto,
  WebRequestDto,
  WebSellerDetailsDto,
  WebSellerDto,
  WalletDto
} from "../types/apiTypes";

const toRole = (role: string): "Admin" | "Seller" => (role === "Admin" ? "Admin" : "Seller");

const fallbackCategories: EnumItemDto[] = [
  { value: 1, name: "Gold" },
  { value: 2, name: "Silver" },
  { value: 3, name: "Diamond" },
  { value: 4, name: "Jewelry" },
  { value: 5, name: "Coins" }
];

const fallbackWeightUnits: EnumItemDto[] = [
  { value: 1, name: "Gram" },
  { value: 2, name: "Kilogram" },
  { value: 3, name: "Ounce" }
];

let allowWebAdminInvestorsEndpoint = true;

const mapSession = (dto: LoginResponseDto): UserSession => ({
  accessToken: dto.accessToken,
  userId: dto.userId,
  sellerId: dto.sellerId ?? null,
  role: toRole(dto.role),
  expiresAtUtc: dto.expiresAtUtc,
  displayName: dto.fullName ?? dto.sellerName ?? null
});

const mapSeller = (dto: WebSellerDto): Seller => ({
  id: dto.id,
  sellerId: Number(dto.id.replace("s-", "")) || 0,
  name: dto.name,
  email: dto.email,
  businessName: dto.businessName,
  companyCode: dto.companyCode,
  loginEmail: dto.loginEmail,
  contactPhone: dto.contactPhone,
  isActive: dto.isActive,
  kycStatus: (dto.kycStatus?.toLowerCase() as Seller["kycStatus"]) ?? "underreview",
  submittedAt: dto.submittedAt,
  reviewedAt: dto.reviewedAt,
  goldPrice: dto.goldPrice ?? null,
  silverPrice: dto.silverPrice ?? null,
  diamondPrice: dto.diamondPrice ?? null
});

const mapProduct = (dto: ProductDto): Product => ({
  id: `p-${dto.id}`,
  sellerId: `s-${dto.sellerId}`,
  name: dto.name,
  category: dto.category,
  unitPrice: Number(dto.sellPrice ?? dto.finalPrice ?? 0),
  marketPrice: Number(dto.sellPrice ?? dto.finalPrice ?? 0),
  stock: dto.availableStock,
  updatedAt: new Date().toISOString().split("T")[0]
});

const mapReports = (dashboard: DashboardDto, requestsCount: number): ReportMetric[] => [
  { title: "Wallet Balance", value: `${dashboard.walletBalance.toFixed(2)} JOD`, trend: "Live from dashboard" },
  { title: "Cart Items", value: `${dashboard.cartItemsCount}`, trend: "Per user" },
  { title: "Unread Notifications", value: `${dashboard.unreadNotifications}`, trend: "Action required" },
  { title: "Transactions", value: `${requestsCount}`, trend: "Latest events" }
];

const mapInvestors = (items: WebInvestorDto[]): Investor[] =>
  items.map((item) => ({
    id: item.id,
    fullName: item.fullName,
    email: item.email,
    phoneNumber: item.phoneNumber,
    totalTransactions: item.totalTransactions,
    createdAt: item.createdAt,
    riskLevel: "medium",
    walletBalance: item.walletBalance,
    status: item.status === "blocked" ? "blocked" : "active"
  }));

const mapWebRequests = (items: WebRequestDto[]): InvestorRequest[] =>
  items.map((item) => ({
    id: item.id,
    sellerId: item.sellerId,
    sellerName: item.sellerName,
    investorId: item.investorId,
    investorName: item.investorName,
    type: ["withdrawal", "pickup", "sell", "transfer", "buy", "gift"].includes(item.type.toLowerCase())
      ? (item.type.toLowerCase() as InvestorRequest["type"])
      : "withdrawal",
    productName: item.productName || item.category,
    productImageUrl: item.productImageUrl,
    category: item.category,
    quantity: item.quantity,
    unitPrice: item.unitPrice,
    weight: item.weight,
    unit: item.unit,
    purity: item.purity,
    amount: item.finalAmount ?? item.amount,
    subTotalAmount: item.subTotalAmount ?? item.amount,
    totalFeesAmount: item.totalFeesAmount ?? 0,
    discountAmount: item.discountAmount ?? 0,
    finalAmount: item.finalAmount ?? item.amount,
    feeBreakdowns: item.feeBreakdowns ?? [],
    status: ["pending", "approved", "rejected", "pending_delivered", "delivered", "cancelled", "canceled"].includes(item.status.toLowerCase())
      ? (item.status.toLowerCase() as InvestorRequest["status"])
      : "pending",
    currency: item.currency,
    notes: item.notes,
    updatedAt: item.updatedAt,
    createdAt: item.createdAt
  }));

const mapWalletAssets = (wallet: WalletDto): WalletAssetItem[] =>
  (wallet.assets ?? []).map((item) => ({
    id: item.id,
    assetType: item.assetType,
    category: item.category,
    sellerId: item.sellerId,
    sellerName: item.sellerName,
    weight: item.weight,
    unit: item.unit,
    purity: item.purity,
    quantity: item.quantity,
    averageBuyPrice: item.averageBuyPrice,
    currentMarketPrice: item.currentMarketPrice
  }));

const mapNotifications = (items: WebNotificationDto[]): NotificationItem[] =>
  items.map((item) => ({
    id: item.id,
    title: item.title,
    message: item.message,
    severity: item.severity ?? "info",
    isRead: item.isRead,
    createdAt: item.createdAt
  }));

export async function loginWithBackend(credentials: AuthCredentials): Promise<UserSession> {
  const data = await postJson<LoginResponseDto, AuthCredentials>("/api/auth/login", credentials);
  allowWebAdminInvestorsEndpoint = true;
  return mapSession(data);
}

export async function registerSellerWithBackend(registration: SellerRegistration): Promise<Seller> {
  const request = {
    firstName: registration.firstName,
    middleName: registration.middleName,
    lastName: registration.lastName,
    email: registration.email,
    password: registration.password,
    role: registration.role,
    phoneNumber: registration.manager.mobileNumber || registration.companyInfo.companyPhone,
    dateOfBirth: null,
    nationality: registration.manager.nationality,
    documentType: registration.manager.idType,
    idNumber: registration.manager.idNumber,
    profilePhotoUrl: "",
    preferredLanguage: "en",
    preferredTheme: "light",
    companyInfo: registration.companyInfo,
    manager: registration.manager,
    branches: registration.branches,
    bankAccounts: registration.bankAccounts,
    documents: registration.documents
  };

  const data = await postJson<RegisterResponseDto, typeof request>("/api/auth/register", request);

  return {
    id: `s-${data.sellerId || data.userId || 0}`,
    sellerId: data.sellerId || data.userId || 0,
    name: data.fullName,
    email: data.email,
    businessName: registration.companyInfo.companyName,
    companyCode: registration.companyInfo.companyCode,
    loginEmail: registration.email,
    contactPhone: registration.companyInfo.companyPhone,
    isActive: false,
    kycStatus: "underreview",
    submittedAt: new Date().toISOString()
  };
}

export interface AdminWorkspaceDto {
  sellersCount: number;
  investorsCount: number;
  productsCount: number;
  requestsCount: number;
  systemSettingsCount: number;
}

export async function fetchAdminWorkspace(accessToken: string): Promise<AdminWorkspaceDto> {
  return getJson<AdminWorkspaceDto>("/api/admin/workspace", accessToken);
}

export interface WalletSellConfigurationDto {
  mode: "locked_30_seconds" | "live_price";
  lockSeconds: number;
}

export async function fetchWalletSellConfiguration(accessToken: string): Promise<WalletSellConfigurationDto> {
  try {
    const raw = await getJson<string>("/api/web-admin/wallet/sell-configuration", accessToken);
    const parsed = JSON.parse(raw) as WalletSellConfigurationDto;
    return { mode: parsed.mode, lockSeconds: parsed.lockSeconds ?? 30 };
  } catch {
    return { mode: "locked_30_seconds", lockSeconds: 30 };
  }
}

export async function updateWalletSellConfiguration(
  accessToken: string,
  payload: WalletSellConfigurationDto
): Promise<WalletSellConfigurationDto> {
  await putJson<string, WalletSellConfigurationDto>("/api/web-admin/wallet/sell-configuration", payload, accessToken);
  return payload;
}

export async function fetchSellers(accessToken: string): Promise<Seller[]> {
  const sellers = await getJson<WebSellerDto[]>("/api/web-admin/sellers", accessToken);
  return sellers.map(mapSeller);
}

export async function fetchSellerDetailsByAdmin(accessToken: string, sellerId: string): Promise<WebSellerDetailsDto> {
  return getJson<WebSellerDetailsDto>(`/api/web-admin/sellers/${sellerId}`, accessToken);
}

export async function updateSellerKycStatusByAdmin(
  accessToken: string,
  sellerId: string,
  status: "approved" | "rejected" | "blocked" | "underreview",
  reviewNotes?: string
): Promise<void> {
  await putJson<string, { status: string; reviewNotes?: string }>(
    `/api/web-admin/sellers/${sellerId}/kyc-status`,
    { status, reviewNotes },
    accessToken
  );
}

export async function updateInvestorStatusByAdmin(
  accessToken: string,
  investorId: string,
  status: "active" | "blocked"
): Promise<void> {
  await putJson<string, { status: string }>(`/api/web-admin/investors/${investorId}/status`, { status }, accessToken);
}

export async function fetchMarketplaceState(session: UserSession): Promise<MarketplaceState> {
  const productsResult = await postJson<PagedResult<ProductDto>, { pageNumber: number; pageSize: number; category: null }>(
    "/api/products/search",
    { pageNumber: 1, pageSize: 50, category: null },
    session.accessToken
  );

  const dashboard = session.role === "Seller" || !session.userId
    ? null
    : await postJson<DashboardDto, { userId: number }>(
        "/api/dashboard/by-user",
        { userId: session.userId },
        session.accessToken
      );

  const notificationsResult = await getJson<WebNotificationDto[]>("/api/web-admin/notifications", session.accessToken)
    .catch(() => [] as WebNotificationDto[]);

  const webRequests = await getJson<WebRequestDto[]>("/api/web-admin/requests", session.accessToken);
  const webInvestors = session.role === "Admin" && allowWebAdminInvestorsEndpoint
    ? await getJson<WebInvestorDto[]>("/api/web-admin/investors", session.accessToken).catch((error) => {
        if (error instanceof HttpError && error.statusCode === 403) {
          allowWebAdminInvestorsEndpoint = false;
          return [] as WebInvestorDto[];
        }
        throw error;
      })
    : [];

  const wallet = session.role === "Seller" || !session.userId
    ? null
    : await postJson<WalletDto, { userId: number }>(
        "/api/wallet/by-user",
        { userId: session.userId },
        session.accessToken
      );
  const requests = mapWebRequests(webRequests);

  const products = productsResult.items.map(mapProduct);

  let sellers: Seller[] = [];
  try {
    sellers = await fetchSellers(session.accessToken);
  } catch {
    sellers = Array.from(
      new Map(
        productsResult.items.map((item) => [
          item.sellerId,
          {
            id: `s-${item.sellerId}`,
            sellerId: item.sellerId,
            name: item.sellerName,
            email: `${item.sellerName.toLowerCase().replace(/\s+/g, ".")}@goldwallet.local`,
            businessName: item.sellerName,
            kycStatus: "approved" as const,
            submittedAt: new Date().toISOString().split("T")[0]
          }
        ])
      ).values()
    );
  }

  return {
    sellers,
    investors: mapInvestors(webInvestors),
    requests,
    products,
    walletAssets: wallet ? mapWalletAssets(wallet) : [],
    invoices: products.slice(0, 5).map((product, index) => ({
      id: `inv-${index + 1}`,
      sellerId: product.sellerId,
      investorName: `Investor ${index + 1}`,
      totalAmount: product.unitPrice,
      issuedAt: new Date().toISOString().split("T")[0],
      status: index % 2 === 0 ? "Issued" : "Completed",
      paymentStatus: index % 2 === 0 ? "Pending" : "Paid",
      pdfUrl: undefined
    })),
    fees: {
      deliveryFee: 12,
      storageFee: 4,
      serviceChargePercent: 2.5
    },
    notifications: mapNotifications(notificationsResult),
    reports: dashboard ? mapReports(dashboard, requests.length) : [],
    currentUserName: session.displayName ?? dashboard?.fullName
  };
}

export async function fetchWebAdminDashboard(accessToken: string, period: "today" | "week" | "month"): Promise<WebDashboardDto> {
  return getJson<WebDashboardDto>(`/api/web-admin/dashboard?period=${period}`, accessToken);
}

export async function updateWebRequestStatus(
  accessToken: string,
  requestId: string,
  status: "pending" | "approved" | "rejected" | "delivered" | "cancelled"
): Promise<void> {
  await putJson<string, { status: string }>(`/api/web-admin/requests/${requestId}/status`, { status }, accessToken);
}

export async function markWebNotificationAsRead(accessToken: string, notificationId: string): Promise<void> {
  await putJson<string, Record<string, never>>(`/api/web-admin/notifications/${notificationId}/read`, {}, accessToken);
}

export async function markAllWebNotificationsAsRead(accessToken: string): Promise<void> {
  await putJson<string, Record<string, never>>("/api/web-admin/notifications/read-all", {}, accessToken);
}

export async function getWebRequestDetails(accessToken: string, requestId: string): Promise<InvestorRequest> {
  const item = await getJson<WebRequestDto>(`/api/web-admin/requests/${requestId}`, accessToken);
  return mapWebRequests([item])[0];
}


export interface ProductFormPayload {
  id?: number;
  name: string;
  sku: string;
  description: string;
  materialType: number;
  formType: number;
  pricingMode: number;
  purityKarat: number;
  purityFactor: number;
  weightValue: number;
  baseMarketPrice: number;
  manualSellPrice: number;
  offerType: number;
  offerPercent: number;
  offerNewPrice: number;
  availableStock: number;
  isActive: boolean;
  sellerId?: number;
  existingImageUrl?: string;
  imageFile?: File | null;
}

export async function fetchManagedProducts(accessToken: string): Promise<ProductManagementDto[]> {
  const searchResult = await postJson<PagedResult<ProductDto>, { pageNumber: number; pageSize: number; category: null }>(
    "/api/products/search",
    { pageNumber: 1, pageSize: 100, category: null },
    accessToken
  );

  return searchResult.items.map((item) => {
    const row = item as ProductDto & { IsActive?: boolean; isActive?: boolean };
    return {
      id: item.id,
      name: item.name,
      sku: item.sku,
      description: item.description,
      imageUrl: item.imageUrl,
      category: item.displayCategoryLabel,
      materialType: item.materialType,
      formType: item.formType,
      displayCategoryLabel: item.displayCategoryLabel,
      pricingMode: item.pricingMode,
      purityKarat: item.purityKarat,
      purityFactor: item.purityFactor,
      weightValue: item.weightValue,
      weightUnit: item.weightUnit,
      baseMarketPrice: Number(item.baseMarketPrice ?? 0),
      autoPrice: Number(item.autoPrice ?? 0),
      fixedPrice: Number(item.fixedPrice ?? item.finalPrice ?? 0),
      sellPrice: Number(item.sellPrice ?? item.finalPrice ?? 0),
      offerType: item.offerType,
      isHasOffer: Boolean(item.isHasOffer),
      offerPercent: Number(item.offerPercent ?? 0),
      offerNewPrice: Number(item.offerNewPrice ?? 0),
      availableStock: item.availableStock,
      isActive: Boolean(row.isActive ?? row.IsActive ?? false),
      sellerId: item.sellerId,
      sellerName: item.sellerName
    };
  });
}

export async function fetchProductCategories(accessToken: string): Promise<EnumItemDto[]> {
  try {
    const categories = await getJson<EnumItemDto[]>("/api/products/categories", accessToken);
    return categories.filter((item) => item.name.toLowerCase() !== "spotmr" && item.value !== 6);
  } catch {
    return fallbackCategories;
  }
}

export async function fetchWeightUnits(accessToken: string): Promise<EnumItemDto[]> {
  try {
    return await getJson<EnumItemDto[]>("/api/products/weight-units", accessToken);
  } catch {
    return fallbackWeightUnits;
  }
}


export async function fetchGlobalMarketPrices(accessToken: string): Promise<MarketPriceConfigDto> {
  return getJson<MarketPriceConfigDto>("/api/products/market-prices", accessToken);
}

export async function updateGlobalMarketPrices(accessToken: string, payload: MarketPriceConfigDto): Promise<MarketPriceConfigDto> {
  return postJson<MarketPriceConfigDto, MarketPriceConfigDto>("/api/products/market-prices", payload, accessToken);
}

export async function createManagedProduct(accessToken: string, payload: ProductFormPayload): Promise<string> {
  const form = buildProductForm(payload);
  return postForm<string>("/api/products/management", form, accessToken);
}

export async function updateManagedProduct(accessToken: string, id: number, payload: ProductFormPayload): Promise<string> {
  const form = buildProductForm(payload);
  return putForm<string>(`/api/products/management/${id}`, form, accessToken);
}

export async function deleteManagedProduct(accessToken: string, id: number): Promise<string> {
  return deleteJson<string>(`/api/products/management/${id}`, accessToken);
}

function buildProductForm(payload: ProductFormPayload): FormData {
  const form = new FormData();
  form.append("Name", payload.name);
  form.append("Sku", payload.sku);
  form.append("Description", payload.description);
  form.append("MaterialType", String(payload.materialType));
  form.append("FormType", String(payload.formType));
  form.append("PricingMode", String(payload.pricingMode));
  form.append("PurityKarat", String(payload.purityKarat));
  form.append("PurityFactor", String(payload.purityFactor));
  form.append("WeightValue", String(payload.weightValue));
  form.append("WeightUnit", "1");
  form.append("ManualSellPrice", String(payload.manualSellPrice));
  form.append("OfferType", String(payload.offerType));
  form.append("OfferPercent", String(payload.offerPercent));
  form.append("OfferNewPrice", String(payload.offerNewPrice));
  form.append("AvailableStock", String(payload.availableStock));
  form.append("IsActive", String(payload.isActive));
  if (payload.sellerId) form.append("SellerId", String(payload.sellerId));
  if (payload.existingImageUrl) form.append("ExistingImageUrl", payload.existingImageUrl);
  if (payload.imageFile) form.append("Image", payload.imageFile);
  return form;
}

export interface SystemFeeTypePayload {
  feeCode: string;
  name: string;
  description: string;
  isEnabled: boolean;
  appliesToBuy: boolean;
  appliesToSell: boolean;
  appliesToPickup: boolean;
  appliesToTransfer: boolean;
  appliesToGift: boolean;
  appliesToInvoice: boolean;
  appliesToReports: boolean;
  isAdminManaged?: boolean;
  sortOrder: number;
}

export interface AdminServiceFeePayload {
  isEnabled: boolean;
  calculationMode: "percent" | "fixed";
  ratePercent?: number | null;
  fixedAmount?: number | null;
  appliesToBuy: boolean;
  appliesToSell: boolean;
  appliesToPickup: boolean;
  appliesToTransfer: boolean;
  appliesToGift: boolean;
}

export interface SellerProductFeePayload {
  sellerId?: number;
  productId: number;
  feeCode: string;
  isEnabled: boolean;
  calculationMode: string;
  ratePercent?: number | null;
  minimumAmount?: number | null;
  flatAmount?: number | null;
  premiumDiscountType?: string | null;
  valuePerUnit?: number | null;
  feePercent?: number | null;
  gracePeriodDays?: number | null;
  fixedAmount?: number | null;
  feePerUnit?: number | null;
  isOverride: boolean;
}

export async function fetchSystemFeeTypes(accessToken: string): Promise<SystemFeeTypePayload[]> {
  return getJson<SystemFeeTypePayload[]>("/api/fees/system", accessToken);
}

export async function updateSystemFeeType(accessToken: string, payload: SystemFeeTypePayload): Promise<SystemFeeTypePayload> {
  return putJson<SystemFeeTypePayload, SystemFeeTypePayload>("/api/fees/system", payload, accessToken);
}

export async function fetchAdminServiceFee(accessToken: string): Promise<AdminServiceFeePayload> {
  return getJson<AdminServiceFeePayload>("/api/fees/service-fee", accessToken);
}

export async function updateAdminServiceFee(accessToken: string, payload: AdminServiceFeePayload): Promise<AdminServiceFeePayload> {
  return putJson<AdminServiceFeePayload, AdminServiceFeePayload>("/api/fees/service-fee", payload, accessToken);
}

export async function fetchSellerFeeTabs(accessToken: string): Promise<SystemFeeTypePayload[]> {
  return getJson<SystemFeeTypePayload[]>("/api/fees/seller/tabs", accessToken);
}

export async function fetchSellerProductFees(accessToken: string, feeCode: string): Promise<SellerProductFeePayload[]> {
  return getJson<SellerProductFeePayload[]>(`/api/fees/seller/products/${feeCode}`, accessToken);
}

export async function upsertSellerProductFee(accessToken: string, payload: SellerProductFeePayload): Promise<SellerProductFeePayload> {
  return putJson<SellerProductFeePayload, SellerProductFeePayload>("/api/fees/seller/products", payload, accessToken);
}

export async function bulkApplySellerProductFee(
  accessToken: string,
  feeCode: string,
  template: SellerProductFeePayload
): Promise<{ updated: number }> {
  return putJson<{ updated: number }, { feeCode: string; applyToAll: boolean; productIds: number[]; template: SellerProductFeePayload }>(
    "/api/fees/seller/products/bulk",
    { feeCode, applyToAll: true, productIds: [], template },
    accessToken
  );
}
