<script setup lang="ts">
import type { Seller } from "../../../shared/types/models";
withDefaults(
  defineProps<{
    role: "admin" | "seller";
    sellers: Seller[];
    reportFilters: { reportType: string; sellerId: string; userId: string; userName: string; productName: string; dateRange: string; customFrom: string; customTo: string; stockOnly: boolean };
    reportTypeCards?: Array<{ key: string; label: string; description: string }>;
    rows?: Array<Record<string, string | number>>;
  }>(),
  {
    role: "seller",
    sellers: () => [],
    reportTypeCards: () => [],
    rows: () => [],
  }
);

const emit = defineEmits<{ generate: []; excel: []; pdf: [] }>();
</script>

<template>
  <div class="report-type-grid">
    <button v-for="card in reportTypeCards" :key="card.key" class="report-type-card" :class="{ active: reportFilters.reportType === card.key }" @click="reportFilters.reportType = card.key">
      <strong>{{ card.label }}</strong><small>{{ card.description }}</small>
    </button>
  </div>
  <div class="grid-two report-filters">
    <input v-model="reportFilters.userId" placeholder="User ID" />
    <input v-model="reportFilters.userName" placeholder="User Name" />
    <input v-model="reportFilters.productName" placeholder="Product Name" />
    <select v-if="role === 'admin'" v-model="reportFilters.sellerId">
      <option value="all">All Sellers</option>
      <option v-for="seller in sellers" :key="seller.id" :value="seller.id">{{ seller.name }} ({{ seller.sellerId }})</option>
    </select>
    <select v-model="reportFilters.dateRange"><option value="today">Today</option><option value="last3days">Last 3 days</option><option value="lastWeek">Last week</option><option value="month">Month</option><option value="custom">Custom</option></select>
    <input v-if="reportFilters.dateRange === 'custom'" v-model="reportFilters.customFrom" type="date" />
    <input v-if="reportFilters.dateRange === 'custom'" v-model="reportFilters.customTo" type="date" />
    <label class="checkbox-line"><input v-model="reportFilters.stockOnly" type="checkbox" /> In stock only</label>
  </div>
  <div class="report-actions"><button @click="emit('generate')">Generate Report</button><button class="ghost" @click="emit('excel')">Download Excel</button><button class="ghost" @click="emit('pdf')">Download PDF</button></div>
  <table v-if="rows.length"><thead><tr><th>Type</th><th>Seller ID</th><th>Seller Name</th><th>User ID</th><th>User Name</th><th>Product</th><th>Stock</th><th>Price</th><th>Date Range</th></tr></thead><tbody><tr v-for="(row, i) in rows" :key="i"><td>{{ row.type }}</td><td>{{ row.sellerId }}</td><td>{{ row.sellerName }}</td><td>{{ row.userId }}</td><td>{{ row.userName }}</td><td>{{ row.productName }}</td><td>{{ row.stock }}</td><td>{{ row.unitPrice }}</td><td>{{ row.dateRange }}</td></tr></tbody></table>
</template>
