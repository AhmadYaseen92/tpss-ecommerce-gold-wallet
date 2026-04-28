import { computed } from "vue";
import type { ReturnTypeUseMarketplace } from "../../../shared/app/store/useMarketplace";
import { updateInvestorStatusByAdmin } from "../../../shared/services/backendGateway";
import type { Investor, InvestorRequest } from "../../../shared/types/models";
import type { InvestorRowView } from "../types/investorTypes";

export function useInvestors(marketplace: ReturnTypeUseMarketplace) {
  const investorRows = computed<InvestorRowView[]>(() => marketplace.state.value.investors.map((inv: Investor) => {
    const investorRequests = marketplace.state.value.requests.filter((r: InvestorRequest) => r.investorId === inv.id);
    const totalTransactions = inv.totalTransactions ?? investorRequests.length;
    const approvedTransactions = investorRequests.filter((r: InvestorRequest) => r.status === "approved").length;
    const pendingTransactions = investorRequests.filter((r: InvestorRequest) => r.status === "pending").length;
    const rejectedTransactions = investorRequests.filter((r: InvestorRequest) => r.status === "rejected").length;
    const sortedDates = investorRequests
      .map((r: InvestorRequest) => r.createdAt)
      .filter(Boolean)
      .sort((a: string, b: string) => new Date(a).getTime() - new Date(b).getTime());
    const totalVolume = investorRequests.reduce((sum: number, item: InvestorRequest) => sum + Number(item.finalAmount ?? item.amount ?? 0), 0);
    const walletAssetsCount = marketplace.state.value.walletAssets.filter((asset: { sellerName: string }) => {
      if (!asset.sellerName) return false;
      const investorName = (inv.fullName ?? "").trim().toLowerCase();
      return investorName.length > 0 && asset.sellerName.trim().toLowerCase().includes(investorName);
    }).length;

    return {
      ...inv,
      investorNumericId: Number(String(inv.id).replace("i-", "")) || 0,
      phoneNumber: inv.phoneNumber ?? "-",
      walletBalance: Number(inv.walletBalance ?? 0),
      riskLevel: inv.riskLevel ?? "medium",
      email: inv.email ?? "",
      totalTransactions,
      totalPurchases: totalVolume,
      createdDate: inv.createdAt ? new Date(inv.createdAt).toISOString().slice(0, 10) : "-",
      lastTransactionDate: sortedDates.length ? sortedDates[sortedDates.length - 1] : "-",
      firstTransactionDate: sortedDates.length ? sortedDates[0] : "-",
      approvedTransactions,
      pendingTransactions,
      rejectedTransactions,
      totalVolume,
      lastActivityDate: sortedDates.length ? sortedDates[sortedDates.length - 1] : (inv.createdAt ?? "-"),
      walletAssetsCount
    };
  }));
  const toggleInvestorStatus = async (id: string) => {
    const investor = marketplace.state.value.investors.find((x: Investor) => x.id === id);
    if (!investor || !marketplace.session.value?.accessToken) return;
    const nextStatus = investor.status === "active" ? "blocked" : "active";
    await updateInvestorStatusByAdmin(marketplace.session.value.accessToken, id, nextStatus);
    await marketplace.refreshMarketplaceState();
  };
  return { investorRows, toggleInvestorStatus };
}
