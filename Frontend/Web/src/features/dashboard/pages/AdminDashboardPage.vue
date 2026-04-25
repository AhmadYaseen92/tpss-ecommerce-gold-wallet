<script setup lang="ts">
import { computed } from "vue";
import type { Product, ReportMetric, Seller } from "../../../shared/types/models";
import MetricGrid from "../../../shared/components/MetricGrid.vue";
import Card from "../../../shared/components/ui/Card.vue";
import PageHeader from "../../../shared/components/ui/PageHeader.vue";
import StatusBadge from "../../../shared/components/ui/StatusBadge.vue";
import Button from "../../../shared/components/ui/Button.vue";

const props = defineProps<{
  sellers: Seller[];
  products: Product[];
  metrics: ReportMetric[];
}>();

const emit = defineEmits<{
  approve: [sellerId: string];
  reject: [sellerId: string];
  updatePrice: [payload: { productId: string; marketPrice: number }];
}>();

const pendingSellers = computed(() =>
  props.sellers.filter((seller) => {
    const status = String(seller.kycStatus ?? "").toLowerCase();
    return status.includes("pending") || status.includes("review");
  })
);

const activeProducts = computed(() => props.products.slice(0, 8));

const formatMoney = (value?: number) => {
  return `$${Number(value ?? 0).toFixed(2)}`;
};
</script>

<template>
  <section class="dashboard-screen">
    <PageHeader
      title="Admin Dashboard"
      subtitle="Monitor sellers, KYC approvals, products, and market prices."
    />

    <MetricGrid :metrics="metrics" />

    <div class="dashboard-bottom-grid">
      <Card
        title="Seller KYC Approval Queue"
        subtitle="Review pending seller registrations and approve or reject access."
      >
        <div v-if="pendingSellers.length === 0" class="ui-state">
          No pending seller approvals.
        </div>

        <div v-else class="ui-table-wrap">
          <table>
            <thead>
              <tr>
                <th>Seller</th>
                <th>Business</th>
                <th>Status</th>
                <th class="text-right">Actions</th>
              </tr>
            </thead>

            <tbody>
              <tr v-for="seller in pendingSellers" :key="seller.id">
                <td>
                  <strong>{{ seller.name }}</strong>
                </td>
                <td>{{ seller.businessName || "—" }}</td>
                <td>
                  <StatusBadge :status="seller.kycStatus" />
                </td>
                <td>
                  <div class="ui-row-actions">
                    <Button size="sm" variant="success" @click="emit('approve', seller.id)">
                      Approve
                    </Button>

                    <Button size="sm" variant="danger" @click="emit('reject', seller.id)">
                      Reject
                    </Button>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </Card>

      <Card
        title="Market Price Management"
        subtitle="Quickly review products and adjust market prices."
      >
        <div v-if="activeProducts.length === 0" class="ui-state">
          No products available.
        </div>

        <div v-else class="ui-table-wrap">
          <table>
            <thead>
              <tr>
                <th>Product</th>
                <th>Seller</th>
                <th>Market Price</th>
                <th class="text-right">Update</th>
              </tr>
            </thead>

            <tbody>
              <tr v-for="product in activeProducts" :key="product.id">
                <td>
                  <strong>{{ product.name }}</strong>
                </td>
                <td>{{ product.sellerId }}</td>
                <td>
                  <strong>{{ formatMoney(product.marketPrice) }}</strong>
                </td>
                <td>
                  <div class="ui-row-actions">
                    <Button
                      size="sm"
                      variant="secondary"
                      @click="emit('updatePrice', { productId: product.id, marketPrice: product.marketPrice + 5 })"
                    >
                      + $5
                    </Button>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </Card>
    </div>
  </section>
</template>