<script setup lang="ts">
import { computed, onMounted, reactive, ref, watch } from "vue";
import type { ReturnTypeUseMarketplace } from "../../../shared/app/store/useMarketplace";
import {
  bulkApplySellerProductFee,
  fetchAdminServiceFee,
  fetchManagedProducts,
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
const activeSellerTab = ref("");
const sellerProducts = ref<Array<{ id: number; name: string }>>([]);
const sellerFeeRows = ref<SellerProductFeePayload[]>([]);

interface BulkConfig {
  isEnabled: boolean;
  calculationMode: string;
  ratePercent: number | null;
  minimumAmount: number | null;
  flatAmount: number | null;
  fixedAmount: number | null;
  feePerUnit: number | null;
  valuePerUnit: number | null;
  feePercent: number | null;
  gracePeriodDays: number | null;
  premiumDiscountType: string | null;
}

const bulkByFee = reactive<Record<string, BulkConfig>>({});
const overrides = reactive<Record<string, SellerProductFeePayload>>({});

const isAdmin = computed(() => marketplace.role.value === "Admin");

const feeMetadata: Record<string, { actions: string; modes: string[] }> = {
  commission_per_transaction: { actions: "Buy, Sell", modes: ["percent_with_minimum", "flat"] },
  premium_discount: { actions: "Pickup", modes: ["per_unit"] },
  storage_custody_fee: { actions: "Pickup", modes: ["percentage_by_held_days_after_grace_period"] },
  delivery_fee: { actions: "Pickup", modes: ["fixed", "per_unit"] },
  service_charge: { actions: "Buy, Sell, Pickup", modes: ["fixed", "per_unit"] }
};

const actionLabels: Array<keyof Pick<SystemFeeTypePayload, "appliesToBuy" | "appliesToSell" | "appliesToPickup" | "appliesToTransfer" | "appliesToGift">> = [
  "appliesToBuy",
  "appliesToSell",
  "appliesToPickup",
  "appliesToTransfer",
  "appliesToGift"
];

const defaultBulk = (feeCode: string): BulkConfig => {
  const firstMode = feeMetadata[feeCode]?.modes[0] ?? "fixed";
  return {
    isEnabled: true,
    calculationMode: firstMode,
    ratePercent: null,
    minimumAmount: null,
    flatAmount: null,
    fixedAmount: null,
    feePerUnit: null,
    valuePerUnit: null,
    feePercent: null,
    gracePeriodDays: null,
    premiumDiscountType: "premium"
  };
};

const currentBulk = computed(() => {
  const code = activeSellerTab.value;
  if (!code) return defaultBulk("delivery_fee");
  if (!bulkByFee[code]) bulkByFee[code] = defaultBulk(code);
  return bulkByFee[code];
});

const rowKey = (productId: number, feeCode: string) => `${productId}_${feeCode}`;
const isOverridden = (productId: number) => !!overrides[rowKey(productId, activeSellerTab.value)];

const getEffectiveRow = (productId: number): SellerProductFeePayload => {
  const key = rowKey(productId, activeSellerTab.value);
  return overrides[key] ?? {
    productId,
    feeCode: activeSellerTab.value,
    isOverride: false,
    isEnabled: currentBulk.value.isEnabled,
    calculationMode: currentBulk.value.calculationMode,
    ratePercent: currentBulk.value.ratePercent,
    minimumAmount: currentBulk.value.minimumAmount,
    flatAmount: currentBulk.value.flatAmount,
    fixedAmount: currentBulk.value.fixedAmount,
    feePerUnit: currentBulk.value.feePerUnit,
    valuePerUnit: currentBulk.value.valuePerUnit,
    feePercent: currentBulk.value.feePercent,
    gracePeriodDays: currentBulk.value.gracePeriodDays,
    premiumDiscountType: currentBulk.value.premiumDiscountType
  };
};

const sellerTableRows = computed(() =>
  sellerProducts.value.map((product) => ({
    productId: product.id,
    productName: product.name,
    override: isOverridden(product.id),
    effective: getEffectiveRow(product.id)
  }))
);

const formulaByMode = (feeCode: string, mode: string) => {
  if (feeCode === "commission_per_transaction") return mode === "percent_with_minimum" ? "max(Notional × Rate, Min)" : "Flat Fee";
  if (feeCode === "premium_discount") return "Quantity × ValuePerUnit";
  if (feeCode === "storage_custody_fee") return "Quantity × ClosePrice × (FeePercent / 100) / 360 × DaysHeldAfterGrace";
  if (feeCode === "delivery_fee") return mode === "per_unit" ? "Quantity × FeePerUnit" : "Fixed Fee";
  if (feeCode === "service_charge") return mode === "per_unit" ? "Quantity × FeePerUnit" : "Fixed Fee";
  return "-";
};

const valueSummary = (row: SellerProductFeePayload) => {
  if (row.feeCode === "commission_per_transaction") {
    return row.calculationMode === "percent_with_minimum"
      ? `${row.ratePercent ?? 0}% | Min ${row.minimumAmount ?? 0}`
      : `Flat ${row.flatAmount ?? 0}`;
  }
  if (row.feeCode === "premium_discount") return `${row.premiumDiscountType ?? "premium"} ${row.valuePerUnit ?? 0} / unit`;
  if (row.feeCode === "storage_custody_fee") return `${row.feePercent ?? 0}% | Grace ${row.gracePeriodDays ?? 0}d`;
  if (row.calculationMode === "per_unit") return `${row.feePerUnit ?? 0} / unit`;
  return `Fixed ${row.fixedAmount ?? row.flatAmount ?? 0}`;
};

const load = async () => {
  const token = marketplace.session.value?.accessToken;
  if (!token) return;
  loading.value = true;
  error.value = "";

  try {
    if (isAdmin.value) {
      systemFees.value = await fetchSystemFeeTypes(token);
      Object.assign(serviceFee, await fetchAdminServiceFee(token));
      return;
    }

    sellerTabs.value = await fetchSellerFeeTabs(token);
    const products = await fetchManagedProducts(token);
    sellerProducts.value = products.map((p) => ({ id: p.id, name: p.name }));

    if (!activeSellerTab.value && sellerTabs.value.length > 0) activeSellerTab.value = sellerTabs.value[0].feeCode;
    await loadSellerRows();
  } catch (e) {
    error.value = e instanceof Error ? e.message : "Failed to load fees.";
  } finally {
    loading.value = false;
  }
};

const loadSellerRows = async () => {
  const token = marketplace.session.value?.accessToken;
  if (!token || !activeSellerTab.value) return;

  sellerFeeRows.value = await fetchSellerProductFees(token, activeSellerTab.value);

  bulkByFee[activeSellerTab.value] = defaultBulk(activeSellerTab.value);
  Object.keys(overrides).forEach((k) => { if (k.endsWith(`_${activeSellerTab.value}`)) delete overrides[k]; });

  const inherited = sellerFeeRows.value.find((x) => !x.isOverride);
  if (inherited) {
    bulkByFee[activeSellerTab.value] = {
      isEnabled: inherited.isEnabled,
      calculationMode: inherited.calculationMode,
      ratePercent: inherited.ratePercent ?? null,
      minimumAmount: inherited.minimumAmount ?? null,
      flatAmount: inherited.flatAmount ?? null,
      fixedAmount: inherited.fixedAmount ?? null,
      feePerUnit: inherited.feePerUnit ?? null,
      valuePerUnit: inherited.valuePerUnit ?? null,
      feePercent: inherited.feePercent ?? null,
      gracePeriodDays: inherited.gracePeriodDays ?? null,
      premiumDiscountType: inherited.premiumDiscountType ?? "premium"
    };
  }

  sellerFeeRows.value.filter((x) => x.isOverride).forEach((row) => {
    overrides[rowKey(row.productId, row.feeCode)] = { ...row, isOverride: true };
  });
};

onMounted(load);
watch(activeSellerTab, loadSellerRows);

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

const toggleOverride = (productId: number, checked: boolean) => {
  const key = rowKey(productId, activeSellerTab.value);
  if (checked) {
    const inherited = getEffectiveRow(productId);
    overrides[key] = { ...inherited, isOverride: true };
  } else {
    delete overrides[key];
  }
};

const applyBulkToAll = async () => {
  const token = marketplace.session.value?.accessToken;
  if (!token || !activeSellerTab.value) return;
  const template: SellerProductFeePayload = {
    productId: sellerProducts.value[0]?.id ?? 0,
    feeCode: activeSellerTab.value,
    isEnabled: currentBulk.value.isEnabled,
    calculationMode: currentBulk.value.calculationMode,
    ratePercent: currentBulk.value.ratePercent,
    minimumAmount: currentBulk.value.minimumAmount,
    flatAmount: currentBulk.value.flatAmount,
    fixedAmount: currentBulk.value.fixedAmount,
    feePerUnit: currentBulk.value.feePerUnit,
    valuePerUnit: currentBulk.value.valuePerUnit,
    feePercent: currentBulk.value.feePercent,
    gracePeriodDays: currentBulk.value.gracePeriodDays,
    premiumDiscountType: currentBulk.value.premiumDiscountType,
    isOverride: false
  };
  await bulkApplySellerProductFee(token, activeSellerTab.value, template);
  await loadSellerRows();
};

const saveOverrideRow = async (productId: number) => {
  const token = marketplace.session.value?.accessToken;
  if (!token) return;
  const row = overrides[rowKey(productId, activeSellerTab.value)];
  if (!row) return;
  await upsertSellerProductFee(token, row);
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
          <select v-model="serviceFee.calculationMode"><option value="percent">Percent</option><option value="fixed">Fixed</option></select>
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

      <div class="bulk-setup" v-if="activeSellerTab">
        <h4>Bulk Setup ({{ activeSellerTab.replace(/_/g, ' ') }})</h4>
        <div class="bulk-grid">
          <label><input v-model="currentBulk.isEnabled" type="checkbox" /> Enable for all</label>
          <label>Mode
            <select v-model="currentBulk.calculationMode">
              <option v-for="mode in (feeMetadata[activeSellerTab]?.modes ?? ['fixed'])" :key="mode" :value="mode">{{ mode }}</option>
            </select>
          </label>
          <label v-if="activeSellerTab === 'commission_per_transaction' && currentBulk.calculationMode === 'percent_with_minimum'">Rate % <input v-model.number="currentBulk.ratePercent" type="number" min="0" step="0.01" /></label>
          <label v-if="activeSellerTab === 'commission_per_transaction' && currentBulk.calculationMode === 'percent_with_minimum'">Min Amount <input v-model.number="currentBulk.minimumAmount" type="number" min="0" step="0.01" /></label>
          <label v-if="activeSellerTab === 'commission_per_transaction' && currentBulk.calculationMode === 'flat'">Flat Fee <input v-model.number="currentBulk.flatAmount" type="number" min="0" step="0.01" /></label>
          <label v-if="activeSellerTab === 'premium_discount'">Type <select v-model="currentBulk.premiumDiscountType"><option value="premium">Premium</option><option value="discount">Discount</option></select></label>
          <label v-if="activeSellerTab === 'premium_discount'">Value / Unit <input v-model.number="currentBulk.valuePerUnit" type="number" min="0" step="0.01" /></label>
          <label v-if="activeSellerTab === 'storage_custody_fee'">Fee % <input v-model.number="currentBulk.feePercent" type="number" min="0" step="0.01" /></label>
          <label v-if="activeSellerTab === 'storage_custody_fee'">Grace Days <input v-model.number="currentBulk.gracePeriodDays" type="number" min="0" step="1" /></label>
          <label v-if="activeSellerTab !== 'commission_per_transaction' && activeSellerTab !== 'premium_discount' && activeSellerTab !== 'storage_custody_fee' && currentBulk.calculationMode === 'fixed'">Fixed Fee <input v-model.number="currentBulk.fixedAmount" type="number" min="0" step="0.01" /></label>
          <label v-if="activeSellerTab !== 'commission_per_transaction' && activeSellerTab !== 'premium_discount' && activeSellerTab !== 'storage_custody_fee' && currentBulk.calculationMode === 'per_unit'">Fee / Unit <input v-model.number="currentBulk.feePerUnit" type="number" min="0" step="0.01" /></label>
        </div>
        <button @click="applyBulkToAll">Apply to all products</button>
      </div>

      <table>
        <thead>
          <tr>
            <th>Override</th>
            <th>Enabled</th>
            <th>Product Id</th>
            <th>Product Name</th>
            <th>Action</th>
            <th>Mode</th>
            <th>Calculation Formula</th>
            <th>Value</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in sellerTableRows" :key="row.productId" :class="row.override ? 'row-custom' : 'row-inherited'">
            <td>
              <input :checked="row.override" type="checkbox" @change="toggleOverride(row.productId, ($event.target as HTMLInputElement).checked)" />
              <small>{{ row.override ? 'Custom' : 'Inherited' }}</small>
            </td>
            <td>
              <input v-if="row.override" v-model="overrides[rowKey(row.productId, activeSellerTab)].isEnabled" type="checkbox" />
              <span v-else>{{ row.effective.isEnabled ? 'Yes' : 'No' }}</span>
            </td>
            <td>{{ row.productId }}</td>
            <td>{{ row.productName }}</td>
            <td>{{ feeMetadata[activeSellerTab]?.actions ?? '-' }}</td>
            <td>
              <select v-if="row.override" v-model="overrides[rowKey(row.productId, activeSellerTab)].calculationMode">
                <option v-for="mode in (feeMetadata[activeSellerTab]?.modes ?? ['fixed'])" :key="mode" :value="mode">{{ mode }}</option>
              </select>
              <span v-else>{{ row.effective.calculationMode }}</span>
            </td>
            <td>{{ formulaByMode(activeSellerTab, row.effective.calculationMode) }}</td>
            <td>
              <div v-if="row.override" class="value-editor">
                <template v-if="activeSellerTab === 'commission_per_transaction' && row.effective.calculationMode === 'percent_with_minimum'">
                  <input v-model.number="overrides[rowKey(row.productId, activeSellerTab)].ratePercent" type="number" min="0" step="0.01" placeholder="Rate %" />
                  <input v-model.number="overrides[rowKey(row.productId, activeSellerTab)].minimumAmount" type="number" min="0" step="0.01" placeholder="Min" />
                </template>
                <input v-else-if="activeSellerTab === 'commission_per_transaction'" v-model.number="overrides[rowKey(row.productId, activeSellerTab)].flatAmount" type="number" min="0" step="0.01" placeholder="Flat" />
                <template v-else-if="activeSellerTab === 'premium_discount'">
                  <select v-model="overrides[rowKey(row.productId, activeSellerTab)].premiumDiscountType"><option value="premium">Premium</option><option value="discount">Discount</option></select>
                  <input v-model.number="overrides[rowKey(row.productId, activeSellerTab)].valuePerUnit" type="number" min="0" step="0.01" placeholder="/unit" />
                </template>
                <template v-else-if="activeSellerTab === 'storage_custody_fee'">
                  <input v-model.number="overrides[rowKey(row.productId, activeSellerTab)].feePercent" type="number" min="0" step="0.01" placeholder="Fee %" />
                  <input v-model.number="overrides[rowKey(row.productId, activeSellerTab)].gracePeriodDays" type="number" min="0" step="1" placeholder="Grace days" />
                </template>
                <input v-else-if="row.effective.calculationMode === 'per_unit'" v-model.number="overrides[rowKey(row.productId, activeSellerTab)].feePerUnit" type="number" min="0" step="0.01" placeholder="/unit" />
                <input v-else v-model.number="overrides[rowKey(row.productId, activeSellerTab)].fixedAmount" type="number" min="0" step="0.01" placeholder="Fixed" />
                <button @click="saveOverrideRow(row.productId)">Save</button>
              </div>
              <span v-else>{{ valueSummary(row.effective) }}</span>
            </td>
          </tr>
        </tbody>
      </table>
    </template>
  </section>
</template>

<style scoped>
.tabs { display: flex; gap: 8px; margin-bottom: 10px; flex-wrap: wrap; }
.tabs button.active { background: #f59e0b; color: #fff; }
.grid { display:grid; grid-template-columns: repeat(3, minmax(180px, 1fr)); gap: 8px; margin-bottom: 8px; }
.actions-grid { display:flex; gap: 12px; margin: 10px 0; }
.bulk-setup { border: 1px solid #ddd; border-radius: 8px; padding: 12px; margin-bottom: 12px; }
.bulk-grid { display:grid; grid-template-columns: repeat(4, minmax(180px, 1fr)); gap: 8px; margin-bottom: 8px; }
.row-inherited { background: #fafafa; }
.row-custom { background: #fff7e6; }
.value-editor { display: grid; grid-template-columns: repeat(2, minmax(100px, 1fr)); gap: 6px; align-items: center; }
</style>
