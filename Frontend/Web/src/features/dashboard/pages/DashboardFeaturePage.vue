<script setup lang="ts">
import type { ReturnTypeUseMarketplace } from "../../../shared/app/store/useMarketplace";
import { useDashboard } from "../store/useDashboard";
import DashboardOverviewPage from "./DashboardOverviewPage.vue";

const props = defineProps<{ marketplace: ReturnTypeUseMarketplace }>();
const { dashboardPeriod, dashboardCards, statusSummary, categorySummary, statusRing, categoryRing, recentTransactions, categoryTransactionSeries, categoryCartSeries } = useDashboard(props.marketplace);
</script>

<template>
  <DashboardOverviewPage
    :dashboard-period="dashboardPeriod"
    :dashboard-cards="dashboardCards"
    :status-summary="statusSummary"
    :category-summary="categorySummary"
    :status-ring="statusRing"
    :category-ring="categoryRing"
    :category-transaction-series="categoryTransactionSeries"
    :category-cart-series="categoryCartSeries"
    :recent-transactions="recentTransactions"
  />
</template>
