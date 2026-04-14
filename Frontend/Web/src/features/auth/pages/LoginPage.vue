<script setup lang="ts">
import LoginForm from "../components/LoginForm.vue";
import type { LoginFormModel } from "../types/authTypes";

defineProps<{ model: LoginFormModel; loading: boolean; title?: string }>();
const emit = defineEmits<{ submit: []; forgot: []; toRegister: [] }>();
</script>

<template>
  <section class="login-page">
    <div class="auth-card large">
      <h1>{{ title ?? 'Welcome Back' }}</h1>
      <p>Sign in to continue to your dashboard.</p>
      <LoginForm :model="model" :loading="loading" @submit="emit('submit')" @forgot="emit('forgot')" @to-register="emit('toRegister')" />
    </div>
  </section>
</template>
