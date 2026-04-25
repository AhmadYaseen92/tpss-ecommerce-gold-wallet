<script setup lang="ts">
import { computed, reactive, ref, watch } from "vue";
import {
  fetchSellerFeeTabs,
  fetchSellerProductFees,
  upsertSellerProductFee,
  type SellerProductFeePayload,
  type SystemFeeTypePayload
} from "../../../shared/services/backendGateway";
import Card from "../../../shared/components/ui/Card.vue";
import FormField from "../../../shared/components/ui/FormField.vue";
import Select from "../../../shared/components/ui/Select.vue";
import Input from "../../../shared/components/ui/Input.vue";
import Checkbox from "../../../shared/components/ui/Checkbox.vue";
import Button from "../../../shared/components/ui/Button.vue";
import LoadingState from "../../../shared/components/ui/LoadingState.vue";

const props = defineProps<{
  accessToken: string;
  productId: number | null;
  sellerId?: number;
  readonly?: boolean;
}>();

const feeTabs = ref<SystemFeeTypePayload[]>([]);
const activeTab = ref("");
const loading = ref(false);
const saving = ref(false);
const error = ref("");
const feeRow = reactive<SellerProductFeePayload>({
  productId: 0,
  feeCode: "",
  isEnabled: true,
  calculationMode: "fixed",
  isOverride: true
});

const feeMetadata: Record<string, { modes: string[] }> = {
  commission_per_transaction: { modes: ["percent_with_minimum", "flat"] },
  premium_discount: { modes: ["fixed_per_unit"] },
  storage_custody_fee: { modes: ["percentage_by_held_days_after_grace_period"] },
  delivery_fee: { modes: ["fixed", "per_unit"] },
  service_charge: { modes: ["fixed", "per_unit"] }
};

const modeOptions = computed(() => feeMetadata[activeTab.value]?.modes ?? ["fixed"]);

const applyRow = (row: SellerProductFeePayload | undefined) => {
  Object.assign(feeRow, {
    productId: props.productId ?? 0,
    sellerId: props.sellerId,
    feeCode: activeTab.value,
    isEnabled: row?.isEnabled ?? true,
    calculationMode: row?.calculationMode ?? modeOptions.value[0] ?? "fixed",
    ratePercent: row?.ratePercent ?? null,
    minimumAmount: row?.minimumAmount ?? null,
    flatAmount: row?.flatAmount ?? null,
    premiumDiscountType: row?.premiumDiscountType ?? null,
    valuePerUnit: row?.valuePerUnit ?? null,
    feePercent: row?.feePercent ?? null,
    gracePeriodDays: row?.gracePeriodDays ?? null,
    fixedAmount: row?.fixedAmount ?? null,
    feePerUnit: row?.feePerUnit ?? null,
    isOverride: true
  } satisfies SellerProductFeePayload);
};

const loadFeeTabs = async () => {
  if (!props.accessToken) return;
  try {
    feeTabs.value = await fetchSellerFeeTabs(props.accessToken);
    if (!activeTab.value && feeTabs.value.length > 0) {
      activeTab.value = feeTabs.value[0].feeCode;
    }
  } catch (e) {
    error.value = e instanceof Error ? e.message : "Failed to load product fee tabs.";
  }
};

const loadRow = async () => {
  if (!props.accessToken || !props.productId || !activeTab.value) return;
  loading.value = true;
  error.value = "";
  try {
    const rows = await fetchSellerProductFees(props.accessToken, activeTab.value);
    const direct = rows.find((x) => x.productId === props.productId && x.isOverride);
    const inherited = rows.find((x) => x.productId === props.productId);
    applyRow(direct ?? inherited);
  } catch (e) {
    error.value = e instanceof Error ? e.message : "Failed to load product fee.";
  } finally {
    loading.value = false;
  }
};

const save = async () => {
  if (!props.accessToken || !props.productId || !activeTab.value) return;
  saving.value = true;
  error.value = "";
  try {
    await upsertSellerProductFee(props.accessToken, {
      ...feeRow,
      productId: props.productId,
      sellerId: props.sellerId,
      feeCode: activeTab.value,
      isOverride: true
    });
  } catch (e) {
    error.value = e instanceof Error ? e.message : "Failed to save product fee.";
  } finally {
    saving.value = false;
  }
};

