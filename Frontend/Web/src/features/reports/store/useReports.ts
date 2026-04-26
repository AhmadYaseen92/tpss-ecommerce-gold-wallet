import { computed, reactive, ref } from "vue";
import type { MarketplaceState, ReportMetric } from "../../../shared/types/models";
import { downloadBlob } from "../../../shared/services/fileDownload";
import type { ReturnTypeUseMarketplace } from "../../../shared/app/store/useMarketplace";
import { reportService } from "../services/reportService";
import type { ReportFilters, ReportTableData, ReportTypeCard } from "../types/reportTypes";
import {
  MATERIAL_TYPE_OPTIONS,
  PRODUCT_FORM_OPTIONS,
  normalizeMaterialTypeKey,
  normalizeProductFormKey
} from "../../../shared/constants/productTaxonomy";

const ADMIN_REPORTS: ReportTypeCard[] = [
  { key: "sales", label: "Sales Report", description: "Sales, orders, quantity and seller/product/category/date splits", audience: "Admin" },
  { key: "sellerPerformance", label: "Seller Performance", description: "Seller revenue and request performance", audience: "Admin" },
  { key: "investorActivity", label: "Investor Activity", description: "Investor onboarding and operations", audience: "Admin" },
  { key: "walletTransactions", label: "Wallet Transactions", description: "Wallet activity by action + status", audience: "Admin" },
  { key: "invoices", label: "Invoices", description: "Invoices, payment and status details", audience: "Both" },
  { key: "operations", label: "Requests / Operations", description: "System request flow and trends", audience: "Admin" },
  { key: "kyc", label: "KYC / Onboarding", description: "Seller onboarding decisions", audience: "Admin" },
  { key: "fees", label: "Fees", description: "Delivery/storage/service fee aggregates", audience: "Admin" }
];

const SELLER_REPORTS: ReportTypeCard[] = [
  { key: "sellerSales", label: "Seller Sales", description: "Own sales totals and top products", audience: "Seller" },
  { key: "stock", label: "Product Stock", description: "Stock health and inactive items", audience: "Seller" },
  { key: "requests", label: "Requests", description: "Own investor requests by status/type", audience: "Seller" },
  { key: "invoices", label: "Invoices", description: "Own invoices and payment state", audience: "Both" },
  { key: "fulfillment", label: "Wallet Pickup / Fulfillment", description: "Pickups, delivery, completion times", audience: "Seller" },
  { key: "customers", label: "Customer / Investor", description: "Investor interactions and value", audience: "Seller" }
];

