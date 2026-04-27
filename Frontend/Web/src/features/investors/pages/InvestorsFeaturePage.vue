<script setup lang="ts">
import { computed, onMounted, ref, watch } from "vue";
import type { ReturnTypeUseMarketplace } from "../../../shared/app/store/useMarketplace";
import { useInvestors } from "../store/useInvestors";
import InvestorsPage from "./InvestorsPage.vue";
import Card from "../../../shared/components/ui/Card.vue";
import PageHeader from "../../../shared/components/ui/PageHeader.vue";
import SearchBar from "../../../shared/components/ui/SearchBar.vue";
import Select from "../../../shared/components/ui/Select.vue";
import FilterBar from "../../../shared/components/ui/FilterBar.vue";
import Pagination from "../../../shared/components/ui/Pagination.vue";
import Button from "../../../shared/components/ui/Button.vue";

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
    return `${item.fullName} ${item.email} ${item.phoneNumber}`
      .toLowerCase()
      .includes(search.value.toLowerCase());
  })
);

const totalPages = computed(() => Math.max(1, Math.ceil(filteredRows.value.length / pageSize)));
const pagedRows = computed(() => {
  const start = (pageNumber.value - 1) * pageSize;
  return filteredRows.value.slice(start, start + pageSize);
});

watch([search, status], () => {
  pageNumber.value = 1;
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
  <section class="dashboard-screen">
    <PageHeader
      title="Investors"
      subtitle="Track investor status, balances, risk profile, and account activity."
    >
      <Button size="sm" variant="secondary" @click="marketplace.refreshMarketplaceState">Refresh</Button>
    </PageHeader>

    <Card>
      <FilterBar>
        <SearchBar v-model="search" placeholder="Search investor name, email, or phone" />
        <Select v-model="status">
          <option value="all">All status</option>
          <option value="active">Active</option>
          <option value="blocked">Blocked</option>
        </Select>
      </FilterBar>

      <div v-if="filteredRows.length === 0" class="ui-state">No investors found.</div>

      <template v-else>
        <InvestorsPage
          :investors="pagedRows"
          :selected="selectedInvestor"
          @view="viewInvestor"
          @toggle="toggleInvestorStatus"
        />

        <Pagination
          :page="pageNumber"
          :total-pages="totalPages"
          :total-items="filteredRows.length"
          :page-size="pageSize"
          @prev="pageNumber = Math.max(1, pageNumber - 1)"
          @next="pageNumber = Math.min(totalPages, pageNumber + 1)"
        />
      </template>
    </Card>
  </section>
</template>
