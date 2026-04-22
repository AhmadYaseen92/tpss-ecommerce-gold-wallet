using GoldWalletSystem.Domain.Enums;

namespace GoldWalletSystem.Application.DTOs.Notifications;

public class UnregisterPushTokenRequestDto
{
    public NotificationPlatform Platform { get; set; }
    public string DeviceToken { get; set; } = string.Empty;
}
