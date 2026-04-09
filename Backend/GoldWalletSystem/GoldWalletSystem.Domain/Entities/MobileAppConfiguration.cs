namespace GoldWalletSystem.Domain.Entities;

public class MobileAppConfiguration : BaseEntity
{
    public string ConfigKey { get; set; } = string.Empty;
    public string JsonValue { get; set; } = "{}";
    public bool IsEnabled { get; set; } = true;
    public string Description { get; set; } = string.Empty;
}
