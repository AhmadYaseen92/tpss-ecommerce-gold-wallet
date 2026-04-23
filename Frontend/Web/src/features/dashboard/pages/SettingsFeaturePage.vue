<script setup lang="ts">
import { computed, onMounted, ref } from "vue";
import { postJson } from "../../../shared/services/httpClient";
import SectionCard from "../../../shared/components/SectionCard.vue";
import SmallCheckbox from "../../../shared/components/SmallCheckbox.vue";
import SmallToggle from "../../../shared/components/SmallToggle.vue";
import { fetchSellers } from "../../../shared/services/backendGateway";
import type { ReturnTypeUseMarketplace } from "../../../shared/app/store/useMarketplace";
import type { Seller } from "../../../shared/types/models";

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

interface UpsertSettingItemPayload extends Omit<SettingItem, "valueBool" | "valueInt" | "valueDecimal" | "valueString"> {
  valueBool: boolean | null;
  valueInt: number | null;
  valueDecimal: number | null;
  valueString: string | null;
}

const settings = ref<SettingItem[]>([]);
const sellers = ref<Seller[]>([]);
const busy = ref(false);
const areaOptions = [
  "registration",
  "reset_password",
  "checkout",
  "buy",
  "sell",
  "transfer",
  "gift",
  "pickup",
  "add_bank_account",
  "edit_bank_account",
  "remove_bank_account",
  "add_payment_method",
  "edit_payment_method",
  "remove_payment_method",
  "change_email",
  "change_password",
  "change_mobile_number"
];
const otpChannelOptions = ["whatsapp", "email"];
const initialSnapshots = ref<Record<string, string>>({});

