<script setup lang="ts">
import { computed, watch } from "vue";
import BaseFormField from "../../../shared/components/BaseFormField.vue";
import type { ProductEnumItem } from "../types/productTypes";
import type { ProductFormPayload } from "../../../shared/services/backendGateway";
import type { MarketPriceConfigDto } from "../../../shared/types/apiTypes";

const props = defineProps<{ model: ProductFormPayload; categories: ProductEnumItem[]; units: ProductEnumItem[]; errors: Record<string, string>; marketPrices: MarketPriceConfigDto }>();
const emit = defineEmits<{ save: []; image: [event: Event] }>();

const isAutoMode = computed(() => props.model.pricingMode === 1);
const isManualMode = computed(() => props.model.pricingMode === 2);
const isGold = computed(() => props.model.materialType === 1);
const isSilver = computed(() => props.model.materialType === 2);
const isDiamond = computed(() => props.model.materialType === 3);

const karatFactorMap: Record<number, number> = { 0: 1, 1: 1, 2: 0.9167, 3: 0.875, 4: 0.75, 5: 0.585 };

watch(
  () => [props.model.materialType, props.model.purityKarat],
  () => {
    if (isDiamond.value) {
      props.model.purityKarat = 0;
      props.model.purityFactor = 1;
      return;
    }

    if (isGold.value) {
      props.model.purityFactor = karatFactorMap[props.model.purityKarat] ?? 1;
      return;
    }

    if (isSilver.value) {
      props.model.purityFactor = props.model.purityKarat > 0 ? 0.999 : 1;
    }
  },
  { immediate: true }
);

const offerEnabled = computed({
  get: () => props.model.offerType !== 0,
  set: (value: boolean) => {
    if (!value) {
      props.model.offerType = 0;
      props.model.offerPercent = 0;
      props.model.offerNewPrice = 0;
    } else if (props.model.offerType === 0) {
      props.model.offerType = 1;
    }
  }
});

const selectedMarketPrice = computed(() => {
  if (isGold.value) return props.marketPrices.goldPerOunce;
  if (isSilver.value) return props.marketPrices.silverPerOunce;
  return props.marketPrices.diamondPerCarat;
});

const estimatedAutoPrice = computed(() => {
  const weight = Number(props.model.weightValue || 0);
  const market = Number(selectedMarketPrice.value || 0);
  if (weight <= 0 || market <= 0) return 0;

  const base = isDiamond.value ? (weight / 0.2) * market : (weight / 31.1035) * market;
  const fees = Number(props.model.deliveryFee || 0) + Number(props.model.storageFee || 0) + Number(props.model.serviceCharge || 0);
  let total = base * Number(props.model.purityFactor || 1) + fees;

  if (props.model.offerType === 1 && props.model.offerPercent > 0) {
    total = total * (1 - props.model.offerPercent / 100);
  } else if (props.model.offerType === 2 && props.model.offerNewPrice > 0) {
    total = props.model.offerNewPrice;
  }

  return Number.isFinite(total) ? total : 0;
});
</script>

<template>
  <div class="grid-two form-grid-two">
    <BaseFormField label="Name" required :error="errors.name"><input v-model="model.name" /></BaseFormField>
    <BaseFormField label="SKU" required :error="errors.sku"><input v-model="model.sku" /></BaseFormField>
    <BaseFormField label="Description" required :error="errors.description"><input v-model="model.description" /></BaseFormField>
    <BaseFormField label="Image"><input type="file" @change="emit('image', $event)" /></BaseFormField>

    <BaseFormField label="Material Type" required :error="errors.materialType">
      <select v-model.number="model.materialType"><option :value="1">Gold</option><option :value="2">Silver</option><option :value="3">Diamond</option></select>
    </BaseFormField>
    <BaseFormField label="Product Form" required :error="errors.formType">
      <select v-model.number="model.formType"><option :value="1">Jewelry</option><option :value="2">Coin</option><option :value="3">Bar</option><option :value="4">Other</option></select>
    </BaseFormField>

    <BaseFormField label="Weight (grams)" required hint="All product weights must be entered in grams." :error="errors.weightValue">
      <input v-model.number="model.weightValue" type="number" min="0" step="0.01" />
    </BaseFormField>

    <BaseFormField label="Pricing Mode" hint="Auto uses provider market prices configured on this page.">
      <select v-model.number="model.pricingMode"><option :value="1">Auto</option><option :value="2">Manual</option></select>
    </BaseFormField>

    <BaseFormField v-if="isGold || isSilver" label="Purity/Karat" hint="Selecting karat updates purity factor automatically.">
      <select v-model.number="model.purityKarat"><option :value="0">Not applicable</option><option :value="1">24K</option><option :value="2">22K</option><option :value="3">21K</option><option :value="4">18K</option><option :value="5">14K</option></select>
    </BaseFormField>

    <BaseFormField v-if="!isDiamond" label="Purity Factor"><input v-model.number="model.purityFactor" type="number" min="0" step="0.0001" /></BaseFormField>

    <BaseFormField v-if="isManualMode" label="Manual Sell Price" :error="errors.manualSellPrice"><input v-model.number="model.manualSellPrice" type="number" min="0" /></BaseFormField>

    <BaseFormField label="Delivery Fee"><input v-model.number="model.deliveryFee" type="number" min="0" /></BaseFormField>
    <BaseFormField label="Storage Fee"><input v-model.number="model.storageFee" type="number" min="0" /></BaseFormField>
    <BaseFormField label="Service Charge"><input v-model.number="model.serviceCharge" type="number" min="0" /></BaseFormField>

    <BaseFormField label="Enable Offer" class="field-full">
      <label class="checkbox-line"><input v-model="offerEnabled" type="checkbox" /> Enable offer pricing</label>
    </BaseFormField>

    <BaseFormField v-if="offerEnabled" label="Offer Type">
      <select v-model.number="model.offerType"><option :value="1">Percent-Based</option><option :value="2">Fixed-Price-Based</option></select>
    </BaseFormField>

    <BaseFormField v-if="offerEnabled && model.offerType === 1" label="Offer Percent"><input v-model.number="model.offerPercent" type="number" min="0" max="100" /></BaseFormField>
    <BaseFormField v-if="offerEnabled && model.offerType === 2" label="Offer New Price"><input v-model.number="model.offerNewPrice" type="number" min="0" /></BaseFormField>

    <BaseFormField label="Available Stock" required :error="errors.availableStock"><input v-model.number="model.availableStock" type="number" /></BaseFormField>
    <BaseFormField label="Status" class="field-full"><label class="checkbox-line"><input v-model="model.isActive" type="checkbox" /> Is Active</label></BaseFormField>

    <div class="field-full muted">Selected market price source: <strong>{{ selectedMarketPrice.toFixed(2) }}</strong> ({{ isGold ? 'Gold/oz' : isSilver ? 'Silver/oz' : 'Diamond/carat' }}).</div>
    <div class="field-full muted">Estimated {{ isAutoMode ? 'Auto' : 'Final (with manual mode + offers)' }} Price: <strong>{{ (isAutoMode ? estimatedAutoPrice : (model.offerType === 1 ? (model.manualSellPrice * (1 - model.offerPercent / 100)) : model.offerType === 2 ? model.offerNewPrice : model.manualSellPrice)).toFixed(2) }}</strong></div>
  </div>
  <button @click="emit('save')">Save</button>
</template>
