<script setup lang="ts">
import { reactive } from "vue";
import type { ReturnTypeUseMarketplace } from "../../../shared/app/store/useMarketplace";
import SectionCard from "../../../shared/components/SectionCard.vue";

const props = defineProps<{ marketplace: ReturnTypeUseMarketplace }>();
const feeDraft = reactive({
  deliveryFee: props.marketplace.state.value.fees.deliveryFee,
  storageFee: props.marketplace.state.value.fees.storageFee,
  serviceChargePercent: props.marketplace.state.value.fees.serviceChargePercent
});

const sellDraft = reactive({
  mode: props.marketplace.walletSellConfiguration.value.mode,
  lockSeconds: props.marketplace.walletSellConfiguration.value.lockSeconds
});

const saveFees = () => {
  props.marketplace.updateFees(feeDraft.deliveryFee, feeDraft.storageFee, feeDraft.serviceChargePercent);
};

const saveSellConfig = async () => {
  await props.marketplace.saveWalletSellConfiguration(sellDraft.mode, sellDraft.lockSeconds);
};
</script>

<template>
  <SectionCard title="Fees Management">
    <div class="report-actions">
      <label>
        Delivery Fee
        <input v-model.number="feeDraft.deliveryFee" type="number" min="0" step="0.01" />
      </label>
      <label>
        Storage Fee
        <input v-model.number="feeDraft.storageFee" type="number" min="0" step="0.01" />
      </label>
      <label>
        Service Charge (%)
        <input v-model.number="feeDraft.serviceChargePercent" type="number" min="0" step="0.1" />
      </label>
      <button type="button" @click="saveFees">Save Fees</button>
    </div>

    <hr style="margin: 16px 0" />

    <div class="report-actions">
      <label>
        Sell Execution Mode
        <select v-model="sellDraft.mode">
          <option value="locked_30_seconds">Locked price for 30 seconds</option>
          <option value="live_price">Live price execution</option>
        </select>
      </label>
      <label>
        Lock Seconds
        <input v-model.number="sellDraft.lockSeconds" :disabled="sellDraft.mode !== 'locked_30_seconds'" type="number" min="5" max="300" step="1" />
      </label>
      <button type="button" @click="saveSellConfig">Save Sell Configuration</button>
    </div>
  </SectionCard>
</template>
