<script setup lang="ts">
import { computed, onBeforeUnmount, ref, watch } from "vue";
import BaseFormField from "../../../shared/components/BaseFormField.vue";
import type { ProductEnumItem } from "../types/productTypes";
import type { ProductFormPayload } from "../../../shared/services/backendGateway";
import type { MarketPriceConfigDto } from "../../../shared/types/apiTypes";

const props = withDefaults(defineProps<{ model: ProductFormPayload; categories: ProductEnumItem[]; units: ProductEnumItem[]; errors: Record<string, string>; marketPrices?: MarketPriceConfigDto }>(), {
  marketPrices: () => ({ goldPerOunce: 0, silverPerOunce: 0, diamondPerCarat: 0 })
});
const emit = defineEmits<{ save: []; image: [event: Event] }>();

const isAutoMode = computed(() => props.model.pricingMode === 1);
const isManualMode = computed(() => props.model.pricingMode === 2);
const isGold = computed(() => props.model.materialType === 1);
const isSilver = computed(() => props.model.materialType === 2);
const isDiamond = computed(() => props.model.materialType === 3);

const materialLabel = computed(() => (isGold.value ? "Gold" : isSilver.value ? "Silver" : "Diamond"));
const formLabel = computed(() => (props.model.formType === 1 ? "Jewelry" : props.model.formType === 2 ? "Coin" : props.model.formType === 3 ? "Bar" : "Other"));
const purityLabel = computed(() => {
  if (isGold.value) return props.model.purityKarat > 0 ? `${["", "24K", "22K", "21K", "18K", "14K"][props.model.purityKarat]}` : "No karat";
  if (isSilver.value) return props.model.purityFactor === 0.925 ? "925" : "999";
  return "Diamond Standard";
});

const karatFactorMap: Record<number, number> = { 0: 1, 1: 1, 2: 0.916, 3: 0.875, 4: 0.75, 5: 0.585 };
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
      if (![0.999, 0.925].includes(Number(props.model.purityFactor))) props.model.purityFactor = 0.999;
      props.model.purityKarat = 0;
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

const selectedMarketPrice = computed(() => (isGold.value ? props.marketPrices.goldPerOunce : isSilver.value ? props.marketPrices.silverPerOunce : props.marketPrices.diamondPerCarat));
const imagePreviewUrl = ref<string>("");

watch(
  () => props.model.imageFile,
  (file) => {
    if (imagePreviewUrl.value.startsWith("blob:")) URL.revokeObjectURL(imagePreviewUrl.value);
    if (file instanceof File) {
      imagePreviewUrl.value = URL.createObjectURL(file);
      return;
    }
    imagePreviewUrl.value = props.model.existingImageUrl || "";
  },
  { immediate: true }
);

watch(
  () => props.model.existingImageUrl,
  (url) => {
    if (!(props.model.imageFile instanceof File)) imagePreviewUrl.value = url || "";
  }
);

onBeforeUnmount(() => {
  if (imagePreviewUrl.value.startsWith("blob:")) URL.revokeObjectURL(imagePreviewUrl.value);
});

const estimatedAutoPrice = computed(() => {
  const weight = Number(props.model.weightValue || 0);
  const market = Number(selectedMarketPrice.value || 0);
  if (weight <= 0 || market <= 0) return 0;
  const base = isDiamond.value ? (weight / 0.2) * market : (weight / 31.1035) * market;
  const fees = Number(props.model.deliveryFee || 0) + Number(props.model.storageFee || 0) + Number(props.model.serviceCharge || 0);
  return Number.isFinite(base) ? base * Number(props.model.purityFactor || 1) + fees : 0;
});

const finalSellPrice = computed(() => {
  const base = isAutoMode.value ? estimatedAutoPrice.value : Number(props.model.manualSellPrice || 0);
  if (props.model.offerType === 1 && props.model.offerPercent > 0) return base * (1 - props.model.offerPercent / 100);
  if (props.model.offerType === 2 && props.model.offerNewPrice > 0) return Number(props.model.offerNewPrice || 0);
  return base;
});

const sellPriceSummary = computed(() => `${materialLabel.value} ${Number(props.model.weightValue || 0).toFixed(2)} Grams, ${purityLabel.value}, ${formLabel.value}`);
</script>

