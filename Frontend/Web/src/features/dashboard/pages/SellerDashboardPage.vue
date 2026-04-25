<script setup lang="ts">
import { computed, ref } from "vue";
import type { Product, Seller } from "../../../shared/types/models";
import Card from "../../../shared/components/ui/Card.vue";
import Button from "../../../shared/components/ui/Button.vue";
import Input from "../../../shared/components/ui/Input.vue";
import FormField from "../../../shared/components/ui/FormField.vue";
import StatusBadge from "../../../shared/components/ui/StatusBadge.vue";

const props = defineProps<{
  seller: Seller | undefined;
  products: Product[];
}>();

const emit = defineEmits<{
  addProduct: [productName: string];
  deleteProduct: [productId: string];
}>();

const productName = ref("");

const totalStock = computed(() =>
  props.products.reduce((sum, product) => sum + Number(product.stock ?? 0), 0)
);

const formatMoney = (value?: number) => `$${Number(value ?? 0).toFixed(2)}`;

const onAddProduct = () => {
  const name = productName.value.trim();
  if (!name) return;

  emit("addProduct", name);
  productName.value = "";
};
</script>

<template>
  <section class="dashboard-screen">
    <Card v-if="!seller" title="Seller account not configured" padding="lg">
      <div class="ui-state">
        No seller account is linked to this user.
      </div>
    </Card>

    <Card v-else-if="seller.kycStatus !== 'approved'" title="KYC Status" padding="lg">
      <p class="hint-text">
        Your KYC status is <StatusBadge :status="seller.kycStatus" />.
        Product management will be available after admin approval.
      </p>
    </Card>

    <template v-else>
      <div class="metric-grid">
        <article class="metric-card">
          <h3>Total SKU</h3>
          <strong>{{ products.length }}</strong>
          <span>Products in your catalog</span>
        </article>

        <article class="metric-card">
          <h3>Total Stock</h3>
          <strong>{{ totalStock }}</strong>
          <span>Available inventory units</span>
        </article>
      </div>

      <Card title="Product Catalog" subtitle="Manage your listed products and stock.">
        <div class="ui-filter-bar">
          <FormField label="New Product Name">
            <Input v-model="productName" placeholder="Enter product name" />
          </FormField>

          <div class="ui-form-field">
            <span class="ui-form-label">&nbsp;</span>
            <Button variant="primary" :disabled="!productName.trim()" @click="onAddProduct">
              Add Product
            </Button>
          </div>
        </div>

        <div v-if="products.length === 0" class="ui-state">
          No products yet. Add your first product.
        </div>

        <div v-else class="ui-table-wrap">
          <table>
            <thead>
              <tr>
                <th>Name</th>
                <th>Unit Price</th>
                <th>Market Price</th>
                <th>Stock</th>
                <th class="text-right">Action</th>
              </tr>
            </thead>

            <tbody>
              <tr v-for="product in products" :key="product.id">
                <td>
                  <strong>{{ product.name }}</strong>
                </td>
                <td>{{ formatMoney(product.unitPrice) }}</td>
                <td>{{ formatMoney(product.marketPrice) }}</td>
                <td>{{ product.stock }}</td>
                <td>
                  <div class="ui-row-actions">
                    <Button size="sm" variant="danger" @click="emit('deleteProduct', product.id)">
                      Delete
                    </Button>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </Card>

      <Card title="Reports" subtitle="Download daily sales, inventory valuation, and price-gap reports.">
        <div class="ui-state">
          Reports are available from the Reports screen.
        </div>
      </Card>
    </template>
  </section>
</template>