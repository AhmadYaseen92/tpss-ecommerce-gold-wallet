export interface LoginFormModel {
  email: string;
  password: string;
  rememberMe: boolean;
}

export interface RegisterFormModel {
  fullName: string;
  email: string;
  password: string;
  confirmPassword: string;
  businessName: string;
  idNumber: string;
}
