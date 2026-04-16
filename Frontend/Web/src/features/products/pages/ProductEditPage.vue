<script setup lang="ts">
import ProductForm from "../components/ProductForm.vue";
import type { ProductEnumItem } from "../types/productTypes";
import type { ProductFormPayload } from "../../../shared/services/backendGateway";

defineProps<{ model: ProductFormPayload; categories: ProductEnumItem[]; units: ProductEnumItem[]; pricingMaterialTypes: ProductEnumItem[]; pricingModes: ProductEnumItem[] }>();
const emit = defineEmits<{ save: []; image: [event: Event] }>();
</script>

<template>
  <ProductForm :model="model" :categories="categories" :units="units" :pricing-material-types="pricingMaterialTypes" :pricing-modes="pricingModes" :errors="{}" @save="emit('save')" @image="emit('image', $event)" />
</template>
