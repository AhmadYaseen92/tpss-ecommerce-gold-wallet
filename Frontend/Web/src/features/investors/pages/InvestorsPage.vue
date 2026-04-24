<script setup lang="ts">
import type { InvestorRowView } from "../types/investorTypes";
import StatusBadge from "../../../shared/components/ui/StatusBadge.vue";
import Button from "../../../shared/components/ui/Button.vue";

withDefaults(
  defineProps<{
    investors?: InvestorRowView[];
    selected?: InvestorRowView | null;
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
        <td>{{ investor.fullName }}</td><td>{{ investor.email }}</td><td><StatusBadge :status="investor.status" /></td><td>{{ investor.totalTransactions }}</td><td>{{ investor.createdDate }}</td>
        <td><Button @click="emit('view', investor.id)">View</Button><Button variant="ghost" @click="emit('toggle', investor.id)">{{ investor.status === 'active' ? 'Deactivate' : 'Activate' }}</Button></td>
      </tr>
    </tbody>
  </table>
  <div v-if="selected" class="product-details">
    <p><strong>Name:</strong> {{ selected.fullName }}</p>
    <p><strong>Email:</strong> {{ selected.email }}</p>
    <p><strong>Status:</strong> <StatusBadge :status="selected.status" /></p>
    <p><strong>Total Purchases:</strong> {{ selected.totalPurchases }}</p>
    <p><strong>Last Transaction Date:</strong> {{ selected.lastTransactionDate }}</p>
  </div>
</template>
