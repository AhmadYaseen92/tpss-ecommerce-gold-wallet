<script setup lang="ts">
defineProps<{
  open: boolean;
  title?: string;
  message: string;
}>();

const emit = defineEmits<{ (e: "close"): void }>();
</script>

<template>
  <div v-if="open" class="common-modal-overlay" role="dialog" aria-modal="true">
    <div class="common-modal">
      <h3>{{ title || "Notice" }}</h3>
      <p>{{ message }}</p>
      <button type="button" class="full-btn" @click="emit('close')">OK</button>
    </div>
  </div>
</template>
