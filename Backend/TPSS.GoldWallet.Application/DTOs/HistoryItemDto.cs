namespace TPSS.GoldWallet.Application.DTOs;

public sealed record HistoryItemDto(string Type, string Description, decimal Amount, string Currency, DateTime CreatedAtUtc);
