<script setup lang="ts">
import SectionCard from "../../../shared/components/SectionCard.vue";

defineProps<{
  dashboardPeriod: "today" | "week" | "month";
  dashboardCards: Array<{ title: string; value: string; trend: string }>;
  statusSummary: { pending: number; approved: number; rejected: number };
  categorySummary: Array<{ category: string; count: number }>;
  statusRing: Array<{ key: string; label: string; value: number; color: string; percent: number }>;
  categoryRing: Array<{ category: string; count: number; color: string; percent: number }>;
  recentTransactions: Array<{ id: string; investorName: string; productName: string; amount: number; status: string; type: string; createdAt: string }>;
}>();

const emit = defineEmits<{ changePeriod: [period: "today" | "week" | "month"] }>();

const ringBackground = (segments: Array<{ color: string; percent: number }>) => {
  let current = 0;
  const stops = segments.map((segment) => {
    const start = current;
    current += segment.percent;
    return `${segment.color} ${start}% ${current}%`;
  });
  return `conic-gradient(${stops.join(",")})`;
};
</script>

<template>
  <section class="dashboard-screen">
    <SectionCard title="Dashboard Controls">
      <div class="report-actions">
        <button :class="{ ghost: dashboardPeriod !== 'today' }" @click="emit('changePeriod', 'today')">Today</button>
        <button :class="{ ghost: dashboardPeriod !== 'week' }" @click="emit('changePeriod', 'week')">Week</button>
        <button :class="{ ghost: dashboardPeriod !== 'month' }" @click="emit('changePeriod', 'month')">Month</button>
      </div>
    </SectionCard>

    <div class="interactive-metrics">
      <div v-for="card in dashboardCards" :key="card.title" class="metric-interactive-card">
        <p>{{ card.title }}</p>
        <strong>{{ card.value }}</strong>
        <small>{{ card.trend }}</small>
      </div>
    </div>

    <div class="dashboard-bottom-grid">
      <SectionCard title="Transactions Status (Circular)">
        <div class="ring-layout">
          <div class="circular-chart" :style="{ background: ringBackground(statusRing) }"></div>
          <ul class="ring-legend">
            <li v-for="item in statusRing" :key="item.key">
              <span class="legend-dot" :style="{ backgroundColor: item.color }"></span>
              <span>{{ item.label }}: {{ item.value }} ({{ item.percent }}%)</span>
            </li>
          </ul>
        </div>
      </SectionCard>

      <SectionCard title="Product Categories (Circular)">
        <div class="ring-layout">
          <div class="circular-chart" :style="{ background: ringBackground(categoryRing) }"></div>
          <ul class="ring-legend">
            <li v-for="item in categoryRing" :key="item.category">
              <span class="legend-dot" :style="{ backgroundColor: item.color }"></span>
              <span>{{ item.category }}: {{ item.count }} ({{ item.percent }}%)</span>
            </li>
          </ul>
        </div>
      </SectionCard>
    </div>

    <SectionCard title="Recent Transactions History">
      <table>
        <thead>
          <tr>
            <th>ID</th>
            <th>Investor</th>
            <th>Product</th>
            <th>Type</th>
            <th>Amount</th>
            <th>Status</th>
            <th>Date</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="item in recentTransactions" :key="item.id">
            <td>{{ item.id }}</td>
            <td>{{ item.investorName }}</td>
            <td>{{ item.productName }}</td>
            <td>{{ item.type }}</td>
            <td>${{ Number(item.amount).toFixed(2) }}</td>
            <td>{{ item.status }}</td>
            <td>{{ item.createdAt }}</td>
          </tr>
        </tbody>
      </table>
    </SectionCard>
  </section>
</template>
