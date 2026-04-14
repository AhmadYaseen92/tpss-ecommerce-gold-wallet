<script setup lang="ts">
import { ref, watch } from "vue";
import type { ReturnTypeUseMarketplace } from "../../../shared/app/store/useMarketplace";
import BaseFormField from "../../../shared/components/BaseFormField.vue";
import CommonModal from "../../../shared/components/CommonModal.vue";
import { useAuthPage } from "../store/useAuthPage";

const { marketplace } = defineProps<{ marketplace: ReturnTypeUseMarketplace }>();
const { authScreen, loginForm, registerForm, registerErrors, registerSellerAction, setKycFile } = useAuthPage(marketplace);

const messageModalOpen = ref(false);
const messageModalTitle = ref("Message");
const messageModalBody = ref("");

const openMessageModal = (title: string, body: string) => {
  messageModalTitle.value = title;
  messageModalBody.value = body;
  messageModalOpen.value = true;
};

const onLoginSubmit = async () => {
  await marketplace.login({ email: loginForm.email, password: loginForm.password });
};

const onKycFileChange = (event: Event, field: "nationalIdFront" | "nationalIdBack" | "tradeLicense") => {
  const target = event.target as HTMLInputElement;
  setKycFile(field, target.files?.[0] ?? null);
};

watch(
  () => marketplace.error.value,
  (value) => {
    if (value) {
      const title = authScreen.value === "login" ? "Login Failed" : "Registration Error";
      openMessageModal(title, value);
    }
  }
);
</script>

