namespace GoldWalletSystem.Application.DTOs.Transactions;

public sealed record TransactionHistoryDto(int Id, int UserId, string TransactionType, decimal Amount, string Currency, string Reference, DateTime CreatedAtUtc);
