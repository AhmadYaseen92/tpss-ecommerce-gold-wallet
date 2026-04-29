<script setup lang="ts">
import { ref, watch } from "vue";
import { useRoute, useRouter } from "vue-router";
import LoginPage from "./LoginPage.vue";
import RegisterPage from "./RegisterPage.vue";

defineProps<{ marketplace: unknown; isDark?: boolean }>();
const emit = defineEmits<{ themeToggle: [] }>();

const route = useRoute();
const router = useRouter();
const mode = ref<"login" | "register">(route.path.toLowerCase() === "/register" ? "register" : "login");

watch(mode, (value) => {
  const target = value === "login" ? "/Login" : "/Register";
  if (route.path !== target) {
    router.replace(target);
  }
});
</script>

<template>
  <LoginPage
    v-if="mode === 'login'"
    :is-dark="isDark"
    @to-register="mode = 'register'"
    @theme-toggle="emit('themeToggle')"
  />
  <RegisterPage
    v-else
    :is-dark="isDark"
    @to-login="mode = 'login'"
    @theme-toggle="emit('themeToggle')"
  />
</template>
