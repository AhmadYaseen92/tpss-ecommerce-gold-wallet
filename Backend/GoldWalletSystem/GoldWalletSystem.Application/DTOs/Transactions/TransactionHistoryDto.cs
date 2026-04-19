namespace GoldWalletSystem.Application.DTOs.Transactions;

public sealed record TransactionHistoryDto(
    int Id,
    int UserId,
    string InvestorName,
    int? SellerId,
    string TransactionType,
    string Status,
    string ProductName,
    string Category,
    int Quantity,
    decimal UnitPrice,
    decimal Weight,
    string Unit,
    decimal Purity,
    decimal Amount,
    string Currency,
    int? WalletItemId,
    int? InvoiceId,
    string? InvoicePdfUrl,
    string Notes,
    DateTime CreatedAtUtc,
    string ProductImageUrl);
