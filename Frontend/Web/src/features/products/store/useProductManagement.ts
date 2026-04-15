import { onMounted, onUnmounted, reactive, ref, watch } from "vue";
import { createManagedProduct, deleteManagedProduct, fetchManagedProducts, fetchProductCategories, fetchWeightUnits, updateManagedProduct, type ProductFormPayload } from "../../../shared/services/backendGateway";
import type { EnumItemDto, ProductManagementDto } from "../../../shared/types/apiTypes";
import { goToProductRoute, syncProductRoute } from "../services/productRoute";
import type { ReturnTypeUseMarketplace } from "../../../shared/app/store/useMarketplace";

export function useProductManagement(marketplace: ReturnTypeUseMarketplace) {
  const managedProducts = ref<ProductManagementDto[]>([]);
  const categories = ref<EnumItemDto[]>([]);
  const weightUnits = ref<EnumItemDto[]>([]);
  const selectedProduct = ref<ProductManagementDto | null>(null);
  const productError = ref("");
  const productPage = ref<"list" | "add" | "edit" | "details">("list");
  const productRouteId = ref<number | null>(null);
  const productForm = reactive<ProductFormPayload>({ name: "", sku: "", description: "", category: 0, weightValue: 0, weightUnit: 0, price: 0, availableStock: 0, isActive: true, imageFile: null, existingImageUrl: "" });
  const validationErrors = reactive<Record<string, string>>({});

  const resetProductForm = () => {
    Object.assign(productForm, { id: undefined, name: "", sku: "", description: "", category: categories.value[0]?.value ?? 0, weightValue: 0, weightUnit: weightUnits.value[0]?.value ?? 0, price: 0, availableStock: 0, isActive: true, imageFile: null, existingImageUrl: "" });
    productError.value = "";
    Object.keys(validationErrors).forEach((k) => delete validationErrors[k]);
  };

  const fillProductForm = (product: ProductManagementDto) => {
    Object.assign(productForm, { id: product.id, name: product.name, sku: product.sku, description: product.description, category: categories.value.find((x) => x.name === product.category)?.value ?? categories.value[0]?.value ?? 0, weightValue: Number(product.weightValue), weightUnit: weightUnits.value.find((x) => x.name === product.weightUnit)?.value ?? weightUnits.value[0]?.value ?? 0, price: Number(product.price), availableStock: product.availableStock, isActive: product.isActive, existingImageUrl: product.imageUrl, imageFile: null });
  };

  const loadProductManagementData = async () => {
    if (!marketplace.session.value?.accessToken) return;
    managedProducts.value = await fetchManagedProducts(marketplace.session.value.accessToken);
    categories.value = await fetchProductCategories(marketplace.session.value.accessToken);
    weightUnits.value = await fetchWeightUnits(marketplace.session.value.accessToken);
  };

  const syncRoute = () => syncProductRoute(managedProducts, productPage, productRouteId, selectedProduct, resetProductForm, fillProductForm);
  const navigate = (path: string) => { goToProductRoute(path); syncRoute(); };

  const openAddProduct = () => { resetProductForm(); navigate("#/products/new"); };
  const openEditProduct = (p: ProductManagementDto) => { fillProductForm(p); navigate(`#/products/${p.id}/edit`); };
  const openProductDetails = (p: ProductManagementDto) => { selectedProduct.value = p; navigate(`#/products/${p.id}`); };
  const onProductImageChange = (event: Event) => { const input = event.target as HTMLInputElement; productForm.imageFile = input.files?.[0] ?? null; };

  
  const validateProductForm = () => {
    Object.keys(validationErrors).forEach((k) => delete validationErrors[k]);
    if (!productForm.name.trim()) validationErrors.name = "Name is required";
    if (!productForm.sku.trim()) validationErrors.sku = "SKU is required";
    if (!productForm.description.trim()) validationErrors.description = "Description is required";
    if (!productForm.category) validationErrors.category = "Category is required";
    if (!productForm.weightValue || productForm.weightValue <= 0) validationErrors.weightValue = "Weight value must be greater than 0";
    if (!productForm.weightUnit) validationErrors.weightUnit = "Weight unit is required";
    if (!productForm.price || productForm.price <= 0) validationErrors.price = "Price must be greater than 0";
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
    try {
      await deleteManagedProduct(marketplace.session.value.accessToken, id);
      await loadProductManagementData();
    } catch (error) {
      productError.value = error instanceof Error ? error.message : "Failed to delete product.";
    }
  };

  const toggleProductActive = async (product: ProductManagementDto) => {
    if (!marketplace.session.value?.accessToken) return;
    try {
      await updateManagedProduct(marketplace.session.value.accessToken, product.id, { ...productForm, id: product.id, name: product.name, sku: product.sku, description: product.description, category: categories.value.find((x) => x.name === product.category)?.value ?? 0, weightValue: Number(product.weightValue), weightUnit: weightUnits.value.find((x) => x.name === product.weightUnit)?.value ?? 0, price: Number(product.price), availableStock: product.availableStock, isActive: !product.isActive, existingImageUrl: product.imageUrl });
      await loadProductManagementData();
    } catch (error) {
      productError.value = error instanceof Error ? error.message : "Failed to update product state.";
    }
  };

  watch(() => marketplace.session.value?.accessToken, () => void loadProductManagementData(), { immediate: true });

  const onRealtimeEvent = (event: Event) => {
    const customEvent = event as CustomEvent<{ entity?: string }>;
    if (customEvent.detail?.entity?.toLowerCase() !== "product") return;
    void loadProductManagementData();
  };

  onMounted(() => {
    syncRoute();
    window.addEventListener("hashchange", syncRoute);
    window.addEventListener("marketplace-realtime-event", onRealtimeEvent);
  });

  onUnmounted(() => {
    window.removeEventListener("hashchange", syncRoute);
    window.removeEventListener("marketplace-realtime-event", onRealtimeEvent);
  });

  watch(managedProducts, () => {
    syncRoute();
  });

  return { managedProducts, categories, weightUnits, selectedProduct, productError, productPage, productRouteId, productForm, validationErrors, resetProductForm, loadProductManagementData, fillProductForm, syncRoute, navigate, openAddProduct, openEditProduct, openProductDetails, onProductImageChange, saveProduct, deleteProductRecord, toggleProductActive };
}
