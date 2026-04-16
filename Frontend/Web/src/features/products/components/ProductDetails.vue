<script setup lang="ts">
import type { ProductListItem } from "../types/productTypes";

defineProps<{ product: ProductListItem | null }>();
</script>

<template>
  <div class="product-details" v-if="product">
    <img v-if="product.imageUrl" :src="product.imageUrl" :alt="product.name" class="detail-image" />
    <div v-else class="detail-image placeholder">No image</div>
    <p><strong>Name:</strong> {{ product.name }}</p>
    <p><strong>SKU:</strong> {{ product.sku }}</p>
    <p><strong>Description:</strong> {{ product.description }}</p>
    <p><strong>Category:</strong> {{ product.category }}</p>
    <p><strong>Weight:</strong> {{ product.weightValue }} {{ product.weightUnit }}</p>
    <p><strong>Price:</strong> {{ product.price }}</p>
    <p><strong>Available Stock:</strong> {{ product.availableStock }}</p>
    <p><strong>Status:</strong> {{ product.isActive ? 'Active' : 'Inactive' }}</p>
    <p><strong>Seller ID:</strong> {{ product.sellerId }}</p>
    <p><strong>Image URL:</strong> {{ product.imageUrl || '—' }}</p>
  </div>
</template>

<style scoped>
.detail-image {
  width: 160px;
  height: 160px;
  object-fit: cover;
  border-radius: 12px;
  border: 1px solid #d4d4d8;
  margin-bottom: 12px;
}

.placeholder {
  display: flex;
  align-items: center;
  justify-content: center;
  color: #71717a;
}
</style>
