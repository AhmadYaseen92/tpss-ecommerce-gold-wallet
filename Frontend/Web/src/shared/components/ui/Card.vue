<script setup lang="ts">
defineProps<{ title?: string; subtitle?: string }>();
</script>

<template>
  <section class="ui-card">
    <header v-if="title || subtitle" class="ui-card-header">
      <h3 v-if="title">{{ title }}</h3>
      <p v-if="subtitle">{{ subtitle }}</p>
      <slot name="header-right" />
    </header>
    <slot />
  </section>
</template>
