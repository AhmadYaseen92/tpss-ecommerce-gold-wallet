<script setup lang="ts">
import type { NavigationKey, UserRole } from "../../domain/models";

defineProps<{
  role: UserRole;
  activeMenu: NavigationKey;
  menuItems: Array<{ key: NavigationKey; label: string }>;
}>();

const emit = defineEmits<{
  roleChange: [role: UserRole];
  menuChange: [menu: NavigationKey];
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
      <slot />
    </main>
  </div>
</template>
