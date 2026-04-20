<script setup lang="ts">
import { computed, onMounted, onUnmounted, ref, watch } from "vue";
import type { NavigationKey } from "./shared/types/models";
import AppShell from "./shared/layouts/AppShell.vue";
import AuthPage from "./features/auth/pages/AuthPage.vue";
import DashboardFeaturePage from "./features/dashboard/pages/DashboardFeaturePage.vue";
import AdminWorkspacePage from "./features/dashboard/pages/AdminWorkspacePage.vue";
import ProductFeaturePage from "./features/products/pages/ProductFeaturePage.vue";
import InvestorsFeaturePage from "./features/investors/pages/InvestorsFeaturePage.vue";
import SellersFeaturePage from "./features/dashboard/pages/SellersFeaturePage.vue";
import SettingsFeaturePage from "./features/dashboard/pages/SettingsFeaturePage.vue";
import TransactionsFeaturePage from "./features/transactions/pages/TransactionsFeaturePage.vue";
import ReportsFeaturePage from "./features/reports/pages/ReportsFeaturePage.vue";
import FeesFeaturePage from "./features/fees/pages/FeesFeaturePage.vue";
import { useMarketplace } from "./shared/app/store/useMarketplace";

const marketplace = useMarketplace();
const isDark = ref(false);
const THEME_KEY = "goldwallet.web.theme";

const ROUTE_BY_MENU: Record<Exclude<NavigationKey, "logout" | "invoices" | "inventory" | "notifications">, string> = {
  overview: "/overview",
  admin: "/admin",
  products: "/products",
  investors: "/investors",
  sellers: "/sellers",
  settings: "/settings",
  requests: "/transactions",
  fees: "/fees",
  reports: "/reports"
};

const readHashPath = () => {
  const value = window.location.hash.replace(/^#/, "");
  if (!value) return "/overview";
  return value.startsWith("/") ? value : "/overview";
};

const currentPath = ref("/overview");
const syncHashPath = () => {
  currentPath.value = readHashPath();
};

onMounted(() => {
  void marketplace.restoreSession();
  isDark.value = window.localStorage.getItem(THEME_KEY) === "dark";
  syncHashPath();
  window.addEventListener("hashchange", syncHashPath);
});

onUnmounted(() => {
  window.removeEventListener("hashchange", syncHashPath);
});

watch(isDark, (value) => {
  document.documentElement.classList.toggle("dark-mode", value);
  window.localStorage.setItem(THEME_KEY, value ? "dark" : "light");
});

const menuItems = computed<Array<{ key: NavigationKey; label: string }>>(() => {
  const common: Array<{ key: NavigationKey; label: string }> = [
    { key: "overview", label: "Dashboard" },
    { key: "products", label: "Products" },
    { key: "requests", label: "Transactions" },
    { key: "reports", label: "Reports" },
    { key: "logout", label: "Logout" }
  ];

  return marketplace.role.value === "admin"
    ? [{ key: "admin" as NavigationKey, label: "Admin" }, ...common.slice(0, 2), { key: "investors" as NavigationKey, label: "Investors" }, { key: "sellers" as NavigationKey, label: "Sellers" }, { key: "settings" as NavigationKey, label: "System Settings" }, ...common.slice(2), { key: "fees" as NavigationKey, label: "Fees" }]
    : common;
});

const activeMenu = computed<NavigationKey>(() => {
  if (currentPath.value.startsWith("/admin")) return "admin";
  if (currentPath.value.startsWith("/products")) return "products";
  if (currentPath.value.startsWith("/investors")) return "investors";
  if (currentPath.value.startsWith("/sellers")) return "sellers";
  if (currentPath.value.startsWith("/settings")) return "settings";
  if (currentPath.value.startsWith("/transactions")) return "requests";
  if (currentPath.value.startsWith("/fees")) return "fees";
  if (currentPath.value.startsWith("/reports")) return "reports";
  return "overview";
});

watch(activeMenu, (menu) => {
  marketplace.activeMenu.value = menu;
}, { immediate: true });

const activeComponent = computed(() => {
  if (currentPath.value.startsWith("/admin")) return marketplace.role.value === "admin" ? AdminWorkspacePage : DashboardFeaturePage;
  if (currentPath.value.startsWith("/products")) return ProductFeaturePage;
  if (currentPath.value.startsWith("/investors")) return marketplace.role.value === "admin" ? InvestorsFeaturePage : DashboardFeaturePage;
  if (currentPath.value.startsWith("/sellers")) return marketplace.role.value === "admin" ? SellersFeaturePage : DashboardFeaturePage;
  if (currentPath.value.startsWith("/settings")) return marketplace.role.value === "admin" ? SettingsFeaturePage : DashboardFeaturePage;
  if (currentPath.value.startsWith("/transactions")) return TransactionsFeaturePage;
  if (currentPath.value.startsWith("/fees")) return FeesFeaturePage;
  if (currentPath.value.startsWith("/reports")) return ReportsFeaturePage;
  return DashboardFeaturePage;
});

const welcomeText = computed(() => {
  if (!marketplace.session.value) return "Welcome";
  const fullName = marketplace.state.value.currentUserName ?? (marketplace.role.value === "admin" ? "Admin User" : "Seller User");
  return `Welcome back, ${fullName}`;
});

const handleMenuChange = (menu: NavigationKey) => {
  if (menu === "logout") {
    marketplace.logout();
    window.location.hash = "#/overview";
    syncHashPath();
    return;
  }

  const target = ROUTE_BY_MENU[menu as keyof typeof ROUTE_BY_MENU];
  if (target) {
    window.location.hash = `#${target}`;
    syncHashPath();
  }
};

const handleLogout = () => {
  marketplace.logout();
  window.location.hash = "#/overview";
  syncHashPath();
};
</script>

<template>
  <AuthPage v-if="!marketplace.session.value" :marketplace="marketplace" />

  <AppShell
    v-else
    :role="marketplace.role.value"
    :active-menu="activeMenu"
    :menu-items="menuItems"
    :welcome-text="welcomeText"
    :is-dark="isDark"
    :notifications="marketplace.state.value.notifications"
    @menu-change="handleMenuChange"
    @logout="handleLogout"
    @theme-toggle="isDark = !isDark"
    @notification-read="marketplace.readNotification"
  >
    <component :is="activeComponent" :marketplace="marketplace" />
  </AppShell>
</template>
