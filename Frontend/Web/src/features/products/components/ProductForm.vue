<script setup lang="ts">
import { computed, onBeforeUnmount, ref, watch } from "vue";
import FormField from "../../../shared/components/ui/FormField.vue";
import Input from "../../../shared/components/ui/Input.vue";
import Select from "../../../shared/components/ui/Select.vue";
import Checkbox from "../../../shared/components/ui/Checkbox.vue";
import Button from "../../../shared/components/ui/Button.vue";
import Card from "../../../shared/components/ui/Card.vue";
import type { ProductFormPayload } from "../../../shared/services/backendGateway";
import type { MarketPriceConfigDto, EnumItemDto } from "../../../shared/types/apiTypes";
import { PRODUCT_FORMS_BY_MATERIAL, PRODUCT_FORM_OPTIONS } from "../../../shared/constants/productTaxonomy";

const props = withDefaults(
  defineProps<{
    model: ProductFormPayload;
    categories: EnumItemDto[];
    units: EnumItemDto[];
    errors: Record<string, string>;
    marketPrices?: MarketPriceConfigDto;
  }>(),
  {
    marketPrices: () => ({
      goldPerOunce: 0,
      silverPerOunce: 0,
      diamondPerCarat: 0,
    }),
  }
);

const emit = defineEmits<{
  save: [];
  image: [event: Event];
}>();

const tab = ref<"basics" | "pricing" | "offer" | "stock" | "fees">("basics");
const lastGoldKarat = ref(3);
const lastSilverPurity = ref(0.999);
const imagePreviewUrl = ref("");

const isAuto = computed(() => Number(props.model.pricingMode) === 1);
const isGold = computed(() => Number(props.model.materialType) === 1);
const isSilver = computed(() => Number(props.model.materialType) === 2);
const isDiamond = computed(() => Number(props.model.materialType) === 3);
const availableFormOptions = computed(() => {
  const materialKey = isGold.value ? "gold" : isSilver.value ? "silver" : "diamond";
  const allowed = new Set(PRODUCT_FORMS_BY_MATERIAL[materialKey] ?? PRODUCT_FORMS_BY_MATERIAL.all);
  return PRODUCT_FORM_OPTIONS.filter((option) => option.value !== "all" && allowed.has(option.value));
});

const resetCoreProductInfoByMaterial = (nextMaterial: number) => {
  // Reset Core Product Info fields whenever material type changes.
  props.model.formType = 1;
  props.model.weightValue = 0;
  props.model.pricingMode = 1;
  props.model.availableStock = 0;

  // Reset pricing / offer values tied to core info.
  props.model.manualSellPrice = 0;
  props.model.offerType = 0;
  props.model.offerPercent = 0;
  props.model.offerNewPrice = 0;

  if (nextMaterial === 1) {
    props.model.purityKarat = lastGoldKarat.value || 3;
    props.model.purityFactor = karatFactorMap[props.model.purityKarat] ?? 0.875;
    return;
  }

  if (nextMaterial === 2) {
    props.model.purityKarat = 0;
    props.model.purityFactor = lastSilverPurity.value;
    return;
  }

  // Diamond
  props.model.formType = 1; // Jewelry only
  props.model.purityKarat = 0;
  props.model.purityFactor = 1;
};

watch(
  () => Number(props.model.materialType),
  () => {
    if (isDiamond.value && [2, 3].includes(Number(props.model.formType))) {
      props.model.formType = 1;
    }
  },
  { immediate: true }
);

const karatFactorMap: Record<number, number> = {
  0: 1,
  1: 1,
  2: 0.916,
  3: 0.875,
  4: 0.75,
  5: 0.585,
};

watch(
  () => [Number(props.model.materialType), Number(props.model.purityKarat)],
  () => {
    if (isDiamond.value) {
      if (props.model.purityKarat > 0) {
        lastGoldKarat.value = props.model.purityKarat;
      }
      props.model.purityKarat = 0;
      props.model.purityFactor = 1;
      return;
    }

    if (isGold.value) {
      if (props.model.purityKarat === 0) props.model.purityKarat = lastGoldKarat.value || 3;
      lastGoldKarat.value = props.model.purityKarat;
      props.model.purityFactor = karatFactorMap[props.model.purityKarat] ?? 1;
      return;
    }

    if (isSilver.value) {
      if (props.model.purityFactor > 0) {
        lastSilverPurity.value = Number(props.model.purityFactor);
      }
      if (![0.999, 0.925].includes(Number(props.model.purityFactor))) {
        props.model.purityFactor = lastSilverPurity.value;
      }
      props.model.purityKarat = 0;
    }
  },
  { immediate: true }
);

