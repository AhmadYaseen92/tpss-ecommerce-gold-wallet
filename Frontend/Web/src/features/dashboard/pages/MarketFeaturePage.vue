<script setup lang="ts">
import { onMounted, ref, watch } from "vue";
import type { ReturnTypeUseMarketplace } from "../../../shared/app/store/useMarketplace";
import { fetchMarketSettings, fetchMarketSellers } from "../../../shared/services/backendGateway";
import type { MarketTypeSettingsDto } from "../../../shared/types/apiTypes";
import type { Seller } from "../../../shared/types/models";
import PageHeader from "../../../shared/components/ui/PageHeader.vue";
import Card from "../../../shared/components/ui/Card.vue";
import Select from "../../../shared/components/ui/Select.vue";
import LoadingState from "../../../shared/components/ui/LoadingState.vue";
import Button from "../../../shared/components/ui/Button.vue";

const props = defineProps<{ marketplace: ReturnTypeUseMarketplace }>();

const loading = ref(false);
const loadingSellers = ref(false);
const settings = ref<MarketTypeSettingsDto[]>([]);
const sellers = ref<Seller[]>([]);
const selectedMarket = ref("UAE");

const load = async () => {
  if (!props.marketplace.session.value?.accessToken) return;
  loading.value = true;
  try {
    settings.value = await fetchMarketSettings(props.marketplace.session.value.accessToken);
    if (settings.value.length > 0) selectedMarket.value = settings.value[0].marketType;
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

watch(selectedMarket, () => {
  void loadSellers();
});

onMounted(() => {
  void load();
});
</script>

<template>
  <section class="dashboard-screen">
    <PageHeader title="Market" subtitle="Manage market settings per country and review all sellers in each market.">
      <Button variant="secondary" size="sm" :loading="loading" @click="load">Refresh</Button>
    </PageHeader>

    <LoadingState v-if="loading" text="Loading market settings..." />

    <template v-else>
      <Card title="Market Type Settings">
        <div class="table-wrap">
          <table class="ui-table">
            <thead>
              <tr>
                <th>Market</th>
                <th>Currency</th>
                <th>Fees %</th>
                <th>Payment Gateway</th>
                <th>Manager Field</th>
                <th>Branches Field</th>
                <th>Bank Accounts Field</th>
                <th>Sellers</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="item in settings" :key="item.marketType">
                <td>{{ item.marketType }}</td>
                <td>{{ item.currency }}</td>
                <td>{{ item.feesPercent }}</td>
                <td>{{ item.paymentGateway }}</td>
                <td>{{ item.enableSellerManagerField ? 'Enabled' : 'Disabled' }}</td>
                <td>{{ item.enableSellerBranchesField ? 'Enabled' : 'Disabled' }}</td>
                <td>{{ item.enableSellerBankAccountsField ? 'Enabled' : 'Disabled' }}</td>
                <td>{{ item.sellersCount }}</td>
              </tr>
            </tbody>
          </table>
        </div>
      </Card>

      <Card title="Sellers by Market">
        <div class="market-filter-row">
          <label>Market</label>
          <Select v-model="selectedMarket">
            <option v-for="item in settings" :key="item.marketType" :value="item.marketType">{{ item.marketType }}</option>
          </Select>
        </div>

        <LoadingState v-if="loadingSellers" text="Loading sellers..." />

        <div v-else class="table-wrap">
          <table class="ui-table">
            <thead>
              <tr>
                <th>Seller ID</th>
                <th>Company</th>
                <th>Email</th>
                <th>Phone</th>
                <th>Status</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="seller in sellers" :key="seller.id">
                <td>{{ seller.id }}</td>
                <td>{{ seller.businessName }}</td>
                <td>{{ seller.email }}</td>
                <td>{{ seller.contactPhone || '-' }}</td>
                <td>{{ seller.kycStatus }}</td>
              </tr>
              <tr v-if="sellers.length === 0">
                <td colspan="5">No sellers found in this market.</td>
              </tr>
            </tbody>
          </table>
        </div>
      </Card>
    </template>
  </section>
</template>
