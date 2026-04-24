<script setup lang="ts">
import AppShell from "../../layouts/AppShell.vue";
import type { NavigationKey, NotificationItem, UserRole } from "../../types/models";
defineProps<{ role: UserRole; activeMenu: NavigationKey; menuItems: Array<{ key: NavigationKey; label: string }>; welcomeText: string; isDark: boolean; notifications: NotificationItem[] }>();
const emit = defineEmits<{
  menuChange: [menu: NavigationKey];
  logout: [];
  themeToggle: [];
  notificationRead: [notificationId: string];
  notificationsReadAll: [];
}>();
</script>
<template>
  <AppShell
    :role="role"
    :active-menu="activeMenu"
    :menu-items="menuItems"
    :welcome-text="welcomeText"
    :is-dark="isDark"
    :notifications="notifications"
    @menu-change="emit('menuChange', $event)"
    @logout="emit('logout')"
    @theme-toggle="emit('themeToggle')"
    @notification-read="emit('notificationRead', $event)"
    @notifications-read-all="emit('notificationsReadAll')"
  >
    <slot />
  </AppShell>
</template>
