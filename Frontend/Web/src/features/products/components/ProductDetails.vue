<script setup lang="ts">
import type { ProductListItem } from "../types/productTypes";

defineProps<{ product: ProductListItem | null }>();
</script>

<template>
  <div class="product-details" v-if="product">
    <p><strong>Name:</strong> {{ product.name }}</p>
    <p><strong>Sku:</strong> {{ product.sku }}</p>
    <p><strong>Description:</strong> {{ product.description }}</p>
    <p><strong>ImageUrl:</strong> {{ product.imageUrl }}</p>
    <p><strong>Category:</strong> {{ product.category }}</p>
    <p><strong>PricingMaterialType:</strong> {{ product.pricingMaterialType }}</p>
    <p><strong>PricingMode:</strong> {{ product.pricingMode }}</p>
    <p><strong>WeightValue:</strong> {{ product.weightValue }}</p>
    <p><strong>WeightUnit:</strong> {{ product.weightUnit }}</p>
    <p><strong>PurityKarat:</strong> {{ product.purityKarat ?? "-" }}</p>
    <p><strong>MarketUnitPrice:</strong> {{ product.marketUnitPrice }}</p>
    <p><strong>DeliveryFee:</strong> {{ product.deliveryFee }}</p>
    <p><strong>StorageFee:</strong> {{ product.storageFee }}</p>
    <p><strong>ServiceCharge:</strong> {{ product.serviceCharge }}</p>
    <p><strong>FinalSellPrice:</strong> {{ product.finalSellPrice }}</p>
    <p><strong>Price:</strong> {{ product.price }}</p>
    <p><strong>AvailableStock:</strong> {{ product.availableStock }}</p>
    <p><strong>IsActive:</strong> {{ product.isActive }}</p>
    <p><strong>CreatedAtUtc:</strong> {{ product.createdAtUtc }}</p>
    <p><strong>UpdatedAtUtc:</strong> {{ product.updatedAtUtc ?? "-" }}</p>
  </div>
</template>
