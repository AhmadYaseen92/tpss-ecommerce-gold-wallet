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
const props = withDefaults(defineProps<{ isDark?: boolean }>(), {
  isDark: false,
});
const marketplace = useMarketplace();

const model = reactive<RegisterFormModel>(createEmptyRegisterForm());
const loading = computed(() => marketplace.loading.value);
const COMPANY_CODE_COUNTER_KEY = "goldwallet.companyCode.counter";

const nextCompanyCode = () => {
  const saved = Number(window.localStorage.getItem(COMPANY_CODE_COUNTER_KEY) ?? "99");
  const next = Number.isFinite(saved) && saved >= 99 ? saved + 1 : 100;
  window.localStorage.setItem(COMPANY_CODE_COUNTER_KEY, String(next));
  return String(next);
};

if (!model.companyInfo.companyCode.trim()) {
  model.companyInfo.companyCode = nextCompanyCode();
}

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

  if (!isEmail(model.companyInfo.email) || !isEmail(model.ownerInfo.email)) {
    await showModal("Validation Error", "Please enter valid email addresses.");
    return;
  }

  if (!/^\+?[0-9]{8,15}$/.test(model.credentials.loginPhone.trim())) {
    await showModal("Validation Error", "Login phone number must contain 8 to 15 digits.");
    return;
  }

  if (model.companyInfo.tradeLicenseExpiryDate) {
    const expiry = new Date(model.companyInfo.tradeLicenseExpiryDate);
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    if (Number.isNaN(expiry.getTime()) || expiry <= today) {
      await showModal("Validation Error", "Trade license expiration date must be in the future.");
      return;
    }
  } else {
    await showModal("Validation Error", "Trade license expiration date is required.");
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
  <section class="login-page">
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
  width: min(1080px, 96vw);
  background: color-mix(in srgb, var(--surface-solid) 86%, transparent);
  border-color: var(--border-strong);
}

.theme-toggle-btn {
  position: fixed;
  top: 18px;
  right: 18px;
  z-index: 3;
  border: 1px solid rgba(241, 195, 75, 0.45);
  background: rgba(8, 8, 8, 0.45);
  color: #fff8e6;
  border-radius: 999px;
  font-size: 12px;
  font-weight: 800;
  letter-spacing: 0.08em;
  text-transform: uppercase;
  padding: 8px 14px;
  cursor: pointer;
}

:global(:root.dark-mode) .auth-card-register {
  background: linear-gradient(180deg, rgba(36, 30, 20, 0.95), rgba(17, 14, 9, 0.95));
  border-color: rgba(214, 168, 45, 0.46);
}

@media (max-width: 900px) {
  .auth-card-register {
    width: min(760px, 96vw);
  }
}
</style>
