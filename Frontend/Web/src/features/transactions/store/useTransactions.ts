import { computed, ref } from "vue";
import type { ReturnTypeUseMarketplace } from "../../../shared/app/store/useMarketplace";

export function useTransactions(marketplace: ReturnTypeUseMarketplace) {
  const selectedTransactionId = ref<string | null>(null);
  const transactionStatusDraft = ref<"pending" | "approved" | "rejected">("pending");

  const transactionsView = computed(() =>
    marketplace.state.value.requests.map((request, idx) => ({
      ...request,
      investorName: marketplace.state.value.investors.find((inv) => inv.id === request.investorId)?.fullName ?? request.investorId,
      productName: marketplace.state.value.products[idx % Math.max(marketplace.state.value.products.length, 1)]?.name ?? "N/A",
      transactionType: idx % 2 === 0 ? "Buy" : "Sell",
      transactionPrice: marketplace.state.value.products[idx % Math.max(marketplace.state.value.products.length, 1)]?.unitPrice ?? 0
    }))
  );

  const selectedTransaction = computed(() => transactionsView.value.find((x) => x.id === selectedTransactionId.value) ?? null);

  const viewTransaction = (id: string) => {
    selectedTransactionId.value = id;
    transactionStatusDraft.value = (transactionsView.value.find((x) => x.id === id)?.status ?? "pending") as "pending" | "approved" | "rejected";
  };

  const saveTransactionStatus = () => {
    if (!selectedTransactionId.value) return;
    marketplace.updateRequestStatus(selectedTransactionId.value, transactionStatusDraft.value);
  };

  return { selectedTransactionId, transactionStatusDraft, transactionsView, selectedTransaction, viewTransaction, saveTransactionStatus };
}
