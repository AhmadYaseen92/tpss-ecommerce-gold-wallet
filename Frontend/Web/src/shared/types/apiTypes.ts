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
}

export interface LoginResponseDto {
  accessToken: string;
  expiresAtUtc: string;
  role: string;
  userId: number;
  sellerId: number;
}

export interface RegisterResponseDto {
  userId: number;
  email: string;
  fullName: string;
  role: string;
  sellerId: number;
}

export interface WebSellerDto {
  id: string;
  name: string;
  email: string;
  businessName: string;
  kycStatus: string;
  submittedAt: string;
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
  weightValue: number;
  weightUnit: string;
  price: number;
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


export interface ProductManagementDto {
  id: number;
  name: string;
  sku: string;
  description: string;
  imageUrl: string;
  category: string;
  weightValue: number;
  weightUnit: string;
  price: number;
  availableStock: number;
  isActive: boolean;
  sellerId: number;
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

export interface WebRecentTransactionDto {
  id: string;
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
  recentTransactions: WebRecentTransactionDto[];
}
