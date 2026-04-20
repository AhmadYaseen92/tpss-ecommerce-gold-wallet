<script setup lang="ts">
import { computed, ref } from "vue";
import ProductForm from "../components/ProductForm.vue";
import ProductDetails from "../components/ProductDetails.vue";
import type { ProductManagementDto, EnumItemDto, MarketPriceConfigDto } from "../../../shared/types/apiTypes";
import type { ProductFormPayload } from "../../../shared/services/backendGateway";
import type { Seller } from "../../../shared/types/models";

const emit = defineEmits<{
  add: [];
  details: [product: ProductManagementDto];
  edit: [product: ProductManagementDto];
  toggle: [product: ProductManagementDto];
  delete: [id: number];
  back: [];
  save: [];
  image: [event: Event];
  "update:search-term": [value: string];
  "update:active-filter": [value: "all" | "active" | "inactive"];
  "update:category-filter": [value: string];
  "update:seller-filter": [value: string];
  "save-market-prices": [];
  "update-market-price": [field: "goldPerOunce" | "silverPerOunce" | "diamondPerCarat", value: number];
}>();

const pageNumber = ref(1);
const pageSize = 20;
const props = defineProps<{
  role: "admin" | "seller";
  productError: string;
  productPage: "list" | "add" | "edit" | "details";
  productRouteId: number | null;
  managedProducts: ProductManagementDto[];
  selectedProduct: ProductManagementDto | null;
  productForm: ProductFormPayload;
  categories: EnumItemDto[];
  weightUnits: EnumItemDto[];
  validationErrors: Record<string, string>;
  searchTerm: string;
  activeFilter: "all" | "active" | "inactive";
  categoryFilter: string;
  sellerFilter: string;
  sellers: Seller[];
  marketPrices: MarketPriceConfigDto;
}>();
const totalPages = computed(() => Math.max(1, Math.ceil(props.managedProducts.length / pageSize)));
const pagedProducts = computed(() => {
  const start = (pageNumber.value - 1) * pageSize;
  return props.managedProducts.slice(start, start + pageSize);
});
</script>

