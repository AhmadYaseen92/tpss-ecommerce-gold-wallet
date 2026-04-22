<script setup lang="ts">
import { computed, onMounted, reactive, ref, watch } from "vue";
import type { ReturnTypeUseMarketplace } from "../../../shared/app/store/useMarketplace";
import {
  fetchAdminServiceFee,
  fetchSellerFeeTabs,
  fetchSellerProductFees,
  fetchSystemFeeTypes,
  updateAdminServiceFee,
  updateSystemFeeType,
  upsertSellerProductFee,
  type AdminServiceFeePayload,
  type SellerProductFeePayload,
  type SystemFeeTypePayload
} from "../../../shared/services/backendGateway";

const { marketplace } = defineProps<{ marketplace: ReturnTypeUseMarketplace }>();
const loading = ref(false);
const error = ref("");

const systemFees = ref<SystemFeeTypePayload[]>([]);
const serviceFee = reactive<AdminServiceFeePayload>({
  isEnabled: false,
  calculationMode: "fixed",
  ratePercent: null,
  fixedAmount: null,
  appliesToBuy: true,
  appliesToSell: true,
  appliesToPickup: true,
  appliesToTransfer: true,
  appliesToGift: true
});

const sellerTabs = ref<SystemFeeTypePayload[]>([]);
const sellerFeeRows = ref<SellerProductFeePayload[]>([]);
const activeSellerTab = ref("");
const sellerDraft = reactive<SellerProductFeePayload>({
  productId: 0,
  feeCode: "",
  isEnabled: true,
  calculationMode: "fixed",
  fixedAmount: 0,
  feePerUnit: 0,
  isOverride: false
});

const isAdmin = computed(() => marketplace.role.value === "Admin");

const actionLabels: Array<keyof Pick<SystemFeeTypePayload, "appliesToBuy" | "appliesToSell" | "appliesToPickup" | "appliesToTransfer" | "appliesToGift">> = [
  "appliesToBuy",
  "appliesToSell",
  "appliesToPickup",
  "appliesToTransfer",
  "appliesToGift"
];

const load = async () => {
  const token = marketplace.session.value?.accessToken;
  if (!token) return;
  loading.value = true;
  error.value = "";

  try {
    if (isAdmin.value) {
      systemFees.value = await fetchSystemFeeTypes(token);
      const service = await fetchAdminServiceFee(token);
      Object.assign(serviceFee, service);
    } else {
      sellerTabs.value = await fetchSellerFeeTabs(token);
      if (!activeSellerTab.value && sellerTabs.value.length > 0) {
        activeSellerTab.value = sellerTabs.value[0].feeCode;
      }
      if (activeSellerTab.value) {
        sellerFeeRows.value = await fetchSellerProductFees(token, activeSellerTab.value);
      }
    }
  } catch (e) {
    error.value = e instanceof Error ? e.message : "Failed to load fees.";
  } finally {
    loading.value = false;
  }
};

onMounted(load);

watch(activeSellerTab, async (value) => {
  const token = marketplace.session.value?.accessToken;
  if (!token || !value) return;
  sellerFeeRows.value = await fetchSellerProductFees(token, value);
  sellerDraft.feeCode = value;
});

const saveSystemFee = async (fee: SystemFeeTypePayload) => {
  const token = marketplace.session.value?.accessToken;
  if (!token) return;
  await updateSystemFeeType(token, fee);
};

const saveServiceFee = async () => {
  const token = marketplace.session.value?.accessToken;
  if (!token) return;
  await updateAdminServiceFee(token, serviceFee);
};

const saveSellerFee = async () => {
  const token = marketplace.session.value?.accessToken;
  if (!token) return;
  if (!sellerDraft.productId || !sellerDraft.feeCode) {
    error.value = "Select tab and product id.";
    return;
  }
  await upsertSellerProductFee(token, sellerDraft);
  sellerFeeRows.value = await fetchSellerProductFees(token, sellerDraft.feeCode);
};
</script>

