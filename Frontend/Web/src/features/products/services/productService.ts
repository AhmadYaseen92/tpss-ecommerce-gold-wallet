import {
  createManagedProduct,
  deleteManagedProduct,
  fetchManagedProducts,
  fetchProductCategories,
  fetchWeightUnits,
  updateManagedProduct,
  type ProductFormPayload
} from "../../../shared/services/backendGateway";

export const productService = {
  list: fetchManagedProducts,
  categories: fetchProductCategories,
  weightUnits: fetchWeightUnits,
  create: createManagedProduct,
  update: updateManagedProduct,
  remove: deleteManagedProduct,
  toPayload(input: ProductFormPayload): ProductFormPayload {
    return input;
  }
};
