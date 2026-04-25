<script setup lang="ts">
import { computed } from "vue";

const props = defineProps<{
  status?: string | null;
}>();

const label = computed(() => props.status || "Unknown");

const statusClass = computed(() => {
  const value = label.value.toLowerCase().replace(/\s|-/g, "");

  if (["approved", "active", "delivered", "completed", "paid", "success"].includes(value)) {
    return "ok";
  }

  if (["pending", "underreview", "pendingdelivered", "processing", "draft"].includes(value)) {
    return "warn";
  }

  if (["rejected", "blocked", "cancelled", "canceled", "inactive", "failed", "expired"].includes(value)) {
    return "bad";
  }

  return "neutral";
});
</script>

<template>
  <span :class="['ui-status', `ui-status--${statusClass}`]">
    {{ label }}
  </span>
</template>