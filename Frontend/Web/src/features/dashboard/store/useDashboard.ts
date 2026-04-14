import { computed, ref } from "vue";
import type { ReturnTypeUseMarketplace } from "../../../shared/app/store/useMarketplace";

export function useDashboard(marketplace: ReturnTypeUseMarketplace) {
  const dashboardPeriod = ref<"today" | "week" | "month">("today");
  const dashboardCards = computed(() => {
    const products = marketplace.state.value.products;
    const totalTransactions = marketplace.state.value.requests.length;
    const totalSales = products.reduce((sum, p) => sum + Number(p.unitPrice) * Math.max(p.stock, 0), 0);
    return [
      { title: "Total Transactions", value: String(totalTransactions), trend: `${dashboardPeriod.value} period` },
      { title: "Total Sales", value: `${totalSales.toFixed(2)}`, trend: `${dashboardPeriod.value} period` },
      { title: "Total Products", value: String(products.length), trend: "All" },
      { title: "Active Products", value: String(products.filter((p) => p.stock > 0).length), trend: "Active" },
      { title: "Out of Stock Products", value: String(products.filter((p) => p.stock === 0).length), trend: "AvailableStock=0" },
      { title: "Gold Market Price", value: `${products.find((p) => p.category.toLowerCase().includes("gold"))?.marketPrice ?? 0}`, trend: "Current" }
    ];
  });

  const chartPoints = computed(() =>
    Array.from({ length: dashboardPeriod.value === "today" ? 6 : dashboardPeriod.value === "week" ? 7 : 12 }, (_, i) => ({ x: i + 1, transactions: 20 + (i % 4) * 5 + i, sales: 500 + i * 85 }))
  );

  const statusSummary = computed(() => ({
    pending: marketplace.state.value.requests.filter((x) => x.status === "pending").length,
    approved: marketplace.state.value.requests.filter((x) => x.status === "approved").length,
    rejected: marketplace.state.value.requests.filter((x) => x.status === "rejected").length
  }));

  const categorySummary = computed(() => {
    const map = new Map<string, number>();
    marketplace.state.value.products.forEach((p) => map.set(p.category, (map.get(p.category) ?? 0) + 1));
    return Array.from(map.entries()).map(([category, count]) => ({ category, count }));
  });

  const statusRing = computed(() => {
    const total = Math.max(statusSummary.value.pending + statusSummary.value.approved + statusSummary.value.rejected, 1);
    return [
      { key: "pending", label: "Pending", value: statusSummary.value.pending, color: "#f59e0b", percent: Math.round((statusSummary.value.pending / total) * 100) },
      { key: "approved", label: "Approved", value: statusSummary.value.approved, color: "#10b981", percent: Math.round((statusSummary.value.approved / total) * 100) },
      { key: "rejected", label: "Rejected", value: statusSummary.value.rejected, color: "#ef4444", percent: Math.round((statusSummary.value.rejected / total) * 100) }
    ];
  });

  const categoryRing = computed(() => {
    const total = Math.max(categorySummary.value.reduce((sum, item) => sum + item.count, 0), 1);
    return categorySummary.value.map((item, idx) => ({
      ...item,
      percent: Math.round((item.count / total) * 100),
      color: ["#f59e0b", "#6366f1", "#14b8a6", "#ec4899", "#84cc16"][idx % 5]
    }));
  });

  const recentTransactions = computed(() =>
    marketplace.state.value.requests
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
      }))
  );

  return { dashboardPeriod, dashboardCards, chartPoints, statusSummary, categorySummary, statusRing, categoryRing, recentTransactions };
}
