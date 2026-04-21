<script setup lang="ts">
import { ref } from "vue";
import LoginPage from "./LoginPage.vue";
import RegisterPage from "./RegisterPage.vue";

defineProps<{ marketplace: unknown }>();
const mode = ref<"login" | "register">("login");
</script>

<template>
  <LoginPage v-if="mode === 'login'" @to-register="mode = 'register'" />
  <RegisterPage v-else @to-login="mode = 'login'" />
</template>
