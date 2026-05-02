<script setup lang="ts">
import { ref } from "vue";
import { ElMessageBox } from "element-plus";
import { requestPasswordResetOtp } from "../services/authService";

const email = ref("");
const loading = ref(false);

const onSubmit = async () => {
  if (!email.value.trim()) {
    await ElMessageBox.alert("Email is required.", "Validation Error", { confirmButtonText: "OK", type: "warning" });
    return;
  }
  loading.value = true;
  try {
    await requestPasswordResetOtp({ email: email.value });
    await ElMessageBox.alert("OTP sent to your email. Please check your inbox.", "Success", { confirmButtonText: "OK", type: "success" });
    window.location.href = "/reset-password";
  } catch (e: any) {
    await ElMessageBox.alert(e?.message || "Failed to send OTP.", "Error", { confirmButtonText: "OK", type: "error" });
  } finally {
    loading.value = false;
  }
};
</script>

<template>
  <section class="forgot-password-page">
    <div class="auth-card">
      <h1>Forgot Password</h1>
      <form @submit.prevent="onSubmit">
        <div class="form-group">
          <label>Email</label>
          <input v-model="email" type="email" placeholder="Enter your email" required />
        </div>
        <button class="submit-btn" :disabled="loading" type="submit">
          {{ loading ? "Sending..." : "Send OTP" }}
        </button>
      </form>
    </div>
  </section>
</template>

<style scoped>
.forgot-password-page {
  display: flex;
  align-items: center;
  justify-content: center;
  min-height: 100vh;
}
.auth-card {
  background: #fff;
  padding: 32px;
  border-radius: 12px;
  box-shadow: 0 2px 16px rgba(0,0,0,0.08);
  width: 350px;
}
.form-group {
  margin-bottom: 18px;
}
.submit-btn {
  width: 100%;
  padding: 10px;
  background: #d6a82d;
  color: #fff;
  border: none;
  border-radius: 6px;
  font-weight: bold;
  cursor: pointer;
}
.submit-btn:disabled {
  opacity: 0.7;
  cursor: not-allowed;
}
</style>
