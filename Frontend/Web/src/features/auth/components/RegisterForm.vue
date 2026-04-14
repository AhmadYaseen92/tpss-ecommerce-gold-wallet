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
      <input v-model="model.password" type="password" placeholder="Password" required />
      <input v-model="model.confirmPassword" type="password" placeholder="Confirm Password" required />
      <input v-model="model.businessName" placeholder="Business Name" required />
      <input v-model="model.idNumber" placeholder="National ID" required />
    </div>
    <button :disabled="loading" type="submit" class="full-btn">Sign Up</button>
    <p class="register-text">Already have an account? <button type="button" class="link-btn" @click="emit('toLogin')">Go to Login</button></p>
  </form>
</template>
