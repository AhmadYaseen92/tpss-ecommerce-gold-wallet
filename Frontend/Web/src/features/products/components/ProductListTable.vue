<script setup lang="ts">
import type { ProductListItem } from "../types/productTypes";

defineProps<{ products: ProductListItem[] }>();
const emit = defineEmits<{ view: [product: ProductListItem]; edit: [product: ProductListItem]; toggle: [product: ProductListItem] }>();
</script>

<template>
  <table>
    <thead>
      <tr>
        <th>Name</th><th>Sku</th><th>Category</th><th>Weight</th><th>Price</th><th>AvailableStock</th><th>IsActive</th><th>Actions</th>
      </tr>
    </thead>
    <tbody>
      <tr v-for="p in products" :key="p.id">
        <td>{{ p.name }}</td>
        <td>{{ p.sku }}</td>
        <td>{{ p.category }}</td>
        <td>{{ p.weightValue }} {{ p.weightUnit }}</td>
        <td>{{ p.price }}</td>
        <td>{{ p.availableStock }}</td>
        <td>{{ p.isActive }}</td>
        <td>
          <button @click="emit('view', p)">View</button>
          <button @click="emit('edit', p)">Edit</button>
          <button class="ghost" @click="emit('toggle', p)">{{ p.isActive ? 'Deactivate' : 'Activate' }}</button>
        </td>
      </tr>
    </tbody>
  </table>
</template>
