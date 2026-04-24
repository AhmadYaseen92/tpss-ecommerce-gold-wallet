<script setup lang="ts">
import { reactive, computed } from "vue";
import { ElMessage } from "element-plus";
import RegisterForm from "../components/RegisterForm.vue";
import {
  createEmptyRegisterForm,
  type RegisterFormModel,
} from "../types/authTypes";
import { buildRegisterSellerPayload } from "../store/useAuthPage";
import { useMarketplace } from "../../../shared/app/store/useMarketplace";

const emit = defineEmits<{ toLogin: [] }>();
const marketplace = useMarketplace();

const model = reactive<RegisterFormModel>(createEmptyRegisterForm());
const loading = computed(() => marketplace.loading.value);

const isEmail = (value: string) => /\S+@\S+\.\S+/.test(value);

const onSubmit = async () => {
  if (model.credentials.password !== model.credentials.confirmPassword) {
    ElMessage.error("Password and confirm password do not match.");
    return;
  }

  if (!isEmail(model.companyInfo.email) || !isEmail(model.ownerInfo.email) || !isEmail(model.credentials.loginEmail)) {
    ElMessage.error("Please enter valid email addresses.");
    return;
  }

  const payload = buildRegisterSellerPayload(model);
  console.info("[SellerRegistration] Final payload", payload);
  await marketplace.registerSeller(payload);

  if (!marketplace.error.value) {
    ElMessage.success("Registration submitted successfully. Region: Seller Onboarding");
    emit("toLogin");
  } else {
    console.error("[SellerRegistration] Submit failed", {
      payload,
      error: marketplace.error.value,
    });
    ElMessage.error(`Registration failed (Seller Onboarding): ${marketplace.error.value}`);
  }
};
</script>

<template>
  <section class="login-page">
    <div class="auth-card auth-card-register">
      <RegisterForm
        :model="model"
        :loading="loading"
        @submit="onSubmit"
        @to-login="emit('toLogin')"
      />
    </div>
  </section>
</template>
