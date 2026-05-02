<script setup lang="ts">
import { onBeforeUnmount, onMounted, reactive, ref, watch } from "vue";
import type { NavigationKey, NotificationItem, UserRole } from "../types/models";

const props = defineProps<{
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
  notificationsReadAll: [];
}>();

const openNotifications = ref(false);
const openSettings = ref(false);
const toastMessage = ref("");
const passwordForm = reactive({ currentPassword: "", newPassword: "", confirmPassword: "" });
const passwordMessage = ref("");
let lastSeenNotificationId: string | null = null;

const closeAllPanels = () => {
  openNotifications.value = false;
  openSettings.value = false;
};

const onEsc = (event: KeyboardEvent) => {
  if (event.key === "Escape") {
    closeAllPanels();
  }
};

const submitPasswordChange = () => {
  if (!passwordForm.currentPassword || !passwordForm.newPassword || !passwordForm.confirmPassword) {
    passwordMessage.value = "Please fill all password fields.";
    return;
  }

  if (passwordForm.newPassword !== passwordForm.confirmPassword) {
    passwordMessage.value = "New password and confirm password do not match.";
    return;
  }

  passwordMessage.value = "Password updated successfully (demo).";
  passwordForm.currentPassword = "";
  passwordForm.newPassword = "";
  passwordForm.confirmPassword = "";
};

onMounted(() => {
  window.addEventListener("keydown", onEsc);
  lastSeenNotificationId = props.notifications[0]?.id ?? null;
});

onBeforeUnmount(() => {
  window.removeEventListener("keydown", onEsc);
});

watch(
  () => props.notifications,
  (items) => {
    if (items.length === 0) return;
    const newest = items[0];
    if (!newest.isRead && newest.id !== lastSeenNotificationId) {
      toastMessage.value = `${newest.title} — ${newest.message}`;
      window.setTimeout(() => {
        toastMessage.value = "";
      }, 4000);
    }
    lastSeenNotificationId = newest.id;
  },
  { deep: true }
);

const formatLocalDateTime = (iso: string) => {
  const value = new Date(iso);
  return value.toLocaleString(undefined, {
    dateStyle: "medium",
    timeStyle: "short"
  });
};
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
          <p>{{ role === "Admin" ? "Administrator workspace" : "Seller workspace" }}</p>
        </div>

        <div class="top-actions modern">
          <button class="top-action-btn" @click="openNotifications = !openNotifications; openSettings = false" title="Notifications">
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
          <button class="top-action-btn" @click="openSettings = !openSettings; openNotifications = false" title="Settings">
            <span>⚙️</span>
            <span>Settings</span>
          </button>
          <button class="top-action-btn danger" @click="emit('logout')" title="Logout">
            <span>⎋</span>
            <span>Logout</span>
          </button>
        </div>
      </header>

      <div v-if="openNotifications || openSettings" class="panel-overlay" @click="closeAllPanels"></div>

      <aside v-if="openNotifications" class="vertical-modal right">
        <div class="modal-head">
          <h4>Notifications</h4>
          <div class="modal-actions">
            <button class="ghost" @click="emit('notificationsReadAll')">Mark all read</button>
            <button class="ghost" @click="openNotifications = false">✕</button>
          </div>
        </div>
        <ul>
          <li v-for="notice in notifications.slice(0, 8)" :key="notice.id" :class="{ unread: !notice.isRead }">
            <div>
              <strong>{{ notice.title }}</strong>
              <p>{{ notice.message }}</p>
              <small>{{ formatLocalDateTime(notice.createdAt) }}</small>
            </div>
            <button class="ghost" @click="emit('notificationRead', notice.id)">Mark read</button>
          </li>
        </ul>
      </aside>

      <div v-if="toastMessage" class="notification-toast">
        {{ toastMessage }}
      </div>

      <aside v-if="openSettings" class="vertical-modal right settings">
        <div class="modal-head">
          <h4>Account Settings</h4>
          <button class="ghost" @click="openSettings = false">✕</button>
        </div>
        <div class="settings-list">
          <button class="settings-link" @click="$router.push({ name: 'ChangePassword' }); openSettings = false;">
            Change Password
          </button>
        </div>
      </aside>

      <slot />
    </main>
  </div>
</template>
