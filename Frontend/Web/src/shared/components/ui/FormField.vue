<script setup lang="ts">
withDefaults(
  defineProps<{
    label?: string;
    hint?: string;
    error?: string;
    required?: boolean;
  }>(),
  {
    required: false,
  }
);
</script>

<template>
  <label class="ui-form-field">
    <span v-if="label" class="ui-form-label">
      {{ label }}
      <span v-if="required" class="ui-required">*</span>
    </span>

    <slot />

    <small v-if="error" class="ui-form-error">
      {{ error }}
    </small>

    <small v-else-if="hint" class="ui-form-hint">
      {{ hint }}
    </small>
  </label>
</template>