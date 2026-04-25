<script setup lang="ts">
withDefaults(
  defineProps<{
    open: boolean;
    title?: string;
    message?: string;
    type?: "info" | "success" | "warning" | "danger";
    confirmText?: string;
    cancelText?: string;
    loading?: boolean;
  }>(),
  {
    type: "info",
    confirmText: "Confirm",
    cancelText: "Cancel",
    loading: false,
  }
);

const emit = defineEmits<{
  confirm: [];
  close: [];
}>();
</script>

<template>
  <div v-if="open" class="common-modal-overlay" @click.self="emit('close')">
    <div class="common-modal">

      <div class="ui-modal-header">
        <h3>{{ title }}</h3>
      </div>

      <p v-if="message" class="ui-modal-message">
        {{ message }}
      </p>

      <div class="ui-modal-actions">
        <button class="ui-btn ui-btn--ghost" @click="emit('close')" :disabled="loading">
          {{ cancelText }}
        </button>

        <button
          class="ui-btn"
          :class="`ui-btn--${type}`"
          @click="emit('confirm')"
          :disabled="loading"
        >
          <span v-if="loading" class="ui-spinner"></span>
          {{ confirmText }}
        </button>
      </div>

    </div>
  </div>
</template>