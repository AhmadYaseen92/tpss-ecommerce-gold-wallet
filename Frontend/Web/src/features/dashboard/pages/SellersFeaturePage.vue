<script setup lang="ts">
import { computed, onMounted, ref } from "vue";
import type { ReturnTypeUseMarketplace } from "../../../shared/app/store/useMarketplace";
import type { KycStatus, Seller } from "../../../shared/types/models";
import SectionCard from "../../../shared/components/SectionCard.vue";

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
  if (status === "pending") return ["underreview", "approve", "reject", "block"];
  if (status === "underreview") return ["approve", "reject", "block"];
  if (status === "approved") return ["underreview", "block"];
  if (status === "rejected") return ["underreview", "approve", "block"];
  return ["underreview", "approve"];
};

const actionLabel: Record<SellerAction, string> = {
  approve: "Approve",
  reject: "Reject",
  block: "Block",
  underreview: "Set Under Review",
};

const isDangerAction = (action: SellerAction) => action === "reject" || action === "block";

const setKyc = async (sellerId: string, action: SellerAction) => {
  if (action === "approve") await props.marketplace.approveKyc(sellerId);
  if (action === "reject") await props.marketplace.rejectKyc(sellerId);
  if (action === "block") await props.marketplace.blockKyc(sellerId);
  if (action === "underreview") await props.marketplace.markKycUnderReview(sellerId);

};

onMounted(() => {
  if (props.marketplace.role.value === "Admin") {
    void props.marketplace.refreshMarketplaceState();
  }
});
</script>

<template>
  <SectionCard title="Seller Registration Requests">
    <div class="filters">
      <input v-model="search" placeholder="Search company, code, login email, phone" />
      <select v-model="kycFilter"><option value="all">All KYC</option><option value="pending">Pending</option><option value="underreview">Under Review</option><option value="approved">Approved</option><option value="rejected">Rejected</option><option value="blocked">Blocked</option></select>
    </div>
    <table>
      <thead><tr><th>Company Name</th><th>Company Code</th><th>Login Email</th><th>Contact Phone</th><th>KYC Status</th><th>Is Active</th><th>Created Date</th><th>Reviewed Date</th><th>Actions</th></tr></thead>
      <tbody>
        <tr v-for="seller in pageItems" :key="seller.id" @click="openSellerDetails(seller.id)">
          <td>{{ seller.businessName }}</td><td>{{ seller.companyCode || '-' }}</td><td>{{ seller.loginEmail || seller.email }}</td><td>{{ seller.contactPhone || '-' }}</td>
          <td>{{ seller.kycStatus }}</td><td>{{ seller.isActive ? 'Yes' : 'No' }}</td><td>{{ seller.submittedAt }}</td><td>{{ seller.reviewedAt || '-' }}</td>
          <td class="actions-cell">
            <button
              v-for="action in availableActions(seller.kycStatus)"
              :key="`${seller.id}-${action}`"
              :class="{ danger: isDangerAction(action) }"
              @click.stop="setKyc(seller.id, action)"
            >
              {{ actionLabel[action] }}
            </button>
          </td>
        </tr>
      </tbody>
    </table>
    <div class="pager">Results: {{ (pageNumber - 1) * pageSize + 1 }} - {{ Math.min(pageNumber * pageSize, filtered.length) }} of {{ filtered.length }}
      <button :disabled="pageNumber <= 1" @click="pageNumber--">&lt;</button>
      <span>{{ pageNumber }} / {{ totalPages }}</span>
      <button :disabled="pageNumber >= totalPages" @click="pageNumber++">&gt;</button>
    </div>

  </SectionCard>
</template>

<style scoped>
.filters { display:grid; grid-template-columns:1fr 220px; gap:10px; margin-bottom:12px; }
.pager { margin-top: 10px; display:flex; gap:8px; align-items:center; justify-content:flex-end; }
tr { cursor: pointer; }
.actions-cell { display: flex; gap: 6px; flex-wrap: wrap; }
.danger { background: #fee2e2; border-color: #fca5a5; }
</style>
