using GoldWalletSystem.Domain.Enums;

namespace GoldWalletSystem.Domain.Entities;

public class MobileAppConfiguration : BaseEntity
{
    public string ConfigKey { get; set; } = string.Empty;
    public string Name { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public ConfigurationValueType ValueType { get; set; } = ConfigurationValueType.String;
    public bool? ValueBool { get; set; }
    public int? ValueInt { get; set; }
    public decimal? ValueDecimal { get; set; }
    public string? ValueString { get; set; }
    public bool SellerAccess { get; set; }
}
