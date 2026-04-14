import { reactive, ref } from "vue";
import type { ReturnTypeUseMarketplace } from "../../../shared/app/store/useMarketplace";

interface RegistrationErrors {
  fullName?: string;
  email?: string;
  phoneNumber?: string;
  password?: string;
  confirmPassword?: string;
  country?: string;
  city?: string;
  street?: string;
  buildingNumber?: string;
  postalCode?: string;
  companyName?: string;
  tradeLicenseNumber?: string;
  vatNumber?: string;
  nationalIdNumber?: string;
  bankName?: string;
  iban?: string;
  accountHolderName?: string;
  nationalIdFrontPath?: string;
  nationalIdBackPath?: string;
  tradeLicensePath?: string;
}

const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

const buildUploadPath = (folder: string, file: File) => {
  const cleanName = file.name.replace(/[^a-zA-Z0-9_.-]/g, "_");
  return `/uploads/${folder}/${Date.now()}-${cleanName}`;
};

export function useAuthPage(marketplace: ReturnTypeUseMarketplace) {
  const authScreen = ref<"login" | "register">("login");
  const loginForm = reactive({ email: "admin@goldwallet.com", password: "P@ssw0rd", rememberMe: true });
  const registerForm = reactive({
    fullName: "",
    email: "",
    password: "",
    confirmPassword: "",
    phoneNumber: "",
    country: "Jordan",
    city: "",
    street: "",
    buildingNumber: "",
    postalCode: "",
    companyName: "",
    tradeLicenseNumber: "",
    vatNumber: "",
    nationalIdNumber: "",
    bankName: "",
    iban: "",
    accountHolderName: "",
    nationalIdFrontPath: "",
    nationalIdBackPath: "",
    tradeLicensePath: ""
  });

  const uploadedFiles = reactive({
    nationalIdFront: null as File | null,
    nationalIdBack: null as File | null,
    tradeLicense: null as File | null
  });

  const registerErrors = reactive<RegistrationErrors>({});

  const setKycFile = (key: "nationalIdFront" | "nationalIdBack" | "tradeLicense", file: File | null) => {
    uploadedFiles[key] = file;

    if (key === "nationalIdFront") {
      registerForm.nationalIdFrontPath = file ? buildUploadPath("kyc", file) : "";
      registerErrors.nationalIdFrontPath = "";
    }

    if (key === "nationalIdBack") {
      registerForm.nationalIdBackPath = file ? buildUploadPath("kyc", file) : "";
      registerErrors.nationalIdBackPath = "";
    }

    if (key === "tradeLicense") {
      registerForm.tradeLicensePath = file ? buildUploadPath("kyc", file) : "";
      registerErrors.tradeLicensePath = "";
    }
  };

  const validateRegistration = () => {
    Object.keys(registerErrors).forEach((key) => {
      registerErrors[key as keyof RegistrationErrors] = "";
    });

    if (!registerForm.fullName.trim()) registerErrors.fullName = "Full name is required.";
    if (!emailRegex.test(registerForm.email.trim())) registerErrors.email = "Enter a valid email address.";
    if (!registerForm.phoneNumber.trim()) registerErrors.phoneNumber = "Phone number is required.";
    if (registerForm.password.length < 8) registerErrors.password = "Password must be at least 8 characters.";
    if (registerForm.password !== registerForm.confirmPassword) registerErrors.confirmPassword = "Passwords do not match.";

    const requiredFields: Array<{ key: keyof RegistrationErrors; value: string; message: string }> = [
      { key: "country", value: registerForm.country, message: "Country is required." },
      { key: "city", value: registerForm.city, message: "City is required." },
      { key: "street", value: registerForm.street, message: "Street is required." },
      { key: "buildingNumber", value: registerForm.buildingNumber, message: "Building number is required." },
      { key: "postalCode", value: registerForm.postalCode, message: "Postal code is required." },
      { key: "companyName", value: registerForm.companyName, message: "Company name is required." },
      { key: "tradeLicenseNumber", value: registerForm.tradeLicenseNumber, message: "Trade license number is required." },
      { key: "vatNumber", value: registerForm.vatNumber, message: "VAT number is required." },
      { key: "nationalIdNumber", value: registerForm.nationalIdNumber, message: "National ID number is required." },
      { key: "bankName", value: registerForm.bankName, message: "Bank name is required." },
      { key: "iban", value: registerForm.iban, message: "IBAN is required." },
      { key: "accountHolderName", value: registerForm.accountHolderName, message: "Account holder name is required." }
    ];

    requiredFields.forEach((field) => {
      if (!field.value.trim()) registerErrors[field.key] = field.message;
    });

    if (!uploadedFiles.nationalIdFront) registerErrors.nationalIdFrontPath = "National ID front file is required.";
    if (!uploadedFiles.nationalIdBack) registerErrors.nationalIdBackPath = "National ID back file is required.";
    if (!uploadedFiles.tradeLicense) registerErrors.tradeLicensePath = "Trade license file is required.";

    return !Object.values(registerErrors).some((value) => !!value);
  };

  const registerSellerAction = async () => {
    if (!validateRegistration()) {
      marketplace.error.value = "Please fix the highlighted fields before submitting registration.";
      return;
    }

    const parts = registerForm.fullName.trim().split(/\s+/);
    await marketplace.registerSeller({
      firstName: parts[0] ?? "",
      middleName: parts.length > 2 ? parts.slice(1, -1).join(" ") : (parts[1] ?? "-"),
      lastName: parts.length > 1 ? parts[parts.length - 1] : "-",
      email: registerForm.email,
      password: registerForm.password,
      phoneNumber: registerForm.phoneNumber,
      country: registerForm.country,
      city: registerForm.city,
      street: registerForm.street,
      buildingNumber: registerForm.buildingNumber,
      postalCode: registerForm.postalCode,
      companyName: registerForm.companyName,
      tradeLicenseNumber: registerForm.tradeLicenseNumber,
      vatNumber: registerForm.vatNumber,
      nationalIdNumber: registerForm.nationalIdNumber,
      bankName: registerForm.bankName,
      iban: registerForm.iban,
      accountHolderName: registerForm.accountHolderName,
      nationalIdFrontPath: registerForm.nationalIdFrontPath,
      nationalIdBackPath: registerForm.nationalIdBackPath,
      tradeLicensePath: registerForm.tradeLicensePath
    });
  };

  return { authScreen, loginForm, registerForm, registerErrors, registerSellerAction, setKycFile };
}
