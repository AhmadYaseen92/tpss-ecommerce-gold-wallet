<script setup lang="ts">
import { onBeforeUnmount, onMounted, reactive, ref } from "vue";
import type { NavigationKey, NotificationItem, UserRole } from "../types/models";

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
const passwordForm = reactive({ currentPassword: "", newPassword: "", confirmPassword: "" });
const passwordMessage = ref("");

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
});

onBeforeUnmount(() => {
  window.removeEventListener("keydown", onEsc);
});
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
          <button class="ghost" @click="openNotifications = false">✕</button>
        </div>
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
        <div class="modal-head">
          <h4>Change Password</h4>
          <button class="ghost" @click="openSettings = false">✕</button>
        </div>
        <form class="settings-list" @submit.prevent="submitPasswordChange">
          <input v-model="passwordForm.currentPassword" type="password" placeholder="Current password" />
          <input v-model="passwordForm.newPassword" type="password" placeholder="New password" />
          <input v-model="passwordForm.confirmPassword" type="password" placeholder="Confirm new password" />
          <button type="submit">Update Password</button>
          <p v-if="passwordMessage" class="settings-message">{{ passwordMessage }}</p>
        </form>
      </aside>

      <slot />
    </main>
  </div>
</template>
