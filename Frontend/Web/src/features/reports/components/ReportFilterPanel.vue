<script setup lang="ts">
import { computed } from "vue";
import type { Investor, Product, Seller } from "../../../shared/types/models";
import type { ReportFilters, ReportTypeCard } from "../types/reportTypes";
import Card from "../../../shared/components/ui/Card.vue";
import Select from "../../../shared/components/ui/Select.vue";
import Input from "../../../shared/components/ui/Input.vue";
import Button from "../../../shared/components/ui/Button.vue";
import FormField from "../../../shared/components/ui/FormField.vue";

const props = defineProps<{
  role: "Admin" | "Seller";
  filters: ReportFilters;
  reportTypes: ReportTypeCard[];
  sellers: Seller[];
  investors: Investor[];
  products: Product[];
  categories: string[];
}>();

const emit = defineEmits<{ refresh: []; reset: []; typeSelected: [type: string] }>();

const isInvestorReport = computed(() => props.filters.reportType.includes("investor") || props.filters.reportType === "customers");
const isSalesReport = computed(() => ["sales", "sellerPerformance", "walletTransactions", "invoices", "sellerSales", "stock"].includes(props.filters.reportType));
const isRequestOpsReport = computed(() => ["requestsOps", "kycOnboarding", "operations", "requests", "fulfillment"].includes(props.filters.reportType));
</script>

<template>
  <div class="report-type-grid">
    <button v-for="card in reportTypes" :key="card.key" class="report-type-card" :class="{ active: filters.reportType === card.key }" @click="emit('typeSelected', card.key)">
      <strong>{{ card.label }}</strong>
      <small>{{ card.description }}</small>
    </button>
  </div>

  <Card title="Filters" subtitle="Only fields relevant to the selected report type are shown.">
    <div class="report-filters-grid">
      <FormField label="Date Range"><Select v-model="filters.datePreset"><option value="today">Today</option><option value="yesterday">Yesterday</option><option value="thisWeek">This Week</option><option value="thisMonth">This Month</option><option value="custom">Custom Date</option></Select></FormField>
      <FormField v-if="filters.datePreset === 'custom'" label="From"><Input v-model="filters.customFrom" type="date" /></FormField>
      <FormField v-if="filters.datePreset === 'custom'" label="To"><Input v-model="filters.customTo" type="date" /></FormField>

      <FormField v-if="role === 'Admin'" label="Seller"><Select v-model="filters.sellerId"><option value="all">All Sellers</option><option v-for="seller in sellers" :key="seller.id" :value="seller.id">{{ seller.name }} ({{ seller.sellerId }})</option></Select></FormField>
      <FormField v-if="isInvestorReport || isSalesReport" label="Investor"><Select v-model="filters.investorId"><option value="all">All Investors</option><option v-for="investor in investors" :key="investor.id" :value="investor.id">{{ investor.fullName }}</option></Select></FormField>
      <FormField v-if="isSalesReport" label="Product"><Select v-model="filters.productId"><option value="all">All Products</option><option v-for="product in products" :key="product.id" :value="product.id">{{ product.name }}</option></Select></FormField>
      <FormField v-if="isSalesReport" label="Category"><Select v-model="filters.category"><option value="all">All Categories</option><option v-for="category in categories" :key="category" :value="category">{{ category }}</option></Select></FormField>
      <FormField v-if="isRequestOpsReport" label="Request Type"><Select v-model="filters.requestType"><option value="all">All Request Types</option><option value="buy">Buy</option><option value="sell">Sell</option><option value="pickup">Pickup</option><option value="gift">Gift</option><option value="transfer">Transfer</option><option value="withdrawal">Withdrawal</option></Select></FormField>
      <FormField v-if="isSalesReport || isRequestOpsReport" label="Status"><Select v-model="filters.transactionStatus"><option value="all">All Transaction Status</option><option value="pending">Pending</option><option value="approved">Approved</option><option value="rejected">Rejected</option><option value="pending_delivered">Pending Delivered</option><option value="delivered">Delivered</option><option value="cancelled">Cancelled</option></Select></FormField>
      <FormField v-if="filters.reportType === 'invoices'" label="Payment Status"><Select v-model="filters.paymentStatus"><option value="all">All Payment Status</option><option value="Pending">Pending</option><option value="Paid">Paid</option><option value="Failed">Failed</option><option value="Cancelled">Cancelled</option></Select></FormField>
      <FormField v-if="filters.reportType === 'walletTransactions'" label="Wallet Action"><Select v-model="filters.walletActionType"><option value="all">All Wallet Actions</option><option value="buy">Buy</option><option value="sell">Sell</option><option value="pickup">Pickup</option><option value="gift">Gift</option><option value="transfer">Transfer</option></Select></FormField>
      <FormField label="Invoice #"><Input v-model="filters.invoiceNumber" placeholder="Invoice number" /></FormField>
      <FormField label="Order / Request #"><Input v-model="filters.orderNumber" placeholder="Order / request number" /></FormField>
    </div>
    <div class="report-actions"><Button variant="ghost" @click="emit('reset')">Reset Filters</Button><Button @click="emit('refresh')">Apply Filters</Button></div>
  </Card>
</template>

