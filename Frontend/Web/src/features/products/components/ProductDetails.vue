<script setup lang="ts">
import Card from "../../../shared/components/ui/Card.vue";
import FormField from "../../../shared/components/ui/FormField.vue";
import StatusBadge from "../../../shared/components/ui/StatusBadge.vue";
import type { ProductManagementDto } from "../../../shared/types/apiTypes";

defineProps<{ product: ProductManagementDto | null }>();

const formatMoney = (value: number) => Number(value || 0).toFixed(2);
const enumLabel = (value: string | number | null | undefined, map: Record<string, string>) => {
  if (value == null) return "—";
  const text = String(value);
  return map[text] ?? map[text.toLowerCase()] ?? text;
};

const materialLabelMap: Record<string, string> = {
  "1": "Gold",
  "2": "Silver",
  "3": "Diamond",
  gold: "Gold",
  silver: "Silver",
  diamond: "Diamond"
};

const formLabelMap: Record<string, string> = {
  "1": "Jewelry",
  "2": "Coin",
  "3": "Bar",
  jewelry: "Jewelry",
  coin: "Coin",
  bar: "Bar",
};

const pricingModeLabelMap: Record<string, string> = {
  "1": "Auto",
  "2": "Manual",
  auto: "Auto",
  manual: "Manual"
};

const purityLabelMap: Record<string, string> = {
  "1": "24K",
  "2": "22K",
  "3": "21K",
  "4": "18K",
  "5": "14K",
  "0": "N/A"
};

const offerTypeLabelMap: Record<string, string> = {
  "0": "None",
  "1": "Percent Based",
  "2": "Fixed Price"
};
</script>

<template>
  <div v-if="product" class="dashboard-screen">
    <Card title="Basic Info">
      <div class="product-detail-hero">
        <img v-if="product.imageUrl" :src="product.imageUrl" :alt="product.name" class="product-detail-image" />
        <div v-else class="product-detail-image product-detail-placeholder">No image available</div>
        <video v-if="product.videoUrl" :src="product.videoUrl" controls class="product-detail-image" />

        <div class="product-detail-grid">
          <FormField label="Name"><div>{{ product.name }}</div></FormField>
          <FormField label="SKU"><div>{{ product.sku }}</div></FormField>
          <FormField label="Category"><div>{{ product.category || '—' }}</div></FormField>
          <FormField label="Status"><StatusBadge :status="product.isActive ? 'Active' : 'Inactive'" /></FormField>
          <FormField label="Description" class="field-full">
            <div>{{ product.description || '—' }}</div>
          </FormField>
        </div>
      </div>
    </Card>

    <div class="dashboard-bottom-grid">
      <Card title="Seller Info">
        <div class="product-detail-grid">
          <FormField label="Seller Name"><div>{{ product.sellerName || '—' }}</div></FormField>
          <FormField label="Seller ID"><div>{{ product.sellerId }}</div></FormField>
        </div>
      </Card>

      <Card title="Material & Weight">
        <div class="product-detail-grid">
          <FormField label="Material Type"><div>{{ enumLabel(product.materialType, materialLabelMap) }}</div></FormField>
          <FormField label="Product Form"><div>{{ enumLabel(product.formType, formLabelMap) }}</div></FormField>
          <FormField label="Purity / Karat"><div>{{ enumLabel(product.purityKarat, purityLabelMap) }}</div></FormField>
          <FormField label="Purity Factor"><div>{{ product.purityFactor }}</div></FormField>
          <FormField label="Weight (grams)"><div>{{ product.weightValue }} g</div></FormField>
        </div>
      </Card>

      <Card title="Pricing">
        <div class="product-detail-grid">
          <FormField label="Pricing Mode"><div>{{ enumLabel(product.pricingMode, pricingModeLabelMap) }}</div></FormField>
          <FormField label="Base Market Price"><div>{{ formatMoney(product.baseMarketPrice) }}</div></FormField>
          <FormField label="Auto Price"><div>{{ formatMoney(product.autoPrice) }}</div></FormField>
          <FormField label="Fixed Price"><div>{{ formatMoney(product.fixedPrice) }}</div></FormField>
          <FormField label="Sell Price"><div>{{ formatMoney(product.sellPrice) }}</div></FormField>
        </div>
      </Card>

      <Card title="Offer">
        <div class="product-detail-grid">
          <FormField label="Offer Type"><div>{{ enumLabel(product.offerType, offerTypeLabelMap) }}</div></FormField>
          <FormField label="Offer Percent"><div>{{ product.offerPercent }}%</div></FormField>
          <FormField label="Offer New Price"><div>{{ formatMoney(product.offerNewPrice) }}</div></FormField>
          <FormField label="Has Offer"><div>{{ product.isHasOffer ? 'Yes' : 'No' }}</div></FormField>
        </div>
      </Card>

      <Card title="Inventory">
        <div class="product-detail-grid">
          <FormField label="Available Stock"><div>{{ product.availableStock }}</div></FormField>
        </div>
      </Card>
    </div>
  </div>
</template>
