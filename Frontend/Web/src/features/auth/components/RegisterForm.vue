<script setup lang="ts">
import { ref } from "vue";
import {
  createEmptyBank,
  createEmptyBranch,
  type RegisterFormModel,
} from "../types/authTypes";

const props = defineProps<{
  model: RegisterFormModel;
  loading: boolean;
}>();

const emit = defineEmits<{
  submit: [];
  toLogin: [];
  openTerms: [];
  openPrivacy: [];
}>();

const steps = [
  "Company Info",
  "Owner",
  "Branches",
  "Bank Details",
  "Login",
  "Summary",
];
const countryCityMap: Record<string, string[]> = {
  Jordan: ["Amman", "Zarqa", "Irbid", "Aqaba", "Mafraq", "Salt", "Madaba", "Jerash", "Ajloun", "Karak", "Tafilah", "Ma'an"],
  "Saudi Arabia": ["Riyadh", "Jeddah", "Mecca", "Medina", "Dammam", "Khobar", "Tabuk", "Abha", "Buraidah", "Hail", "Jizan", "Najran"],
  UAE: ["Dubai", "Abu Dhabi", "Sharjah", "Ajman", "Ras Al Khaimah", "Fujairah", "Umm Al Quwain", "Al Ain"],
  Egypt: ["Cairo", "Alexandria", "Giza", "Luxor", "Aswan", "Mansoura", "Tanta", "Suez", "Port Said", "Ismailia", "Faiyum", "Minya"],
  "United States": ["New York", "Los Angeles", "Chicago", "Houston", "Phoenix", "Philadelphia", "San Antonio", "San Diego", "Dallas", "San Jose"],
  "United Kingdom": ["London", "Manchester", "Birmingham", "Leeds", "Liverpool", "Bristol", "Sheffield", "Newcastle", "Nottingham", "Leicester"],
  Germany: ["Berlin", "Munich", "Hamburg", "Frankfurt", "Cologne", "Stuttgart", "Dusseldorf", "Dortmund", "Essen", "Leipzig"],
  France: ["Paris", "Lyon", "Marseille", "Toulouse", "Nice", "Nantes", "Strasbourg", "Montpellier", "Bordeaux", "Lille"],
  India: ["Mumbai", "Delhi", "Bengaluru", "Hyderabad", "Chennai", "Kolkata", "Pune", "Ahmedabad", "Jaipur", "Lucknow"],
  Pakistan: ["Karachi", "Lahore", "Islamabad", "Peshawar", "Rawalpindi", "Faisalabad", "Multan", "Sialkot", "Hyderabad", "Quetta"],
};
const countryOptions = Object.keys(countryCityMap);
const currencyOptions = ["USD", "EUR", "GBP", "JOD", "SAR", "AED", "EGP", "INR", "PKR"];
const getCityOptions = (country: string) => countryCityMap[country] || [];

const activeStep = ref(0);
const stepError = ref("");
const stepRefs = ref<Array<HTMLElement | null>>([]);

const setSingleFile = (listRef: any[], event: Event) => {
  const input = event.target as HTMLInputElement;
  const file = input.files?.[0];
  listRef.splice(0, listRef.length);
  if (file) {
    const selectedFile = {
      name: file.name,
      file,
      contentType: file.type || "application/octet-stream",
      filePath: "",
    };
    listRef.push(selectedFile);

    const reader = new FileReader();
    reader.onload = () => {
      selectedFile.filePath = typeof reader.result === "string" ? reader.result : "";
    };
    reader.readAsDataURL(file);
  }
};

