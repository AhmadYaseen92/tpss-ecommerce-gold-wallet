namespace GoldWalletSystem.Application.DTOs.Invoices;

public sealed record InvoiceDto(
    int Id,
    int InvestorUserId,
    int SellerUserId,
    string InvoiceNumber,
    string InvoiceCategory,
    string SourceChannel,
    decimal SubTotal,
    decimal TaxAmount,
    decimal TotalAmount,
    string Status,
    string InvoiceQrCode,
    DateTime IssuedOnUtc,
    IReadOnlyList<InvoiceItemDto> Items);

public sealed record InvoiceItemDto(int Id, int ProductId, string ItemName, int Quantity, decimal UnitPrice, decimal LineTotal, string ItemQrCode);

public class CreateInvoiceRequestDto
{
    public int InvestorUserId { get; set; }
    public int? SellerUserId { get; set; }
    public string InvoiceCategory { get; set; } = "Trade";
    public string SourceChannel { get; set; } = "Mobile";
    public decimal TaxAmount { get; set; }
    public List<CreateInvoiceItemRequestDto> Items { get; set; } = [];
}

public class CreateInvoiceItemRequestDto
{
    public int ProductId { get; set; }
    public string ItemName { get; set; } = string.Empty;
    public int Quantity { get; set; }
    public decimal UnitPrice { get; set; }
}
