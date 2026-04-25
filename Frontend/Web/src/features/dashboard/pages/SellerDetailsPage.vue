<script setup lang="ts">
import { computed, onMounted, ref } from "vue";
import { ElMessage } from "element-plus";
import type { ReturnTypeUseMarketplace } from "../../../shared/app/store/useMarketplace";
import { fetchSellerDetailsByAdmin } from "../../../shared/services/backendGateway";
import type { KycStatus } from "../../../shared/types/models";
import type { WebSellerDetailsDto, WebSellerDocumentDto } from "../../../shared/types/apiTypes";

import Card from "../../../shared/components/ui/Card.vue";
import Button from "../../../shared/components/ui/Button.vue";
import StatusBadge from "../../../shared/components/ui/StatusBadge.vue";
import LoadingState from "../../../shared/components/ui/LoadingState.vue";

const props = defineProps<{ marketplace: ReturnTypeUseMarketplace }>();

const loading = ref(false);
const details = ref<WebSellerDetailsDto | null>(null);


const sellerIdFromPath = computed(() => {
  const parts = window.location.pathname.split("/").filter(Boolean);
  return parts.length >= 2 ? parts[1] : "";
});

const goBack = () => {
  window.history.pushState({}, "", "/sellers");
  window.dispatchEvent(new PopStateEvent("popstate"));
};

const loadDetails = async () => {
  if (!props.marketplace.session.value?.accessToken || !sellerIdFromPath.value) return;

  loading.value = true;

  try {
    details.value = await fetchSellerDetailsByAdmin(
      props.marketplace.session.value.accessToken,
      sellerIdFromPath.value
    );
  } catch (e) {
    ElMessage.error("Failed to load seller details");
  } finally {
    loading.value = false;
  }
};

type SellerAction = "approve" | "reject" | "block";

const setKyc = async (action: SellerAction) => {
  if (!details.value) return;

  if (action === "approve") await props.marketplace.approveKyc(details.value.id);
  if (action === "reject") await props.marketplace.rejectKyc(details.value.id);
  if (action === "block") await props.marketplace.blockKyc(details.value.id);

  await loadDetails();
};

const tabs = ["company", "managers", "branches", "banks", "files"] as const;
type SellerDetailsTab = (typeof tabs)[number];

const activeTab = ref<SellerDetailsTab>("company");

onMounted(() => {
  void loadDetails();
});
</script>

<template>
  <section class="dashboard-screen">

    <Card title="Seller Details">
      
      <div class="ui-row-actions">
        <Button variant="ghost" @click="goBack">← Back</Button>
      </div>

      <LoadingState v-if="loading" />

      <template v-else-if="details">

        <!-- Tabs -->
        <div class="ui-tabs">
        <button
  v-for="tab in tabs"
  :key="tab"
  class="ui-tab"
  :class="{ active: activeTab === tab }"
  type="button"
  @click="activeTab = tab"
>
  {{ tab }}
</button>
        </div>

        <!-- Company -->
        <Card v-if="activeTab === 'company'" title="Company Info">
          <div class="form-grid-two">
            <div><strong>Name:</strong> {{ details.companyName }}</div>
            <div><strong>Status:</strong> <StatusBadge :status="details.kycStatus" /></div>
            <div><strong>Email:</strong> {{ details.companyEmail }}</div>
            <div><strong>Phone:</strong> {{ details.companyPhone }}</div>
          </div>
        </Card>

        <!-- Managers -->
        <Card v-if="activeTab === 'managers'" title="Managers">
          <div v-if="!details.managers.length" class="ui-state">No managers</div>

          <div v-else class="grid-two">
            <div v-for="m in details.managers" :key="m.fullName" class="ui-card">
              <strong>{{ m.fullName }}</strong>
              <p>{{ m.positionTitle }}</p>
              <small>{{ m.emailAddress }}</small>
            </div>
          </div>
        </Card>

        <!-- Files -->
        <Card v-if="activeTab === 'files'" title="Documents">
          <div v-if="!details.documents.length" class="ui-state">No documents</div>

          <div v-else class="grid-two">
            <div v-for="doc in details.documents" :key="doc.id" class="ui-card">
              <strong>{{ doc.documentType }}</strong>
              <p>{{ doc.fileName }}</p>
              <Button size="sm">View</Button>
            </div>
          </div>
        </Card>

        <!-- Actions -->
        <div class="ui-row-actions">
          <Button variant="success" @click="setKyc('approve')">Approve</Button>
          <Button variant="danger" @click="setKyc('reject')">Reject</Button>
          <Button variant="warning" @click="setKyc('block')">Block</Button>
        </div>

      </template>

    </Card>

  </section>
</template>