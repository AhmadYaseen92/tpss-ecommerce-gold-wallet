import { ref } from "vue";

export function useTransactions() {
  const selectedTransactionId = ref<string | null>(null);
  return { selectedTransactionId };
}
