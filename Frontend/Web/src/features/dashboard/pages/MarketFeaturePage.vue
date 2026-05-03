<script setup lang="ts">
import { computed, onMounted, ref, watch } from "vue";
import type { ReturnTypeUseMarketplace } from "../../../shared/app/store/useMarketplace";
import { fetchMarketSettings, fetchMarketSellers, updateMarketSettings } from "../../../shared/services/backendGateway";
import type { MarketTypeSettingsDto } from "../../../shared/types/apiTypes";
import type { Seller } from "../../../shared/types/models";
import PageHeader from "../../../shared/components/ui/PageHeader.vue";
import Card from "../../../shared/components/ui/Card.vue";
import Select from "../../../shared/components/ui/Select.vue";
import LoadingState from "../../../shared/components/ui/LoadingState.vue";
import Button from "../../../shared/components/ui/Button.vue";
import Input from "../../../shared/components/ui/Input.vue";
import Checkbox from "../../../shared/components/ui/Checkbox.vue";

const props = defineProps<{ marketplace: ReturnTypeUseMarketplace }>();
const loading = ref(false);
const loadingSellers = ref(false);
const saving = ref(false);
const settings = ref<MarketTypeSettingsDto[]>([]);
const sellers = ref<Seller[]>([]);
const selectedMarket = ref("UAE");
const activeTab = ref<"general" | "registration" | "gateway">("general");

const currentSettings = computed(() => settings.value.find((x) => x.marketType === selectedMarket.value));

const load = async () => {
  if (!props.marketplace.session.value?.accessToken) return;
  loading.value = true;
  try {
    settings.value = await fetchMarketSettings(props.marketplace.session.value.accessToken);
    if (!settings.value.some((x) => x.marketType === selectedMarket.value) && settings.value.length > 0) {
      selectedMarket.value = settings.value[0].marketType;
    }
    await loadSellers();
  } finally {
    loading.value = false;
  }
};

const loadSellers = async () => {
  if (!props.marketplace.session.value?.accessToken) return;
  loadingSellers.value = true;
  try {
    sellers.value = await fetchMarketSellers(props.marketplace.session.value.accessToken, selectedMarket.value);
  } finally {
    loadingSellers.value = false;
  }
};

const saveCurrent = async () => {
  if (!props.marketplace.session.value?.accessToken || !currentSettings.value) return;
  saving.value = true;
  try {
    await updateMarketSettings(props.marketplace.session.value.accessToken, selectedMarket.value, currentSettings.value);
    await load();
  } finally {
    saving.value = false;
  }
};

watch(selectedMarket, () => void loadSellers());
onMounted(() => void load());
</script>

