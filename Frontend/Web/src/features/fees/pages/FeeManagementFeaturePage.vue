<script setup lang="ts">
import { computed, onMounted, reactive, ref, watch } from "vue";
import type { ReturnTypeUseMarketplace } from "../../../shared/app/store/useMarketplace";
import SmallCheckbox from "../../../shared/components/SmallCheckbox.vue";
import SmallToggle from "../../../shared/components/SmallToggle.vue";
import CommonModal from "../../../shared/components/CommonModal.vue";
import PageHeader from "../../../shared/components/ui/PageHeader.vue";
import {
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
import { MATERIAL_TYPE_OPTIONS, PRODUCT_FORM_OPTIONS } from "../../../shared/constants/productTaxonomy";

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
const sellerProducts = ref<Array<{ id: number; name: string; materialType: string; formType: string }>>([]);
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
const enabledByProduct = reactive<Record<number, boolean>>({});
const savedRowSnapshot = reactive<Record<number, string>>({});
const savingAll = ref(false);
const pageSize = ref(10);
const pageIndex = ref(1);
const feeSearchTerm = ref("");
const feeMaterialTypeFilter = ref("all");
const feeFormTypeFilter = ref("all");

const isAdmin = computed(() => marketplace.role.value === "Admin");
const successModalOpen = ref(false);
const successMessage = ref("Saved successfully");
const adminSnapshot = ref("");
const adminSystemFees = computed(() => systemFees.value);

const feeMetadata: Record<string, { modes: string[] }> = {
  commission_per_transaction: { modes: ["percent_with_minimum", "flat"] },
  premium_discount: { modes: ["per_unit"] },
  storage_custody_fee: { modes: ["percentage_by_held_days_after_grace_period"] },
  delivery_fee: { modes: ["fixed", "per_unit"] }
};

const actionLabels: Array<keyof Pick<SystemFeeTypePayload, "appliesToBuy" | "appliesToSell" | "appliesToPickup" | "appliesToTransfer" | "appliesToGift">> = [
  "appliesToBuy",
  "appliesToSell",
  "appliesToPickup",
  "appliesToTransfer",
  "appliesToGift"
];

const defaultBulk = (feeCode: string): BulkConfig => ({
  isEnabled: true,
  calculationMode: feeMetadata[feeCode]?.modes[0] ?? "fixed",
  ratePercent: null,
  minimumAmount: null,
  flatAmount: null,
  fixedAmount: null,
  feePerUnit: null,
  valuePerUnit: null,
  feePercent: null,
  gracePeriodDays: null,
  premiumDiscountType: "premium"
});

const rowKey = (productId: number, feeCode: string) => `${productId}_${feeCode}`;
const isOverridden = (productId: number) => !!overrides[rowKey(productId, activeSellerTab.value)];
const currentBulk = computed(() => {
  if (!activeSellerTab.value) return defaultBulk("delivery_fee");
  if (!bulkByFee[activeSellerTab.value]) bulkByFee[activeSellerTab.value] = defaultBulk(activeSellerTab.value);
  return bulkByFee[activeSellerTab.value];
});

const activeTabConfig = computed(() => sellerTabs.value.find((x) => x.feeCode === activeSellerTab.value));
const actionText = computed(() => {
  const tab = activeTabConfig.value;
  if (!tab) return "-";
  const labels: string[] = [];
  if (tab.appliesToBuy) labels.push("Buy");
  if (tab.appliesToSell) labels.push("Sell");
  if (tab.appliesToPickup) labels.push("Pickup");
  if (tab.appliesToTransfer) labels.push("Transfer");
  if (tab.appliesToGift) labels.push("Gift");
  return labels.join(", ") || "-";
});

const getEffectiveRow = (productId: number): SellerProductFeePayload => {
  const override = overrides[rowKey(productId, activeSellerTab.value)];
  const enabled = enabledByProduct[productId] ?? currentBulk.value.isEnabled;
  if (override) return { ...override, isEnabled: enabled };
  return {
    productId,
    feeCode: activeSellerTab.value,
    isOverride: false,
    isEnabled: enabled,
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

const toSnapshot = (row: SellerProductFeePayload) => JSON.stringify({
  isEnabled: row.isEnabled,
  isOverride: row.isOverride,
  calculationMode: row.calculationMode,
  ratePercent: row.ratePercent,
  minimumAmount: row.minimumAmount,
  flatAmount: row.flatAmount,
  fixedAmount: row.fixedAmount,
  feePerUnit: row.feePerUnit,
  valuePerUnit: row.valuePerUnit,
  feePercent: row.feePercent,
  gracePeriodDays: row.gracePeriodDays,
  premiumDiscountType: row.premiumDiscountType
});

const isRowDirty = (productId: number) => {
  const current = getEffectiveRow(productId);
  return savedRowSnapshot[productId] !== toSnapshot(current);
};

const sellerTableRows = computed(() =>
  sellerProducts.value.map((p) => ({
    productId: p.id,
    productName: p.name,
    override: isOverridden(p.id),
    effective: getEffectiveRow(p.id),
    dirty: isRowDirty(p.id)
  }))
);

const filteredSellerRows = computed(() => {
  const query = feeSearchTerm.value.trim().toLowerCase();
  return sellerTableRows.value.filter((row) => {
    const matchedSearch = !query || row.productName.toLowerCase().includes(query) || String(row.productId).includes(query);
    const feeRow = sellerProducts.value.find((x) => x.id === row.productId);
    const matchedMaterial = feeMaterialTypeFilter.value === "all" || (feeRow?.materialType?.toLowerCase() ?? "") === feeMaterialTypeFilter.value.toLowerCase();
    const matchedForm = feeFormTypeFilter.value === "all" || (feeRow?.formType?.toLowerCase() ?? "") === feeFormTypeFilter.value.toLowerCase();
    return matchedSearch && matchedMaterial && matchedForm;
  });
});

const totalPages = computed(() => Math.max(1, Math.ceil(filteredSellerRows.value.length / pageSize.value)));
const pagedSellerRows = computed(() => {
  const start = (pageIndex.value - 1) * pageSize.value;
  return filteredSellerRows.value.slice(start, start + pageSize.value);
});
const dirtyRows = computed(() => sellerTableRows.value.filter((x) => x.dirty));
const adminDirty = computed(() => JSON.stringify({ systemFees: systemFees.value, serviceFee }) !== adminSnapshot.value);

const formulaByMode = (feeCode: string, mode: string) => {
  if (feeCode === "commission_per_transaction") return mode === "percent_with_minimum" ? "max(Notional × Rate, Min)" : "Flat Fee";
  if (feeCode === "premium_discount") return "Quantity × ValuePerUnit";
  if (feeCode === "storage_custody_fee") return "Quantity × ClosePrice × (FeePercent / 100) / 360 × DaysHeldAfterGrace";
  if (feeCode === "delivery_fee") return mode === "per_unit" ? "Quantity × FeePerUnit" : "Fixed Fee";
  return "-";
};

const valueSummary = (row: SellerProductFeePayload) => {
  if (!row.isEnabled) return "Disabled";
  if (row.feeCode === "commission_per_transaction") {
    return row.calculationMode === "percent_with_minimum" ? `${row.ratePercent ?? 0}% | Min ${row.minimumAmount ?? 0}` : `Flat ${row.flatAmount ?? 0}`;
  }
  if (row.feeCode === "premium_discount") return `${row.premiumDiscountType ?? "premium"} ${row.valuePerUnit ?? 0} / unit`;
  if (row.feeCode === "storage_custody_fee") return `${row.feePercent ?? 0}% | Grace ${row.gracePeriodDays ?? 0}d`;
  if (row.calculationMode === "per_unit") return `${row.feePerUnit ?? 0} / unit`;
  return `Fixed ${row.fixedAmount ?? row.flatAmount ?? 0}`;
};

const hydrateSnapshots = () => {
  sellerProducts.value.forEach((p) => {
    savedRowSnapshot[p.id] = toSnapshot(getEffectiveRow(p.id));
  });
};

const loadSellerRows = async () => {
  const token = marketplace.session.value?.accessToken;
  if (!token || !activeSellerTab.value) return;

  sellerTabs.value = await fetchSellerFeeTabs(token);
  sellerFeeRows.value = await fetchSellerProductFees(token, activeSellerTab.value);

  bulkByFee[activeSellerTab.value] = defaultBulk(activeSellerTab.value);
  Object.keys(overrides).forEach((k) => { if (k.endsWith(`_${activeSellerTab.value}`)) delete overrides[k]; });
  Object.keys(enabledByProduct).forEach((k) => delete enabledByProduct[Number(k)]);

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

  sellerFeeRows.value.forEach((row) => {
    enabledByProduct[row.productId] = row.isEnabled;
    if (row.isOverride) overrides[rowKey(row.productId, row.feeCode)] = { ...row, isOverride: true };
  });

  hydrateSnapshots();
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
      adminSnapshot.value = JSON.stringify({ systemFees: systemFees.value, serviceFee: { ...serviceFee } });
      return;
    }

    sellerTabs.value = await fetchSellerFeeTabs(token);
    sellerProducts.value = (await fetchManagedProducts(token)).map((p) => ({
      id: p.id,
      name: p.name,
      materialType: p.materialType,
      formType: p.formType
    }));
    if (!activeSellerTab.value && sellerTabs.value.length > 0) activeSellerTab.value = sellerTabs.value[0].feeCode;
    await loadSellerRows();
  } catch (e) {
    error.value = e instanceof Error ? e.message : "Failed to load fees.";
  } finally {
    loading.value = false;
  }
};

onMounted(load);
watch(activeSellerTab, loadSellerRows);
watch(activeSellerTab, () => {
  pageIndex.value = 1;
});
watch([feeSearchTerm, feeMaterialTypeFilter, feeFormTypeFilter], () => {
  pageIndex.value = 1;
});

const showSuccess = (message: string) => {
  successMessage.value = message;
  successModalOpen.value = true;
};

const saveAdminAllChanges = async () => {
  const token = marketplace.session.value?.accessToken;
  if (!token) return;
  for (const fee of systemFees.value) {
    await updateSystemFeeType(token, fee);
  }
  await updateAdminServiceFee(token, serviceFee);
  adminSnapshot.value = JSON.stringify({ systemFees: systemFees.value, serviceFee: { ...serviceFee } });
  showSuccess("Saved successfully");
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

const onEnabledChange = (productId: number, value: boolean) => {
  enabledByProduct[productId] = value;
};

const applyBulkToAll = async () => {
  const token = marketplace.session.value?.accessToken;
  if (!token || !activeSellerTab.value || sellerProducts.value.length === 0) return;
  const inheritedRows = sellerProducts.value.filter((p) => !isOverridden(p.id));
  for (const product of inheritedRows) {
    const template: SellerProductFeePayload = {
      productId: product.id,
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
    await upsertSellerProductFee(token, template);
  }
  await loadSellerRows();
  showSuccess("Fee settings applied to all products successfully.");
};

const saveAllChanges = async () => {
  const token = marketplace.session.value?.accessToken;
  if (!token || dirtyRows.value.length === 0) return;
  savingAll.value = true;
  try {
    for (const row of dirtyRows.value) {
      const payload = getEffectiveRow(row.productId);
      await upsertSellerProductFee(token, payload);
      savedRowSnapshot[row.productId] = toSnapshot(payload);
    }
    showSuccess("Saved successfully");
  } finally {
    savingAll.value = false;
  }
};
</script>

<template>
  <section class="dashboard-screen">
    <PageHeader title="Fees Management" subtitle="System Fee Types" />
    <p v-if="loading">Loading...</p>
    <p v-if="error" class="error-text">{{ error }}</p>

    <template v-if="isAdmin">
      <div class="table-toolbar">
        <button v-if="adminDirty" @click="saveAdminAllChanges">Save All Changes</button>
      </div>

      <div class="admin-fee-cards">
        <article v-for="fee in adminSystemFees" :key="fee.feeCode" class="fee-card">
          <header class="fee-card-header">
            <h4>{{ fee.name }}</h4>
            <label class="inline-toggle"><SmallToggle v-model="fee.isEnabled" /> Enabled</label>
          </header>
          <div class="fee-actions" :class="{ muted: !fee.isEnabled }">
            <span>Applies To:</span>
            <label v-for="action in actionLabels" :key="`${fee.feeCode}-${action}`" class="inline-toggle">
              <SmallToggle v-model="fee[action]" :disabled="!fee.isEnabled" />
              {{ action.replace("appliesTo", "") }}
            </label>
          </div>
        </article>
      </div>

      <h3>Service Fee (Admin Only)</h3>
      <article class="fee-card">
        <header class="fee-card-header">
          <h4>Service Fee</h4>
          <label class="inline-toggle"><SmallToggle v-model="serviceFee.isEnabled" /> Enabled</label>
        </header>
        <div class="bulk-grid" :class="{ muted: !serviceFee.isEnabled }">
          <label>Mode
            <select v-model="serviceFee.calculationMode" :disabled="!serviceFee.isEnabled"><option value="percent">Percent</option><option value="fixed">Fixed</option></select>
          </label>
          <label v-if="serviceFee.calculationMode === 'percent'">Rate % <input v-model.number="serviceFee.ratePercent" type="number" min="0" step="0.01" :disabled="!serviceFee.isEnabled" /></label>
          <label v-else>Fixed Amount <input v-model.number="serviceFee.fixedAmount" type="number" min="0" step="0.01" :disabled="!serviceFee.isEnabled" /></label>
        </div>
        <div class="fee-actions" :class="{ muted: !serviceFee.isEnabled }">
          <span>Applies To:</span>
          <label class="inline-toggle"><SmallToggle v-model="serviceFee.appliesToBuy" :disabled="!serviceFee.isEnabled" /> Buy</label>
          <label class="inline-toggle"><SmallToggle v-model="serviceFee.appliesToSell" :disabled="!serviceFee.isEnabled" /> Sell</label>
          <label class="inline-toggle"><SmallToggle v-model="serviceFee.appliesToPickup" :disabled="!serviceFee.isEnabled" /> Pickup</label>
          <label class="inline-toggle"><SmallToggle v-model="serviceFee.appliesToTransfer" :disabled="!serviceFee.isEnabled" /> Transfer</label>
          <label class="inline-toggle"><SmallToggle v-model="serviceFee.appliesToGift" :disabled="!serviceFee.isEnabled" /> Gift</label>
        </div>
      </article>
    </template>

    <template v-else>
      <h3>Seller Manage Fees</h3>
      <div class="table-toolbar">
        <button v-if="dirtyRows.length > 0" :disabled="savingAll" @click="saveAllChanges">
          {{ savingAll ? "Saving..." : `Save All Changes (${dirtyRows.length})` }}
        </button>
      </div>
      <div class="tabs">
        <button v-for="tab in sellerTabs" :key="tab.feeCode" :class="{ active: activeSellerTab === tab.feeCode }" @click="activeSellerTab = tab.feeCode">{{ tab.name }}</button>
      </div>
      <div class="grid">
        <input v-model="feeSearchTerm" type="text" placeholder="Search by product name or ID..." />
        <select v-model="feeMaterialTypeFilter">
          <option v-for="option in MATERIAL_TYPE_OPTIONS" :key="option.value" :value="option.value">{{ option.label }}</option>
        </select>
        <select v-model="feeFormTypeFilter">
          <option v-for="option in PRODUCT_FORM_OPTIONS" :key="option.value" :value="option.value">{{ option.label }}</option>
        </select>
      </div>

      <div class="bulk-setup" v-if="activeSellerTab">
        <h4>Bulk Setup ({{ activeSellerTab.replace(/_/g, ' ') }})</h4>
        <div class="bulk-grid">
          <label><SmallCheckbox v-model="currentBulk.isEnabled" /> Enable / Disable for all</label>
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
            <th>Enabled</th>
            <th>Override</th>
            <th>Product Id</th>
            <th>Product Name</th>
            <th>Action</th>
            <th>Mode</th>
            <th>Calculation Formula</th>
            <th>Value</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in pagedSellerRows" :key="row.productId" :class="[{ 'row-disabled': !row.effective.isEnabled, 'row-custom': row.override, 'row-inherited': !row.override }]">
            <td>
              <SmallCheckbox :model-value="row.effective.isEnabled" @update:model-value="onEnabledChange(row.productId, $event)" />
            </td>
            <td>
              <SmallCheckbox :model-value="row.override" @update:model-value="toggleOverride(row.productId, $event)" />
              <small class="badge" :class="row.override ? 'custom' : 'inherited'">{{ row.override ? 'Custom' : 'Inherited' }}</small>
            </td>
            <td>{{ row.productId }}</td>
            <td>{{ row.productName }}</td>
            <td>{{ actionText }}</td>
            <td :class="{ muted: !row.override || !row.effective.isEnabled }">
              <select v-if="row.override" v-model="overrides[rowKey(row.productId, activeSellerTab)].calculationMode">
                <option v-for="mode in (feeMetadata[activeSellerTab]?.modes ?? ['fixed'])" :key="mode" :value="mode">{{ mode }}</option>
              </select>
              <span v-else>{{ row.effective.calculationMode }}</span>
            </td>
            <td :class="{ muted: !row.effective.isEnabled }">{{ formulaByMode(activeSellerTab, row.effective.calculationMode) }}</td>
            <td :class="{ muted: !row.effective.isEnabled }">
              <template v-if="!row.effective.isEnabled">--</template>
              <div v-else-if="row.override" class="value-editor">
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
              </div>
              <span v-else>{{ valueSummary(row.effective) }}</span>
            </td>
          </tr>
        </tbody>
      </table>
      <div class="pager">
        <span>Rows {{ filteredSellerRows.length === 0 ? 0 : (pageIndex - 1) * pageSize + 1 }} - {{ Math.min(pageIndex * pageSize, filteredSellerRows.length) }} of {{ filteredSellerRows.length }}</span>
        <button :disabled="pageIndex <= 1" @click="pageIndex--">&lt;</button>
        <span>{{ pageIndex }} / {{ totalPages }}</span>
        <button :disabled="pageIndex >= totalPages" @click="pageIndex++">&gt;</button>
      </div>
    </template>
    <CommonModal :open="successModalOpen" title="Success" :message="successMessage" @close="successModalOpen = false" />
  </section>
</template>

<style scoped>
.tabs { display: flex; gap: 8px; margin-bottom: 10px; flex-wrap: wrap; }
.tabs button.active { background: var(--primary); color: var(--text-inverse); }
.grid { display:grid; grid-template-columns: repeat(3, minmax(180px, 1fr)); gap: 8px; margin-bottom: 8px; }
.actions-grid { display:flex; gap: 12px; margin: 10px 0; }
.bulk-setup { border: 1px solid var(--border-strong); border-radius: 8px; padding: 12px; margin-bottom: 12px; background: var(--surface-elevated); }
.bulk-grid { display:grid; grid-template-columns: repeat(4, minmax(180px, 1fr)); gap: 8px; margin-bottom: 8px; }
.admin-fee-cards { display: grid; gap: 10px; margin-bottom: 16px; }
.fee-card { border: 1px solid var(--border-strong); border-radius: 10px; padding: 12px; background: var(--surface-elevated); color: var(--text); }
.fee-card-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 10px; }
.fee-card-header h4 { margin: 0; }
.fee-actions { display: flex; flex-wrap: wrap; gap: 10px; align-items: center; }
.inline-toggle { display: inline-flex; align-items: center; gap: 6px; }
.row-inherited { background: color-mix(in srgb, var(--surface-solid) 88%, var(--bg)); }
.row-custom { background: color-mix(in srgb, var(--warning-soft) 35%, var(--surface-elevated)); }
.row-disabled { opacity: 0.7; background: color-mix(in srgb, var(--surface-solid) 70%, var(--bg-soft)); }
.muted { color: var(--text-muted); }
.value-editor { display: grid; grid-template-columns: repeat(2, minmax(100px, 1fr)); gap: 6px; align-items: center; }
.badge { margin-left: 6px; font-size: 11px; padding: 1px 6px; border-radius: 8px; }
.badge.inherited { background: color-mix(in srgb, var(--info-soft) 70%, transparent); color: var(--text-soft); }
.badge.custom { background: color-mix(in srgb, var(--warning-soft) 70%, transparent); color: #92400e; }
.table-toolbar { margin-bottom: 8px; display: flex; justify-content: flex-end; }
.pager { margin-top: 10px; display: flex; gap: 8px; justify-content: flex-end; align-items: center; }
</style>
