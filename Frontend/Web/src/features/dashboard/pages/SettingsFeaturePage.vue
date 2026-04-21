<script setup lang="ts">
import { onMounted, ref } from "vue";
import { getJson, postJson } from "../../../shared/services/httpClient";
import SectionCard from "../../../shared/components/SectionCard.vue";
import type { ReturnTypeUseMarketplace } from "../../../shared/app/store/useMarketplace";

const props = defineProps<{ marketplace: ReturnTypeUseMarketplace }>();

interface SettingItem {
  configKey: string;
  name: string;
  description?: string;
  valueType: number;
  valueBool?: boolean | null;
  valueInt?: number | null;
  valueDecimal?: number | null;
  valueString?: string | null;
  sellerAccess: boolean;
}

const settings = ref<SettingItem[]>([]);
const busy = ref(false);

const load = async () => {
  if (!props.marketplace.session.value?.accessToken) return;
  settings.value = await postJson<SettingItem[], object>("/api/mobile-app-configurations/list", {}, props.marketplace.session.value.accessToken);
};

const save = async (item: SettingItem) => {
  if (!props.marketplace.session.value?.accessToken) return;
  busy.value = true;
  try {
    await postJson<SettingItem, SettingItem>("/api/mobile-app-configurations/upsert", item, props.marketplace.session.value.accessToken);
    await getJson<string>("/api/web-admin/wallet/sell-configuration", props.marketplace.session.value.accessToken);
  } finally {
    busy.value = false;
  }
};

onMounted(() => { void load(); });
</script>

<template>
  <SectionCard title="System Settings">
    <table>
      <thead><tr><th>Key</th><th>Name</th><th>Value</th><th>Type</th><th>Save</th></tr></thead>
      <tbody>
        <tr v-for="item in settings" :key="item.configKey">
          <td>{{ item.configKey }}</td><td>{{ item.name }}</td>
          <td>
            <input v-if="item.valueType === 1" v-model="item.valueString" />
            <input v-else-if="item.valueType === 2" v-model="item.valueBool" type="checkbox" />
            <input v-else-if="item.valueType === 3" v-model.number="item.valueInt" type="number" />
            <input v-else v-model.number="item.valueDecimal" type="number" step="0.01" />
          </td>
          <td>{{ item.valueType }}</td>
          <td><button :disabled="busy" @click="save(item)">Save</button></td>
        </tr>
      </tbody>
    </table>
  </SectionCard>
</template>
