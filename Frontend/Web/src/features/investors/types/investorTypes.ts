export interface InvestorRowView {
  id: string;
  investorNumericId: number;
  fullName: string;
  email: string;
  phoneNumber: string;
  walletBalance: number;
  riskLevel: string;
  status: string;
  totalTransactions: number;
  createdDate: string;
  totalPurchases: number;
  lastTransactionDate: string;
  firstTransactionDate: string;
  approvedTransactions: number;
  pendingTransactions: number;
  rejectedTransactions: number;
  totalVolume: number;
  lastActivityDate: string;
  walletAssetsCount: number;
}
