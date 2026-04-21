<script setup lang="ts">
import { ref, watch } from "vue";
import { useRoute, useRouter } from "vue-router";
import LoginPage from "./LoginPage.vue";
import RegisterPage from "./RegisterPage.vue";

defineProps<{ marketplace: unknown }>();

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
  <LoginPage v-if="mode === 'login'" @to-register="mode = 'register'" />
  <RegisterPage v-else @to-login="mode = 'login'" />
</template>
