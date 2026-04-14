import { computed, ref } from "vue";
import type { ReturnTypeUseMarketplace } from "../../../shared/app/store/useMarketplace";

export function useInvestors(marketplace: ReturnTypeUseMarketplace) {
  const selectedInvestorId = ref<string | null>(null);
  const investorRows = computed(() => marketplace.state.value.investors.map((inv, idx) => {
    const totalTransactions = marketplace.state.value.requests.filter((r) => r.investorId === inv.id).length;
    return { ...inv, email: `${inv.fullName.toLowerCase().replace(/\s+/g, ".")}@mail.com`, totalTransactions, totalPurchases: totalTransactions * 250, createdDate: `2026-04-${String(10 + idx).padStart(2, "0")}`, lastTransactionDate: marketplace.state.value.requests.find((r) => r.investorId === inv.id)?.createdAt ?? "-" };
  }));
  const selectedInvestor = computed(() => investorRows.value.find((x) => x.id === selectedInvestorId.value) ?? null);
  const toggleInvestorStatus = (id: string) => {
    const investor = marketplace.state.value.investors.find((x) => x.id === id);
    if (investor) investor.status = investor.status === "active" ? "review" : "active";
  };
  return { selectedInvestorId, investorRows, selectedInvestor, toggleInvestorStatus };
}
