import { loginWithBackend, registerSellerWithBackend } from "../../../shared/services/backendGateway";
import type { AuthCredentials, SellerRegistration, UserSession } from "../../../shared/types/models";

export const authService = {
  login(credentials: AuthCredentials): Promise<UserSession> {
    return loginWithBackend(credentials);
  },
  register(registration: SellerRegistration) {
    return registerSellerWithBackend(registration);
  }
};
