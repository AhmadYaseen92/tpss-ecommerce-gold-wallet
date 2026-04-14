<script setup lang="ts">
import { computed, reactive, ref, watch } from "vue";
import type { NavigationKey } from "./domain/models";
import AppShell from "./presentation/components/AppShell.vue";
import MetricGrid from "./presentation/components/MetricGrid.vue";
import SectionCard from "./presentation/components/SectionCard.vue";
import { useMarketplace } from "./presentation/composables/useMarketplace";
import {
  createManagedProduct,
  deleteManagedProduct,
  fetchManagedProducts,
  fetchProductCategories,
  fetchWeightUnits,
  updateManagedProduct,
  type ProductFormPayload
} from "./infrastructure/backendMarketplaceGateway";
import type { ProductManagementDto, EnumItemDto } from "./infrastructure/apiTypes";

const marketplace = useMarketplace();
const isDark = ref(false);
const authScreen = ref<"login" | "register">("login");

const loginForm = reactive({
  email: "admin@goldwallet.com",
  password: "P@ssw0rd",
  rememberMe: true
});

const registerForm = reactive({
  firstName: "",
  middleName: "",
  lastName: "",
  email: "",
  password: "",
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
const managedProducts = ref<ProductManagementDto[]>([]);
const categories = ref<EnumItemDto[]>([]);
const weightUnits = ref<EnumItemDto[]>([]);
const selectedProduct = ref<ProductManagementDto | null>(null);
const showProductForm = ref(false);
const isEditMode = ref(false);
const productError = ref("");
const productForm = reactive<ProductFormPayload>({
  name: "",
  sku: "",
  description: "",
  category: 4,
  weightValue: 0,
  weightUnit: 1,
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
  productForm.category = 4;
  productForm.weightValue = 0;
  productForm.weightUnit = 1;
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
    categories.value = await fetchProductCategories(marketplace.session.value.accessToken);
    weightUnits.value = await fetchWeightUnits(marketplace.session.value.accessToken);
  } catch (error) {
    productError.value = error instanceof Error ? error.message : "Failed to load products";
  }
};

watch(
  () => marketplace.session.value?.accessToken,
  () => {
    void loadProductManagementData();
  },
  { immediate: true }
);

const openAddProduct = () => {
  resetProductForm();
  isEditMode.value = false;
  showProductForm.value = true;
};

const openEditProduct = (product: ProductManagementDto) => {
  isEditMode.value = true;
  showProductForm.value = true;
  productForm.id = product.id;
  productForm.name = product.name;
  productForm.sku = product.sku;
  productForm.description = product.description;
  productForm.category = categories.value.find((x) => x.name === product.category)?.value ?? 4;
  productForm.weightValue = Number(product.weightValue);
  productForm.weightUnit = weightUnits.value.find((x) => x.name === product.weightUnit)?.value ?? 1;
  productForm.price = Number(product.price);
  productForm.availableStock = product.availableStock;
  productForm.isActive = product.isActive;
  productForm.existingImageUrl = product.imageUrl;
  productForm.imageFile = null;
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
    if (isEditMode.value && productForm.id) {
      await updateManagedProduct(marketplace.session.value.accessToken, productForm.id, productForm);
    } else {
      await createManagedProduct(marketplace.session.value.accessToken, productForm);
    }

    showProductForm.value = false;
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
    if (selectedProduct.value?.id === productId) selectedProduct.value = null;
  } catch (error) {
    productError.value = error instanceof Error ? error.message : "Failed to delete product";
  }
};


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





const reportTypeCards = [
  { key: "sales", label: "Sales Report", description: "Sales totals by products and users" },
  { key: "inventory", label: "Inventory Report", description: "Stock status and low stock items" },
  { key: "transactions", label: "Transactions Report", description: "Requests and approval activity" },
  { key: "seller", label: "Seller Report", description: "Seller-specific operational summary" }
];

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

      <form v-else class="register-form" @submit.prevent="marketplace.registerSeller(registerForm)">
        <div class="grid-two">
          <input v-model="registerForm.firstName" placeholder="First Name" required />
          <input v-model="registerForm.middleName" placeholder="Middle Name" required />
          <input v-model="registerForm.lastName" placeholder="Last Name" required />
          <input v-model="registerForm.businessName" placeholder="Business Name" required />
          <input v-model="registerForm.email" type="email" placeholder="Email" required />
          <input v-model="registerForm.password" type="password" placeholder="Password" required />
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
    @menu-change="(menu) => (menu === 'logout' ? marketplace.logout() : (marketplace.activeMenu.value = menu))"
    @logout="marketplace.logout"
    @theme-toggle="isDark = !isDark"
    @notification-read="marketplace.readNotification"
  >
    <section v-if="marketplace.activeMenu.value === 'overview'">
      <MetricGrid :metrics="marketplace.overviewCards.value" />
    </section>

    <SectionCard v-if="marketplace.activeMenu.value === 'products'" title="Products Management">
      <template #actions>
        <button v-if="marketplace.role.value === 'seller'" @click="openAddProduct">Add Product</button>
      </template>

      <p v-if="productError" class="error-text">{{ productError }}</p>

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
            <th>Actions</th>
          </tr>
        </thead>
        <tbody>
          <tr
            v-for="product in managedProducts"
            :key="product.id"
            class="clickable-row"
            @click="selectedProduct = product"
          >
            <td>{{ product.id }}</td>
            <td>{{ product.name }}</td>
            <td>{{ product.sku }}</td>
            <td>{{ product.category }}</td>
            <td>{{ product.price }}</td>
            <td>{{ product.availableStock }}</td>
            <td>{{ product.isActive ? 'Yes' : 'No' }}</td>
            <td>
              <button @click.stop="openEditProduct(product)">Edit</button>
              <button class="danger" @click.stop="deleteProductRecord(product.id)">Delete</button>
            </td>
          </tr>
        </tbody>
      </table>

      <div v-if="selectedProduct" class="product-details">
        <h4>Product Details</h4>
        <p><strong>ID:</strong> {{ selectedProduct.id }}</p>
        <p><strong>Name:</strong> {{ selectedProduct.name }}</p>
        <p><strong>SKU:</strong> {{ selectedProduct.sku }}</p>
        <p><strong>Description:</strong> {{ selectedProduct.description }}</p>
        <p><strong>Weight:</strong> {{ selectedProduct.weightValue }} {{ selectedProduct.weightUnit }}</p>
        <p><strong>Image:</strong> <a :href="selectedProduct.imageUrl" target="_blank">Open</a></p>
      </div>

      <div v-if="showProductForm" class="modal-form product-form">
        <h3>{{ isEditMode ? 'Edit Product' : 'Add Product' }}</h3>
        <div class="grid-two">
          <input v-model="productForm.name" placeholder="Name *" required />
          <input v-model="productForm.sku" placeholder="SKU (unique) *" required />
          <input v-model="productForm.description" placeholder="Description *" required />
          <select v-model.number="productForm.category">
            <option v-for="item in categories" :key="item.value" :value="item.value">{{ item.name }}</option>
          </select>
          <input v-model.number="productForm.weightValue" type="number" placeholder="Weight Value *" required />
          <select v-model.number="productForm.weightUnit">
            <option v-for="item in weightUnits" :key="item.value" :value="item.value">{{ item.name }}</option>
          </select>
          <input v-model.number="productForm.price" type="number" placeholder="Price *" required />
          <input v-model.number="productForm.availableStock" type="number" placeholder="Available Stock *" required />
          <label class="checkbox-line">
            <input v-model="productForm.isActive" type="checkbox" /> Active
          </label>
          <input type="file" accept="image/*" @change="onProductImageChange" />
        </div>
        <div class="report-actions">
          <button @click="saveProduct">Save</button>
          <button class="ghost" @click="showProductForm = false">Cancel</button>
        </div>
      </div>
    </SectionCard>

    <SectionCard v-if="marketplace.activeMenu.value === 'investors'" title="Investors">
      <table>
        <thead>
          <tr>
            <th>Name</th>
            <th>Risk</th>
            <th>Wallet</th>
            <th>Status</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="investor in marketplace.state.value.investors" :key="investor.id">
            <td>{{ investor.fullName }}</td>
            <td>{{ investor.riskLevel }}</td>
            <td>{{ investor.walletBalance }}</td>
            <td>{{ investor.status }}</td>
          </tr>
        </tbody>
      </table>
    </SectionCard>

    <SectionCard v-if="marketplace.activeMenu.value === 'requests'" title="Transactions / Requests">
      <table>
        <thead>
          <tr>
            <th>ID</th>
            <th>Type</th>
            <th>Amount</th>
            <th>Status</th>
            <th>Action</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="request in marketplace.state.value.requests" :key="request.id">
            <td>{{ request.id }}</td>
            <td>{{ request.type }}</td>
            <td>{{ request.amount }}</td>
            <td>{{ request.status }}</td>
            <td>
              <button @click="marketplace.updateRequestStatus(request.id, 'approved')">Approve</button>
              <button class="danger" @click="marketplace.updateRequestStatus(request.id, 'rejected')">Reject</button>
            </td>
          </tr>
        </tbody>
      </table>
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
        <button class="ghost" @click="downloadReport">Download CSV</button>
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
