<script setup lang="ts">
withDefaults(
  defineProps<{
    modelValue: string;
    placeholder?: string;
    disabled?: boolean;
  }>(),
  {
    placeholder: "Search...",
    disabled: false,
  }
);

const emit = defineEmits<{
  "update:modelValue": [value: string];
}>();
</script>

<template>
  <input
    class="ui-input ui-search"
    type="search"
    :value="modelValue"
    :placeholder="placeholder"
    :disabled="disabled"
    @input="emit('update:modelValue', ($event.target as HTMLInputElement).value)"
  />
</template>