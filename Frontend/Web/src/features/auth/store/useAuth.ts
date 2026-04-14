import { ref } from "vue";
import { authService } from "../services/authService";
import type { AuthCredentials, SellerRegistration } from "../../../shared/types/models";

export function useAuth() {
  const loading = ref(false);
  const error = ref("");

  const login = async (credentials: AuthCredentials) => {
    loading.value = true;
    error.value = "";
    try {
      return await authService.login(credentials);
    } catch (err) {
      error.value = err instanceof Error ? err.message : "Login failed";
      throw err;
    } finally {
      loading.value = false;
    }
  };

  const register = async (registration: SellerRegistration) => {
    loading.value = true;
    error.value = "";
    try {
      return await authService.register(registration);
    } catch (err) {
      error.value = err instanceof Error ? err.message : "Registration failed";
      throw err;
    } finally {
      loading.value = false;
    }
  };

  return { loading, error, login, register };
}
