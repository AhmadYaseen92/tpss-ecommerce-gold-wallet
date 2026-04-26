<script setup lang="ts">
import type { TransactionRowView } from "../types/transactionTypes";
import { formatCurrency, formatDateTime } from "../../../shared/services/formatters";
import Card from "../../../shared/components/ui/Card.vue";
import StatusBadge from "../../../shared/components/ui/StatusBadge.vue";
import FormField from "../../../shared/components/ui/FormField.vue";

defineProps<{ item: TransactionRowView | null }>();
</script>

<template>
  <section v-if="item" class="dashboard-screen">
    <Card title="Transaction Summary">
      <div class="form-grid-three">
        <FormField label="ID"><div>{{ item.id }}</div></FormField>
        <FormField label="Type"><div>{{ item.transactionType }}</div></FormField>
        <FormField label="Status"><StatusBadge :status="item.status" /></FormField>
        <FormField label="Created At"><div>{{ formatDateTime(item.createdAt) }}</div></FormField>
        <FormField label="Updated At"><div>{{ item.updatedAt ? formatDateTime(item.updatedAt) : '—' }}</div></FormField>
      </div>
    </Card>

    <Card title="Parties & Product">
      <div class="ui-row-inline" style="margin-bottom: 12px;">
        <img v-if="item.productImageUrl" :src="item.productImageUrl" :alt="item.productName" class="product-thumb product-thumb--lg" />
        <span v-else class="product-thumb-placeholder">No image</span>
      </div>
      <div class="form-grid-three">
        <FormField label="Investor"><div>{{ item.investorName }}</div></FormField>
        <FormField label="Investor ID"><div>{{ item.investorId }}</div></FormField>
        <FormField label="Seller"><div>{{ item.sellerName || item.sellerId || '-' }}</div></FormField>
        <FormField label="Transfer From"><div>{{ item.transferFrom || '—' }}</div></FormField>
        <FormField label="Transfer To"><div>{{ item.transferTo || '—' }}</div></FormField>
        <FormField label="Product"><div>{{ item.productName }}</div></FormField>
        <FormField label="Category"><div>{{ item.category }}</div></FormField>
        <FormField label="Quantity"><div>{{ item.quantity.toLocaleString() }}</div></FormField>
        <FormField label="Weight"><div>{{ item.weight.toFixed(3) }} {{ item.unit }}</div></FormField>
      </div>
    </Card>

    <Card title="Amount Breakdown">
      <div class="form-grid-three">
        <FormField label="Unit Price"><div>{{ formatCurrency(item.unitPrice, item.currency) }}</div></FormField>
        <FormField label="Subtotal"><div>{{ formatCurrency(item.subTotalAmount ?? item.finalAmount, item.currency) }}</div></FormField>
        <FormField label="Fees"><div>{{ formatCurrency(item.totalFeesAmount ?? 0, item.currency) }}</div></FormField>
        <FormField label="Discount"><div>{{ formatCurrency(item.discountAmount ?? 0, item.currency) }}</div></FormField>
        <FormField label="Final Amount"><div>{{ formatCurrency(item.finalAmount, item.currency) }}</div></FormField>
      </div>
    </Card>
  </section>

  <section v-else>
    <p class="ui-state">Transaction not found.</p>
  </section>
</template>
