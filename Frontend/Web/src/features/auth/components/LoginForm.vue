<script setup lang="ts">
import type { LoginFormModel } from "../types/authTypes";

defineProps<{
  model: LoginFormModel;
  loading: boolean;
}>();

const emit = defineEmits<{
  submit: [];
  forgot: [];
  toRegister: [];
}>();
</script>

<template>
  <form @submit.prevent="emit('submit')">
    <input v-model="model.email" type="email" placeholder="Email" required />
    <input v-model="model.password" type="password" placeholder="Password" required />

    <div class="auth-options">
      <label class="remember">
        <input v-model="model.rememberMe" type="checkbox" />
        Remember me
      </label>

      <button type="button" class="link-btn" @click="emit('forgot')">
        Forgot password?
      </button>
    </div>

    <button :disabled="loading" type="submit" class="full-btn">Login</button>

    <p class="register-text">
      Don’t have an account?
      <button type="button" class="link-btn" @click="emit('toRegister')">
        Go to Sign Up
      </button>
    </p>
  </form>
</template>