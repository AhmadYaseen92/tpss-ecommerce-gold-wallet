<script setup lang="ts">
import ProductForm from "../components/ProductForm.vue";
import ProductDetails from "../components/ProductDetails.vue";
import type { ProductManagementDto, EnumItemDto } from "../../../shared/types/apiTypes";
import type { ProductFormPayload } from "../../../shared/services/backendGateway";

defineProps<{
  role: "admin" | "seller";
  productError: string;
  productPage: "list" | "add" | "edit" | "details";
  productRouteId: number | null;
  managedProducts: ProductManagementDto[];
  selectedProduct: ProductManagementDto | null;
  productForm: ProductFormPayload;
  categories: EnumItemDto[];
  weightUnits: EnumItemDto[];
  pricingMaterialTypes: EnumItemDto[];
  pricingModes: EnumItemDto[];
  marketPrices: { gold: number; silver: number; diamond: number };
  validationErrors: Record<string, string>;
}>();

const emit = defineEmits<{
  add: [];
  details: [product: ProductManagementDto];
  edit: [product: ProductManagementDto];
  toggle: [product: ProductManagementDto];
  delete: [id: number];
  back: [];
  save: [];
  saveMarketPrices: [];
  image: [event: Event];
}>();
</script>

<template>
  <section>
    <p v-if="productError" class="error-text">{{ productError }}</p>
    <div class="grid-two form-grid-two">
      <label>Gold Market Price <input v-model.number="marketPrices.gold" type="number" /></label>
      <label>Silver Market Price <input v-model.number="marketPrices.silver" type="number" /></label>
      <label>Diamond Market Price <input v-model.number="marketPrices.diamond" type="number" /></label>
      <button @click="emit('saveMarketPrices')">Save Market Prices</button>
    </div>
    <div class="report-actions" v-if="role === 'seller'"><button @click="emit('add')">Add Product</button></div>

    <div v-if="productPage === 'list'">
      <table>
        <thead><tr><th>ID</th><th>Name</th><th>SKU</th><th>Category</th><th>Material</th><th>Pricing</th><th>Price</th><th>Final</th><th>Stock</th><th>Active</th><th>CreatedAtUtc</th><th>UpdatedAtUtc</th><th>Actions</th></tr></thead>
        <tbody>
          <tr v-for="product in managedProducts" :key="product.id" class="clickable-row" @click="emit('details', product)">
            <td>{{ product.id }}</td><td>{{ product.name }}</td><td>{{ product.sku }}</td><td>{{ product.category }}</td><td>{{ product.pricingMaterialType }}</td><td>{{ product.pricingMode }}</td><td>{{ product.price }}</td><td>{{ product.finalSellPrice }}</td><td>{{ product.availableStock }}</td><td>{{ product.isActive ? 'Yes' : 'No' }}</td><td>{{ product.createdAtUtc }}</td><td>{{ product.updatedAtUtc ?? "-" }}</td>
            <td>
              <button @click.stop="emit('edit', product)">Edit</button>
              <button class="ghost" @click.stop="emit('toggle', product)">{{ product.isActive ? 'Deactivate' : 'Activate' }}</button>
              <button class="danger" @click.stop="emit('delete', product.id)">Delete</button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>

    <div v-else-if="productPage === 'details'" class="product-details">
      <h4>Product Details #{{ selectedProduct?.id ?? productRouteId }}</h4>
      <p v-if="!selectedProduct">Unable to load this product.</p>
      <ProductDetails v-else :product="selectedProduct" />
      <button class="ghost" @click="emit('back')">Back to list</button>
    </div>

    <div v-else class="modal-form product-form vertical-form product-form-contrast">
      <h3>{{ productPage === 'edit' ? 'Edit Product' : 'Add Product' }}</h3>
      <ProductForm :model="productForm" :categories="categories" :units="weightUnits" :pricing-material-types="pricingMaterialTypes" :pricing-modes="pricingModes" :errors="validationErrors" @save="emit('save')" @image="emit('image', $event)" />
      <div class="report-actions"><button class="ghost" @click="emit('back')">Cancel</button></div>
    </div>
  </section>
</template>
