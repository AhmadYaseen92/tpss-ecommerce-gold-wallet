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
  phoneNumber: string;
  country: string;
  city: string;
  street: string;
  buildingNumber: string;
  postalCode: string;
  companyName: string;
  tradeLicenseNumber: string;
  vatNumber: string;
  nationalIdNumber: string;
  bankName: string;
  iban: string;
  accountHolderName: string;
  nationalIdFrontPath: string;
  nationalIdBackPath: string;
  tradeLicensePath: string;
}
