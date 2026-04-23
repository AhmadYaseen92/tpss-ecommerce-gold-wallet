<script setup lang="ts">
import { computed, onMounted, ref } from "vue";
import { getJson, postJson } from "../../../shared/services/httpClient";
import SectionCard from "../../../shared/components/SectionCard.vue";
import SmallCheckbox from "../../../shared/components/SmallCheckbox.vue";
import SmallToggle from "../../../shared/components/SmallToggle.vue";
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
const areaOptions = ["registration", "reset_password", "checkout", "buy", "sell", "transfer", "gift", "pickup"];

const load = async () => {
  if (!props.marketplace.session.value?.accessToken) return;
  const rows = await postJson<SettingItem[], object>("/api/mobile-app-configurations/list", {}, props.marketplace.session.value.accessToken);
  settings.value = rows.map((row) => ({
    ...row,
    valueBool: row.valueBool ?? false,
    sellerAccess: !!row.sellerAccess
  }));
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

const groupedSettings = computed(() => {
  const map = new Map<string, SettingItem[]>();
  settings.value.forEach((item) => {
    const area = item.configKey.split("_")[0] || "General";
    if (!map.has(area)) map.set(area, []);
    map.get(area)!.push(item);
  });
  return Array.from(map.entries()).map(([group, items]) => ({ group, items }));
});

const valueTypeLabel = (type: number) => {
  if (type === 1) return "Text";
  if (type === 2) return "Feature Toggle";
  if (type === 3) return "Integer";
  if (type === 4) return "Decimal";
  return "Unknown";
};

const supportsAffectedAreas = (item: SettingItem) =>
  item.configKey.toLowerCase().includes("requiredactions");

const selectedAreas = (item: SettingItem) => {
  const raw = item.valueString ?? "";
  return raw
    .split(",")
    .map((x) => x.trim())
    .filter(Boolean);
};

const isAreaChecked = (item: SettingItem, area: string) => selectedAreas(item).includes(area);

const toggleArea = (item: SettingItem, area: string, checked: boolean) => {
  const set = new Set(selectedAreas(item));
  if (checked) set.add(area);
  else set.delete(area);
  item.valueString = Array.from(set).join(",");
};
</script>

<template>
  <SectionCard title="System Settings">
    <div class="settings-layout">
      <section v-for="group in groupedSettings" :key="group.group" class="settings-group">
        <h3>{{ group.group }}</h3>
        <div class="settings-grid">
          <article v-for="item in group.items" :key="item.configKey" class="setting-card">
            <header class="setting-header">
              <div>
                <h4>{{ item.name }}</h4>
                <p class="setting-key">{{ item.configKey }}</p>
              </div>
              <span class="type-badge">{{ valueTypeLabel(item.valueType) }}</span>
            </header>

            <p class="setting-description">{{ item.description || "No description provided." }}</p>

            <div class="setting-row" v-if="item.valueType === 2">
              <label class="inline-toggle">
                <SmallToggle v-model="item.valueBool" />
                <span>Feature enabled</span>
              </label>
            </div>

            <div class="setting-row" v-else-if="item.valueType === 1">
              <label>Default value</label>
              <input v-model="item.valueString" type="text" />
            </div>

            <div class="setting-row" v-else-if="item.valueType === 3">
              <label>Default value</label>
              <input v-model.number="item.valueInt" type="number" />
            </div>

            <div class="setting-row" v-else>
              <label>Default value</label>
              <input v-model.number="item.valueDecimal" type="number" step="0.01" />
            </div>

            <div v-if="supportsAffectedAreas(item)" class="setting-row">
              <label>Affected areas</label>
              <div class="checkboxes">
                <label v-for="area in areaOptions" :key="`${item.configKey}-${area}`" class="inline-checkbox">
                  <SmallCheckbox :model-value="isAreaChecked(item, area)" @update:model-value="toggleArea(item, area, $event)" />
                  <span>{{ area }}</span>
                </label>
              </div>
            </div>

            <div class="setting-row">
              <label class="inline-checkbox">
                <SmallCheckbox v-model="item.sellerAccess" />
                <span>Default item for seller panel</span>
              </label>
            </div>

            <footer class="setting-actions">
              <button :disabled="busy" @click="save(item)">
                Save
              </button>
            </footer>
          </article>
        </div>
      </section>
    </div>
  </SectionCard>
</template>

<style scoped>
.settings-layout { display: flex; flex-direction: column; gap: 20px; }
.settings-group h3 { margin: 0 0 12px; font-size: 22px; }
.settings-grid { display: grid; gap: 14px; grid-template-columns: repeat(auto-fill, minmax(320px, 1fr)); }
.setting-card {
  border: 1px solid #ebe3d2;
  border-radius: 14px;
  padding: 16px;
  background: #fff;
  box-shadow: 0 1px 8px rgba(0, 0, 0, 0.04);
  display: flex;
  flex-direction: column;
  gap: 10px;
}
.setting-header { display: flex; justify-content: space-between; gap: 12px; align-items: flex-start; }
.setting-header h4 { margin: 0; font-size: 18px; }
.setting-key { margin: 4px 0 0; font-size: 12px; color: #8f8573; }
.type-badge {
  font-size: 12px;
  padding: 4px 10px;
  border-radius: 99px;
  background: #f7f2e7;
  color: #6f5a23;
  border: 1px solid #e4d5ad;
}
.setting-description { margin: 0; color: #655d50; font-size: 14px; }
.setting-row { display: flex; flex-direction: column; gap: 8px; }
.setting-row input[type="text"],
.setting-row input[type="number"] {
  border: 1px solid #ddd0b7;
  border-radius: 10px;
  min-height: 40px;
  padding: 0 12px;
  font-size: 15px;
}
.inline-toggle, .inline-checkbox { display: inline-flex; align-items: center; gap: 8px; font-size: 15px; }
.checkboxes { display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 8px; }
.setting-actions { margin-top: 4px; display: flex; justify-content: flex-end; }
</style>
