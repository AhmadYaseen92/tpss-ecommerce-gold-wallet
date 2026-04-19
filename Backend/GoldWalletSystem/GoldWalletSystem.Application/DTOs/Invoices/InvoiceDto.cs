namespace GoldWalletSystem.Application.DTOs.Invoices;

public sealed record InvoiceDto(
    int Id,
    int InvestorUserId,
    int SellerUserId,
    string InvoiceNumber,
    string InvoiceCategory,
    string SourceChannel,
    string? ExternalReference,
    decimal SubTotal,
    decimal FeesAmount,
    decimal DiscountAmount,
    decimal TaxAmount,
    decimal TotalAmount,
    string Currency,
    string PaymentMethod,
    string PaymentStatus,
    string? PaymentTransactionId,
    int? WalletItemId,
    int? ProductId,
    string ProductName,
    int Quantity,
    decimal UnitPrice,
    decimal Weight,
    decimal Purity,
    string? FromPartyType,
    string? ToPartyType,
    int? FromPartyUserId,
    int? ToPartyUserId,
    DateTime? OwnershipEffectiveOnUtc,
    int? RelatedTransactionId,
    string Status,
    string InvoiceQrCode,
    string? PdfUrl,
    DateTime IssuedOnUtc,
    DateTime? PaidOnUtc);

public class CreateInvoiceRequestDto
{
    public int InvestorUserId { get; set; }
    public int? SellerUserId { get; set; }
    public string InvoiceCategory { get; set; } = "Buy";
    public string SourceChannel { get; set; } = "Mobile";
    public string? ExternalReference { get; set; }
    public decimal FeesAmount { get; set; }
    public decimal DiscountAmount { get; set; }
    public decimal TaxAmount { get; set; }
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
    public string? PdfUrl { get; set; }
    public DateTime? PaidOnUtc { get; set; }
}
