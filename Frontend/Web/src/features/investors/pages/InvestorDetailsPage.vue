<script setup lang="ts">
import { computed, onMounted, ref } from "vue";
import type { ReturnTypeUseMarketplace } from "../../../shared/app/store/useMarketplace";
import { fetchInvestorDetailsByAdmin } from "../../../shared/services/backendGateway";
import type { WebInvestorProfileDto } from "../../../shared/types/apiTypes";
import Card from "../../../shared/components/ui/Card.vue";
import Button from "../../../shared/components/ui/Button.vue";
import StatusBadge from "../../../shared/components/ui/StatusBadge.vue";
import LoadingState from "../../../shared/components/ui/LoadingState.vue";
import PageHeader from "../../../shared/components/ui/PageHeader.vue";
import FormField from "../../../shared/components/ui/FormField.vue";
import ResultModal from "../../../shared/components/ui/ResultModal.vue";

const props = defineProps<{ marketplace: ReturnTypeUseMarketplace }>();

const loading = ref(false);
const details = ref<WebInvestorProfileDto | null>(null);
const error = ref("");

const investorIdFromPath = computed(() => {
  const parts = window.location.pathname.split("/").filter(Boolean);
  return parts.length >= 2 ? parts[1] : "";
});

const goBack = () => {
  window.history.pushState({}, "", "/investors");
  window.dispatchEvent(new PopStateEvent("popstate"));
};

const loadDetails = async () => {
  if (!props.marketplace.session.value?.accessToken || !investorIdFromPath.value) return;

  loading.value = true;
  try {
    details.value = await fetchInvestorDetailsByAdmin(
      props.marketplace.session.value.accessToken,
      investorIdFromPath.value
    );
  } catch (e) {
    error.value = e instanceof Error ? e.message : "Failed to load investor details.";
  } finally {
    loading.value = false;
  }
};

onMounted(() => {
  void loadDetails();
});
</script>

<template>
  <section class="dashboard-screen">
    <PageHeader title="Investor Details" subtitle="Review investor profile, preferences, bank accounts and payment methods.">
      <Button variant="ghost" @click="goBack">Back to Investors</Button>
    </PageHeader>

    <ResultModal
      :open="Boolean(error)"
      title="Unable to load investor"
      :message="error"
      tone="error"
      @close="error = ''"
    />

    <LoadingState v-if="loading" />

    <template v-else-if="details">
      <Card title="Profile">
        <div class="investor-profile-grid">
          <div class="investor-photo-wrap">
            <img v-if="details.profilePhotoUrl" :src="details.profilePhotoUrl" alt="Investor profile" class="investor-photo" />
            <div v-else class="investor-photo placeholder">No image</div>
          </div>

          <div class="form-grid-three">
            <FormField label="Investor ID"><div>{{ details.id }}</div></FormField>
            <FormField label="Full Name"><div>{{ details.fullName }}</div></FormField>
            <FormField label="Status"><StatusBadge :status="details.status" /></FormField>
            <FormField label="Email"><div>{{ details.email }}</div></FormField>
            <FormField label="Phone"><div>{{ details.phoneNumber || '-' }}</div></FormField>
            <FormField label="Date of Birth"><div>{{ details.dateOfBirth || '-' }}</div></FormField>
            <FormField label="Nationality"><div>{{ details.nationality || '-' }}</div></FormField>
            <FormField label="Document Type"><div>{{ details.documentType || '-' }}</div></FormField>
            <FormField label="ID Number"><div>{{ details.idNumber || '-' }}</div></FormField>
            <FormField label="Preferred Language"><div>{{ details.preferredLanguage || '-' }}</div></FormField>
            <FormField label="Preferred Theme"><div>{{ details.preferredTheme || '-' }}</div></FormField>
            <FormField label="Wallet Balance"><div>{{ Number(details.walletBalance ?? 0).toFixed(2) }}</div></FormField>
            <FormField label="Total Transactions"><div>{{ details.totalTransactions }}</div></FormField>
            <FormField label="Created At"><div>{{ details.createdAt }}</div></FormField>
            <FormField label="Updated At"><div>{{ details.updatedAt || '-' }}</div></FormField>
          </div>
        </div>
      </Card>

      <Card title="Linked Bank Accounts">
        <div v-if="!details.bankAccounts.length" class="ui-state">No bank accounts available.</div>
        <div v-else class="ui-table-wrap">
          <table>
            <thead>
              <tr>
                <th>Bank</th>
                <th>Account Holder</th>
                <th>Account Number</th>
                <th>IBAN</th>
                <th>SWIFT</th>
                <th>Country</th>
                <th>City</th>
                <th>Currency</th>
                <th>Verified</th>
                <th>Default</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="(bank, idx) in details.bankAccounts" :key="`${bank.bankName}-${idx}`">
                <td>{{ bank.bankName || '-' }}</td>
                <td>{{ bank.accountHolderName || '-' }}</td>
                <td>{{ bank.accountNumber || '-' }}</td>
                <td>{{ bank.ibanMasked || '-' }}</td>
                <td>{{ bank.swiftCode || '-' }}</td>
                <td>{{ bank.country || '-' }}</td>
                <td>{{ bank.city || '-' }}</td>
                <td>{{ bank.currency || '-' }}</td>
                <td>{{ bank.isVerified ? 'Yes' : 'No' }}</td>
                <td>{{ bank.isDefault ? 'Yes' : 'No' }}</td>
              </tr>
            </tbody>
          </table>
        </div>
      </Card>

      <Card title="Payment Methods">
        <div v-if="!details.paymentMethods.length" class="ui-state">No payment methods available.</div>
        <div v-else class="ui-table-wrap">
          <table>
            <thead>
              <tr>
                <th>Type</th>
                <th>Masked Number</th>
                <th>Default</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="(payment, idx) in details.paymentMethods" :key="`${payment.type}-${idx}`">
                <td>{{ payment.type || '-' }}</td>
                <td>{{ payment.maskedNumber || '-' }}</td>
                <td>{{ payment.isDefault ? 'Yes' : 'No' }}</td>
              </tr>
            </tbody>
          </table>
        </div>
      </Card>
    </template>
  </section>
</template>

<style scoped>
.investor-profile-grid {
  display: grid;
  grid-template-columns: 220px 1fr;
  gap: 1rem;
}

.investor-photo-wrap {
  display: flex;
  align-items: flex-start;
  justify-content: center;
}

.investor-photo {
  width: 160px;
  height: 160px;
  object-fit: cover;
  border-radius: 16px;
  border: 1px solid var(--border-strong);
  background: var(--surface-elevated);
}

.investor-photo.placeholder {
  display: grid;
  place-items: center;
  color: var(--text-muted);
}

@media (max-width: 900px) {
  .investor-profile-grid {
    grid-template-columns: 1fr;
  }
}
</style>
