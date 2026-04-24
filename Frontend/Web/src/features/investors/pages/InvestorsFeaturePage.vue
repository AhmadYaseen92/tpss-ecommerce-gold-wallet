<script setup lang="ts">
import { computed, onMounted, ref } from "vue";
import type { ReturnTypeUseMarketplace } from "../../../shared/app/store/useMarketplace";
import { useInvestors } from "../store/useInvestors";
import InvestorsPage from "./InvestorsPage.vue";
import SectionCard from "../../../shared/components/SectionCard.vue";
import SearchBar from "../../../shared/components/ui/SearchBar.vue";
import Select from "../../../shared/components/ui/Select.vue";
import FilterBar from "../../../shared/components/ui/FilterBar.vue";
import Pagination from "../../../shared/components/ui/Pagination.vue";

const props = defineProps<{ marketplace: ReturnTypeUseMarketplace }>();
const { selectedInvestorId, investorRows, selectedInvestor, toggleInvestorStatus } = useInvestors(props.marketplace);
const search = ref("");
const status = ref("all");
const pageNumber = ref(1);
const pageSize = 20;
const filteredRows = computed(() =>
  investorRows.value.filter((item: { status: string; fullName: string; email: string }) => {
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
  if (props.marketplace.role.value === "Admin") {
    void props.marketplace.refreshMarketplaceState();
  }
});
</script>

<template>
  <SectionCard title="Investors">
    <FilterBar>
      <SearchBar v-model="search" placeholder="Search investor" />
      <Select v-model="status"><option value="all">All status</option><option value="active">Active</option><option value="review">Review</option><option value="blocked">Blocked</option></Select>
    </FilterBar>
    <InvestorsPage :investors="pagedRows" :selected="selectedInvestor" @view="viewInvestor" @toggle="toggleInvestorStatus" />
    <Pagination :page="pageNumber" :total-pages="totalPages" :total-items="filteredRows.length" :page-size="pageSize" @prev="pageNumber--" @next="pageNumber++" />
  </SectionCard>
</template>
