<script setup lang="ts">
import { computed, ref } from "vue";
import ProductForm from "../components/ProductForm.vue";
import ProductDetails from "../components/ProductDetails.vue";
import type { ProductManagementDto, EnumItemDto, MarketPriceConfigDto } from "../../../shared/types/apiTypes";
import type { ProductFormPayload } from "../../../shared/services/backendGateway";
import type { Seller } from "../../../shared/types/models";
import FilterBar from "../../../shared/components/ui/FilterBar.vue";
import SearchBar from "../../../shared/components/ui/SearchBar.vue";
import Select from "../../../shared/components/ui/Select.vue";
import Card from "../../../shared/components/ui/Card.vue";
import Button from "../../../shared/components/ui/Button.vue";
import Pagination from "../../../shared/components/ui/Pagination.vue";

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
  "manage-fees": [];
}>();

const pageNumber = ref(1);
const pageSize = 20;
const props = defineProps<{
  role: "Admin" | "Seller";
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
const pagedProducts = computed(() => props.managedProducts.slice((pageNumber.value - 1) * pageSize, (pageNumber.value - 1) * pageSize + pageSize));
</script>

<template>
  <section>
    <p v-if="productError" class="error-text">{{ productError }}</p>
    <div class="report-actions" v-if="role === 'Seller'"><Button @click="emit('add')">Add Product</Button><Button variant="ghost" @click="emit('manage-fees')">Manage Fees</Button></div>

    <div v-if="productPage === 'list'">
      <Card title="Provider Market Prices">
        <FilterBar>
          <input class="ui-input" :value="marketPrices.goldPerOunce" type="number" min="0" step="0.01" placeholder="Gold / oz" @input="emit('update-market-price', 'goldPerOunce', Number(($event.target as HTMLInputElement).value || 0))" />
          <input class="ui-input" :value="marketPrices.silverPerOunce" type="number" min="0" step="0.01" placeholder="Silver / oz" @input="emit('update-market-price', 'silverPerOunce', Number(($event.target as HTMLInputElement).value || 0))" />
          <input class="ui-input" :value="marketPrices.diamondPerCarat" type="number" min="0" step="0.01" placeholder="Diamond / carat" @input="emit('update-market-price', 'diamondPerCarat', Number(($event.target as HTMLInputElement).value || 0))" />
          <Button @click="emit('save-market-prices')">Save Market Prices</Button>
        </FilterBar>
      </Card>
      <FilterBar>
        <SearchBar :model-value="searchTerm" @update:model-value="emit('update:search-term', $event)" placeholder="Search by name, SKU, description..." />
        <Select :model-value="activeFilter" @update:model-value="emit('update:active-filter', $event as 'all' | 'active' | 'inactive')"><option value="all">All statuses</option><option value="active">Active</option><option value="inactive">Inactive</option></Select>
        <Select :model-value="categoryFilter" @update:model-value="emit('update:category-filter', $event)"><option value="all">All categories</option><option v-for="category in categories" :key="category.value" :value="category.name">{{ category.name }}</option></Select>
        <Select v-if="role === 'Admin'" :model-value="sellerFilter" @update:model-value="emit('update:seller-filter', $event)"><option value="all">All Sellers</option><option v-for="seller in sellers" :key="seller.id" :value="String(seller.sellerId)">{{ seller.name }} ({{ seller.sellerId }})</option></Select>
      </FilterBar>

      <table>
        <thead><tr><th>ID</th><th v-if="role === 'Admin'">Seller ID</th><th v-if="role === 'Admin'">Seller Name</th><th>Image</th><th>Name</th><th>SKU</th><th>Description</th><th>Category</th><th>Weight</th><th>Price</th><th>Stock</th><th>Active</th><th>Actions</th></tr></thead>
        <tbody>
          <tr v-for="product in pagedProducts" :key="product.id" class="clickable-row" @click="emit('details', product)">
            <td>{{ product.id }}</td>
            <td v-if="role === 'Admin'">{{ product.sellerId }}</td>
            <td v-if="role === 'Admin'">{{ product.sellerName || '-' }}</td>
            <td><img v-if="product.imageUrl" :src="product.imageUrl" :alt="product.name" class="product-thumb" /><span v-else class="product-thumb-placeholder">No image</span></td>
            <td>{{ product.name }}</td><td>{{ product.sku }}</td><td class="description">{{ product.description }}</td><td>{{ product.category }}</td><td>{{ product.weightValue }} {{ product.weightUnit }}</td><td>{{ product.finalPrice }}</td><td>{{ product.availableStock }}</td><td>{{ product.isActive ? 'Yes' : 'No' }}</td>
            <td><Button @click.stop="emit('edit', product)">Edit</Button><Button variant="ghost" @click.stop="emit('toggle', product)">{{ product.isActive ? 'Deactivate' : 'Activate' }}</Button><Button variant="danger" @click.stop="emit('delete', product.id)">Delete</Button></td>
          </tr>
        </tbody>
      </table>
      <Pagination :page="pageNumber" :total-pages="totalPages" :total-items="managedProducts.length" :page-size="pageSize" @prev="pageNumber--" @next="pageNumber++" />
    </div>

    <div v-else-if="productPage === 'details'" class="product-details">
      <h4>Product Details #{{ selectedProduct?.id ?? productRouteId }}</h4>
      <p v-if="!selectedProduct">Unable to load this product.</p>
      <ProductDetails v-else :product="selectedProduct" />
      <div class="detail-actions"><Button v-if="selectedProduct" @click="emit('edit', selectedProduct)">Edit Product</Button><Button variant="ghost" @click="emit('back')">Back to list</Button></div>
    </div>

    <div v-else class="modal-form product-form vertical-form product-form-contrast">
      <h3>{{ productPage === 'edit' ? 'Edit Product' : 'Add Product' }}</h3>
      <ProductForm :model="productForm" :categories="categories" :units="weightUnits" :errors="validationErrors" :market-prices="marketPrices" @save="emit('save')" @image="emit('image', $event)" />
      <div class="report-actions"><Button variant="ghost" @click="emit('back')">Cancel</Button></div>
    </div>
  </section>
</template>

<style scoped>
.product-thumb { width: 48px; height: 48px; border-radius: 8px; object-fit: cover; border: 1px solid #d9d9d9; }
.product-thumb-placeholder { display: inline-flex; align-items: center; justify-content: center; width: 48px; height: 48px; border-radius: 8px; border: 1px dashed #d9d9d9; color: #7a7a7a; font-size: 11px; }
.description { max-width: 240px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
.detail-actions { display: flex; gap: 8px; margin-top: 12px; }
</style>
