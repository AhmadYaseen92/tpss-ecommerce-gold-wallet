namespace GoldWalletSystem.Application.DTOs.Transactions;

public sealed record TransactionHistoryDto(int Id, int UserId, int? SellerId, string TransactionType, decimal Amount, string Currency, string Reference, DateTime CreatedAtUtc);
