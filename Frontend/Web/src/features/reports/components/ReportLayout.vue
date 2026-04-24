<script setup lang="ts">
import MetricGrid from "../../../shared/components/MetricGrid.vue";
import type { ReportMetric } from "../../../shared/types/models";
import type { ReportTableData } from "../types/reportTypes";

defineProps<{
  title: string;
  loading: boolean;
  empty: boolean;
  summaryMetrics: ReportMetric[];
  table: ReportTableData;
  page: number;
  totalPages: number;
}>();

const emit = defineEmits<{ sort: [key: string]; page: [delta: number] }>();
</script>

<template>
  <div class="report-layout">
    <h3>{{ title }}</h3>
    <MetricGrid :metrics="summaryMetrics" />

    <div v-if="loading" class="report-state">Loading report...</div>
    <div v-else-if="empty" class="report-state">No records found for the current filters.</div>
    <div v-else class="report-table-wrap">
      <table>
        <thead>
          <tr>
            <th v-for="header in table.headers" :key="header">
              <button class="sort-btn" @click="emit('sort', header)">{{ header }}</button>
            </th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="(row, rowIndex) in table.rows" :key="rowIndex">
            <td v-for="header in table.headers" :key="`${rowIndex}-${header}`">{{ row[header] ?? "-" }}</td>
          </tr>
          <tr class="totals-row">
            <td v-for="header in table.headers" :key="`total-${header}`">{{ table.totalsRow[header] ?? "" }}</td>
          </tr>
        </tbody>
      </table>

      <div class="report-pagination">
        <button class="ghost" :disabled="page <= 1" @click="emit('page', -1)">Previous</button>
        <span>Page {{ page }} / {{ totalPages }}</span>
        <button class="ghost" :disabled="page >= totalPages" @click="emit('page', 1)">Next</button>
      </div>
    </div>
  </div>
</template>
