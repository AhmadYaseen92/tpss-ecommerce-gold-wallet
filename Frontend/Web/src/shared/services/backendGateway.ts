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
import { deleteJson, getJson, postForm, postJson, putForm, putJson } from "./httpClient";
import type {
  AuditLogDto,
  DashboardDto,
  LoginResponseDto,
  PagedResult,
  ProductDto,
  ProductManagementDto,
  MarketPriceConfigDto,
  RegisterResponseDto,
  EnumItemDto,
  WebDashboardDto,
  WebRequestDto,
  WebSellerDto,
  WalletDto
} from "../types/apiTypes";

const toRole = (role: string): "admin" | "seller" => (role.toLowerCase() === "admin" ? "admin" : "seller");

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
  kycStatus: (dto.kycStatus?.toLowerCase() as "pending" | "approved" | "rejected") ?? "pending",
  submittedAt: dto.submittedAt,
  goldPrice: dto.goldPrice ?? null,
  silverPrice: dto.silverPrice ?? null,
  diamondPrice: dto.diamondPrice ?? null
});

const mapProduct = (dto: ProductDto): Product => ({
  id: `p-${dto.id}`,
  sellerId: `s-${dto.sellerId}`,
  name: dto.name,
  category: dto.category,
  unitPrice: dto.price,
  marketPrice: dto.price,
  stock: dto.availableStock,
  updatedAt: new Date().toISOString().split("T")[0]
});

const mapReports = (dashboard: DashboardDto, requestsCount: number): ReportMetric[] => [
  { title: "Wallet Balance", value: `${dashboard.walletBalance.toFixed(2)} JOD`, trend: "Live from dashboard" },
  { title: "Cart Items", value: `${dashboard.cartItemsCount}`, trend: "Per user" },
  { title: "Unread Notifications", value: `${dashboard.unreadNotifications}`, trend: "Action required" },
  { title: "Transactions", value: `${requestsCount}`, trend: "Latest events" }
];

const mapInvestors = (dashboard: DashboardDto): Investor[] => [
  {
    id: `i-${dashboard.userId}`,
    fullName: dashboard.fullName,
    riskLevel: "medium",
    walletBalance: dashboard.walletBalance,
    status: "active"
  }
];

const mapRequests = (logs: AuditLogDto[]): InvestorRequest[] =>
  logs.slice(0, 5).map((log, index) => ({
    id: `r-${log.id}`,
    investorId: `i-${log.userId ?? index + 1}`,
    investorName: `Investor ${index + 1}`,
    type: "withdrawal",
    productName: "Gold",
    category: "Gold",
    quantity: 1,
    unitPrice: 150 + index * 35,
    weight: 1,
    unit: "gram",
    purity: 24,
    amount: 150 + index * 35,
    status: "pending",
    currency: "USD",
    createdAt: log.createdAtUtc
  }));

const mapWebRequests = (items: WebRequestDto[]): InvestorRequest[] =>
  items.map((item) => ({
    id: item.id,
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
    amount: item.amount,
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

const mapNotifications = (logs: AuditLogDto[]): NotificationItem[] =>
  logs.slice(0, 6).map((log) => ({
    id: `n-${log.id}`,
    title: log.action,
    message: log.details || `${log.entityName} updated`,
    severity: "info",
    isRead: false,
    createdAt: log.createdAtUtc
  }));

export async function loginWithBackend(credentials: AuthCredentials): Promise<UserSession> {
  const data = await postJson<LoginResponseDto, AuthCredentials>("/api/auth/login", credentials);
  return mapSession(data);
}

export async function registerSellerWithBackend(registration: SellerRegistration): Promise<Seller> {
  const request = {
    firstName: registration.firstName,
    middleName: registration.middleName,
    lastName: registration.lastName,
    email: registration.email,
    password: registration.password,
    phoneNumber: registration.phoneNumber,
    dateOfBirth: null,
    nationality: registration.country,
    documentType: "NationalId",
    idNumber: registration.nationalIdNumber,
    profilePhotoUrl: "",
    preferredLanguage: "en",
    preferredTheme: "light",
    role: "Seller",
    sellerCode: "",
    country: registration.country,
    city: registration.city,
    street: registration.street,
    buildingNumber: registration.buildingNumber,
    postalCode: registration.postalCode,
    companyName: registration.companyName,
    tradeLicenseNumber: registration.tradeLicenseNumber,
    vatNumber: registration.vatNumber,
    nationalIdNumber: registration.nationalIdNumber,
    bankName: registration.bankName,
    iban: registration.iban,
    accountHolderName: registration.accountHolderName,
    nationalIdFrontPath: registration.nationalIdFrontPath,
    nationalIdBackPath: registration.nationalIdBackPath,
    tradeLicensePath: registration.tradeLicensePath
  };

  const data = await postJson<RegisterResponseDto, typeof request>("/api/auth/register", request);

  return {
    id: `s-${data.sellerId || data.userId || 0}`,
    sellerId: data.sellerId || data.userId || 0,
    name: data.fullName,
    email: data.email,
    businessName: registration.companyName,
    kycStatus: "pending",
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

export async function updateSellerKycStatusByAdmin(
  accessToken: string,
  sellerId: string,
  status: "approved" | "rejected",
  reviewNotes?: string
): Promise<void> {
  await putJson<string, { status: string; reviewNotes?: string }>(
    `/api/web-admin/sellers/${sellerId}/kyc-status`,
    { status, reviewNotes },
    accessToken
  );
}

export async function fetchMarketplaceState(session: UserSession): Promise<MarketplaceState> {
  const productsResult = await postJson<PagedResult<ProductDto>, { pageNumber: number; pageSize: number; category: null }>(
    "/api/products/search",
    { pageNumber: 1, pageSize: 50, category: null },
    session.accessToken
  );

  const dashboard = session.role === "seller" || !session.userId
    ? null
    : await postJson<DashboardDto, { userId: number }>(
        "/api/dashboard/by-user",
        { userId: session.userId },
        session.accessToken
      );

  const logsResult = session.role === "admin"
    ? await postJson<PagedResult<AuditLogDto>, { pageNumber: number; pageSize: number }>(
        "/api/logs/search",
        { pageNumber: 1, pageSize: 20 },
        session.accessToken
      )
    : { items: [] as AuditLogDto[], totalCount: 0, pageNumber: 1, pageSize: 20 };

  const webRequests = await getJson<WebRequestDto[]>("/api/web-admin/requests", session.accessToken);

  const wallet = session.role === "seller" || !session.userId
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
    investors: dashboard ? mapInvestors(dashboard) : [],
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
    notifications: mapNotifications(logsResult.items),
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
  deliveryFee: number;
  storageFee: number;
  serviceCharge: number;
  offerType: number;
  offerPercent: number;
  offerNewPrice: number;
  price: number;
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

  return searchResult.items.map((item) => ({
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
    baseMarketPrice: item.baseMarketPrice,
    manualSellPrice: item.price,
    deliveryFee: item.deliveryFee,
    storageFee: item.storageFee,
    serviceCharge: item.serviceCharge,
    offerType: item.offerType,
    offerPercent: item.offerPercent,
    offerNewPrice: item.offerNewPrice,
    price: item.price,
    availableStock: item.availableStock,
    isActive: true,
    sellerId: item.sellerId
  }));
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
  form.append("DeliveryFee", String(payload.deliveryFee));
  form.append("StorageFee", String(payload.storageFee));
  form.append("ServiceCharge", String(payload.serviceCharge));
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
