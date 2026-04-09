namespace GoldWalletSystem.Application.DTOs.Notifications;

public sealed record NotificationDto(int Id, int UserId, string Title, string Body, bool IsRead, DateTime CreatedAtUtc);
