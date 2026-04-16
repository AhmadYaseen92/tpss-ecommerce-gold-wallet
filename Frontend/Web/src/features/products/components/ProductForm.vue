<script setup lang="ts">
import BaseFormField from "../../../shared/components/BaseFormField.vue";
import type { ProductEnumItem } from "../types/productTypes";
import type { ProductFormPayload } from "../../../shared/services/backendGateway";

defineProps<{ model: ProductFormPayload; categories: ProductEnumItem[]; units: ProductEnumItem[]; pricingMaterialTypes: ProductEnumItem[]; pricingModes: ProductEnumItem[]; errors: Record<string, string> }>();
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

    <BaseFormField label="Category" required hint="Choose product category." :error="errors.category">
      <select v-model.number="model.category" :class="{ 'input-error': !!errors.category }">
        <option :value="0" disabled>Select category</option>
        <option v-for="c in categories" :key="c.value" :value="c.value">{{ c.name }}</option>
      </select>
    </BaseFormField>

    <BaseFormField label="Weight Value" required hint="Numeric value of weight." :error="errors.weightValue">
      <input v-model.number="model.weightValue" :class="{ 'input-error': !!errors.weightValue }" type="number" placeholder="WeightValue" />
    </BaseFormField>

    <BaseFormField label="Material Type" required hint="Source used for pricing." :error="errors.pricingMaterialType">
      <select v-model.number="model.pricingMaterialType" :class="{ 'input-error': !!errors.pricingMaterialType }">
        <option v-for="m in pricingMaterialTypes" :key="m.value" :value="m.value">{{ m.name }}</option>
      </select>
    </BaseFormField>

    <BaseFormField label="Pricing Mode" required hint="Auto uses market+fees, manual uses entered price." :error="errors.pricingMode">
      <select v-model.number="model.pricingMode" :class="{ 'input-error': !!errors.pricingMode }">
        <option v-for="mode in pricingModes" :key="mode.value" :value="mode.value">{{ mode.name }}</option>
      </select>
    </BaseFormField>

    <BaseFormField label="Purity / Karat" hint="Used for Gold/Silver auto pricing.">
      <input v-model.number="model.purityKarat" type="number" placeholder="e.g. 24 or 18" />
    </BaseFormField>

    <BaseFormField label="Weight Unit" required hint="Unit for weight." :error="errors.weightUnit">
      <select v-model.number="model.weightUnit" :class="{ 'input-error': !!errors.weightUnit }">
        <option :value="0" disabled>Select unit</option>
        <option v-for="u in units" :key="u.value" :value="u.value">{{ u.name }}</option>
      </select>
    </BaseFormField>

    <BaseFormField label="Price" required hint="Selling price." :error="errors.price">
      <input v-model.number="model.price" :class="{ 'input-error': !!errors.price }" type="number" placeholder="Price" />
    </BaseFormField>

    <BaseFormField label="Market Unit Price" hint="Price per gram for auto mode.">
      <input v-model.number="model.marketUnitPrice" type="number" placeholder="MarketUnitPrice" />
    </BaseFormField>

    <BaseFormField label="Delivery Fee" hint="Fixed fee.">
      <input v-model.number="model.deliveryFee" type="number" placeholder="DeliveryFee" />
    </BaseFormField>

    <BaseFormField label="Storage Fee" hint="Fixed fee.">
      <input v-model.number="model.storageFee" type="number" placeholder="StorageFee" />
    </BaseFormField>

    <BaseFormField label="Service Charge" hint="Fixed service amount.">
      <input v-model.number="model.serviceCharge" type="number" placeholder="ServiceCharge" />
    </BaseFormField>

    <BaseFormField label="Available Stock" required hint="Quantity available." :error="errors.availableStock">
      <input v-model.number="model.availableStock" :class="{ 'input-error': !!errors.availableStock }" type="number" placeholder="AvailableStock" />
    </BaseFormField>

    <BaseFormField label="Status" hint="Toggle active/inactive." class="field-full">
      <label class="checkbox-line"><input v-model="model.isActive" type="checkbox" /> Is Active</label>
    </BaseFormField>
  </div>
  <button @click="emit('save')">Save</button>
</template>
