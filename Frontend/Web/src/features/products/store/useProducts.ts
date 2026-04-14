import { ref } from "vue";
import { productService } from "../services/productService";
import type { ProductListItem } from "../types/productTypes";

export function useProducts() {
  const items = ref<ProductListItem[]>([]);

  const load = async (token: string) => {
    items.value = await productService.list(token);
  };

  return { items, load };
}
