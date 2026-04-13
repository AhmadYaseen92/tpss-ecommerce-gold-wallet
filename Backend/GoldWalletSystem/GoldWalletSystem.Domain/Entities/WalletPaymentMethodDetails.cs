namespace GoldWalletSystem.Domain.Entities;

public class WalletPaymentMethodDetails : BaseEntity
{
    public int PaymentMethodId { get; set; }
    public string Provider { get; set; } = string.Empty;
    public string WalletNumber { get; set; } = string.Empty;
    public string AccountHolderName { get; set; } = string.Empty;

    public PaymentMethod PaymentMethod { get; set; } = null!;
}
