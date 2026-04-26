<script setup lang="ts">
import type { TransactionRowView } from "../types/transactionTypes";
import { formatCurrency, formatDateTime } from "../../../shared/services/formatters";
import StatusBadge from "../../../shared/components/ui/StatusBadge.vue";
import Button from "../../../shared/components/ui/Button.vue";
import Select from "../../../shared/components/ui/Select.vue";

withDefaults(
  defineProps<{
    items?: TransactionRowView[];
  }>(),
  {
    items: () => [],
  }
);

const emit = defineEmits<{
  (e: "view", id: string): void;
  (e: "quickStatus", id: string, status: "pending" | "approved" | "rejected" | "delivered" | "cancelled"): void;
  (e: "cancelRequest", id: string): void;
}>();

const formatAmount = (amount: number, currency: string) => formatCurrency(amount, currency);
const formatWeight = (weight: number, unit: string) => `${weight.toFixed(3)} ${unit}`;
const formatQty = (quantity: number) => quantity.toLocaleString();

const canEditStatus = (trx: TransactionRowView) =>
  trx.status === "pending" || (trx.status === "pending_delivered" && trx.transactionType?.toLowerCase() === "pickup");

const statusOptions = (trx: TransactionRowView) => {
  if (trx.status === "pending_delivered") {
    return [
      { value: "pending_delivered", label: "Pending - Delivered" },
      { value: "delivered", label: "Delivered" },
      { value: "cancelled", label: "Canceled" }
    ] as const;
  }

  return [
    { value: "pending", label: "Pending" },
    { value: "approved", label: "Approved" },
    { value: "rejected", label: "Rejected" },
    { value: "cancelled", label: "Canceled" }
  ] as const;
};
</script>

<template>
  <div class="ui-table-wrap">
    <table>
      <thead>
        <tr>
          <th>Transaction ID</th><th>Investor</th><th>Seller</th><th>Product</th><th>Type</th><th>Qty</th><th>Weight</th><th>Amount</th><th>Status</th><th>Created</th><th>Updated</th><th class="text-right">Actions</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="trx in items" :key="trx.id">
          <td>{{ trx.id }}</td>
          <td>{{ trx.investorName }}</td>
          <td>{{ trx.sellerName || trx.sellerId || '-' }}</td>
          <td>
            <div class="ui-row-inline">
              <img v-if="trx.productImageUrl" :src="trx.productImageUrl" :alt="trx.productName" class="product-thumb" />
              <span>{{ trx.productName }}</span>
            </div>
          </td>
          <td>
            <div>{{ trx.transactionType }}</div>
            <small v-if="trx.pickupSchedule">Pickup: {{ trx.pickupSchedule }}</small>
          </td>
          <td>{{ formatQty(trx.quantity) }}</td>
          <td>{{ formatWeight(trx.weight, trx.unit) }}</td>
          <td>{{ formatAmount(trx.finalAmount, trx.currency) }}</td>
          <td>
            <Select
              v-if="canEditStatus(trx)"
              :model-value="trx.status"
              @update:model-value="emit('quickStatus', trx.id, $event as 'pending' | 'approved' | 'rejected' | 'delivered' | 'cancelled')"
            >
              <option v-for="option in statusOptions(trx)" :key="option.value" :value="option.value">{{ option.label }}</option>
            </Select>
            <StatusBadge v-else :status="trx.status" />
          </td>
          <td>{{ formatDateTime(trx.createdAt) }}</td>
          <td>{{ trx.updatedAt ? formatDateTime(trx.updatedAt) : "—" }}</td>
          <td class="text-right">
            <div class="ui-row-actions">
              <Button size="sm" @click="emit('view', trx.id)">View</Button>
              <Button v-if="canEditStatus(trx)" size="sm" variant="ghost" @click="emit('cancelRequest', trx.id)">Cancel</Button>
            </div>
          </td>
        </tr>
      </tbody>
    </table>
  </div>
</template>
