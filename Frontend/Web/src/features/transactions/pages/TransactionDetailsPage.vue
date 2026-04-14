<script setup lang="ts">
import type { TransactionRowView } from "../types/transactionTypes";
import { statusClass } from "../../../shared/services/statusStyles";

defineProps<{ item: TransactionRowView | null }>();
</script>

<template>
  <section v-if="item" class="tx-details-card">
    <h3>Transaction Details</h3>
    <p><strong>ID:</strong> {{ item.id }}</p>
    <p><strong>Investor:</strong> {{ item.investorName }}</p>
    <p><strong>Type:</strong> {{ item.transactionType }}</p>
    <p><strong>Category:</strong> {{ item.productName }}</p>
    <p><strong>Amount:</strong> {{ item.amount }}</p>
    <p><strong>Unit Price:</strong> {{ item.transactionPrice }}</p>
    <p><strong>Status:</strong> <span :class="statusClass(item.status)">{{ item.status }}</span></p>
    <p><strong>Created At:</strong> {{ item.createdAt }}</p>
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
