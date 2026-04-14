<script setup lang="ts">
import type { InvestorRowView } from "../types/investorTypes";

withDefaults(
  defineProps<{
    investors?: InvestorRowView[];
    selected?: InvestorRowView | null;
    statusClass: (status?: string | null) => string;
  }>(),
  {
    investors: () => [],
    selected: null,
  }
);

const emit = defineEmits<{ view: [id: string]; toggle: [id: string] }>();
</script>

<template>
  <table>
    <thead><tr><th>Name</th><th>Email</th><th>Status</th><th>Total Transactions</th><th>Created Date</th><th>Actions</th></tr></thead>
    <tbody>
      <tr v-for="investor in investors" :key="investor.id">
        <td>{{ investor.fullName }}</td><td>{{ investor.email }}</td><td><span :class="statusClass(investor.status)">{{ investor.status }}</span></td><td>{{ investor.totalTransactions }}</td><td>{{ investor.createdDate }}</td>
        <td><button @click="emit('view', investor.id)">View</button><button class="ghost" @click="emit('toggle', investor.id)">{{ investor.status === 'active' ? 'Deactivate' : 'Activate' }}</button></td>
      </tr>
    </tbody>
  </table>
  <div v-if="selected" class="product-details">
    <p><strong>Name:</strong> {{ selected.fullName }}</p>
    <p><strong>Email:</strong> {{ selected.email }}</p>
    <p><strong>Status:</strong> <span :class="statusClass(selected.status)">{{ selected.status }}</span></p>
    <p><strong>Total Purchases:</strong> {{ selected.totalPurchases }}</p>
    <p><strong>Last Transaction Date:</strong> {{ selected.lastTransactionDate }}</p>
  </div>
</template>
