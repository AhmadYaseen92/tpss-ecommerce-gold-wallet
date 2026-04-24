<script setup lang="ts">
defineProps<{ label: string; hint?: string; error?: string }>();
</script>
<template>
  <label class="ui-form-field">
    <span class="ui-form-label">{{ label }}</span>
    <slot />
    <small v-if="hint && !error" class="ui-form-hint">{{ hint }}</small>
    <small v-if="error" class="ui-form-error">{{ error }}</small>
  </label>
</template>
