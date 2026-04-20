<script setup lang="ts">
import { onMounted, ref } from "vue";
import { fetchAdminWorkspace, type AdminWorkspaceDto } from "../../../shared/services/backendGateway";
import { useMarketplace } from "../../../shared/app/store/useMarketplace";

const props = defineProps<{ marketplace: ReturnType<typeof useMarketplace> }>();
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

onMounted(() => {
  void load();
});
</script>

<template>
  <section class="feature-page">
    <header class="feature-header">
      <h2>Admin Control Center</h2>
      <p>Manage the entire app: sellers, investors, products, requests, and system settings.</p>
    </header>

    <p v-if="loading">Loading admin workspace...</p>
    <p v-else-if="error">{{ error }}</p>

    <div v-else-if="workspace" class="metric-grid">
      <article class="metric-card"><h3>Sellers</h3><p>{{ workspace.sellersCount }}</p></article>
      <article class="metric-card"><h3>Investors</h3><p>{{ workspace.investorsCount }}</p></article>
      <article class="metric-card"><h3>Items</h3><p>{{ workspace.productsCount }}</p></article>
      <article class="metric-card"><h3>Requests</h3><p>{{ workspace.requestsCount }}</p></article>
      <article class="metric-card"><h3>System Settings</h3><p>{{ workspace.systemSettingsCount }}</p></article>
    </div>
  </section>
</template>

<style scoped>
.metric-grid { display:grid; grid-template-columns: repeat(auto-fit,minmax(180px,1fr)); gap: 12px; }
.metric-card { background:#fff; border-radius:10px; border:1px solid #e8e8e8; padding:16px; }
.metric-card p { font-size: 1.5rem; font-weight: 700; }
</style>
