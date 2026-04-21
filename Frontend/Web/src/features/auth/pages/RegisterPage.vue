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

  const required = [
    model.companyInfo.companyName,
    model.companyInfo.companyCode,
    model.companyInfo.crNumber,
    model.companyInfo.vatNumber,
    model.companyInfo.businessActivity,
    model.companyInfo.country,
    model.companyInfo.city,
    model.companyInfo.street,
    model.companyInfo.buildingNumber,
    model.companyInfo.postalCode,
    model.companyInfo.phone,
    model.companyInfo.email,
    model.ownerInfo.name,
    model.ownerInfo.position,
    model.ownerInfo.nationality,
    model.ownerInfo.mobile,
    model.ownerInfo.email,
    model.ownerInfo.idType,
    model.ownerInfo.idNumber,
    model.credentials.loginEmail,
    model.credentials.password,
  ];

  if (required.some((x) => !x?.trim())) {
    ElMessage.error("Please fill all required fields.");
    return;
  }

  if (!isEmail(model.companyInfo.email) || !isEmail(model.ownerInfo.email) || !isEmail(model.credentials.loginEmail)) {
    ElMessage.error("Please enter valid email addresses.");
    return;
  }

  if (!model.companyInfo.documents.crDoc.length || !model.companyInfo.documents.articles.length ||
      !model.companyInfo.documents.proofOfAddress.length || !model.companyInfo.documents.vatCert.length ||
      !model.companyInfo.documents.amlDoc.length || !model.ownerInfo.idCopy.length) {
    ElMessage.error("Please upload all required KYC documents.");
    return;
  }

  const payload = buildRegisterSellerPayload(model);
  await marketplace.registerSeller(payload);

  if (!marketplace.error.value) {
    ElMessage.success("Registration submitted successfully.");
    emit("toLogin");
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
