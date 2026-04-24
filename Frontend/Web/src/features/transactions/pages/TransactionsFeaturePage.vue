<script setup lang="ts">
import { computed, onMounted, onUnmounted, ref } from "vue";
import type { ReturnTypeUseMarketplace } from "../../../shared/app/store/useMarketplace";
import { useTransactions } from "../store/useTransactions";
import TransactionsPage from "./TransactionsPage.vue";
import TransactionDetailsPage from "./TransactionDetailsPage.vue";
import SectionCard from "../../../shared/components/SectionCard.vue";
import SearchBar from "../../../shared/components/ui/SearchBar.vue";
import Select from "../../../shared/components/ui/Select.vue";
import FilterBar from "../../../shared/components/ui/FilterBar.vue";
import Pagination from "../../../shared/components/ui/Pagination.vue";
import Button from "../../../shared/components/ui/Button.vue";

const props = defineProps<{ marketplace: ReturnTypeUseMarketplace }>();
const { transactionsView, viewTransaction, searchTerm, statusFilter, typeFilter, sellerFilter } = useTransactions(props.marketplace);
const sellers = computed(() => props.marketplace.state.value.sellers);
const pageNumber = ref(1);
const pageSize = 20;
const currentPath = ref(window.location.hash.replace(/^#/, ""));
const syncPath = () => { currentPath.value = window.location.hash.replace(/^#/, ""); };
onMounted(() => window.addEventListener("hashchange", syncPath));
onMounted(() => { if (props.marketplace.role.value === "Admin") void props.marketplace.refreshMarketplaceState(); });
onUnmounted(() => { window.removeEventListener("hashchange", syncPath); });
const detailsId = computed(() => currentPath.value.match(/^\/transactions\/(.+)$/)?.[1] ?? null);
const detailsItem = computed(() => transactionsView.value.find((item: { id: string }) => item.id === detailsId.value) ?? null);
const totalPages = computed(() => Math.max(1, Math.ceil(transactionsView.value.length / pageSize)));
const pagedItems = computed(() => transactionsView.value.slice((pageNumber.value - 1) * pageSize, (pageNumber.value - 1) * pageSize + pageSize));

const quickStatus = async (id: string, status: "pending" | "approved" | "rejected" | "delivered" | "cancelled") => {
  const current = transactionsView.value.find((x: { id: string; status: string; transactionType?: string }) => x.id === id);
  const canUpdatePending = current?.status === "pending";
  const canUpdatePendingDelivered = current?.status === "pending_delivered" && current.transactionType?.toLowerCase() === "pickup";
  if (!canUpdatePending && !canUpdatePendingDelivered) return;
  await props.marketplace.updateRequestStatus(id, status);
};

const goDetails = (id: string) => { viewTransaction(id); window.location.hash = `#/transactions/${id}`; };
const goList = () => { window.location.hash = "#/transactions"; };
const cancelRequest = async (id: string) => {
  const current = transactionsView.value.find((x: { id: string; status: string; transactionType?: string }) => x.id === id);
  const canCancel = current?.status === "pending" || (current?.status === "pending_delivered" && current.transactionType?.toLowerCase() === "pickup");
  if (!canCancel) return;
  await props.marketplace.updateRequestStatus(id, "cancelled");
};
</script>

<template>
  <SectionCard v-if="detailsId" title="Transaction Details">
    <template #actions><Button @click="goList">← Back to Transactions</Button></template>
    <TransactionDetailsPage :item="detailsItem" />
  </SectionCard>
  <SectionCard v-else title="Transactions">
    <FilterBar>
      <SearchBar v-model="searchTerm" placeholder="Search by ID, investor, product, category..." />
      <Select v-model="statusFilter"><option value="all">All statuses</option><option value="pending">Pending</option><option value="pending_delivered">Pending - Delivered</option><option value="delivered">Delivered</option><option value="cancelled">Canceled</option><option value="approved">Approved</option><option value="rejected">Rejected</option></Select>
      <Select v-model="typeFilter"><option value="all">All types</option><option value="buy">Buy</option><option value="sell">Sell</option><option value="transfer">Transfer</option><option value="gift">Gift</option><option value="pickup">Pickup</option><option value="withdrawal">Withdrawal</option></Select>
      <Select v-if="marketplace.role.value === 'Admin'" v-model="sellerFilter"><option value="all">All sellers</option><option v-for="seller in sellers" :key="seller.id" :value="seller.id">{{ seller.name }}</option></Select>
    </FilterBar>
    <TransactionsPage :items="pagedItems" @view="goDetails" @quick-status="quickStatus" @cancel-request="cancelRequest" />
    <Pagination :page="pageNumber" :total-pages="totalPages" :total-items="transactionsView.length" :page-size="pageSize" @prev="pageNumber--" @next="pageNumber++" />
  </SectionCard>
</template>
