namespace GoldWalletSystem.Domain.Entities;

public class Invoice : BaseEntity
{
    public int InvestorUserId { get; set; }
    public int SellerUserId { get; set; }
    public string InvoiceNumber { get; set; } = string.Empty;
    public string InvoiceCategory { get; set; } = "Trade";
    public string SourceChannel { get; set; } = "Mobile";
    public decimal SubTotal { get; set; }
    public decimal TaxAmount { get; set; }
    public decimal TotalAmount { get; set; }
    public string InvoiceQrCode { get; set; } = string.Empty;
    public DateTime IssuedOnUtc { get; set; } = DateTime.UtcNow;
    public string Status { get; set; } = "Pending";

    public ICollection<InvoiceItem> Items { get; set; } = new List<InvoiceItem>();
}
