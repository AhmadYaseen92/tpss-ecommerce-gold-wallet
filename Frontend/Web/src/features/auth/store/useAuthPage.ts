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

const toDoc = (
  documentType: string,
  fileName: string,
  filePath: string,
  contentType: string,
  isRequired: boolean,
  relatedEntityType?: string,
) => ({
  documentType,
  fileName,
  filePath,
  contentType,
  isRequired,
  relatedEntityType,
});

const normalizeOptionalDate = (value: unknown): string | null => {
  if (typeof value !== "string") return null;
  const trimmed = value.trim();
  return trimmed.length > 0 ? trimmed : null;
};

const getSelectedFileName = (value: unknown): string => {
  if (!value || typeof value !== "object") return "";
  const withName = value as { name?: unknown };
  return typeof withName.name === "string" ? withName.name : "";
};

const getSelectedFilePath = (value: unknown): string => {
  if (!value || typeof value !== "object") return "";
  const withPath = value as { filePath?: unknown };
  if (typeof withPath.filePath === "string" && withPath.filePath.trim()) return withPath.filePath;
  return getSelectedFileName(value);
};

const getSelectedContentType = (value: unknown): string => {
  if (!value || typeof value !== "object") return "application/octet-stream";
  const withType = value as { contentType?: unknown };
  if (typeof withType.contentType === "string" && withType.contentType.trim()) {
    return withType.contentType;
  }

  const fileName = getSelectedFileName(value).toLowerCase();
  if (fileName.endsWith(".pdf")) return "application/pdf";
  if (fileName.endsWith(".jpg") || fileName.endsWith(".jpeg")) return "image/jpeg";
  if (fileName.endsWith(".png")) return "image/png";
  if (fileName.endsWith(".webp")) return "image/webp";
  if (fileName.endsWith(".gif")) return "image/gif";

  return "application/octet-stream";
};

export function buildRegisterSellerPayload(form: RegisterFormModel) {
  const nameParts = splitFullName(form.ownerInfo.name);

  return {
    firstName: nameParts.firstName,
    middleName: nameParts.middleName,
    lastName: nameParts.lastName,
    email: form.credentials.loginPhone,
    password: form.credentials.password,
    role: "Seller" as const,
    companyInfo: {
      companyName: form.companyInfo.companyName,
      companyCode: form.companyInfo.companyCode,
      commercialRegistrationNumber: form.companyInfo.crNumber,
      vatNumber: form.companyInfo.vatNumber,
      businessActivity: form.companyInfo.businessActivity,
      establishedDate: normalizeOptionalDate(form.companyInfo.establishedDate),
      tradeLicenseExpiryDate: normalizeOptionalDate(form.companyInfo.tradeLicenseExpiryDate),
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
      idExpiryDate: normalizeOptionalDate(form.ownerInfo.idExpiry),
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
      toDoc(
        "CommercialRegistrationDocument",
        getSelectedFileName(form.companyInfo.documents.crDoc?.[0]),
        getSelectedFilePath(form.companyInfo.documents.crDoc?.[0]),
        getSelectedContentType(form.companyInfo.documents.crDoc?.[0]),
        true,
        "Seller"),
      toDoc(
        "ProofOfAddress",
        getSelectedFileName(form.companyInfo.documents.proofOfAddress?.[0]),
        getSelectedFilePath(form.companyInfo.documents.proofOfAddress?.[0]),
        getSelectedContentType(form.companyInfo.documents.proofOfAddress?.[0]),
        true,
        "Seller"),
      toDoc(
        "VatCertificate",
        getSelectedFileName(form.companyInfo.documents.vatCert?.[0]),
        getSelectedFilePath(form.companyInfo.documents.vatCert?.[0]),
        getSelectedContentType(form.companyInfo.documents.vatCert?.[0]),
        false,
        "Seller"),
      toDoc(
        "AmlDocumentation",
        getSelectedFileName(form.companyInfo.documents.amlDoc?.[0]),
        getSelectedFilePath(form.companyInfo.documents.amlDoc?.[0]),
        getSelectedContentType(form.companyInfo.documents.amlDoc?.[0]),
        true,
        "Seller"),
      toDoc(
        "ManagerIdCopy",
        getSelectedFileName(form.ownerInfo.idCopy?.[0]),
        getSelectedFilePath(form.ownerInfo.idCopy?.[0]),
        getSelectedContentType(form.ownerInfo.idCopy?.[0]),
        true,
        "Manager"),
      toDoc(
        "AuthorizationLetter",
        getSelectedFileName(form.ownerInfo.authLetter?.[0]),
        getSelectedFilePath(form.ownerInfo.authLetter?.[0]),
        getSelectedContentType(form.ownerInfo.authLetter?.[0]),
        false,
        "Manager"),
      ...form.banks.flatMap((bank) => [
        toDoc(
          "BankConfirmationLetter",
          getSelectedFileName(bank.bankLetter?.[0]),
          getSelectedFilePath(bank.bankLetter?.[0]),
          getSelectedContentType(bank.bankLetter?.[0]),
          false,
          "BankAccount"),
        toDoc(
          "IbanProofDocument",
          getSelectedFileName(bank.ibanProof?.[0]),
          getSelectedFilePath(bank.ibanProof?.[0]),
          getSelectedContentType(bank.ibanProof?.[0]),
          false,
          "BankAccount"),
      ])
    ].filter((doc) => doc.fileName),
  };
}

export function useAuthPage(marketplace: ReturnTypeUseMarketplace) {
  const authScreen = ref<"login" | "register">("login");

  const loginForm = reactive<LoginFormModel>({
    email: "",
    password: "",
    rememberMe: false,
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
