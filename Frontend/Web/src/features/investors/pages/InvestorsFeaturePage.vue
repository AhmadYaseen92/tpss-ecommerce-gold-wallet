<script setup lang="ts">
import type { ReturnTypeUseMarketplace } from "../../../shared/app/store/useMarketplace";
import { useInvestors } from "../store/useInvestors";
import InvestorsPage from "./InvestorsPage.vue";
import { statusClass } from "../../../shared/services/statusStyles";
import SectionCard from "../../../shared/components/SectionCard.vue";

const props = defineProps<{ marketplace: ReturnTypeUseMarketplace }>();
const { selectedInvestorId, investorRows, selectedInvestor, toggleInvestorStatus } = useInvestors(props.marketplace);

const viewInvestor = (id: string) => {
  selectedInvestorId.value = id;
};
</script>

<template>
  <SectionCard title="Investors">
    <InvestorsPage :investors="investorRows" :selected="selectedInvestor" :status-class="statusClass" @view="viewInvestor" @toggle="toggleInvestorStatus" />
  </SectionCard>
</template>