<template>
  <div class="form-sections-grid">
    <section class="section-card">
      <h4>1) Product Basics</h4>
      <BaseFormField label="Name" required :error="errors.name"><input v-model="model.name" /></BaseFormField>
      <BaseFormField label="SKU" required :error="errors.sku"><input v-model="model.sku" /></BaseFormField>
      <BaseFormField label="Description" required :error="errors.description">
        <textarea v-model="model.description" rows="5" class="description-input"></textarea>
      </BaseFormField>
      <BaseFormField label="Image">
        <input type="file" accept="image/*" @change="emit('image', $event)" />
        <div v-if="imagePreviewUrl" class="image-preview-wrap">
          <img :src="imagePreviewUrl" :alt="`${model.name || 'Product'} preview`" class="image-preview" />
        </div>
      </BaseFormField>
    </section>

    <section class="section-card">
      <h4>2) Material & Item Properties</h4>
      <BaseFormField label="Material Type" required :error="errors.materialType"><select v-model.number="model.materialType"><option :value="1">Gold</option><option :value="2">Silver</option><option :value="3">Diamond</option></select></BaseFormField>
      <BaseFormField label="Product Form" required :error="errors.formType"><select v-model.number="model.formType"><option :value="1">Jewelry</option><option :value="2">Coin</option><option :value="3">Bar</option><option :value="4">Other</option></select></BaseFormField>
      <BaseFormField label="Weight (grams)" required hint="All product weights must be entered in grams." :error="errors.weightValue"><input v-model.number="model.weightValue" type="number" min="0" step="0.01" /></BaseFormField>
      <BaseFormField v-if="isGold" label="Purity/Karat"><select v-model.number="model.purityKarat"><option :value="0">Not applicable</option><option :value="1">24K</option><option :value="2">22K</option><option :value="3">21K</option><option :value="4">18K</option><option :value="5">14K</option></select></BaseFormField>
      <BaseFormField v-if="isSilver" label="Silver Purity"><select :value="model.purityFactor" @change="model.purityFactor = Number(($event.target as HTMLSelectElement).value)"><option :value="0.999">999 (0.999)</option><option :value="0.925">925 (0.925)</option></select></BaseFormField>
      <BaseFormField v-if="!isDiamond" label="Purity Factor"><input :value="model.purityFactor" readonly /></BaseFormField>
    </section>

    <section class="section-card">
      <h4>3) Pricing Mode</h4>
      <BaseFormField label="Pricing Mode"><select v-model.number="model.pricingMode"><option :value="1">Auto</option><option :value="2">Manual</option></select></BaseFormField>
      <BaseFormField v-if="isManualMode" label="Manual Sell Price" :error="errors.manualSellPrice"><input v-model.number="model.manualSellPrice" type="number" min="0" /></BaseFormField>
      <div v-if="isAutoMode" class="muted">Selected Market Price Source: <strong>{{ selectedMarketPrice.toFixed(2) }}</strong> ({{ isGold ? 'Gold per ounce' : isSilver ? 'Silver per ounce' : 'Diamond per carat' }})</div>
      <div v-if="isAutoMode" class="muted">Auto Calculated Price: <strong>{{ estimatedAutoPrice.toFixed(2) }}</strong></div>
    </section>

    <section class="section-card">
      <h4>4) Fees & Offer</h4>
      <BaseFormField label="Delivery Fee"><input v-model.number="model.deliveryFee" type="number" min="0" /></BaseFormField>
      <BaseFormField label="Storage Fee"><input v-model.number="model.storageFee" type="number" min="0" /></BaseFormField>
      <BaseFormField label="Service Charge"><input v-model.number="model.serviceCharge" type="number" min="0" /></BaseFormField>
      <BaseFormField label="Enable Offer"><label class="checkbox-line"><input v-model="offerEnabled" type="checkbox" /> Enable offer pricing</label></BaseFormField>
      <BaseFormField v-if="offerEnabled" label="Offer Type"><select v-model.number="model.offerType"><option :value="1">Percent-Based</option><option :value="2">Fixed-Price-Based</option></select></BaseFormField>
      <BaseFormField v-if="offerEnabled && model.offerType === 1" label="Offer Percent"><input v-model.number="model.offerPercent" type="number" min="0" max="100" /></BaseFormField>
      <BaseFormField v-if="offerEnabled && model.offerType === 2" label="Offer New Price"><input v-model.number="model.offerNewPrice" type="number" min="0" /></BaseFormField>
    </section>

    <section class="section-card full-row">
      <h4>5) Final Investor Price</h4>
      <BaseFormField label="Sell Price" hint="This is the final investor price including all applicable pricing rules, fees, and offer logic.">
        <input :value="finalSellPrice.toFixed(2)" readonly />
      </BaseFormField>
      <div class="muted"><strong>Sell Price Composition:</strong> {{ sellPriceSummary }}</div>
      <BaseFormField label="Available Stock" required :error="errors.availableStock"><input v-model.number="model.availableStock" type="number" /></BaseFormField>
      <BaseFormField label="Status"><label class="checkbox-line"><input v-model="model.isActive" type="checkbox" /> Is Active</label></BaseFormField>
      <button @click="emit('save')">Save</button>
    </section>
  </div>
</template>

<style scoped>
.form-sections-grid { display:grid; grid-template-columns: 1fr 1fr; gap: 12px; }
.section-card { border:1px solid #e4e4e7; border-radius:10px; padding:12px; background:#fff; display:flex; flex-direction:column; gap:8px; }
.section-card h4 { margin:0 0 6px; }
.full-row { grid-column: 1 / -1; }
.muted { color:#475569; font-size:13px; }
.description-input { min-height: 120px; resize: vertical; }
.image-preview-wrap { margin-top: 8px; }
.image-preview { width: 100%; max-width: 220px; max-height: 220px; object-fit: cover; border-radius: 10px; border: 1px solid #d4d4d8; }
@media (max-width: 900px) { .form-sections-grid { grid-template-columns: 1fr; } }
</style>
