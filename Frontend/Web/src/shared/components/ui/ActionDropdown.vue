<script setup lang="ts">
defineProps<{ modelValue?: string }>();
const emit = defineEmits<{ 'update:modelValue': [v: string] }>();
</script>
<template>
  <select class="ui-select" :value="modelValue" @change="emit('update:modelValue', ($event.target as HTMLSelectElement).value)">
    <slot />
  </select>
</template>
