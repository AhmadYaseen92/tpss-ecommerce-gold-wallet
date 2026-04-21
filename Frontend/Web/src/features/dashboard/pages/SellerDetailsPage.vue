<script setup lang="ts">
import { computed, onMounted, ref } from "vue";
import { ElMessage } from "element-plus";
import type { ReturnTypeUseMarketplace } from "../../../shared/app/store/useMarketplace";
import { fetchSellerDetailsByAdmin } from "../../../shared/services/backendGateway";
import type { KycStatus } from "../../../shared/types/models";
import type { WebSellerDetailsDto, WebSellerDocumentDto } from "../../../shared/types/apiTypes";
import SectionCard from "../../../shared/components/SectionCard.vue";

const props = defineProps<{ marketplace: ReturnTypeUseMarketplace }>();

const loading = ref(false);
const details = ref<WebSellerDetailsDto | null>(null);
const viewerDoc = ref<WebSellerDocumentDto | null>(null);
const viewerUrl = computed(() => {
  if (!viewerDoc.value || !details.value) return "";
  return `/api/web-admin/sellers/${details.value.id}/documents/${viewerDoc.value.id}/view`;
});

const sellerIdFromPath = computed(() => {
  const parts = window.location.pathname.split("/").filter(Boolean);
  return parts.length >= 2 ? parts[1] : "";
});

const goBack = () => {
  window.history.pushState({}, "", "/sellers");
  window.dispatchEvent(new PopStateEvent("popstate"));
};

const loadDetails = async () => {
  if (!props.marketplace.session.value?.accessToken || !sellerIdFromPath.value) return;
  loading.value = true;
  try {
    details.value = await fetchSellerDetailsByAdmin(props.marketplace.session.value.accessToken, sellerIdFromPath.value);
  } catch (error) {
    ElMessage.error(error instanceof Error ? error.message : "Failed to load seller details.");
  } finally {
    loading.value = false;
  }
};

type SellerAction = "approve" | "reject" | "block" | "underreview";
const actionLabel: Record<SellerAction, string> = {
  approve: "Approve",
  reject: "Reject",
  block: "Block",
  underreview: "Set Under Review",
};
const availableActions = (status: KycStatus): SellerAction[] => {
  if (status === "pending") return ["underreview", "approve", "reject", "block"];
  if (status === "underreview") return ["approve", "reject", "block"];
  if (status === "approved") return ["underreview", "block"];
  if (status === "rejected") return ["underreview", "approve", "block"];
  return ["underreview", "approve"];
};
const setKyc = async (action: SellerAction) => {
  if (!details.value) return;
  if (action === "approve") await props.marketplace.approveKyc(details.value.id);
  if (action === "reject") await props.marketplace.rejectKyc(details.value.id);
  if (action === "block") await props.marketplace.blockKyc(details.value.id);
  if (action === "underreview") await props.marketplace.markKycUnderReview(details.value.id);
  await loadDetails();
};

onMounted(() => {
  void loadDetails();
});
</script>

