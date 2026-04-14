<script setup lang="ts">
import type { ProductEnumItem } from "../types/productTypes";
import type { ProductFormPayload } from "../../../shared/services/backendGateway";

defineProps<{ model: ProductFormPayload; categories: ProductEnumItem[]; units: ProductEnumItem[] }>();
const emit = defineEmits<{ save: []; image: [event: Event] }>();
</script>

<template>
  <div class="grid-two form-grid-two">
    <input v-model="model.name" placeholder="Name" required />
    <input v-model="model.sku" placeholder="Sku" required />
    <input v-model="model.description" placeholder="Description" required />
    <input type="file" @change="emit('image', $event)" />
    <select v-model.number="model.category"><option v-for="c in categories" :key="c.value" :value="c.value">{{ c.name }}</option></select>
    <input v-model.number="model.weightValue" type="number" placeholder="WeightValue" />
    <select v-model.number="model.weightUnit"><option v-for="u in units" :key="u.value" :value="u.value">{{ u.name }}</option></select>
    <input v-model.number="model.price" type="number" placeholder="Price" />
    <input v-model.number="model.availableStock" type="number" placeholder="AvailableStock" />
    <label class="checkbox-line"><input v-model="model.isActive" type="checkbox" /> IsActive</label>
  </div>
  <button @click="emit('save')">Save</button>
</template>
