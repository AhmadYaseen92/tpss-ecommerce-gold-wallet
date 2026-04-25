<script setup lang="ts">
import { computed } from "vue";
import type { ProductListItem } from "../types/productTypes";

const props = defineProps<{ product: ProductListItem | null }>();

const pricingSummary = computed(() => {
  if (!props.product) return "—";
  const mode = props.product.pricingMode || "Unknown";
  return `${mode} pricing • ${props.product.materialType || "Material"} • ${props.product.formType || "Form"}`;
});

const formatMoney = (value: number) => Number(value || 0).toFixed(2);
</script>

<template>
  <div class="product-details" v-if="product">
    <div class="hero-card">
      <img v-if="product.imageUrl" :src="product.imageUrl" :alt="product.name" class="detail-image" />
      <div v-else class="detail-image placeholder">No image</div>
      <div class="hero-content">
        <h3>{{ product.name }}</h3>
        <p class="muted">{{ pricingSummary }}</p>
        <div class="chips">
          <span class="chip">SKU: {{ product.sku }}</span>
          <span class="chip">{{ product.isActive ? 'Active' : 'Inactive' }}</span>
          <span class="chip">Stock: {{ product.availableStock }}</span>
        </div>
      </div>
    </div>

    <div class="detail-grid">
      <section class="detail-card">
        <h4>Basics</h4>
        <p><strong>Description:</strong> {{ product.description || "—" }}</p>
        <p><strong>Category:</strong> {{ product.category || "—" }}</p>
        <p><strong>Display Label:</strong> {{ product.displayCategoryLabel || "—" }}</p>
        <p><strong>Seller ID:</strong> {{ product.sellerId }}</p>
      </section>

      <section class="detail-card">
        <h4>Material & Weight</h4>
        <p><strong>Material Type:</strong> {{ product.materialType || "—" }}</p>
        <p><strong>Form Type:</strong> {{ product.formType || "—" }}</p>
        <p><strong>Purity Karat:</strong> {{ product.purityKarat || "—" }}</p>
        <p><strong>Purity Factor:</strong> {{ product.purityFactor }}</p>
        <p><strong>Weight:</strong> {{ product.weightValue }} {{ product.weightUnit }}</p>
      </section>

      <section class="detail-card">
        <h4>Pricing</h4>
        <p><strong>Pricing Mode:</strong> {{ product.pricingMode || "—" }}</p>
        <p><strong>Base Market Price:</strong> {{ formatMoney(product.baseMarketPrice) }}</p>
        <p><strong>Manual Sell Price:</strong> {{ formatMoney(product.manualSellPrice) }}</p>
      </section>

      <section class="detail-card">
        <h4>Offer & Final</h4>
        <p><strong>Offer Type:</strong> {{ product.offerType || "None" }}</p>
        <p><strong>Offer Percent:</strong> {{ product.offerPercent }}%</p>
        <p><strong>Offer New Price:</strong> {{ formatMoney(product.offerNewPrice) }}</p>
        <p><strong>Final Sell Price:</strong> {{ formatMoney(product.sellPrice) }}</p>
        <p><strong>Image URL:</strong> <span class="url-value">{{ product.imageUrl || "—" }}</span></p>
      </section>
    </div>
  </div>
</template>

<style scoped>
.product-details {
  display: flex;
  flex-direction: column;
  gap: 14px;
}

.hero-card {
  display: grid;
  grid-template-columns: 180px 1fr;
  gap: 12px;
  border: 1px solid #e4e4e7;
  border-radius: 12px;
  padding: 12px;
  background: #fff;
}

.detail-image {
  width: 180px;
  height: 180px;
  object-fit: cover;
  border-radius: 12px;
  border: 1px solid #d4d4d8;
}

.placeholder {
  display: flex;
  align-items: center;
  justify-content: center;
  color: #71717a;
}

.hero-content h3 {
  margin: 0 0 6px;
}

.muted {
  color: #64748b;
  margin: 0 0 8px;
}

.chips {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

.chip {
  border: 1px solid #d4d4d8;
  border-radius: 999px;
  padding: 4px 10px;
  font-size: 12px;
  background: #fafafa;
}

.detail-grid {
  display: grid;
  grid-template-columns: repeat(2, minmax(240px, 1fr));
  gap: 12px;
}

.detail-card {
  border: 1px solid #e4e4e7;
  border-radius: 12px;
  padding: 12px;
  background: #fff;
}

.detail-card h4 {
  margin: 0 0 8px;
}

.detail-card p {
  margin: 6px 0;
}

.url-value {
  word-break: break-all;
}

@media (max-width: 900px) {
  .hero-card {
    grid-template-columns: 1fr;
  }

  .detail-image {
    width: 100%;
    max-width: 260px;
  }

  .detail-grid {
    grid-template-columns: 1fr;
  }
}
</style>
