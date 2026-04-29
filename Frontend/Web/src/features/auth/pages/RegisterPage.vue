<script setup lang="ts">
import { reactive, computed } from "vue";
import { ElMessageBox } from "element-plus";
import RegisterForm from "../components/RegisterForm.vue";
import {
  createEmptyRegisterForm,
  type RegisterFormModel,
} from "../types/authTypes";
import { buildRegisterSellerPayload } from "../store/useAuthPage";
import { useMarketplace } from "../../../shared/app/store/useMarketplace";

const emit = defineEmits<{ toLogin: []; themeToggle: [] }>();
const props = withDefaults(defineProps<{ isDark?: boolean }>(), { isDark: false });
const marketplace = useMarketplace();

const model = reactive<RegisterFormModel>(createEmptyRegisterForm());
const loading = computed(() => marketplace.loading.value);

const isEmail = (value: string) => /\S+@\S+\.\S+/.test(value);
const showModal = (title: string, message: string) =>
  ElMessageBox.alert(message, title, { confirmButtonText: "OK", type: "warning" });

const ensureDataUrl = async (item: any) => {
  if (!item || typeof item !== "object") return;
  if (typeof item.filePath === "string" && item.filePath.startsWith("data:")) return;
  if (!item.file) return;

  item.filePath = await new Promise<string>((resolve) => {
    const reader = new FileReader();
    reader.onload = () => resolve(typeof reader.result === "string" ? reader.result : "");
    reader.onerror = () => resolve("");
    reader.readAsDataURL(item.file as File);
  });
  if (!item.contentType) item.contentType = (item.file as File).type || "application/octet-stream";
};

const hydrateDocumentsBeforeSubmit = async () => {
  const files = [
    model.companyInfo.documents.crDoc?.[0],
    model.companyInfo.documents.proofOfAddress?.[0],
    model.companyInfo.documents.vatCert?.[0],
    model.companyInfo.documents.amlDoc?.[0],
    model.ownerInfo.idCopy?.[0],
    model.ownerInfo.authLetter?.[0],
    ...model.banks.flatMap((bank) => [bank.bankLetter?.[0], bank.ibanProof?.[0]]),
  ];

  await Promise.all(files.map((item) => ensureDataUrl(item)));
};

const onSubmit = async () => {
  if (model.credentials.password !== model.credentials.confirmPassword) {
    await showModal("Validation Error", "Password and confirm password do not match.");
    return;
  }

  if (!isEmail(model.companyInfo.email) || !isEmail(model.ownerInfo.email) || !isEmail(model.credentials.loginEmail)) {
    await showModal("Validation Error", "Please enter valid email addresses.");
    return;
  }

  await hydrateDocumentsBeforeSubmit();

  const payload = buildRegisterSellerPayload(model);
  await marketplace.registerSeller(payload);

  if (!marketplace.error.value) {
    await ElMessageBox.alert("Registration submitted successfully.", "Success", { confirmButtonText: "OK", type: "success" });
    emit("toLogin");
  } else {
    await showModal("Registration Failed", marketplace.error.value || "Something went wrong, please contact system Admin.");
  }
};
</script>

<template>
  <section class="login-page" :class="{ 'dark-auth': props.isDark }">
    <button class="theme-toggle-btn" type="button" @click="emit('themeToggle')">
      {{ props.isDark ? "Light Theme" : "Dark Theme" }}
    </button>
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

<style scoped>
.auth-card-register {
  background: var(--surface);
  color: var(--text);
}

.theme-toggle-btn {
  position: fixed;
  top: 18px;
  right: 18px;
  z-index: 3;
  border: 1px solid rgba(214, 168, 45, 0.4);
  background: var(--surface);
  color: var(--text);
  border-radius: 999px;
  font-size: 11px;
  font-weight: 700;
  padding: 6px 10px;
}

:global(:root.dark-mode) .auth-card-register {
  background: var(--surface);
  color: var(--text);
}
</style>
