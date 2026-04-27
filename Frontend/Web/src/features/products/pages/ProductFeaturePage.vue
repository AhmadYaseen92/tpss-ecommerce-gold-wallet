<script setup lang="ts">
import type { ReturnTypeUseMarketplace } from "../../../shared/app/store/useMarketplace";
import { useProductManagement } from "../store/useProductManagement";
import ProductManagementPage from "./ProductManagementPage.vue";

const props = defineProps<{
  marketplace: ReturnTypeUseMarketplace;
}>();

const pm = useProductManagement(props.marketplace);

const openManageFees = () => {
  window.history.pushState({}, "", "/fees");
  window.dispatchEvent(new PopStateEvent("popstate"));
};
</script>

<template>
  <ProductManagementPage
    :role="marketplace.role.value"
    :access-token="marketplace.session.value?.accessToken ?? ''"
    :product-error="pm.productError.value"
    :product-page="pm.productPage.value"
    :product-route-id="pm.productRouteId.value"
    :managed-products="pm.filteredManagedProducts.value"
    :selected-product="pm.selectedProduct.value"
    :product-form="pm.productForm"
    :categories="pm.categories.value"
    :weight-units="pm.weightUnits.value"
    :validation-errors="pm.validationErrors"
    :search-term="pm.productSearchTerm.value"
    :active-filter="pm.activeFilter.value"
    :material-type-filter="pm.materialTypeFilter.value"
    :form-type-filter="pm.formTypeFilter.value"
    :seller-filter="pm.sellerFilter.value"
    :sellers="marketplace.state.value.sellers"
    :market-prices="pm.marketPrices"
    :product-fee-draft="pm.productFeeDraft.value"
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
    @video="pm.onProductVideoChange"
    @update:search-term="pm.productSearchTerm.value = $event"
    @update:active-filter="pm.activeFilter.value = $event"
    @update:material-type-filter="pm.materialTypeFilter.value = $event"
    @update:form-type-filter="pm.formTypeFilter.value = $event"
    @update:seller-filter="pm.sellerFilter.value = $event"
    @manage-fees="openManageFees"
    @clear-error="pm.productError.value = ''"
    @update:product-fee-draft="pm.productFeeDraft.value = $event"
  />
</template>
