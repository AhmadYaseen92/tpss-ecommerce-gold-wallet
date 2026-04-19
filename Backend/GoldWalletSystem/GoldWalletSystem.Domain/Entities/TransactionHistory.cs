namespace GoldWalletSystem.Domain.Entities;

public class TransactionHistory : BaseEntity
{
    public int UserId { get; set; }
    public int? SellerId { get; set; }
    public string TransactionType { get; set; } = string.Empty;
    public string Status { get; set; } = "pending";
    public string Category { get; set; } = "Gold";
    public int Quantity { get; set; } = 1;
    public decimal UnitPrice { get; set; }
    public decimal Weight { get; set; }
    public string Unit { get; set; } = "gram";
    public decimal Purity { get; set; }
    public string Notes { get; set; } = string.Empty;
    public decimal Amount { get; set; }
    public string Currency { get; set; } = "USD";
    public int? WalletItemId { get; set; }
    public int? InvoiceId { get; set; }

    public WalletAsset? WalletItem { get; set; }
    public Invoice? Invoice { get; set; }
}
