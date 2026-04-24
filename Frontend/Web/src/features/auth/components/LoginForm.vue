<script setup lang="ts">
import type { LoginFormModel } from "../types/authTypes";
import FormField from "../../../shared/components/ui/FormField.vue";
import Input from "../../../shared/components/ui/Input.vue";
import Checkbox from "../../../shared/components/ui/Checkbox.vue";
import Button from "../../../shared/components/ui/Button.vue";

defineProps<{ model: LoginFormModel; loading: boolean; }>();
const emit = defineEmits<{ submit: []; forgot: []; toRegister: []; }>();
</script>

<template>
  <form @submit.prevent="emit('submit')">
    <FormField label="Email"><Input v-model="model.email" type="email" placeholder="Email" /></FormField>
    <FormField label="Password"><Input v-model="model.password" type="password" placeholder="Password" /></FormField>

    <div class="auth-options">
      <label class="remember"><Checkbox v-model="model.rememberMe" /> Remember me</label>
      <button type="button" class="link-btn" @click="emit('forgot')">Forgot password?</button>
    </div>

    <Button :disabled="loading" type="submit" class="full-btn">Login</Button>

    <p class="register-text">Don’t have an account? <button type="button" class="link-btn" @click="emit('toRegister')">Go to Sign Up</button></p>
  </form>
</template>
