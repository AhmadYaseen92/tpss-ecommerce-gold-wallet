
import { loginWithBackend, registerSellerWithBackend } from "../../../shared/services/backendGateway";
import { HttpError, postJson, putJson } from "../../../shared/services/httpClient";
import type { AuthCredentials, SellerRegistration, UserSession } from "../../../shared/types/models";

export const authService = {
  login(credentials: AuthCredentials): Promise<UserSession> {
    return loginWithBackend(credentials);
  },
  register(registration: SellerRegistration) {
    return registerSellerWithBackend(registration);
  }
  ,
  async requestPasswordResetOtp(payload: { email: string }) {
    // Backend expects: { email }
    return postJson<any, typeof payload>("/api/auth/password/reset/request-otp", payload);
  },
  async confirmPasswordReset(payload: { email: string; otp: string; newPassword: string }) {
    // Backend expects: { email, otp, newPassword }
    return postJson<any, typeof payload>("/api/auth/password/reset/confirm", payload);
  },
  async changePassword(payload: { oldPassword: string; newPassword: string }) {
    // Backend expects: { oldPassword, newPassword }
    return putJson<any, typeof payload>("/api/profile/password", payload);
  }
};
