namespace GoldWalletSystem.Domain.Entities;

public class InvoiceItem : BaseEntity
{
    public int InvoiceId { get; set; }
    public int ProductId { get; set; }
    public string ItemName { get; set; } = string.Empty;
    public int Quantity { get; set; }
    public decimal UnitPrice { get; set; }
    public decimal LineTotal { get; set; }
    public string ItemQrCode { get; set; } = string.Empty;

    public Invoice Invoice { get; set; } = null!;
}
