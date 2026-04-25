<script setup lang="ts">
withDefaults(
  defineProps<{
    open: boolean;
    title?: string;
    message: string;
    type?: "info" | "success" | "warning" | "danger";
    buttonText?: string;
  }>(),
  {
    title: "Notice",
    type: "info",
    buttonText: "OK",
  }
);

const emit = defineEmits<{
  close: [];
}>();
</script>

<template>
  <div v-if="open" class="common-modal-overlay" @click.self="emit('close')">
    <div class="common-modal">

      <div class="ui-modal-header">
        <h3 :class="`ui-modal-title ui-modal-title--${type}`">
          {{ title }}
        </h3>
      </div>

      <p class="ui-modal-message">
        {{ message }}
      </p>

      <div class="ui-modal-actions">
        <button
          class="ui-btn ui-btn--primary ui-btn--full"
          @click="emit('close')"
        >
          {{ buttonText }}
        </button>
      </div>

    </div>
  </div>
</template>