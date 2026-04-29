import { computed, ref, watch } from "vue";
import type { ReturnTypeUseMarketplace } from "../../../shared/app/store/useMarketplace";
import { fetchWebAdminDashboard } from "../../../shared/services/backendGateway";
import type { WebDashboardDto } from "../../../shared/types/apiTypes";
import type { Investor, InvestorRequest, Product } from "../../../shared/types/models";

const STATUS_COLORS: Record<string, string> = {
  pending: "#f59e0b",
  approved: "#10b981",
  rejected: "#ef4444"
};

const CATEGORY_COLORS = ["#f59e0b", "#6366f1", "#14b8a6", "#ec4899", "#84cc16"];
const CATEGORY_NAME_BY_ID: Record<string, string> = {
  "1": "Gold",
  "2": "Silver",
  "3": "Diamond",
  "4": "Jewelry",
  "5": "Coins",
};

const normalizeCategoryLabel = (rawCategory: string) => CATEGORY_NAME_BY_ID[rawCategory] ?? rawCategory;
const isVisibleCategory = (category: string) => category.trim().toLowerCase() !== "spotmr";

export function useDashboard(marketplace: ReturnTypeUseMarketplace) {
  const dashboardPeriod = ref<"month">("month");
  const serverDashboard = ref<WebDashboardDto | null>(null);
  const loadServerDashboard = async () => {
    const accessToken = marketplace.session.value?.accessToken;
    if (!accessToken) {
      serverDashboard.value = null;
      return;
    }

    try {
      serverDashboard.value = await fetchWebAdminDashboard(accessToken, dashboardPeriod.value);
    } catch {
      // Keep fallback computed metrics when dashboard endpoint is temporarily unavailable.
      serverDashboard.value = null;
    }
  };

  const dashboardCards = computed(() => {
    if (serverDashboard.value?.cards?.length) {
      return serverDashboard.value.cards;
    }

    const products = marketplace.state.value.products as Product[];
    const requests = marketplace.state.value.requests as InvestorRequest[];
    const totalTransactions = requests.length;
    const totalSales = requests
      .filter((request: InvestorRequest) => {
        const type = String(request.type ?? "").toLowerCase();
        return type === "purchase" || type === "buy";
      })
      .reduce((sum: number, request: InvestorRequest) => sum + Number(request.amount ?? 0), 0);

    return [
      { title: "Total Sales", value: `${totalSales.toFixed(2)}`, trend: `${dashboardPeriod.value} period` },
      { title: "Total Products", value: String(products.length), trend: "All" },
      { title: "Active Products", value: String(products.filter((p: Product) => p.stock > 0).length), trend: "Active" },
      { title: "Out of Stock Products", value: String(products.filter((p: Product) => p.stock === 0).length), trend: "AvailableStock=0" },
      { title: "Total Transactions", value: String(totalTransactions), trend: `${dashboardPeriod.value} period` }
    ];
  });

  const statusSummary = computed(() => ({
    pending: marketplace.state.value.requests.filter((x: InvestorRequest) => x.status === "pending").length,
    approved: marketplace.state.value.requests.filter((x: InvestorRequest) => x.status === "approved").length,
    rejected: marketplace.state.value.requests.filter((x: InvestorRequest) => x.status === "rejected").length
  }));

  const categorySummary = computed(() => {
    const map = new Map<string, number>();
    marketplace.state.value.products.forEach((p: Product) => {
      const categoryName = normalizeCategoryLabel(String(p.category));
      if (!isVisibleCategory(categoryName)) return;
      map.set(categoryName, (map.get(categoryName) ?? 0) + 1);
    });
    return Array.from(map.entries()).map(([category, count]) => ({ category, count }));
  });

  const categoryTransactionSeries = computed(() => {
    if (serverDashboard.value?.categoryTransactionSeries?.length) {
      return serverDashboard.value.categoryTransactionSeries.filter((item) => isVisibleCategory(item.label));
    }

    return categorySummary.value
      .filter((item) => isVisibleCategory(item.category))
      .map((item) => ({ label: item.category, value: item.count }));
  });

  const categoryCartSeries = computed(() => {
    if (serverDashboard.value?.categoryCartSeries?.length) {
      return serverDashboard.value.categoryCartSeries.filter((item) => isVisibleCategory(item.label));
    }

    return categorySummary.value
      .filter((item) => isVisibleCategory(item.category))
      .map((item) => ({ label: item.category, value: Math.max(0, item.count * 2) }));
  });

  const statusRing = computed(() => {
    if (serverDashboard.value?.statusSegments?.length) {
      return serverDashboard.value.statusSegments.map((x) => ({
        key: x.key,
        label: x.label,
        value: x.value,
        percent: x.percent,
        color: STATUS_COLORS[x.key.toLowerCase()] ?? "#6b7280"
      }));
    }

    const total = Math.max(statusSummary.value.pending + statusSummary.value.approved + statusSummary.value.rejected, 1);
    return [
      { key: "pending", label: "Pending", value: statusSummary.value.pending, color: "#f59e0b", percent: Math.round((statusSummary.value.pending / total) * 100) },
      { key: "approved", label: "Approved", value: statusSummary.value.approved, color: "#10b981", percent: Math.round((statusSummary.value.approved / total) * 100) },
      { key: "rejected", label: "Rejected", value: statusSummary.value.rejected, color: "#ef4444", percent: Math.round((statusSummary.value.rejected / total) * 100) }
    ];
  });

  const categoryRing = computed(() => {
    if (serverDashboard.value?.categorySegments?.length) {
      return serverDashboard.value.categorySegments.map((item, idx) => ({
        category: item.label,
        count: item.value,
        percent: item.percent,
        color: CATEGORY_COLORS[idx % CATEGORY_COLORS.length]
      }));
    }

    const total = Math.max(categorySummary.value.reduce((sum, item) => sum + item.count, 0), 1);
    return categorySummary.value.map((item, idx) => ({
      ...item,
      percent: Math.round((item.count / total) * 100),
      color: CATEGORY_COLORS[idx % CATEGORY_COLORS.length]
    }));
  });

  const recentTransactions = computed(() => {
    if (serverDashboard.value?.recentTransactions?.length) {
      return serverDashboard.value.recentTransactions;
    }

    return marketplace.state.value.requests
      .slice(-6)
      .reverse()
      .map((request: InvestorRequest, idx: number) => ({
        id: request.id,
        sellerName: request.sellerName,
        createdAt: request.createdAt,
        status: request.status,
        type: request.type,
        amount: request.amount,
        investorName: (marketplace.state.value.investors as Investor[]).find((inv: Investor) => inv.id === request.investorId)?.fullName ?? request.investorId,
        productName: marketplace.state.value.products[idx % Math.max(marketplace.state.value.products.length, 1)]?.name ?? "N/A"
      }));
  });

  const pendingKycRequests = computed(() =>
    marketplace.state.value.sellers.filter((seller: { kycStatus?: string }) => {
      const status = String(seller.kycStatus ?? "").toLowerCase();
      return status === "pending" || status === "underreview";
    }).length
  );


  watch(
    [() => marketplace.session.value?.accessToken, dashboardPeriod],
    () => {
      void loadServerDashboard();
    },
    { immediate: true }
  );

  watch(
    () => marketplace.realtimeRefreshTick.value,
    () => {
      void loadServerDashboard();
    }
  );

  return { dashboardPeriod, dashboardCards, statusSummary, categorySummary, statusRing, categoryRing, recentTransactions, categoryTransactionSeries, categoryCartSeries, pendingKycRequests };
}