watch(() => props.accessToken, () => void loadFeeTabs(), { immediate: true });
watch(() => [props.productId, activeTab.value], () => void loadRow(), { immediate: true });
</script>

<template>
  <Card title="Product Fee">
    <div v-if="!productId" class="ui-state">
      Save this product first, then configure product-level fees.
    </div>

    <template v-else>
      <p v-if="error" class="error-text">{{ error }}</p>

      <div class="ui-filter-bar">
        <FormField label="Fee Type">
          <Select v-model="activeTab" :disabled="readonly || feeTabs.length === 0">
            <option v-for="tab in feeTabs" :key="tab.feeCode" :value="tab.feeCode">
              {{ tab.name }}
            </option>
          </Select>
        </FormField>

        <FormField label="Calculation Mode">
          <Select v-model="feeRow.calculationMode" :disabled="readonly">
            <option v-for="mode in modeOptions" :key="mode" :value="mode">{{ mode }}</option>
          </Select>
        </FormField>

        <FormField label="Enabled">
          <Checkbox v-model="feeRow.isEnabled" :disabled="readonly" label="Product fee active" />
        </FormField>
      </div>

      <LoadingState v-if="loading" text="Loading product fee..." />

      <div v-else class="product-fee-grid">
        <FormField v-if="activeTab === 'commission_per_transaction' && feeRow.calculationMode !== 'flat'" label="Rate Percent">
          <Input type="number" min="0" step="0.01" v-model="feeRow.ratePercent" :disabled="readonly" />
        </FormField>
        <FormField v-if="activeTab === 'commission_per_transaction' && feeRow.calculationMode !== 'flat'" label="Minimum Amount">
          <Input type="number" min="0" step="0.01" v-model="feeRow.minimumAmount" :disabled="readonly" />
        </FormField>
        <FormField v-if="activeTab === 'commission_per_transaction' && feeRow.calculationMode === 'flat'" label="Flat Amount">
          <Input type="number" min="0" step="0.01" v-model="feeRow.flatAmount" :disabled="readonly" />
        </FormField>

        <FormField v-if="activeTab === 'premium_discount'" label="Discount Type">
          <Select v-model="feeRow.premiumDiscountType" :disabled="readonly">
            <option value="premium">Premium</option>
            <option value="discount">Discount</option>
          </Select>
        </FormField>
        <FormField v-if="activeTab === 'premium_discount'" label="Value Per Unit">
          <Input type="number" min="0" step="0.01" v-model="feeRow.valuePerUnit" :disabled="readonly" />
        </FormField>

        <FormField v-if="activeTab === 'storage_custody_fee'" label="Fee Percent">
          <Input type="number" min="0" step="0.01" v-model="feeRow.feePercent" :disabled="readonly" />
        </FormField>
        <FormField v-if="activeTab === 'storage_custody_fee'" label="Grace Period Days">
          <Input type="number" min="0" step="1" v-model="feeRow.gracePeriodDays" :disabled="readonly" />
        </FormField>

        <FormField v-if="activeTab !== 'commission_per_transaction' && activeTab !== 'premium_discount' && activeTab !== 'storage_custody_fee' && feeRow.calculationMode === 'fixed'" label="Fixed Amount">
          <Input type="number" min="0" step="0.01" v-model="feeRow.fixedAmount" :disabled="readonly" />
        </FormField>
        <FormField v-if="activeTab !== 'commission_per_transaction' && activeTab !== 'premium_discount' && activeTab !== 'storage_custody_fee' && feeRow.calculationMode === 'per_unit'" label="Fee Per Unit">
          <Input type="number" min="0" step="0.01" v-model="feeRow.feePerUnit" :disabled="readonly" />
        </FormField>
      </div>

      <div class="ui-row-actions" v-if="!readonly">
        <Button :disabled="saving" @click="save">Save Product Fee</Button>
      </div>
    </template>
  </Card>
</template>
