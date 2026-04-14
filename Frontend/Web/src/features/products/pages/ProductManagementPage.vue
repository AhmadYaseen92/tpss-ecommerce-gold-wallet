<script setup lang="ts">
import type { ProductManagementDto, EnumItemDto } from "../../../shared/types/apiTypes";
import type { ProductFormPayload } from "../../../shared/services/backendGateway";

defineProps<{
  role: "admin" | "seller";
  productError: string;
  productPage: "list" | "add" | "edit" | "details";
  productRouteId: number | null;
  managedProducts: ProductManagementDto[];
  selectedProduct: ProductManagementDto | null;
  productForm: ProductFormPayload;
  categories: EnumItemDto[];
  weightUnits: EnumItemDto[];
}>();

const emit = defineEmits<{
  add: [];
  details: [product: ProductManagementDto];
  edit: [product: ProductManagementDto];
  toggle: [product: ProductManagementDto];
  delete: [id: number];
  back: [];
  save: [];
  image: [event: Event];
}>();
</script>

<template>
  <section>
    <p v-if="productError" class="error-text">{{ productError }}</p>
    <div class="report-actions" v-if="role === 'seller'"><button @click="emit('add')">Add Product</button></div>

    <div v-if="productPage === 'list'">
      <table>
        <thead><tr><th>ID</th><th>Name</th><th>SKU</th><th>Category</th><th>Price</th><th>Stock</th><th>Active</th><th>CreatedAtUtc</th><th>UpdatedAtUtc</th><th>Actions</th></tr></thead>
        <tbody>
          <tr v-for="product in managedProducts" :key="product.id" class="clickable-row" @click="emit('details', product)">
            <td>{{ product.id }}</td><td>{{ product.name }}</td><td>{{ product.sku }}</td><td>{{ product.category }}</td><td>{{ product.price }}</td><td>{{ product.availableStock }}</td><td>{{ product.isActive ? 'Yes' : 'No' }}</td><td>-</td><td>-</td>
            <td>
              <button @click.stop="emit('edit', product)">Edit</button>
              <button class="ghost" @click.stop="emit('toggle', product)">{{ product.isActive ? 'Deactivate' : 'Activate' }}</button>
              <button class="danger" @click.stop="emit('delete', product.id)">Delete</button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>

    <div v-else-if="productPage === 'details'" class="product-details">
      <h4>Product Details #{{ selectedProduct?.id ?? productRouteId }}</h4>
      <p v-if="!selectedProduct">Unable to load this product.</p>
      <template v-else>
        <p><strong>Name:</strong> {{ selectedProduct.name }}</p><p><strong>SKU:</strong> {{ selectedProduct.sku }}</p><p><strong>Description:</strong> {{ selectedProduct.description }}</p>
      </template>
      <button class="ghost" @click="emit('back')">Back to list</button>
    </div>

    <div v-else class="modal-form product-form vertical-form product-form-contrast">
      <h3>{{ productPage === 'edit' ? 'Edit Product' : 'Add Product' }}</h3>
      <div class="grid-two form-grid-two">
        <input v-model="productForm.name" placeholder="Product Name *" required />
        <input v-model="productForm.sku" placeholder="SKU *" required />
        <input type="file" accept="image/*" @change="emit('image', $event)" />
        <input v-model.number="productForm.price" type="number" min="0.01" step="0.01" placeholder="Price *" required />
        <select v-model.number="productForm.category"><option v-for="item in categories" :key="item.value" :value="item.value">{{ item.name }}</option></select>
        <input v-model.number="productForm.availableStock" type="number" min="0" step="1" placeholder="Available Stock *" required />
        <input v-model.number="productForm.weightValue" type="number" min="0.01" step="0.01" placeholder="Weight Value *" required />
        <select v-model.number="productForm.weightUnit"><option v-for="item in weightUnits" :key="item.value" :value="item.value">{{ item.name }}</option></select>
        <input class="field-full" v-model="productForm.description" placeholder="Description *" required />
        <label class="field-full checkbox-line"><input v-model="productForm.isActive" type="checkbox" /> Is Active</label>
      </div>
      <div class="report-actions"><button @click="emit('save')">Save</button><button class="ghost" @click="emit('back')">Cancel</button></div>
    </div>
  </section>
</template>
