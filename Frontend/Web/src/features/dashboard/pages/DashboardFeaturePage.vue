<script setup lang="ts">
import type { ReturnTypeUseMarketplace } from "../../../shared/app/store/useMarketplace";
import { useDashboard } from "../store/useDashboard";
import DashboardOverviewPage from "./DashboardOverviewPage.vue";

const props = defineProps<{ marketplace: ReturnTypeUseMarketplace }>();
const { dashboardPeriod, dashboardCards, statusSummary, categorySummary, statusRing, categoryRing, recentTransactions } = useDashboard(props.marketplace);
const setDashboardPeriod = (period: "today" | "week" | "month") => {
  dashboardPeriod.value = period;
};
</script>

<template>
  <DashboardOverviewPage
    :dashboard-period="dashboardPeriod"
    :dashboard-cards="dashboardCards"
    :status-summary="statusSummary"
    :category-summary="categorySummary"
    :status-ring="statusRing"
    :category-ring="categoryRing"
    :recent-transactions="recentTransactions"
    @change-period="setDashboardPeriod"
  />
</template>
