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

const saveFees = () => {
  props.marketplace.updateFees(feeDraft.deliveryFee, feeDraft.storageFee, feeDraft.serviceChargePercent);
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
  </SectionCard>
</template>
