<script setup lang="ts">
defineProps<{ modelValue: boolean; disabled?: boolean }>();
const emit = defineEmits<{ 'update:modelValue': [v: boolean] }>();
</script>
<template>
  <label class="normal-toggle">
    <input type="checkbox" :checked="modelValue" :disabled="disabled" @change="emit('update:modelValue', ($event.target as HTMLInputElement).checked)" />
    <span class="slider"></span>
  </label>
</template>