<template>
  <SectionCard title="Seller Details">
    <button type="button" class="ghost" @click="goBack">← Back to Sellers</button>
    <p v-if="loading">Loading...</p>

    <template v-else-if="details">
      <section class="form-grid">
        <h3>Company Information</h3>
        <label>Company Name <input :value="details.companyName" readonly /></label>
        <label>Company Code <input :value="details.companyCode" readonly /></label>
        <label>Commercial Registration Number <input :value="details.commercialRegistrationNumber" readonly /></label>
        <label>VAT Number <input :value="details.vatNumber" readonly /></label>
        <label>Business Activity <input :value="details.businessActivity" readonly /></label>
        <label>Established Date <input :value="details.establishedDate || '-'" readonly /></label>
        <label>Company Phone <input :value="details.companyPhone" readonly /></label>
        <label>Company Email <input :value="details.companyEmail" readonly /></label>
        <label>Login Email <input :value="details.loginEmail" readonly /></label>
        <label>Website <input :value="details.website || '-'" readonly /></label>
        <label>Status <input :value="details.kycStatus" readonly /></label>
        <label>Is Active <input :value="details.isActive ? 'Yes' : 'No'" readonly /></label>
        <label>Submitted At <input :value="details.submittedAt" readonly /></label>
        <label>Reviewed At <input :value="details.reviewedAt || '-'" readonly /></label>
        <label class="full">Review Notes <textarea :value="details.reviewNotes || '-'" rows="2" readonly /></label>
        <label class="full">Description <textarea :value="details.description || '-'" rows="2" readonly /></label>
      </section>

      <section class="form-grid">
        <h3>Address</h3>
        <label>Country <input :value="details.address?.country || '-'" readonly /></label>
        <label>City <input :value="details.address?.city || '-'" readonly /></label>
        <label>Street <input :value="details.address?.street || '-'" readonly /></label>
        <label>Building Number <input :value="details.address?.buildingNumber || '-'" readonly /></label>
        <label>Postal Code <input :value="details.address?.postalCode || '-'" readonly /></label>
      </section>

      <section class="form-grid">
        <h3 class="full">Managers</h3>
        <article v-for="(item, idx) in details.managers" :key="`manager-${idx}`" class="card full">
          <label>Full Name <input :value="item.fullName" readonly /></label>
          <label>Position <input :value="item.positionTitle" readonly /></label>
          <label>Nationality <input :value="item.nationality" readonly /></label>
          <label>Mobile <input :value="item.mobileNumber" readonly /></label>
          <label>Email <input :value="item.emailAddress" readonly /></label>
          <label>ID Type <input :value="item.idType" readonly /></label>
          <label>ID Number <input :value="item.idNumber" readonly /></label>
          <label>ID Expiry <input :value="item.idExpiryDate || '-'" readonly /></label>
          <label>Primary <input :value="item.isPrimary ? 'Yes' : 'No'" readonly /></label>
        </article>
      </section>

      <section class="form-grid">
        <h3 class="full">Branches</h3>
        <article v-for="(item, idx) in details.branches" :key="`branch-${idx}`" class="card full">
          <label>Branch Name <input :value="item.branchName" readonly /></label>
          <label>Country <input :value="item.country" readonly /></label>
          <label>City <input :value="item.city" readonly /></label>
          <label>Address <input :value="item.fullAddress" readonly /></label>
          <label>Building Number <input :value="item.buildingNumber" readonly /></label>
          <label>Postal Code <input :value="item.postalCode" readonly /></label>
          <label>Phone <input :value="item.phoneNumber" readonly /></label>
          <label>Email <input :value="item.email" readonly /></label>
          <label>Main Branch <input :value="item.isMainBranch ? 'Yes' : 'No'" readonly /></label>
        </article>
      </section>

      <section class="form-grid">
        <h3 class="full">Bank Accounts</h3>
        <article v-for="(item, idx) in details.bankAccounts" :key="`bank-${idx}`" class="card full">
          <label>Bank Name <input :value="item.bankName" readonly /></label>
          <label>Account Holder <input :value="item.accountHolderName" readonly /></label>
          <label>Account Number <input :value="item.accountNumber" readonly /></label>
          <label>IBAN <input :value="item.iban" readonly /></label>
          <label>SWIFT <input :value="item.swiftCode" readonly /></label>
          <label>Bank Country <input :value="item.bankCountry" readonly /></label>
          <label>Bank City <input :value="item.bankCity" readonly /></label>
          <label>Branch Name <input :value="item.branchName" readonly /></label>
          <label>Branch Address <input :value="item.branchAddress" readonly /></label>
          <label>Currency <input :value="item.currency" readonly /></label>
          <label>Main Account <input :value="item.isMainAccount ? 'Yes' : 'No'" readonly /></label>
        </article>
      </section>

      <section class="form-grid">
        <h3 class="full">Uploaded Files</h3>
        <article v-for="(doc, idx) in details.documents" :key="`doc-${idx}`" class="card full doc-card">
          <p><strong>{{ doc.documentType }}</strong></p>
          <p>{{ doc.fileName || "-" }}</p>
          <p>{{ doc.contentType || "-" }}</p>
          <p>{{ doc.uploadedAtUtc }}</p>
          <button type="button" @click="viewerDoc = doc">View File</button>
        </article>
      </section>

      <div class="action-row">
        <button
          v-for="action in availableActions(details.kycStatus as KycStatus)"
          :key="action"
          type="button"
          :class="{ danger: action === 'reject' || action === 'block' }"
          @click="setKyc(action)"
        >
          {{ actionLabel[action] }}
        </button>
      </div>
    </template>
  </SectionCard>

  <div v-if="viewerDoc" class="viewer-overlay" @click.self="viewerDoc = null">
    <div class="viewer-modal">
      <div class="viewer-header">
        <strong>{{ viewerDoc.fileName || viewerDoc.documentType }}</strong>
        <button type="button" @click="viewerDoc = null">Close</button>
      </div>
      <iframe :src="viewerUrl" title="Attachment Viewer" class="viewer-frame" />
    </div>
  </div>
</template>

<style scoped>
.form-grid { display: grid; grid-template-columns: repeat(2,minmax(0,1fr)); gap: 10px; margin-top: 14px; }
.full { grid-column: 1 / -1; }
label { display: grid; gap: 6px; font-weight: 600; }
input, textarea { padding: 8px; border: 1px solid #cfd6e4; border-radius: 8px; font: inherit; background: #f9fafb; }
.card { border: 1px solid #e4e7ee; border-radius: 10px; padding: 10px; display: grid; gap: 8px; }
.doc-card { grid-template-columns: repeat(5,minmax(0,1fr)); align-items: center; }
.action-row { display: flex; flex-wrap: wrap; gap: 8px; margin-top: 14px; }
.danger { background: #fee2e2; border-color: #fca5a5; }
.viewer-overlay { position: fixed; inset: 0; background: rgba(15,23,42,.55); display: grid; place-items: center; z-index: 1000; }
.viewer-modal { width: min(1100px, 96vw); height: min(760px, 90vh); background: #fff; border-radius: 10px; display: grid; grid-template-rows: auto 1fr; overflow: hidden; }
.viewer-header { padding: 10px 12px; display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid #e5e7eb; }
.viewer-frame { width: 100%; height: 100%; border: 0; }
@media (max-width: 900px) { .form-grid { grid-template-columns: 1fr; } .doc-card { grid-template-columns: 1fr; } }
</style>
