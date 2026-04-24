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
}>();

const steps = [
  "Company Information",
  "Company Owner / Manager",
  "Company Branches / Locations",
  "Bank Details",
  "Login Credentials",
  "Order Summary",
];

const activeStep = ref(0);
const stepError = ref("");
const stepRefs = ref<Array<HTMLElement | null>>([]);

const setSingleFile = (listRef: any[], event: Event) => {
  const input = event.target as HTMLInputElement;
  const file = input.files?.[0];
  listRef.splice(0, listRef.length);
  if (file) {
    listRef.push({
      name: file.name,
      file,
    });
  }
};

const validateStep = (step: number) => {
  if (step === 0) {
    const required = [
      props.model.companyInfo.companyName,
      props.model.companyInfo.companyCode,
      props.model.companyInfo.crNumber,
      props.model.companyInfo.vatNumber,
      props.model.companyInfo.country,
      props.model.companyInfo.city,
      props.model.companyInfo.street,
      props.model.companyInfo.phone,
      props.model.companyInfo.email
    ];
    if (required.some((x) => !x?.trim())) return "Please complete all required Company Information fields.";
  }
  if (step === 1) {
    const required = [props.model.ownerInfo.name, props.model.ownerInfo.position, props.model.ownerInfo.mobile, props.model.ownerInfo.email, props.model.ownerInfo.idType, props.model.ownerInfo.idNumber];
    if (required.some((x) => !x?.trim())) return "Please complete all required Owner / Manager fields.";
  }
  if (step === 2 && props.model.branches.some((x) => !x.branchName || !x.country || !x.city || !x.address)) return "Please complete branch details before continuing.";
  if (step === 3 && props.model.banks.some((x) => !x.bankName || !x.accountHolder || !x.accountNumber || !x.iban)) return "Please complete bank account details before continuing.";
  if (step === 4) {
    const required = [props.model.credentials.loginEmail, props.model.credentials.password, props.model.credentials.confirmPassword];
    if (required.some((x) => !x?.trim())) return "Please complete login credentials before continuing.";
    if (props.model.credentials.password !== props.model.credentials.confirmPassword) return "Password and Confirm Password do not match.";
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
      <label>Company Code <input v-model="model.companyInfo.companyCode" required /></label>
      <label>Commercial Registration Number (CR) <input v-model="model.companyInfo.crNumber" required /></label>
      <label>Tax / VAT Number <input v-model="model.companyInfo.vatNumber" required /></label>
      <label>Business Activity / Industry Type <input v-model="model.companyInfo.businessActivity" /></label>
      <label>Established Date <input v-model="model.companyInfo.establishedDate" type="date" /></label>
      <label>Country <input v-model="model.companyInfo.country" required /></label>
      <label>City <input v-model="model.companyInfo.city" required /></label>
      <label>Street <input v-model="model.companyInfo.street" required /></label>
      <label>Building Number <input v-model="model.companyInfo.buildingNumber" /></label>
      <label>Postal Code <input v-model="model.companyInfo.postalCode" /></label>
      <label>Company Phone <input v-model="model.companyInfo.phone" required /></label>
      <label>Company Email <input v-model="model.companyInfo.email" type="email" required /></label>
      <label>Website (optional) <input v-model="model.companyInfo.website" /></label>
      <label class="full">Description (optional) <textarea v-model="model.companyInfo.description" rows="3" /></label>

      <label>Commercial Registration Document <input type="file" @change="setSingleFile(model.companyInfo.documents.crDoc, $event)" /></label>
      <label>Articles of Association <input type="file" @change="setSingleFile(model.companyInfo.documents.articles, $event)" /></label>
      <label>Proof of Address <input type="file" @change="setSingleFile(model.companyInfo.documents.proofOfAddress, $event)" /></label>
      <label>VAT Certificate <input type="file" @change="setSingleFile(model.companyInfo.documents.vatCert, $event)" /></label>
      <label>AML Documentation <input type="file" @change="setSingleFile(model.companyInfo.documents.amlDoc, $event)" /></label>
    </div>

    <div v-if="activeStep === 1" :ref="(el) => (stepRefs[1] = el as HTMLElement)" class="form-grid">
      <h2>Company Owner / Manager</h2>
      <label>Manager / Owner Name <input v-model="model.ownerInfo.name" required /></label>
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
      <label>Owner / Manager ID Copy <input type="file" @change="setSingleFile(model.ownerInfo.idCopy, $event)" /></label>
      <label>Authorization Letter (if applicable) <input type="file" @change="setSingleFile(model.ownerInfo.authLetter, $event)" /></label>
    </div>

    <div v-if="activeStep === 2" :ref="(el) => (stepRefs[2] = el as HTMLElement)" class="form-grid">
      <div class="title-row"><h2>Company Branches / Locations</h2><button type="button" @click="addBranch">Add Branch</button></div>
      <div v-for="(branch, idx) in model.branches" :key="idx" class="card full">
        <div class="title-row"><strong>Branch {{ idx + 1 }}</strong><button type="button" @click="removeBranch(idx)">Remove</button></div>
        <label>Branch Name <input v-model="branch.branchName" required /></label>
        <label>Country <input v-model="branch.country" required /></label>
        <label>City <input v-model="branch.city" required /></label>
        <label>Full Address <input v-model="branch.address" required /></label>
        <label>Building Number <input v-model="branch.buildingNumber" /></label>
        <label>Postal Code <input v-model="branch.postalCode" /></label>
        <label>Phone Number <input v-model="branch.phone" /></label>
        <label>Email <input v-model="branch.email" type="email" /></label>
        <label><input type="radio" name="mainBranch" :checked="branch.isMain" @change="setMainBranch(idx)" /> Is Main Branch</label>
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
        <label>Bank Country <input v-model="bank.country" /></label>
        <label>Bank City <input v-model="bank.city" /></label>
        <label>Branch Name <input v-model="bank.branchName" /></label>
        <label>Branch Address <input v-model="bank.branchAddress" /></label>
        <label>Currency <input v-model="bank.currency" /></label>
        <label><input type="radio" name="mainBank" :checked="bank.isMain" @change="setMainBank(idx)" /> Is Main Account</label>
        <label>Bank Confirmation Letter <input type="file" @change="setSingleFile(bank.bankLetter, $event)" /></label>
        <label>IBAN Proof Document <input type="file" @change="setSingleFile(bank.ibanProof, $event)" /></label>
      </div>
    </div>

    <div v-if="activeStep === 4" :ref="(el) => (stepRefs[4] = el as HTMLElement)" class="form-grid">
      <h2>Login Credentials</h2>
      <label>Login Email <input v-model="model.credentials.loginEmail" type="email" required /></label>
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
.subtitle { color: #5f6b7a; margin: 0; }
.stepper { display: flex; gap: 8px; flex-wrap: wrap; }
.step-btn { border: 1px solid #d7dbe3; background: #fff; border-radius: 8px; padding: 6px 10px; cursor: pointer; }
.step-btn.active { background: #1f2937; color: #fff; }
.form-grid { display: grid; grid-template-columns: repeat(2,minmax(0,1fr)); gap: 10px; }
.form-grid h2, .full, .title-row { grid-column: 1 / -1; }
label { display: grid; gap: 6px; font-weight: 600; }
input, textarea, select { padding: 8px; border: 1px solid #cfd6e4; border-radius: 8px; font: inherit; }
.card { border: 1px solid #e4e7ee; border-radius: 10px; padding: 10px; display:grid; gap: 8px; }
.title-row { display:flex; justify-content: space-between; align-items: center; }
.wizard-actions { display:flex; justify-content: space-between; margin-top: 8px; }
.ghost { margin-right: 8px; }
.error-banner { margin: 0; background: #fee2e2; color: #991b1b; border: 1px solid #fca5a5; border-radius: 8px; padding: 8px 10px; }
@media (max-width: 900px) { .form-grid { grid-template-columns: 1fr; } }
</style>
