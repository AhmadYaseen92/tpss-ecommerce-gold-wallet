<script setup lang="ts">
import type { ReturnTypeUseMarketplace } from "../../../shared/app/store/useMarketplace";
import { useTransactions } from "../store/useTransactions";
import TransactionsPage from "./TransactionsPage.vue";
import { statusClass } from "../../../shared/services/statusStyles";
import SectionCard from "../../../shared/components/SectionCard.vue";

const props = defineProps<{ marketplace: ReturnTypeUseMarketplace }>();
const { transactionStatusDraft, transactionsView, selectedTransaction, viewTransaction, saveTransactionStatus } = useTransactions(props.marketplace);

const updateStatusDraft = (value: "pending" | "approved" | "rejected") => {
  transactionStatusDraft.value = value;
};
</script>

<template>
  <SectionCard title="Transactions">
    <TransactionsPage :items="transactionsView" :selected="selectedTransaction" :status-draft="transactionStatusDraft" :status-class="statusClass" @view="viewTransaction" @save-status="saveTransactionStatus" @update-status="updateStatusDraft" />
  </SectionCard>
</template>
