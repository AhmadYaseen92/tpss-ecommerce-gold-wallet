using GoldWalletSystem.Domain.Enums;

namespace GoldWalletSystem.Application.DTOs.Notifications;

public class CreateNotificationRequestDto
{
    public int UserId { get; set; }
    public NotificationType Type { get; set; } = NotificationType.General;
    public int? ReferenceId { get; set; }
    public NotificationReferenceType? ReferenceType { get; set; }
    public string? ActionUrl { get; set; }
    public string? ImageUrl { get; set; }
    public string? Role { get; set; }
    public int? Priority { get; set; }
    public string Title { get; set; } = string.Empty;
    public string Body { get; set; } = string.Empty;
}
