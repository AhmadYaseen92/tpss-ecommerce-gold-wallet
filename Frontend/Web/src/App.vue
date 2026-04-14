<script setup lang="ts">
import { computed, onMounted, onUnmounted, reactive, ref, watch } from "vue";
import type { NavigationKey } from "./shared/types/models";
import AppShell from "./shared/layouts/AppShell.vue";
import SectionCard from "./shared/components/SectionCard.vue";
import DashboardOverviewPage from "./features/dashboard/pages/DashboardOverviewPage.vue";
import ProductManagementPage from "./features/products/pages/ProductManagementPage.vue";
import InvestorsPage from "./features/investors/pages/InvestorsPage.vue";
import TransactionsPage from "./features/transactions/pages/TransactionsPage.vue";
import ReportsPage from "./features/reports/pages/ReportsPage.vue";
import { useMarketplace } from "./features/dashboard/store/useMarketplace";
import {
  createManagedProduct,
  deleteManagedProduct,
  fetchManagedProducts,
  fetchProductCategories,
  fetchWeightUnits,
  updateManagedProduct,
  type ProductFormPayload
} from "./shared/services/backendGateway";
import type { ProductManagementDto, EnumItemDto } from "./shared/types/apiTypes";

const marketplace = useMarketplace();
const isDark = ref(false);
const authScreen = ref<"login" | "register">("login");

const loginForm = reactive({
  email: "admin@goldwallet.com",
  password: "P@ssw0rd",
  rememberMe: true
});

const registerForm = reactive({
  fullName: "",
  email: "",
  password: "",
  confirmPassword: "",
  businessName: "",
  idNumber: ""
});


const reportFilters = reactive({
  reportType: "sales",
  userId: "",
  userName: "",
  productName: "",
  dateRange: "today",
  customFrom: "",
  customTo: "",
  stockOnly: false
});
const generatedReports = ref<Array<Record<string, string | number>>>([]);
const dashboardPeriod = ref<"today" | "week" | "month">("today");
const selectedInvestorId = ref<string | null>(null);
const selectedTransactionId = ref<string | null>(null);
const transactionStatusDraft = ref<"pending" | "approved" | "rejected">("pending");
const managedProducts = ref<ProductManagementDto[]>([]);
const categories = ref<EnumItemDto[]>([]);
const weightUnits = ref<EnumItemDto[]>([]);
const selectedProduct = ref<ProductManagementDto | null>(null);
const productError = ref("");
const productPage = ref<"list" | "add" | "edit" | "details">("list");
const productRouteId = ref<number | null>(null);
const productForm = reactive<ProductFormPayload>({
  name: "",
  sku: "",
  description: "",
  category: 0,
  weightValue: 0,
  weightUnit: 0,
  price: 0,
  availableStock: 0,
  isActive: true,
  imageFile: null,
  existingImageUrl: ""
});

const resetProductForm = () => {
  productForm.id = undefined;
  productForm.name = "";
  productForm.sku = "";
  productForm.description = "";
  productForm.category = categories.value[0]?.value ?? 0;
  productForm.weightValue = 0;
  productForm.weightUnit = weightUnits.value[0]?.value ?? 0;
  productForm.price = 0;
  productForm.availableStock = 0;
  productForm.isActive = true;
  productForm.imageFile = null;
  productForm.existingImageUrl = "";
  productError.value = "";
};

const loadProductManagementData = async () => {
  if (!marketplace.session.value?.accessToken) return;

  try {
    managedProducts.value = await fetchManagedProducts(marketplace.session.value.accessToken);
  } catch (error) {
    productError.value = error instanceof Error ? error.message : "Failed to load products";
  }

  try {
    categories.value = await fetchProductCategories(marketplace.session.value.accessToken);
    weightUnits.value = await fetchWeightUnits(marketplace.session.value.accessToken);
    if (!productForm.category && categories.value.length > 0) productForm.category = categories.value[0].value;
    if (!productForm.weightUnit && weightUnits.value.length > 0) productForm.weightUnit = weightUnits.value[0].value;
  } catch (error) {
    productError.value = error instanceof Error ? error.message : "Failed to load dropdown values";
  }
};

watch(
  () => marketplace.session.value?.accessToken,
  () => {
    void loadProductManagementData();
  },
  { immediate: true }
);