<template>
  <section class="login-page">
    <div class="auth-card large">
      <h1>{{ authScreen === 'login' ? 'Welcome Back' : 'Create Seller Account' }}</h1>
      <p v-if="authScreen === 'login'">Sign in to continue to your dashboard.</p>
      <p v-else>Register seller account with KYC details and wait for admin approval.</p>

      <form v-if="authScreen === 'login'" @submit.prevent="onLoginSubmit">
        <BaseFormField label="Email" hint="Use your seller login email." required>
          <input v-model="loginForm.email" type="email" placeholder="seller@company.com" required />
        </BaseFormField>
        <BaseFormField label="Password" hint="Enter your seller login password." required>
          <input v-model="loginForm.password" type="password" placeholder="********" required />
        </BaseFormField>
        <div class="auth-options">
          <label class="remember"><input v-model="loginForm.rememberMe" type="checkbox" /> Remember me</label>
          <a href="#">Forgot password?</a>
        </div>
        <button :disabled="marketplace.loading.value" type="submit" class="full-btn">Login</button>
      </form>

      <form v-else class="register-form" @submit.prevent="registerSellerAction">
        <div class="grid-two">
          <BaseFormField label="Full Name" hint="Enter legal full name as per ID." :error="registerErrors.fullName" required>
            <input v-model="registerForm.fullName" placeholder="Full Name" :class="{ 'input-error': registerErrors.fullName }" required />
          </BaseFormField>

          <BaseFormField label="Seller Login Email" hint="This will be used for login." :error="registerErrors.email" required>
            <input v-model="registerForm.email" type="email" placeholder="Seller Login Email" :class="{ 'input-error': registerErrors.email }" required />
          </BaseFormField>

          <BaseFormField label="Contact Phone" hint="Include country code." :error="registerErrors.phoneNumber" required>
            <input v-model="registerForm.phoneNumber" placeholder="Contact Phone" :class="{ 'input-error': registerErrors.phoneNumber }" required />
          </BaseFormField>

          <BaseFormField label="Seller Login Password" hint="Minimum 8 characters." :error="registerErrors.password" required>
            <input v-model="registerForm.password" type="password" placeholder="Seller Login Password" :class="{ 'input-error': registerErrors.password }" required />
          </BaseFormField>

          <BaseFormField label="Confirm Password" hint="Must match password." :error="registerErrors.confirmPassword" required>
            <input v-model="registerForm.confirmPassword" type="password" placeholder="Confirm Seller Login Password" :class="{ 'input-error': registerErrors.confirmPassword }" required />
          </BaseFormField>

          <BaseFormField label="Country" hint="Business registration country." :error="registerErrors.country" required>
            <input v-model="registerForm.country" placeholder="Country" :class="{ 'input-error': registerErrors.country }" required />
          </BaseFormField>

          <BaseFormField label="City" hint="Business city." :error="registerErrors.city" required>
            <input v-model="registerForm.city" placeholder="City" :class="{ 'input-error': registerErrors.city }" required />
          </BaseFormField>

          <BaseFormField label="Street" hint="Business street address." :error="registerErrors.street" required>
            <input v-model="registerForm.street" placeholder="Street" :class="{ 'input-error': registerErrors.street }" required />
          </BaseFormField>

          <BaseFormField label="Building Number" hint="Business building number." :error="registerErrors.buildingNumber" required>
            <input v-model="registerForm.buildingNumber" placeholder="Building Number" :class="{ 'input-error': registerErrors.buildingNumber }" required />
          </BaseFormField>

          <BaseFormField label="Postal Code" hint="Business postal code." :error="registerErrors.postalCode" required>
            <input v-model="registerForm.postalCode" placeholder="Postal Code" :class="{ 'input-error': registerErrors.postalCode }" required />
          </BaseFormField>

          <BaseFormField label="Company Name" hint="Registered company name." :error="registerErrors.companyName" required>
            <input v-model="registerForm.companyName" placeholder="Company Name" :class="{ 'input-error': registerErrors.companyName }" required />
          </BaseFormField>

          <BaseFormField label="Trade License Number" hint="License number from authority." :error="registerErrors.tradeLicenseNumber" required>
            <input v-model="registerForm.tradeLicenseNumber" placeholder="Trade License Number" :class="{ 'input-error': registerErrors.tradeLicenseNumber }" required />
          </BaseFormField>

          <BaseFormField label="VAT Number" hint="Tax/VAT registration number." :error="registerErrors.vatNumber" required>
            <input v-model="registerForm.vatNumber" placeholder="VAT Number" :class="{ 'input-error': registerErrors.vatNumber }" required />
          </BaseFormField>

          <BaseFormField label="National ID Number" hint="Owner national ID number." :error="registerErrors.nationalIdNumber" required>
            <input v-model="registerForm.nationalIdNumber" placeholder="National ID Number" :class="{ 'input-error': registerErrors.nationalIdNumber }" required />
          </BaseFormField>

          <BaseFormField label="Bank Name" hint="Bank for settlement account." :error="registerErrors.bankName" required>
            <input v-model="registerForm.bankName" placeholder="Bank Name" :class="{ 'input-error': registerErrors.bankName }" required />
          </BaseFormField>

          <BaseFormField label="IBAN" hint="International bank account number." :error="registerErrors.iban" required>
            <input v-model="registerForm.iban" placeholder="IBAN" :class="{ 'input-error': registerErrors.iban }" required />
          </BaseFormField>

          <BaseFormField label="Account Holder Name" hint="Name on bank account." :error="registerErrors.accountHolderName" required>
            <input v-model="registerForm.accountHolderName" placeholder="Account Holder Name" :class="{ 'input-error': registerErrors.accountHolderName }" required />
          </BaseFormField>

          <BaseFormField label="National ID Front" hint="Attach front side image/pdf." :error="registerErrors.nationalIdFrontPath" required>
            <input type="file" accept="image/*,.pdf" :class="{ 'input-error': registerErrors.nationalIdFrontPath }" @change="onKycFileChange($event, 'nationalIdFront')" required />
          </BaseFormField>

          <BaseFormField label="National ID Back" hint="Attach back side image/pdf." :error="registerErrors.nationalIdBackPath" required>
            <input type="file" accept="image/*,.pdf" :class="{ 'input-error': registerErrors.nationalIdBackPath }" @change="onKycFileChange($event, 'nationalIdBack')" required />
          </BaseFormField>

          <BaseFormField label="Trade License File" hint="Attach trade license image/pdf." :error="registerErrors.tradeLicensePath" required>
            <input type="file" accept="image/*,.pdf" :class="{ 'input-error': registerErrors.tradeLicensePath }" @change="onKycFileChange($event, 'tradeLicense')" required />
          </BaseFormField>
        </div>
        <button :disabled="marketplace.loading.value" type="submit" class="full-btn">Create account</button>
      </form>

      <p class="register-text" v-if="authScreen === 'login'">Don’t have an account? <button class="link-btn" @click="authScreen = 'register'">Register now</button></p>
      <p class="register-text" v-else>Already have an account? <button class="link-btn" @click="authScreen = 'login'">Back to login</button></p>
    </div>

    <CommonModal
      :open="messageModalOpen"
      :title="messageModalTitle"
      :message="messageModalBody"
      @close="messageModalOpen = false; marketplace.error.value = ''"
    />
  </section>
</template>
