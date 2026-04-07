namespace TPSS.GoldWallet.Application.DTOs;

public sealed record NotificationDto(string Title, string Description, string Category, bool IsRead, DateTime CreatedAtUtc);
