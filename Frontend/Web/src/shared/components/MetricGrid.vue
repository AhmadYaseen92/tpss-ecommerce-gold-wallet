<script setup lang="ts">
import type { ReportMetric } from "../types/models";

defineProps<{ metrics: ReportMetric[] }>();
</script>

<template>
  <div class="metric-grid">
    <article v-for="metric in metrics" :key="metric.title" class="metric-card">
      <h3>{{ metric.title }}</h3>
      <strong>{{ metric.value }}</strong>
      <span>{{ metric.trend }}</span>
    </article>
  </div>
</template>
