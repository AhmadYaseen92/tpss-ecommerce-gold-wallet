<script setup lang="ts">
import ProductListTable from "../components/ProductListTable.vue";
import type { ProductListItem } from "../types/productTypes";

defineProps<{ products: ProductListItem[] }>();
const emit = defineEmits<{ view: [product: ProductListItem]; edit: [product: ProductListItem]; toggle: [product: ProductListItem] }>();
</script>

<template>
  <ProductListTable :products="products" @view="emit('view', $event)" @edit="emit('edit', $event)" @toggle="emit('toggle', $event)" />
</template>
