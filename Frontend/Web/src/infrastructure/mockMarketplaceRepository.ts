import type { MarketplaceState } from "../domain/models";

export const mockMarketplaceState: MarketplaceState = {
  sellers: [
    {
      id: "s-100",
      userId: 100,
      name: "Lina Kareem",
      email: "lina@desertbullion.com",
      businessName: "Desert Bullion",
      kycStatus: "pending",
      submittedAt: "2026-04-10"
    }
  ],
  investors: [
    { id: "i-1", fullName: "Ahmad Saleh", riskLevel: "medium", walletBalance: 4850, status: "active" },
    { id: "i-2", fullName: "Sara Odeh", riskLevel: "low", walletBalance: 12200, status: "review" }
  ],
  requests: [
    { id: "r-1", investorId: "i-1", type: "withdrawal", amount: 1200, status: "pending", createdAt: "2026-04-13" },
    { id: "r-2", investorId: "i-2", type: "sell", amount: 740, status: "approved", createdAt: "2026-04-12" }
  ],
  products: [
    {
      id: "p-1",
      sellerId: "s-100",
      name: "24K Gold Bar 10g",
      category: "Gold Bars",
      unitPrice: 980,
      marketPrice: 995,
      stock: 42,
      updatedAt: "2026-04-13"
    }
  ],
  invoices: [
    { id: "inv-1", sellerId: "s-100", investorName: "Ahmad Saleh", totalAmount: 980, issuedAt: "2026-04-13", status: "sent" }
  ],
  fees: {
    deliveryFee: 12,
    storageFee: 4,
    serviceChargePercent: 2.5
  },
  notifications: [
    {
      id: "n-1",
      title: "KYC pending",
      message: "A new seller registration is awaiting approval.",
      severity: "warning",
      isRead: false,
      createdAt: "2026-04-14"
    }
  ],
  reports: [{ title: "Fallback Mode", value: "ON", trend: "Backend unavailable" }]
};
