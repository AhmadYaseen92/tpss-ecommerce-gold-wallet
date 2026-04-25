<script setup lang="ts">
import { computed, ref, watch } from "vue";
import ProductForm from "../components/ProductForm.vue";
import ProductDetails from "../components/ProductDetails.vue";

import type {
  ProductManagementDto,
  EnumItemDto,
  MarketPriceConfigDto,
} from "../../../shared/types/apiTypes";
import type { ProductFormPayload } from "../../../shared/services/backendGateway";
import type { Seller } from "../../../shared/types/models";

import Card from "../../../shared/components/ui/Card.vue";
import Button from "../../../shared/components/ui/Button.vue";
import Input from "../../../shared/components/ui/Input.vue";
import Select from "../../../shared/components/ui/Select.vue";
import SearchBar from "../../../shared/components/ui/SearchBar.vue";
import Pagination from "../../../shared/components/ui/Pagination.vue";
import StatusBadge from "../../../shared/components/ui/StatusBadge.vue";
import FormField from "../../../shared/components/ui/FormField.vue";

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
  "update-market-price": [
    field: "goldPerOunce" | "silverPerOunce" | "diamondPerCarat",
    value: number
  ];
  "manage-fees": [];
}>();

const pageNumber = ref(1);
const pageSize = 20;

const isSingleSellerSelected = computed(() => {
  return props.role === "Seller" || props.sellerFilter !== "all";
});

const totalPages = computed(() =>
  Math.max(1, Math.ceil(props.managedProducts.length / pageSize))
);

const pagedProducts = computed(() => {
  const start = (pageNumber.value - 1) * pageSize;
  return props.managedProducts.slice(start, start + pageSize);
});

watch(
  () => [props.searchTerm, props.activeFilter, props.categoryFilter, props.sellerFilter],
  () => {
    pageNumber.value = 1;
  }
);

const updateMarketPrice = (
  field: "goldPerOunce" | "silverPerOunce" | "diamondPerCarat",
  value: string
) => {
  emit("update-market-price", field, Number(value || 0));
};

const formatMoney = (value: number | string | null | undefined) => {
  return Number(value ?? 0).toFixed(2);
};

const getSellPrice = (product: ProductManagementDto) => {
  const row = product as ProductManagementDto & {
    sellPrice?: number;
    SellPrice?: number;
    manualSellPrice?: number;
  };

  return row.sellPrice ?? row.SellPrice ?? product.autoPrice ?? row.fixedPrice ?? 0;
};
</script>

