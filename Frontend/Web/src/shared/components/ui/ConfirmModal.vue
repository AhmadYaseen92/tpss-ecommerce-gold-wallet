<script setup lang="ts">
defineProps<{ open: boolean; title: string; message: string }>();
const emit = defineEmits<{ confirm: []; close: [] }>();
</script>
<template>
  <div v-if="open" class="common-modal-overlay" @click.self="emit('close')">
    <div class="common-modal">
      <h3>{{ title }}</h3>
      <p>{{ message }}</p>
      <div class="ui-modal-actions">
        <button class="ui-btn ui-btn--ghost" @click="emit('close')">Cancel</button>
        <button class="ui-btn ui-btn--danger" @click="emit('confirm')">Confirm</button>
      </div>
    </div>
  </div>
</template>
