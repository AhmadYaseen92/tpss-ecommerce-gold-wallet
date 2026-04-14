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
import { postJson } from "./api/httpClient";
import type {
  AuditLogDto,
  DashboardDto,
  LoginResponseDto,
  PagedResult,
  ProductDto,
  RegisterResponseDto
} from "./apiTypes";

const toRole = (role: string): "admin" | "seller" => (role.toLowerCase() === "admin" ? "admin" : "seller");

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
