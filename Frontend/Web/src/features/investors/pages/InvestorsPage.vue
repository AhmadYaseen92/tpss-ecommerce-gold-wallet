<script setup lang="ts">
import type { InvestorRowView } from "../types/investorTypes";
import StatusBadge from "../../../shared/components/ui/StatusBadge.vue";
import Button from "../../../shared/components/ui/Button.vue";

withDefaults(
  defineProps<{
    investors?: InvestorRowView[];
  }>(),
  {
    investors: () => [],
  }
);

const emit = defineEmits<{ open: [id: string]; toggle: [id: string] }>();
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
          <tr v-for="investor in investors" :key="investor.id" class="clickable-row" @click="emit('open', investor.id)">
            <td><strong>{{ investor.id }}</strong></td>
            <td><strong>{{ investor.fullName }}</strong></td>
            <td>{{ investor.email }}</td>
            <td>{{ investor.phoneNumber }}</td>
            <td><StatusBadge :status="investor.status" /></td>
            <td>{{ investor.totalTransactions }}</td>
            <td>{{ investor.approvedTransactions }}/{{ investor.pendingTransactions }}/{{ investor.rejectedTransactions }}</td>
            <td>{{ formatMoney(investor.totalVolume) }}</td>
            <td>{{ formatMoney(investor.walletBalance) }}</td>
            <td>{{ investor.createdDate }}</td>
            <td>{{ investor.lastActivityDate }}</td>
            <td class="text-right" @click.stop>
              <div class="ui-row-actions">
                <Button size="sm" variant="ghost" @click="emit('toggle', investor.id)">
                  {{ investor.status === 'active' ? 'Block' : 'Activate' }}
                </Button>
              </div>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>
