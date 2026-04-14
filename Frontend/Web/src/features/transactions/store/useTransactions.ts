import { computed, ref, type Ref } from "vue";
import type { ReturnTypeUseMarketplace } from "../../dashboard/store/useMarketplace";
import type { ProductManagementDto } from "../../../shared/types/apiTypes";

export function useTransactions(marketplace: ReturnTypeUseMarketplace, managedProducts: Ref<ProductManagementDto[]>, investorRows: Ref<Array<{ id: string; fullName: string }>>) {
  const selectedTransactionId = ref<string | null>(null);
  const transactionStatusDraft = ref<"pending" | "approved" | "rejected">("pending");
  const transactionsView = computed(() => marketplace.state.value.requests.map((request, idx) => ({ ...request, investorName: investorRows.value.find((inv) => inv.id === request.investorId)?.fullName ?? request.investorId, productName: managedProducts.value[idx % Math.max(managedProducts.value.length, 1)]?.name ?? "N/A", transactionType: idx % 2 === 0 ? "Buy" : "Sell", transactionPrice: managedProducts.value[idx % Math.max(managedProducts.value.length, 1)]?.price ?? 0 })));
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
