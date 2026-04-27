<script setup lang="ts">
import { computed, onMounted, ref } from "vue";
import type { ReturnTypeUseMarketplace } from "../../../shared/app/store/useMarketplace";
import { fetchSellerDetailsByAdmin } from "../../../shared/services/backendGateway";
import type { WebSellerDetailsDto } from "../../../shared/types/apiTypes";

import Card from "../../../shared/components/ui/Card.vue";
import Button from "../../../shared/components/ui/Button.vue";
import StatusBadge from "../../../shared/components/ui/StatusBadge.vue";
import LoadingState from "../../../shared/components/ui/LoadingState.vue";
import PageHeader from "../../../shared/components/ui/PageHeader.vue";
import FormField from "../../../shared/components/ui/FormField.vue";
import ResultModal from "../../../shared/components/ui/ResultModal.vue";

const props = defineProps<{ marketplace: ReturnTypeUseMarketplace }>();

const loading = ref(false);
const details = ref<WebSellerDetailsDto | null>(null);
const error = ref("");

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
    details.value = await fetchSellerDetailsByAdmin(
      props.marketplace.session.value.accessToken,
      sellerIdFromPath.value
    );
  } catch (e) {
    error.value = e instanceof Error ? e.message : "Failed to load seller details.";
  } finally {
    loading.value = false;
  }
};

type SellerAction = "approve" | "reject" | "block";

const setKyc = async (action: SellerAction) => {
  if (!details.value) return;

  if (action === "approve") await props.marketplace.approveKyc(details.value.id);
  if (action === "reject") await props.marketplace.rejectKyc(details.value.id);
  if (action === "block") await props.marketplace.blockKyc(details.value.id);

  await loadDetails();
};

const tabs = ["company", "managers", "branches", "banks", "files"] as const;
type SellerDetailsTab = (typeof tabs)[number];

const tabLabel: Record<SellerDetailsTab, string> = {
  company: "Company",
  managers: "Managers",
  branches: "Branches",
  banks: "Bank Accounts",
  files: "Documents"
};

const activeTab = ref<SellerDetailsTab>("company");

const API_BASE_URL = (import.meta.env.VITE_API_BASE_URL ?? "").replace(/\/$/, "");

const toDocumentUrl = (filePath: string) => {
  const path = String(filePath ?? "").trim();
  if (!path) return "#";
  if (/^(https?:\/\/|data:|blob:)/i.test(path)) return path;

  if (API_BASE_URL) {
    return path.startsWith("/") ? `${API_BASE_URL}${path}` : `${API_BASE_URL}/${path}`;
  }

  return path.startsWith("/") ? path : `/${path}`;
};

onMounted(() => {
  void loadDetails();
});
</script>

