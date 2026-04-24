<script setup lang="ts">
const props = defineProps<{ status: string }>();
const cls = () => {
  const value = props.status.toLowerCase();
  if (["approved", "active", "delivered"].includes(value)) return "ok";
  if (["pending", "underreview", "pending_delivered"].includes(value)) return "warn";
  if (["rejected", "blocked", "cancelled", "canceled", "inactive"].includes(value)) return "bad";
  return "neutral";
};
</script>
<template><span :class="['ui-status', `ui-status--${cls()}`]">{{ status }}</span></template>
