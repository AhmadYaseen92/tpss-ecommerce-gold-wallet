<script setup lang="ts">
import type { InvestorRowView } from "../types/investorTypes";
import StatusBadge from "../../../shared/components/ui/StatusBadge.vue";
import Button from "../../../shared/components/ui/Button.vue";
import Card from "../../../shared/components/ui/Card.vue";
import FormField from "../../../shared/components/ui/FormField.vue";

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
const formatMoney = (value: number) => value.toFixed(2);
</script>

<template>
  <div class="dashboard-screen">
    <div class="ui-table-wrap">
      <table>
        <thead>
          <tr>
            <th>Investor</th>
            <th>Email</th>
            <th>Phone</th>
            <th>Status</th>
            <th>Total Transactions</th>
            <th>Wallet Balance</th>
            <th>Created Date</th>
            <th class="text-right">Actions</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="investor in investors" :key="investor.id">
            <td><strong>{{ investor.fullName }}</strong></td>
            <td>{{ investor.email }}</td>
            <td>{{ investor.phoneNumber }}</td>
            <td><StatusBadge :status="investor.status" /></td>
            <td>{{ investor.totalTransactions }}</td>
            <td>{{ formatMoney(investor.walletBalance) }}</td>
            <td>{{ investor.createdDate }}</td>
            <td class="text-right">
              <div class="ui-row-actions">
                <Button size="sm" @click="emit('view', investor.id)">View</Button>
                <Button size="sm" variant="ghost" @click="emit('toggle', investor.id)">
                  {{ investor.status === 'active' ? 'Block' : 'Activate' }}
                </Button>
              </div>
            </td>
          </tr>
        </tbody>
      </table>
    </div>

    <Card v-if="selected" title="Investor Details">
      <div class="form-grid-three">
        <FormField label="Full Name"><div>{{ selected.fullName }}</div></FormField>
        <FormField label="Email"><div>{{ selected.email }}</div></FormField>
        <FormField label="Phone"><div>{{ selected.phoneNumber }}</div></FormField>
        <FormField label="Status"><StatusBadge :status="selected.status" /></FormField>
        <FormField label="Risk Level"><div>{{ selected.riskLevel }}</div></FormField>
        <FormField label="Wallet Balance"><div>{{ formatMoney(selected.walletBalance) }}</div></FormField>
        <FormField label="Total Transactions"><div>{{ selected.totalTransactions }}</div></FormField>
        <FormField label="Estimated Purchases"><div>{{ formatMoney(selected.totalPurchases) }}</div></FormField>
        <FormField label="Last Transaction"><div>{{ selected.lastTransactionDate }}</div></FormField>
      </div>
    </Card>
  </div>
</template>
