<script setup lang="ts">
import { reactive, computed } from "vue";
import { ElMessageBox } from "element-plus";
import LoginForm from "../components/LoginForm.vue";
import type { LoginFormModel } from "../types/authTypes";
import { useMarketplace } from "../../../shared/app/store/useMarketplace";

const emit = defineEmits<{ toRegister: []; themeToggle: [] }>();
const props = withDefaults(defineProps<{ isDark?: boolean }>(), { isDark: false });
const marketplace = useMarketplace();

const model = reactive<LoginFormModel>({
  email: "admin@goldwallet.com",
  password: "P@ssw0rd",
  rememberMe: true,
});

const loading = computed(() => marketplace.loading.value);

const onSubmit = async () => {
  if (!model.email?.trim() || !model.password?.trim()) {
    await ElMessageBox.alert("Email and password are required.", "Validation Error", {
      confirmButtonText: "OK",
      type: "warning",
    });
    return;
  }

  await marketplace.login({ emailOrPhone: model.email, password: model.password });

  if (!marketplace.error.value && marketplace.session.value) {
    window.history.replaceState({}, "", "/overview");
    window.dispatchEvent(new PopStateEvent("popstate"));
    return;
  }

  if (marketplace.error.value) {
    await ElMessageBox.alert(marketplace.error.value, "Login Failed", {
      confirmButtonText: "OK",
      type: "warning",
    });
  }
};

const onForgot = () => {
  console.log("Forgot password clicked");
};
</script>

<template>
  <section class="login-page">
    <div class="login-overlay"></div>

    <div class="login-shell">
      <div class="brand-panel">
        <p class="brand-kicker">Secure Trading Platform</p>
        <h2>Gold Wallet Control Center</h2>
        <p>
          Manage sellers, investors, products, transactions, reports, and wallet operations from one premium dashboard.
        </p>
      </div>

      <div class="auth-card auth-card--login">
        <button class="theme-toggle-btn" type="button" @click="emit('themeToggle')">
          {{ props.isDark ? "Light Theme" : "Dark Theme" }}
        </button>
        <p class="login-kicker">Gold Wallet Admin</p>
        <h1>Welcome Back</h1>
        <p class="login-subtitle">Sign in to continue to your dashboard.</p>

        <LoginForm
          :model="model"
          :loading="loading"
          @submit="onSubmit"
          @forgot="onForgot"
          @to-register="emit('toRegister')"
        />
      </div>
    </div>
  </section>
</template>

<style scoped>
.login-page {
  min-height: 100vh;
  position: relative;
  overflow: hidden;
  background:
    linear-gradient(90deg, rgba(7, 7, 6, 0.25), rgba(7, 7, 6, 0.9) 58%, rgba(7, 7, 6, 0.98)),
    url("/images/gold-wallet-login.png");
  background-size: cover;
  background-position: left center;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 48px;
}

.login-overlay {
  position: absolute;
  inset: 0;
  background:
    radial-gradient(circle at 18% 70%, rgba(214, 168, 45, 0.2), transparent 34%),
    radial-gradient(circle at 80% 20%, rgba(214, 168, 45, 0.12), transparent 28%);
  pointer-events: none;
}

.login-shell {
  position: relative;
  z-index: 1;
  width: min(1180px, 100%);
  display: grid;
  grid-template-columns: 1fr 420px;
  align-items: center;
  gap: 56px;
}

.brand-panel {
  max-width: 520px;
  color: #fff4d0;
  margin-top: 260px;
}

.brand-kicker {
  margin: 0 0 12px;
  color: #f1c34b;
  font-size: 12px;
  font-weight: 900;
  letter-spacing: 0.18em;
  text-transform: uppercase;
}

.brand-panel h2 {
  margin: 0;
  font-size: clamp(34px, 4vw, 58px);
  line-height: 1.02;
  font-weight: 900;
}

.brand-panel p:not(.brand-kicker) {
  margin: 18px 0 0;
  max-width: 460px;
  color: rgba(255, 244, 208, 0.74);
  font-size: 16px;
  line-height: 1.7;
}

.auth-card {
  position: relative;
  width: 100%;
  border: 1px solid rgba(214, 168, 45, 0.35);
  border-radius: 26px;
  background: linear-gradient(180deg, rgba(32, 28, 18, 0.88), rgba(12, 11, 8, 0.9));
  box-shadow:
    0 28px 80px rgba(0, 0, 0, 0.55),
    0 0 45px rgba(214, 168, 45, 0.12);
  backdrop-filter: blur(16px);
  padding: 34px;
}

.theme-toggle-btn {
  position: absolute;
  right: 16px;
  top: 14px;
  border: 1px solid rgba(214, 168, 45, 0.4);
  background: rgba(0, 0, 0, 0.2);
  color: #fff8e6;
  border-radius: 999px;
  font-size: 11px;
  font-weight: 700;
  padding: 6px 10px;
}

.login-kicker {
  margin: 0 0 10px;
  color: #f1c34b;
  font-size: 11px;
  font-weight: 900;
  letter-spacing: 0.18em;
  text-transform: uppercase;
}

.auth-card h1 {
  margin: 0;
  color: #fff8e6;
  font-size: 34px;
  line-height: 1.1;
  font-weight: 900;
}

.login-subtitle {
  margin: 10px 0 28px;
  color: rgba(255, 248, 230, 0.72);
  font-size: 14px;
  line-height: 1.6;
}

@media (max-width: 900px) {
  .login-page {
    padding: 28px;
    background-position: 28% center;
  }

  .login-shell {
    grid-template-columns: 1fr;
    justify-items: center;
  }

  .brand-panel {
    display: none;
  }

  .auth-card {
    max-width: 430px;
  }
}

@media (max-width: 520px) {
  .login-page {
    padding: 18px;
  }

  .auth-card {
    padding: 26px 20px;
    border-radius: 22px;
  }

  .auth-card h1 {
    font-size: 28px;
  }
}
</style>
