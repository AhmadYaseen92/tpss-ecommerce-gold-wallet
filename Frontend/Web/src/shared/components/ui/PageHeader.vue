<script setup lang="ts">
defineProps<{
  title: string;
  subtitle?: string;
}>();
</script>

<template>
  <header class="ui-page-header">
    <div>
      <h2>{{ title }}</h2>
      <p v-if="subtitle">{{ subtitle }}</p>
    </div>

    <div v-if="$slots.default" class="ui-page-header-actions">
      <slot />
    </div>
  </header>
</template>