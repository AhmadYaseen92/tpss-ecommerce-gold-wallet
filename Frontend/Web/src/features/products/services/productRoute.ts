import type { Ref } from "vue";
import type { ProductManagementDto } from "../../../shared/types/apiTypes";

export function syncProductRoute(
  managedProducts: Ref<ProductManagementDto[]>,
  productPage: Ref<"list" | "add" | "edit" | "details">,
  productRouteId: Ref<number | null>,
  selectedProduct: Ref<ProductManagementDto | null>,
  reset: () => void,
  fill: (product: ProductManagementDto) => void
) {
  const hash = window.location.hash || "#/products";
  const addMatch = hash.match(/^#\/products\/new$/);
  const editMatch = hash.match(/^#\/products\/(\d+)\/edit$/);
  const detailsMatch = hash.match(/^#\/products\/(\d+)$/);

  if (addMatch) {
    productPage.value = "add";
    productRouteId.value = null;
    selectedProduct.value = null;
    reset();
    return;
  }

  if (editMatch) {
    const id = Number(editMatch[1]);
    const product = managedProducts.value.find((item) => item.id === id) ?? null;
    productPage.value = "edit";
    productRouteId.value = id;
    selectedProduct.value = product;
    if (product) fill(product);
    return;
  }

  if (detailsMatch) {
    const id = Number(detailsMatch[1]);
    productPage.value = "details";
    productRouteId.value = id;
    selectedProduct.value = managedProducts.value.find((item) => item.id === id) ?? null;
    return;
  }

  productPage.value = "list";
  productRouteId.value = null;
  selectedProduct.value = null;
}

export function goToProductRoute(path: string) {
  window.location.hash = path;
}