const validateStep = (step: number) => {
  if (step === 0) {
    const missing: string[] = [];
    if (!props.model.companyInfo.companyName?.trim()) missing.push("Company Name");
    if (!props.model.companyInfo.companyCode?.trim()) missing.push("Company Code");
    if (!props.model.companyInfo.crNumber?.trim()) missing.push("Trade License Number");
    if (!props.model.companyInfo.tradeLicenseExpiryDate?.trim()) missing.push("Trade License Expiration Date");
    if (!props.model.companyInfo.vatNumber?.trim()) missing.push("VAT Number");
    if (!props.model.companyInfo.businessActivity?.trim()) missing.push("Business Activity");
    if (!props.model.companyInfo.country?.trim()) missing.push("Country");
    if (!props.model.companyInfo.city?.trim()) missing.push("City");
    if (!props.model.companyInfo.street?.trim()) missing.push("Street");
    if (!props.model.companyInfo.buildingNumber?.trim()) missing.push("Building Number");
    if (!props.model.companyInfo.postalCode?.trim()) missing.push("Postal Code");
    if (!props.model.companyInfo.phone?.trim()) missing.push("Company Phone");
    if (!props.model.companyInfo.email?.trim()) missing.push("Company Email");
    if (!props.model.companyInfo.documents.crDoc.length) missing.push("Trade License Number Document");
    if (!props.model.companyInfo.documents.proofOfAddress.length) missing.push("Proof of Address");
    if (!props.model.companyInfo.documents.amlDoc.length) missing.push("AML Documentation");
    if (missing.length > 0) return `Company Information missing required fields: ${missing.join(", ")}.`;
  }
  if (step === 1) {
    const missing: string[] = [];
    if (!props.model.ownerInfo.name?.trim()) missing.push("Manager Name");
    if (!props.model.ownerInfo.position?.trim()) missing.push("Position / Job Title");
    if (!props.model.ownerInfo.nationality?.trim()) missing.push("Nationality");
    if (!props.model.ownerInfo.mobile?.trim()) missing.push("Mobile Number");
    if (!props.model.ownerInfo.email?.trim()) missing.push("Email Address");
    if (!props.model.ownerInfo.idType?.trim()) missing.push("ID Type");
    if (!props.model.ownerInfo.idNumber?.trim()) missing.push("ID Number");
    if (!props.model.ownerInfo.idCopy.length) missing.push("Manager ID Copy");
    if (missing.length > 0) return `Manager tab is missing: ${missing.join(", ")}.`;
  }
  if (step === 2) {
    const invalidBranch = props.model.branches.findIndex((x) => !x.branchName || !x.country || !x.city || !x.address);
    if (invalidBranch >= 0) return `Branch #${invalidBranch + 1} is missing required fields: Branch Name, Country, City, or Full Address.`;
  }
  if (step === 3) {
    const invalidBank = props.model.banks.findIndex((x) => !x.bankName || !x.accountHolder || !x.accountNumber || !x.iban || !x.country || !x.city || !x.currency);
    if (invalidBank >= 0) return `Bank Account #${invalidBank + 1} is missing required fields: Bank Name, Account Holder, Account Number, or IBAN.`;
  }
  if (step === 4) {
    const required = [props.model.credentials.password, props.model.credentials.confirmPassword];
    if (required.some((x) => !x?.trim())) return "Please complete login credentials before continuing.";
    if (!props.model.credentials.loginEmail?.trim() && !props.model.credentials.loginPhone?.trim()) {
      return "Please provide at least one login identifier (Email or Phone).";
    }
    if (props.model.credentials.password !== props.model.credentials.confirmPassword) return "Password and Confirm Password do not match.";
  }
  if (step === 5) {
    if (!props.model.agreements.termsAccepted) return "You must accept Terms & Conditions and Privacy Policy to continue.";
  }
  return "";
};

const reportCurrentStepValidity = (step: number) => {
  const container = stepRefs.value[step];
  if (!container) return true;

  const fields = container.querySelectorAll<HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement>(
    "input, textarea, select",
  );

  for (const field of fields) {
    if (!field.checkValidity()) {
      field.reportValidity();
      return false;
    }
  }

  return true;
};

function nextStep() {
  if (!reportCurrentStepValidity(activeStep.value)) return;
  const error = validateStep(activeStep.value);
  stepError.value = error;
  if (error) return;
  if (activeStep.value < steps.length - 1) activeStep.value++;
}

function prevStep() {
  stepError.value = "";
  if (activeStep.value > 0) activeStep.value--;
}

function addBranch() {
  props.model.branches.push(createEmptyBranch());
}

