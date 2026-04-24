<script setup lang="ts">
import type { Investor, Product, Seller } from "../../../shared/types/models";
import type { ReportFilters, ReportTableData, ReportTypeCard } from "../types/reportTypes";
import ReportFilterPanel from "../components/ReportFilterPanel.vue";
import ReportLayout from "../components/ReportLayout.vue";
import type { ReportMetric } from "../../../shared/types/models";

const props = defineProps<{
  role: "Admin" | "Seller";
  sellers: Seller[];
  investors: Investor[];
  products: Product[];
  categories: string[];
  reportFilters: ReportFilters;
  reportTypeCards: ReportTypeCard[];
  summaryMetrics: ReportMetric[];
  loading: boolean;
  tableData: ReportTableData;
  totalPages: number;
}>();

const emit = defineEmits<{
  generate: [];
  reset: [];
  sort: [key: string];
  page: [delta: number];
  csv: [];
  excel: [];
  print: [];
}>();
</script>

<template>
  <div class="reports-page">
    <ReportFilterPanel
      :role="props.role"
      :filters="reportFilters"
      :report-types="reportTypeCards"
      :sellers="sellers"
      :investors="investors"
      :products="products"
      :categories="categories"
      @refresh="emit('generate')"
      @reset="emit('reset')"
    />

    <div class="report-actions">
      <button @click="emit('generate')">Refresh Report</button>
      <button class="ghost" @click="emit('csv')">Export CSV</button>
      <button class="ghost" @click="emit('excel')">Export Excel</button>
      <button class="ghost" @click="emit('print')">Print</button>
    </div>

    <ReportLayout
      title="Report Results"
      :loading="loading"
      :empty="!loading && tableData.rows.length === 0"
      :summary-metrics="summaryMetrics"
      :table="tableData"
      :page="reportFilters.page"
      :total-pages="totalPages"
      @sort="(key) => emit('sort', key)"
      @page="(delta) => emit('page', delta)"
    />
  </div>
</template>

<style scoped>
.reports-page { display: grid; gap: 14px; }
.report-filters-grid { display: grid; grid-template-columns: repeat(4, minmax(0, 1fr)); gap: 8px; }
.report-type-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(210px, 1fr)); gap: 8px; }
.report-type-card { border: 1px solid var(--border); background: var(--surface); border-radius: 10px; padding: 10px; text-align: left; display: grid; gap: 4px; }
.report-type-card.active { border-color: var(--primary); box-shadow: 0 0 0 1px color-mix(in srgb, var(--primary) 35%, transparent); }
.report-actions { display: flex; gap: 8px; flex-wrap: wrap; }
.report-layout { display: grid; gap: 10px; }
.report-table-wrap { overflow: auto; border: 1px solid var(--border); border-radius: 12px; background: var(--surface); }
.report-state { border: 1px dashed var(--border); border-radius: 10px; padding: 16px; color: var(--text-muted); background: var(--surface); }
.sort-btn { all: unset; cursor: pointer; font-weight: 700; }
.report-pagination { display: flex; justify-content: space-between; padding: 10px; border-top: 1px solid var(--border); }
.totals-row { background: color-mix(in srgb, var(--surface-muted) 72%, transparent); font-weight: 700; }
@media print {
  .report-filters-grid,
  .report-type-grid,
  .report-actions,
  .report-pagination,
  .side-nav,
  .top-bar { display: none !important; }
}
</style>
