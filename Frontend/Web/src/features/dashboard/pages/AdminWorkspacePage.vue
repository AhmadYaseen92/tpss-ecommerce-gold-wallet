<script setup lang="ts">
import { computed, onMounted, ref } from "vue";
import { fetchAdminWorkspace, type AdminWorkspaceDto } from "../../../shared/services/backendGateway";
import { useMarketplace } from "../../../shared/app/store/useMarketplace";
import PageHeader from "../../../shared/components/ui/PageHeader.vue";
import Card from "../../../shared/components/ui/Card.vue";
import Button from "../../../shared/components/ui/Button.vue";
import LoadingState from "../../../shared/components/ui/LoadingState.vue";

const props = defineProps<{
  marketplace: ReturnType<typeof useMarketplace>;
}>();

const loading = ref(false);
const error = ref<string | null>(null);
const workspace = ref<AdminWorkspaceDto | null>(null);

const load = async () => {
  if (!props.marketplace.session.value) return;

  loading.value = true;
  error.value = null;

  try {
    workspace.value = await fetchAdminWorkspace(props.marketplace.session.value.accessToken);
  } catch (e) {
    error.value = e instanceof Error ? e.message : "Failed to load admin workspace";
  } finally {
    loading.value = false;
  }
};

const metrics = computed(() => {
  if (!workspace.value) return [];

  return [
    {
      label: "Sellers",
      value: workspace.value.sellersCount,
      hint: "Registered sellers",
    },
    {
      label: "Investors",
      value: workspace.value.investorsCount,
      hint: "Registered investors",
    },
    {
      label: "Items",
      value: workspace.value.productsCount,
      hint: "Listed products",
    },
    {
      label: "Requests",
      value: workspace.value.requestsCount,
      hint: "Wallet and trading requests",
    },
    {
      label: "System Settings",
      value: workspace.value.systemSettingsCount,
      hint: "Configured app settings",
    },
  ];
});

onMounted(() => {
  void load();
});
</script>

<template>
  <section class="dashboard-screen">
    <PageHeader
      title="Admin Control Center"
      subtitle="Manage sellers, investors, products, requests, reports, and system settings."
    >
      <Button variant="secondary" size="sm" :loading="loading" @click="load">
        Refresh
      </Button>
    </PageHeader>

    <LoadingState v-if="loading" text="Loading admin workspace..." />

    <Card v-else-if="error" title="Unable to load dashboard" padding="lg">
      <div class="ui-state">
        <p class="error-text">{{ error }}</p>
        <Button variant="primary" size="sm" @click="load">Try Again</Button>
      </div>
    </Card>

    <div v-else-if="workspace" class="metric-grid">
      <article v-for="metric in metrics" :key="metric.label" class="metric-card">
        <h3>{{ metric.label }}</h3>
        <strong>{{ metric.value }}</strong>
        <span>{{ metric.hint }}</span>
      </article>
    </div>

    <Card v-else title="No dashboard data" padding="lg">
      <div class="ui-state">No admin workspace data is available.</div>
    </Card>
  </section>
</template>