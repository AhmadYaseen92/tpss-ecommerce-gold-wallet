<script setup lang="ts">
import Card from "../../../shared/components/ui/Card.vue";
import StatusBadge from "../../../shared/components/ui/StatusBadge.vue";

defineProps<{
  dashboardPeriod: "month";
  dashboardCards: Array<{ title: string; value: string; trend: string }>;
  statusRing: Array<{ key: string; label: string; value: number; color: string; percent: number }>;
  categoryTransactionSeries: Array<{ label: string; value: number }>;
  categoryCartSeries: Array<{ label: string; value: number }>;
  recentTransactions: Array<{
    id: string;
    sellerName?: string;
    investorName: string;
    productName: string;
    amount: number;
    status: string;
    type: string;
    createdAt: string;
  }>;
  pendingKycRequests: number;
}>();

const ringBackground = (segments: Array<{ color: string; percent: number }>) => {
  let current = 0;
  return `conic-gradient(${segments
    .map((s) => {
      const start = current;
      current += s.percent;
      return `${s.color} ${start}% ${current}%`;
    })
    .join(",")})`;
};

const barHeight = (value: number, max: number) => {
  return `${Math.max(8, (value / (max || 1)) * 140)}px`;
};
</script>

<template>
  <section class="dashboard-screen">
    <Card
      title="KYC Seller Requests"
      :subtitle="pendingKycRequests > 0 ? 'Action required: pending seller KYC requests.' : 'No pending seller KYC requests.'"
      class="kyc-widget"
      :class="{ alert: pendingKycRequests > 0 }"
    >
      <div class="kyc-widget-content">
        <strong>{{ pendingKycRequests }}</strong>
        <span>{{ pendingKycRequests === 1 ? "Pending request" : "Pending requests" }}</span>
      </div>
    </Card>

    <!-- Metrics -->
    <div class="interactive-metrics">
      <div v-for="card in dashboardCards" :key="card.title" class="metric-interactive-card">
        <p>{{ card.title }}</p>
        <strong>{{ card.value }}</strong>
        <small>{{ card.trend }}</small>
      </div>
    </div>

    <!-- Charts -->
    <div class="dashboard-bottom-grid">

      <!-- Ring -->
      <Card title="Transactions Status">
        <div class="ring-layout">
          <div class="circular-chart" :style="{ background: ringBackground(statusRing) }"></div>

          <ul class="ring-legend">
            <li v-for="item in statusRing" :key="item.key">
              <span class="legend-dot" :style="{ backgroundColor: item.color }"></span>
              <span>{{ item.label }}: {{ item.value }}</span>
            </li>
          </ul>
        </div>
      </Card>

      <!-- Transactions -->
      <Card title="Wallet Analytics">
        <div class="bar-chart">
          <div
            v-for="item in categoryTransactionSeries"
            :key="item.label"
            class="bar-column"
          >
            <small class="bar-value">{{ item.value }}</small>
            <div
              class="bar-stick"
              :style="{ height: barHeight(item.value, Math.max(...categoryTransactionSeries.map(x => x.value))) }"
            ></div>
            <span class="bar-label">{{ item.label }}</span>
          </div>
        </div>
      </Card>

      <!-- Cart -->
      <Card title="Cart Analytics">
        <div class="bar-chart">
          <div
            v-for="item in categoryCartSeries"
            :key="item.label"
            class="bar-column"
          >
            <small class="bar-value">{{ item.value }}</small>
            <div
              class="bar-stick cart"
              :style="{ height: barHeight(item.value, Math.max(...categoryCartSeries.map(x => x.value))) }"
            ></div>
            <span class="bar-label">{{ item.label }}</span>
          </div>
        </div>
      </Card>

    </div>

    <!-- Table -->
    <Card title="Recent Transactions">
      <div v-if="!recentTransactions.length" class="ui-state">
        No transactions available.
      </div>

      <div v-else class="ui-table-wrap">
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
              <td><StatusBadge :status="item.status" /></td>
              <td>{{ item.createdAt }}</td>
            </tr>
          </tbody>
        </table>
      </div>
    </Card>

  </section>
</template>

<style scoped>
.kyc-widget {
  margin-bottom: 12px;
  border-color: var(--border-strong);
}

.kyc-widget.alert {
  border-color: color-mix(in srgb, var(--warning) 60%, var(--border-strong));
  box-shadow: 0 0 0 1px color-mix(in srgb, var(--warning) 40%, transparent);
}

.kyc-widget-content {
  display: inline-flex;
  align-items: baseline;
  gap: 10px;
}

.kyc-widget-content strong {
  font-size: 28px;
  line-height: 1;
}
</style>
