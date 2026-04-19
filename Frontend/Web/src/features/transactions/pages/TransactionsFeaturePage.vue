<script setup lang="ts">
import { computed, onMounted, onUnmounted, ref } from "vue";
import type { ReturnTypeUseMarketplace } from "../../../shared/app/store/useMarketplace";
import { useTransactions } from "../store/useTransactions";
import TransactionsPage from "./TransactionsPage.vue";
import TransactionDetailsPage from "./TransactionDetailsPage.vue";
import { statusClass } from "../../../shared/services/statusStyles";
import SectionCard from "../../../shared/components/SectionCard.vue";

const props = defineProps<{ marketplace: ReturnTypeUseMarketplace }>();
const { transactionsView, viewTransaction, searchTerm, statusFilter, typeFilter } = useTransactions(props.marketplace);
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

const cancelRequest = async (id: string) => {
  const current = transactionsView.value.find((x) => x.id === id);
  if (!current || current.status !== "pending") return;
  const confirmed = window.confirm(`Cancel pending request ${id}?`);
  if (!confirmed) return;
  await props.marketplace.updateRequestStatus(id, "rejected");
};
</script>

<template>
  <SectionCard v-if="detailsId" title="Transaction Details">
    <template #actions><button @click="goList">← Back to Transactions</button></template>
    <TransactionDetailsPage :item="detailsItem" />
  </SectionCard>
  <SectionCard v-else title="Transactions">
    <div class="filters">
      <input v-model="searchTerm" placeholder="Search by ID, investor, product, category..." />
      <select v-model="statusFilter">
        <option value="all">All statuses</option>
        <option value="pending">Pending</option>
        <option value="pending_delivered">Pending - Delivered</option>
        <option value="delivered">Delivered</option>
        <option value="approved">Approved</option>
        <option value="rejected">Rejected</option>
      </select>
      <select v-model="typeFilter">
        <option value="all">All types</option>
        <option value="buy">Buy</option>
        <option value="sell">Sell</option>
        <option value="transfer">Transfer</option>
        <option value="gift">Gift</option>
        <option value="pickup">Pickup</option>
        <option value="withdrawal">Withdrawal</option>
      </select>
    </div>
    <TransactionsPage :items="transactionsView" :status-class="statusClass" @view="goDetails" @quick-status="quickStatus" @cancel-request="cancelRequest" />
  </SectionCard>
</template>


<style scoped>
.filters {
  display: grid;
  grid-template-columns: 1fr 180px 180px;
  gap: 10px;
  margin-bottom: 12px;
}

.filters input,
.filters select {
  border: 1px solid #d4d4d8;
  border-radius: 8px;
  padding: 8px 10px;
}
</style>
