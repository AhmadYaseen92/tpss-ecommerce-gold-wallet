<script setup lang="ts">
import type { ReturnTypeUseMarketplace } from "../../dashboard/store/useMarketplace";
import { useTransactions } from "../store/useTransactions";
import TransactionsPage from "./TransactionsPage.vue";
import { statusClass } from "../../../shared/services/statusStyles";

const props = defineProps<{ marketplace: ReturnTypeUseMarketplace }>();
const tx = useTransactions(props.marketplace);
const updateStatusDraft = (value: "pending" | "approved" | "rejected") => {
  tx.transactionStatusDraft.value = value;
};
</script>

<template>
  <TransactionsPage :items="tx.transactionsView" :selected="tx.selectedTransaction" :status-draft="tx.transactionStatusDraft" :status-class="statusClass" @view="tx.viewTransaction" @save-status="tx.saveTransactionStatus" @update-status="updateStatusDraft" />
</template>
