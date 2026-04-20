<script setup lang="ts">
import { onMounted } from "vue";
import type { ReturnTypeUseMarketplace } from "../../../shared/app/store/useMarketplace";
import { useReports } from "../store/useReports";
import ReportsPage from "./ReportsPage.vue";
import SectionCard from "../../../shared/components/SectionCard.vue";

const props = defineProps<{ marketplace: ReturnTypeUseMarketplace }>();
const { reportFilters, reportTypeCards, generatedReports, generateReports, downloadReport, downloadPdf } = useReports(props.marketplace);

onMounted(() => {
  if (props.marketplace.role.value === "admin") {
    void props.marketplace.refreshMarketplaceState();
  }
});
</script>

<template>
  <SectionCard title="Reports Generator">
    <ReportsPage
      :role="marketplace.role.value"
      :sellers="marketplace.state.value.sellers"
      :report-filters="reportFilters"
      :report-type-cards="reportTypeCards"
      :rows="generatedReports"
      @generate="generateReports"
      @excel="downloadReport"
      @pdf="downloadPdf"
    />
  </SectionCard>
</template>
