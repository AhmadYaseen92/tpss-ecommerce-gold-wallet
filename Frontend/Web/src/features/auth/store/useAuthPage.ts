import { reactive, ref } from "vue";
import type { ReturnTypeUseMarketplace } from "../../../shared/app/store/useMarketplace";

export function useAuthPage(marketplace: ReturnTypeUseMarketplace) {
  const authScreen = ref<"login" | "register">("login");
  const loginForm = reactive({ email: "admin@goldwallet.com", password: "P@ssw0rd", rememberMe: true });
  const registerForm = reactive({
    fullName: "",
    email: "",
    password: "",
    confirmPassword: "",
    phoneNumber: "",
    country: "Jordan",
    city: "",
    street: "",
    buildingNumber: "",
    postalCode: "",
    companyName: "",
    tradeLicenseNumber: "",
    vatNumber: "",
    nationalIdNumber: "",
    bankName: "",
    iban: "",
    accountHolderName: "",
    nationalIdFrontPath: "",
    nationalIdBackPath: "",
    tradeLicensePath: ""
  });

  const registerSellerAction = async () => {
    if (registerForm.password !== registerForm.confirmPassword) {
      marketplace.error.value = "Password and confirm password do not match.";
      return;
    }

    const parts = registerForm.fullName.trim().split(/\s+/);
    await marketplace.registerSeller({
      firstName: parts[0] ?? "",
      middleName: parts.length > 2 ? parts.slice(1, -1).join(" ") : (parts[1] ?? "-"),
      lastName: parts.length > 1 ? parts[parts.length - 1] : "-",
      email: registerForm.email,
      password: registerForm.password,
      phoneNumber: registerForm.phoneNumber,
      country: registerForm.country,
      city: registerForm.city,
      street: registerForm.street,
      buildingNumber: registerForm.buildingNumber,
      postalCode: registerForm.postalCode,
      companyName: registerForm.companyName,
      tradeLicenseNumber: registerForm.tradeLicenseNumber,
      vatNumber: registerForm.vatNumber,
      nationalIdNumber: registerForm.nationalIdNumber,
      bankName: registerForm.bankName,
      iban: registerForm.iban,
      accountHolderName: registerForm.accountHolderName,
      nationalIdFrontPath: registerForm.nationalIdFrontPath,
      nationalIdBackPath: registerForm.nationalIdBackPath,
      tradeLicensePath: registerForm.tradeLicensePath
    });
  };

  return { authScreen, loginForm, registerForm, registerSellerAction };
}
