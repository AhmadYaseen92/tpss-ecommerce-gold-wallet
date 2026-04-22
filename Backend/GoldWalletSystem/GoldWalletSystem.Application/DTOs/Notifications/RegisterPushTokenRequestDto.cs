using GoldWalletSystem.Domain.Enums;

namespace GoldWalletSystem.Application.DTOs.Notifications;

public class RegisterPushTokenRequestDto
{
    public NotificationPlatform Platform { get; set; }
    public string DeviceToken { get; set; } = string.Empty;
    public string? DeviceName { get; set; }
}
