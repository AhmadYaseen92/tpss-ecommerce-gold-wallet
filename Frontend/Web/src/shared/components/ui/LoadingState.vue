<script setup lang="ts">
withDefaults(
  defineProps<{
    text?: string;
    size?: "sm" | "md" | "lg";
  }>(),
  {
    text: "Loading...",
    size: "md",
  }
);
</script>

<template>
  <div class="ui-state ui-loading" :class="`ui-loading--${size}`">
    <span class="ui-spinner"></span>
    <span>{{ text }}</span>
  </div>
</template>