<script setup lang="ts">
import { computed } from "vue";
import type { ReturnTypeUseMarketplace } from "../../../shared/app/store/useMarketplace";
import { useProductManagement } from "../store/useProductManagement";
import ProductManagementPage from "./ProductManagementPage.vue";
import SectionCard from "../../../shared/components/SectionCard.vue";
import CommonModal from "../../../shared/components/CommonModal.vue";

const { marketplace } = defineProps<{ marketplace: ReturnTypeUseMarketplace }>();
const pm = useProductManagement(marketplace);
const productError = computed(() => pm.productError.value);
const productPage = computed(() => pm.productPage.value);
const productRouteId = computed(() => pm.productRouteId.value);
const managedProducts = computed(() => pm.managedProducts.value);
const selectedProduct = computed(() => pm.selectedProduct.value);
const categories = computed(() => pm.categories.value);
const weightUnits = computed(() => pm.weightUnits.value);
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
  <CommonModal
    :open="pm.actionModal.value.open"
    :title="pm.actionModal.value.title"
    :message="pm.actionModal.value.message"
    @close="pm.closeActionModal"
  />
</template>
