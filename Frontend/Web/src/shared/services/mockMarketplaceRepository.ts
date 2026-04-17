import type { MarketplaceState } from "../types/models";

export const mockMarketplaceState: MarketplaceState = {
  sellers: [
    {
      id: "s-100",
      sellerId: 100,
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
    { id: "r-1", investorId: "i-1", investorName: "Ahmad Saleh", type: "withdrawal", productName: "Gold Bar 10g", category: "Gold", quantity: 2, unitPrice: 600, weight: 10, unit: "gram", purity: 24, amount: 1200, status: "pending", currency: "USD", createdAt: "2026-04-13" },
    { id: "r-2", investorId: "i-2", investorName: "Sara Odeh", type: "sell", productName: "Gold Bar 5g", category: "Gold", quantity: 1, unitPrice: 740, weight: 5, unit: "gram", purity: 24, amount: 740, status: "approved", currency: "USD", createdAt: "2026-04-12" }
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
  walletAssets: [],
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
  reports: [{ title: "Fallback Mode", value: "ON", trend: "Backend unavailable" }],
  currentUserName: "Demo User"
};
