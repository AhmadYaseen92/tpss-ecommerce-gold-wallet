<script setup lang="ts">
import { computed, onMounted, onUnmounted, ref, watch } from "vue";
import type { NavigationKey } from "./shared/types/models";
import AppShell from "./shared/layouts/AppShell.vue";
import SectionCard from "./shared/components/SectionCard.vue";
import DashboardOverviewPage from "./features/dashboard/pages/DashboardOverviewPage.vue";
import ProductManagementPage from "./features/products/pages/ProductManagementPage.vue";
import InvestorsPage from "./features/investors/pages/InvestorsPage.vue";
import TransactionsPage from "./features/transactions/pages/TransactionsPage.vue";
import ReportsPage from "./features/reports/pages/ReportsPage.vue";
import { useMarketplace } from "./features/dashboard/store/useMarketplace";
import { useAuthPage } from "./features/auth/store/useAuthPage";
import { useProductManagement } from "./features/products/store/useProductManagement";
import { useDashboard } from "./features/dashboard/store/useDashboard";
import { useInvestors } from "./features/investors/store/useInvestors";
import { useTransactions } from "./features/transactions/store/useTransactions";
import { useReports } from "./features/reports/store/useReports";
import { statusClass } from "./shared/services/statusStyles";

const marketplace = useMarketplace();
const isDark = ref(false);

const { authScreen, loginForm, registerForm, registerSellerAction } = useAuthPage(marketplace);

const {
  managedProducts,
  categories,
  weightUnits,
  selectedProduct,
  productError,
  productPage,
  productRouteId,
  productForm,
  validationErrors,
  syncRoute,
  navigate,
  openAddProduct,
  openEditProduct,
  openProductDetails,
  onProductImageChange,
  saveProduct,
  deleteProductRecord,
  toggleProductActive
} = useProductManagement(marketplace);

const { dashboardPeriod, dashboardCards, chartPoints, statusSummary, categorySummary } = useDashboard(marketplace, managedProducts);
const { selectedInvestorId, investorRows, selectedInvestor, toggleInvestorStatus } = useInvestors(marketplace);
const { selectedTransactionId, transactionStatusDraft, transactionsView, selectedTransaction, viewTransaction, saveTransactionStatus } = useTransactions(marketplace, managedProducts, investorRows);
const { reportFilters, generatedReports, reportTypeCards, generateReports, downloadReport, downloadPdf } = useReports(marketplace);

watch(isDark, (value) => document.documentElement.classList.toggle("dark-mode", value));
watch(managedProducts, () => {
  if (marketplace.activeMenu.value === "products") syncRoute();
});

onMounted(() => {
  syncRoute();
  window.addEventListener("hashchange", syncRoute);
});

onUnmounted(() => {
  window.removeEventListener("hashchange", syncRoute);
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
  return marketplace.role.value === "admin" ? [...common, { key: "fees", label: "Fees" }] : common;
});

const welcomeText = computed(() => {
  if (!marketplace.session.value) return "Welcome";
  const fullName = marketplace.state.value.currentUserName ?? (marketplace.role.value === "admin" ? "Admin User" : "Seller User");
  return `Welcome back, ${fullName}`;
});
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
    @menu-change="(menu) => { if (menu === 'logout') { marketplace.logout(); } else { marketplace.activeMenu.value = menu; if (menu === 'products' && !window.location.hash.startsWith('#/products')) navigate('#/products'); } }"
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
        :validation-errors="validationErrors"
        @add="openAddProduct"
        @details="openProductDetails"
        @edit="openEditProduct"
        @toggle="toggleProductActive"
        @delete="deleteProductRecord"
        @back="navigate('#/products')"
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