<template>
  <section>
    <h2>Fees Management</h2>
    <p v-if="loading">Loading...</p>
    <p v-if="error" class="error-text">{{ error }}</p>

    <template v-if="isAdmin">
      <h3>System Fee Types</h3>
      <table>
        <thead>
          <tr><th>Fee</th><th>Enabled</th><th>Buy</th><th>Sell</th><th>Pickup</th><th>Transfer</th><th>Gift</th><th>Save</th></tr>
        </thead>
        <tbody>
          <tr v-for="fee in systemFees" :key="fee.feeCode">
            <td>{{ fee.name }}</td>
            <td><input v-model="fee.isEnabled" type="checkbox" /></td>
            <td v-for="action in actionLabels" :key="`${fee.feeCode}-${action}`"><input v-model="fee[action]" type="checkbox" /></td>
            <td><button @click="saveSystemFee(fee)">Save</button></td>
          </tr>
        </tbody>
      </table>

      <h3>Service Fee (Admin Only)</h3>
      <div class="grid">
        <label><input v-model="serviceFee.isEnabled" type="checkbox" /> Enabled</label>
        <label>Mode
          <select v-model="serviceFee.calculationMode">
            <option value="percent">Percent</option>
            <option value="fixed">Fixed</option>
          </select>
        </label>
        <label v-if="serviceFee.calculationMode === 'percent'">Rate % <input v-model.number="serviceFee.ratePercent" type="number" min="0" step="0.01" /></label>
        <label v-else>Fixed Amount <input v-model.number="serviceFee.fixedAmount" type="number" min="0" step="0.01" /></label>
      </div>
      <div class="actions-grid">
        <label><input v-model="serviceFee.appliesToBuy" type="checkbox" /> Buy</label>
        <label><input v-model="serviceFee.appliesToSell" type="checkbox" /> Sell</label>
        <label><input v-model="serviceFee.appliesToPickup" type="checkbox" /> Pickup</label>
        <label><input v-model="serviceFee.appliesToTransfer" type="checkbox" /> Transfer</label>
        <label><input v-model="serviceFee.appliesToGift" type="checkbox" /> Gift</label>
      </div>
      <button @click="saveServiceFee">Save Service Fee</button>
    </template>

    <template v-else>
      <h3>Seller Manage Fees</h3>
      <div class="tabs">
        <button v-for="tab in sellerTabs" :key="tab.feeCode" :class="{ active: activeSellerTab === tab.feeCode }" @click="activeSellerTab = tab.feeCode">{{ tab.name }}</button>
      </div>
      <table>
        <thead><tr><th>Product ID</th><th>Enabled</th><th>Mode</th><th>Rate %</th><th>Fixed</th><th>Per Unit</th></tr></thead>
        <tbody>
          <tr v-for="row in sellerFeeRows" :key="`${row.productId}-${row.feeCode}`">
            <td>{{ row.productId }}</td>
            <td>{{ row.isEnabled ? "Yes" : "No" }}</td>
            <td>{{ row.calculationMode }}</td>
            <td>{{ row.ratePercent ?? '-' }}</td>
            <td>{{ row.fixedAmount ?? '-' }}</td>
            <td>{{ row.feePerUnit ?? '-' }}</td>
          </tr>
        </tbody>
      </table>

      <h4>Upsert Product Fee</h4>
      <div class="grid">
        <label>Product ID <input v-model.number="sellerDraft.productId" type="number" min="1" /></label>
        <label>Mode <input v-model="sellerDraft.calculationMode" type="text" placeholder="fixed, per_unit..." /></label>
        <label>Rate % <input v-model.number="sellerDraft.ratePercent" type="number" min="0" step="0.01" /></label>
        <label>Fixed <input v-model.number="sellerDraft.fixedAmount" type="number" min="0" step="0.01" /></label>
        <label>Per Unit <input v-model.number="sellerDraft.feePerUnit" type="number" min="0" step="0.01" /></label>
        <label><input v-model="sellerDraft.isEnabled" type="checkbox" /> Enabled</label>
      </div>
      <button @click="saveSellerFee">Save Product Fee</button>
    </template>
  </section>
</template>

<style scoped>
.tabs { display: flex; gap: 8px; margin-bottom: 10px; }
.tabs button.active { background: #f59e0b; color: #fff; }
.grid { display:grid; grid-template-columns: repeat(3, minmax(180px, 1fr)); gap: 8px; margin-bottom: 8px; }
.actions-grid { display:flex; gap: 12px; margin: 10px 0; }
</style>
