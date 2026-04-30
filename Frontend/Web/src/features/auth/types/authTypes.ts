export interface LoginFormModel {
  email: string;
  password: string;
  rememberMe: boolean;
}

export type UploadFileList = any[];

export interface CompanyDocumentsModel {
  crDoc: UploadFileList;
  proofOfAddress: UploadFileList;
  vatCert: UploadFileList;
  amlDoc: UploadFileList;
}

export interface CompanyInfoModel {
  companyName: string;
  companyCode: string;
  crNumber: string;
  vatNumber: string;
  businessActivity: string;
  establishedDate: string;
  tradeLicenseExpiryDate: string;
  country: string;
  city: string;
  street: string;
  buildingNumber: string;
  postalCode: string;
  phone: string;
  email: string;
  website: string;
  description: string;
  documents: CompanyDocumentsModel;
}

export interface OwnerInfoModel {
  name: string;
  position: string;
  nationality: string;
  mobile: string;
  email: string;
  idType: string;
  idNumber: string;
  idExpiry: string;
  idCopy: UploadFileList;
  authLetter: UploadFileList;
}

export interface BranchModel {
  branchName: string;
  country: string;
  city: string;
  address: string;
  buildingNumber: string;
  postalCode: string;
  phone: string;
  email: string;
  isMain: boolean;
}

export interface BankModel {
  bankName: string;
  accountHolder: string;
  accountNumber: string;
  iban: string;
  swift: string;
  country: string;
  city: string;
  branchName: string;
  branchAddress: string;
  currency: string;
  isMain: boolean;
  bankLetter: UploadFileList;
  ibanProof: UploadFileList;
}

export interface CredentialsModel {
  loginEmail: string;
  loginPhone: string;
  password: string;
  confirmPassword: string;
}

export interface RegisterFormModel {
  companyInfo: CompanyInfoModel;
  ownerInfo: OwnerInfoModel;
  branches: BranchModel[];
  banks: BankModel[];
  credentials: CredentialsModel;
  agreements: {
    termsAccepted: boolean;
  };
}

export function createEmptyBranch(): BranchModel {
  return {
    branchName: "",
    country: "UAE",
    city: "",
    address: "",
    buildingNumber: "",
    postalCode: "",
    phone: "",
    email: "",
    isMain: false,
  };
}

export function createEmptyBank(): BankModel {
  return {
    bankName: "",
    accountHolder: "",
    accountNumber: "",
    iban: "",
    swift: "",
    country: "UAE",
    city: "",
    branchName: "",
    branchAddress: "",
    currency: "",
    isMain: false,
    bankLetter: [],
    ibanProof: [],
  };
}

export function createEmptyRegisterForm(): RegisterFormModel {
  return {
    companyInfo: {
      companyName: "",
      companyCode: "",
      crNumber: "",
      vatNumber: "",
      businessActivity: "",
      establishedDate: "",
      tradeLicenseExpiryDate: "",
      country: "UAE",
      city: "",
      street: "",
      buildingNumber: "",
      postalCode: "",
      phone: "",
      email: "",
      website: "",
      description: "",
      documents: {
        crDoc: [],
        proofOfAddress: [],
        vatCert: [],
        amlDoc: [],
      },
    },
    ownerInfo: {
      name: "",
      position: "",
      nationality: "",
      mobile: "",
      email: "",
      idType: "",
      idNumber: "",
      idExpiry: "",
      idCopy: [],
      authLetter: [],
    },
    branches: [createEmptyBranch()],
    banks: [createEmptyBank()],
    credentials: {
      loginEmail: "",
      loginPhone: "",
      password: "",
      confirmPassword: "",
    },
    agreements: {
      termsAccepted: false,
    },
  };
}
