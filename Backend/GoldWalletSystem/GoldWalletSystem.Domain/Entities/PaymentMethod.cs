namespace GoldWalletSystem.Domain.Entities;

public class PaymentMethod : BaseEntity
{
    public int UserProfileId { get; set; }
    public string Type { get; set; } = string.Empty;
    public string MaskedNumber { get; set; } = string.Empty;
    public bool IsDefault { get; set; }

    public UserProfile UserProfile { get; set; } = null!;
    public CardPaymentMethodDetails? CardDetails { get; set; }
    public ApplePayPaymentMethodDetails? ApplePayDetails { get; set; }
    public WalletPaymentMethodDetails? WalletDetails { get; set; }
    public CliqPaymentMethodDetails? CliqDetails { get; set; }
}
