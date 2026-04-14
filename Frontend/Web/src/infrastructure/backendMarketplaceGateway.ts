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
} from "../domain/models";
import { HttpError, deleteJson, getJson, postForm, postJson, putForm } from "./api/httpClient";
import type {
  AuditLogDto,
  DashboardDto,
  LoginResponseDto,
  PagedResult,
  ProductDto,
  ProductManagementDto,
  RegisterResponseDto,
  EnumItemDto
} from "./apiTypes";

const toRole = (role: string): "admin" | "seller" => (role.toLowerCase() === "admin" ? "admin" : "seller");

const fallbackCategories: EnumItemDto[] = [
  { value: 1, name: "Gold" },
  { value: 2, name: "Silver" },
  { value: 3, name: "Diamond" },
  { value: 4, name: "Jewelry" },
  { value: 5, name: "Coins" },
  { value: 6, name: "SpotMr" }
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

const mapReports = (dashboard: DashboardDto, logs: AuditLogDto[]): ReportMetric[] => [
  { title: "Wallet Balance", value: `${dashboard.walletBalance.toFixed(2)} JOD`, trend: "Live from dashboard" },
  { title: "Cart Items", value: `${dashboard.cartItemsCount}`, trend: "Per user" },
  { title: "Unread Notifications", value: `${dashboard.unreadNotifications}`, trend: "Action required" },
  { title: "Audit Logs", value: `${logs.length}`, trend: "Latest events" }
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
    type: "withdrawal",
    amount: 150 + index * 35,
    status: "pending",
    createdAt: log.createdAtUtc
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
    phoneNumber: null,
    dateOfBirth: null,
    nationality: "Jordan",
    documentType: "NationalId",
    idNumber: registration.idNumber,
    profilePhotoUrl: "",
    preferredLanguage: "en",
    preferredTheme: "light",
    role: "Seller",
    sellerId: 0
  };

  const data = await postJson<RegisterResponseDto, typeof request>("/api/auth/register", request);

  return {
    id: `s-${data.sellerId || data.userId}`,
    userId: data.userId,
    name: data.fullName,
    email: data.email,
    businessName: registration.businessName,
    kycStatus: "pending",
    submittedAt: new Date().toISOString().split("T")[0]
  };
}

export async function fetchMarketplaceState(session: UserSession): Promise<MarketplaceState> {
  const productsResult = await postJson<PagedResult<ProductDto>, { pageNumber: number; pageSize: number; category: null }>(
    "/api/products/search",
    { pageNumber: 1, pageSize: 50, category: null },
    session.accessToken
  );

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

  const products = productsResult.items.map(mapProduct);
  const sellers: Seller[] = Array.from(
    new Map(
      productsResult.items.map((item) => [
        item.sellerId,
        {
          id: `s-${item.sellerId}`,
          userId: item.sellerId,
          name: item.sellerName,
          email: `${item.sellerName.toLowerCase().replaceAll(" ", ".")}@goldwallet.local`,
          businessName: item.sellerName,
          kycStatus: "approved" as const,
          submittedAt: new Date().toISOString().split("T")[0]
        }
      ])
    ).values()
  );

  return {
    sellers,
    investors: mapInvestors(dashboard),
    requests: mapRequests(logsResult.items),
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
    reports: mapReports(dashboard, logsResult.items),
    currentUserName: dashboard.fullName
  };
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
  try {
    return await getJson<ProductManagementDto[]>("/api/products/management", accessToken);
  } catch (error) {
    if (error instanceof HttpError && error.statusCode === 404) {
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
        category: item.category,
        weightValue: item.weightValue,
        weightUnit: item.weightUnit,
        price: item.price,
        availableStock: item.availableStock,
        isActive: true,
        sellerId: item.sellerId
      }));
    }

    throw error;
  }
}

export async function fetchProductCategories(accessToken: string): Promise<EnumItemDto[]> {
  try {
    return await getJson<EnumItemDto[]>("/api/products/categories", accessToken);
  } catch (error) {
    if (error instanceof HttpError && error.statusCode === 404) {
      return fallbackCategories;
    }

    throw error;
  }
}

export async function fetchWeightUnits(accessToken: string): Promise<EnumItemDto[]> {
  try {
    return await getJson<EnumItemDto[]>("/api/products/weight-units", accessToken);
  } catch (error) {
    if (error instanceof HttpError && error.statusCode === 404) {
      return fallbackWeightUnits;
    }

    throw error;
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
