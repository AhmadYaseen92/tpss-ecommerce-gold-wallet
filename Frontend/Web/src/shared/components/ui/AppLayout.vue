<script setup lang="ts">
import { onBeforeUnmount, onMounted, reactive, ref, watch } from "vue";
import type { NavigationKey, NotificationItem, UserRole } from "../../types/models";

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
  passwordChange: [payload: { currentPassword: string; newPassword: string }];
}>();

const openNotifications = ref(false);
const openSettings = ref(false);
const toastMessage = ref("");
const passwordMessage = ref("");

const passwordForm = reactive({
  currentPassword: "",
  newPassword: "",
  confirmPassword: "",
});

let lastSeenNotificationId: string | null = null;

const unreadCount = () => props.notifications.filter((item) => !item.isRead).length;

const closeAllPanels = () => {
  openNotifications.value = false;
  openSettings.value = false;
};

const onEsc = (event: KeyboardEvent) => {
  if (event.key === "Escape") closeAllPanels();
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

  emit("passwordChange", {
    currentPassword: passwordForm.currentPassword,
    newPassword: passwordForm.newPassword,
  });
};

const resetPasswordForm = () => {
  passwordForm.currentPassword = "";
  passwordForm.newPassword = "";
  passwordForm.confirmPassword = "";
};

watch(openSettings, (value) => {
  if (!value) {
    passwordMessage.value = "";
    resetPasswordForm();
  }
});

const formatLocalDateTime = (iso: string) => {
  const value = new Date(iso);

  return value.toLocaleString(undefined, {
    dateStyle: "medium",
    timeStyle: "short",
  });
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
</script>

<template>
  <div class="app-shell">
    <aside class="side-nav">
      <div class="brand">
        <div class="brand-mark">GW</div>
        <div>
          <h1>Gold Wallet</h1>
          <p>Control Center</p>
        </div>
      </div>

      <nav class="menu-list">
        <button
          v-for="item in menuItems"
          :key="item.key"
          class="menu-btn"
          :class="{ active: item.key === activeMenu }"
          type="button"
          @click="emit('menuChange', item.key)"
        >
          <span>{{ item.label }}</span>
        </button>
      </nav>
    </aside>

    <main class="content">
      <header class="top-bar">
        <div class="top-title">
          <h2>{{ welcomeText }}</h2>
          <p>{{ role === "Admin" ? "Administrator workspace" : "Seller workspace" }}</p>
        </div>

        <div class="top-actions">
          <button
            class="top-action-btn"
            type="button"
            title="Notifications"
            @click="openNotifications = !openNotifications; openSettings = false"
          >
            <span>🔔</span>
            <span>Notifications</span>
            <small v-if="unreadCount() > 0" class="badge">{{ unreadCount() }}</small>
          </button>

          <button
            class="top-action-btn"
            type="button"
            :title="isDark ? 'Switch to light theme' : 'Switch to dark theme'"
            @click="emit('themeToggle')"
          >
            <span>{{ isDark ? "☀️" : "🌙" }}</span>
            <span>{{ isDark ? "Light" : "Dark" }}</span>
          </button>

          <button
            class="top-action-btn"
            type="button"
            title="Settings"
            @click="openSettings = !openSettings; openNotifications = false"
          >
            <span>⚙️</span>
            <span>Settings</span>
          </button>

          <button class="top-action-btn danger" type="button" title="Logout" @click="emit('logout')">
            <span>⎋</span>
            <span>Logout</span>
          </button>
        </div>
      </header>

      <div v-if="openNotifications || openSettings" class="panel-overlay" @click="closeAllPanels"></div>

      <aside v-if="openNotifications" class="vertical-modal right">
        <div class="modal-head">
          <div>
            <h4>Notifications</h4>
            <p>Latest system updates</p>
          </div>

          <div class="modal-actions">
            <button class="ui-btn ui-btn--ghost ui-btn--sm" type="button" @click="emit('notificationsReadAll')">
              Mark all read
            </button>
            <button class="ui-btn ui-btn--ghost ui-btn--icon" type="button" @click="openNotifications = false">
              ✕
            </button>
          </div>
        </div>

        <ul class="notification-panel-list">
          <li v-for="notice in notifications.slice(0, 8)" :key="notice.id" :class="{ unread: !notice.isRead }">
            <div>
              <strong>{{ notice.title }}</strong>
              <p>{{ notice.message }}</p>
              <small>{{ formatLocalDateTime(notice.createdAt) }}</small>
            </div>

            <button class="ui-btn ui-btn--ghost ui-btn--sm" type="button" @click="emit('notificationRead', notice.id)">
              Mark read
            </button>
          </li>
        </ul>
      </aside>

      <aside v-if="openSettings" class="vertical-modal right settings">
        <div class="modal-head">
          <div>
            <h4>Change Password</h4>
            <p>Update your account security</p>
          </div>

          <button class="ui-btn ui-btn--ghost ui-btn--icon" type="button" @click="openSettings = false">
            ✕
          </button>
        </div>

        <form class="settings-list" @submit.prevent="submitPasswordChange">
          <label class="ui-form-field">
            <span class="ui-form-label">Current password</span>
            <input v-model="passwordForm.currentPassword" class="ui-input" type="password" placeholder="Current password" />
          </label>

          <label class="ui-form-field">
            <span class="ui-form-label">New password</span>
            <input v-model="passwordForm.newPassword" class="ui-input" type="password" placeholder="New password" />
          </label>

          <label class="ui-form-field">
            <span class="ui-form-label">Confirm new password</span>
            <input v-model="passwordForm.confirmPassword" class="ui-input" type="password" placeholder="Confirm new password" />
          </label>

          <button class="ui-btn ui-btn--primary" type="submit">Update Password</button>

          <p v-if="passwordMessage" class="settings-message">{{ passwordMessage }}</p>
        </form>
      </aside>

      <div v-if="toastMessage" class="notification-toast">
        {{ toastMessage }}
      </div>

      <section class="page-content">
        <slot />
      </section>
    </main>
  </div>
</template>
