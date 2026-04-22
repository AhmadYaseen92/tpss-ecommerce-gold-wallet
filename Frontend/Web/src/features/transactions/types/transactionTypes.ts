export interface TransactionFeeBreakdownView {
  feeCode: string;
  feeName: string;
  calculationMode: string;
  baseAmount: number;
  quantity: number;
  appliedRate?: number | null;
  appliedValue: number;
  isDiscount: boolean;
  currency: string;
  sourceType: string;
  displayOrder: number;
}

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
  subTotalAmount?: number;
  totalFeesAmount?: number;
  discountAmount?: number;
  finalAmount: number;
  feeBreakdowns?: TransactionFeeBreakdownView[];
  currency: string;
  status: string;
  notes?: string;
  transferFrom?: string;
  transferTo?: string;
  pickupSchedule?: string;
  createdAt: string;
  updatedAt?: string;
}
