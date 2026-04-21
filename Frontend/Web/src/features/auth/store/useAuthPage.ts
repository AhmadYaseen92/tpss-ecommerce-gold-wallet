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

const toDoc = (documentType: string, fileName: string, isRequired: boolean, relatedEntityType?: string) => ({
  documentType,
  fileName,
  filePath: fileName,
  contentType: "application/octet-stream",
  isRequired,
  relatedEntityType,
});

export function buildRegisterSellerPayload(form: RegisterFormModel) {
  const nameParts = splitFullName(form.ownerInfo.name);

  return {
    firstName: nameParts.firstName,
    middleName: nameParts.middleName,
    lastName: nameParts.lastName,
    email: form.credentials.loginEmail,
    password: form.credentials.password,
    role: "Seller" as const,
    companyInfo: {
      companyName: form.companyInfo.companyName,
      companyCode: form.companyInfo.companyCode,
      commercialRegistrationNumber: form.companyInfo.crNumber,
      vatNumber: form.companyInfo.vatNumber,
      businessActivity: form.companyInfo.businessActivity,
      establishedDate: form.companyInfo.establishedDate,
      country: form.companyInfo.country,
      city: form.companyInfo.city,
      street: form.companyInfo.street,
      buildingNumber: form.companyInfo.buildingNumber,
      postalCode: form.companyInfo.postalCode,
      companyPhone: form.companyInfo.phone,
      companyEmail: form.companyInfo.email,
      website: form.companyInfo.website,
      description: form.companyInfo.description,
    },
    manager: {
      fullName: form.ownerInfo.name,
      positionTitle: form.ownerInfo.position,
      nationality: form.ownerInfo.nationality,
      mobileNumber: form.ownerInfo.mobile,
      emailAddress: form.ownerInfo.email,
      idType: form.ownerInfo.idType,
      idNumber: form.ownerInfo.idNumber,
      idExpiryDate: form.ownerInfo.idExpiry,
    },
    branches: form.branches.map((branch) => ({
      branchName: branch.branchName,
      country: branch.country,
      city: branch.city,
      fullAddress: branch.address,
      buildingNumber: branch.buildingNumber,
      postalCode: branch.postalCode,
      phoneNumber: branch.phone,
      email: branch.email,
      isMainBranch: branch.isMain,
    })),
    bankAccounts: form.banks.map((bank) => ({
      bankName: bank.bankName,
      accountHolderName: bank.accountHolder,
      accountNumber: bank.accountNumber,
      iban: bank.iban,
      swiftCode: bank.swift,
      bankCountry: bank.country,
      bankCity: bank.city,
      branchName: bank.branchName,
      branchAddress: bank.branchAddress,
      currency: bank.currency,
      isMainAccount: bank.isMain,
    })),
    documents: [
      toDoc("CommercialRegistrationDocument", form.companyInfo.documents.crDoc?.[0]?.name ?? "", true, "Seller"),
      toDoc("ArticlesOfAssociation", form.companyInfo.documents.articles?.[0]?.name ?? "", true, "Seller"),
      toDoc("ProofOfAddress", form.companyInfo.documents.proofOfAddress?.[0]?.name ?? "", true, "Seller"),
      toDoc("VatCertificate", form.companyInfo.documents.vatCert?.[0]?.name ?? "", true, "Seller"),
      toDoc("AmlDocumentation", form.companyInfo.documents.amlDoc?.[0]?.name ?? "", true, "Seller"),
      toDoc("ManagerIdCopy", form.ownerInfo.idCopy?.[0]?.name ?? "", true, "Manager"),
      toDoc("AuthorizationLetter", form.ownerInfo.authLetter?.[0]?.name ?? "", false, "Manager"),
      ...form.banks.flatMap((bank) => [
        toDoc("BankConfirmationLetter", bank.bankLetter?.[0]?.name ?? "", false, "BankAccount"),
        toDoc("IbanProofDocument", bank.ibanProof?.[0]?.name ?? "", false, "BankAccount"),
      ])
    ].filter((doc) => doc.fileName),
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
