<script setup lang="ts">
import { onMounted } from "vue";
import type { ReturnTypeUseMarketplace } from "../../../shared/app/store/useMarketplace";
import { useReports } from "../store/useReports";
import ReportsPage from "./ReportsPage.vue";
import Card from "../../../shared/components/ui/Card.vue";
import PageHeader from "../../../shared/components/ui/PageHeader.vue";
import Button from "../../../shared/components/ui/Button.vue";

const props = defineProps<{ marketplace: ReturnTypeUseMarketplace }>();
const {
  reportFilters,
  reportTypeCards,
  summaryMetrics,
  tableData,
  loading,
  totalPages,
  categories,
  generateReports,
  resetFilters,
  exportCsv,
  exportExcel,
  printReport,
  setSort,
  changePage,
  selectReportType
} = useReports(props.marketplace);

onMounted(() => {
  if (props.marketplace.role.value === "Admin") {
    void props.marketplace.refreshMarketplaceState();
  }
  const initialType = reportTypeCards.value[0]?.key ?? "sales";
  selectReportType(initialType);
});
</script>

<template>
  <section class="dashboard-screen">
    <PageHeader title="Reports" subtitle="Generate operational, sales, investor, and invoice analytics.">
      <Button size="sm" variant="secondary" @click="generateReports">Refresh</Button>
    </PageHeader>

    <Card>
      <ReportsPage
        :role="marketplace.role.value"
        :sellers="marketplace.state.value.sellers"
        :investors="marketplace.state.value.investors"
        :products="marketplace.state.value.products"
        :categories="categories"
        :report-filters="reportFilters"
        :report-type-cards="reportTypeCards"
        :summary-metrics="summaryMetrics"
        :loading="loading"
        :table-data="tableData"
        :total-pages="totalPages"
        @generate="generateReports"
        @reset="resetFilters"
        @sort="setSort"
        @page="changePage"
        @csv="exportCsv"
        @excel="exportExcel"
        @print="printReport"
        @type-selected="selectReportType"
      />
    </Card>
  </section>
</template>
