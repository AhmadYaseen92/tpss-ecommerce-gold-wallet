<script setup lang="ts">
import { computed, ref, watch } from "vue";
import { RouterView, useRoute, useRouter } from "vue-router";
import type { NavigationKey } from "./shared/types/models";
import AppShell from "./shared/layouts/AppShell.vue";
import AuthPage from "./features/auth/pages/AuthPage.vue";
import { useMarketplace } from "./shared/app/store/useMarketplace";

const marketplace = useMarketplace();
const route = useRoute();
const router = useRouter();
const isDark = ref(false);

const ROUTE_BY_MENU: Record<Exclude<NavigationKey, "logout" | "invoices" | "inventory" | "notifications">, string> = {
  overview: "/overview",
  products: "/products",
  investors: "/investors",
  requests: "/transactions",
  fees: "/fees",
  reports: "/reports"
};

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

const activeMenu = computed<NavigationKey>(() => {
  if (route.path.startsWith("/products")) return "products";
  if (route.path.startsWith("/investors")) return "investors";
  if (route.path.startsWith("/transactions")) return "requests";
  if (route.path.startsWith("/fees")) return "fees";
  if (route.path.startsWith("/reports")) return "reports";
  return "overview";
});

watch(activeMenu, (menu) => {
  marketplace.activeMenu.value = menu;
}, { immediate: true });

const welcomeText = computed(() => {
  if (!marketplace.session.value) return "Welcome";
  const fullName = marketplace.state.value.currentUserName ?? (marketplace.role.value === "admin" ? "Admin User" : "Seller User");
  return `Welcome back, ${fullName}`;
});

const handleMenuChange = (menu: NavigationKey) => {
  if (menu === "logout") {
    marketplace.logout();
    router.replace("/");
    return;
  }

  const target = ROUTE_BY_MENU[menu as keyof typeof ROUTE_BY_MENU];
  if (target && route.path !== target) {
    router.push(target);
  }
};

const handleLogout = () => {
  marketplace.logout();
  router.replace("/");
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
    <RouterView v-slot="{ Component }">
      <component :is="Component" :marketplace="marketplace" />
    </RouterView>
  </AppShell>
</template>
