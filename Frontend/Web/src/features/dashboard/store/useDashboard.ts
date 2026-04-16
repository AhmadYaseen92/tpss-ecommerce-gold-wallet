import { computed, onMounted, ref, watch } from "vue";
import type { ReturnTypeUseMarketplace } from "../../../shared/app/store/useMarketplace";
import { fetchWebAdminDashboard } from "../../../shared/services/backendGateway";
import type { WebDashboardDto } from "../../../shared/types/apiTypes";

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
const ANALYTICS_CATEGORIES = ["Gold", "Silver", "Diamond", "Jewelry", "Coins"];

const normalizeCategoryLabel = (rawCategory: string) => CATEGORY_NAME_BY_ID[rawCategory] ?? rawCategory;
const isVisibleCategory = (category: string) => category.trim().toLowerCase() !== "spotmr";

export function useDashboard(marketplace: ReturnTypeUseMarketplace) {
  const dashboardPeriod = ref<"month">("month");
  const serverDashboard = ref<WebDashboardDto | null>(null);

  const toCategorySeriesWithDefaults = (items: Array<{ label: string; value: number }>) => {
    const map = new Map<string, number>();
    ANALYTICS_CATEGORIES.forEach((category) => map.set(category, 0));
    items.forEach((item) => {
      const category = normalizeCategoryLabel(item.label);
      if (!isVisibleCategory(category)) return;
      if (!map.has(category)) return;
      map.set(category, item.value);
    });

    return ANALYTICS_CATEGORIES.map((category) => ({ label: category, value: map.get(category) ?? 0 }));
  };

  const loadServerDashboard = async () => {
    if (!marketplace.session.value?.accessToken) {
      serverDashboard.value = null;
      return;
    }

    try {
      serverDashboard.value = await fetchWebAdminDashboard(marketplace.session.value.accessToken, "month");
    } catch {
      // Keep previous payload on transient failure.
    }
  };
  const dashboardCards = computed(() => {
    if (serverDashboard.value?.cards?.length) {
      return serverDashboard.value.cards;
    }

    const products = marketplace.state.value.products;
    const totalTransactions = marketplace.state.value.requests.length;
    const totalSales = products.reduce((sum, p) => sum + Number(p.unitPrice) * Math.max(p.stock, 0), 0);
    return [
      { title: "Total Transactions", value: String(totalTransactions), trend: `${dashboardPeriod.value} period` },
      { title: "Total Sales", value: `${totalSales.toFixed(2)}`, trend: `${dashboardPeriod.value} period` },
      { title: "Total Products", value: String(products.length), trend: "All" },
      { title: "Active Products", value: String(products.filter((p) => p.stock > 0).length), trend: "Active" },
      { title: "Out of Stock Products", value: String(products.filter((p) => p.stock === 0).length), trend: "AvailableStock=0" },
      { title: "Gold Market Price", value: `${products.find((p) => String(p.category).toLowerCase().includes("gold"))?.marketPrice ?? 0}`, trend: "Current" }
    ];
  });

  const statusSummary = computed(() => ({
    pending: marketplace.state.value.requests.filter((x) => x.status === "pending").length,
    approved: marketplace.state.value.requests.filter((x) => x.status === "approved").length,
    rejected: marketplace.state.value.requests.filter((x) => x.status === "rejected").length
  }));

  const categorySummary = computed(() => {
    const map = new Map<string, number>(ANALYTICS_CATEGORIES.map((category) => [category, 0]));
    marketplace.state.value.products.forEach((p) => {
      const categoryName = normalizeCategoryLabel(String(p.category));
      if (!isVisibleCategory(categoryName) || !map.has(categoryName)) return;
      map.set(categoryName, (map.get(categoryName) ?? 0) + 1);
    });
    return Array.from(map.entries()).map(([category, count]) => ({ category, count }));
  });

  const categoryTransactionSeries = computed(() => {
    if (serverDashboard.value?.categoryTransactionSeries?.length) {
      return toCategorySeriesWithDefaults(serverDashboard.value.categoryTransactionSeries);
    }

    return toCategorySeriesWithDefaults(categorySummary.value.map((item) => ({ label: item.category, value: item.count })));
  });

  const categoryCartSeries = computed(() => {
    if (serverDashboard.value?.categoryCartSeries?.length) {
      return toCategorySeriesWithDefaults(serverDashboard.value.categoryCartSeries);
    }

    return toCategorySeriesWithDefaults(categorySummary.value.map((item) => ({ label: item.category, value: Math.max(0, item.count * 2) })));
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
      .map((request, idx) => ({
        id: request.id,
        createdAt: request.createdAt,
        status: request.status,
        type: request.type,
        amount: request.amount,
        investorName: marketplace.state.value.investors.find((inv) => inv.id === request.investorId)?.fullName ?? request.investorId,
        productName: marketplace.state.value.products[idx % Math.max(marketplace.state.value.products.length, 1)]?.name ?? "N/A"
      }));
  });

  watch(() => marketplace.session.value?.accessToken, () => {
    void loadServerDashboard();
  }, { immediate: true });

  // SignalR in useMarketplace triggers marketplace state refresh.
  // We refresh dashboard data when marketplace state gets refreshed.
  watch(() => [marketplace.state.value.requests.length, marketplace.state.value.products.length, marketplace.signalRConnected.value], () => {
    if (!marketplace.signalRConnected.value) return;
    void loadServerDashboard();
  });

  onMounted(() => {
    void loadServerDashboard();
  });

  return { dashboardPeriod, dashboardCards, statusSummary, categorySummary, statusRing, categoryRing, recentTransactions, categoryTransactionSeries, categoryCartSeries };
}
