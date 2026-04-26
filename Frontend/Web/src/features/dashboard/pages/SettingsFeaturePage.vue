<script setup lang="ts">
import { computed, onMounted, reactive, ref, watch } from "vue";
import { postJson } from "../../../shared/services/httpClient";
import type { ReturnTypeUseMarketplace } from "../../../shared/app/store/useMarketplace";
import Card from "../../../shared/components/ui/Card.vue";
import PageHeader from "../../../shared/components/ui/PageHeader.vue";
import Button from "../../../shared/components/ui/Button.vue";
import Input from "../../../shared/components/ui/Input.vue";
import Select from "../../../shared/components/ui/Select.vue";
import Checkbox from "../../../shared/components/ui/Checkbox.vue";
import LoadingState from "../../../shared/components/ui/LoadingState.vue";
import ResultModal from "../../../shared/components/ui/ResultModal.vue";

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

interface SettingMeta {
  key: string;
  section: "Mobile App" | "Mobile Security" | "OTP Settings" | "Wallet Sell Settings";
  label: string;
  description: string;
  type: "toggle" | "text" | "number" | "select" | "multiselect";
  options?: Array<{ value: string; label: string }>;
}

const settings = ref<SettingItem[]>([]);
const loading = ref(false);
const saving = ref(false);
const errorModalOpen = ref(false);
const errorModalMessage = ref("");
const inlineErrors = reactive<Record<string, string>>({});

const META: SettingMeta[] = [
  { key: "MobileRelease_IsIndividualSeller", section: "Mobile App", label: "Single Seller Mode", description: "Enable this to show only one seller in the mobile app instead of the marketplace.", type: "toggle" },
  { key: "MobileRelease_IndividualSellerName", section: "Mobile App", label: "Single Seller Name", description: "The seller name displayed when Single Seller Mode is enabled.", type: "text" },
  { key: "MobileRelease_MarketWatchEnabled", section: "Mobile App", label: "Show Market Watch", description: "Show or hide the Market Watch tab in the mobile app.", type: "toggle" },
  { key: "MobileSecurity_LoginByPin", section: "Mobile Security", label: "Enable PIN Login", description: "Allow users to unlock the app using a PIN code.", type: "toggle" },
  { key: "MobileSecurity_LoginByBiometric", section: "Mobile Security", label: "Enable Biometric Login", description: "Allow users to unlock the app using fingerprint or Face ID.", type: "toggle" },
  { key: "Otp_RequiredActions", section: "OTP Settings", label: "Actions Requiring OTP", description: "Select which actions require OTP verification.", type: "multiselect", options: [{ value: "buy", label: "Buy" }, { value: "sell", label: "Sell" }, { value: "transfer", label: "Transfer" }, { value: "gift", label: "Gift" }, { value: "pickup", label: "Pickup" }, { value: "withdrawal", label: "Withdrawal" }] },
  { key: "Otp_EnableWhatsapp", section: "OTP Settings", label: "Enable WhatsApp OTP", description: "Allow sending OTP via WhatsApp.", type: "toggle" },
  { key: "Otp_EnableEmail", section: "OTP Settings", label: "Enable Email OTP", description: "Allow sending OTP via Email.", type: "toggle" },
  { key: "Otp_ChannelPriority", section: "OTP Settings", label: "OTP Channel Priority", description: "ترتيب قنوات إرسال OTP حسب الأولوية.", type: "multiselect", options: [{ value: "whatsapp", label: "WhatsApp" }, { value: "email", label: "Email" }] },
  { key: "Otp_ExpirySeconds", section: "OTP Settings", label: "OTP Expiry Time", description: "Time before OTP expires (in seconds).", type: "number" },
  { key: "Otp_ResendCooldownSeconds", section: "OTP Settings", label: "OTP Resend Cooldown", description: "Time before user can request another OTP.", type: "number" },
  { key: "Otp_MaxResendCount", section: "OTP Settings", label: "Max Resend Attempts", description: "Maximum number of OTP resend attempts.", type: "number" },
  { key: "Otp_MaxVerificationAttempts", section: "OTP Settings", label: "Max Verification Attempts", description: "Maximum wrong OTP attempts allowed.", type: "number" },
  { key: "WalletSell_Mode", section: "Wallet Sell Settings", label: "Sell Execution Mode", description: "Defines how sell price is executed (instant or locked).", type: "select", options: [{ value: "live_price", label: "Instant (Live Price)" }, { value: "locked_30_seconds", label: "Locked Price" }] },
  { key: "WalletSell_LockSeconds", section: "Wallet Sell Settings", label: "Price Lock Duration", description: "Time the sell price remains fixed before confirmation expires.", type: "number" }
];

const orderedSections: Array<SettingMeta["section"]> = ["Mobile App", "Mobile Security", "OTP Settings", "Wallet Sell Settings"];

const findSetting = (key: string) => settings.value.find((item) => item.configKey === key);
const getBool = (key: string) => Boolean(findSetting(key)?.valueBool);
const getString = (key: string) => String(findSetting(key)?.valueString ?? "");
const getInt = (key: string) => Number(findSetting(key)?.valueInt ?? 0);

const isSingleSellerMode = computed(() => getBool("MobileRelease_IsIndividualSeller"));
const hasOtpChannel = computed(() => getBool("Otp_EnableWhatsapp") || getBool("Otp_EnableEmail"));

