<script setup lang="ts">
import { computed, reactive } from "vue";
import type { NavigationKey, UserRole } from "./domain/models";
import AppShell from "./presentation/components/AppShell.vue";
import MetricGrid from "./presentation/components/MetricGrid.vue";
import SectionCard from "./presentation/components/SectionCard.vue";
import { useMarketplace } from "./presentation/composables/useMarketplace";

const marketplace = useMarketplace();

const loginForm = reactive({ email: "admin@goldwallet.com", password: "P@ssw0rd" });
const registerForm = reactive({
  firstName: "",
  middleName: "",
  lastName: "",
  email: "",
  password: "",
  businessName: "",
  idNumber: ""
});

const feeForm = reactive({
  deliveryFee: 12,
  storageFee: 4,
  serviceChargePercent: 2.5
});

const invoiceForm = reactive({ investorName: "", totalAmount: 0 });

const menuItems = computed(() => [
  { key: "overview", label: "Overview" },
  { key: "investors", label: "Investors" },
  { key: "requests", label: "Transactions / Requests" },
  { key: "products", label: "Products" },
  { key: "invoices", label: "Invoices" },
  { key: "fees", label: "Fees" },
  { key: "inventory", label: "Inventory" },
  { key: "reports", label: "Reports" },
  { key: "notifications", label: "Notifications" }
] as Array<{ key: NavigationKey; label: string }>);

const inventorySummary = computed(() => {
  const totalStock = marketplace.state.value.products.reduce((sum, product) => sum + product.stock, 0);
  const lowStock = marketplace.state.value.products.filter((product) => product.stock < 20).length;
  return { totalStock, lowStock };
});

const onRoleChange = (role: UserRole) => {
  marketplace.role.value = role;
};

const addProduct = () => {
  if (!marketplace.activeSeller.value) return;

  marketplace.addProduct({
    sellerId: marketplace.activeSeller.value.id,
    name: `New Product ${marketplace.state.value.products.length + 1}`,
    category: "Gold",
    unitPrice: 100,
    marketPrice: 110,
    stock: 20
  });
};

const saveInvoice = () => {
  if (!marketplace.activeSeller.value || !invoiceForm.investorName || !invoiceForm.totalAmount) return;

  marketplace.saveInvoice({
    id: `inv-${Date.now()}`,
    sellerId: marketplace.activeSeller.value.id,
    investorName: invoiceForm.investorName,
    totalAmount: Number(invoiceForm.totalAmount),
    issuedAt: new Date().toISOString().split("T")[0],
    status: "sent"
  });

  invoiceForm.investorName = "";
  invoiceForm.totalAmount = 0;
};
</script>

