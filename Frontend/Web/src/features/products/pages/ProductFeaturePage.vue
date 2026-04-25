<script setup lang="ts">
import { computed } from "vue";
import type { ReturnTypeUseMarketplace } from "../../../shared/app/store/useMarketplace";
import { useProductManagement } from "../store/useProductManagement";
import ProductManagementPage from "./ProductManagementPage.vue";

const props = defineProps<{
  marketplace: ReturnTypeUseMarketplace;
}>();

const pm = useProductManagement(props.marketplace);

const productError = computed(() => pm.productError.value);
const productPage = computed(() => pm.productPage.value);
const productRouteId = computed(() => pm.productRouteId.value);
const managedProducts = computed(() => pm.filteredManagedProducts.value);
const selectedProduct = computed(() => pm.selectedProduct.value);
const categories = computed(() => pm.categories.value);
const weightUnits = computed(() => pm.weightUnits.value);

const openManageFees = () => {
  window.history.pushState({}, "", "/fees");
  window.dispatchEvent(new PopStateEvent("popstate"));
};
</script>

<template>
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
    :search-term="pm.productSearchTerm.value"
    :active-filter="pm.activeFilter.value"
    :category-filter="pm.categoryFilter.value"
    :seller-filter="pm.sellerFilter.value"
    :sellers="marketplace.state.value.sellers"
    :market-prices="pm.marketPrices"
    @add="pm.openAddProduct"
    @details="pm.openProductDetails"
    @edit="pm.openEditProduct"
    @toggle="pm.toggleProductActive"
    @delete="pm.deleteProductRecord"
    @back="pm.navigate('#/products')"
    @save="pm.saveProduct"
    @save-market-prices="pm.saveMarketPrices"
    @update-market-price="pm.updateMarketPriceField"
    @image="pm.onProductImageChange"
    @update:search-term="pm.productSearchTerm.value = $event"
    @update:active-filter="pm.activeFilter.value = $event"
    @update:category-filter="pm.categoryFilter.value = $event"
    @update:seller-filter="pm.sellerFilter.value = $event"
    @manage-fees="openManageFees"
  />
</template>