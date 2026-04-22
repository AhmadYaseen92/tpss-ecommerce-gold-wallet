<script setup lang="ts">
const model = defineModel<boolean>({ default: false });
const props = defineProps<{ disabled?: boolean }>();
</script>

<template>
  <label class="small-toggle" :class="{ disabled: props.disabled }">
    <input v-model="model" type="checkbox" :disabled="props.disabled" />
    <span class="track"><span class="thumb" /></span>
  </label>
</template>

<style scoped>
.small-toggle { display:inline-flex; align-items:center; cursor:pointer; }
.small-toggle input { display:none; }
.track { width:34px; height:18px; border-radius:999px; background:#d1d5db; position:relative; transition:0.2s; }
.thumb { position:absolute; top:2px; left:2px; width:14px; height:14px; background:#fff; border-radius:50%; transition:0.2s; box-shadow:0 1px 2px rgba(0,0,0,.2); }
.small-toggle input:checked + .track { background:#caa32a; }
.small-toggle input:checked + .track .thumb { transform:translateX(16px); }
.small-toggle.disabled { opacity:.5; cursor:not-allowed; }
</style>
