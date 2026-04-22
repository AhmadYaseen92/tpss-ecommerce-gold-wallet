<script setup lang="ts">
const model = defineModel<boolean>({ default: false });
const props = defineProps<{ disabled?: boolean }>();
</script>

<template>
  <input v-model="model" class="small-checkbox" type="checkbox" :disabled="props.disabled" />
</template>

<style scoped>
.small-checkbox {
  width: 14px;
  height: 14px;
  accent-color: #caa32a;
  cursor: pointer;
  vertical-align: middle;
}
.small-checkbox:disabled {
  cursor: not-allowed;
  opacity: 0.6;
}
</style>