const fillProductForm = (product: ProductManagementDto) => {
  productForm.id = product.id;
  productForm.name = product.name;
  productForm.sku = product.sku;
  productForm.description = product.description;
  productForm.category = categories.value.find((x) => x.name === product.category)?.value ?? categories.value[0]?.value ?? 0;
  productForm.weightValue = Number(product.weightValue);
  productForm.weightUnit = weightUnits.value.find((x) => x.name === product.weightUnit)?.value ?? weightUnits.value[0]?.value ?? 0;
  productForm.price = Number(product.price);
  productForm.availableStock = product.availableStock;
  productForm.isActive = product.isActive;
  productForm.existingImageUrl = product.imageUrl;
  productForm.imageFile = null;
};

const syncProductRoute = () => {
  const hash = window.location.hash || "#/products";
  const addMatch = hash.match(/^#\/products\/new$/);
  const editMatch = hash.match(/^#\/products\/(\d+)\/edit$/);
  const detailsMatch = hash.match(/^#\/products\/(\d+)$/);

  if (addMatch) {
    productPage.value = "add";
    productRouteId.value = null;
    selectedProduct.value = null;
    resetProductForm();
    return;
  }

  if (editMatch) {
    const id = Number(editMatch[1]);
    const product = managedProducts.value.find((item) => item.id === id) ?? null;
    productPage.value = "edit";
    productRouteId.value = id;
    selectedProduct.value = product;
    if (product) fillProductForm(product);
    return;
  }

  if (detailsMatch) {
    const id = Number(detailsMatch[1]);
    productPage.value = "details";
    productRouteId.value = id;
    selectedProduct.value = managedProducts.value.find((item) => item.id === id) ?? null;
    return;
  }

  productPage.value = "list";
  productRouteId.value = null;
  selectedProduct.value = null;
};

const goToProductRoute = (path: string) => {
  window.location.hash = path;
  syncProductRoute();
};

const openAddProduct = () => {
  resetProductForm();
  goToProductRoute("#/products/new");
};

const openEditProduct = (product: ProductManagementDto) => {
  fillProductForm(product);
  goToProductRoute(`#/products/${product.id}/edit`);
};

const openProductDetails = (product: ProductManagementDto) => {
  selectedProduct.value = product;
  goToProductRoute(`#/products/${product.id}`);
};

const onProductImageChange = (event: Event) => {
  const input = event.target as HTMLInputElement;
  productForm.imageFile = input.files?.[0] ?? null;
};

const saveProduct = async () => {
  if (!marketplace.session.value?.accessToken) return;
  if (!productForm.name || !productForm.sku || !productForm.description || productForm.price <= 0) {
    productError.value = "Please fill all mandatory fields with valid values.";
    return;
  }

  try {
    if (productPage.value === "edit" && productForm.id) {
      await updateManagedProduct(marketplace.session.value.accessToken, productForm.id, productForm);
      goToProductRoute(`#/products/${productForm.id}`);
    } else {
      await createManagedProduct(marketplace.session.value.accessToken, productForm);
      goToProductRoute("#/products");
      resetProductForm();
    }

    await loadProductManagementData();
  } catch (error) {
    productError.value = error instanceof Error ? error.message : "Failed to save product";
  }
};

const deleteProductRecord = async (productId: number) => {
  if (!marketplace.session.value?.accessToken) return;
  if (!confirm("Are you sure you want to delete this product?")) return;

  try {
    await deleteManagedProduct(marketplace.session.value.accessToken, productId);
    await loadProductManagementData();
    if (selectedProduct.value?.id === productId) goToProductRoute("#/products");
  } catch (error) {
    productError.value = error instanceof Error ? error.message : "Failed to delete product";
  }
};


onMounted(() => {
  syncProductRoute();
  window.addEventListener("hashchange", syncProductRoute);
});

onUnmounted(() => {
  window.removeEventListener("hashchange", syncProductRoute);
});

watch(managedProducts, () => {
  if (marketplace.activeMenu.value === "products") {
    syncProductRoute();
  }
});

watch(isDark, (value) => {
  document.documentElement.classList.toggle("dark-mode", value);
});


const menuItems = computed(() => {
  const common: Array<{ key: NavigationKey; label: string }> = [
    { key: "overview", label: "Dashboard" },
    { key: "products", label: "Products" },
    { key: "investors", label: "Investors" },
    { key: "requests", label: "Transactions" },
    { key: "reports", label: "Reports" },
    { key: "logout", label: "Logout" }
  ];

  if (marketplace.role.value === "admin") {
    return [...common, { key: "fees", label: "Fees" }];
  }

  return common;
});

const welcomeText = computed(() => {
  if (!marketplace.session.value) return "Welcome";
  const fullName = marketplace.state.value.currentUserName ?? (marketplace.role.value === "admin" ? "Admin User" : "Seller User");
  return `Welcome back, ${fullName}`;
});

const registerSellerAction = async () => {
  if (registerForm.password !== registerForm.confirmPassword) {
    marketplace.error.value = "Password and confirm password do not match.";
    return;
  }

  const parts = registerForm.fullName.trim().split(/\s+/);
  const firstName = parts[0] ?? "";
  const middleName = parts.length > 2 ? parts.slice(1, -1).join(" ") : (parts[1] ?? "-");
  const lastName = parts.length > 1 ? parts[parts.length - 1] : "-";

  await marketplace.registerSeller({
    firstName,
    middleName,
    lastName,
    email: registerForm.email,
    password: registerForm.password,
    businessName: registerForm.businessName,
    idNumber: registerForm.idNumber
  });
};

const dashboardCards = computed(() => {
  const products = managedProducts.value;
  const totalTransactions = marketplace.state.value.requests.length;
  const totalSales = products.reduce((sum, p) => sum + Number(p.price) * Math.max(p.availableStock, 0), 0);
  const activeProducts = products.filter((p) => p.isActive).length;
  const outOfStockProducts = products.filter((p) => p.availableStock === 0).length;
  const goldMarketPrice = products.find((p) => p.category.toLowerCase().includes("gold"))?.price ?? 0;

  return [
    { title: "Total Transactions", value: String(totalTransactions), trend: `${dashboardPeriod.value} period` },
    { title: "Total Sales", value: `${totalSales.toFixed(2)}`, trend: `${dashboardPeriod.value} period` },
    { title: "Total Products", value: String(products.length), trend: "All" },
    { title: "Active Products", value: String(activeProducts), trend: "IsActive=true" },
    { title: "Out of Stock Products", value: String(outOfStockProducts), trend: "AvailableStock=0" },
    { title: "Gold Market Price", value: `${goldMarketPrice}`, trend: "Current" }
  ];
});

const chartPoints = computed(() => {
  const points = dashboardPeriod.value === "today" ? 6 : dashboardPeriod.value === "week" ? 7 : 12;
  return Array.from({ length: points }, (_, i) => ({
    x: i + 1,
    transactions: 20 + (i % 4) * 5 + i,
    sales: 500 + i * 85,
    pending: 4 + (i % 3),
    approved: 8 + (i % 4),
    rejected: 2 + (i % 2)
  }));
});

const statusSummary = computed(() => ({
  pending: marketplace.state.value.requests.filter((x) => x.status === "pending").length,
  approved: marketplace.state.value.requests.filter((x) => x.status === "approved").length,
  rejected: marketplace.state.value.requests.filter((x) => x.status === "rejected").length
}));

const categorySummary = computed(() => {
  const map = new Map<string, number>();
  for (const product of managedProducts.value) {
    map.set(product.category, (map.get(product.category) ?? 0) + 1);
  }
  return Array.from(map.entries()).map(([category, count]) => ({ category, count }));
});

const investorRows = computed(() =>
  marketplace.state.value.investors.map((inv, idx) => {
    const totalTransactions = marketplace.state.value.requests.filter((r) => r.investorId === inv.id).length;
    return {
      ...inv,
      email: `${inv.fullName.toLowerCase().replace(/\s+/g, ".")}@mail.com`,
      totalTransactions,
      totalPurchases: totalTransactions * 250,
      createdDate: `2026-04-${String(10 + idx).padStart(2, "0")}`,
      lastTransactionDate: marketplace.state.value.requests.find((r) => r.investorId === inv.id)?.createdAt ?? "-"
    };
  })
);

const selectedInvestor = computed(() => investorRows.value.find((x) => x.id === selectedInvestorId.value) ?? null);

const transactionsView = computed(() =>
  marketplace.state.value.requests.map((request, idx) => ({
    ...request,
    investorName: investorRows.value.find((inv) => inv.id === request.investorId)?.fullName ?? request.investorId,
    productName: managedProducts.value[idx % Math.max(managedProducts.value.length, 1)]?.name ?? "N/A",
    transactionType: idx % 2 === 0 ? "Buy" : "Sell",
    transactionPrice: managedProducts.value[idx % Math.max(managedProducts.value.length, 1)]?.price ?? 0
  }))
);

const selectedTransaction = computed(() => transactionsView.value.find((x) => x.id === selectedTransactionId.value) ?? null);

const viewTransaction = (id: string) => {
  selectedTransactionId.value = id;
  transactionStatusDraft.value = (transactionsView.value.find((x) => x.id === id)?.status ?? "pending") as "pending" | "approved" | "rejected";
};

const saveTransactionStatus = () => {
  if (!selectedTransactionId.value) return;
  marketplace.updateRequestStatus(selectedTransactionId.value, transactionStatusDraft.value);
};

const toggleInvestorStatus = (id: string) => {
  const investor = marketplace.state.value.investors.find((x) => x.id === id);
  if (!investor) return;
  investor.status = investor.status === "active" ? "review" : "active";
};

const toggleProductActive = async (product: ProductManagementDto) => {
  if (!marketplace.session.value?.accessToken) return;
  const payload: ProductFormPayload = {
    id: product.id,
    name: product.name,
    sku: product.sku,
    description: product.description,
    category: categories.value.find((x) => x.name === product.category)?.value ?? categories.value[0]?.value ?? 0,
    weightValue: Number(product.weightValue),
    weightUnit: weightUnits.value.find((x) => x.name === product.weightUnit)?.value ?? weightUnits.value[0]?.value ?? 0,
    price: Number(product.price),
    availableStock: product.availableStock,
    isActive: !product.isActive,
    existingImageUrl: product.imageUrl
  };

  await updateManagedProduct(marketplace.session.value.accessToken, product.id, payload);
  await loadProductManagementData();
};


const reportTypeCards = [
  { key: "sales", label: "Sales Report", description: "Sales totals by products and users" },
  { key: "inventory", label: "Inventory Report", description: "Stock status and low stock items" },
  { key: "transactions", label: "Transactions Report", description: "Requests and approval activity" },
  { key: "seller", label: "Seller Report", description: "Seller-specific operational summary" }
];


const statusClass = (status: string) => {
  const normalized = status.toLowerCase();
  if (normalized.includes("approved") || normalized.includes("active")) return "status-green";
  if (normalized.includes("rejected") || normalized.includes("inactive")) return "status-red";
  return "status-orange";
};

const generateReports = () => {
  const rows: Array<Record<string, string | number>> = [];

  for (const product of marketplace.state.value.products) {
    if (reportFilters.productName && !product.name.toLowerCase().includes(reportFilters.productName.toLowerCase())) continue;
    if (reportFilters.stockOnly && product.stock <= 0) continue;

    rows.push({
      type: reportFilters.reportType,
      userId: reportFilters.userId || "N/A",
      userName: reportFilters.userName || (marketplace.state.value.currentUserName ?? "N/A"),
      productName: product.name,
      stock: product.stock,
      unitPrice: product.unitPrice,
      dateRange: reportFilters.dateRange
    });
  }

  generatedReports.value = rows;
};

const downloadReport = () => {
  if (generatedReports.value.length === 0) return;

  const headers = Object.keys(generatedReports.value[0]);
  const csvRows = [headers.join(",")];
  for (const row of generatedReports.value) {
    csvRows.push(headers.map((header) => JSON.stringify(row[header] ?? "")).join(","));
  }

  const blob = new Blob([csvRows.join("\n")], { type: "text/csv;charset=utf-8;" });
  const url = URL.createObjectURL(blob);
  const link = document.createElement("a");
  link.href = url;
  link.download = `report-${reportFilters.reportType}.csv`;
  link.click();
  URL.revokeObjectURL(url);
};

const downloadPdf = () => {
  if (generatedReports.value.length === 0) return;
  const content = generatedReports.value.map((row) => Object.entries(row).map(([k, v]) => `${k}: ${v}`).join(" | ")).join("\n");
  const blob = new Blob([content], { type: "application/pdf" });
  const url = URL.createObjectURL(blob);
  const link = document.createElement("a");
  link.href = url;
  link.download = `report-${reportFilters.reportType}.pdf`;
  link.click();
  URL.revokeObjectURL(url);
};

</script>

<template>
  <section v-if="!marketplace.session.value" class="login-page">
    <div class="auth-card large">
      <h1>{{ authScreen === "login" ? "Welcome Back" : "Create Seller Account" }}</h1>
      <p v-if="authScreen === 'login'">Sign in to continue to your dashboard.</p>
      <p v-else>Register seller account with KYC details and wait for admin approval.</p>

      <form
        v-if="authScreen === 'login'"
        @submit.prevent="marketplace.login({ email: loginForm.email, password: loginForm.password })"
      >
        <input v-model="loginForm.email" type="email" placeholder="Email" required />
        <input v-model="loginForm.password" type="password" placeholder="Password" required />

        <div class="auth-options">
          <label class="remember">
            <input v-model="loginForm.rememberMe" type="checkbox" /> Remember me
          </label>
          <a href="#">Forgot password?</a>
        </div>

        <button :disabled="marketplace.loading.value" type="submit" class="full-btn">Login</button>
      </form>

      <form v-else class="register-form" @submit.prevent="registerSellerAction">
        <div class="grid-two">
          <input v-model="registerForm.fullName" placeholder="Full Name" required />
          <input v-model="registerForm.email" type="email" placeholder="Email" required />
          <input v-model="registerForm.password" type="password" placeholder="Password" required />
          <input v-model="registerForm.confirmPassword" type="password" placeholder="Confirm Password" required />
          <input v-model="registerForm.businessName" placeholder="Business Name" required />
          <input v-model="registerForm.idNumber" placeholder="National ID" required />
        </div>
        <button :disabled="marketplace.loading.value" type="submit" class="full-btn">Create account</button>
      </form>

      <p v-if="marketplace.error.value" class="error-text">{{ marketplace.error.value }}</p>

      <p class="register-text" v-if="authScreen === 'login'">
        Don’t have an account?
        <button class="link-btn" @click="authScreen = 'register'">Register now</button>
      </p>
      <p class="register-text" v-else>
        Already have an account?
        <button class="link-btn" @click="authScreen = 'login'">Back to login</button>
      </p>
    </div>
  </section>

  <AppShell
    v-else
    :role="marketplace.role.value"
    :active-menu="marketplace.activeMenu.value"
    :menu-items="menuItems"
    :welcome-text="welcomeText"
    :is-dark="isDark"
    :notifications="marketplace.state.value.notifications"
    @menu-change="(menu) => { if (menu === 'logout') { marketplace.logout(); } else { marketplace.activeMenu.value = menu; if (menu === 'products' && !window.location.hash.startsWith('#/products')) goToProductRoute('#/products'); } }"
    @logout="marketplace.logout"
    @theme-toggle="isDark = !isDark"
    @notification-read="marketplace.readNotification"
  >
    <section v-if="marketplace.activeMenu.value === 'overview'">
      <DashboardOverviewPage
        :dashboard-period="dashboardPeriod"
        :dashboard-cards="dashboardCards"
        :chart-points="chartPoints"
        :status-summary="statusSummary"
        :category-summary="categorySummary"
        @change-period="(period) => (dashboardPeriod = period)"
      />
    </section>

    <SectionCard v-if="marketplace.activeMenu.value === 'products'" title="Products Management">
      <ProductManagementPage
        :role="marketplace.role.value"
        :product-error="productError"
        :product-page="productPage"
        :product-route-id="productRouteId"
        :managed-products="managedProducts"
        :selected-product="selectedProduct"
        :product-form="productForm"
        :categories="categories"
        :weight-units="weightUnits"
        @add="openAddProduct"
        @details="openProductDetails"
        @edit="openEditProduct"
        @toggle="toggleProductActive"
        @delete="deleteProductRecord"
        @back="goToProductRoute('#/products')"
        @save="saveProduct"
        @image="onProductImageChange"
      />
    </SectionCard>

    <SectionCard v-if="marketplace.activeMenu.value === 'investors'" title="Investors">
      <InvestorsPage
        :investors="investorRows"
        :selected="selectedInvestor"
        :status-class="statusClass"
        @view="(id) => (selectedInvestorId = id)"
        @toggle="toggleInvestorStatus"
      />
    </SectionCard>

    <SectionCard v-if="marketplace.activeMenu.value === 'requests'" title="Transactions">
      <TransactionsPage
        :items="transactionsView"
        :selected="selectedTransaction"
        :status-draft="transactionStatusDraft"
        :status-class="statusClass"
        @view="viewTransaction"
        @save-status="saveTransactionStatus"
        @update-status="(value) => (transactionStatusDraft = value)"
      />
    </SectionCard>



    <SectionCard v-if="marketplace.activeMenu.value === 'fees'" title="Fees Management">
      <p>Delivery: {{ marketplace.state.value.fees.deliveryFee }}</p>
      <p>Storage: {{ marketplace.state.value.fees.storageFee }}</p>
      <p>Service Charge: {{ marketplace.state.value.fees.serviceChargePercent }}%</p>
    </SectionCard>



    <SectionCard v-if="marketplace.activeMenu.value === 'reports'" title="Reports Generator">
      <ReportsPage
        :report-filters="reportFilters"
        :report-type-cards="reportTypeCards"
        :rows="generatedReports"
        @generate="generateReports"
        @excel="downloadReport"
        @pdf="downloadPdf"
      />
    </SectionCard>


  </AppShell>
</template>
