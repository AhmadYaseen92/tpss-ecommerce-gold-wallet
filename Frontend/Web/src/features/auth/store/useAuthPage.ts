import { reactive, ref } from "vue";
import type { ReturnTypeUseMarketplace } from "../../dashboard/store/useMarketplace";

export function useAuthPage(marketplace: ReturnTypeUseMarketplace) {
  const authScreen = ref<"login" | "register">("login");
  const loginForm = reactive({ email: "admin@goldwallet.com", password: "P@ssw0rd", rememberMe: true });
  const registerForm = reactive({ fullName: "", email: "", password: "", confirmPassword: "", businessName: "", idNumber: "" });

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
      businessName: registerForm.businessName,
      idNumber: registerForm.idNumber
    });
  };

  return { authScreen, loginForm, registerForm, registerSellerAction };
}
