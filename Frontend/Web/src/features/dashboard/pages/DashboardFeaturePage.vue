<script setup lang="ts">
import { onMounted } from "vue";
import type { ReturnTypeUseMarketplace } from "../../../shared/app/store/useMarketplace";
import { useDashboard } from "../store/useDashboard";
import DashboardOverviewPage from "./DashboardOverviewPage.vue";

const props = defineProps<{ marketplace: ReturnTypeUseMarketplace }>();
const { dashboardPeriod, dashboardCards, statusSummary, categorySummary, statusRing, categoryRing, recentTransactions, categoryTransactionSeries, categoryCartSeries, pendingKycRequests } = useDashboard(props.marketplace);

onMounted(() => {
  void props.marketplace.refreshMarketplaceState();
});
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
    :pending-kyc-requests="pendingKycRequests"
  />
</template>