<template>
  <section class="dashboard-screen">
    <p v-if="productError" class="error-text">{{ productError }}</p>

    <template v-if="productPage === 'list'">
      <Card title="Market Prices">
        <div class="ui-filter-bar">
          <FormField v-if="role === 'Admin'" label="Seller">
            <Select
              :model-value="sellerFilter"
              @update:model-value="emit('update:seller-filter', $event)"
            >
              <option value="all">All Sellers</option>
              <option
                v-for="seller in sellers"
                :key="seller.id"
                :value="String(seller.sellerId ?? seller.id)"
              >
                {{ seller.name }} ({{ seller.sellerId ?? seller.id }})
              </option>
            </Select>
          </FormField>

          <FormField label="Gold Price / Ounce">
            <Input
              type="number"
              min="0"
              step="0.01"
              placeholder="Gold / ounce"
              :model-value="marketPrices.goldPerOunce"
              :disabled="role === 'Admin' && !isSingleSellerSelected"
              @update:model-value="updateMarketPrice('goldPerOunce', $event)"
            />
          </FormField>

          <FormField label="Silver Price / Ounce">
            <Input
              type="number"
              min="0"
              step="0.01"
              placeholder="Silver / ounce"
              :model-value="marketPrices.silverPerOunce"
              :disabled="role === 'Admin' && !isSingleSellerSelected"
              @update:model-value="updateMarketPrice('silverPerOunce', $event)"
            />
          </FormField>

          <FormField label="Diamond Price / Carat">
            <Input
              type="number"
              min="0"
              step="0.01"
              placeholder="Diamond / carat"
              :model-value="marketPrices.diamondPerCarat"
              :disabled="role === 'Admin' && !isSingleSellerSelected"
              @update:model-value="updateMarketPrice('diamondPerCarat', $event)"
            />
          </FormField>
        </div>

        <div class="ui-row-actions">
          <p v-if="role === 'Admin' && !isSingleSellerSelected" class="hint-text">
            Select one seller to edit seller-specific market prices. Products for all sellers are still visible.
          </p>

          <Button
            size="sm"
            :disabled="role === 'Admin' && !isSingleSellerSelected"
            @click="emit('save-market-prices')"
          >
            Save Prices
          </Button>
        </div>
      </Card>

      <Card title="Products">
        <div class="ui-filter-bar">
          <SearchBar
            :model-value="searchTerm"
            placeholder="Search by name, SKU, description..."
            @update:model-value="emit('update:search-term', $event)"
          />

          <Select
            :model-value="activeFilter"
            @update:model-value="emit('update:active-filter', $event as 'all' | 'active' | 'inactive')"
          >
            <option value="all">All statuses</option>
            <option value="active">Active</option>
            <option value="inactive">Inactive</option>
          </Select>

          <Select
            :model-value="categoryFilter"
            @update:model-value="emit('update:category-filter', $event)"
          >
            <option value="all">All categories</option>
            <option v-for="category in categories" :key="category.value" :value="category.name">
              {{ category.name }}
            </option>
          </Select>

          <Button v-if="role === 'Seller'" @click="emit('add')">
            Add Product
          </Button>
        </div>

        <div v-if="managedProducts.length === 0" class="ui-state">
          No products found.
        </div>

        <template v-else>
          <div class="ui-table-wrap">
            <table>
              <thead>
                <tr>
                  <th>ID</th>
                  <th v-if="role === 'Admin'">Seller</th>
                  <th>Image</th>
                  <th>Name</th>
                  <th>SKU</th>
                  <th>Category</th>
                  <th>Weight</th>
                  <th>Sell Price</th>
                  <th>Stock</th>
                  <th>Status</th>
                  <th class="text-right">Actions</th>
                </tr>
              </thead>

              <tbody>
                <tr
                  v-for="product in pagedProducts"
                  :key="product.id"
                  class="clickable-row"
                  @click="emit('details', product)"
                >
                  <td>{{ product.id }}</td>

                  <td v-if="role === 'Admin'">
                    <strong>{{ product.sellerName || "-" }}</strong>
                    <div class="hint-text">ID: {{ product.sellerId }}</div>
                  </td>

                  <td>
                    <img
                      v-if="product.imageUrl"
                      :src="product.imageUrl"
                      :alt="product.name"
                      class="product-thumb"
                    />
                    <span v-else class="product-thumb-placeholder">No image</span>
                  </td>

                  <td><strong>{{ product.name }}</strong></td>
                  <td>{{ product.sku }}</td>
                  <td>{{ product.category }}</td>
                  <td>{{ product.weightValue }} g</td>
                  <td>{{ formatMoney(getSellPrice(product)) }}</td>
                  <td>{{ product.availableStock }}</td>
                  <td>
                    <StatusBadge :status="product.isActive ? 'Active' : 'Inactive'" />
                  </td>

                  <td @click.stop>
                    <div class="ui-row-actions">
                      <Button size="sm" @click="emit('edit', product)">Edit</Button>
                      <Button size="sm" variant="ghost" @click="emit('toggle', product)">
                        {{ product.isActive ? "Deactivate" : "Activate" }}
                      </Button>
                      <Button size="sm" variant="danger" @click="emit('delete', product.id)">
                        Delete
                      </Button>
                    </div>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>

          <Pagination
            :page="pageNumber"
            :total-pages="totalPages"
            :total-items="managedProducts.length"
            :page-size="pageSize"
            @prev="pageNumber = Math.max(1, pageNumber - 1)"
            @next="pageNumber = Math.min(totalPages, pageNumber + 1)"
          />
        </template>
      </Card>
    </template>

    <Card v-else-if="productPage === 'details'" title="Product Details">
      <div v-if="!selectedProduct" class="ui-state">
        Unable to load this product.
      </div>

      <template v-else>
        <ProductDetails :product="selectedProduct" />

        <div class="ui-row-actions">
          <Button @click="emit('edit', selectedProduct)">Edit Product</Button>
          <Button variant="ghost" @click="emit('back')">Back to List</Button>
        </div>
      </template>
    </Card>

    <Card v-else :title="productPage === 'edit' ? 'Edit Product' : 'Add Product'">
      <ProductForm
        :model="productForm"
        :categories="categories"
        :units="weightUnits"
        :errors="validationErrors"
        :market-prices="marketPrices"
        @save="emit('save')"
        @image="emit('image', $event)"
      />

      <div class="ui-row-actions">
        <Button variant="ghost" @click="emit('back')">Cancel</Button>
      </div>
    </Card>
  </section>
</template>