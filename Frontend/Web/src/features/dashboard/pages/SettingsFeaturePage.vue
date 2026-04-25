<script setup lang="ts">
import { computed, onMounted, ref } from "vue";
import { postJson } from "../../../shared/services/httpClient";
import { fetchSellers } from "../../../shared/services/backendGateway";
import type { ReturnTypeUseMarketplace } from "../../../shared/app/store/useMarketplace";
import type { Seller } from "../../../shared/types/models";

import Card from "../../../shared/components/ui/Card.vue";
import PageHeader from "../../../shared/components/ui/PageHeader.vue";
import Button from "../../../shared/components/ui/Button.vue";
import Input from "../../../shared/components/ui/Input.vue";
import Select from "../../../shared/components/ui/Select.vue";
import Checkbox from "../../../shared/components/ui/Checkbox.vue";
import LoadingState from "../../../shared/components/ui/LoadingState.vue";

const props = defineProps<{ marketplace: ReturnTypeUseMarketplace }>();

interface SettingItem {
  configKey: string;
  name: string;
  description?: string;
  valueType: number;
  valueBool?: boolean;
  valueInt?: number | null;
  valueDecimal?: number | null;
  valueString?: string | null;
  sellerAccess: boolean;
}

const settings = ref<SettingItem[]>([]);
const sellers = ref<Seller[]>([]);
const loading = ref(false);
const saving = ref(false);

const load = async () => {
  if (!props.marketplace.session.value?.accessToken) return;

  loading.value = true;

  try {
    settings.value = await postJson("/api/mobile-app-configurations/list", {}, props.marketplace.session.value.accessToken);
    sellers.value = await fetchSellers(props.marketplace.session.value.accessToken);
  } finally {
    loading.value = false;
  }
};

onMounted(load);

const grouped = computed(() => {
  const map = new Map<string, SettingItem[]>();

  settings.value.forEach((s) => {
    const group = s.configKey.split("_")[0] || "General";
    if (!map.has(group)) map.set(group, []);
    map.get(group)!.push(s);
  });

  return Array.from(map.entries());
});

const saveAll = async () => {
  if (!props.marketplace.session.value?.accessToken) return;

  saving.value = true;

  try {
    for (const s of settings.value) {
      await postJson("/api/mobile-app-configurations/upsert", s, props.marketplace.session.value.accessToken);
    }
  } finally {
    saving.value = false;
  }
};
</script>

<template>
  <section class="dashboard-screen">

    <PageHeader
      title="System Settings"
      subtitle="Manage all application configurations and behavior."
    >
      <Button :loading="saving" @click="saveAll">
        Save All
      </Button>
    </PageHeader>

    <LoadingState v-if="loading" text="Loading settings..." />

    <template v-else>

      <div v-for="[group, items] in grouped" :key="group">

        <Card :title="group">

          <div class="settings-grid">

            <div v-for="item in items" :key="item.configKey" class="ui-card">

              <div class="setting-header">
                <div>
                  <strong>{{ item.name }}</strong>
                  <p class="hint-text">{{ item.description }}</p>
                </div>

                <Checkbox v-if="item.valueType === 2" v-model="item.valueBool" label="Enabled" />
              </div>

              <!-- STRING -->
              <Input
                v-if="item.valueType === 1"
                v-model="item.valueString"
                placeholder="Enter value"
              />

              <!-- INT -->
              <Input
                v-if="item.valueType === 3"
                type="number"
                v-model="item.valueInt"
              />

              <!-- DECIMAL -->
              <Input
                v-if="item.valueType === 4"
                type="number"
                step="0.01"
                v-model="item.valueDecimal"
              />

              <!-- SELLER SELECT -->
              <Select v-if="item.configKey === 'MobileRelease_IndividualSellerName'" v-model="item.valueString">
                <option value="">Select seller</option>
                <option v-for="s in sellers" :key="s.id" :value="s.name">
                  {{ s.name }}
                </option>
              </Select>

            </div>

          </div>

        </Card>

      </div>

    </template>

  </section>
</template>