watch(
  () => Number(props.model.materialType),
  (next, prev) => {
    if (next === prev || prev == null) return;
    resetCoreProductInfoByMaterial(next);
  }
);

watch(
  () => props.model.purityKarat,
  (next) => {
    if (isGold.value && next > 0) {
      lastGoldKarat.value = next;
    }
  }
);

watch(
  () => props.model.purityFactor,
  (next) => {
    if (isSilver.value && [0.999, 0.925].includes(Number(next))) {
      lastSilverPurity.value = Number(next);
    }
  }
);

const offerEnabled = computed({
  get: () => props.model.offerType !== 0,
  set: (value: boolean) => {
    props.model.offerType = value ? 1 : 0;

    if (!value) {
      props.model.offerPercent = 0;
      props.model.offerNewPrice = 0;
    }
  },
});

const selectedMarketPrice = computed(() => {
  if (isGold.value) return Number(props.marketPrices.goldPerOunce || props.model.baseMarketPrice || 0);
  if (isSilver.value) return Number(props.marketPrices.silverPerOunce || props.model.baseMarketPrice || 0);
  return Number(props.marketPrices.diamondPerCarat || props.model.baseMarketPrice || 0);
});

const autoCalculatedPrice = computed(() => {
  const weight = Number(props.model.weightValue || 0);
  const market = selectedMarketPrice.value;
  const purity = Number(props.model.purityFactor || 1);

  if (weight <= 0 || market <= 0) return 0;

  if (isDiamond.value) {
    return (weight / 0.2) * market;
  }

  return (weight / 31.1035) * market * purity;
});

const finalPrice = computed(() => {
  const base = isAuto.value
    ? autoCalculatedPrice.value
    : Number(props.model.manualSellPrice || 0);

  if (props.model.offerType === 1 && Number(props.model.offerPercent || 0) > 0) {
    return base * (1 - Number(props.model.offerPercent || 0) / 100);
  }

  if (props.model.offerType === 2 && Number(props.model.offerNewPrice || 0) > 0) {
    return Number(props.model.offerNewPrice || 0);
  }

  return Number.isFinite(base) ? base : 0;
});

watch(
  selectedMarketPrice,
  (next) => {
    props.model.baseMarketPrice = Number(next || 0);
  },
  { immediate: true }
);

watch(
  () => props.model.imageFile,
  (file) => {
    if (imagePreviewUrl.value.startsWith("blob:")) {
      URL.revokeObjectURL(imagePreviewUrl.value);
    }
    imagePreviewUrl.value = file ? URL.createObjectURL(file) : "";
  },
  { immediate: true }
);

onBeforeUnmount(() => {
  if (imagePreviewUrl.value.startsWith("blob:")) {
    URL.revokeObjectURL(imagePreviewUrl.value);
  }
});
</script>

