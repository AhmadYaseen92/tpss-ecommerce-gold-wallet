
import { loginWithBackend, registerSellerWithBackend } from "../../../shared/services/backendGateway";
import { postJson, putJson } from "../../../shared/services/httpClient";
import type { AuthCredentials, SellerRegistration, UserSession } from "../../../shared/types/models";

export const authService = {
  login(credentials: AuthCredentials): Promise<UserSession> {
    return loginWithBackend(credentials);
  },
  register(registration: SellerRegistration) {
    return registerSellerWithBackend(registration);
  },
  async requestPasswordResetOtp(payload: { email: string }) {
    // Backend expects: { email }
    return postJson<any, typeof payload>("/api/auth/password/reset/request-otp", payload);
  },
  async confirmPasswordReset(payload: { email: string; otp: string; newPassword: string }) {
    // Backend expects: { email, otp, newPassword }
    return postJson<any, typeof payload>("/api/auth/password/reset/confirm", payload);
  },
  async changePassword(payload: { userId: number; oldPassword: string; newPassword: string; accessToken: string }) {
    return putJson<any, { userId: number; currentPassword: string; newPassword: string }>(
      "/api/profile/password",
      {
        userId: payload.userId,
        currentPassword: payload.oldPassword,
        newPassword: payload.newPassword
      },
      payload.accessToken
    );
  }
};

export const requestPasswordResetOtp = authService.requestPasswordResetOtp;
export const confirmPasswordReset = authService.confirmPasswordReset;
export const changePassword = authService.changePassword;
