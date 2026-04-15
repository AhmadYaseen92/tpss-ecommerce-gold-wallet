import { computed, ref } from "vue";
import type { ReturnTypeUseMarketplace } from "../../../shared/app/store/useMarketplace";

export function useTransactions(marketplace: ReturnTypeUseMarketplace) {
  const selectedTransactionId = ref<string | null>(null);
  const transactionStatusDraft = ref<"pending" | "approved" | "rejected">("pending");

  const transactionsView = computed(() =>
    marketplace.state.value.requests.map((request) => ({
      ...request,
      investorName: request.investorName,
      transactionType: request.type
    }))
  );

  const selectedTransaction = computed(() => transactionsView.value.find((x) => x.id === selectedTransactionId.value) ?? null);

  const viewTransaction = (id: string) => {
    selectedTransactionId.value = id;
    transactionStatusDraft.value = (transactionsView.value.find((x) => x.id === id)?.status ?? "pending") as "pending" | "approved" | "rejected";
  };

  const saveTransactionStatus = async () => {
    if (!selectedTransactionId.value) return;
    const selected = transactionsView.value.find((x) => x.id === selectedTransactionId.value);
    if (selected && selected.status !== "pending") {
      window.alert("Only pending requests can be updated.");
      return;
    }
    const confirmed = window.confirm(`Are you sure you want to change request status to "${transactionStatusDraft.value}"?`);
    if (!confirmed) return;
    await marketplace.updateRequestStatus(selectedTransactionId.value, transactionStatusDraft.value);
  };

  return { selectedTransactionId, transactionStatusDraft, transactionsView, selectedTransaction, viewTransaction, saveTransactionStatus };
}
