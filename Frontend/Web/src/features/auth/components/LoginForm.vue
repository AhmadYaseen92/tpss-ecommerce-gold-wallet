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
      <label>Email or Phone</label>
      <input v-model="model.email" type="text" placeholder="Email or UAE phone (e.g. +971501234567)" autocomplete="username" />
      <small class="input-hint">You can sign in using either your email address or phone number.</small>
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
  color: var(--text);
  font-size: 13px;
  font-weight: 700;
}

.form-group input {
  width: 100%;
  height: 46px;
  border: 1px solid var(--color-border);
  border-radius: 12px;
  background: var(--surface-solid);
  color: var(--text);
  padding: 0 14px;
  font-size: 14px;
  outline: none;
  transition: 0.2s ease;
}

.input-hint {
  color: var(--text-muted);
  font-size: 12px;
}

.form-group input::placeholder {
  color: var(--text-muted);
}

.form-group input:focus {
  border-color: var(--primary);
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
  color: var(--text-muted);
  font-size: 13px;
  cursor: pointer;
}

.remember input {
  width: 16px;
  height: 16px;
  accent-color: var(--primary);
}

.link-btn {
  border: 0;
  background: transparent;
  color: var(--primary);
  font-size: 13px;
  font-weight: 700;
  cursor: pointer;
  padding: 0;
}

.link-btn:hover {
  color: var(--primary-strong);
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
  color: var(--text-muted);
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
