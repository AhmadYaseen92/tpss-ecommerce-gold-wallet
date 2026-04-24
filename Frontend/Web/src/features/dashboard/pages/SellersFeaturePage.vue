<script setup lang="ts">
import { computed, onMounted, ref } from "vue";
import type { ReturnTypeUseMarketplace } from "../../../shared/app/store/useMarketplace";
import type { KycStatus, Seller } from "../../../shared/types/models";
import SectionCard from "../../../shared/components/SectionCard.vue";
import SearchBar from "../../../shared/components/ui/SearchBar.vue";
import Select from "../../../shared/components/ui/Select.vue";
import StatusBadge from "../../../shared/components/ui/StatusBadge.vue";
import Pagination from "../../../shared/components/ui/Pagination.vue";
import ActionDropdown from "../../../shared/components/ui/ActionDropdown.vue";
import FilterBar from "../../../shared/components/ui/FilterBar.vue";

const props = defineProps<{ marketplace: ReturnTypeUseMarketplace }>();
const search = ref("");
const kycFilter = ref("all");
const pageNumber = ref(1);
const pageSize = 20;

const filtered = computed(() => props.marketplace.state.value.sellers.filter((seller: Seller) => {
  if (kycFilter.value !== "all" && seller.kycStatus !== kycFilter.value) return false;
  if (!search.value.trim()) return true;
  const term = search.value.toLowerCase();
  return [seller.name, seller.businessName, seller.email, seller.companyCode, seller.loginEmail, seller.contactPhone]
    .join(" ").toLowerCase().includes(term);
}));

const totalPages = computed(() => Math.max(1, Math.ceil(filtered.value.length / pageSize)));
const pageItems = computed(() => {
  const start = (pageNumber.value - 1) * pageSize;
  return filtered.value.slice(start, start + pageSize);
});

const openSellerDetails = (sellerId: string) => {
  window.history.pushState({}, "", `/sellers/${sellerId}`);
  window.dispatchEvent(new PopStateEvent("popstate"));
};

type SellerAction = "approve" | "reject" | "block" | "underreview";

const availableActions = (status: KycStatus): SellerAction[] => {
  if (status === "pending" || status === "underreview") return ["approve", "reject"];
  if (status === "approved") return ["block"];
  return [];
};

const actionLabel: Record<SellerAction, string> = {
  approve: "Approve",
  reject: "Reject",
  block: "Block",
  underreview: "Set Under Review",
};

const setKyc = async (sellerId: string, action: SellerAction) => {
  if (action === "approve") await props.marketplace.approveKyc(sellerId);
  if (action === "reject") await props.marketplace.rejectKyc(sellerId);
  if (action === "block") await props.marketplace.blockKyc(sellerId);
  if (action === "underreview") await props.marketplace.markKycUnderReview(sellerId);
};

const runActionFromDropdown = async (sellerId: string, action: string) => {
  const nextAction = action as SellerAction | "";
  if (!nextAction) return;
  await setKyc(sellerId, nextAction);
};

onMounted(() => {
  if (props.marketplace.role.value === "Admin") {
    void props.marketplace.refreshMarketplaceState();
  }
});
</script>

<template>
  <SectionCard title="Seller Registration Requests">
    <FilterBar>
      <SearchBar v-model="search" placeholder="Search company, code, login email, phone" />
      <Select v-model="kycFilter"><option value="all">All KYC</option><option value="underreview">Under Review</option><option value="approved">Approved</option><option value="rejected">Rejected</option><option value="blocked">Blocked</option><option value="pending">Pending (legacy)</option></Select>
    </FilterBar>
    <table>
      <thead><tr><th>Company Name</th><th>Company Code</th><th>Login Email</th><th>Contact Phone</th><th>KYC Status</th><th>Is Active</th><th>Created Date</th><th>Reviewed Date</th><th>Actions</th></tr></thead>
      <tbody>
        <tr v-for="seller in pageItems" :key="seller.id" @click="openSellerDetails(seller.id)">
          <td>{{ seller.businessName }}</td><td>{{ seller.companyCode || '-' }}</td><td>{{ seller.loginEmail || seller.email }}</td><td>{{ seller.contactPhone || '-' }}</td>
          <td><StatusBadge :status="seller.kycStatus" /></td><td>{{ seller.isActive ? 'Yes' : 'No' }}</td><td>{{ seller.submittedAt }}</td><td>{{ seller.reviewedAt || '-' }}</td>
          <td class="actions-cell">
            <ActionDropdown @click.stop @update:model-value="runActionFromDropdown(seller.id, $event)">
              <option value="">Select action</option>
              <option v-for="action in availableActions(seller.kycStatus)" :key="`${seller.id}-${action}`" :value="action">{{ actionLabel[action] }}</option>
            </ActionDropdown>
          </td>
        </tr>
      </tbody>
    </table>
    <Pagination :page="pageNumber" :total-pages="totalPages" :total-items="filtered.length" :page-size="pageSize" @prev="pageNumber--" @next="pageNumber++" />
  </SectionCard>
</template>

<style scoped>
tr { cursor: pointer; }
.actions-cell { display: flex; gap: 6px; flex-wrap: wrap; }
</style>
