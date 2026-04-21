import { reactive, ref } from "vue";
import type { ReturnTypeUseMarketplace } from "../../../shared/app/store/useMarketplace";
import type { LoginFormModel, RegisterFormModel } from "../types/authTypes";
import { createEmptyRegisterForm } from "../types/authTypes";

export function splitFullName(fullName: string) {
  const parts = fullName.trim().split(/\s+/).filter(Boolean);

  return {
    firstName: parts[0] ?? "",
    middleName: parts.length > 2 ? parts.slice(1, -1).join(" ") : (parts[1] ?? "-"),
    lastName: parts.length > 1 ? parts[parts.length - 1] : "-",
  };
}

export function buildRegisterSellerPayload(form: RegisterFormModel) {
  const nameParts = splitFullName(form.ownerInfo.name);
  const primaryBank = form.banks.find((x) => x.isMain) ?? form.banks[0];

  return {
    firstName: nameParts.firstName,
    middleName: nameParts.middleName,
    lastName: nameParts.lastName,
    email: form.credentials.loginEmail,
    password: form.credentials.password,
    phoneNumber: form.ownerInfo.mobile || form.companyInfo.phone,
    country: form.companyInfo.country,
    city: form.companyInfo.city,
    street: form.companyInfo.street,
    buildingNumber: form.companyInfo.buildingNumber,
    postalCode: form.companyInfo.postalCode,
    companyName: form.companyInfo.companyName,
    tradeLicenseNumber: form.companyInfo.crNumber,
    vatNumber: form.companyInfo.vatNumber,
    nationalIdNumber: form.ownerInfo.idNumber,
    bankName: primaryBank?.bankName ?? "",
    iban: primaryBank?.iban ?? "",
    accountHolderName: primaryBank?.accountHolder ?? "",
    nationalIdFrontPath: form.ownerInfo.idCopy?.[0]?.name ?? "",
    nationalIdBackPath: form.ownerInfo.idCopy?.[0]?.name ?? "",
    tradeLicensePath: form.companyInfo.documents.crDoc?.[0]?.name ?? "",
  };
}

export function useAuthPage(marketplace: ReturnTypeUseMarketplace) {
  const authScreen = ref<"login" | "register">("login");

  const loginForm = reactive<LoginFormModel>({
    email: "admin@goldwallet.com",
    password: "P@ssw0rd",
    rememberMe: true,
  });

  const registerForm = reactive<RegisterFormModel>(createEmptyRegisterForm());

  const registerErrors = reactive<Record<string, string>>({});

  const setKycFile = () => {
    // no-op for compatibility with old AuthPage.vue
  };

  const registerSellerAction = async () => {
    const payload = buildRegisterSellerPayload(registerForm);
    await marketplace.registerSeller(payload);
  };

  return {
    authScreen,
    loginForm,
    registerForm,
    registerErrors,
    registerSellerAction,
    setKycFile,
  };
}