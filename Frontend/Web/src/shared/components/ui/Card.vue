<script setup lang="ts">
withDefaults(
  defineProps<{
    title?: string;
    subtitle?: string;
    padding?: "sm" | "md" | "lg";
  }>(),
  {
    padding: "md",
  }
);
</script>

<template>
  <section class="ui-card" :class="`ui-card--${padding}`">
    
    <header v-if="title || subtitle || $slots['header-right']" class="ui-card-header">
      
      <div class="ui-card-header-left">
        <h3 v-if="title">{{ title }}</h3>
        <p v-if="subtitle">{{ subtitle }}</p>
      </div>

      <div v-if="$slots['header-right']" class="ui-card-header-right">
        <slot name="header-right" />
      </div>

    </header>

    <div class="ui-card-body">
      <slot />
    </div>

  </section>
</template>