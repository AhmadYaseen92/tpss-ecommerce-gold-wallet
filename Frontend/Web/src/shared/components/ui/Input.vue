<script setup lang="ts">
defineProps<{ modelValue?: string | number; type?: string; placeholder?: string; min?: number | string; step?: number | string; disabled?: boolean }>();
const emit = defineEmits<{ 'update:modelValue': [v: string] }>();
</script>

<template>
  <input
    class="ui-input"
    :value="modelValue"
    :type="type ?? 'text'"
    :placeholder="placeholder"
    :min="min"
    :step="step"
    :disabled="disabled"
    @input="emit('update:modelValue', ($event.target as HTMLInputElement).value)"
  />
</template>
