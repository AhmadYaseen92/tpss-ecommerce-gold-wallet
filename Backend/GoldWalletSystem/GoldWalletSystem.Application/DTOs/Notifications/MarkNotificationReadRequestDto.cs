namespace GoldWalletSystem.Application.DTOs.Notifications;

public class MarkNotificationReadRequestDto
{
    public int UserId { get; set; }
    public int NotificationId { get; set; }
}
