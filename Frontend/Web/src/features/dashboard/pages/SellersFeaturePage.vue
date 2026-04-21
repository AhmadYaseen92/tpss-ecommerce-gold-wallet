<script setup lang="ts">
import { computed, onMounted, ref } from "vue";
import { ElMessage } from "element-plus";
import type { ReturnTypeUseMarketplace } from "../../../shared/app/store/useMarketplace";
import { fetchSellerDetailsByAdmin } from "../../../shared/services/backendGateway";
import type { KycStatus, Seller } from "../../../shared/types/models";
import type { WebSellerDetailsDto } from "../../../shared/types/apiTypes";
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

const selectedSellerId = ref("");
const selectedSellerDetails = ref<WebSellerDetailsDto | null>(null);
const detailsLoading = ref(false);

const openSellerDetails = async (sellerId: string) => {
  selectedSellerId.value = sellerId;
  selectedSellerDetails.value = null;

  if (!props.marketplace.session.value?.accessToken) return;

  detailsLoading.value = true;
  try {
    selectedSellerDetails.value = await fetchSellerDetailsByAdmin(
      props.marketplace.session.value.accessToken,
      sellerId,
    );
  } catch (error) {
    selectedSellerDetails.value = null;
    ElMessage.error(error instanceof Error ? error.message : "Failed to load seller details.");
  } finally {
    detailsLoading.value = false;
  }
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

  const seller = props.marketplace.state.value.sellers.find((item: Seller) => item.id === sellerId);
  if (seller && selectedSellerDetails.value && selectedSellerDetails.value.id === sellerId) {
    selectedSellerDetails.value.kycStatus = seller.kycStatus;
    selectedSellerDetails.value.isActive = seller.isActive ?? selectedSellerDetails.value.isActive;
    selectedSellerDetails.value.reviewedAt = new Date().toISOString();
  }
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
        <tr v-for="seller in pageItems" :key="seller.id" :class="{ selected: selectedSellerId === seller.id }" @click="openSellerDetails(seller.id)">
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

    <div v-if="selectedSellerId" class="details-card">
      <h3>Seller Details</h3>
      <p v-if="detailsLoading">Loading details...</p>
      <template v-else-if="selectedSellerDetails">
        <div class="detail-grid">
          <p><strong>Company Name:</strong> {{ selectedSellerDetails.companyName }}</p>
          <p><strong>Company Code:</strong> {{ selectedSellerDetails.companyCode || '-' }}</p>
          <p><strong>CR Number:</strong> {{ selectedSellerDetails.commercialRegistrationNumber || '-' }}</p>
          <p><strong>VAT Number:</strong> {{ selectedSellerDetails.vatNumber || '-' }}</p>
          <p><strong>Business Activity:</strong> {{ selectedSellerDetails.businessActivity || '-' }}</p>
          <p><strong>Established Date:</strong> {{ selectedSellerDetails.establishedDate || '-' }}</p>
          <p><strong>Company Phone:</strong> {{ selectedSellerDetails.companyPhone || '-' }}</p>
          <p><strong>Company Email:</strong> {{ selectedSellerDetails.companyEmail || '-' }}</p>
          <p><strong>Login Email:</strong> {{ selectedSellerDetails.loginEmail || '-' }}</p>
          <p><strong>Website:</strong> {{ selectedSellerDetails.website || '-' }}</p>
          <p><strong>Is Active:</strong> {{ selectedSellerDetails.isActive ? 'Yes' : 'No' }}</p>
          <p><strong>KYC Status:</strong> {{ selectedSellerDetails.kycStatus }}</p>
          <p><strong>Submitted At:</strong> {{ selectedSellerDetails.submittedAt }}</p>
          <p><strong>Reviewed At:</strong> {{ selectedSellerDetails.reviewedAt || '-' }}</p>
          <p><strong>Review Notes:</strong> {{ selectedSellerDetails.reviewNotes || '-' }}</p>
          <p><strong>Description:</strong> {{ selectedSellerDetails.description || '-' }}</p>
          <p><strong>Address:</strong>
            {{ selectedSellerDetails.address ? `${selectedSellerDetails.address.country}, ${selectedSellerDetails.address.city}, ${selectedSellerDetails.address.street}, Building ${selectedSellerDetails.address.buildingNumber}, ${selectedSellerDetails.address.postalCode}` : '-' }}
          </p>
        </div>

        <h4>Managers</h4>
        <ul class="list-block">
          <li v-for="(item, idx) in selectedSellerDetails.managers" :key="`manager-${idx}`">
            {{ item.fullName }} ({{ item.positionTitle }}) - {{ item.emailAddress }} / {{ item.mobileNumber }} - {{ item.idType }} {{ item.idNumber }} <span v-if="item.isPrimary">[Primary]</span>
          </li>
        </ul>

        <h4>Branches</h4>
        <ul class="list-block">
          <li v-for="(item, idx) in selectedSellerDetails.branches" :key="`branch-${idx}`">
            {{ item.branchName }} - {{ item.country }}, {{ item.city }}, {{ item.fullAddress }} ({{ item.phoneNumber }}) <span v-if="item.isMainBranch">[Main]</span>
          </li>
        </ul>

        <h4>Bank Accounts</h4>
        <ul class="list-block">
          <li v-for="(item, idx) in selectedSellerDetails.bankAccounts" :key="`bank-${idx}`">
            {{ item.bankName }} / {{ item.accountHolderName }} / {{ item.accountNumber }} / {{ item.iban }} / {{ item.currency }} <span v-if="item.isMainAccount">[Main]</span>
          </li>
        </ul>

        <h4>Uploaded Files</h4>
        <ul class="list-block">
          <li v-for="(doc, idx) in selectedSellerDetails.documents" :key="`doc-${idx}`">
            <strong>{{ doc.documentType }}:</strong>
            <a :href="doc.filePath" target="_blank" rel="noopener noreferrer">{{ doc.fileName || doc.filePath }}</a>
            <span> ({{ doc.contentType || 'unknown type' }}, uploaded {{ doc.uploadedAtUtc }})</span>
          </li>
        </ul>

        <div class="detail-actions">
          <button
            v-for="action in availableActions(selectedSellerDetails.kycStatus as KycStatus)"
            :key="`detail-${selectedSellerDetails.id}-${action}`"
            :class="{ danger: isDangerAction(action) }"
            @click="setKyc(selectedSellerDetails.id, action)"
          >
            {{ actionLabel[action] }}
          </button>
        </div>
      </template>
      <p v-else>No seller details available.</p>
    </div>
  </SectionCard>
</template>

<style scoped>
.filters { display:grid; grid-template-columns:1fr 220px; gap:10px; margin-bottom:12px; }
.pager { margin-top: 10px; display:flex; gap:8px; align-items:center; justify-content:flex-end; }
tr { cursor: pointer; }
.actions-cell { display: flex; gap: 6px; flex-wrap: wrap; }
.danger { background: #fee2e2; border-color: #fca5a5; }
.selected { background: #f8fafc; }
.details-card { margin-top: 16px; border-top: 1px solid #e5e7eb; padding-top: 14px; display: grid; gap: 10px; }
.detail-grid { display:grid; grid-template-columns: repeat(2, minmax(0,1fr)); gap:8px 14px; }
.list-block { margin: 0; padding-left: 18px; display: grid; gap: 6px; }
.detail-actions { display:flex; gap:8px; flex-wrap: wrap; }
</style>
