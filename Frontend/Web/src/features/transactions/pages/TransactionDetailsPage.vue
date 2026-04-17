<script setup lang="ts">
import type { TransactionRowView } from "../types/transactionTypes";
import { statusClass } from "../../../shared/services/statusStyles";
import { formatCurrency, formatDateTime } from "../../../shared/services/formatters";

defineProps<{ item: TransactionRowView | null }>();
</script>

<template>
  <section v-if="item" class="tx-details-card">
    <h3>Transaction Details</h3>
    <p><strong>ID:</strong> {{ item.id }}</p>
    <p><strong>Investor ID:</strong> {{ item.investorId }}</p>
    <p><strong>Investor:</strong> {{ item.investorName }}</p>
    <p><strong>Type:</strong> {{ item.transactionType }}</p>
    <template v-if="['transfer', 'gift'].includes((item.transactionType || '').toLowerCase())">
      <p><strong>Transfer From:</strong> {{ item.transferFrom || "—" }}</p>
      <p><strong>Transfer To:</strong> {{ item.transferTo || "—" }}</p>
    </template>
    <p><strong>Product:</strong> {{ item.productName }}</p>
    <p><strong>Category:</strong> {{ item.category }}</p>
    <p><strong>Quantity:</strong> {{ item.quantity.toLocaleString() }}</p>
    <p><strong>Weight:</strong> {{ item.weight.toFixed(3) }} {{ item.unit }}</p>
    <p><strong>Purity:</strong> {{ item.purity }}%</p>
    <p><strong>Unit Price:</strong> {{ formatCurrency(item.unitPrice, item.currency) }}</p>
    <p><strong>Amount:</strong> {{ formatCurrency(item.amount, item.currency) }}</p>
    <p><strong>Currency:</strong> {{ item.currency }}</p>
    <p><strong>Notes:</strong> {{ item.notes || "—" }}</p>
    <p><strong>Status:</strong> <span :class="statusClass(item.status)">{{ item.status }}</span></p>
    <p><strong>Created At:</strong> {{ formatDateTime(item.createdAt) }}</p>
    <p><strong>Updated At:</strong> {{ item.updatedAt ? formatDateTime(item.updatedAt) : "—" }}</p>
  </section>
  <section v-else>
    <p>Transaction not found.</p>
  </section>
</template>

<style scoped>
.tx-details-card {
  border: 1px solid var(--border-color, #ddd);
  border-radius: 14px;
  padding: 20px;
  background: var(--card-bg, #fff);
  box-shadow: 0 8px 30px rgba(0,0,0,0.08);
}
</style>
