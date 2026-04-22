using GoldWalletSystem.Domain.Enums;

namespace GoldWalletSystem.Domain.Entities;

public class UserPushToken : BaseEntity
{
    public int UserId { get; set; }
    public string DeviceToken { get; set; } = string.Empty;
    public NotificationPlatform Platform { get; set; }
    public string? DeviceName { get; set; }
    public bool IsActive { get; set; } = true;
}
