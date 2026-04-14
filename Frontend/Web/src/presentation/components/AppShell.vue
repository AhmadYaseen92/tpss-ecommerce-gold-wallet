<script setup lang="ts">
import type { NavigationKey, UserRole } from "../../domain/models";

defineProps<{
  role: UserRole;
  activeMenu: NavigationKey;
  menuItems: Array<{ key: NavigationKey; label: string }>;
  welcomeText: string;
  isDark: boolean;
}>();

const emit = defineEmits<{
  roleChange: [role: UserRole];
  menuChange: [menu: NavigationKey];
  logout: [];
  themeToggle: [];
}>();
</script>

<template>
  <div class="app-shell">
    <aside class="side-nav">
      <div class="brand">
        <h1>Gold Wallet</h1>
        <p>Control Center</p>
      </div>

      <label>
        Active Role
        <select :value="role" @change="emit('roleChange', ($event.target as HTMLSelectElement).value as UserRole)">
          <option value="admin">Admin</option>
          <option value="seller">Seller</option>
        </select>
      </label>

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
      <header class="top-bar">
        <div>
          <h2>{{ welcomeText }}</h2>
          <p>Manage operations with role-aware controls.</p>
        </div>
        <div class="top-actions">
          <button class="ghost" @click="emit('themeToggle')">{{ isDark ? "Light" : "Dark" }} Theme</button>
          <button class="ghost">Settings</button>
          <button class="danger" @click="emit('logout')">Logout</button>
        </div>
      </header>
      <slot />
    </main>
  </div>
</template>
