<script setup lang="ts">
import RegisterPage from "./RegisterPage.vue";
import type { RegisterFormModel } from "../types/authTypes";

defineProps<{ model: RegisterFormModel; loading: boolean; title?: string }>();
const emit = defineEmits<{ submit: []; toLogin: [] }>();
</script>

<template>
  <RegisterPage :model="model" :loading="loading" :title="title ?? 'Sign Up'" @submit="emit('submit')" @to-login="emit('toLogin')" />
</template>
