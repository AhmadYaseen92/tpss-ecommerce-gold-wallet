<script setup lang="ts">
withDefaults(defineProps<{ variant?: 'primary' | 'ghost' | 'danger'; type?: 'button' | 'submit' | 'reset'; disabled?: boolean }>(), {
  variant: 'primary',
  type: 'button',
  disabled: false,
});
</script>

<template>
  <button :class="['ui-btn', `ui-btn--${variant}`]" :type="type" :disabled="disabled">
    <slot />
  </button>
</template>
