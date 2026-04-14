<script setup lang="ts">
import type { RegisterFormModel } from "../types/authTypes";

defineProps<{ model: RegisterFormModel; loading: boolean }>();
const emit = defineEmits<{ submit: []; toLogin: [] }>();
</script>

<template>
  <form class="register-form" @submit.prevent="emit('submit')">
    <div class="grid-two">
      <input v-model="model.fullName" placeholder="Full Name" required />
      <input v-model="model.email" type="email" placeholder="Email" required />
      <input v-model="model.phoneNumber" placeholder="Contact Phone" required />
      <input v-model="model.password" type="password" placeholder="Password" required />
      <input v-model="model.confirmPassword" type="password" placeholder="Confirm Password" required />
      <input v-model="model.country" placeholder="Country" required />
      <input v-model="model.city" placeholder="City" required />
      <input v-model="model.street" placeholder="Street" required />
      <input v-model="model.buildingNumber" placeholder="Building Number" required />
      <input v-model="model.postalCode" placeholder="Postal Code" required />
      <input v-model="model.companyName" placeholder="Company Name" required />
      <input v-model="model.tradeLicenseNumber" placeholder="Trade License Number" required />
      <input v-model="model.vatNumber" placeholder="VAT Number" required />
      <input v-model="model.nationalIdNumber" placeholder="National ID Number" required />
      <input v-model="model.bankName" placeholder="Bank Name" required />
      <input v-model="model.iban" placeholder="IBAN" required />
      <input v-model="model.accountHolderName" placeholder="Account Holder Name" required />
      <input v-model="model.nationalIdFrontPath" placeholder="National ID Front Path" required />
      <input v-model="model.nationalIdBackPath" placeholder="National ID Back Path" required />
      <input v-model="model.tradeLicensePath" placeholder="Trade License Path" required />
    </div>
    <button :disabled="loading" type="submit" class="full-btn">Sign Up</button>
    <p class="register-text">Already have an account? <button type="button" class="link-btn" @click="emit('toLogin')">Go to Login</button></p>
  </form>
</template>
