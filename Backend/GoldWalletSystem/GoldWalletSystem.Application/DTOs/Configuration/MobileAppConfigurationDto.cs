namespace GoldWalletSystem.Application.DTOs.Configuration;

public class MobileAppConfigurationDto
{
    public int Id { get; set; }
    public string ConfigKey { get; set; } = string.Empty;
    public string JsonValue { get; set; } = "{}";
    public bool IsEnabled { get; set; }
    public string Description { get; set; } = string.Empty;
}

public class UpsertMobileAppConfigurationRequestDto
{
    public string ConfigKey { get; set; } = string.Empty;
    public string JsonValue { get; set; } = "{}";
    public bool IsEnabled { get; set; } = true;
    public string Description { get; set; } = string.Empty;
}