function removeBranch(idx: number) {
  if (props.model.branches.length <= 1) return;
  props.model.branches.splice(idx, 1);
  if (!props.model.branches.some((x) => x.isMain)) props.model.branches[0].isMain = true;
}

function setMainBranch(idx: number) {
  props.model.branches.forEach((x, i) => (x.isMain = i === idx));
}

function addBank() {
  props.model.banks.push(createEmptyBank());
}

function removeBank(idx: number) {
  if (props.model.banks.length <= 1) return;
  props.model.banks.splice(idx, 1);
  if (!props.model.banks.some((x) => x.isMain)) props.model.banks[0].isMain = true;
}

function setMainBank(idx: number) {
  props.model.banks.forEach((x, i) => (x.isMain = i === idx));
}

function goToStep(idx: number) {
  if (idx <= activeStep.value) {
    activeStep.value = idx;
    return;
  }

  if (!reportCurrentStepValidity(activeStep.value)) return;

  const error = validateStep(activeStep.value);
  stepError.value = error;
  if (error) return;

  activeStep.value = idx;
}
</script>

<template>
  <section class="register-wizard">
    <h1>Create Seller Account</h1>
    <p class="subtitle">Register company information, owner details, branches, bank accounts, and login credentials.</p>

    <p v-if="stepError" class="error-banner">{{ stepError }}</p>

    <div class="stepper">
      <button
        v-for="(step, idx) in steps"
        :key="step"
        type="button"
        class="step-btn"
        :class="{ active: idx === activeStep }"
        @click="goToStep(idx)"
      >
        {{ idx + 1 }}. {{ step }}
      </button>
    </div>

    <div v-if="activeStep === 0" :ref="(el) => (stepRefs[0] = el as HTMLElement)" class="form-grid">
      <h2>Company Information</h2>
      <label>Company Name <input v-model="model.companyInfo.companyName" required /></label>
      <label>Company Code <input v-model="model.companyInfo.companyCode" required readonly /></label>
      <label>Trade License Number <input v-model="model.companyInfo.crNumber" required /></label>
      <label>Company trade license expiration date <input v-model="model.companyInfo.tradeLicenseExpiryDate" type="date" required /></label>
      <label>Tax / VAT Number <input v-model="model.companyInfo.vatNumber" required /></label>
      <label>Business Activity / Industry Type <input v-model="model.companyInfo.businessActivity" /></label>
      <label>Established Date <input v-model="model.companyInfo.establishedDate" type="date" /></label>
      <label>Country
        <select v-model="model.companyInfo.country" required @change="() => { if (!getCityOptions(model.companyInfo.country).includes(model.companyInfo.city)) model.companyInfo.city = ''; }">
          <option value="">Select country</option>
          <option v-for="country in countryOptions" :key="country" :value="country">{{ country }}</option>
        </select>
      </label>
      <label>City
        <select v-model="model.companyInfo.city" required>
          <option value="">Select city</option>
          <option v-for="city in getCityOptions(model.companyInfo.country)" :key="`company-${model.companyInfo.country}-${city}`" :value="city">{{ city }}</option>
        </select>
      </label>
      <label>Street <input v-model="model.companyInfo.street" required /></label>
      <label>Building Number <input v-model="model.companyInfo.buildingNumber" /></label>
      <label>Postal Code <input v-model="model.companyInfo.postalCode" /></label>
      <label>Company Phone <input v-model="model.companyInfo.phone" required /></label>
      <label>Company Email <input v-model="model.companyInfo.email" type="email" required /></label>
      <label>Website (optional) <input v-model="model.companyInfo.website" /></label>
      <label class="full">Description (optional) <textarea v-model="model.companyInfo.description" rows="3" /></label>

      <label>Trade License Number Document <input type="file" @change="setSingleFile(model.companyInfo.documents.crDoc, $event)" /></label>
      <label>Proof of Address <input type="file" @change="setSingleFile(model.companyInfo.documents.proofOfAddress, $event)" /></label>
      <label>VAT Certificate (optional) <input type="file" @change="setSingleFile(model.companyInfo.documents.vatCert, $event)" /></label>
      <label>AML Documentation <input type="file" @change="setSingleFile(model.companyInfo.documents.amlDoc, $event)" /></label>
    </div>

    <div v-if="activeStep === 1" :ref="(el) => (stepRefs[1] = el as HTMLElement)" class="form-grid">
      <h2>Company Manager</h2>
      <label>Manager Name <input v-model="model.ownerInfo.name" required /></label>
      <label>Position / Job Title <input v-model="model.ownerInfo.position" required /></label>
      <label>Nationality <input v-model="model.ownerInfo.nationality" /></label>
      <label>Mobile Number <input v-model="model.ownerInfo.mobile" required /></label>
      <label>Email Address <input v-model="model.ownerInfo.email" type="email" required /></label>
      <label>ID Type
        <select v-model="model.ownerInfo.idType" required>
          <option value="">Select</option>
          <option>National ID</option>
          <option>Passport</option>
        </select>
      </label>
      <label>ID Number <input v-model="model.ownerInfo.idNumber" required /></label>
      <label>ID Expiry Date <input v-model="model.ownerInfo.idExpiry" type="date" /></label>
      <label>Manager ID Copy <input type="file" @change="setSingleFile(model.ownerInfo.idCopy, $event)" /></label>
      <label>Authorization Letter (if applicable) <input type="file" @change="setSingleFile(model.ownerInfo.authLetter, $event)" /></label>
    </div>

    <div v-if="activeStep === 2" :ref="(el) => (stepRefs[2] = el as HTMLElement)" class="form-grid">
      <div class="title-row"><h2>Company Branches / Locations</h2><button type="button" @click="addBranch">Add Branch</button></div>
      <div v-for="(branch, idx) in model.branches" :key="idx" class="card full">
        <div class="title-row"><strong>Branch {{ idx + 1 }}</strong><button type="button" @click="removeBranch(idx)">Remove</button></div>
        <label>Branch Name <input v-model="branch.branchName" required /></label>
        <label>Country
          <select v-model="branch.country" required @change="() => { if (!getCityOptions(branch.country).includes(branch.city)) branch.city = ''; }">
            <option value="">Select country</option>
            <option v-for="country in countryOptions" :key="`branch-country-${country}`" :value="country">{{ country }}</option>
          </select>
        </label>
        <label>City
          <select v-model="branch.city" required>
            <option value="">Select city</option>
            <option v-for="city in getCityOptions(branch.country)" :key="`branch-city-${branch.country}-${city}`" :value="city">{{ city }}</option>
          </select>
        </label>
        <label>Full Address <input v-model="branch.address" required /></label>
        <label>Building Name & Number <input v-model="branch.buildingNumber" /></label>
        <label>Postal Code <input v-model="branch.postalCode" /></label>
        <label>Phone Number <input v-model="branch.phone" /></label>
        <label>Email <input v-model="branch.email" type="email" /></label>
        <label class="inline-check"><input type="checkbox" :checked="branch.isMain" @change="setMainBranch(idx)" /> Is Main Branch</label>
      </div>
    </div>

    <div v-if="activeStep === 3" :ref="(el) => (stepRefs[3] = el as HTMLElement)" class="form-grid">
      <div class="title-row"><h2>Bank Details</h2><button type="button" @click="addBank">Add Bank Account</button></div>
      <div v-for="(bank, idx) in model.banks" :key="idx" class="card full">
        <div class="title-row"><strong>Bank Account {{ idx + 1 }}</strong><button type="button" @click="removeBank(idx)">Remove</button></div>
        <label>Bank Name <input v-model="bank.bankName" required /></label>
        <label>Account Holder Name <input v-model="bank.accountHolder" required /></label>
        <label>Account Number <input v-model="bank.accountNumber" required /></label>
        <label>IBAN <input v-model="bank.iban" required /></label>
        <label>SWIFT Code <input v-model="bank.swift" /></label>
        <label>Bank Country
          <select v-model="bank.country">
            <option value="">Select country</option>
            <option v-for="country in countryOptions" :key="country" :value="country">{{ country }}</option>
          </select>
        </label>
        <label>Bank City
          <select v-model="bank.city">
            <option value="">Select city</option>
            <option v-for="city in getCityOptions(bank.country)" :key="`${bank.country}-${city}`" :value="city">{{ city }}</option>
          </select>
        </label>
        <label>Branch Name <input v-model="bank.branchName" /></label>
        <label>Branch Address <input v-model="bank.branchAddress" /></label>
        <label>Currency
          <select v-model="bank.currency">
            <option value="">Select currency</option>
            <option v-for="currency in currencyOptions" :key="currency" :value="currency">{{ currency }}</option>
          </select>
        </label>
        <label class="inline-check"><input type="checkbox" :checked="bank.isMain" @change="setMainBank(idx)" /> Is Main Account</label>
        <label>Bank Confirmation Letter (optional) <input type="file" @change="setSingleFile(bank.bankLetter, $event)" /></label>
        <label>IBAN Proof Document (optional) <input type="file" @change="setSingleFile(bank.ibanProof, $event)" /></label>
      </div>
    </div>

    <div v-if="activeStep === 4" :ref="(el) => (stepRefs[4] = el as HTMLElement)" class="form-grid login-step">
      <h2>Login Credentials</h2>
      <label>Login Email <input v-model="model.credentials.loginEmail" type="email" placeholder="Example: seller@example.com" /></label>
      <p class="full login-hint">Use a valid email address if you want to login by email.</p>
      <label>Login Phone Number <input v-model="model.credentials.loginPhone" type="tel" placeholder="UAE example: +971501234567" /></label>
      <p class="full login-hint">Use UAE format (+9715XXXXXXXX) if you want to login by phone.</p>
      <label>Password <input v-model="model.credentials.password" type="password" required /></label>
      <label>Confirm Password <input v-model="model.credentials.confirmPassword" type="password" required /></label>
    </div>

    <div v-if="activeStep === 5" class="form-grid">
      <h2>Order Summary</h2>
      <p><strong>Company:</strong> {{ model.companyInfo.companyName || '-' }}</p>
      <p><strong>Owner/Manager:</strong> {{ model.ownerInfo.name || '-' }}</p>
      <p><strong>Branches:</strong> {{ model.branches.length }}</p>
      <p><strong>Bank Accounts:</strong> {{ model.banks.length }}</p>
      <p><strong>Login Email:</strong> {{ model.credentials.loginEmail || '-' }}</p>
      <p><strong>Login Phone:</strong> {{ model.credentials.loginPhone || '-' }}</p>
      <label class="inline-check full terms-check">
        <input v-model="model.agreements.termsAccepted" type="checkbox" />
        <span>
          I have read and agree to the
          <button type="button" class="link-btn" @click="emit('openTerms')">Terms &amp; Conditions</button>
          and
          <button type="button" class="link-btn" @click="emit('openPrivacy')">Privacy Policy</button>.
        </span>
      </label>
    </div>

    <div class="wizard-actions">
      <button type="button" @click="prevStep" :disabled="activeStep === 0">Previous</button>
      <div>
        <button type="button" class="ghost" @click="emit('toLogin')">Back to Login</button>
        <button v-if="activeStep < steps.length - 1" type="button" @click="nextStep">Next</button>
        <button v-else type="button" :disabled="loading" @click="emit('submit')">Submit</button>
      </div>
    </div>
  </section>
