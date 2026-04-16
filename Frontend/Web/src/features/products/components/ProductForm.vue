<script setup lang="ts">
import BaseFormField from "../../../shared/components/BaseFormField.vue";
import type { ProductEnumItem } from "../types/productTypes";
import type { ProductFormPayload } from "../../../shared/services/backendGateway";

defineProps<{ model: ProductFormPayload; categories: ProductEnumItem[]; units: ProductEnumItem[]; errors: Record<string, string> }>();
const emit = defineEmits<{ save: []; image: [event: Event] }>();

</script>

<template>
  <div class="grid-two form-grid-two">
    <BaseFormField label="Name" required hint="Product display name." :error="errors.name">
      <input v-model="model.name" :class="{ 'input-error': !!errors.name }" placeholder="Name" required />
    </BaseFormField>

    <BaseFormField label="SKU" required hint="Unique stock keeping unit." :error="errors.sku">
      <input v-model="model.sku" :class="{ 'input-error': !!errors.sku }" placeholder="Sku" required />
    </BaseFormField>

    <BaseFormField label="Description" required hint="Short description for buyers." :error="errors.description">
      <input v-model="model.description" :class="{ 'input-error': !!errors.description }" placeholder="Description" required />
    </BaseFormField>

    <BaseFormField label="Image" hint="Upload product image.">
      <input type="file" @change="emit('image', $event)" />
    </BaseFormField>

    <BaseFormField label="Material Type" required hint="Select Gold, Silver, or Diamond." :error="errors.materialType">
      <select v-model.number="model.materialType" :class="{ 'input-error': !!errors.materialType }">
        <option :value="1">Gold</option>
        <option :value="2">Silver</option>
        <option :value="3">Diamond</option>
      </select>
    </BaseFormField>

    <BaseFormField label="Product Form" required hint="Select Jewelry, Coin, Bar, or Other." :error="errors.formType">
      <select v-model.number="model.formType" :class="{ 'input-error': !!errors.formType }">
        <option :value="1">Jewelry</option>
        <option :value="2">Coin</option>
        <option :value="3">Bar</option>
        <option :value="4">Other</option>
      </select>
    </BaseFormField>

    <BaseFormField label="Weight (grams)" required hint="All product weights must be entered in grams." :error="errors.weightValue">
      <input v-model.number="model.weightValue" :class="{ 'input-error': !!errors.weightValue }" type="number" min="0" placeholder="Weight in grams" />
    </BaseFormField>

    <BaseFormField label="Pricing Mode" required hint="Auto is default. Manual allows direct sell price." :error="errors.pricingMode">
      <select v-model.number="model.pricingMode" :class="{ 'input-error': !!errors.pricingMode }">
        <option :value="1">Auto</option>
        <option :value="2">Manual</option>
      </select>
    </BaseFormField>

    <BaseFormField label="Purity/Karat" hint="Used in auto pricing when applicable.">
      <select v-model.number="model.purityKarat">
        <option :value="0">Not applicable</option>
        <option :value="1">24K</option>
        <option :value="2">22K</option>
        <option :value="3">21K</option>
        <option :value="4">18K</option>
        <option :value="5">14K</option>
      </select>
    </BaseFormField>

    <BaseFormField label="Purity Factor" hint="Examples: 24K=1.0, 22K=0.9167">
      <input v-model.number="model.purityFactor" type="number" min="0" step="0.0001" />
    </BaseFormField>

    
    <BaseFormField label="Manual Sell Price" hint="Used only when pricing mode = Manual. Auto mode uses global market price configured by admin.">
      <input v-model.number="model.manualSellPrice" type="number" min="0" />
    </BaseFormField>

    <BaseFormField label="Delivery Fee"><input v-model.number="model.deliveryFee" type="number" min="0" /></BaseFormField>
    <BaseFormField label="Storage Fee"><input v-model.number="model.storageFee" type="number" min="0" /></BaseFormField>
    <BaseFormField label="Service Charge"><input v-model.number="model.serviceCharge" type="number" min="0" /></BaseFormField>

    <BaseFormField label="Offer Type" hint="None, percent-based, or fixed-price based.">
      <select v-model.number="model.offerType">
        <option :value="0">None</option>
        <option :value="1">Percent-Based</option>
        <option :value="2">Fixed-Price-Based</option>
      </select>
    </BaseFormField>

    <BaseFormField label="Offer Percent" hint="Used when offer type is percent-based.">
      <input v-model.number="model.offerPercent" type="number" min="0" max="100" />
    </BaseFormField>

    <BaseFormField label="Offer New Price" hint="Used when offer type is fixed-price-based.">
      <input v-model.number="model.offerNewPrice" type="number" min="0" />
    </BaseFormField>

    <BaseFormField label="Available Stock" required hint="Quantity available." :error="errors.availableStock">
      <input v-model.number="model.availableStock" :class="{ 'input-error': !!errors.availableStock }" type="number" placeholder="AvailableStock" />
    </BaseFormField>

    <BaseFormField label="Status" hint="Toggle active/inactive." class="field-full">
      <label class="checkbox-line"><input v-model="model.isActive" type="checkbox" /> Is Active</label>
    </BaseFormField>

    <div class="field-full muted">Auto mode is default. Final sell price = base price × weight × purity + fees, then offer adjustment if selected.</div>
  </div>
  <button @click="emit('save')">Save</button>
</template>
