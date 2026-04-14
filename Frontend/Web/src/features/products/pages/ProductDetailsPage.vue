<script setup lang="ts">
import ProductDetails from "../components/ProductDetails.vue";
import type { ProductListItem } from "../types/productTypes";

defineProps<{ product: ProductListItem | null }>();
</script>

<template>
  <ProductDetails :product="product" />
</template>