export function useReports(marketplace: ReturnTypeUseMarketplace) {
  const reportFilters = reactive<ReportFilters>({
    reportType: "sales",
    datePreset: "thisMonth",
    customFrom: "",
    customTo: "",
    sellerId: "all",
    investorId: "all",
    productId: "all",
    materialType: "all",
    formType: "all",
    requestType: "all",
    transactionStatus: "all",
    paymentStatus: "all",
    walletActionType: "all",
    invoiceNumber: "",
    orderNumber: "",
    userName: "",
    phone: "",
    email: "",
    sortBy: "Date",
    sortDir: "desc",
    page: 1,
    pageSize: 10
  });

  const loading = ref(false);
  const tableData = ref<ReportTableData>({ headers: [], rows: [], totalsRow: {} });
  const summaryMetrics = ref<ReportMetric[]>([]);

  const stateSnapshot = computed(() => marketplace.state.value as MarketplaceState);

  const effectiveSellerId = computed(() => {
    if (marketplace.role.value === "Seller") {
      return marketplace.activeSeller.value?.id ?? "";
    }
    return reportFilters.sellerId;
  });

  const reportTypeCards = computed(() => (marketplace.role.value === "Admin" ? ADMIN_REPORTS : SELLER_REPORTS));

  const visibleProducts = computed(() =>
    stateSnapshot.value.products.filter((p) => effectiveSellerId.value === "all" || !effectiveSellerId.value || p.sellerId === effectiveSellerId.value)
  );

  const visibleRequests = computed(() =>
    stateSnapshot.value.requests.filter((r) => effectiveSellerId.value === "all" || !effectiveSellerId.value || r.sellerId === effectiveSellerId.value)
  );

  const visibleInvoices = computed(() =>
    stateSnapshot.value.invoices.filter((i) => effectiveSellerId.value === "all" || !effectiveSellerId.value || i.sellerId === effectiveSellerId.value)
  );

  const materialTypes = computed(() => MATERIAL_TYPE_OPTIONS);
  const productForms = computed(() => PRODUCT_FORM_OPTIONS);

  const buildSummary = (rows: Array<Record<string, string | number>>) => {
    const numeric = (key: string) => rows.reduce((acc, row) => acc + (typeof row[key] === "number" ? Number(row[key]) : 0), 0);
    const pendingCount = rows.filter((r) => String(r.Status ?? "").toLowerCase().includes("pending")).length;

    const common = [{ title: "Total Rows", value: String(rows.length), trend: "Filtered records" }];

    switch (reportFilters.reportType) {
      case "sales":
      case "sellerSales":
      case "sellerPerformance":
        summaryMetrics.value = [
          ...common,
          { title: "Total Amount", value: numeric("Amount").toFixed(2), trend: "Revenue" },
          { title: "Pending", value: String(pendingCount), trend: "Open requests" },
          { title: "Approved", value: String(rows.filter((r) => String(r.Status ?? "").toLowerCase().includes("approved") || String(r.Completed ?? "0") !== "0").length), trend: "Completed flow" }
        ];
        break;
      case "stock":
        summaryMetrics.value = [
          ...common,
          { title: "Low Stock", value: String(rows.filter((r) => typeof r.Stock === "number" && Number(r.Stock) <= 5).length), trend: "Needs restock" },
          { title: "Out of Stock", value: String(rows.filter((r) => Number(r.Stock ?? 0) === 0).length), trend: "Critical" },
          { title: "Inventory Value", value: numeric("Market Price").toFixed(2), trend: "Market tracked" }
        ];
        break;
      case "invoices":
        summaryMetrics.value = [
          ...common,
          { title: "Grand Total", value: numeric("Grand Total").toFixed(2), trend: "Invoice value" },
          { title: "Paid", value: numeric("Paid Amount").toFixed(2), trend: "Collections" },
          { title: "Unpaid", value: numeric("Unpaid Amount").toFixed(2), trend: "Outstanding" }
        ];
        break;
      default:
        summaryMetrics.value = [
          ...common,
          { title: "Total Amount", value: numeric("Amount").toFixed(2), trend: "Operational value" },
          { title: "Pending", value: String(pendingCount), trend: "Open flow" },
          { title: "Unique Sellers", value: String(new Set(rows.map((r) => String(r.Seller ?? "-"))).size), trend: "Coverage" }
        ];
        break;
    }
  };

  const toTable = (rows: Array<Record<string, string | number>>) => {
    if (!rows.length) {
      tableData.value = { headers: [], rows: [], totalsRow: {} };
      buildSummary([]);
      return;
    }

    const headers = Object.keys(rows[0]);
    const sorted = [...rows].sort((a, b) => reportService.compareBy(a, b, reportFilters.sortBy, reportFilters.sortDir));
    const start = (reportFilters.page - 1) * reportFilters.pageSize;
    const paginated = sorted.slice(start, start + reportFilters.pageSize);
    tableData.value = { headers, rows: paginated, totalsRow: reportService.buildTotalsRow(headers, sorted) };
    buildSummary(sorted);
  };

  const generateReports = async () => {
    loading.value = true;
    try {
      const criteria = reportService.makeCriteria(reportFilters);
      const sellersMap = new Map(stateSnapshot.value.sellers.map((s) => [s.id, s]));
      const investorsMap = new Map(stateSnapshot.value.investors.map((i) => [i.id, i]));

      const passesProductShapeFilters = (product: { materialType?: string; formType?: string; category?: string }) =>
        (criteria.materialType === "all" || normalizeMaterialTypeKey(product.materialType || product.category) === criteria.materialType)
        && (criteria.formType === "all" || normalizeProductFormKey(product.formType) === criteria.formType);

      let rows: Array<Record<string, string | number>> = [];
      switch (reportFilters.reportType) {
        case "sales":
        case "sellerSales":
          rows = visibleRequests.value
            .filter((r) => r.type === "buy")
            .filter((r) => reportService.matchRequest(r, criteria, investorsMap))
            .filter((r) => {
              const matchedProduct = visibleProducts.value.find((p) => p.name === r.productName);
              return matchedProduct ? passesProductShapeFilters(matchedProduct) : criteria.materialType === "all";
            })
            .map((r) => ({
              Date: reportService.dateLabel(r.createdAt),
              "Order #": r.id,
              Seller: sellersMap.get(r.sellerId ?? "")?.name ?? "N/A",
              Investor: r.investorName,
              Product: r.productName,
              Category: r.category,
              Qty: r.quantity,
              Amount: r.amount,
              Status: r.status
            }));
          break;
        case "sellerPerformance":
          rows = stateSnapshot.value.sellers
            .filter((seller) => reportFilters.sellerId === "all" || seller.id === reportFilters.sellerId)
            .map((seller) => {
              const sellerRequests = stateSnapshot.value.requests.filter((r) => r.sellerId === seller.id);
              return {
                Seller: seller.name,
                "Active Products": stateSnapshot.value.products.filter((p) => p.sellerId === seller.id && p.stock > 0).length,
                Completed: sellerRequests.filter((r) => r.status === "delivered" || r.status === "approved").length,
                Pending: sellerRequests.filter((r) => String(r.status).includes("pending")).length,
                Rejected: sellerRequests.filter((r) => r.status === "rejected").length,
                Amount: sellerRequests.reduce((sum, r) => sum + r.amount, 0)
              };
            });
          break;
        case "stock":
          rows = visibleProducts.value
            .filter((product) => reportService.matchProduct(product, criteria))
            .filter((product) => passesProductShapeFilters(product))
            .map((product) => ({
              Product: product.name,
              Category: product.category,
              Stock: product.stock,
              "Unit Price": product.unitPrice,
              "Market Price": product.marketPrice,
              Status: product.stock <= 5 ? "Low Stock" : product.stock === 0 ? "Inactive" : "Active",
              Date: reportService.dateLabel(product.updatedAt)
            }));
          break;
        case "investorActivity":
        case "customers":
          rows = stateSnapshot.value.investors
            .filter((investor) => reportService.matchInvestor(investor, criteria))
            .map((investor) => {
              const investorRequests = visibleRequests.value.filter((r) => r.investorId === investor.id);
              return {
                Investor: investor.fullName,
                Email: investor.email ?? "-",
                Phone: investor.phoneNumber ?? "-",
                Transactions: investorRequests.length,
                Purchases: investorRequests.filter((r) => r.type === "buy").length,
                "Sell Requests": investorRequests.filter((r) => r.type === "sell").length,
                "Transfer/Gift": investorRequests.filter((r) => r.type === "transfer" || r.type === "gift").length,
                Amount: investorRequests.reduce((sum, r) => sum + r.amount, 0),
                Status: investor.status
              };
            });
          break;
        case "walletTransactions":
        case "requests":
        case "operations":
        case "fulfillment":
          rows = visibleRequests.value
            .filter((request) => reportService.matchRequest(request, criteria, investorsMap))
            .filter((request) => {
              const matchedProduct = visibleProducts.value.find((p) => p.name === request.productName);
              return matchedProduct ? passesProductShapeFilters(matchedProduct) : criteria.materialType === "all";
            })
            .map((request) => ({
              Date: reportService.dateLabel(request.createdAt),
              "Request #": request.id,
              Seller: sellersMap.get(request.sellerId ?? "")?.name ?? "N/A",
              Investor: request.investorName,
              Type: request.type,
              Product: request.productName,
              Qty: request.quantity,
              Amount: request.amount,
              Status: request.status,
              "Completion Hrs": request.updatedAt ? reportService.diffHours(request.createdAt, request.updatedAt) : "-"
            }));
          break;
        case "invoices":
          rows = visibleInvoices.value
            .filter((invoice) => reportService.matchInvoice(invoice, criteria))
            .map((invoice) => ({
              Date: reportService.dateLabel(invoice.issuedAt),
              Invoice: invoice.id,
              Seller: sellersMap.get(invoice.sellerId)?.name ?? "N/A",
              Investor: invoice.investorName,
              Subtotal: invoice.totalAmount,
              Fees: Number((invoice.totalAmount * stateSnapshot.value.fees.serviceChargePercent) / 100).toFixed(2),
              VAT: Number(invoice.totalAmount * 0.15).toFixed(2),
              Discount: 0,
              "Grand Total": invoice.totalAmount,
              "Paid Amount": invoice.paymentStatus === "Paid" ? invoice.totalAmount : 0,
              "Unpaid Amount": invoice.paymentStatus === "Paid" ? 0 : invoice.totalAmount,
              Status: invoice.status,
              "Payment Status": invoice.paymentStatus
            }));
          break;
        case "kyc":
          rows = stateSnapshot.value.sellers.map((seller) => ({
            Seller: seller.name,
            Email: seller.email,
            "Submission Date": reportService.dateLabel(seller.submittedAt),
            "Review Date": seller.reviewedAt ? reportService.dateLabel(seller.reviewedAt) : "-",
            Status: seller.kycStatus,
            Notes: seller.reviewNotes ?? "-"
          }));
          break;
        case "fees":
          rows = [{
            "Delivery Fees": stateSnapshot.value.fees.deliveryFee,
            "Storage Fees": stateSnapshot.value.fees.storageFee,
            "Service Fees %": stateSnapshot.value.fees.serviceChargePercent,
            "Collected (Estimated)": visibleInvoices.value.reduce((sum, invoice) => sum + (invoice.totalAmount * stateSnapshot.value.fees.serviceChargePercent) / 100, 0)
          }];
          break;
        default:
          rows = [];
      }

      toTable(rows);
    } finally {
      loading.value = false;
    }
  };

  const totalPages = computed(() => Math.max(1, Math.ceil(Math.max(1, summaryMetrics.value[0] ? Number(summaryMetrics.value[0].value) : 0) / reportFilters.pageSize)));

  const setSort = (key: string) => {
    reportFilters.sortDir = reportFilters.sortBy === key && reportFilters.sortDir === "asc" ? "desc" : "asc";
    reportFilters.sortBy = key;
    void generateReports();
  };

  const changePage = (delta: number) => {
    reportFilters.page = Math.min(totalPages.value, Math.max(1, reportFilters.page + delta));
    void generateReports();
  };

  

  const resetFiltersForType = (type: string) => {
    reportFilters.reportType = type;
    reportFilters.datePreset = "thisMonth";
    reportFilters.customFrom = "";
    reportFilters.customTo = "";
    reportFilters.sellerId = "all";
    reportFilters.investorId = "all";
    reportFilters.productId = "all";
    reportFilters.materialType = "all";
    reportFilters.formType = "all";
    reportFilters.requestType = "all";
    reportFilters.transactionStatus = "all";
    reportFilters.paymentStatus = "all";
    reportFilters.walletActionType = "all";
    reportFilters.invoiceNumber = "";
    reportFilters.orderNumber = "";
    reportFilters.userName = "";
    reportFilters.phone = "";
    reportFilters.email = "";
    reportFilters.page = 1;
  };

  const resetFilters = () => {
    resetFiltersForType(reportTypeCards.value[0]?.key ?? "sales");
    void generateReports();
  };

  const selectReportType = (type: string) => {
    resetFiltersForType(type);
    void generateReports();
  };

  const exportCsv = () => {
    if (!tableData.value.rows.length) return;
    const content = reportService.toDelimited(tableData.value.headers, tableData.value.rows, ",");
    downloadBlob(content, "text/csv;charset=utf-8;", `report-${reportFilters.reportType}.csv`);
  };

  const exportExcel = () => {
    if (!tableData.value.rows.length) return;
    const content = reportService.toDelimited(tableData.value.headers, tableData.value.rows, "\t");
    downloadBlob(content, "application/vnd.ms-excel", `report-${reportFilters.reportType}.xls`);
  };

  const printReport = () => {
    if (typeof window === "undefined") return;
    window.print();
  };

  return {
    reportFilters,
    reportTypeCards,
    summaryMetrics,
    tableData,
    loading,
    totalPages,
    materialTypes,
    productForms,
    generateReports,
    resetFilters,
    selectReportType,
    exportCsv,
    exportExcel,
    printReport,
    setSort,
    changePage
  };
}