<template>
  <section>
    <p v-if="productError" class="error-text">{{ productError }}</p>
    <div class="report-actions" v-if="role === 'seller'"><button @click="emit('add')">Add Product</button></div>

    <div v-if="productPage === 'list'">
      <div class="filters" style="grid-template-columns: repeat(4, minmax(140px, 1fr)); margin-bottom: 16px; align-items:end;">
        <label>
          Gold Price (per ounce)
          <input :value="marketPrices.goldPerOunce" type="number" min="0" step="0.01" @input="emit('update-market-price', 'goldPerOunce', Number(($event.target as HTMLInputElement).value || 0))" />
        </label>
        <label>
          Silver Price (per ounce)
          <input :value="marketPrices.silverPerOunce" type="number" min="0" step="0.01" @input="emit('update-market-price', 'silverPerOunce', Number(($event.target as HTMLInputElement).value || 0))" />
        </label>
        <label>
          Diamond Base (per carat)
          <input :value="marketPrices.diamondPerCarat" type="number" min="0" step="0.01" @input="emit('update-market-price', 'diamondPerCarat', Number(($event.target as HTMLInputElement).value || 0))" />
        </label>
        <button @click="emit('save-market-prices')">Save Provider Market Prices</button>
      </div>
      <div class="filters">
        <input :value="searchTerm" @input="emit('update:search-term', ($event.target as HTMLInputElement).value)" placeholder="Search by name, SKU, description..." />
        <select :value="activeFilter" @change="emit('update:active-filter', ($event.target as HTMLSelectElement).value as 'all' | 'active' | 'inactive')">
          <option value="all">All statuses</option>
          <option value="active">Active</option>
          <option value="inactive">Inactive</option>
        </select>
        <select :value="categoryFilter" @change="emit('update:category-filter', ($event.target as HTMLSelectElement).value)">
          <option value="all">All categories</option>
          <option v-for="category in categories" :key="category.value" :value="category.name">{{ category.name }}</option>
        </select>
        <select v-if="role === 'admin'" :value="sellerFilter" @change="emit('update:seller-filter', ($event.target as HTMLSelectElement).value)">
          <option value="all">All Sellers</option>
          <option v-for="seller in sellers" :key="seller.id" :value="String(seller.sellerId)">{{ seller.name }} ({{ seller.sellerId }})</option>
        </select>
      </div>

      <table>
        <thead><tr><th>ID</th><th v-if="role === 'admin'">Seller ID</th><th v-if="role === 'admin'">Seller Name</th><th>Image</th><th>Name</th><th>SKU</th><th>Description</th><th>Category</th><th>Weight</th><th>Price</th><th>Stock</th><th>Active</th><th>Actions</th></tr></thead>
        <tbody>
          <tr v-for="product in pagedProducts" :key="product.id" class="clickable-row" @click="emit('details', product)">
            <td>{{ product.id }}</td>
            <td v-if="role === 'admin'">{{ product.sellerId }}</td>
            <td v-if="role === 'admin'">{{ product.sellerName || '-' }}</td>
            <td><img v-if="product.imageUrl" :src="product.imageUrl" :alt="product.name" class="product-thumb" /><span v-else class="product-thumb-placeholder">No image</span></td>
            <td>{{ product.name }}</td>
            <td>{{ product.sku }}</td>
            <td class="description">{{ product.description }}</td>
            <td>{{ product.category }}</td>
            <td>{{ product.weightValue }} {{ product.weightUnit }}</td>
            <td>{{ product.price }}</td>
            <td>{{ product.availableStock }}</td>
            <td>{{ product.isActive ? 'Yes' : 'No' }}</td>
            <td>
              <button @click.stop="emit('edit', product)">Edit</button>
              <button class="ghost" @click.stop="emit('toggle', product)">{{ product.isActive ? 'Deactivate' : 'Activate' }}</button>
              <button class="danger" @click.stop="emit('delete', product.id)">Delete</button>
            </td>
          </tr>
        </tbody>
      </table>
      <div class="pager">
        Results: {{ (pageNumber - 1) * pageSize + 1 }} - {{ Math.min(pageNumber * pageSize, managedProducts.length) }} of {{ managedProducts.length }}
        <button :disabled="pageNumber <= 1" @click="pageNumber--">&lt;</button>
        <span>{{ pageNumber }} / {{ totalPages }}</span>
        <button :disabled="pageNumber >= totalPages" @click="pageNumber++">&gt;</button>
      </div>
    </div>

    <div v-else-if="productPage === 'details'" class="product-details">
      <h4>Product Details #{{ selectedProduct?.id ?? productRouteId }}</h4>
      <p v-if="!selectedProduct">Unable to load this product.</p>
      <ProductDetails v-else :product="selectedProduct" />
      <div class="detail-actions">
        <button v-if="selectedProduct" @click="emit('edit', selectedProduct)">Edit Product</button>
        <button class="ghost" @click="emit('back')">Back to list</button>
      </div>
    </div>

    <div v-else class="modal-form product-form vertical-form product-form-contrast">
      <h3>{{ productPage === 'edit' ? 'Edit Product' : 'Add Product' }}</h3>
      <ProductForm :model="productForm" :categories="categories" :units="weightUnits" :errors="validationErrors" :market-prices="marketPrices" @save="emit('save')" @image="emit('image', $event)" />
      <div class="report-actions"><button class="ghost" @click="emit('back')">Cancel</button></div>
    </div>
  </section>
</template>


<style scoped>
.filters {
  display: grid;
  grid-template-columns: 1fr 180px 180px;
  gap: 10px;
  margin-bottom: 12px;
}

.filters input,
.filters select {
  border: 1px solid #d4d4d8;
  border-radius: 8px;
  padding: 8px 10px;
}

.product-thumb {
  width: 48px;
  height: 48px;
  border-radius: 8px;
  object-fit: cover;
  border: 1px solid #d9d9d9;
}

.product-thumb-placeholder {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 48px;
  height: 48px;
  border-radius: 8px;
  border: 1px dashed #d9d9d9;
  color: #7a7a7a;
  font-size: 11px;
}

.description {
  max-width: 240px;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.detail-actions {
  display: flex;
  gap: 8px;
  margin-top: 12px;
}
.pager { margin-top: 10px; display:flex; gap:8px; justify-content:flex-end; align-items:center; }
</style>
