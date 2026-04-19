namespace GoldWalletSystem.Application.DTOs.Wallet;

public sealed record WalletDto(
    int Id,
    int UserId,
    decimal CashBalance,
    string CurrencyCode,
    IReadOnlyList<WalletAssetDto> Assets);

public sealed record WalletAssetDto(
    int Id,
    string AssetType,
    string Category,
    int? SellerId,
    string SellerName,
    decimal Weight,
    string Unit,
    decimal Purity,
    int Quantity,
    decimal AverageBuyPrice,
    decimal CurrentMarketPrice,
    int? InvoiceId,
    string? CertificateUrl,
    bool IsDelivered,
    string Status,
    string? StatusDetails);
