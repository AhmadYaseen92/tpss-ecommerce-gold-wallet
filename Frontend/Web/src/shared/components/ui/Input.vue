<script setup lang="ts">
withDefaults(
  defineProps<{
    modelValue?: string | number | null;
    type?: string;
    placeholder?: string;
    min?: number | string;
    max?: number | string;
    step?: number | string;
    disabled?: boolean;
    readonly?: boolean;
    error?: boolean;
    autocomplete?: string;
    inputmode?: "none" | "text" | "decimal" | "numeric" | "tel" | "search" | "email" | "url";
  }>(),
  {
    type: "text",
    disabled: false,
    readonly: false,
    error: false,
  }
);

const emit = defineEmits<{
  "update:modelValue": [value: string];
  blur: [event: FocusEvent];
  focus: [event: FocusEvent];
}>();
</script>

<template>
  <input
    class="ui-input"
    :class="{ 'input-error': error }"
    :value="modelValue ?? ''"
    :type="type"
    :placeholder="placeholder"
    :min="min"
    :max="max"
    :step="step"
    :disabled="disabled"
    :readonly="readonly"
    :autocomplete="autocomplete"
    :inputmode="inputmode"
    @input="emit('update:modelValue', ($event.target as HTMLInputElement).value)"
    @blur="emit('blur', $event)"
    @focus="emit('focus', $event)"
  />
</template>