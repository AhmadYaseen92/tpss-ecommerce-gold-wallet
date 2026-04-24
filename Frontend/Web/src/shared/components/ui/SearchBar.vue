<script setup lang="ts">
defineProps<{ modelValue: string; placeholder?: string }>();
const emit = defineEmits<{ 'update:modelValue': [v: string] }>();
</script>

<template>
  <input class="ui-input ui-search" :value="modelValue" :placeholder="placeholder ?? 'Search...'" @input="emit('update:modelValue', ($event.target as HTMLInputElement).value)" />
</template>
