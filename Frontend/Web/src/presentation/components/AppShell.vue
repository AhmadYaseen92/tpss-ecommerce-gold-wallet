<script setup lang="ts">
import { ref } from "vue";
import type { NavigationKey, NotificationItem, UserRole } from "../../domain/models";

defineProps<{
  role: UserRole;
  activeMenu: NavigationKey;
  menuItems: Array<{ key: NavigationKey; label: string }>;
  welcomeText: string;
  isDark: boolean;
  notifications: NotificationItem[];
}>();

const emit = defineEmits<{
  menuChange: [menu: NavigationKey];
  logout: [];
  themeToggle: [];
  notificationRead: [notificationId: string];
}>();

const openNotifications = ref(false);
</script>

<template>
  <div class="app-shell">
    <aside class="side-nav">
      <div class="brand">
        <h1>Gold Wallet</h1>
        <p>Control Center</p>
      </div>

      <nav class="menu-list">
        <button
          v-for="item in menuItems"
          :key="item.key"
          class="menu-btn"
          :class="{ active: item.key === activeMenu }"
          @click="emit('menuChange', item.key)"
        >
          {{ item.label }}
        </button>
      </nav>
    </aside>

    <main class="content">
      <header class="top-bar modern">
        <div class="top-title">
          <h2>{{ welcomeText }}</h2>
          <p>{{ role === "admin" ? "Administrator workspace" : "Seller workspace" }}</p>
        </div>

        <div class="top-actions modern">
          <button class="icon-btn" @click="openNotifications = !openNotifications" title="Notifications">
            <span>🔔</span>
            <small v-if="notifications.filter((item) => !item.isRead).length > 0" class="badge">
              {{ notifications.filter((item) => !item.isRead).length }}
            </small>
          </button>
          <button class="icon-btn" @click="emit('themeToggle')" :title="isDark ? 'Light Theme' : 'Dark Theme'">
            <span>{{ isDark ? "☀️" : "🌙" }}</span>
          </button>
          <button class="icon-btn" title="Settings"><span>⚙️</span></button>
          <button class="icon-btn danger" @click="emit('logout')" title="Logout"><span>⎋</span></button>
        </div>

        <div v-if="openNotifications" class="notification-popover">
          <h4>Notifications</h4>
          <ul>
            <li v-for="notice in notifications.slice(0, 6)" :key="notice.id">
              <div>
                <strong>{{ notice.title }}</strong>
                <p>{{ notice.message }}</p>
              </div>
              <button class="ghost" @click="emit('notificationRead', notice.id)">Mark read</button>
            </li>
          </ul>
        </div>
      </header>

      <slot />
    </main>
  </div>
</template>
