import { computed, ref } from "vue";
import type { ReturnTypeUseMarketplace } from "../../../shared/app/store/useMarketplace";
import { updateInvestorStatusByAdmin } from "../../../shared/services/backendGateway";

export function useInvestors(marketplace: ReturnTypeUseMarketplace) {
  const selectedInvestorId = ref<string | null>(null);
  const investorRows = computed(() => marketplace.state.value.investors.map((inv) => {
    const totalTransactions = inv.totalTransactions ?? marketplace.state.value.requests.filter((r) => r.investorId === inv.id).length;
    return {
      ...inv,
      email: inv.email ?? "",
      totalTransactions,
      totalPurchases: totalTransactions * 250,
      createdDate: inv.createdAt ? new Date(inv.createdAt).toISOString().slice(0, 10) : "-",
      lastTransactionDate: marketplace.state.value.requests.find((r) => r.investorId === inv.id)?.createdAt ?? "-"
    };
  }));
  const selectedInvestor = computed(() => investorRows.value.find((x) => x.id === selectedInvestorId.value) ?? null);
  const toggleInvestorStatus = async (id: string) => {
    const investor = marketplace.state.value.investors.find((x) => x.id === id);
    if (!investor || !marketplace.session.value?.accessToken) return;
    const nextStatus = investor.status === "active" ? "blocked" : "active";
    await updateInvestorStatusByAdmin(marketplace.session.value.accessToken, id, nextStatus);
    await marketplace.refreshMarketplaceState();
  };
  return { selectedInvestorId, investorRows, selectedInvestor, toggleInvestorStatus };
}
