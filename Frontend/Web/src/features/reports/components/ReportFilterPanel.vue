<script setup lang="ts">
import type { Investor, Product, Seller } from "../../../shared/types/models";
import type { ReportFilters, ReportTypeCard } from "../types/reportTypes";

const props = defineProps<{
  role: "Admin" | "Seller";
  filters: ReportFilters;
  reportTypes: ReportTypeCard[];
  sellers: Seller[];
  investors: Investor[];
  products: Product[];
  categories: string[];
}>();

const emit = defineEmits<{ refresh: []; reset: [] }>();
</script>

<template>
  <div class="report-type-grid">
    <button
      v-for="card in reportTypes"
      :key="card.key"
      class="report-type-card"
      :class="{ active: filters.reportType === card.key }"
      @click="filters.reportType = card.key"
    >
      <strong>{{ card.label }}</strong>
      <small>{{ card.description }}</small>
    </button>
  </div>

  <div class="report-filters-grid">
    <select v-model="filters.datePreset">
      <option value="today">Today</option>
      <option value="yesterday">Yesterday</option>
      <option value="thisWeek">This Week</option>
      <option value="thisMonth">This Month</option>
      <option value="custom">Custom Date</option>
    </select>
    <input v-if="filters.datePreset === 'custom'" v-model="filters.customFrom" type="date" />
    <input v-if="filters.datePreset === 'custom'" v-model="filters.customTo" type="date" />

    <select v-if="role === 'Admin'" v-model="filters.sellerId">
      <option value="all">All Sellers</option>
      <option v-for="seller in sellers" :key="seller.id" :value="seller.id">{{ seller.name }} ({{ seller.sellerId }})</option>
    </select>

    <select v-model="filters.investorId">
      <option value="all">All Investors</option>
      <option v-for="investor in investors" :key="investor.id" :value="investor.id">{{ investor.fullName }}</option>
    </select>

    <select v-model="filters.productId">
      <option value="all">All Products</option>
      <option v-for="product in products" :key="product.id" :value="product.id">{{ product.name }}</option>
    </select>

    <select v-model="filters.category">
      <option value="all">All Categories</option>
      <option v-for="category in categories" :key="category" :value="category">{{ category }}</option>
    </select>

    <select v-model="filters.requestType">
      <option value="all">All Request Types</option>
      <option value="buy">Buy</option><option value="sell">Sell</option><option value="pickup">Pickup</option>
      <option value="gift">Gift</option><option value="transfer">Transfer</option><option value="withdrawal">Withdrawal</option>
    </select>

    <select v-model="filters.transactionStatus">
      <option value="all">All Transaction Status</option>
      <option value="pending">Pending</option><option value="approved">Approved</option><option value="rejected">Rejected</option>
      <option value="pending_delivered">Pending Delivered</option><option value="delivered">Delivered</option><option value="cancelled">Cancelled</option>
    </select>

    <select v-model="filters.paymentStatus">
      <option value="all">All Payment Status</option>
      <option value="Pending">Pending</option><option value="Paid">Paid</option><option value="Failed">Failed</option><option value="Cancelled">Cancelled</option>
    </select>

    <select v-model="filters.walletActionType">
      <option value="all">All Wallet Actions</option>
      <option value="buy">Buy</option><option value="sell">Sell</option><option value="pickup">Pickup</option><option value="gift">Gift</option><option value="transfer">Transfer</option>
    </select>

    <input v-model="filters.invoiceNumber" placeholder="Invoice number" />
    <input v-model="filters.orderNumber" placeholder="Order / request number" />
    <input v-model="filters.userName" placeholder="User name" />
    <input v-model="filters.phone" placeholder="Phone" />
    <input v-model="filters.email" placeholder="Email" />

    <select v-model="filters.pageSize">
      <option :value="10">10 / page</option>
      <option :value="25">25 / page</option>
      <option :value="50">50 / page</option>
    </select>

    <button class="ghost" @click="emit('reset')">Reset Filters</button>
    <button @click="emit('refresh')">Apply Filters</button>
  </div>
</template>
