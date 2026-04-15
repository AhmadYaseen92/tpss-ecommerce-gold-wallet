<script setup lang="ts">
import { computed, onMounted, onUnmounted, ref } from "vue";
import type { ReturnTypeUseMarketplace } from "../../../shared/app/store/useMarketplace";
import { useTransactions } from "../store/useTransactions";
import TransactionsPage from "./TransactionsPage.vue";
import TransactionDetailsPage from "./TransactionDetailsPage.vue";
import { statusClass } from "../../../shared/services/statusStyles";
import SectionCard from "../../../shared/components/SectionCard.vue";

const props = defineProps<{ marketplace: ReturnTypeUseMarketplace }>();
const { transactionsView, viewTransaction } = useTransactions(props.marketplace);
const currentPath = ref(window.location.hash.replace(/^#/, ""));
const syncPath = () => {
  currentPath.value = window.location.hash.replace(/^#/, "");
};
onMounted(() => window.addEventListener("hashchange", syncPath));
onUnmounted(() => {
  window.removeEventListener("hashchange", syncPath);
});
const detailsId = computed(() => {
  const match = currentPath.value.match(/^\/transactions\/(.+)$/);
  return match?.[1] ?? null;
});
const detailsItem = computed(() => transactionsView.value.find((item) => item.id === detailsId.value) ?? null);

const quickStatus = async (id: string, status: "pending" | "approved" | "rejected") => {
  const current = transactionsView.value.find((x) => x.id === id);
  if (current && current.status !== "pending") {
    window.alert("Only pending requests can be updated.");
    return;
  }
  const confirmed = window.confirm(`Confirm changing request ${id} to ${status}?`);
  if (!confirmed) return;
  await props.marketplace.updateRequestStatus(id, status);
};

const goDetails = (id: string) => {
  viewTransaction(id);
  window.location.hash = `#/transactions/${id}`;
};

const goList = () => {
  window.location.hash = "#/transactions";
};
</script>

<template>
  <SectionCard v-if="detailsId" title="Transaction Details">
    <template #actions><button @click="goList">← Back to Transactions</button></template>
    <TransactionDetailsPage :item="detailsItem" />
  </SectionCard>
  <SectionCard v-else title="Transactions">
    <TransactionsPage :items="transactionsView" :status-class="statusClass" @view="goDetails" @quick-status="quickStatus" />
  </SectionCard>
</template>
