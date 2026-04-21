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
  "Order Summary",
  "Company Information",
  "Company Owner / Manager",
  "Company Branches / Locations",
  "Bank Details",
  "Login Credentials",
];

const activeStep = ref(0);

function nextStep() {
  if (activeStep.value < steps.length - 1) {
    activeStep.value++;
  }
}

function prevStep() {
  if (activeStep.value > 0) {
    activeStep.value--;
  }
}

function addBranch() {
  props.model.branches.push(createEmptyBranch());
}

function removeBranch(idx: number) {
  if (props.model.branches.length > 1) {
    props.model.branches.splice(idx, 1);

    if (!props.model.branches.some((branch) => branch.isMain) && props.model.branches.length > 0) {
      props.model.branches[0].isMain = true;
    }
  }
}

function setMainBranch(idx: number) {
  props.model.branches.forEach((branch, index) => {
    branch.isMain = index === idx;
  });
}

function addBank() {
  props.model.banks.push(createEmptyBank());
}

function removeBank(idx: number) {
  if (props.model.banks.length > 1) {
    props.model.banks.splice(idx, 1);

    if (!props.model.banks.some((bank) => bank.isMain) && props.model.banks.length > 0) {
      props.model.banks[0].isMain = true;
    }
  }
}

function setMainBank(idx: number) {
  props.model.banks.forEach((bank, index) => {
    bank.isMain = index === idx;
  });
}

function goToStep(stepIndex: number) {
  activeStep.value = stepIndex;
}
</script>

