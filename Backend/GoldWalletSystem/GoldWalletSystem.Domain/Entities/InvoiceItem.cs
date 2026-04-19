namespace GoldWalletSystem.Domain.Entities;

public class InvoiceItem : BaseEntity
{
    public int InvoiceId { get; set; }
    public int? WalletItemId { get; set; }
    public int ProductId { get; set; }
    public string ProductName { get; set; } = string.Empty;
    public int Quantity { get; set; }
    public decimal UnitPrice { get; set; }
    public decimal Weight { get; set; }
    public decimal Purity { get; set; }
    public decimal TotalPrice { get; set; }

    public Invoice Invoice { get; set; } = null!;
    public WalletAsset? WalletItem { get; set; }
    public Product Product { get; set; } = null!;
}
