<script setup lang="ts">
import type { ReturnTypeUseMarketplace } from "../../dashboard/store/useMarketplace";
import { useInvestors } from "../store/useInvestors";
import InvestorsPage from "./InvestorsPage.vue";
import { statusClass } from "../../../shared/services/statusStyles";

const props = defineProps<{ marketplace: ReturnTypeUseMarketplace }>();
const iv = useInvestors(props.marketplace);
const viewInvestor = (id: string) => {
  iv.selectedInvestorId.value = id;
};
</script>

<template>
  <InvestorsPage :investors="iv.investorRows" :selected="iv.selectedInvestor" :status-class="statusClass" @view="viewInvestor" @toggle="iv.toggleInvestorStatus" />
</template>
