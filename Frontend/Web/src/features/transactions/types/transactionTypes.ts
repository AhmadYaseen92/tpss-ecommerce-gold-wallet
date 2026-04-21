export interface TransactionRowView {
  id: string;
  sellerId?: string;
  investorId: string;
  investorName: string;
  sellerName?: string;
  productName: string;
  productImageUrl?: string;
  category: string;
  transactionType: string;
  quantity: number;
  unitPrice: number;
  weight: number;
  unit: string;
  purity: number;
  amount: number;
  currency: string;
  status: string;
  notes?: string;
  transferFrom?: string;
  transferTo?: string;
  pickupSchedule?: string;
  createdAt: string;
  updatedAt?: string;
}
