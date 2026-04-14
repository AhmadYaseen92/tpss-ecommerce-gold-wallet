<script setup lang="ts">
import type { ReturnTypeUseMarketplace } from "../../../shared/app/store/useMarketplace";
import { useProductManagement } from "../store/useProductManagement";
import ProductManagementPage from "./ProductManagementPage.vue";
import SectionCard from "../../../shared/components/SectionCard.vue";

const { marketplace } = defineProps<{ marketplace: ReturnTypeUseMarketplace }>();
const pm = useProductManagement(marketplace);
</script>

<template>
  <SectionCard title="Products Management">
    <ProductManagementPage
      :role="marketplace.role.value"
      :product-error="pm.productError"
      :product-page="pm.productPage"
      :product-route-id="pm.productRouteId"
      :managed-products="pm.managedProducts"
      :selected-product="pm.selectedProduct"
      :product-form="pm.productForm"
      :categories="pm.categories"
      :weight-units="pm.weightUnits"
      :validation-errors="pm.validationErrors"
      @add="pm.openAddProduct"
      @details="pm.openProductDetails"
      @edit="pm.openEditProduct"
      @toggle="pm.toggleProductActive"
      @delete="pm.deleteProductRecord"
      @back="pm.navigate('#/products')"
      @save="pm.saveProduct"
      @image="pm.onProductImageChange"
    />
  </SectionCard>
</template>
