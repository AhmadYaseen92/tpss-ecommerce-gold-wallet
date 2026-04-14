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

      <SectionCard title="Product Categories Analytics">
        <div class="bar-chart">
          <div
            v-for="item in categoryTransactionSeries"
            :key="item.label"
            class="bar-column"
          >
            <small class="bar-value">{{ item.value }}</small>
            <div class="bar-stick" :style="{ height: barHeight(item.value, Math.max(...categoryTransactionSeries.map((x) => x.value), 1)) }"></div>
            <span class="bar-label">{{ item.label }}</span>
          </div>
        </div>
      </SectionCard>

      <SectionCard title="Cart Analytics">
        <div class="bar-chart">
          <div
            v-for="item in categoryCartSeries"
            :key="item.label"
            class="bar-column"
          >
            <small class="bar-value">{{ item.value }}</small>
            <div class="bar-stick cart" :style="{ height: barHeight(item.value, Math.max(...categoryCartSeries.map((x) => x.value), 1)) }"></div>
            <span class="bar-label">{{ item.label }}</span>
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
.bar-chart {
  display: flex;
  align-items: flex-end;
  gap: 0.9rem;
  min-height: 200px;
  padding: 0.75rem 0.5rem;
  overflow-x: auto;
}

.bar-column {
  min-width: 90px;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 0.4rem;
}

.bar-stick {
  width: 20px;
  border-radius: 8px 8px 2px 2px;
  background: linear-gradient(180deg, #5eead4 0%, #14b8a6 100%);
}

.bar-stick.cart {
  background: linear-gradient(180deg, #7dd3fc 0%, #22d3ee 100%);
}

.bar-label {
  font-size: 0.75rem;
  text-align: center;
  line-height: 1.1;
  max-width: 88px;
}

.bar-value {
  color: #475569;
  font-weight: 600;
}

</style>
