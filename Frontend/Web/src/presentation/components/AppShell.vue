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
const openSettings = ref(false);
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
      <header class="top-bar modern compact">
        <div class="top-title">
          <h2>{{ welcomeText }}</h2>
          <p>{{ role === "admin" ? "Administrator workspace" : "Seller workspace" }}</p>
        </div>

        <div class="top-actions modern">
          <button class="top-action-btn" @click="openNotifications = !openNotifications" title="Notifications">
            <span>🔔</span>
            <span>Notifications</span>
            <small v-if="notifications.filter((item) => !item.isRead).length > 0" class="badge">
              {{ notifications.filter((item) => !item.isRead).length }}
            </small>
          </button>
          <button class="top-action-btn" @click="emit('themeToggle')" :title="isDark ? 'Light Theme' : 'Dark Theme'">
            <span>{{ isDark ? "☀️" : "🌙" }}</span>
            <span>{{ isDark ? "Light" : "Dark" }}</span>
          </button>
          <button class="top-action-btn" @click="openSettings = !openSettings" title="Settings">
            <span>⚙️</span>
            <span>Settings</span>
          </button>
          <button class="top-action-btn danger" @click="emit('logout')" title="Logout">
            <span>⎋</span>
            <span>Logout</span>
          </button>
        </div>
      </header>

      <aside v-if="openNotifications" class="vertical-modal right">
        <h4>Notifications</h4>
        <ul>
          <li v-for="notice in notifications.slice(0, 8)" :key="notice.id">
            <div>
              <strong>{{ notice.title }}</strong>
              <p>{{ notice.message }}</p>
            </div>
            <button class="ghost" @click="emit('notificationRead', notice.id)">Mark read</button>
          </li>
        </ul>
      </aside>

      <aside v-if="openSettings" class="vertical-modal right settings">
        <h4>Settings</h4>
        <div class="settings-list">
          <button class="ghost" @click="emit('themeToggle')">Toggle Theme</button>
          <button class="ghost">Profile Preferences</button>
          <button class="ghost">Security</button>
          <button class="danger" @click="emit('logout')">Logout</button>
        </div>
      </aside>

      <slot />
    </main>
  </div>
</template>
