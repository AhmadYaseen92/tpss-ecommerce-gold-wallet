<script setup lang="ts">
import { computed, reactive, ref, watch } from "vue";
import type { NavigationKey } from "./domain/models";
import AppShell from "./presentation/components/AppShell.vue";
import MetricGrid from "./presentation/components/MetricGrid.vue";
import SectionCard from "./presentation/components/SectionCard.vue";
import { useMarketplace } from "./presentation/composables/useMarketplace";

const marketplace = useMarketplace();
const isDark = ref(false);
const showAddProduct = ref(false);
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

const newProduct = reactive({ name: "", category: "Gold Bars", unitPrice: 0, stock: 0 });

watch(isDark, (value) => {
  document.documentElement.classList.toggle("dark-mode", value);
});


const menuItems = computed(() => {
  const common: Array<{ key: NavigationKey; label: string }> = [
    { key: "overview", label: "Dashboard" },
    { key: "products", label: "Products" },
      ];

  if (marketplace.role.value === "admin") {
    return [
      ...common,
      { key: "investors", label: "Investors" },
      { key: "requests", label: "Transactions" },
      { key: "fees", label: "Fees" },
      { key: "reports", label: "Reports" },
      { key: "logout", label: "Logout" }
    ];
  }

  return [...common, { key: "reports", label: "Reports" }, { key: "logout", label: "Logout" }];
});

const welcomeText = computed(() => {
  if (!marketplace.session.value) return "Welcome";
  const fullName = marketplace.state.value.currentUserName ?? (marketplace.role.value === "admin" ? "Admin User" : "Seller User");
  return `Welcome back, ${fullName}`;
});



const productsForRole = computed(() =>
  marketplace.role.value === "seller" ? marketplace.sellerProducts.value : marketplace.state.value.products
);

const submitNewProduct = () => {
  if (!marketplace.activeSeller.value || !newProduct.name || newProduct.unitPrice <= 0) return;

  marketplace.addProduct({
    sellerId: marketplace.activeSeller.value.id,
    name: newProduct.name,
    category: newProduct.category,
    unitPrice: Number(newProduct.unitPrice),
    marketPrice: Number(newProduct.unitPrice),
    stock: Number(newProduct.stock)
  });

  newProduct.name = "";
  newProduct.category = "Gold Bars";
  newProduct.unitPrice = 0;
  newProduct.stock = 0;
  showAddProduct.value = false;
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

    <SectionCard v-if="marketplace.activeMenu.value === 'products'" title="Products">
      <template #actions>
        <button v-if="marketplace.role.value === 'seller'" @click="showAddProduct = true">Add Product</button>
      </template>

      <div v-if="showAddProduct" class="modal-form">
        <h3>New Product</h3>
        <div class="grid-two">
          <input v-model="newProduct.name" placeholder="Product name" />
          <input v-model="newProduct.category" placeholder="Category" />
          <input v-model.number="newProduct.unitPrice" type="number" placeholder="Price" />
          <input v-model.number="newProduct.stock" type="number" placeholder="Stock" />
        </div>
        <div>
          <button @click="submitNewProduct">Save Product</button>
          <button class="ghost" @click="showAddProduct = false">Cancel</button>
        </div>
      </div>

      <table>
        <thead>
          <tr>
            <th>Name</th>
            <th>Category</th>
            <th>Stock</th>
            <th>Price</th>
            <th>Market</th>
            <th>Actions</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="product in productsForRole" :key="product.id">
            <td>{{ product.name }}</td>
            <td>{{ product.category }}</td>
            <td>{{ product.stock }}</td>
            <td>{{ product.unitPrice }}</td>
            <td>{{ product.marketPrice }}</td>
            <td>
              <button @click="marketplace.updateProduct(product.id, { stock: product.stock + 5 })">Update</button>
              <button class="danger" @click="marketplace.deleteProduct(product.id)">Delete</button>
            </td>
          </tr>
        </tbody>
      </table>
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



    <SectionCard v-if="marketplace.activeMenu.value === 'reports'" title="Reports">
      <MetricGrid :metrics="marketplace.adminMetrics.value" />
    </SectionCard>


  </AppShell>
</template>
