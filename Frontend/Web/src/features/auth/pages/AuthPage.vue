<script setup lang="ts">
import type { ReturnTypeUseMarketplace } from "../../dashboard/store/useMarketplace";
import { useAuthPage } from "../store/useAuthPage";

const { marketplace } = defineProps<{ marketplace: ReturnTypeUseMarketplace }>();
const { authScreen, loginForm, registerForm, registerSellerAction } = useAuthPage(marketplace);
</script>

<template>
  <section class="login-page">
    <div class="auth-card large">
      <h1>{{ authScreen === 'login' ? 'Welcome Back' : 'Create Seller Account' }}</h1>
      <p v-if="authScreen === 'login'">Sign in to continue to your dashboard.</p>
      <p v-else>Register seller account with KYC details and wait for admin approval.</p>

      <form v-if="authScreen === 'login'" @submit.prevent="marketplace.login({ email: loginForm.email, password: loginForm.password })">
        <input v-model="loginForm.email" type="email" placeholder="Email" required />
        <input v-model="loginForm.password" type="password" placeholder="Password" required />
        <div class="auth-options">
          <label class="remember"><input v-model="loginForm.rememberMe" type="checkbox" /> Remember me</label>
          <a href="#">Forgot password?</a>
        </div>
        <button :disabled="marketplace.loading.value" type="submit" class="full-btn">Login</button>
      </form>

      <form v-else class="register-form" @submit.prevent="registerSellerAction">
        <div class="grid-two">
          <input v-model="registerForm.fullName" placeholder="Full Name" required />
          <input v-model="registerForm.email" type="email" placeholder="Email" required />
          <input v-model="registerForm.password" type="password" placeholder="Password" required />
          <input v-model="registerForm.confirmPassword" type="password" placeholder="Confirm Password" required />
          <input v-model="registerForm.businessName" placeholder="Business Name" required />
          <input v-model="registerForm.idNumber" placeholder="National ID" required />
        </div>
        <button :disabled="marketplace.loading.value" type="submit" class="full-btn">Create account</button>
      </form>

      <p v-if="marketplace.error.value" class="error-text">{{ marketplace.error.value }}</p>
      <p class="register-text" v-if="authScreen === 'login'">Don’t have an account? <button class="link-btn" @click="authScreen = 'register'">Register now</button></p>
      <p class="register-text" v-else>Already have an account? <button class="link-btn" @click="authScreen = 'login'">Back to login</button></p>
    </div>
  </section>
</template>
