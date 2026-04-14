<script setup lang="ts">
import RegisterForm from "../components/RegisterForm.vue";
import type { RegisterFormModel } from "../types/authTypes";

defineProps<{ model: RegisterFormModel; loading: boolean; title?: string }>();
const emit = defineEmits<{ submit: []; toLogin: [] }>();
</script>

<template>
  <section class="login-page">
    <div class="auth-card large">
      <h1>{{ title ?? 'Create Seller Account' }}</h1>
      <p>Register seller account with KYC details and wait for admin approval.</p>
      <RegisterForm :model="model" :loading="loading" @submit="emit('submit')" @to-login="emit('toLogin')" />
    </div>
  </section>
</template>