<template>
  <section class="dashboard-screen">
    <PageHeader title="Seller Details" subtitle="Review company profile, KYC, and submitted documents.">
      <Button variant="ghost" @click="goBack">Back to Sellers</Button>
    </PageHeader>

    <ResultModal
      :open="Boolean(error)"
      title="Unable to load seller"
      :message="error"
      tone="error"
      @close="error = ''"
    />

    <LoadingState v-if="loading" />

    <template v-else-if="details">
      <Card>
        <div class="ui-tabs">
          <button
            v-for="tab in tabs"
            :key="tab"
            class="ui-tab"
            :class="{ active: activeTab === tab }"
            type="button"
            @click="activeTab = tab"
          >
            {{ tabLabel[tab] }}
          </button>
        </div>
      </Card>

      <Card v-if="activeTab === 'company'" title="Company Profile">
        <div class="form-grid-three">
          <FormField label="Company Name"><div>{{ details.companyName }}</div></FormField>
          <FormField label="KYC Status"><StatusBadge :status="details.kycStatus" /></FormField>
          <FormField label="Active"><StatusBadge :status="details.isActive ? 'Active' : 'Inactive'" /></FormField>
          <FormField label="Company Code"><div>{{ details.companyCode }}</div></FormField>
          <FormField label="Commercial Reg."><div>{{ details.commercialRegistrationNumber }}</div></FormField>
          <FormField label="VAT Number"><div>{{ details.vatNumber || '-' }}</div></FormField>
          <FormField label="Company Email"><div>{{ details.companyEmail }}</div></FormField>
          <FormField label="Company Phone"><div>{{ details.companyPhone }}</div></FormField>
          <FormField label="Website"><div>{{ details.website || '-' }}</div></FormField>
          <FormField label="Business Activity" class="field-full"><div>{{ details.businessActivity }}</div></FormField>
          <FormField label="Description" class="field-full"><div>{{ details.description || '-' }}</div></FormField>
        </div>
      </Card>

      <Card v-if="activeTab === 'managers'" title="Managers">
        <div v-if="!details.managers.length" class="ui-state">No managers available.</div>
        <div v-else class="dashboard-bottom-grid">
          <Card v-for="m in details.managers" :key="`${m.emailAddress}-${m.idNumber}`" :title="m.fullName">
            <div class="form-grid-two">
              <FormField label="Position"><div>{{ m.positionTitle }}</div></FormField>
              <FormField label="Nationality"><div>{{ m.nationality }}</div></FormField>
              <FormField label="Mobile"><div>{{ m.mobileNumber }}</div></FormField>
              <FormField label="Email"><div>{{ m.emailAddress }}</div></FormField>
            </div>
          </Card>
        </div>
      </Card>

      <Card v-if="activeTab === 'branches'" title="Branches">
        <div v-if="!details.branches.length" class="ui-state">No branches available.</div>
        <div v-else class="dashboard-bottom-grid">
          <Card v-for="b in details.branches" :key="`${b.branchName}-${b.city}`" :title="b.branchName">
            <div class="form-grid-two">
              <FormField label="Country"><div>{{ b.country }}</div></FormField>
              <FormField label="City"><div>{{ b.city }}</div></FormField>
              <FormField label="Phone"><div>{{ b.phoneNumber }}</div></FormField>
              <FormField label="Email"><div>{{ b.email }}</div></FormField>
              <FormField label="Address" class="field-full"><div>{{ b.fullAddress }}</div></FormField>
            </div>
          </Card>
        </div>
      </Card>

      <Card v-if="activeTab === 'banks'" title="Bank Accounts">
        <div v-if="!details.bankAccounts.length" class="ui-state">No bank accounts available.</div>
        <div v-else class="dashboard-bottom-grid">
          <Card v-for="a in details.bankAccounts" :key="`${a.iban}-${a.accountNumber}`" :title="a.bankName">
            <div class="form-grid-two">
              <FormField label="Account Holder"><div>{{ a.accountHolderName }}</div></FormField>
              <FormField label="Account Number"><div>{{ a.accountNumber }}</div></FormField>
              <FormField label="IBAN"><div>{{ a.iban }}</div></FormField>
              <FormField label="SWIFT"><div>{{ a.swiftCode }}</div></FormField>
            </div>
          </Card>
        </div>
      </Card>

      <Card v-if="activeTab === 'files'" title="Documents">
        <div v-if="!details.documents.length" class="ui-state">No documents available.</div>
        <div v-else class="ui-table-wrap">
          <table>
            <thead>
              <tr>
                <th>Type</th>
                <th>File Name</th>
                <th>Uploaded At</th>
                <th>Link</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="doc in details.documents" :key="doc.id">
                <td>{{ doc.documentType }}</td>
                <td>{{ doc.fileName }}</td>
                <td>{{ doc.uploadedAtUtc }}</td>
                <td>
                  <a :href="toDocumentUrl(doc.filePath)" target="_blank" rel="noopener noreferrer">Open</a>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </Card>

      <Card title="KYC Actions">
        <div class="ui-row-actions">
          <Button variant="success" @click="setKyc('approve')">Approve</Button>
          <Button variant="danger" @click="setKyc('reject')">Reject</Button>
          <Button variant="warning" @click="setKyc('block')">Block</Button>
        </div>
      </Card>
    </template>
  </section>
</template>
