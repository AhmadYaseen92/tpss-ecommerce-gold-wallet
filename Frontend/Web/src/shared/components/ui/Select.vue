<script setup lang="ts">
withDefaults(
  defineProps<{
    modelValue?: string | number | null;
    placeholder?: string;
    disabled?: boolean;
    error?: boolean;
  }>(),
  {
    disabled: false,
    error: false,
  }
);

const emit = defineEmits<{
  "update:modelValue": [value: string];
}>();
</script>

<template>
  <select
    class="ui-select"
    :class="{ 'input-error': error }"
    :value="modelValue ?? ''"
    :disabled="disabled"
    @change="emit('update:modelValue', ($event.target as HTMLSelectElement).value)"
  >
    <!-- Placeholder -->
    <option v-if="placeholder" disabled value="">
      {{ placeholder }}
    </option>

    <slot />
  </select>
</template>