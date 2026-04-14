<script setup lang="ts">
import SectionCard from "../../../shared/components/SectionCard.vue";

defineProps<{
  dashboardPeriod: "month";
  dashboardCards: Array<{ title: string; value: string; trend: string }>;
  statusSummary: { pending: number; approved: number; rejected: number };
  categorySummary: Array<{ category: string; count: number }>;
  statusRing: Array<{ key: string; label: string; value: number; color: string; percent: number }>;
  categoryRing: Array<{ category: string; count: number; color: string; percent: number }>;
  categoryTransactionSeries: Array<{ label: string; value: number }>;
  categoryCartSeries: Array<{ label: string; value: number }>;
  recentTransactions: Array<{ id: string; investorName: string; productName: string; amount: number; status: string; type: string; createdAt: string }>;
}>();

const ringBackground = (segments: Array<{ color: string; percent: number }>) => {
  let current = 0;
  const stops = segments.map((segment) => {
    const start = current;
    current += segment.percent;
    return `${segment.color} ${start}% ${current}%`;
  });
  return `conic-gradient(${stops.join(",")})`;
};

const barHeight = (value: number, maxValue: number) => {
  const safeMax = Math.max(maxValue, 1);
  return `${Math.max(8, Math.round((value / safeMax) * 140))}px`;
};
</script>

<template>
  <section class="dashboard-screen">
    <SectionCard title="Dashboard Controls">
      <p>Analytics Period: <strong>This Month</strong></p>
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

      <SectionCard title="Product Categories Analytics (X,Y)">
        <div class="analytics-chart">
          <div
            v-for="item in categoryTransactionSeries"
            :key="item.label"
            class="analytics-bar-group"
          >
            <div class="analytics-bar" :style="{ height: barHeight(item.value, Math.max(...categoryTransactionSeries.map((x) => x.value), 1)) }"></div>
            <span class="analytics-label">{{ item.label }}</span>
            <small class="analytics-value">{{ item.value }}</small>
          </div>
        </div>
      </SectionCard>

      <SectionCard title="Cart Analytics (X,Y)">
        <div class="analytics-chart">
          <div
            v-for="item in categoryCartSeries"
            :key="item.label"
            class="analytics-bar-group"
          >
            <div class="analytics-bar cart" :style="{ height: barHeight(item.value, Math.max(...categoryCartSeries.map((x) => x.value), 1)) }"></div>
            <span class="analytics-label">{{ item.label }}</span>
            <small class="analytics-value">{{ item.value }}</small>
          </div>
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

<style scoped>
.analytics-chart {
  display: flex;
  align-items: flex-end;
  gap: 0.75rem;
  min-height: 190px;
  overflow-x: auto;
  padding: 0.5rem 0;
}

.analytics-bar-group {
  min-width: 90px;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 0.35rem;
}

.analytics-bar {
  width: 34px;
  border-radius: 8px 8px 2px 2px;
  background: linear-gradient(180deg, #5b6cff 0%, #3f4ed7 100%);
}

.analytics-bar.cart {
  background: linear-gradient(180deg, #14b8a6 0%, #0f766e 100%);
}

.analytics-label {
  font-size: 0.75rem;
  text-align: center;
  line-height: 1.1;
}

.analytics-value {
  color: #6b7280;
}
</style>