<template>
  <section class="dashboard-screen">
    <Card title="Core Product Info">
      <div class="form-grid-two">
        <FormField label="Material Type" required :error="errors.materialType">
          <Select
            :model-value="model.materialType"
            @update:model-value="model.materialType = Number($event)"
          >
            <option :value="1">Gold</option>
            <option :value="2">Silver</option>
            <option :value="3">Diamond</option>
          </Select>
        </FormField>

        <FormField label="Product Form" required :error="errors.formType">
          <Select
            :model-value="model.formType"
            @update:model-value="model.formType = Number($event)"
          >
            <option
              v-for="option in availableFormOptions"
              :key="option.value"
              :value="option.value === 'jewelry' ? 1 : option.value === 'coin' ? 2 : 3"
            >
              {{ option.label }}
            </option>
          </Select>
        </FormField>

        <FormField label="Weight (grams)" required hint="Weight is always entered in grams." :error="errors.weightValue">
          <Input type="number" min="0" step="0.01" v-model="model.weightValue" />
        </FormField>

        <FormField v-if="isGold" label="Purity / Karat" :error="errors.purityKarat">
          <Select v-model="model.purityKarat">
            <option :value="1">24K</option>
            <option :value="2">22K</option>
            <option :value="3">21K</option>
            <option :value="4">18K</option>
            <option :value="5">14K</option>
          </Select>
        </FormField>

        <FormField v-if="isSilver" label="Silver Purity" :error="errors.purityFactor">
          <Select
            :model-value="model.purityFactor"
            @update:model-value="model.purityFactor = Number($event)"
          >
            <option :value="0.999">999</option>
            <option :value="0.925">925</option>
          </Select>
        </FormField>

        <FormField v-if="!isDiamond" label="Purity Factor">
          <Input :model-value="model.purityFactor" readonly />
        </FormField>

        <FormField v-else label="Purity Factor">
          <Input :model-value="1" readonly />
        </FormField>

        <FormField label="Pricing Mode">
          <Select
            :model-value="model.pricingMode"
            @update:model-value="model.pricingMode = Number($event)"
          >
            <option :value="1">Auto</option>
            <option :value="2">Manual</option>
          </Select>
        </FormField>

        <FormField label="Available Stock" required :error="errors.availableStock">
          <Input type="number" min="0" v-model="model.availableStock" />
        </FormField>

        <FormField label="Final Sell Price" class="field-full">
          <Input :model-value="finalPrice.toFixed(2)" readonly />
        </FormField>
      </div>
    </Card>

    <div class="ui-tabs">
      <button type="button" class="ui-tab" :class="{ active: tab === 'basics' }" @click="tab = 'basics'">
        Basics
      </button>
      <button type="button" class="ui-tab" :class="{ active: tab === 'pricing' }" @click="tab = 'pricing'">
        Pricing
      </button>
      <button type="button" class="ui-tab" :class="{ active: tab === 'offer' }" @click="tab = 'offer'">
        Offer
      </button>
      <button type="button" class="ui-tab" :class="{ active: tab === 'stock' }" @click="tab = 'stock'">
        Stock
      </button>
      <button type="button" class="ui-tab" :class="{ active: tab === 'fees' }" @click="tab = 'fees'">
        Product Fee
      </button>
    </div>

    <Card v-if="tab === 'basics'" title="Product Basics">
      <div class="ui-row-inline">
        <img
          v-if="imagePreviewUrl || model.existingImageUrl"
          :src="imagePreviewUrl || model.existingImageUrl"
          alt="Product preview"
          class="product-thumb product-thumb--lg"
        />
        <span v-else class="product-thumb-placeholder product-thumb-placeholder--lg">No image</span>
      </div>

      <FormField label="Name" required :error="errors.name">
        <Input v-model="model.name" />
      </FormField>

      <FormField label="SKU" required :error="errors.sku">
        <Input v-model="model.sku" />
      </FormField>

      <FormField label="Description" required :error="errors.description">
        <textarea class="ui-input" v-model="model.description"></textarea>
      </FormField>

      <FormField label="Image">
        <input type="file" accept="image/*" @change="emit('image', $event)" />
      </FormField>
    </Card>

    <Card v-if="tab === 'pricing'" title="Pricing">
      <FormField v-if="!isAuto" label="Manual Sell Price" :error="errors.manualSellPrice">
        <Input type="number" min="0" step="0.01" v-model="model.manualSellPrice" />
      </FormField>

      <div v-else class="ui-state">
        Auto price uses selected seller market price, weight in grams, and purity factor.
        <br />
        Market source value: <strong>{{ selectedMarketPrice.toFixed(2) }}</strong>
        <br />
        Auto calculated price: <strong>{{ autoCalculatedPrice.toFixed(2) }}</strong>
      </div>
    </Card>

    <Card v-if="tab === 'offer'" title="Offer">
      <Checkbox v-model="offerEnabled" label="Enable Offer" />

      <template v-if="offerEnabled">
        <FormField label="Offer Type">
          <Select v-model="model.offerType">
            <option :value="1">Percent Based</option>
            <option :value="2">Fixed Price</option>
          </Select>
        </FormField>

        <FormField v-if="model.offerType === 1" label="Offer Percent" :error="errors.offerPercent">
          <Input type="number" min="0" max="100" step="0.01" v-model="model.offerPercent" />
        </FormField>

        <FormField v-if="model.offerType === 2" label="Offer New Price" :error="errors.offerNewPrice">
          <Input type="number" min="0" step="0.01" v-model="model.offerNewPrice" />
        </FormField>
      </template>
    </Card>

    <Card v-if="tab === 'stock'" title="Inventory & Status">
      <FormField label="Available Stock" required :error="errors.availableStock">
        <Input type="number" min="0" v-model="model.availableStock" />
      </FormField>

      <Checkbox v-model="model.isActive" label="Active Product" />
    </Card>

    <Card v-if="tab === 'fees'" title="Product Fee">
      <slot name="fees">
        <div class="ui-state">Fee settings unavailable.</div>
      </slot>
    </Card>

    <div class="ui-row-actions">
      <Button @click="emit('save')">Save Product</Button>
    </div>
  </section>
</template>
