<script setup lang="ts">
import type { Product, ReportMetric, Seller } from "../../domain/models";
import MetricGrid from "../components/MetricGrid.vue";
import SectionCard from "../components/SectionCard.vue";

defineProps<{
  sellers: Seller[];
  products: Product[];
  metrics: ReportMetric[];
}>();

const emit = defineEmits<{
  approve: [sellerId: string];
  reject: [sellerId: string];
  updatePrice: [payload: { productId: string; marketPrice: number }];
}>();
</script>

<template>
  <MetricGrid :metrics="metrics" />

  <SectionCard title="Seller KYC Approval Queue">
    <table>
      <thead>
        <tr>
          <th>Seller</th>
          <th>Business</th>
          <th>Status</th>
          <th>Action</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="seller in sellers" :key="seller.id">
          <td>{{ seller.name }}</td>
          <td>{{ seller.businessName }}</td>
          <td>{{ seller.kycStatus }}</td>
          <td>
            <button @click="emit('approve', seller.id)">Approve</button>
            <button class="danger" @click="emit('reject', seller.id)">Reject</button>
          </td>
        </tr>
      </tbody>
    </table>
  </SectionCard>

  <SectionCard title="Market Price Management">
    <table>
      <thead>
        <tr>
          <th>Product</th>
          <th>Seller</th>
          <th>Market Price</th>
          <th>Update</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="product in products" :key="product.id">
          <td>{{ product.name }}</td>
          <td>{{ product.sellerId }}</td>
          <td>${{ product.marketPrice.toFixed(2) }}</td>
          <td>
            <button @click="emit('updatePrice', { productId: product.id, marketPrice: product.marketPrice + 5 })">
              + $5
            </button>
          </td>
        </tr>
      </tbody>
    </table>
  </SectionCard>
</template>
