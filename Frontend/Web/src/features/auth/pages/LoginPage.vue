<script setup lang="ts">
import { reactive, computed } from "vue";
import { useRouter } from "vue-router";
import LoginForm from "../components/LoginForm.vue";
import type { LoginFormModel } from "../types/authTypes";
import { useMarketplace } from "../../../shared/app/store/useMarketplace";

const router = useRouter();
const marketplace = useMarketplace();

const model = reactive<LoginFormModel>({
  email: "admin@goldwallet.com",
  password: "P@ssw0rd",
  rememberMe: true,
});

const loading = computed(() => marketplace.loading.value);

const onSubmit = async () => {
  await marketplace.login({
    email: model.email,
    password: model.password,
  });

  if (!marketplace.error.value) {
    router.push("/OverView");
  }
};

const onForgot = () => {
  console.log("Forgot password clicked");
};

const onToRegister = () => {
  router.push("/Register");
};
</script>

<template>
  <section class="login-page">
    <div class="auth-card large">
      <h1>Welcome Back</h1>
      <p>Sign in to continue to your dashboard.</p>

      <LoginForm
        :model="model"
        :loading="loading"
        @submit="onSubmit"
        @forgot="onForgot"
        @to-register="onToRegister"
      />
    </div>
  </section>
</template>