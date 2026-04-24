<script setup lang="ts">
import MetricGrid from "../../../shared/components/MetricGrid.vue";
import type { ReportMetric } from "../../../shared/types/models";
import type { ReportTableData } from "../types/reportTypes";
import LoadingState from "../../../shared/components/ui/LoadingState.vue";
import EmptyState from "../../../shared/components/ui/EmptyState.vue";
import Pagination from "../../../shared/components/ui/Pagination.vue";

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

    <LoadingState v-if="loading" />
    <EmptyState v-else-if="empty" message="No records found for the current filters." />
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
          <tr class="totals-row"><td v-for="header in table.headers" :key="`total-${header}`">{{ table.totalsRow[header] ?? "" }}</td></tr>
        </tbody>
      </table>
      <Pagination :page="page" :total-pages="totalPages" :total-items="table.rows.length" :page-size="table.rows.length || 1" @prev="emit('page', -1)" @next="emit('page', 1)" />
    </div>
  </div>
</template>

<style scoped>
.report-layout { display: grid; gap: 12px; }
.report-layout h3 { margin: 0; font-size: 20px; }
.report-table-wrap { overflow: auto; border: 1px solid var(--border); border-radius: 14px; background: var(--surface); }
.report-table-wrap table { min-width: 880px; }
.report-table-wrap th { position: sticky; top: 0; background: color-mix(in srgb, var(--surface-muted) 75%, white 25%); z-index: 1; }
.report-table-wrap tr:nth-child(even) td { background: color-mix(in srgb, var(--surface) 94%, #f6f7f9 6%); }
.sort-btn { all: unset; cursor: pointer; font-weight: 700; font-size: 13px; }
.totals-row td { background: color-mix(in srgb, var(--surface-muted) 70%, transparent); font-weight: 700; }
</style>
