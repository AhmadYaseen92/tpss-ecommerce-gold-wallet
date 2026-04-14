import { computed, ref, type Ref } from "vue";
import type { ProductManagementDto } from "../../../shared/types/apiTypes";
import type { ReturnTypeUseMarketplace } from "./useMarketplace";

export function useDashboard(marketplace: ReturnTypeUseMarketplace, managedProducts: Ref<ProductManagementDto[]>) {
  const dashboardPeriod = ref<"today" | "week" | "month">("today");
  const dashboardCards = computed(() => {
    const products = managedProducts.value;
    const totalTransactions = marketplace.state.value.requests.length;
    const totalSales = products.reduce((sum, p) => sum + Number(p.price) * Math.max(p.availableStock, 0), 0);
    return [
      { title: "Total Transactions", value: String(totalTransactions), trend: `${dashboardPeriod.value} period` },
      { title: "Total Sales", value: `${totalSales.toFixed(2)}`, trend: `${dashboardPeriod.value} period` },
      { title: "Total Products", value: String(products.length), trend: "All" },
      { title: "Active Products", value: String(products.filter((p) => p.isActive).length), trend: "IsActive=true" },
      { title: "Out of Stock Products", value: String(products.filter((p) => p.availableStock === 0).length), trend: "AvailableStock=0" },
      { title: "Gold Market Price", value: `${products.find((p) => p.category.toLowerCase().includes("gold"))?.price ?? 0}`, trend: "Current" }
    ];
  });
  const chartPoints = computed(() => Array.from({ length: dashboardPeriod.value === "today" ? 6 : dashboardPeriod.value === "week" ? 7 : 12 }, (_, i) => ({ x: i + 1, transactions: 20 + (i % 4) * 5 + i, sales: 500 + i * 85 })));
  const statusSummary = computed(() => ({ pending: marketplace.state.value.requests.filter((x) => x.status === "pending").length, approved: marketplace.state.value.requests.filter((x) => x.status === "approved").length, rejected: marketplace.state.value.requests.filter((x) => x.status === "rejected").length }));
  const categorySummary = computed(() => {
    const map = new Map<string, number>();
    managedProducts.value.forEach((p) => map.set(p.category, (map.get(p.category) ?? 0) + 1));
    return Array.from(map.entries()).map(([category, count]) => ({ category, count }));
  });
  return { dashboardPeriod, dashboardCards, chartPoints, statusSummary, categorySummary };
}
