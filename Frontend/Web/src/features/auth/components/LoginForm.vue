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
  <form class="login-form" @submit.prevent="emit('submit')">
    <div class="form-group">
      <label>Email</label>
      <input v-model="model.email" type="email" placeholder="admin@goldwallet.com" autocomplete="email" />
    </div>

    <div class="form-group">
      <label>Password</label>
      <input v-model="model.password" type="password" placeholder="Enter password" autocomplete="current-password" />
    </div>

    <div class="auth-options">
      <label class="remember">
        <input v-model="model.rememberMe" type="checkbox" />
        <span>Remember me</span>
      </label>

      <button type="button" class="link-btn" @click="emit('forgot')">
        Forgot password?
      </button>
    </div>

    <button class="login-btn" :disabled="loading" type="submit">
      {{ loading ? "Signing in..." : "Login" }}
    </button>

    <p class="register-text">
      Don’t have an account?
      <button type="button" class="link-btn" @click="emit('toRegister')">
        Go to Sign Up
      </button>
    </p>
  </form>
</template>

<style scoped>
.login-form {
  display: grid;
  gap: 18px;
}

.form-group {
  display: grid;
  gap: 7px;
}

.form-group label {
  color: #f8e7b0;
  font-size: 13px;
  font-weight: 700;
}

.form-group input {
  width: 100%;
  height: 46px;
  border: 1px solid rgba(214, 168, 45, 0.3);
  border-radius: 12px;
  background: rgba(18, 16, 10, 0.82);
  color: #fff8e6;
  padding: 0 14px;
  font-size: 14px;
  outline: none;
  transition: 0.2s ease;
}

.form-group input::placeholder {
  color: rgba(255, 248, 230, 0.45);
}

.form-group input:focus {
  border-color: #d6a82d;
  box-shadow: 0 0 0 3px rgba(214, 168, 45, 0.18);
}

.auth-options {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 16px;
}

.remember {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  color: rgba(255, 248, 230, 0.82);
  font-size: 13px;
  cursor: pointer;
}

.remember input {
  width: 16px;
  height: 16px;
  accent-color: #d6a82d;
}

.link-btn {
  border: 0;
  background: transparent;
  color: #f0c34a;
  font-size: 13px;
  font-weight: 700;
  cursor: pointer;
  padding: 0;
}

.link-btn:hover {
  color: #ffe08a;
  text-decoration: underline;
}

.login-btn {
  width: 100%;
  height: 48px;
  border: 0;
  border-radius: 13px;
  background: linear-gradient(135deg, #f2cf62, #c79b1d);
  color: #171207;
  font-size: 15px;
  font-weight: 800;
  cursor: pointer;
  box-shadow: 0 14px 28px rgba(214, 168, 45, 0.24);
  transition: 0.2s ease;
}

.login-btn:hover:not(:disabled) {
  transform: translateY(-1px);
  box-shadow: 0 18px 34px rgba(214, 168, 45, 0.32);
}

.login-btn:disabled {
  opacity: 0.65;
  cursor: not-allowed;
}

.register-text {
  margin: 4px 0 0;
  color: rgba(255, 248, 230, 0.78);
  font-size: 13px;
  text-align: center;
}

@media (max-width: 520px) {
  .auth-options {
    align-items: flex-start;
    flex-direction: column;
  }
}
</style>