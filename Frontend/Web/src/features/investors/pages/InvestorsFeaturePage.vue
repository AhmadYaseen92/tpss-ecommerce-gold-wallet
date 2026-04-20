<script setup lang="ts">
import { computed, onMounted, ref } from "vue";
import type { ReturnTypeUseMarketplace } from "../../../shared/app/store/useMarketplace";
import { useInvestors } from "../store/useInvestors";
import InvestorsPage from "./InvestorsPage.vue";
import { statusClass } from "../../../shared/services/statusStyles";
import SectionCard from "../../../shared/components/SectionCard.vue";

const props = defineProps<{ marketplace: ReturnTypeUseMarketplace }>();
const { selectedInvestorId, investorRows, selectedInvestor, toggleInvestorStatus } = useInvestors(props.marketplace);
const search = ref("");
const status = ref("all");
const pageNumber = ref(1);
const pageSize = 20;
const filteredRows = computed(() =>
  investorRows.value.filter((item) => {
    if (status.value !== "all" && item.status !== status.value) return false;
    if (!search.value.trim()) return true;
    return `${item.fullName} ${item.email}`.toLowerCase().includes(search.value.toLowerCase());
  })
);
const totalPages = computed(() => Math.max(1, Math.ceil(filteredRows.value.length / pageSize)));
const pagedRows = computed(() => {
  const start = (pageNumber.value - 1) * pageSize;
  return filteredRows.value.slice(start, start + pageSize);
});

const viewInvestor = (id: string) => {
  selectedInvestorId.value = id;
};

onMounted(() => {
  if (props.marketplace.role.value === "admin") {
    void props.marketplace.refreshMarketplaceState();
  }
});
</script>

<template>
  <SectionCard title="Investors">
    <div class="filters">
      <input v-model="search" placeholder="Search investor" />
      <select v-model="status"><option value="all">All status</option><option value="active">Active</option><option value="review">Review</option><option value="blocked">Blocked</option></select>
    </div>
    <InvestorsPage :investors="pagedRows" :selected="selectedInvestor" :status-class="statusClass" @view="viewInvestor" @toggle="toggleInvestorStatus" />
    <div class="pager">Results: {{ (pageNumber - 1) * pageSize + 1 }} - {{ Math.min(pageNumber * pageSize, filteredRows.length) }} of {{ filteredRows.length }}
      <button :disabled="pageNumber <= 1" @click="pageNumber--">&lt;</button>
      <span>{{ pageNumber }} / {{ totalPages }}</span>
      <button :disabled="pageNumber >= totalPages" @click="pageNumber++">&gt;</button>
    </div>
  </SectionCard>
</template>

<style scoped>
.filters { display:grid; grid-template-columns:1fr 220px; gap:10px; margin-bottom:12px; }
.pager { margin-top: 10px; display:flex; gap:8px; justify-content:flex-end; align-items:center; }
</style>
