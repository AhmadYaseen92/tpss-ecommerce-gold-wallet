<script setup lang="ts">
import { computed, ref } from "vue";
import type { Product, Seller } from "../../../shared/types/models";
import SectionCard from "../../../shared/components/SectionCard.vue";

const props = defineProps<{
  seller: Seller | undefined;
  products: Product[];
}>();

const emit = defineEmits<{
  addProduct: [productName: string];
  deleteProduct: [productId: string];
}>();

const productName = ref("");
const totalStock = computed(() => props.products.reduce((sum, product) => sum + product.stock, 0));

const onAddProduct = () => {
  if (!productName.value.trim()) return;
  emit("addProduct", productName.value.trim());
  productName.value = "";
};
</script>

<template>
  <p v-if="!seller">No seller account configured.</p>

  <template v-else-if="seller.kycStatus !== 'approved'">
    <SectionCard title="KYC Status">
      <p>
        Your KYC is <strong>{{ seller.kycStatus }}</strong
        >. Seller login to manage products is enabled only after admin approval.
      </p>
    </SectionCard>
  </template>

  <template v-else>
    <SectionCard title="Product Catalog">
      <template #actions>
        <button @click="onAddProduct">Add Product</button>
      </template>

      <div class="inline-form">
        <input v-model="productName" placeholder="New product name" />
      </div>

      <table>
        <thead>
          <tr>
            <th>Name</th>
            <th>Price</th>
            <th>Market</th>
            <th>Stock</th>
            <th>Action</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="product in products" :key="product.id">
            <td>{{ product.name }}</td>
            <td>${{ product.unitPrice.toFixed(2) }}</td>
            <td>${{ product.marketPrice.toFixed(2) }}</td>
            <td>{{ product.stock }}</td>
            <td>
              <button class="danger" @click="emit('deleteProduct', product.id)">Delete</button>
            </td>
          </tr>
        </tbody>
      </table>
    </SectionCard>

    <SectionCard title="Inventory Monitoring">
      <p>Total SKU: {{ products.length }}</p>
      <p>Total Stock: {{ totalStock }}</p>
    </SectionCard>

    <SectionCard title="Reports">
      <p>Download daily sales, inventory valuation, and price-gap reports.</p>
    </SectionCard>
  </template>
</template>
