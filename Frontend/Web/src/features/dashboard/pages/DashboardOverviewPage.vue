<script setup lang="ts">
import SectionCard from "../../../shared/components/SectionCard.vue";
import MetricGrid from "../../../shared/components/MetricGrid.vue";

defineProps<{
  dashboardPeriod: "today" | "week" | "month";
  dashboardCards: Array<{ title: string; value: string; trend: string }>;
  chartPoints: Array<{ x: number; transactions: number; sales: number }>;
  statusSummary: { pending: number; approved: number; rejected: number };
  categorySummary: Array<{ category: string; count: number }>;
}>();

const emit = defineEmits<{ changePeriod: [period: "today" | "week" | "month"] }>();
</script>

<template>
  <SectionCard title="Dashboard Filters">
    <div class="report-actions">
      <button :class="{ ghost: dashboardPeriod !== 'today' }" @click="emit('changePeriod', 'today')">Today</button>
      <button :class="{ ghost: dashboardPeriod !== 'week' }" @click="emit('changePeriod', 'week')">Week</button>
      <button :class="{ ghost: dashboardPeriod !== 'month' }" @click="emit('changePeriod', 'month')">Month</button>
    </div>
  </SectionCard>

  <MetricGrid :metrics="dashboardCards" />

  <SectionCard title="Transactions Trend (Line)">
    <div class="chart-line">
      <div v-for="point in chartPoints" :key="`tx-${point.x}`" class="line-point" :style="{ height: `${point.transactions * 2}px` }"></div>
    </div>
  </SectionCard>

  <SectionCard title="Sales Trend (Line)">
    <div class="chart-line">
      <div v-for="point in chartPoints" :key="`sales-${point.x}`" class="line-point gold" :style="{ height: `${point.sales / 20}px` }"></div>
    </div>
  </SectionCard>

  <SectionCard title="Transactions by Status (Bar)">
    <div class="chart-bars">
      <div class="bar pending" :style="{ height: `${statusSummary.pending * 30 + 20}px` }">Pending {{ statusSummary.pending }}</div>
      <div class="bar approved" :style="{ height: `${statusSummary.approved * 30 + 20}px` }">Approved {{ statusSummary.approved }}</div>
      <div class="bar rejected" :style="{ height: `${statusSummary.rejected * 30 + 20}px` }">Rejected {{ statusSummary.rejected }}</div>
    </div>
  </SectionCard>

  <SectionCard title="Products by Category (Bar)">
    <div class="chart-bars">
      <div v-for="item in categorySummary" :key="item.category" class="bar gold" :style="{ height: `${item.count * 28 + 20}px` }">
        {{ item.category }} ({{ item.count }})
      </div>
    </div>
  </SectionCard>
</template>
