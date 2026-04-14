<script setup lang="ts">
import type { ReturnTypeUseMarketplace } from "../../../shared/app/store/useMarketplace";
import { useDashboard } from "../store/useDashboard";
import DashboardOverviewPage from "./DashboardOverviewPage.vue";

const props = defineProps<{ marketplace: ReturnTypeUseMarketplace }>();
const { dashboardPeriod, dashboardCards, chartPoints, statusSummary, categorySummary } = useDashboard(props.marketplace);
</script>

<template>
  <DashboardOverviewPage
    :dashboard-period="dashboardPeriod"
    :dashboard-cards="dashboardCards"
    :chart-points="chartPoints"
    :status-summary="statusSummary"
    :category-summary="categorySummary"
    @change-period="(period) => (dashboardPeriod = period)"
  />
</template>