<template>
  <AppShell
    :role="marketplace.role.value"
    :active-menu="marketplace.activeMenu.value"
    :menu-items="menuItems"
    @role-change="onRoleChange"
    @menu-change="(menu) => (marketplace.activeMenu.value = menu)"
  >
    <section class="hero-card">
      <div>
        <h2>Modern Gold Wallet Operations</h2>
        <p>Unified dashboard for investor operations, seller products, fees, reports, inventory and notifications.</p>
      </div>
      <button v-if="marketplace.session.value" @click="marketplace.logout">Logout</button>
    </section>

    <section class="section-card">
      <header>
        <h2>Backend Authentication</h2>
      </header>

      <p v-if="!marketplace.session.value">Login for live backend summary and role-based control.</p>
      <p v-else>
        Connected as #{{ marketplace.session.value.userId }} ({{ marketplace.session.value.role }})
      </p>

      <p v-if="marketplace.error.value" class="error-text">{{ marketplace.error.value }}</p>

      <div class="grid-two" v-if="!marketplace.session.value">
        <form @submit.prevent="marketplace.login(loginForm)">
          <h3>Login</h3>
          <input v-model="loginForm.email" type="email" placeholder="Email" required />
          <input v-model="loginForm.password" type="password" placeholder="Password" required />
          <button :disabled="marketplace.loading.value" type="submit">Login & Sync</button>
        </form>

        <form @submit.prevent="marketplace.registerSeller(registerForm)">
          <h3>Seller Registration with KYC</h3>
          <input v-model="registerForm.firstName" placeholder="First Name" required />
          <input v-model="registerForm.middleName" placeholder="Middle Name" required />
          <input v-model="registerForm.lastName" placeholder="Last Name" required />
          <input v-model="registerForm.businessName" placeholder="Business Name" required />
          <input v-model="registerForm.email" type="email" placeholder="Email" required />
          <input v-model="registerForm.password" type="password" placeholder="Password" required />
          <input v-model="registerForm.idNumber" placeholder="National ID" required />
          <button :disabled="marketplace.loading.value" type="submit">Register Seller</button>
        </form>
      </div>
    </section>

    <section v-if="marketplace.activeMenu.value === 'overview'">
      <MetricGrid :metrics="marketplace.overviewCards.value" />
    </section>

    <SectionCard v-if="marketplace.activeMenu.value === 'investors'" title="Investors Monitoring & Management">
      <table>
        <thead>
          <tr>
            <th>Name</th>
            <th>Risk</th>
            <th>Wallet</th>
            <th>Status</th>
            <th>Action</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="investor in marketplace.state.value.investors" :key="investor.id">
            <td>{{ investor.fullName }}</td>
            <td>{{ investor.riskLevel }}</td>
            <td>{{ investor.walletBalance.toFixed(2) }}</td>
            <td>{{ investor.status }}</td>
            <td>
              <button @click="marketplace.updateInvestorStatus(investor.id, 'active')">Activate</button>
              <button class="danger" @click="marketplace.updateInvestorStatus(investor.id, 'blocked')">Block</button>
            </td>
          </tr>
        </tbody>
      </table>
    </SectionCard>

    <SectionCard v-if="marketplace.activeMenu.value === 'requests'" title="Investor Transactions / Requests">
      <table>
        <thead>
          <tr>
            <th>ID</th>
            <th>Investor</th>
            <th>Type</th>
            <th>Amount</th>
            <th>Status</th>
            <th>Action</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="request in marketplace.state.value.requests" :key="request.id">
            <td>{{ request.id }}</td>
            <td>{{ request.investorId }}</td>
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

    <SectionCard v-if="marketplace.activeMenu.value === 'products'" title="Seller Products Management">
      <template #actions>
        <button @click="addProduct">Add Product</button>
      </template>
      <table>
        <thead>
          <tr>
            <th>Name</th>
            <th>Stock</th>
            <th>Price</th>
            <th>Market</th>
            <th>Action</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="product in marketplace.sellerProducts.value" :key="product.id">
            <td>{{ product.name }}</td>
            <td>{{ product.stock }}</td>
            <td>{{ product.unitPrice }}</td>
            <td>{{ product.marketPrice }}</td>
            <td>
              <button @click="marketplace.setMarketPrice(product.id, product.marketPrice + 5)">Update Price</button>
              <button class="danger" @click="marketplace.deleteProduct(product.id)">Delete</button>
            </td>
          </tr>
        </tbody>
      </table>
    </SectionCard>

    <SectionCard v-if="marketplace.activeMenu.value === 'invoices'" title="Seller Invoices CRUD">
      <div class="inline-form">
        <input v-model="invoiceForm.investorName" placeholder="Investor Name" />
        <input v-model.number="invoiceForm.totalAmount" type="number" placeholder="Amount" />
        <button @click="saveInvoice">Add Invoice</button>
      </div>

      <table>
        <thead>
          <tr>
            <th>ID</th>
            <th>Investor</th>
            <th>Total</th>
            <th>Status</th>
            <th>Action</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="invoice in marketplace.state.value.invoices" :key="invoice.id">
            <td>{{ invoice.id }}</td>
            <td>{{ invoice.investorName }}</td>
            <td>{{ invoice.totalAmount }}</td>
            <td>{{ invoice.status }}</td>
            <td>
              <button @click="marketplace.saveInvoice({ ...invoice, status: 'paid' })">Mark Paid</button>
              <button class="danger" @click="marketplace.removeInvoice(invoice.id)">Delete</button>
            </td>
          </tr>
        </tbody>
      </table>
    </SectionCard>

    <SectionCard v-if="marketplace.activeMenu.value === 'fees'" title="Manage Fees">
      <div class="fee-grid">
        <label>
          Delivery
          <input v-model.number="feeForm.deliveryFee" type="number" />
        </label>
        <label>
          Storage
          <input v-model.number="feeForm.storageFee" type="number" />
        </label>
        <label>
          Service Charge %
          <input v-model.number="feeForm.serviceChargePercent" type="number" />
        </label>
      </div>
      <button @click="marketplace.updateFees(feeForm.deliveryFee, feeForm.storageFee, feeForm.serviceChargePercent)">Save Fees</button>
    </SectionCard>

    <SectionCard v-if="marketplace.activeMenu.value === 'inventory'" title="Inventory / Stock Availability">
      <p>Total Stock: {{ inventorySummary.totalStock }}</p>
      <p>Low Stock Products (&lt; 20): {{ inventorySummary.lowStock }}</p>
    </SectionCard>

    <SectionCard v-if="marketplace.activeMenu.value === 'reports'" title="Reports">
      <MetricGrid :metrics="marketplace.adminMetrics.value" />
      <p>Generate daily, weekly, and monthly operational reports.</p>
    </SectionCard>

    <SectionCard v-if="marketplace.activeMenu.value === 'notifications'" title="Notifications Center">
      <ul class="notification-list">
        <li v-for="notice in marketplace.state.value.notifications" :key="notice.id">
          <strong>{{ notice.title }}</strong>
          <p>{{ notice.message }}</p>
          <small>{{ notice.createdAt }} - {{ notice.severity }}</small>
          <button @click="marketplace.readNotification(notice.id)">Mark as read</button>
        </li>
      </ul>
    </SectionCard>
  </AppShell>
</template>
