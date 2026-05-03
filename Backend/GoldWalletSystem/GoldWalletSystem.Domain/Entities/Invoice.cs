namespace GoldWalletSystem.Domain.Entities;

public class Invoice : BaseEntity
{
    public int InvestorUserId { get; set; }
    public int SellerUserId { get; set; }
    public string InvoiceNumber { get; set; } = string.Empty;
    public string InvoiceCategory { get; set; } = "Trade";
    public string SourceChannel { get; set; } = "Mobile";
    public string? ExternalReference { get; set; }
    public decimal SubTotal { get; set; }
    public decimal FeesAmount { get; set; }
    public decimal DiscountAmount { get; set; }
    public decimal TaxAmount { get; set; }
    public decimal TotalAmount { get; set; }

    // Fee breakdown fields
    public decimal CommissionFee { get; set; }
    public decimal DeliveryFee { get; set; }
    public decimal ServiceFee { get; set; }
    public decimal StorageFee { get; set; }
    public decimal PremiumDiscount { get; set; }
    public string Currency { get; set; } = "USD";
    public string PaymentMethod { get; set; } = "Unknown";
    public string PaymentStatus { get; set; } = "Pending";
    public string? PaymentTransactionId { get; set; }
    public int? WalletItemId { get; set; }
    public int? ProductId { get; set; }
    public string ProductName { get; set; } = string.Empty;
    public int Quantity { get; set; } = 1;
    public decimal UnitPrice { get; set; }
    public decimal Weight { get; set; }
    public decimal Purity { get; set; }
    public string? FromPartyType { get; set; }
    public string? ToPartyType { get; set; }
    public int? FromPartyUserId { get; set; }
    public int? ToPartyUserId { get; set; }
    public DateTime? OwnershipEffectiveOnUtc { get; set; }
    public int? RelatedTransactionId { get; set; }
    public string InvoiceQrCode { get; set; } = string.Empty;
    public string? PdfUrl { get; set; }
    public DateTime IssuedOnUtc { get; set; } = DateTime.UtcNow;
    public DateTime? PaidOnUtc { get; set; }
    public string Status { get; set; } = "Draft";

    public WalletAsset? WalletItem { get; set; }
    public Product? Product { get; set; }
}
