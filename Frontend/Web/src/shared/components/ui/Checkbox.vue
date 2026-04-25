<script setup lang="ts">
withDefaults(
  defineProps<{
    modelValue?: boolean;
    label?: string;
    disabled?: boolean;
  }>(),
  {
    modelValue: false,
    disabled: false,
  }
);
const emit = defineEmits<{
  "update:modelValue": [value: boolean];
}>();
</script>

<template>
  <label class="ui-checkbox" :class="{ disabled }">
    <input
      type="checkbox"
      :checked="modelValue"
      :disabled="disabled"
      @change="emit('update:modelValue', ($event.target as HTMLInputElement).checked)"
    />
    <span class="ui-checkbox-box"></span>
    <span v-if="label" class="ui-checkbox-label">
      {{ label }}
    </span>
  </label>
</template>