const load = async () => {
  if (!props.marketplace.session.value?.accessToken) return;
  const rows = await postJson<SettingItem[], object>("/api/mobile-app-configurations/list", {}, props.marketplace.session.value.accessToken);
  sellers.value = await fetchSellers(props.marketplace.session.value.accessToken);
  settings.value = rows.map((row) => ({
    ...row,
    valueBool: row.valueType === 2 ? (row.valueBool ?? false) : undefined,
    sellerAccess: !!row.sellerAccess
  }));
  initialSnapshots.value = Object.fromEntries(settings.value.map((item) => [item.configKey, snapshotOf(item)]));
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

const supportsAffectedAreas = (item: SettingItem) =>
  item.configKey.toLowerCase().includes("requiredactions");
const supportsOtpChannelPriority = (item: SettingItem) => item.configKey === "Otp_ChannelPriority";
const usesSellerDropdown = (item: SettingItem) => item.configKey === "MobileRelease_IndividualSellerName";
const hasDefaultValueInput = (item: SettingItem) => item.valueType !== 2 && !supportsAffectedAreas(item) && !supportsOtpChannelPriority(item);

const normalizedValues = (item: SettingItem) => ({
  valueString: item.valueType === 1 ? (item.valueString ?? null) : null,
  valueBool: item.valueType === 2 ? (item.valueBool ?? false) : null,
  valueInt: item.valueType === 3 ? (item.valueInt ?? null) : null,
  valueDecimal: item.valueType === 4 ? (item.valueDecimal ?? null) : null
});

const toUpsertPayload = (item: SettingItem): UpsertSettingItemPayload => ({
  ...item,
  ...normalizedValues(item),
  sellerAccess: !!item.sellerAccess
});

const snapshotOf = (item: SettingItem) => JSON.stringify({
  valueType: item.valueType,
  ...normalizedValues(item),
  sellerAccess: !!item.sellerAccess
});

const dirtyItems = computed(() => settings.value.filter((item) => initialSnapshots.value[item.configKey] !== snapshotOf(item)));
const dirtyCount = computed(() => dirtyItems.value.length);

const saveAll = async () => {
  if (dirtyItems.value.length === 0 || !props.marketplace.session.value?.accessToken) return;
  busy.value = true;
  try {
    for (const item of dirtyItems.value) {
      await postJson<SettingItem, UpsertSettingItemPayload>("/api/mobile-app-configurations/upsert", toUpsertPayload(item), props.marketplace.session.value.accessToken);
      initialSnapshots.value[item.configKey] = snapshotOf(item);
    }
  } finally {
    busy.value = false;
  }
};

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

const selectedOtpChannels = (item: SettingItem) => {
  const raw = item.valueString ?? "";
  return raw
    .split(",")
    .map((x) => x.trim().toLowerCase())
    .filter(Boolean);
};

const isOtpChannelChecked = (item: SettingItem, channel: string) => selectedOtpChannels(item).includes(channel);
const otpDefaultChannel = (item: SettingItem) => selectedOtpChannels(item)[0] ?? "";

const toggleOtpChannel = (item: SettingItem, channel: string, checked: boolean) => {
  const channels = selectedOtpChannels(item);
  if (checked && !channels.includes(channel)) channels.push(channel);
  if (!checked) {
    item.valueString = channels.filter((x) => x !== channel).join(",");
    return;
  }
  item.valueString = channels.join(",");
};

const setOtpDefaultChannel = (item: SettingItem, channel: string, enabled: boolean) => {
  if (!enabled) return;
  const channels = selectedOtpChannels(item);
  if (!channels.includes(channel)) channels.push(channel);
  item.valueString = [channel, ...channels.filter((x) => x !== channel)].join(",");
};
</script>

<template>
  <SectionCard title="System Settings">
    <div class="settings-toolbar">
      <span class="pending-counter">{{ dirtyCount }} pending change(s)</span>
      <button :disabled="busy || dirtyCount === 0" @click="saveAll">
        {{ busy ? "Saving..." : "Save All Changes" }}
      </button>
    </div>
    <div class="settings-layout">
      <section v-for="group in groupedSettings" :key="group.group" class="settings-group">
        <h3>{{ group.group }}</h3>
        <div class="settings-stack">
          <article v-for="item in group.items" :key="item.configKey" class="setting-card">
            <header class="setting-header">
              <div>
                <h4>{{ item.name }}</h4>
                <p class="setting-key">{{ item.configKey }}</p>
              </div>
              <div class="setting-header-right">
                <label v-if="item.valueType === 2" class="inline-toggle">
                  <SmallToggle v-model="item.valueBool" />
                  <span>Enabled</span>
                </label>
              </div>
            </header>

            <p class="setting-description">{{ item.description || "No description provided." }}</p>

            <div class="setting-row" v-if="hasDefaultValueInput(item) && item.valueType === 1 && !usesSellerDropdown(item)">
              <label>Default value</label>
              <input v-model="item.valueString" type="text" />
            </div>

            <div class="setting-row" v-else-if="hasDefaultValueInput(item) && item.valueType === 3">
              <label>Default value</label>
              <input v-model.number="item.valueInt" type="number" />
            </div>

            <div class="setting-row" v-else-if="hasDefaultValueInput(item) && item.valueType === 4">
              <label>Default value</label>
              <input v-model.number="item.valueDecimal" type="number" step="0.01" />
            </div>

            <div v-if="usesSellerDropdown(item)" class="setting-row">
              <label>Default value</label>
              <select v-model="item.valueString">
                <option value="">Select seller</option>
                <option v-for="seller in sellers" :key="seller.id" :value="seller.name">
                  {{ seller.name }}
                </option>
              </select>
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

            <div v-if="supportsOtpChannelPriority(item)" class="setting-row">
              <label>Preferred channels</label>
              <div class="otp-channels">
                <label v-for="channel in otpChannelOptions" :key="`${item.configKey}-${channel}`" class="otp-channel-item">
                  <SmallCheckbox :model-value="isOtpChannelChecked(item, channel)" @update:model-value="toggleOtpChannel(item, channel, $event)" />
                  <span class="channel-name">{{ channel }}</span>
                  <SmallToggle
                    :model-value="otpDefaultChannel(item) === channel"
                    :disabled="!isOtpChannelChecked(item, channel)"
                    @update:model-value="setOtpDefaultChannel(item, channel, $event)"
                  />
                  <span class="default-label">Default</span>
                </label>
              </div>
            </div>
          </article>
        </div>
      </section>
    </div>
  </SectionCard>
</template>

<style scoped>
.settings-layout { display: flex; flex-direction: column; gap: 16px; }
.settings-toolbar {
  display: flex;
  justify-content: flex-end;
  gap: 10px;
  align-items: center;
  margin-bottom: 12px;
}
.pending-counter {
  color: #6f5a23;
  font-weight: 600;
  font-size: 14px;
}
.settings-group h3 { margin: 0 0 10px; font-size: 22px; }
.settings-stack { display: flex; flex-direction: column; gap: 10px; }
.setting-card {
  border: 1px solid #d9d9d9;
  border-radius: 8px;
  padding: 12px 14px;
  background: #f7f7f7;
  display: flex;
  flex-direction: column;
  gap: 8px;
}
.setting-header { display: flex; justify-content: space-between; gap: 12px; align-items: flex-start; }
.setting-header-right { display: inline-flex; align-items: center; gap: 10px; }
.setting-header h4 { margin: 0; font-size: 22px; }
.setting-key { margin: 4px 0 0; font-size: 12px; color: #8f8573; }
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
.setting-row select {
  border: 1px solid #ddd0b7;
  border-radius: 10px;
  min-height: 40px;
  padding: 0 12px;
  font-size: 15px;
  background: #fff;
}
.inline-toggle, .inline-checkbox { display: inline-flex; align-items: center; gap: 8px; font-size: 15px; }
.checkboxes { display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 8px; }
.otp-channels { display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 8px; }
.otp-channel-item { display: inline-flex; align-items: center; gap: 8px; }
.channel-name { text-transform: capitalize; min-width: 80px; }
.default-label { color: #7f755f; font-size: 13px; }
</style>
