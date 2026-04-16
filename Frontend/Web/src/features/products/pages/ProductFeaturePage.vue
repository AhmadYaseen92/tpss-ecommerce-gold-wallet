<script setup lang="ts">
import { computed } from "vue";
import type { ReturnTypeUseMarketplace } from "../../../shared/app/store/useMarketplace";
import { useProductManagement } from "../store/useProductManagement";
import ProductManagementPage from "./ProductManagementPage.vue";
import SectionCard from "../../../shared/components/SectionCard.vue";

const { marketplace } = defineProps<{ marketplace: ReturnTypeUseMarketplace }>();
const pm = useProductManagement(marketplace);
const productError = computed(() => pm.productError.value);
const productPage = computed(() => pm.productPage.value);
const productRouteId = computed(() => pm.productRouteId.value);
const managedProducts = computed(() => pm.managedProducts.value);
const selectedProduct = computed(() => pm.selectedProduct.value);
const categories = computed(() => pm.categories.value);
const weightUnits = computed(() => pm.weightUnits.value);
const pricingMaterialTypes = computed(() => pm.pricingMaterialTypes.value);
const pricingModes = computed(() => pm.pricingModes.value);
const marketPrices = computed(() => pm.marketPrices);
</script>

<template>
  <SectionCard title="Products Management">
    <ProductManagementPage
      :role="marketplace.role.value"
      :product-error="productError"
      :product-page="productPage"
      :product-route-id="productRouteId"
      :managed-products="managedProducts"
      :selected-product="selectedProduct"
      :product-form="pm.productForm"
      :categories="categories"
      :weight-units="weightUnits"
      :pricing-material-types="pricingMaterialTypes"
      :pricing-modes="pricingModes"
      :market-prices="marketPrices"
      :validation-errors="pm.validationErrors"
      @add="pm.openAddProduct"
      @details="pm.openProductDetails"
      @edit="pm.openEditProduct"
      @toggle="pm.toggleProductActive"
      @delete="pm.deleteProductRecord"
      @back="pm.navigate('#/products')"
      @save="pm.saveProduct"
      @save-market-prices="pm.saveMarketPrices"
      @image="pm.onProductImageChange"
    />
  </SectionCard>
</template>
