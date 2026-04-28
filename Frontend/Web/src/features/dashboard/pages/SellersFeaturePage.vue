<script setup lang="ts">
import { computed, onMounted, ref, watch } from "vue";
import type { ReturnTypeUseMarketplace } from "../../../shared/app/store/useMarketplace";
import type { KycStatus, Seller } from "../../../shared/types/models";

import Card from "../../../shared/components/ui/Card.vue";
import PageHeader from "../../../shared/components/ui/PageHeader.vue";
import SearchBar from "../../../shared/components/ui/SearchBar.vue";
import Select from "../../../shared/components/ui/Select.vue";
import StatusBadge from "../../../shared/components/ui/StatusBadge.vue";
import Pagination from "../../../shared/components/ui/Pagination.vue";
import ActionDropdown from "../../../shared/components/ui/ActionDropdown.vue";
import FilterBar from "../../../shared/components/ui/FilterBar.vue";
import Button from "../../../shared/components/ui/Button.vue";

const props = defineProps<{
  marketplace: ReturnTypeUseMarketplace;
}>();

const search = ref("");
const kycFilter = ref("all");
const pageNumber = ref(1);
const pageSize = 20;

const filtered = computed(() =>
  props.marketplace.state.value.sellers.filter((seller: Seller) => {
    if (kycFilter.value !== "all" && seller.kycStatus !== kycFilter.value) return false;

    const term = search.value.trim().toLowerCase();
    if (!term) return true;

    return [
      seller.id,
      String(seller.sellerId ?? ""),
      seller.name,
      seller.businessName,
      seller.email,
      seller.companyCode,
      seller.loginEmail,
      seller.contactPhone,
    ]
      .filter(Boolean)
      .join(" ")
      .toLowerCase()
      .includes(term);
  })
);

const totalPages = computed(() => Math.max(1, Math.ceil(filtered.value.length / pageSize)));
const pendingKycCount = computed(() =>
  props.marketplace.state.value.sellers.filter((seller: Seller) => {
    const status = String(seller.kycStatus ?? "").toLowerCase();
    return status === "pending" || status === "underreview";
  }).length
);

const pageItems = computed(() => {
  const start = (pageNumber.value - 1) * pageSize;
  return filtered.value.slice(start, start + pageSize);
});

watch([search, kycFilter], () => {
  pageNumber.value = 1;
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
  if (action === "approve") {
    const note = window.prompt("Optional approval note (will be included in email/WhatsApp template):", "") ?? "";
    await props.marketplace.approveKyc(sellerId, note.trim() || undefined);
  }
  if (action === "reject") {
    const note = window.prompt("Optional rejection note (will be included in email/WhatsApp template):", "") ?? "";
    await props.marketplace.rejectKyc(sellerId, note.trim() || undefined);
  }
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
  <section class="dashboard-screen">
    <PageHeader
      title="Seller Registration Requests"
      subtitle="Review seller accounts, KYC status, contact details, and approval actions."
    >
      <div class="ui-row-actions">
        <span class="kyc-pending-widget">
          KYC Pending
          <strong class="kyc-pending-badge">{{ pendingKycCount }}</strong>
        </span>
      </div>
      <Button variant="secondary" size="sm" @click="marketplace.refreshMarketplaceState">
        Refresh
      </Button>
    </PageHeader>

    <Card>
      <FilterBar>
        <SearchBar
          v-model="search"
          placeholder="Search seller ID, company, code, login email, phone"
        />

        <Select v-model="kycFilter">
          <option value="all">All KYC</option>
          <option value="underreview">Under Review</option>
          <option value="approved">Approved</option>
          <option value="rejected">Rejected</option>
          <option value="blocked">Blocked</option>
          <option value="pending">Pending</option>
        </Select>
      </FilterBar>

      <div v-if="filtered.length === 0" class="ui-state">
        No sellers match the selected filters.
      </div>

      <template v-else>
        <div class="ui-table-wrap">
          <table>
            <thead>
              <tr>
                <th>Company Name</th>
                <th>Seller ID</th>
                <th>Company Code</th>
                <th>Login Email</th>
                <th>Contact Phone</th>
                <th>KYC Status</th>
                <th>Active</th>
                <th>Created Date</th>
                <th>Reviewed Date</th>
                <th class="text-right">Actions</th>
              </tr>
            </thead>

            <tbody>
              <tr
                v-for="seller in pageItems"
                :key="seller.id"
                class="clickable-row"
                @click="openSellerDetails(seller.id)"
              >
                <td>
                  <strong>{{ seller.businessName || seller.name || "-" }}</strong>
                </td>
                <td>{{ seller.id }}</td>
                <td>{{ seller.companyCode || "-" }}</td>
                <td>{{ seller.loginEmail || seller.email || "-" }}</td>
                <td>{{ seller.contactPhone || "-" }}</td>
                <td>
                  <StatusBadge :status="seller.kycStatus" />
                </td>
                <td>
                  <StatusBadge :status="seller.isActive ? 'Active' : 'Inactive'" />
                </td>
                <td>{{ seller.submittedAt || "-" }}</td>
                <td>{{ seller.reviewedAt || "-" }}</td>
                <td @click.stop>
                  <div class="ui-row-actions">
                    <ActionDropdown
                      :disabled="availableActions(seller.kycStatus).length === 0"
                      @update:model-value="runActionFromDropdown(seller.id, $event)"
                    >
                      <option value="">Select action</option>
                      <option
                        v-for="action in availableActions(seller.kycStatus)"
                        :key="`${seller.id}-${action}`"
                        :value="action"
                      >
                        {{ actionLabel[action] }}
                      </option>
                    </ActionDropdown>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        </div>

        <Pagination
          :page="pageNumber"
          :total-pages="totalPages"
          :total-items="filtered.length"
          :page-size="pageSize"
          @prev="pageNumber = Math.max(1, pageNumber - 1)"
          @next="pageNumber = Math.min(totalPages, pageNumber + 1)"
        />
      </template>
    </Card>
  </section>
</template>

<style scoped>
.kyc-pending-widget {
  display: inline-flex;
  align-items: center;
  gap: 0.5rem;
  border: 1px solid var(--border);
  border-radius: 999px;
  padding: 0.25rem 0.75rem;
  background: var(--surface-elevated);
  font-weight: 600;
}

.kyc-pending-badge {
  display: inline-grid;
  place-items: center;
  min-width: 1.5rem;
  height: 1.5rem;
  border-radius: 999px;
  background: #f59e0b;
  color: #111827;
  padding: 0 0.3rem;
}
</style>