<template>
  <section class="register-wizard">
    <h1>Create Seller Account</h1>
    <p class="subtitle">
      Register company information, owner details, branches, bank accounts, and login credentials.
    </p>

    <el-steps :active="activeStep" finish-status="success" align-center class="wizard-steps">
      <el-step v-for="(step, idx) in steps" :key="idx" :title="step" />
    </el-steps>

    <div v-show="activeStep === 1">
      <h2>Company Information</h2>

      <el-form :model="model.companyInfo" label-width="220px" class="step-form">
        <el-form-item label="Company Name">
          <el-input v-model="model.companyInfo.companyName" placeholder="Enter company name" />
        </el-form-item>

        <el-form-item label="Company Code">
          <el-input v-model="model.companyInfo.companyCode" placeholder="Enter company code" />
        </el-form-item>

        <el-form-item label="Commercial Registration Number (CR)">
          <el-input v-model="model.companyInfo.crNumber" placeholder="Enter CR number" />
        </el-form-item>

        <el-form-item label="Tax / VAT Number">
          <el-input v-model="model.companyInfo.vatNumber" placeholder="Enter VAT number" />
        </el-form-item>

        <el-form-item label="Business Activity / Industry Type">
          <el-input v-model="model.companyInfo.businessActivity" placeholder="Enter business activity" />
        </el-form-item>

        <el-form-item label="Established Date">
          <el-date-picker
            v-model="model.companyInfo.establishedDate"
            type="date"
            placeholder="Pick a date"
            style="width: 100%"
          />
        </el-form-item>

        <el-divider>Address</el-divider>

        <el-form-item label="Country">
          <el-input v-model="model.companyInfo.country" placeholder="Enter country" />
        </el-form-item>

        <el-form-item label="City">
          <el-input v-model="model.companyInfo.city" placeholder="Enter city" />
        </el-form-item>

        <el-form-item label="Street">
          <el-input v-model="model.companyInfo.street" placeholder="Enter street" />
        </el-form-item>

        <el-form-item label="Building Number">
          <el-input v-model="model.companyInfo.buildingNumber" placeholder="Enter building number" />
        </el-form-item>

        <el-form-item label="Postal Code">
          <el-input v-model="model.companyInfo.postalCode" placeholder="Enter postal code" />
        </el-form-item>

        <el-divider>Contact</el-divider>

        <el-form-item label="Company Phone">
          <el-input v-model="model.companyInfo.phone" placeholder="Enter company phone number" />
        </el-form-item>

        <el-form-item label="Company Email">
          <el-input v-model="model.companyInfo.email" placeholder="Enter company email address" />
        </el-form-item>

        <el-form-item label="Website">
          <el-input v-model="model.companyInfo.website" placeholder="Enter website (optional)" />
        </el-form-item>

        <el-form-item label="Description">
          <el-input
            v-model="model.companyInfo.description"
            type="textarea"
            :rows="4"
            placeholder="Enter description (optional)"
          />
        </el-form-item>

        <el-divider>Company Documents</el-divider>

        <el-form-item label="Commercial Registration Document">
          <el-upload
            v-model:file-list="model.companyInfo.documents.crDoc"
            :auto-upload="false"
            :limit="1"
            list-type="text"
          >
            <el-button type="primary">Upload</el-button>
          </el-upload>
        </el-form-item>

        <el-form-item label="Articles of Association">
          <el-upload
            v-model:file-list="model.companyInfo.documents.articles"
            :auto-upload="false"
            :limit="1"
            list-type="text"
          >
            <el-button type="primary">Upload</el-button>
          </el-upload>
        </el-form-item>

        <el-form-item label="Proof of Address">
          <el-upload
            v-model:file-list="model.companyInfo.documents.proofOfAddress"
            :auto-upload="false"
            :limit="1"
            list-type="text"
          >
            <el-button type="primary">Upload</el-button>
          </el-upload>
        </el-form-item>

        <el-form-item label="VAT Certificate">
          <el-upload
            v-model:file-list="model.companyInfo.documents.vatCert"
            :auto-upload="false"
            :limit="1"
            list-type="text"
          >
            <el-button type="primary">Upload</el-button>
          </el-upload>
        </el-form-item>

        <el-form-item label="AML Documentation">
          <el-upload
            v-model:file-list="model.companyInfo.documents.amlDoc"
            :auto-upload="false"
            :limit="1"
            list-type="text"
          >
            <el-button type="primary">Upload</el-button>
          </el-upload>
        </el-form-item>
      </el-form>
    </div>

    <div v-show="activeStep === 2">
      <h2>Owner / Manager</h2>

      <el-form :model="model.ownerInfo" label-width="220px" class="step-form">
        <el-form-item label="Manager (Owner) Name">
          <el-input v-model="model.ownerInfo.name" placeholder="Enter manager or owner name" />
        </el-form-item>

        <el-form-item label="Position / Job Title">
          <el-input v-model="model.ownerInfo.position" placeholder="Enter position or job title" />
        </el-form-item>

        <el-form-item label="Nationality">
          <el-input v-model="model.ownerInfo.nationality" placeholder="Enter nationality" />
        </el-form-item>

        <el-form-item label="Mobile Number">
          <el-input v-model="model.ownerInfo.mobile" placeholder="Enter mobile number" />
        </el-form-item>

        <el-form-item label="Email Address">
          <el-input v-model="model.ownerInfo.email" placeholder="Enter email address" />
        </el-form-item>

        <el-form-item label="ID Type">
          <el-select v-model="model.ownerInfo.idType" placeholder="Select ID type" style="width: 100%">
            <el-option label="National ID" value="National ID" />
            <el-option label="Passport" value="Passport" />
          </el-select>
        </el-form-item>

        <el-form-item label="ID Number">
          <el-input v-model="model.ownerInfo.idNumber" placeholder="Enter ID number" />
        </el-form-item>

        <el-form-item label="ID Expiry Date">
          <el-date-picker
            v-model="model.ownerInfo.idExpiry"
            type="date"
            placeholder="Pick expiry date"
            style="width: 100%"
          />
        </el-form-item>

        <el-divider>Attachments</el-divider>

        <el-form-item label="Owner / Manager ID Copy">
          <el-upload
            v-model:file-list="model.ownerInfo.idCopy"
            :auto-upload="false"
            :limit="1"
            list-type="text"
          >
            <el-button type="primary">Upload</el-button>
          </el-upload>
        </el-form-item>

        <el-form-item label="Authorization Letter">
          <el-upload
            v-model:file-list="model.ownerInfo.authLetter"
            :auto-upload="false"
            :limit="1"
            list-type="text"
          >
            <el-button type="primary">Upload</el-button>
          </el-upload>
        </el-form-item>
      </el-form>
    </div>

    <div v-show="activeStep === 3">
      <div class="section-header">
        <h2>Branches / Locations</h2>
        <el-button type="primary" @click="addBranch">Add Branch</el-button>
      </div>

      <div v-for="(branch, idx) in model.branches" :key="idx" class="dynamic-card">
        <div class="dynamic-card-header">
          <h3>Branch {{ idx + 1 }}</h3>
          <el-button
            v-if="model.branches.length > 1"
            type="danger"
            plain
            size="small"
            @click="removeBranch(idx)"
          >
            Remove
          </el-button>
        </div>

        <el-form :model="branch" label-width="180px" class="step-form">
          <el-form-item label="Branch Name">
            <el-input v-model="branch.branchName" placeholder="Enter branch name" />
          </el-form-item>

          <el-form-item label="Country">
            <el-input v-model="branch.country" placeholder="Enter country" />
          </el-form-item>

          <el-form-item label="City">
            <el-input v-model="branch.city" placeholder="Enter city" />
          </el-form-item>

          <el-form-item label="Full Address">
            <el-input v-model="branch.address" placeholder="Enter full address" />
          </el-form-item>

          <el-form-item label="Building Number">
            <el-input v-model="branch.buildingNumber" placeholder="Enter building number" />
          </el-form-item>

          <el-form-item label="Postal Code">
            <el-input v-model="branch.postalCode" placeholder="Enter postal code" />
          </el-form-item>

          <el-form-item label="Phone Number">
            <el-input v-model="branch.phone" placeholder="Enter phone number" />
          </el-form-item>

          <el-form-item label="Email">
            <el-input v-model="branch.email" placeholder="Enter email address" />
          </el-form-item>

          <el-form-item label="Is Main Branch">
            <el-radio :model-value="branch.isMain" :label="true" @change="setMainBranch(idx)">
              Main Branch
            </el-radio>
          </el-form-item>
        </el-form>
      </div>
    </div>

    <div v-show="activeStep === 4">
      <div class="section-header">
        <h2>Bank Details</h2>
        <el-button type="primary" @click="addBank">Add Bank</el-button>
      </div>

      <div v-for="(bank, idx) in model.banks" :key="idx" class="dynamic-card">
        <div class="dynamic-card-header">
          <h3>Bank {{ idx + 1 }}</h3>
          <el-button
            v-if="model.banks.length > 1"
            type="danger"
            plain
            size="small"
            @click="removeBank(idx)"
          >
            Remove
          </el-button>
        </div>

        <el-form :model="bank" label-width="180px" class="step-form">
          <el-form-item label="Bank Name">
            <el-input v-model="bank.bankName" placeholder="Enter bank name" />
          </el-form-item>

          <el-form-item label="Account Holder Name">
            <el-input v-model="bank.accountHolder" placeholder="Enter account holder name" />
          </el-form-item>

          <el-form-item label="Account Number">
            <el-input v-model="bank.accountNumber" placeholder="Enter account number" />
          </el-form-item>

          <el-form-item label="IBAN">
            <el-input v-model="bank.iban" placeholder="Enter IBAN" />
          </el-form-item>

          <el-form-item label="SWIFT Code">
            <el-input v-model="bank.swift" placeholder="Enter SWIFT code" />
          </el-form-item>

          <el-form-item label="Bank Country">
            <el-input v-model="bank.country" placeholder="Enter bank country" />
          </el-form-item>

          <el-form-item label="Bank City">
            <el-input v-model="bank.city" placeholder="Enter bank city" />
          </el-form-item>

          <el-form-item label="Branch Name">
            <el-input v-model="bank.branchName" placeholder="Enter bank branch name" />
          </el-form-item>

          <el-form-item label="Branch Address">
            <el-input v-model="bank.branchAddress" placeholder="Enter bank branch address" />
          </el-form-item>

          <el-form-item label="Currency">
            <el-input v-model="bank.currency" placeholder="Enter currency" />
          </el-form-item>

          <el-form-item label="Is Main Account">
            <el-radio :model-value="bank.isMain" :label="true" @change="setMainBank(idx)">
              Main Account
            </el-radio>
          </el-form-item>

          <el-divider>Attachments</el-divider>

          <el-form-item label="Bank Confirmation Letter">
            <el-upload
              v-model:file-list="bank.bankLetter"
              :auto-upload="false"
              :limit="1"
              list-type="text"
            >
              <el-button type="primary">Upload</el-button>
            </el-upload>
          </el-form-item>

          <el-form-item label="IBAN Proof Document">
            <el-upload
              v-model:file-list="bank.ibanProof"
              :auto-upload="false"
              :limit="1"
              list-type="text"
            >
              <el-button type="primary">Upload</el-button>
            </el-upload>
          </el-form-item>
        </el-form>
      </div>
    </div>

    <div v-show="activeStep === 5">
      <h2>Login Credentials</h2>

      <el-form :model="model.credentials" label-width="180px" class="step-form">
        <el-form-item label="Login Email">
          <el-input v-model="model.credentials.loginEmail" placeholder="Enter login email" />
        </el-form-item>

        <el-form-item label="Password">
          <el-input
            v-model="model.credentials.password"
            type="password"
            show-password
            placeholder="Enter password"
          />
        </el-form-item>

        <el-form-item label="Confirm Password">
          <el-input
            v-model="model.credentials.confirmPassword"
            type="password"
            show-password
            placeholder="Confirm password"
          />
        </el-form-item>
      </el-form>
    </div>

    <div v-show="activeStep === 0">
      <h2>Order Summary</h2>

      <div class="summary-card">
        <div class="summary-section">
          <div class="summary-title-row">
            <h3>Company Information</h3>
            <el-button text type="primary" @click="goToStep(1)">Edit</el-button>
          </div>
          <p><strong>Company Name:</strong> {{ model.companyInfo.companyName || "-" }}</p>
          <p><strong>Company Code:</strong> {{ model.companyInfo.companyCode || "-" }}</p>
          <p><strong>CR Number:</strong> {{ model.companyInfo.crNumber || "-" }}</p>
          <p><strong>VAT Number:</strong> {{ model.companyInfo.vatNumber || "-" }}</p>
        </div>

        <div class="summary-section">
          <div class="summary-title-row">
            <h3>Owner / Manager</h3>
            <el-button text type="primary" @click="goToStep(2)">Edit</el-button>
          </div>
          <p><strong>Name:</strong> {{ model.ownerInfo.name || "-" }}</p>
          <p><strong>Position:</strong> {{ model.ownerInfo.position || "-" }}</p>
          <p><strong>ID Number:</strong> {{ model.ownerInfo.idNumber || "-" }}</p>
        </div>

        <div class="summary-section">
          <div class="summary-title-row">
            <h3>Branches / Locations</h3>
            <el-button text type="primary" @click="goToStep(3)">Edit</el-button>
          </div>
          <div v-for="(branch, idx) in model.branches" :key="`summary-branch-${idx}`" class="summary-item">
            <p><strong>Branch {{ idx + 1 }}:</strong> {{ branch.branchName || "-" }}</p>
            <p><strong>Main Branch:</strong> {{ branch.isMain ? "Yes" : "No" }}</p>
          </div>
        </div>

        <div class="summary-section">
          <div class="summary-title-row">
            <h3>Bank Details</h3>
            <el-button text type="primary" @click="goToStep(4)">Edit</el-button>
          </div>
          <div v-for="(bank, idx) in model.banks" :key="`summary-bank-${idx}`" class="summary-item">
            <p><strong>Bank {{ idx + 1 }}:</strong> {{ bank.bankName || "-" }}</p>
            <p><strong>IBAN:</strong> {{ bank.iban || "-" }}</p>
            <p><strong>Main Account:</strong> {{ bank.isMain ? "Yes" : "No" }}</p>
          </div>
        </div>

        <div class="summary-section">
          <div class="summary-title-row">
            <h3>Login Credentials</h3>
            <el-button text type="primary" @click="goToStep(5)">Edit</el-button>
          </div>
          <p><strong>Login Email:</strong> {{ model.credentials.loginEmail || "-" }}</p>
        </div>
      </div>
    </div>

    <div class="wizard-actions">
      <el-button @click="prevStep" :disabled="activeStep === 0">Previous</el-button>

      <div class="wizard-actions-right">
        <el-button plain @click="emit('toLogin')">Back to Login</el-button>

        <el-button
          v-if="activeStep < steps.length - 1"
          @click="nextStep"
          type="primary"
        >
          Next
        </el-button>

        <el-button
          v-else
          @click="emit('submit')"
          type="success"
          :loading="loading"
        >
          Submit
        </el-button>
      </div>
    </div>
  </section>
</template>

<style scoped>
.register-wizard {
  width: 100%;
}

.subtitle {
  margin-top: 0.5rem;
  margin-bottom: 1.5rem;
  color: #6b7280;
}

.wizard-steps {
  margin-bottom: 2rem;
}

.step-form {
  margin-top: 1rem;
}

.section-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 1rem;
}

.dynamic-card {
  border: 1px solid #e5e7eb;
  border-radius: 14px;
  padding: 1rem;
  margin-bottom: 1rem;
  background: #fafafa;
}

.dynamic-card-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 1rem;
}

.summary-card {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.summary-section {
  border: 1px solid #e5e7eb;
  border-radius: 14px;
  padding: 1rem;
  background: #fafafa;
}

.summary-title-row {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 0.75rem;
}

.summary-item {
  padding: 0.75rem 0;
  border-top: 1px solid #e5e7eb;
}

.summary-item:first-of-type {
  border-top: 0;
  padding-top: 0;
}

.wizard-actions {
  display: flex;
  justify-content: space-between;
  margin-top: 2rem;
}

.wizard-actions-right {
  display: flex;
  gap: 0.75rem;
}
</style>