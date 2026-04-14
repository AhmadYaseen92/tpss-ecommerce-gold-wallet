<script setup lang="ts">
import type { ReturnTypeUseMarketplace } from "../../../shared/app/store/useMarketplace";
import { useReports } from "../store/useReports";
import ReportsPage from "./ReportsPage.vue";
import SectionCard from "../../../shared/components/SectionCard.vue";

const props = defineProps<{ marketplace: ReturnTypeUseMarketplace }>();
const rp = useReports(props.marketplace);
</script>

<template>
  <SectionCard title="Reports Generator">
    <ReportsPage :report-filters="rp.reportFilters" :report-type-cards="rp.reportTypeCards" :rows="rp.generatedReports" @generate="rp.generateReports" @excel="rp.downloadReport" @pdf="rp.downloadPdf" />
  </SectionCard>
</template>
