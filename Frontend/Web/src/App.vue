<script setup lang="ts">
import { computed, onMounted, onUnmounted, ref, watch } from "vue";
import type { NavigationKey } from "./shared/types/models";
import AppLayout from "./shared/components/ui/AppLayout.vue";
import AuthPage from "./features/auth/pages/AuthPage.vue";
import DashboardFeaturePage from "./features/dashboard/pages/DashboardFeaturePage.vue";
import ProductFeaturePage from "./features/products/pages/ProductFeaturePage.vue";
import InvestorsFeaturePage from "./features/investors/pages/InvestorsFeaturePage.vue";
import SellersFeaturePage from "./features/dashboard/pages/SellersFeaturePage.vue";
import SellerDetailsPage from "./features/dashboard/pages/SellerDetailsPage.vue";
import SettingsFeaturePage from "./features/dashboard/pages/SettingsFeaturePage.vue";
import TransactionsFeaturePage from "./features/transactions/pages/TransactionsFeaturePage.vue";
import ReportsFeaturePage from "./features/reports/pages/ReportsFeaturePage.vue";
import FeeManagementFeaturePage from "./features/fees/pages/FeeManagementFeaturePage.vue";
import { useMarketplace } from "./shared/app/store/useMarketplace";

const marketplace = useMarketplace();

const THEME_KEY = "goldwallet.web.theme";
const isDark = ref(window.localStorage.getItem(THEME_KEY) === "dark");

const ROUTE_BY_MENU: Partial<Record<NavigationKey, string>> = {
  overview: "/overview",
  products: "/products",
  investors: "/investors",
  sellers: "/sellers",
  settings: "/settings",
  requests: "/transactions",
  reports: "/reports",
  fees: "/fees",
};

const applyTheme = (dark: boolean) => {
  document.documentElement.classList.toggle("dark-mode", dark);
  document.documentElement.setAttribute("data-theme", dark ? "dark" : "light");
  window.localStorage.setItem(THEME_KEY, dark ? "dark" : "light");
};

applyTheme(isDark.value);

const readPath = () => {
  const value = window.location.pathname;

  if (!value || value === "/" || value === "/Login" || value === "/Register") {
    return "/overview";
  }

  return value.startsWith("/") ? value : "/overview";
};

const currentPath = ref("/overview");

const syncPath = () => {
  currentPath.value = readPath();
};

onMounted(() => {
  void marketplace.restoreSession();
  syncPath();
  window.addEventListener("popstate", syncPath);
});

onUnmounted(() => {
  window.removeEventListener("popstate", syncPath);
});

watch(isDark, (value) => {
  applyTheme(value);
});

const menuItems = computed<Array<{ key: NavigationKey; label: string }>>(() => {
  const common: Array<{ key: NavigationKey; label: string }> = [
    { key: "overview", label: "Dashboard" },
    { key: "products", label: "Products" },
    { key: "fees" as NavigationKey, label: "Fees" },
    { key: "requests", label: "Transactions" },
    { key: "reports", label: "Reports" },
    { key: "logout", label: "Logout" },
  ];

  if (marketplace.role.value === "Admin") {
    return [
      common[0],
      common[1],
      { key: "investors" as NavigationKey, label: "Investors" },
      { key: "sellers" as NavigationKey, label: "Sellers" },
      { key: "settings" as NavigationKey, label: "System Settings" },
      common[2],
      common[3],
      common[4],
      common[5],
    ];
  }

  return common;
});

const activeMenu = computed<NavigationKey>(() => {
  if (currentPath.value.startsWith("/products")) return "products";
  if (currentPath.value.startsWith("/investors")) return "investors";
  if (currentPath.value.startsWith("/sellers")) return "sellers";
  if (currentPath.value.startsWith("/settings")) return "settings";
  if (currentPath.value.startsWith("/transactions")) return "requests";
  if (currentPath.value.startsWith("/fees")) return "fees" as NavigationKey;
  if (currentPath.value.startsWith("/reports")) return "reports";
  return "overview";
});

watch(
  activeMenu,
  (menu) => {
    marketplace.activeMenu.value = menu;
  },
  { immediate: true }
);

const activeComponent = computed(() => {
  if (currentPath.value.startsWith("/sellers/")) {
    return marketplace.role.value === "Admin" ? SellerDetailsPage : DashboardFeaturePage;
  }

  if (currentPath.value.startsWith("/products")) return ProductFeaturePage;
  if (currentPath.value.startsWith("/investors")) return marketplace.role.value === "Admin" ? InvestorsFeaturePage : DashboardFeaturePage;
  if (currentPath.value.startsWith("/sellers")) return marketplace.role.value === "Admin" ? SellersFeaturePage : DashboardFeaturePage;
  if (currentPath.value.startsWith("/settings")) return marketplace.role.value === "Admin" ? SettingsFeaturePage : DashboardFeaturePage;
  if (currentPath.value.startsWith("/transactions")) return TransactionsFeaturePage;
  if (currentPath.value.startsWith("/fees")) return FeeManagementFeaturePage;
  if (currentPath.value.startsWith("/reports")) return ReportsFeaturePage;

  return DashboardFeaturePage;
});

const welcomeText = computed(() => {
  if (!marketplace.session.value) return "Welcome";

  const fullName =
    marketplace.state.value.currentUserName ??
    (marketplace.role.value === "Admin" ? "Admin User" : "Seller User");

  return `Welcome back, ${fullName}`;
});

watch(
  () => marketplace.session.value,
  (session) => {
    const authPath =
      window.location.pathname === "/Login" ||
      window.location.pathname === "/Register" ||
      window.location.pathname === "/";

    if (session && authPath) {
      window.history.replaceState({}, "", "/overview");
      syncPath();
    }
  }
);

const handleMenuChange = (menu: NavigationKey) => {
  if (menu === "logout") {
    marketplace.logout();
    window.history.pushState({}, "", "/overview");
    syncPath();
    return;
  }

  const target = ROUTE_BY_MENU[menu];

  if (target) {
    window.history.pushState({}, "", target);
    syncPath();
  }
};

const handleLogout = () => {
  marketplace.logout();
  window.history.pushState({}, "", "/overview");
  syncPath();
};
</script>

<template>
  <AuthPage v-if="!marketplace.session.value" :marketplace="marketplace" />

  <AppLayout
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
    @notifications-read-all="marketplace.readAllNotifications"
  >
    <component :is="activeComponent" :marketplace="marketplace" />
  </AppLayout>
</template>