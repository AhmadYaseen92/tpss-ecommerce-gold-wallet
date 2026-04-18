import { computed, ref } from "vue";
import type { ReturnTypeUseMarketplace } from "../../../shared/app/store/useMarketplace";

function readNoteValue(notes: string | undefined, key: string): string | null {
  if (!notes) return null;
  const marker = `${key}=`;
  const lower = notes.toLowerCase();
  const index = lower.indexOf(marker.toLowerCase());
  if (index < 0) return null;

  const rawTail = notes.slice(index + marker.length).trim();
  if (!rawTail) return null;

  const stopCandidates = ["|", ",", ";", " "]
    .map((separator) => rawTail.indexOf(separator))
    .filter((value) => value >= 0);
  const stop = stopCandidates.length ? Math.min(...stopCandidates) : rawTail.length;
  const value = rawTail.slice(0, stop).trim();
  return value || null;
}

function formatInvestor(id: string | null): string {
  return id ? `Investor #${id}` : "Unknown";
}

export function useTransactions(marketplace: ReturnTypeUseMarketplace) {
  const selectedTransactionId = ref<string | null>(null);
  const transactionStatusDraft = ref<"pending" | "approved" | "rejected">("pending");
  const searchTerm = ref("");
  const statusFilter = ref<"all" | "pending" | "approved" | "rejected" | "pending_delivered" | "delivered">("all");
  const typeFilter = ref<"all" | "withdrawal" | "pickup" | "sell" | "transfer" | "buy" | "gift">("all");

  const transactionsView = computed(() =>
    marketplace.state.value.requests
      .map((request) => ({
        ...request,
        investorName: request.investorName,
        transactionType: request.type,
        productName: request.productName || request.category,
        transferFrom: (() => {
          const type = (request.type || "").toLowerCase();
          if (type !== "transfer" && type !== "gift") return undefined;
          const direction = (readNoteValue(request.notes, "direction") || "").toLowerCase();
          if (direction === "received") {
            return readNoteValue(request.notes, "from_investor_name")
              || formatInvestor(readNoteValue(request.notes, "from_investor_user_id"));
          }
          return request.investorName;
        })(),
        transferTo: (() => {
          const type = (request.type || "").toLowerCase();
          if (type !== "transfer" && type !== "gift") return undefined;
          const direction = (readNoteValue(request.notes, "direction") || "").toLowerCase();
          if (direction === "received") {
            return request.investorName;
          }
          return readNoteValue(request.notes, "recipient_investor_name")
            || formatInvestor(readNoteValue(request.notes, "recipient_investor_user_id"));
        })()
      }))
      .filter((request) => {
        if (statusFilter.value !== "all" && request.status !== statusFilter.value) return false;
        if (typeFilter.value !== "all" && request.transactionType !== typeFilter.value) return false;
        if (!searchTerm.value.trim()) return true;

        const term = searchTerm.value.trim().toLowerCase();
        return [
          request.id,
          request.investorName,
          request.productName,
          request.category,
          request.transactionType,
          request.notes || ""
        ]
          .join(" ")
          .toLowerCase()
          .includes(term);
      })
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

  return {
    selectedTransactionId,
    transactionStatusDraft,
    transactionsView,
    selectedTransaction,
    viewTransaction,
    saveTransactionStatus,
    searchTerm,
    statusFilter,
    typeFilter
  };
}