</template>

<style scoped>
.register-wizard { display: grid; gap: 14px; }
.register-wizard h1,
.register-wizard h2,
.register-wizard strong,
.register-wizard label {
  color: var(--text);
}
.register-wizard p {
  color: var(--text-soft);
}
.subtitle { color: var(--text-muted); margin: 0; }
.stepper { display: grid; grid-template-columns: repeat(6, minmax(0, 1fr)); gap: 8px; }
.step-btn {
  border: 1px solid var(--border);
  color: var(--text);
  background: var(--surface-elevated);
  border-radius: 8px;
  padding: 6px 10px;
  cursor: pointer;
  white-space: nowrap;
  font-size: 13px;
  text-align: center;
  font-weight: 700;
}
.step-btn.active {
  background: var(--primary-gradient);
  border-color: var(--border-strong);
  color: #1b1408;
}
.form-grid { display: grid; grid-template-columns: repeat(2,minmax(0,1fr)); gap: 10px; }
.form-grid h2, .full, .title-row { grid-column: 1 / -1; }
label { display: grid; gap: 6px; font-weight: 600; }
.inline-check { display: inline-flex; align-items: center; gap: 8px; }
.inline-check input[type="checkbox"] { width: 14px; height: 14px; }
.terms-check { align-items: flex-start; line-height: 1.45; }
.link-btn {
  border: none;
  background: transparent;
  color: var(--primary);
  text-decoration: underline;
  cursor: pointer;
  font: inherit;
  padding: 0;
}
.login-step { grid-template-columns: 1fr; max-width: 420px; }
.login-hint { margin: -4px 0 2px; font-size: 12px; }
input, textarea, select {
  padding: 8px;
  border: 1px solid var(--border-strong);
  background: var(--surface-solid);
  color: var(--text);
  border-radius: 8px;
  font: inherit;
}
input::placeholder,
textarea::placeholder {
  color: var(--text-muted);
}
select option {
  background: var(--surface-solid);
  color: var(--text);
}
input:-webkit-autofill,
input:-webkit-autofill:hover,
input:-webkit-autofill:focus,
textarea:-webkit-autofill,
textarea:-webkit-autofill:hover,
textarea:-webkit-autofill:focus,
select:-webkit-autofill,
select:-webkit-autofill:hover,
select:-webkit-autofill:focus {
  -webkit-text-fill-color: var(--text);
  box-shadow: 0 0 0 1000px var(--surface-solid) inset;
  transition: background-color 9999s ease-in-out 0s;
}
.card { border: 1px solid var(--border); border-radius: 10px; padding: 10px; display:grid; gap: 8px; background: var(--surface-elevated); }
.title-row { display:flex; justify-content: space-between; align-items: center; }
.wizard-actions { display:flex; justify-content: space-between; margin-top: 8px; }
.ghost { margin-right: 8px; }
.error-banner { margin: 0; background: #fee2e2; color: #991b1b; border: 1px solid #fca5a5; border-radius: 8px; padding: 8px 10px; }
:global(:root.dark-mode) input,
:global(:root.dark-mode) textarea,
:global(:root.dark-mode) select {
  background: rgba(30, 25, 16, 0.95);
  color: #fff8e6;
  border-color: rgba(214, 168, 45, 0.35);
}
:global(:root.dark-mode) input::placeholder,
:global(:root.dark-mode) textarea::placeholder {
  color: rgba(255, 248, 230, 0.58);
}
:global(:root.dark-mode) select option {
  background: #21180d;
  color: #fff8e6;
}
:global(:root.dark-mode) input:-webkit-autofill,
:global(:root.dark-mode) input:-webkit-autofill:hover,
:global(:root.dark-mode) input:-webkit-autofill:focus,
:global(:root.dark-mode) textarea:-webkit-autofill,
:global(:root.dark-mode) textarea:-webkit-autofill:hover,
:global(:root.dark-mode) textarea:-webkit-autofill:focus,
:global(:root.dark-mode) select:-webkit-autofill,
:global(:root.dark-mode) select:-webkit-autofill:hover,
:global(:root.dark-mode) select:-webkit-autofill:focus {
  -webkit-text-fill-color: #fff8e6;
  box-shadow: 0 0 0 1000px rgba(30, 25, 16, 0.95) inset;
}
:global(:root.dark-mode) input[type="date"]::-webkit-calendar-picker-indicator {
  filter: invert(1) sepia(0.3) saturate(1.4);
}
@media (max-width: 1100px) { .stepper { grid-template-columns: repeat(3, minmax(0, 1fr)); } }
@media (max-width: 900px) { .form-grid { grid-template-columns: 1fr; } }
@media (max-width: 640px) { .stepper { grid-template-columns: repeat(2, minmax(0, 1fr)); } }
</style>
