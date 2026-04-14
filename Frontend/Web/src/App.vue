<script setup lang="ts">
import { computed, ref, watch } from "vue";
import type { NavigationKey } from "./shared/types/models";
import AppShell from "./shared/layouts/AppShell.vue";
import SectionCard from "./shared/components/SectionCard.vue";
import AuthPage from "./features/auth/pages/AuthPage.vue";
import DashboardFeaturePage from "./features/dashboard/pages/DashboardFeaturePage.vue";
import ProductFeaturePage from "./features/products/pages/ProductFeaturePage.vue";
import InvestorsFeaturePage from "./features/investors/pages/InvestorsFeaturePage.vue";
import TransactionsFeaturePage from "./features/transactions/pages/TransactionsFeaturePage.vue";
import ReportsFeaturePage from "./features/reports/pages/ReportsFeaturePage.vue";
import { useMarketplace } from "./features/dashboard/store/useMarketplace";

const marketplace = useMarketplace();
const isDark = ref(false);

watch(isDark, (value) => document.documentElement.classList.toggle("dark-mode", value));

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
  <AuthPage v-if="!marketplace.session.value" :marketplace="marketplace" />

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
      <DashboardFeaturePage :marketplace="marketplace" />
    </section>

    <SectionCard v-if="marketplace.activeMenu.value === 'products'" title="Products Management">
      <ProductFeaturePage :marketplace="marketplace" />
    </SectionCard>

    <SectionCard v-if="marketplace.activeMenu.value === 'investors'" title="Investors">
      <InvestorsFeaturePage :marketplace="marketplace" />
    </SectionCard>

    <SectionCard v-if="marketplace.activeMenu.value === 'requests'" title="Transactions">
      <TransactionsFeaturePage :marketplace="marketplace" />
    </SectionCard>

    <SectionCard v-if="marketplace.activeMenu.value === 'fees'" title="Fees Management">
      <p>Delivery: {{ marketplace.state.value.fees.deliveryFee }}</p>
      <p>Storage: {{ marketplace.state.value.fees.storageFee }}</p>
      <p>Service Charge: {{ marketplace.state.value.fees.serviceChargePercent }}%</p>
    </SectionCard>

    <SectionCard v-if="marketplace.activeMenu.value === 'reports'" title="Reports Generator">
      <ReportsFeaturePage :marketplace="marketplace" />
    </SectionCard>
  </AppShell>
</template>
