using GoldWalletSystem.Domain.Enums;

namespace GoldWalletSystem.Application.DTOs.Notifications;

public sealed record NotificationDto(
    int Id,
    int UserId,
    NotificationType Type,
    NotificationReferenceType? ReferenceType,
    int? ReferenceId,
    string? ActionUrl,
    string? ImageUrl,
    string Title,
    string Body,
    bool IsRead,
    DateTime? ReadAtUtc,
    int? Priority,
    DateTime CreatedAtUtc);