<template>
  <section class="dashboard-screen">
    <PageHeader title="Market" subtitle="Manage market settings per country and review all sellers in each market.">
      <Button variant="secondary" size="sm" :loading="loading" @click="load">Refresh</Button>
    </PageHeader>

    <LoadingState v-if="loading" text="Loading market settings..." />

    <template v-else>
      <Card title="Market Type Settings">
        <div class="market-actions-row">
          <Button size="sm" :loading="saving" @click="saveCurrent">Save Settings</Button>
        </div>
        <div class="market-filter-row">
          <label>Market</label>
          <Select v-model="selectedMarket">
            <option v-for="item in settings" :key="item.marketType" :value="item.marketType">{{ item.marketType }}</option>
          </Select>
        </div>

        <div class="market-tabs">
          <button :class="{ active: activeTab === 'general' }" @click="activeTab = 'general'">General</button>
          <button :class="{ active: activeTab === 'registration' }" @click="activeTab = 'registration'">Registration Fields</button>
          <button :class="{ active: activeTab === 'gateway' }" @click="activeTab = 'gateway'">Payment Gateway</button>
        </div>

        <div v-if="currentSettings" class="settings-grid">
          <div v-if="activeTab === 'general'" class="ui-card">
            <label>Currency</label>
            <Input v-model="currentSettings.currency" />
            <label>USD To Local Rate</label>
            <Input v-model="currentSettings.usdToLocalRate" type="number" min="0" step="0.0001" />
            <label>Default Fees %</label>
            <Input v-model="currentSettings.feesPercent" type="number" min="0" step="0.01" />
            <label>Tax Fee %</label>
            <Input v-model="currentSettings.vatRatePercent" type="number" min="0" step="0.01" />
          </div>

          <div v-if="activeTab === 'registration'" class="ui-card">
            <Checkbox v-model="currentSettings.enableSellerCompanyInfoField" label="Company Info Section Enabled" />
            <Checkbox v-model="currentSettings.enableSellerManagerField" label="Manager Section Enabled" />
            <Checkbox v-model="currentSettings.enableSellerBranchesField" label="Branches Section Enabled" />
            <Checkbox v-model="currentSettings.enableSellerBankAccountsField" label="Bank Accounts Section Enabled" />
            <Checkbox v-model="currentSettings.enableSellerLoginCredentialsField" label="Login Credentials Section Enabled" />
            <hr />
            <Checkbox v-model="currentSettings.enableCompanyNameField" label="Company Name Field" />
            <Checkbox v-model="currentSettings.enableCompanyCrNumberField" label="Trade License Number Field" />
            <Checkbox v-model="currentSettings.enableCompanyVatNumberField" label="VAT Number Field" />
            <Checkbox v-model="currentSettings.enableCompanyBusinessActivityField" label="Business Activity Field" />
            <Checkbox v-model="currentSettings.enableManagerNameField" label="Manager Name Field" />
            <Checkbox v-model="currentSettings.enableManagerMobileField" label="Manager Mobile Field" />
            <Checkbox v-model="currentSettings.enableManagerEmailField" label="Manager Email Field" />
            <Checkbox v-model="currentSettings.enableBranchNameField" label="Branch Name Field" />
            <Checkbox v-model="currentSettings.enableBranchAddressField" label="Branch Address Field" />
            <Checkbox v-model="currentSettings.enableBranchPhoneField" label="Branch Phone Field" />
            <Checkbox v-model="currentSettings.enableBankNameField" label="Bank Name Field" />
            <Checkbox v-model="currentSettings.enableBankAccountNumberField" label="Bank Account Number Field" />
            <Checkbox v-model="currentSettings.enableBankIbanField" label="Bank IBAN Field" />
            <Checkbox v-model="currentSettings.enableLoginEmailField" label="Login Email Field" />
            <Checkbox v-model="currentSettings.enableLoginPhoneField" label="Login Phone Field" />
            <Checkbox v-model="currentSettings.enablePasswordField" label="Password/Confirm Password Fields" />
          </div>

          <div v-if="activeTab === 'gateway'" class="ui-card">
            <label>Payment Gateway</label>
            <Input v-model="currentSettings.paymentGateway" placeholder="ex: PayTabs, HyperPay, Razorpay" />
            <p class="hint-text">Add common configuration fields in next step (key/value configurations).</p>
          </div>
        </div>
      </Card>

      <Card title="Sellers in Selected Market">
        <LoadingState v-if="loadingSellers" text="Loading sellers..." />
        <div v-else class="table-wrap">
          <table class="ui-table">
            <thead><tr><th>Seller ID</th><th>Company</th><th>Email</th><th>Phone</th><th>Status</th></tr></thead>
            <tbody>
              <tr v-for="seller in sellers" :key="seller.id">
                <td>{{ seller.id }}</td><td>{{ seller.businessName }}</td><td>{{ seller.email }}</td><td>{{ seller.contactPhone || '-' }}</td><td>{{ seller.kycStatus }}</td>
              </tr>
              <tr v-if="sellers.length === 0"><td colspan="5">No sellers found in this market.</td></tr>
            </tbody>
          </table>
        </div>
      </Card>
    </template>
  </section>
</template>

<style scoped>
.market-actions-row {
  display: flex;
  justify-content: flex-end;
  margin-bottom: 8px;
}

.market-tabs {
  display: flex;
  gap: 12px;
  margin: 14px 0;
}
</style>