const load = async () => {
  if (!props.marketplace.session.value?.accessToken) return;
  loading.value = true;
  try {
    const allSettings = await postJson<SettingItem[], Record<string, never>>("/api/mobile-app-configurations/list", {}, props.marketplace.session.value.accessToken);
    const keySet = new Set(META.map((x) => x.key));
    settings.value = allSettings.filter((x) => keySet.has(x.configKey));
  } finally {
    loading.value = false;
  }
};

onMounted(load);

watch(
  () => getBool("MobileSecurity_LoginByPin"),
  (pinEnabled) => {
    if (!pinEnabled) {
      const biometric = findSetting("MobileSecurity_LoginByBiometric");
      if (biometric) biometric.valueBool = false;
    }
  }
);

const grouped = computed(() =>
  orderedSections.map((section) => ({
    section,
    items: META.filter((meta) => meta.section === section)
      .map((meta) => ({ meta, item: findSetting(meta.key) }))
      .filter((x) => Boolean(x.item))
  }))
);

const parseMulti = (raw: string | null | undefined) =>
  (raw ?? "").split(",").map((x) => x.trim()).filter(Boolean);

const updateMulti = (item: SettingItem, event: Event) => {
  const selected = Array.from((event.target as HTMLSelectElement).selectedOptions).map((x) => x.value);
  item.valueString = selected.join(",");
};

const isDisabled = (key: string) => {
  if (key === "MobileRelease_IndividualSellerName") return !isSingleSellerMode.value;
  if (key === "Otp_ChannelPriority") return !hasOtpChannel.value;
  if (key === "MobileSecurity_LoginByBiometric") return !getBool("MobileSecurity_LoginByPin");
  return false;
};

const validate = () => {
  Object.keys(inlineErrors).forEach((key) => delete inlineErrors[key]);

  if (isSingleSellerMode.value && !getString("MobileRelease_IndividualSellerName").trim()) {
    inlineErrors.MobileRelease_IndividualSellerName = "Single Seller Name is required when Single Seller Mode is enabled.";
  }

  if (!hasOtpChannel.value) {
    inlineErrors.Otp_EnableWhatsapp = "At least one OTP delivery channel must be enabled.";
    inlineErrors.Otp_EnableEmail = "At least one OTP delivery channel must be enabled.";
  }

  for (const key of ["Otp_ExpirySeconds", "Otp_ResendCooldownSeconds", "Otp_MaxResendCount", "Otp_MaxVerificationAttempts", "WalletSell_LockSeconds"]) {
    const value = getInt(key);
    if (!Number.isInteger(value) || value <= 0) {
      inlineErrors[key] = "Value must be greater than 0.";
    }
  }

  return Object.keys(inlineErrors).length === 0;
};

const saveAll = async () => {
  if (!props.marketplace.session.value?.accessToken) return;

  if (!validate()) {
    errorModalMessage.value = Object.values(inlineErrors)[0] ?? "Please fix validation errors before saving.";
    errorModalOpen.value = true;
    return;
  }

  saving.value = true;
  try {
    for (const meta of META) {
      const item = findSetting(meta.key);
      if (!item) continue;
      await postJson("/api/mobile-app-configurations/upsert", item, props.marketplace.session.value.accessToken);
    }
  } catch (error) {
    errorModalMessage.value = error instanceof Error ? error.message : "Unable to save settings.";
    errorModalOpen.value = true;
  } finally {
    saving.value = false;
  }
};
</script>

<template>
  <section class="dashboard-screen">
    <PageHeader title="System Settings" subtitle="Manage all application configurations and behavior.">
      <Button :loading="saving" @click="saveAll">Save All</Button>
    </PageHeader>

    <ResultModal :open="errorModalOpen" title="Validation Error" :message="errorModalMessage" tone="error" @close="errorModalOpen = false" />
    <LoadingState v-if="loading" text="Loading settings..." />

    <template v-else>
      <Card v-for="section in grouped" :key="section.section" :title="section.section">
        <div class="settings-grid">
          <div
            v-for="{ meta, item } in section.items"
            :key="meta.key"
            class="ui-card"
            :style="{ opacity: isDisabled(meta.key) ? '0.55' : '1' }"
          >
            <div class="setting-header">
              <div>
                <strong>{{ meta.label }}</strong>
                <p class="hint-text">{{ meta.description }}</p>
                <small class="hint-text">{{ meta.key }}</small>
              </div>
              <Checkbox v-if="meta.type === 'toggle'" v-model="item!.valueBool" label="Enabled" :disabled="isDisabled(meta.key)" />
            </div>

            <Input
              v-if="meta.type === 'text'"
              v-model="item!.valueString"
              placeholder="Enter value"
              :disabled="isDisabled(meta.key)"
            />
            <Input
              v-if="meta.type === 'number'"
              v-model="item!.valueInt"
              type="number"
              min="1"
              step="1"
              :disabled="isDisabled(meta.key)"
            />
            <Select
              v-if="meta.type === 'select'"
              v-model="item!.valueString"
              :disabled="isDisabled(meta.key)"
            >
              <option v-for="option in meta.options" :key="option.value" :value="option.value">{{ option.label }}</option>
            </Select>
            <select
              v-if="meta.type === 'multiselect'"
              class="ui-select"
              multiple
              :value="parseMulti(item!.valueString)"
              :disabled="isDisabled(meta.key)"
              @change="updateMulti(item!, $event)"
            >
              <option v-for="option in meta.options" :key="option.value" :value="option.value">{{ option.label }}</option>
            </select>

            <small v-if="inlineErrors[meta.key]" class="ui-form-error">{{ inlineErrors[meta.key] }}</small>
          </div>
        </div>
      </Card>
    </template>
  </section>
</template>
