import { computed, onMounted, onUnmounted, reactive, ref, watch } from "vue";
import { createManagedProduct, deleteManagedProduct, fetchManagedProducts, fetchProductCategories, fetchWeightUnits, fetchGlobalMarketPrices, updateGlobalMarketPrices, updateManagedProduct, type ProductFormPayload } from "../../../shared/services/backendGateway";
import type { EnumItemDto, ProductManagementDto, MarketPriceConfigDto } from "../../../shared/types/apiTypes";
import { goToProductRoute, syncProductRoute } from "../services/productRoute";
import type { ReturnTypeUseMarketplace } from "../../../shared/app/store/useMarketplace";

export function useProductManagement(marketplace: ReturnTypeUseMarketplace) {

const toMaterialTypeValue = (name: string) => {
  const key = name.toLowerCase();
  if (key.includes('silver')) return 2;
  if (key.includes('diamond')) return 3;
  return 1;
};
const toFormTypeValue = (name: string) => {
  const key = name.toLowerCase();
  if (key.includes('coin')) return 2;
  if (key.includes('bar')) return 3;
  if (key.includes('other')) return 4;
  return 1;
};
const toPricingModeValue = (name: string) => name.toLowerCase().includes('manual') ? 2 : 1;
const toOfferTypeValue = (name: string) => name.toLowerCase().includes('fixed') ? 2 : (name.toLowerCase().includes('percent') ? 1 : 0);
const toPurityKaratValue = (name: string) => {
  const key = name.toLowerCase().replace(' ', '');
  if (key.includes('24')) return 1;
  if (key.includes('22')) return 2;
  if (key.includes('21')) return 3;
  if (key.includes('18')) return 4;
  if (key.includes('14')) return 5;
  return 0;
};

  const managedProducts = ref<ProductManagementDto[]>([]);
  const categories = ref<EnumItemDto[]>([]);
  const weightUnits = ref<EnumItemDto[]>([]);
  const selectedProduct = ref<ProductManagementDto | null>(null);
  const productError = ref("");
  const productPage = ref<"list" | "add" | "edit" | "details">("list");
  const productRouteId = ref<number | null>(null);
  const productForm = reactive<ProductFormPayload>({ name: "", sku: "", description: "", materialType: 1, formType: 1, pricingMode: 1, purityKarat: 0, purityFactor: 1, weightValue: 0, baseMarketPrice: 0, manualSellPrice: 0, deliveryFee: 0, storageFee: 0, serviceCharge: 0, offerType: 0, offerPercent: 0, offerNewPrice: 0, price: 0, availableStock: 0, isActive: true, imageFile: null, existingImageUrl: "" });
  const validationErrors = reactive<Record<string, string>>({});
  const productSearchTerm = ref("");
  const activeFilter = ref<"all" | "active" | "inactive">("all");
  const categoryFilter = ref("all");
  const marketPrices = reactive<MarketPriceConfigDto>({ goldPerOunce: 0, silverPerOunce: 0, diamondPerCarat: 0 });
  const marketPricesDirty = ref(false);

  const resetProductForm = () => {
    Object.assign(productForm, { id: undefined, name: "", sku: "", description: "", materialType: 1, formType: 1, pricingMode: 1, purityKarat: 0, purityFactor: 1, weightValue: 0, baseMarketPrice: 0, manualSellPrice: 0, deliveryFee: 0, storageFee: 0, serviceCharge: 0, offerType: 0, offerPercent: 0, offerNewPrice: 0, price: 0, availableStock: 0, isActive: true, imageFile: null, existingImageUrl: "" });
    productError.value = "";
    Object.keys(validationErrors).forEach((k) => delete validationErrors[k]);
  };

  const fillProductForm = (product: ProductManagementDto) => {
    Object.assign(productForm, { id: product.id, name: product.name, sku: product.sku, description: product.description, materialType: toMaterialTypeValue(product.materialType), formType: toFormTypeValue(product.formType), pricingMode: toPricingModeValue(product.pricingMode), purityKarat: toPurityKaratValue(product.purityKarat), purityFactor: Number(product.purityFactor), weightValue: Number(product.weightValue), baseMarketPrice: Number(product.baseMarketPrice), manualSellPrice: Number(product.manualSellPrice), deliveryFee: Number(product.deliveryFee), storageFee: Number(product.storageFee), serviceCharge: Number(product.serviceCharge), offerType: toOfferTypeValue(product.offerType), offerPercent: Number(product.offerPercent), offerNewPrice: Number(product.offerNewPrice), price: Number(product.price), availableStock: product.availableStock, isActive: product.isActive, existingImageUrl: product.imageUrl, imageFile: null });
  };

  const loadProductManagementData = async () => {
    if (!marketplace.session.value?.accessToken) return;
    managedProducts.value = await fetchManagedProducts(marketplace.session.value.accessToken);
    categories.value = await fetchProductCategories(marketplace.session.value.accessToken);
    weightUnits.value = await fetchWeightUnits(marketplace.session.value.accessToken);
    if (!marketPricesDirty.value) {
      Object.assign(marketPrices, await fetchGlobalMarketPrices(marketplace.session.value.accessToken));
    }
  };

  const syncRoute = () => syncProductRoute(managedProducts, productPage, productRouteId, selectedProduct, resetProductForm, fillProductForm);
  const navigate = (path: string) => { goToProductRoute(path); syncRoute(); };

  const openAddProduct = () => { resetProductForm(); navigate("#/products/new"); };
  const openEditProduct = (p: ProductManagementDto) => { fillProductForm(p); navigate(`#/products/${p.id}/edit`); };
  const openProductDetails = (p: ProductManagementDto) => { selectedProduct.value = p; navigate(`#/products/${p.id}`); };
  const onProductImageChange = (event: Event) => { const input = event.target as HTMLInputElement; productForm.imageFile = input.files?.[0] ?? null; };

  

  const filteredManagedProducts = computed(() =>
    managedProducts.value.filter((product) => {
      if (activeFilter.value === "active" && !product.isActive) return false;
      if (activeFilter.value === "inactive" && product.isActive) return false;
      if (categoryFilter.value !== "all" && product.category !== categoryFilter.value) return false;
      if (!productSearchTerm.value.trim()) return true;

      const term = productSearchTerm.value.trim().toLowerCase();
      return [product.name, product.sku, product.description, product.category]
        .join(" ")
        .toLowerCase()
        .includes(term);
    })
  );

  const validateProductForm = () => {
    Object.keys(validationErrors).forEach((k) => delete validationErrors[k]);
    if (!productForm.name.trim()) validationErrors.name = "Name is required";
    if (!productForm.sku.trim()) validationErrors.sku = "SKU is required";
    if (!productForm.description.trim()) validationErrors.description = "Description is required";
    if (!productForm.materialType) validationErrors.materialType = "Material type is required";
    if (!productForm.formType) validationErrors.formType = "Product form is required";
    if (!productForm.weightValue || productForm.weightValue <= 0) validationErrors.weightValue = "Weight (grams) must be greater than 0";
    if (productForm.pricingMode === 2 && (!productForm.manualSellPrice || productForm.manualSellPrice <= 0)) validationErrors.manualSellPrice = "Manual price must be greater than 0";
    if (productForm.availableStock == null || productForm.availableStock < 0) validationErrors.availableStock = "Stock cannot be negative";
    return Object.keys(validationErrors).length === 0;
  };

  const saveProduct = async () => {
    if (!marketplace.session.value?.accessToken) return;
    if (!validateProductForm()) return;
    try {
      if (productPage.value === "edit" && productForm.id) await updateManagedProduct(marketplace.session.value.accessToken, productForm.id, productForm);
      else await createManagedProduct(marketplace.session.value.accessToken, productForm);
      await loadProductManagementData();
      navigate("#/products");
    } catch (error) {
      productError.value = error instanceof Error ? error.message : "Failed to save product.";
    }
  };

  const deleteProductRecord = async (id: number) => {
    if (!marketplace.session.value?.accessToken) return;
    const confirmed = window.confirm(`Delete product #${id}? This action cannot be undone.`);
    if (!confirmed) return;
    try {
      await deleteManagedProduct(marketplace.session.value.accessToken, id);
      await loadProductManagementData();
    } catch (error) {
      productError.value = error instanceof Error ? error.message : "Failed to delete product.";
    }
  };

  const updateMarketPriceField = (field: "goldPerOunce" | "silverPerOunce" | "diamondPerCarat", value: number) => {
    marketPricesDirty.value = true;
    marketPrices[field] = Number.isFinite(value) ? value : 0;
  };

  const saveMarketPrices = async () => {
    if (!marketplace.session.value?.accessToken) return;
    try {
      await updateGlobalMarketPrices(marketplace.session.value.accessToken, marketPrices);
      marketPricesDirty.value = false;
      Object.assign(marketPrices, await fetchGlobalMarketPrices(marketplace.session.value.accessToken));
      productError.value = "";
    } catch (error) {
      productError.value = error instanceof Error ? error.message : "Failed to update global market prices.";
    }
  };

  const toggleProductActive = async (product: ProductManagementDto) => {
    if (!marketplace.session.value?.accessToken) return;
    const nextState = product.isActive ? "deactivate" : "activate";
    const confirmed = window.confirm(`Are you sure you want to ${nextState} product ${product.name}?`);
    if (!confirmed) return;
    try {
      await updateManagedProduct(marketplace.session.value.accessToken, product.id, {
        id: product.id,
        name: product.name,
        sku: product.sku,
        description: product.description,
        materialType: toMaterialTypeValue(product.materialType),
        formType: toFormTypeValue(product.formType),
        pricingMode: toPricingModeValue(product.pricingMode),
        purityKarat: toPurityKaratValue(product.purityKarat),
        purityFactor: Number(product.purityFactor),
        weightValue: Number(product.weightValue),
        baseMarketPrice: Number(product.baseMarketPrice),
        manualSellPrice: Number(product.manualSellPrice),
        deliveryFee: Number(product.deliveryFee),
        storageFee: Number(product.storageFee),
        serviceCharge: Number(product.serviceCharge),
        offerType: toOfferTypeValue(product.offerType),
        offerPercent: Number(product.offerPercent),
        offerNewPrice: Number(product.offerNewPrice),
        price: Number(product.price),
        availableStock: product.availableStock,
        isActive: !product.isActive,
        existingImageUrl: product.imageUrl
      });
      await loadProductManagementData();
    } catch (error) {
      productError.value = error instanceof Error ? error.message : "Failed to update product state.";
    }
  };

  watch(() => marketplace.session.value?.accessToken, () => void loadProductManagementData(), { immediate: true });

  watch(() => marketplace.realtimeRefreshTick.value, () => {
    if (productPage.value === "list") {
      void loadProductManagementData();
    }
  });

  onMounted(() => {
    syncRoute();
    window.addEventListener("hashchange", syncRoute);
  });

  onUnmounted(() => {
    window.removeEventListener("hashchange", syncRoute);
  });

  watch(managedProducts, () => {
    if (productPage.value === "list" || productPage.value === "details") {
      syncRoute();
    }
  });

  return { managedProducts, filteredManagedProducts, categories, weightUnits, selectedProduct, productError, productPage, productRouteId, productForm, validationErrors, productSearchTerm, activeFilter, categoryFilter, marketPrices, resetProductForm, loadProductManagementData, fillProductForm, syncRoute, navigate, openAddProduct, openEditProduct, openProductDetails, onProductImageChange, saveProduct, saveMarketPrices, updateMarketPriceField, deleteProductRecord, toggleProductActive };
}
