namespace GoldWalletSystem.Domain.Entities;

public class PaymentMethod : BaseEntity
{
    public int UserProfileId { get; set; }
    public string Type { get; set; } = string.Empty;
    public string MaskedNumber { get; set; } = string.Empty;
    public string HolderName { get; set; } = string.Empty;
    public string Expiry { get; set; } = string.Empty;
    public string DetailsJson { get; set; } = string.Empty;
    public bool IsDefault { get; set; }

    public UserProfile UserProfile { get; set; } = null!;
}
