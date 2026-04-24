<script setup lang="ts">
defineProps<{ page: number; totalPages: number; totalItems: number; pageSize: number }>();
const emit = defineEmits<{ prev: []; next: [] }>();
</script>
<template>
  <div class="ui-pagination">
    <span>Results: {{ (page - 1) * pageSize + 1 }} - {{ Math.min(page * pageSize, totalItems) }} of {{ totalItems }}</span>
    <div>
      <button class="ui-btn ui-btn--ghost" :disabled="page <= 1" @click="emit('prev')">&lt;</button>
      <span>{{ page }} / {{ totalPages }}</span>
      <button class="ui-btn ui-btn--ghost" :disabled="page >= totalPages" @click="emit('next')">&gt;</button>
    </div>
  </div>
</template>
