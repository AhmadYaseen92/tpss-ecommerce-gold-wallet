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
  type UserSession
} from "../types/models";
import { deleteJson, getJson, postForm, postJson, putForm, putJson } from "./httpClient";
import type {
  AuditLogDto,
  DashboardDto,
  LoginResponseDto,
  PagedResult,
  ProductDto,
  ProductManagementDto,
  RegisterResponseDto,
  EnumItemDto,
  WebDashboardDto,
  WebRequestDto,
  WebSellerDto
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
  sellerId: dto.sellerId,
  role: toRole(dto.role),
  expiresAtUtc: dto.expiresAtUtc
});

const mapSeller = (dto: WebSellerDto): Seller => ({
  id: dto.id,
  userId: Number(dto.id.replace("s-", "")) || 0,
  name: dto.name,
  email: dto.email,
  businessName: dto.businessName,
  kycStatus: (dto.kycStatus?.toLowerCase() as "pending" | "approved" | "rejected") ?? "pending",
  submittedAt: dto.submittedAt
});

const mapProduct = (dto: ProductDto): Product => ({
  id: `p-${dto.id}`,
  sellerId: `s-${dto.sellerId}`,
  name: dto.name,
  category: dto.category,
  unitPrice: dto.price,
  marketPrice: dto.price,
  stock: dto.availableStock,
  updatedAt: normalizeProductTimestamp(dto.updatedAtUtc ?? dto.createdAtUtc)
});

const normalizeProductTimestamp = (rawTimestamp?: string): string => {
  if (!rawTimestamp) {
    return new Date().toISOString();
  }

  const parsed = new Date(rawTimestamp);
  if (Number.isNaN(parsed.getTime())) {
    return new Date().toISOString();
  }

  return parsed.toISOString();
};

const toTimestampSortValue = (rawTimestamp?: string): number => {
  if (!rawTimestamp) return 0;
  const parsed = new Date(rawTimestamp).getTime();
  return Number.isNaN(parsed) ? 0 : parsed;
};

const mapAndSortProducts = (items: ProductDto[]): Product[] =>
  items
    .slice()
    .sort((a, b) => {
      const left = toTimestampSortValue(a.updatedAtUtc ?? a.createdAtUtc);
      const right = toTimestampSortValue(b.updatedAtUtc ?? b.createdAtUtc);
      return right - left;
    })
    .map(mapProduct);

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
    category: item.category,
    quantity: item.quantity,
    unitPrice: item.unitPrice,
    weight: item.weight,
    unit: item.unit,
    purity: item.purity,
    amount: item.amount,
    status: ["pending", "approved", "rejected"].includes(item.status.toLowerCase())
      ? (item.status.toLowerCase() as InvestorRequest["status"])
      : "pending",
    currency: item.currency,
    notes: item.notes,
    updatedAt: item.updatedAt,
    createdAt: item.createdAt
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
  const data = await postJson<LoginResponseDto, AuthCredentials>("/api/auth/seller-login", credentials);
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
    sellerId: 0,
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
    id: `s-${data.sellerId || data.userId}`,
    userId: data.userId,
    name: data.fullName,
    email: data.email,
    businessName: registration.companyName,
    kycStatus: "pending",
    submittedAt: new Date().toISOString()
  };
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
  const productsResult = await fetchProductsResult(session.accessToken, 50);

  const dashboard = await postJson<DashboardDto, { userId: number }>(
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
  const requests = mapWebRequests(webRequests);

  const products = mapAndSortProducts(productsResult.items);

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
            userId: item.sellerId,
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
    investors: mapInvestors(dashboard),
    requests,
    products,
    invoices: products.slice(0, 5).map((product, index) => ({
      id: `inv-${index + 1}`,
      sellerId: product.sellerId,
      investorName: `Investor ${index + 1}`,
      totalAmount: product.unitPrice,
      issuedAt: new Date().toISOString().split("T")[0],
      status: index % 2 === 0 ? "sent" : "paid"
    })),
    fees: {
      deliveryFee: 12,
      storageFee: 4,
      serviceChargePercent: 2.5
    },
    notifications: mapNotifications(logsResult.items),
    reports: mapReports(dashboard, requests.length),
    currentUserName: dashboard.fullName
  };
}

async function fetchProductsResult(accessToken: string, pageSize: number): Promise<PagedResult<ProductDto>> {
  return postJson<PagedResult<ProductDto>, { pageNumber: number; pageSize: number; category: null }>(
    "/api/products/search",
    { pageNumber: 1, pageSize, category: null },
    accessToken
  );
}

export async function fetchMarketplaceProducts(accessToken: string): Promise<Product[]> {
  const productsResult = await fetchProductsResult(accessToken, 100);
  return mapAndSortProducts(productsResult.items);
}

export async function fetchMarketplaceRequests(accessToken: string): Promise<InvestorRequest[]> {
  const webRequests = await getJson<WebRequestDto[]>("/api/web-admin/requests", accessToken);
  return mapWebRequests(webRequests);
}

export async function fetchMarketplaceSellers(accessToken: string): Promise<Seller[]> {
  return fetchSellers(accessToken);
}

export async function fetchWebAdminDashboard(accessToken: string, period: "today" | "week" | "month"): Promise<WebDashboardDto> {
  return getJson<WebDashboardDto>(`/api/web-admin/dashboard?period=${period}`, accessToken);
}

export async function updateWebRequestStatus(
  accessToken: string,
  requestId: string,
  status: "pending" | "approved" | "rejected"
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
  category: number;
  weightValue: number;
  weightUnit: number;
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

  return searchResult.items
    .map((item) => ({
    id: item.id,
    name: item.name,
    sku: item.sku,
    description: item.description,
    imageUrl: item.imageUrl,
    category: item.category,
    weightValue: item.weightValue,
    weightUnit: item.weightUnit,
    price: item.price,
    availableStock: item.availableStock,
    isActive: true,
    sellerId: item.sellerId,
    createdAtUtc: normalizeProductTimestamp(item.createdAtUtc),
    updatedAtUtc: normalizeProductTimestamp(item.updatedAtUtc ?? item.createdAtUtc)
  }))
    .sort((a, b) => {
      const left = toTimestampSortValue(a.updatedAtUtc ?? a.createdAtUtc);
      const right = toTimestampSortValue(b.updatedAtUtc ?? b.createdAtUtc);
      return right - left;
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
  form.append("Category", String(payload.category));
  form.append("WeightValue", String(payload.weightValue));
  form.append("WeightUnit", String(payload.weightUnit));
  form.append("Price", String(payload.price));
  form.append("AvailableStock", String(payload.availableStock));
  form.append("IsActive", String(payload.isActive));
  if (payload.sellerId) form.append("SellerId", String(payload.sellerId));
  if (payload.existingImageUrl) form.append("ExistingImageUrl", payload.existingImageUrl);
  if (payload.imageFile) form.append("Image", payload.imageFile);
  return form;
}
