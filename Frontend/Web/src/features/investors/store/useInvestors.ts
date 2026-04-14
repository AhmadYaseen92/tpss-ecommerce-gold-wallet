import { ref } from "vue";

export function useInvestors() {
  const selectedInvestorId = ref<string | null>(null);
  return { selectedInvestorId };
}
