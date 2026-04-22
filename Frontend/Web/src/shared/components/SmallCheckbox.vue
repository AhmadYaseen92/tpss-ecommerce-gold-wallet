<script setup lang="ts">
const model = defineModel<boolean>({ default: false });
const props = defineProps<{ disabled?: boolean }>();
</script>

<template>
  <label class="small-checkbox-wrap">
    <input v-model="model" class="small-checkbox-input" type="checkbox" :disabled="props.disabled" />
    <span class="small-checkbox-box" />
  </label>
</template>

<style scoped>
.small-checkbox-wrap {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 16px;
  height: 16px;
  position: relative;
}

.small-checkbox-input {
  position: absolute;
  inset: 0;
  opacity: 0;
  margin: 0;
}

.small-checkbox-box {
  width: 14px;
  height: 14px;
  border: 1px solid #b8b8b8;
  border-radius: 3px;
  background: #fff;
  transition: all 0.15s ease;
}

.small-checkbox-input:checked + .small-checkbox-box {
  background: #caa32a;
  border-color: #b88f1b;
}

.small-checkbox-input:checked + .small-checkbox-box::after {
  content: "";
  display: block;
  width: 4px;
  height: 8px;
  border: solid #fff;
  border-width: 0 2px 2px 0;
  transform: translate(4px, 1px) rotate(45deg);
}

.small-checkbox-input:focus-visible + .small-checkbox-box {
  outline: 2px solid #f2d27b;
  outline-offset: 1px;
}

.small-checkbox-wrap,
.small-checkbox-input {
  cursor: pointer;
}

.small-checkbox-input:disabled + .small-checkbox-box {
  background: #efefef;
  border-color: #d4d4d4;
}

.small-checkbox-input:disabled {
  cursor: not-allowed;
}
</style>
