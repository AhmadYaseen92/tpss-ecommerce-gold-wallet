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
            <th>Investor ID</th>
            <th>Investor</th>
            <th>Email</th>
            <th>Phone</th>
            <th>Status</th>
            <th>Risk</th>
            <th>Total Transactions</th>
            <th>Approved/Pending/Rejected</th>
            <th>Total Volume</th>
            <th>Wallet Balance</th>
            <th>Joined Date</th>
            <th>Last Activity</th>
            <th class="text-right">Actions</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="investor in investors" :key="investor.id">
            <td><strong>{{ investor.id }}</strong></td>
            <td><strong>{{ investor.fullName }}</strong></td>
            <td>{{ investor.email }}</td>
            <td>{{ investor.phoneNumber }}</td>
            <td><StatusBadge :status="investor.status" /></td>
            <td>{{ investor.riskLevel }}</td>
            <td>{{ investor.totalTransactions }}</td>
            <td>{{ investor.approvedTransactions }}/{{ investor.pendingTransactions }}/{{ investor.rejectedTransactions }}</td>
            <td>{{ formatMoney(investor.totalVolume) }}</td>
            <td>{{ formatMoney(investor.walletBalance) }}</td>
            <td>{{ investor.createdDate }}</td>
            <td>{{ investor.lastActivityDate }}</td>
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
        <FormField label="Investor ID"><div>{{ selected.id }}</div></FormField>
        <FormField label="Numeric ID"><div>{{ selected.investorNumericId }}</div></FormField>
        <FormField label="Full Name"><div>{{ selected.fullName }}</div></FormField>
        <FormField label="Email"><div>{{ selected.email }}</div></FormField>
        <FormField label="Phone"><div>{{ selected.phoneNumber }}</div></FormField>
        <FormField label="Status"><StatusBadge :status="selected.status" /></FormField>
        <FormField label="Risk Level"><div>{{ selected.riskLevel }}</div></FormField>
        <FormField label="Wallet Balance"><div>{{ formatMoney(selected.walletBalance) }}</div></FormField>
        <FormField label="Wallet Assets"><div>{{ selected.walletAssetsCount }}</div></FormField>
        <FormField label="Total Transactions"><div>{{ selected.totalTransactions }}</div></FormField>
        <FormField label="Approved Transactions"><div>{{ selected.approvedTransactions }}</div></FormField>
        <FormField label="Pending Transactions"><div>{{ selected.pendingTransactions }}</div></FormField>
        <FormField label="Rejected Transactions"><div>{{ selected.rejectedTransactions }}</div></FormField>
        <FormField label="Total Volume"><div>{{ formatMoney(selected.totalVolume) }}</div></FormField>
        <FormField label="Estimated Purchases"><div>{{ formatMoney(selected.totalPurchases) }}</div></FormField>
        <FormField label="First Transaction"><div>{{ selected.firstTransactionDate }}</div></FormField>
        <FormField label="Last Transaction"><div>{{ selected.lastTransactionDate }}</div></FormField>
        <FormField label="Last Activity"><div>{{ selected.lastActivityDate }}</div></FormField>
        <FormField label="Joined Date"><div>{{ selected.createdDate }}</div></FormField>
      </div>
    </Card>
  </div>
</template>
