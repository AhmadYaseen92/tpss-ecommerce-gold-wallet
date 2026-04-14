import type {
  FeeConfiguration,
  Invoice,
  Investor,
  InvestorRequest,
  KycStatus,
  MarketplaceState,
  NotificationItem,
  Product,
  ReportMetric,
  Seller
} from "../../../shared/types/models";

const nowDate = () => new Date().toISOString().split("T")[0];

export function updateSellerKycStatus(sellers: Seller[], sellerId: string, status: KycStatus): Seller[] {
  return sellers.map((seller) => (seller.id === sellerId ? { ...seller, kycStatus: status } : seller));
}

export function updateProductMarketPrice(products: Product[], productId: string, marketPrice: number): Product[] {
  return products.map((product) =>
    product.id === productId ? { ...product, marketPrice, updatedAt: nowDate() } : product
  );
}

export function addSellerProduct(products: Product[], productDraft: Omit<Product, "id" | "updatedAt">): Product[] {
  return [...products, { ...productDraft, id: `p-${Date.now()}`, updatedAt: nowDate() }];
}

export function deleteSellerProduct(products: Product[], productId: string): Product[] {
  return products.filter((product) => product.id !== productId);
}

export function updateSellerProduct(products: Product[], productId: string, payload: Partial<Product>): Product[] {
  return products.map((product) => (product.id === productId ? { ...product, ...payload, updatedAt: nowDate() } : product));
}

export function upsertSeller(sellers: Seller[], seller: Seller): Seller[] {
  const exists = sellers.some((item) => item.id === seller.id);
  return exists ? sellers.map((item) => (item.id === seller.id ? seller : item)) : [seller, ...sellers];
}

export function selectSellerProducts(state: MarketplaceState, sellerId: string): Product[] {
  return state.products.filter((product) => product.sellerId === sellerId);
}

export function upsertInvoice(invoices: Invoice[], invoice: Invoice): Invoice[] {
  const exists = invoices.some((item) => item.id === invoice.id);
  return exists ? invoices.map((item) => (item.id === invoice.id ? invoice : item)) : [invoice, ...invoices];
}

export function deleteInvoice(invoices: Invoice[], invoiceId: string): Invoice[] {
  return invoices.filter((invoice) => invoice.id !== invoiceId);
}

export function updateFeeConfiguration(current: FeeConfiguration, payload: Partial<FeeConfiguration>): FeeConfiguration {
  return { ...current, ...payload };
}

export function setInvestorStatus(investors: Investor[], investorId: string, status: Investor["status"]): Investor[] {
  return investors.map((investor) => (investor.id === investorId ? { ...investor, status } : investor));
}

export function setRequestStatus(
  requests: InvestorRequest[],
  requestId: string,
  status: InvestorRequest["status"]
): InvestorRequest[] {
  return requests.map((request) => (request.id === requestId ? { ...request, status } : request));
}

export function markNotificationAsRead(notifications: NotificationItem[], notificationId: string): NotificationItem[] {
  return notifications.map((item) => (item.id === notificationId ? { ...item, isRead: true } : item));
}

export function buildFallbackAdminMetrics(state: MarketplaceState): ReportMetric[] {
  return [
    { title: "Total Investors", value: `${state.investors.length}`, trend: "Live monitoring" },
    { title: "Pending Requests", value: `${state.requests.filter((req) => req.status === "pending").length}`, trend: "Needs review" },
    { title: "Active Products", value: `${state.products.length}`, trend: "Seller catalog" },
    { title: "Unread Alerts", value: `${state.notifications.filter((item) => !item.isRead).length}`, trend: "Notifications" }
  ];
}
