import { ref } from "vue";

export interface ActionModalState {
  open: boolean;
  title: string;
  message: string;
  tone: "success" | "error" | "info";
}

const defaultState: ActionModalState = {
  open: false,
  title: "Notice",
  message: "",
  tone: "info"
};

export function useActionModal() {
  const modal = ref<ActionModalState>({ ...defaultState });

  const showSuccess = (message: string, title = "Success") => {
    modal.value = { open: true, title, message, tone: "success" };
  };

  const showError = (message: string, title = "Error") => {
    modal.value = { open: true, title, message, tone: "error" };
  };

  const showInfo = (message: string, title = "Notice") => {
    modal.value = { open: true, title, message, tone: "info" };
  };

  const close = () => {
    modal.value = { ...defaultState };
  };

  return {
    modal,
    showSuccess,
    showError,
    showInfo,
    close
  };
}
