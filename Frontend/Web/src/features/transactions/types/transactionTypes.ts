export interface TransactionRowView {
  id: string;
  investorId: string;
  investorName: string;
  productName: string;
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
  createdAt: string;
  updatedAt?: string;
}
