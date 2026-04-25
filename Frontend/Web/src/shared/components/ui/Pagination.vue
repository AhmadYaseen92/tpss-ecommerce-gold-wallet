<script setup lang="ts">
import { computed } from "vue";

const props = withDefaults(
  defineProps<{
    page: number;
    totalPages: number;
    totalItems: number;
    pageSize: number;
  }>(),
  {
    page: 1,
    totalPages: 1,
    totalItems: 0,
    pageSize: 10,
  }
);

const emit = defineEmits<{
  prev: [];
  next: [];
}>();

const start = computed(() => {
  if (props.totalItems === 0) return 0;
  return (props.page - 1) * props.pageSize + 1;
});

const end = computed(() => Math.min(props.page * props.pageSize, props.totalItems));
</script>

<template>
  <div class="ui-pagination">
    <span>Results: {{ start }} - {{ end }} of {{ totalItems }}</span>

    <div>
      <button class="ui-btn ui-btn--ghost ui-btn--sm" type="button" :disabled="page <= 1" @click="emit('prev')">
        Previous
      </button>

      <span>{{ page }} / {{ totalPages }}</span>

      <button class="ui-btn ui-btn--ghost ui-btn--sm" type="button" :disabled="page >= totalPages" @click="emit('next')">
        Next
      </button>
    </div>
  </div>
</template>