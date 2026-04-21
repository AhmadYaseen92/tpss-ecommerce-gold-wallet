import { reactive, ref } from "vue";
import { downloadBlob } from "../../../shared/services/fileDownload";
import type { ReturnTypeUseMarketplace } from "../../../shared/app/store/useMarketplace";

export function useReports(marketplace: ReturnTypeUseMarketplace) {
  const reportFilters = reactive({ reportType: "sales", sellerId: "all", userId: "", userName: "", productName: "", dateRange: "today", customFrom: "", customTo: "", stockOnly: false });
  const generatedReports = ref<Array<Record<string, string | number>>>([]);
  const reportTypeCards = [
    { key: "sales", label: "Sales Report", description: "Sales totals by products and users" },
    { key: "inventory", label: "Inventory Report", description: "Stock status and low stock items" },
    { key: "transactions", label: "Transactions Report", description: "Requests and approval activity" },
    { key: "seller", label: "Seller Report", description: "Seller-specific operational summary" }
  ];

  const generateReports = () => {
    const sellerLookup = new Map(marketplace.state.value.sellers.map((seller) => [seller.id, seller]));
    generatedReports.value = marketplace.state.value.products
      .filter((product) =>
        (!reportFilters.productName || product.name.toLowerCase().includes(reportFilters.productName.toLowerCase())) &&
        (!reportFilters.stockOnly || product.stock > 0) &&
        (reportFilters.sellerId === "all" || product.sellerId === reportFilters.sellerId)
      )
      .map((product) => ({
        type: reportFilters.reportType,
        sellerId: product.sellerId,
        sellerName: sellerLookup.get(product.sellerId)?.name ?? "N/A",
        userId: reportFilters.userId || "N/A",
        userName: reportFilters.userName || (marketplace.state.value.currentUserName ?? "N/A"),
        productName: product.name,
        stock: product.stock,
        unitPrice: product.unitPrice,
        dateRange: reportFilters.dateRange
      }));
  };

  const downloadReport = () => {
    if (!generatedReports.value.length) return;
    const headers = Object.keys(generatedReports.value[0]);
    const csv = [headers.join(","), ...generatedReports.value.map((row) => headers.map((h) => JSON.stringify(row[h] ?? "")).join(","))].join("\n");
    downloadBlob(csv, "text/csv;charset=utf-8;", `report-${reportFilters.reportType}.csv`);
  };

  const downloadPdf = () => {
    if (!generatedReports.value.length) return;
    const content = generatedReports.value.map((row) => Object.entries(row).map(([k, v]) => `${k}: ${v}`).join(" | ")).join("\n");
    downloadBlob(content, "application/pdf", `report-${reportFilters.reportType}.pdf`);
  };

  return { reportFilters, generatedReports, reportTypeCards, generateReports, downloadReport, downloadPdf };
}
