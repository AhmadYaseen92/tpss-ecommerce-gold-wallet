<script setup lang="ts">
import type { ReturnTypeUseMarketplace } from "../../dashboard/store/useMarketplace";
import { useReports } from "../store/useReports";
import ReportsPage from "./ReportsPage.vue";

const props = defineProps<{ marketplace: ReturnTypeUseMarketplace }>();
const rp = useReports(props.marketplace);
</script>

<template>
  <ReportsPage :report-filters="rp.reportFilters" :report-type-cards="rp.reportTypeCards" :rows="rp.generatedReports" @generate="rp.generateReports" @excel="rp.downloadReport" @pdf="rp.downloadPdf" />
</template>
