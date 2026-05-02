<script setup lang="ts">
import { ref } from "vue";
import { ElMessageBox } from "element-plus";
import { changePassword } from "../services/authService";

const oldPassword = ref("");
const newPassword = ref("");
const confirmPassword = ref("");
const loading = ref(false);

const onSubmit = async () => {
  if (!oldPassword.value.trim() || !newPassword.value.trim() || !confirmPassword.value.trim()) {
    await ElMessageBox.alert("All fields are required.", "Validation Error", { confirmButtonText: "OK", type: "warning" });
    return;
  }
  if (newPassword.value !== confirmPassword.value) {
    await ElMessageBox.alert("Passwords do not match.", "Validation Error", { confirmButtonText: "OK", type: "warning" });
    return;
  }
  loading.value = true;
  try {
    await changePassword({ oldPassword: oldPassword.value, newPassword: newPassword.value });
    await ElMessageBox.alert("Password changed successfully.", "Success", { confirmButtonText: "OK", type: "success" });
    window.location.href = "/overview";
  } catch (e: any) {
    await ElMessageBox.alert(e?.message || "Failed to change password.", "Error", { confirmButtonText: "OK", type: "error" });
  } finally {
    loading.value = false;
  }
};
</script>

<template>
  <section class="change-password-page">
    <div class="auth-card">
      <h1>Change Password</h1>
      <form @submit.prevent="onSubmit">
        <div class="form-group">
          <label>Old Password</label>
          <input v-model="oldPassword" type="password" placeholder="Old password" required />
        </div>
        <div class="form-group">
          <label>New Password</label>
          <input v-model="newPassword" type="password" placeholder="New password" required />
        </div>
        <div class="form-group">
          <label>Confirm Password</label>
          <input v-model="confirmPassword" type="password" placeholder="Confirm new password" required />
        </div>
        <button class="submit-btn" :disabled="loading" type="submit">
          {{ loading ? "Changing..." : "Change Password" }}
        </button>
      </form>
    </div>
  </section>
</template>

<style scoped>
.change-password-page {
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
