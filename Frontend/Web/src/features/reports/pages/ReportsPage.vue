<script setup lang="ts">
import type { Investor, Product, Seller } from "../../../shared/types/models";
import type { ReportFilters, ReportTableData, ReportTypeCard } from "../types/reportTypes";
import ReportFilterPanel from "../components/ReportFilterPanel.vue";
import ReportLayout from "../components/ReportLayout.vue";
import Button from "../../../shared/components/ui/Button.vue";
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
  typeSelected: [type: string];
}>();
</script>

<template>
  <div class="reports-page">
    <div class="report-toolbar">
      <h3>Report Results</h3>
      <div class="report-actions">
        <Button @click="emit('generate')">Refresh Report</Button>
        <Button variant="ghost" @click="emit('csv')">Export CSV</Button>
        <Button variant="ghost" @click="emit('excel')">Export Excel</Button>
        <Button variant="ghost" @click="emit('print')">Print</Button>
      </div>
    </div>

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
      @type-selected="(type) => emit('typeSelected', type)"
    />

    <ReportLayout
      :title="`${reportTypeCards.find((card) => card.key === reportFilters.reportType)?.label ?? 'Report'} Results`"
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
.report-toolbar { display: flex; align-items: center; justify-content: space-between; gap: 10px; flex-wrap: wrap; }
.report-toolbar h3 { margin: 0; font-size: 22px; }
.report-actions { display: flex; gap: 8px; flex-wrap: wrap; margin-left: auto; }
@media print {
  .report-actions,
  .side-nav,
  .top-bar { display: none !important; }
}
</style>
