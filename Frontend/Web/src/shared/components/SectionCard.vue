<script setup lang="ts">
defineProps<{ title: string }>();
</script>

<template>
  <section class="section-card">
    <header>
      <h2>{{ title }}</h2>
      <div class="header-actions">
        <slot name="actions" />
      </div>
    </header>
    <slot />
  </section>
</template>
