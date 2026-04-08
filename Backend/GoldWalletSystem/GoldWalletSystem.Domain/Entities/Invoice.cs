namespace GoldWalletSystem.Domain.Entities;

public class Invoice : BaseEntity
{
    public int UserId { get; set; }
    public string InvoiceNumber { get; set; } = string.Empty;
    public decimal SubTotal { get; set; }
    public decimal TaxAmount { get; set; }
    public decimal TotalAmount { get; set; }
    public DateTime IssuedOnUtc { get; set; } = DateTime.UtcNow;
    public string Status { get; set; } = "Pending";
}
