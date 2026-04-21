<script setup lang="ts">
import { reactive, computed } from "vue";
import { useRouter } from "vue-router";
import { ElMessage } from "element-plus";
import RegisterForm from "../components/RegisterForm.vue";
import {
  createEmptyRegisterForm,
  type RegisterFormModel,
} from "../types/authTypes";
import { buildRegisterSellerPayload } from "../store/useAuthPage";
import { useMarketplace } from "../../../shared/app/store/useMarketplace";

const router = useRouter();
const marketplace = useMarketplace();

const model = reactive<RegisterFormModel>(createEmptyRegisterForm());
const loading = computed(() => marketplace.loading.value);

const onSubmit = async () => {
  if (model.credentials.password !== model.credentials.confirmPassword) {
    ElMessage.error("Password and confirm password do not match.");
    return;
  }

  const payload = buildRegisterSellerPayload(model);
  await marketplace.registerSeller(payload);

  if (!marketplace.error.value) {
    ElMessage.success("Registration submitted successfully.");
    router.push("/Login");
  }
};

const onToLogin = () => {
  router.push("/Login");
};
</script>

<template>
  <section class="register-page">
    <div class="auth-card large">
      <RegisterForm
        :model="model"
        :loading="loading"
        @submit="onSubmit"
        @to-login="onToLogin"
      />
    </div>
  </section>
</template>