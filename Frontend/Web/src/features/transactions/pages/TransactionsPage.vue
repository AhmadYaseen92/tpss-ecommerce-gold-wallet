<script setup lang="ts">
import type { TransactionRowView } from "../types/transactionTypes";

withDefaults(
  defineProps<{
    items?: TransactionRowView[];
    selected?: TransactionRowView | null;
    statusDraft?: "pending" | "approved" | "rejected";
    statusClass: (status?: string | null) => string;
  }>(),
  {
    items: () => [],
    selected: null,
    statusDraft: "pending",
  }
);

const emit = defineEmits<{ view: [id: string]; saveStatus: []; updateStatus: [status: "pending" | "approved" | "rejected"] }>();
</script>

<template>
  <table>
    <thead><tr><th>Transaction ID</th><th>Investor</th><th>Product</th><th>Type</th><th>Amount</th><th>Status</th><th>Date</th><th>Actions</th></tr></thead>
    <tbody>
      <tr v-for="trx in items" :key="trx.id">
        <td>{{ trx.id }}</td><td>{{ trx.investorName }}</td><td>{{ trx.productName }}</td><td>{{ trx.transactionType }}</td><td>{{ trx.amount }}</td><td><span :class="statusClass(trx.status)">{{ trx.status }}</span></td><td>{{ trx.createdAt }}</td>
        <td><button @click="emit('view', trx.id)">View</button><button class="ghost" @click="emit('view', trx.id)">Change Status</button></td>
      </tr>
    </tbody>
  </table>

  <div v-if="selected" class="product-details">
    <p><strong>Transaction ID:</strong> {{ selected.id }}</p><p><strong>Investor Info:</strong> {{ selected.investorName }}</p><p><strong>Product Info:</strong> {{ selected.productName }}</p>
    <p><strong>Type:</strong> {{ selected.transactionType }}</p><p><strong>Amount:</strong> {{ selected.amount }}</p><p><strong>Price:</strong> {{ selected.transactionPrice }}</p>
    <p><strong>Status:</strong> <span :class="statusClass(selected.status)">{{ selected.status }}</span></p>
    <label>Change Status<select :value="statusDraft" @change="emit('updateStatus', ($event.target as HTMLSelectElement).value as 'pending' | 'approved' | 'rejected')"><option value="pending">Pending</option><option value="approved">Approved</option><option value="rejected">Rejected</option></select></label>
    <button @click="emit('saveStatus')">Save</button>
  </div>
</template>
