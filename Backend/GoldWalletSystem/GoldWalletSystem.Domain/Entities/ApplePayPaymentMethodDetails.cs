namespace GoldWalletSystem.Domain.Entities;

public class ApplePayPaymentMethodDetails : BaseEntity
{
    public int PaymentMethodId { get; set; }
    public string ApplePayToken { get; set; } = string.Empty;
    public string AccountHolderName { get; set; } = string.Empty;

    public PaymentMethod PaymentMethod { get; set; } = null!;
}
