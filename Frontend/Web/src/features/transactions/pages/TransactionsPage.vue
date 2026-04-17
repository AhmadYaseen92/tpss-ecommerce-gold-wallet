<script setup lang="ts">
import type { TransactionRowView } from "../types/transactionTypes";
import { formatCurrency, formatDateTime } from "../../../shared/services/formatters";

withDefaults(
  defineProps<{
    items?: TransactionRowView[];
    statusClass: (status?: string | null) => string;
  }>(),
  {
    items: () => [],
  }
);

const emit = defineEmits<{
  (e: "view", id: string): void;
  (e: "quickStatus", id: string, status: "pending" | "approved" | "rejected"): void;
}>();

const formatAmount = (amount: number, currency: string) => formatCurrency(amount, currency);
const formatWeight = (weight: number, unit: string) => `${weight.toFixed(3)} ${unit}`;
const formatQty = (quantity: number) => quantity.toLocaleString();
</script>

<template>
  <table>
    <thead>
      <tr>
        <th>Transaction ID</th>
        <th>Investor</th>
        <th>Product</th>
        <th>Category</th>
        <th>Type</th>
        <th>Qty</th>
        <th>Weight</th>
        <th>Amount</th>
        <th>Status</th>
        <th>Created</th>
        <th>Updated</th>
        <th>Actions</th>
      </tr>
    </thead>
    <tbody>
      <tr v-for="trx in items" :key="trx.id">
        <td>{{ trx.id }}</td>
        <td>{{ trx.investorName }}</td>
        <td>
          <div class="product-cell">
            <img
              v-if="trx.productImageUrl"
              :src="trx.productImageUrl"
              :alt="trx.productName"
              class="product-thumb"
            />
            <span>{{ trx.productName }}</span>
          </div>
        </td>
        <td>{{ trx.category }}</td>
        <td>{{ trx.transactionType }}</td>
        <td>{{ formatQty(trx.quantity) }}</td>
        <td>{{ formatWeight(trx.weight, trx.unit) }}</td>
        <td>{{ formatAmount(trx.amount, trx.currency) }}</td>
        <td>
          <select
            v-if="trx.status === 'pending'"
            :class="statusClass(trx.status)"
            :value="trx.status"
            @change="emit('quickStatus', trx.id, ($event.target as HTMLSelectElement).value as 'pending' | 'approved' | 'rejected')"
          >
            <option value="pending">Pending</option><option value="approved">Approved</option><option value="rejected">Rejected</option>
          </select>
          <span v-else :class="statusClass(trx.status)">{{ trx.status }}</span>
        </td>
        <td>{{ formatDateTime(trx.createdAt) }}</td>
        <td>{{ trx.updatedAt ? formatDateTime(trx.updatedAt) : "—" }}</td>
        <td><button @click="emit('view', trx.id)">View Details</button></td>
      </tr>
    </tbody>
  </table>
</template>

<style scoped>
.product-cell {
  display: flex;
  align-items: center;
  gap: 8px;
}

.product-thumb {
  width: 28px;
  height: 28px;
  object-fit: cover;
  border-radius: 6px;
  border: 1px solid #ddd;
}
</style>
