<script setup lang="ts">
defineProps<{ label: string; hint?: string; error?: string; required?: boolean }>();
</script>

<template>
  <label class="base-field" :class="{ invalid: !!error }">
    <span class="field-label">{{ label }} <strong v-if="required">*</strong></span>
    <slot />
    <small v-if="hint" class="field-hint">{{ hint }}</small>
    <small v-if="error" class="field-error">{{ error }}</small>
  </label>
</template>
