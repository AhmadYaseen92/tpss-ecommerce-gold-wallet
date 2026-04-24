<script setup lang="ts">
defineProps<{ open: boolean; title: string; message: string; tone?: 'success' | 'error' | 'warning' | 'info' }>();
const emit = defineEmits<{ close: [] }>();
</script>
<template>
  <div v-if="open" class="common-modal-overlay" @click.self="emit('close')">
    <div class="common-modal">
      <h3>{{ title }}</h3>
      <p>{{ message }}</p>
      <button class="ui-btn" @click="emit('close')">OK</button>
    </div>
  </div>
</template>
