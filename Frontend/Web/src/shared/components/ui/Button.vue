<script setup lang="ts">
withDefaults(
  defineProps<{
    variant?: "primary" | "secondary" | "ghost" | "danger" | "success" | "warning";
    size?: "sm" | "md" | "lg";
    type?: "button" | "submit" | "reset";
    disabled?: boolean;
    full?: boolean;
    loading?: boolean;
  }>(),
  {
    variant: "primary",
    size: "md",
    type: "button",
    disabled: false,
    full: false,
    loading: false,
  }
);
</script>

<template>
  <button
    :class="[
      'ui-btn',
      `ui-btn--${variant}`,
      `ui-btn--${size}`,
      { 'ui-btn--full': full, 'is-loading': loading }
    ]"
    :type="type"
    :disabled="disabled || loading"
  >
    <span v-if="loading" class="ui-spinner"></span>
    <slot />
  </button>
</template>