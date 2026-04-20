using GoldWalletSystem.Domain.Enums;

namespace GoldWalletSystem.Application.DTOs.Configuration;

public class MobileAppConfigurationDto
{
    public int Id { get; set; }
    public string ConfigKey { get; set; } = string.Empty;
    public string Name { get; set; } = string.Empty;
    public ConfigurationValueType ValueType { get; set; } = ConfigurationValueType.String;
    public string? ValueString { get; set; }
    public bool? ValueBool { get; set; }
    public int? ValueInt { get; set; }
    public decimal? ValueDecimal { get; set; }
    public bool SellerAccess { get; set; }
    public string Description { get; set; } = string.Empty;
}

public class UpsertMobileAppConfigurationRequestDto
{
    public string ConfigKey { get; set; } = string.Empty;
    public string Name { get; set; } = string.Empty;
    public ConfigurationValueType ValueType { get; set; } = ConfigurationValueType.String;
    public string? ValueString { get; set; }
    public bool? ValueBool { get; set; }
    public int? ValueInt { get; set; }
    public decimal? ValueDecimal { get; set; }
    public bool SellerAccess { get; set; }
    public string Description { get; set; } = string.Empty;
}
