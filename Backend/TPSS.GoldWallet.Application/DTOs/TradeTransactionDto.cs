namespace TPSS.GoldWallet.Application.DTOs;

public sealed record TradeTransactionDto(string Id, string Title, string Type, string Status, DateTime Date, string Amount, string SellerName, string? SecondaryAmount);
