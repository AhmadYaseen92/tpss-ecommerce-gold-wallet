<script setup lang="ts">
import { computed, onMounted, onUnmounted, reactive, ref, watch } from "vue";
import type { NavigationKey } from "./shared/types/models";
import AppShell from "./shared/layouts/AppShell.vue";
import MetricGrid from "./shared/components/MetricGrid.vue";
import SectionCard from "./shared/components/SectionCard.vue";
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
      <SectionCard title="Dashboard Filters">
        <div class="report-actions">
          <button :class="{ ghost: dashboardPeriod !== 'today' }" @click="dashboardPeriod = 'today'">Today</button>
          <button :class="{ ghost: dashboardPeriod !== 'week' }" @click="dashboardPeriod = 'week'">Week</button>
          <button :class="{ ghost: dashboardPeriod !== 'month' }" @click="dashboardPeriod = 'month'">Month</button>
        </div>
      </SectionCard>
      <MetricGrid :metrics="dashboardCards" />
      <SectionCard title="Transactions Trend (Line)">
        <div class="chart-line">
          <div v-for="point in chartPoints" :key="`tx-${point.x}`" class="line-point" :style="{ height: `${point.transactions * 2}px` }"></div>
        </div>
      </SectionCard>
      <SectionCard title="Sales Trend (Line)">
        <div class="chart-line">
          <div v-for="point in chartPoints" :key="`sales-${point.x}`" class="line-point gold" :style="{ height: `${point.sales / 20}px` }"></div>
        </div>
      </SectionCard>
      <SectionCard title="Transactions by Status (Bar)">
        <div class="chart-bars">
          <div class="bar pending" :style="{ height: `${statusSummary.pending * 30 + 20}px` }">Pending {{ statusSummary.pending }}</div>
          <div class="bar approved" :style="{ height: `${statusSummary.approved * 30 + 20}px` }">Approved {{ statusSummary.approved }}</div>
          <div class="bar rejected" :style="{ height: `${statusSummary.rejected * 30 + 20}px` }">Rejected {{ statusSummary.rejected }}</div>
        </div>
      </SectionCard>
      <SectionCard title="Products by Category (Bar)">
        <div class="chart-bars">
          <div v-for="item in categorySummary" :key="item.category" class="bar gold" :style="{ height: `${item.count * 28 + 20}px` }">
            {{ item.category }} ({{ item.count }})
          </div>
        </div>
      </SectionCard>
    </section>

    <SectionCard v-if="marketplace.activeMenu.value === 'products'" title="Products Management">
      <template #actions>
        <button v-if="marketplace.role.value === 'seller'" @click="openAddProduct">Add Product</button>
      </template>

      <p v-if="productError" class="error-text">{{ productError }}</p>

      <div v-if="productPage === 'list'">
        <table>
          <thead>
            <tr>
              <th>ID</th>
              <th>Name</th>
              <th>SKU</th>
              <th>Category</th>
              <th>Price</th>
              <th>Stock</th>
              <th>Active</th>
              <th>CreatedAtUtc</th>
              <th>UpdatedAtUtc</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            <tr
              v-for="product in managedProducts"
              :key="product.id"
              class="clickable-row"
              @click="openProductDetails(product)"
            >
              <td>{{ product.id }}</td>
              <td>{{ product.name }}</td>
              <td>{{ product.sku }}</td>
              <td>{{ product.category }}</td>
              <td>{{ product.price }}</td>
              <td>{{ product.availableStock }}</td>
              <td>{{ product.isActive ? 'Yes' : 'No' }}</td>
              <td>{{ "-" }}</td>
              <td>{{ "-" }}</td>
              <td>
                <button @click.stop="openEditProduct(product)">Edit</button>
                <button class="ghost" @click.stop="toggleProductActive(product)">{{ product.isActive ? "Deactivate" : "Activate" }}</button>
                <button class="danger" @click.stop="deleteProductRecord(product.id)">Delete</button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>

      <div v-else-if="productPage === 'details'" class="product-details">
        <h4>Product Details #{{ selectedProduct?.id ?? productRouteId }}</h4>
        <p v-if="!selectedProduct">Unable to load this product. Please return to list.</p>
        <template v-else>
          <p><strong>Name:</strong> {{ selectedProduct.name }}</p>
          <p><strong>SKU:</strong> {{ selectedProduct.sku }}</p>
          <p><strong>Description:</strong> {{ selectedProduct.description }}</p>
          <p><strong>Category:</strong> {{ selectedProduct.category }}</p>
          <p><strong>Weight:</strong> {{ selectedProduct.weightValue }} {{ selectedProduct.weightUnit }}</p>
          <p><strong>Price:</strong> {{ selectedProduct.price }}</p>
          <p><strong>Available Stock:</strong> {{ selectedProduct.availableStock }}</p>
          <p><strong>Status:</strong> {{ selectedProduct.isActive ? 'Active' : 'Inactive' }}</p>
          <p><strong>Image:</strong> <a :href="selectedProduct.imageUrl" target="_blank">Open image</a></p>
        </template>
        <div class="report-actions">
          <button class="ghost" @click="goToProductRoute('#/products')">Back to list</button>
          <button v-if="selectedProduct" @click="openEditProduct(selectedProduct)">Edit Product</button>
        </div>
      </div>

      <div v-else class="modal-form product-form vertical-form product-form-contrast">
        <h3>{{ productPage === 'edit' ? 'Edit Product' : 'Add Product' }}</h3>
        <p class="hint-text">Important fields first. Every row has 2 fields.</p>

        <div class="grid-two form-grid-two">
          <label>
            <span>Product Name *</span>
            <input v-model="productForm.name" placeholder="e.g. 24K Gold Bar - 10g" required />
            <small>Customer-facing name for listings and reports.</small>
          </label>

          <label>
            <span>SKU (Unique) *</span>
            <input v-model="productForm.sku" placeholder="e.g. GB-10G-24K" required />
            <small>Internal stock keeping unit; cannot be duplicated.</small>
          </label>

          <label>
            <span>Product Image</span>
            <input type="file" accept="image/*" @change="onProductImageChange" />
            <small>Upload JPG/PNG image for display in product details.</small>
          </label>

          <label>
            <span>Price *</span>
            <input v-model.number="productForm.price" type="number" min="0.01" step="0.01" placeholder="e.g. 250.00" required />
            <small>Selling price in system currency.</small>
          </label>

          <label>
            <span>Category *</span>
            <select v-model.number="productForm.category">
              <option disabled :value="0">{{ categories.length ? 'Select category' : 'Loading categories...' }}</option>
              <option v-for="item in categories" :key="item.value" :value="item.value">{{ item.name }}</option>
            </select>
            <small>Dropdown values are loaded from backend (with fallback values if unavailable).</small>
          </label>

          <label>
            <span>Available Stock *</span>
            <input v-model.number="productForm.availableStock" type="number" min="0" step="1" placeholder="e.g. 50" required />
            <small>Current quantity ready for sale.</small>
          </label>

          <label>
            <span>Weight Value *</span>
            <input v-model.number="productForm.weightValue" type="number" min="0.01" step="0.01" placeholder="e.g. 10" required />
            <small>Numeric weight amount before unit.</small>
          </label>

          <label>
            <span>Weight Unit *</span>
            <select v-model.number="productForm.weightUnit">
              <option disabled :value="0">{{ weightUnits.length ? 'Select unit' : 'Loading units...' }}</option>
              <option v-for="item in weightUnits" :key="item.value" :value="item.value">{{ item.name }}</option>
            </select>
            <small>Unit dropdown values come from backend (or fallback values).</small>
          </label>

          <label class="field-full">
            <span>Description *</span>
            <input v-model="productForm.description" placeholder="Short details about purity, origin, and packaging" required />
            <small>Describe the product details that buyers need.</small>
          </label>

          <div class="form-toggle-row field-full">
            <span class="status-label">Product Status</span>
            <label class="normal-toggle" aria-label="Product status toggle">
              <span class="toggle-state">{{ productForm.isActive ? 'ON' : 'OFF' }}</span>
              <input v-model="productForm.isActive" type="checkbox" />
              <span class="slider"></span>
            </label>
          </div>
        </div>

        <div class="report-actions">
          <button @click="saveProduct">Save</button>
          <button class="ghost" @click="goToProductRoute('#/products')">Cancel</button>
        </div>
      </div>
    </SectionCard>

    <SectionCard v-if="marketplace.activeMenu.value === 'investors'" title="Investors">
      <table>
        <thead>
          <tr>
            <th>Name</th>
            <th>Email</th>
            <th>Status</th>
            <th>Total Transactions</th>
            <th>Created Date</th>
            <th>Actions</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="investor in investorRows" :key="investor.id">
            <td>{{ investor.fullName }}</td>
            <td>{{ investor.email }}</td>
            <td><span :class="statusClass(investor.status)">{{ investor.status }}</span></td>
            <td>{{ investor.totalTransactions }}</td>
            <td>{{ investor.createdDate }}</td>
            <td>
              <button @click="selectedInvestorId = investor.id">View</button>
              <button class="ghost" @click="toggleInvestorStatus(investor.id)">{{ investor.status === 'active' ? 'Deactivate' : 'Activate' }}</button>
            </td>
          </tr>
        </tbody>
      </table>

      <div v-if="selectedInvestor" class="product-details">
        <h4>Investor Details</h4>
        <p><strong>Name:</strong> {{ selectedInvestor.fullName }}</p>
        <p><strong>Email:</strong> {{ selectedInvestor.email }}</p>
        <p><strong>Status:</strong> <span :class="statusClass(selectedInvestor.status)">{{ selectedInvestor.status }}</span></p>
        <p><strong>Total Transactions:</strong> {{ selectedInvestor.totalTransactions }}</p>
        <p><strong>Total Purchases:</strong> {{ selectedInvestor.totalPurchases }}</p>
        <p><strong>Last Transaction Date:</strong> {{ selectedInvestor.lastTransactionDate }}</p>
      </div>
    </SectionCard>

    <SectionCard v-if="marketplace.activeMenu.value === 'requests'" title="Transactions">
      <table>
        <thead>
          <tr>
            <th>Transaction ID</th>
            <th>Investor</th>
            <th>Product</th>
            <th>Transaction Type</th>
            <th>Amount</th>
            <th>Status</th>
            <th>Date</th>
            <th>Actions</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="trx in transactionsView" :key="trx.id">
            <td>{{ trx.id }}</td>
            <td>{{ trx.investorName }}</td>
            <td>{{ trx.productName }}</td>
            <td>{{ trx.transactionType }}</td>
            <td>{{ trx.amount }}</td>
            <td><span :class="statusClass(trx.status)">{{ trx.status }}</span></td>
            <td>{{ trx.createdAt }}</td>
            <td>
              <button @click="viewTransaction(trx.id)">View</button>
              <button class="ghost" @click="viewTransaction(trx.id)">Change Status</button>
            </td>
          </tr>
        </tbody>
      </table>

      <div v-if="selectedTransaction" class="product-details">
        <h4>Transaction View Details</h4>
        <p><strong>Transaction ID:</strong> {{ selectedTransaction.id }}</p>
        <p><strong>Investor Info:</strong> {{ selectedTransaction.investorName }}</p>
        <p><strong>Product Info:</strong> {{ selectedTransaction.productName }}</p>
        <p><strong>Transaction Type:</strong> {{ selectedTransaction.transactionType }}</p>
        <p><strong>Amount:</strong> {{ selectedTransaction.amount }}</p>
        <p><strong>Price (at transaction time):</strong> {{ selectedTransaction.transactionPrice }}</p>
        <p><strong>Status:</strong> <span :class="statusClass(selectedTransaction.status)">{{ selectedTransaction.status }}</span></p>
        <p><strong>Date:</strong> {{ selectedTransaction.createdAt }}</p>

        <div class="grid-two">
          <label>
            <span>Change Transaction Status</span>
            <select v-model="transactionStatusDraft">
              <option value="pending">Pending</option>
              <option value="approved">Approved</option>
              <option value="rejected">Rejected</option>
            </select>
          </label>
        </div>
        <button @click="saveTransactionStatus">Save</button>
      </div>
    </SectionCard>



    <SectionCard v-if="marketplace.activeMenu.value === 'fees'" title="Fees Management">
      <p>Delivery: {{ marketplace.state.value.fees.deliveryFee }}</p>
      <p>Storage: {{ marketplace.state.value.fees.storageFee }}</p>
      <p>Service Charge: {{ marketplace.state.value.fees.serviceChargePercent }}%</p>
    </SectionCard>



    <SectionCard v-if="marketplace.activeMenu.value === 'reports'" title="Reports Generator">
      <div class="report-type-grid">
        <button
          v-for="card in reportTypeCards"
          :key="card.key"
          class="report-type-card"
          :class="{ active: reportFilters.reportType === card.key }"
          @click="reportFilters.reportType = card.key"
        >
          <strong>{{ card.label }}</strong>
          <small>{{ card.description }}</small>
        </button>
      </div>

      <div class="grid-two report-filters">
        <input v-model="reportFilters.userId" placeholder="User ID" />
        <input v-model="reportFilters.userName" placeholder="User Name" />
        <input v-model="reportFilters.productName" placeholder="Product Name" />
        <select v-model="reportFilters.dateRange">
          <option value="today">Today</option>
          <option value="last3days">Last 3 days</option>
          <option value="lastWeek">Last week</option>
          <option value="month">Month</option>
          <option value="custom">Custom</option>
        </select>
        <input v-if="reportFilters.dateRange === 'custom'" v-model="reportFilters.customFrom" type="date" />
        <input v-if="reportFilters.dateRange === 'custom'" v-model="reportFilters.customTo" type="date" />
        <label class="checkbox-line">
          <input v-model="reportFilters.stockOnly" type="checkbox" /> In stock only
        </label>
      </div>

      <div class="report-actions">
        <button @click="generateReports">Generate Report</button>
        <button class="ghost" @click="downloadReport">Download Excel</button>
        <button class="ghost" @click="downloadPdf">Download PDF</button>
      </div>

      <table v-if="generatedReports.length > 0">
        <thead>
          <tr>
            <th>Type</th>
            <th>User ID</th>
            <th>User Name</th>
            <th>Product</th>
            <th>Stock</th>
            <th>Price</th>
            <th>Date Range</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="(row, index) in generatedReports" :key="index">
            <td>{{ row.type }}</td>
            <td>{{ row.userId }}</td>
            <td>{{ row.userName }}</td>
            <td>{{ row.productName }}</td>
            <td>{{ row.stock }}</td>
            <td>{{ row.unitPrice }}</td>
            <td>{{ row.dateRange }}</td>
          </tr>
        </tbody>
      </table>
    </SectionCard>


  </AppShell>
</template>
