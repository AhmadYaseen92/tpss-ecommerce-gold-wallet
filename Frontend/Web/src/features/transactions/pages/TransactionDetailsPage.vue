<script setup lang="ts">
import type { TransactionRowView } from "../types/transactionTypes";
import { formatCurrency, formatDateTime } from "../../../shared/services/formatters";
import Card from "../../../shared/components/ui/Card.vue";
import StatusBadge from "../../../shared/components/ui/StatusBadge.vue";

defineProps<{ item: TransactionRowView | null }>();
</script>

<template>
  <section v-if="item" class="tx-sections">
    <Card title="Transaction Summary">
      <div class="detail-grid">
        <p><strong>ID:</strong> {{ item.id }}</p>
        <p><strong>Type:</strong> {{ item.transactionType }}</p>
        <p><strong>Status:</strong> <StatusBadge :status="item.status" /></p>
        <p><strong>Created At:</strong> {{ formatDateTime(item.createdAt) }}</p>
        <p><strong>Updated At:</strong> {{ item.updatedAt ? formatDateTime(item.updatedAt) : '—' }}</p>
      </div>
    </Card>
    <Card title="Parties & Product">
      <div class="detail-grid">
        <p><strong>Investor:</strong> {{ item.investorName }}</p>
        <p><strong>Investor ID:</strong> {{ item.investorId }}</p>
        <p><strong>Transfer From:</strong> {{ item.transferFrom || '—' }}</p>
        <p><strong>Transfer To:</strong> {{ item.transferTo || '—' }}</p>
        <p><strong>Product:</strong> {{ item.productName }}</p>
        <p><strong>Category:</strong> {{ item.category }}</p>
        <p><strong>Quantity:</strong> {{ item.quantity.toLocaleString() }}</p>
        <p><strong>Weight:</strong> {{ item.weight.toFixed(3) }} {{ item.unit }}</p>
      </div>
    </Card>
    <Card title="Amount Breakdown">
      <div class="detail-grid">
        <p><strong>Unit Price:</strong> {{ formatCurrency(item.unitPrice, item.currency) }}</p>
        <p><strong>Subtotal:</strong> {{ formatCurrency(item.subTotalAmount ?? item.finalAmount, item.currency) }}</p>
        <p><strong>Fees:</strong> {{ formatCurrency(item.totalFeesAmount ?? 0, item.currency) }}</p>
        <p><strong>Discount:</strong> {{ formatCurrency(item.discountAmount ?? 0, item.currency) }}</p>
        <p><strong>Final Amount:</strong> {{ formatCurrency(item.finalAmount, item.currency) }}</p>
      </div>
    </Card>
  </section>
  <section v-else><p>Transaction not found.</p></section>
</template>

<style scoped>
.tx-sections { display:grid; gap: 12px; }
.detail-grid { display:grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap: 8px 12px; }
.detail-grid p { margin: 0; }
</style>
