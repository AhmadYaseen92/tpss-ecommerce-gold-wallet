namespace GoldWalletSystem.Domain.Entities;

public class CliqPaymentMethodDetails : BaseEntity
{
    public int PaymentMethodId { get; set; }
    public string CliqAlias { get; set; } = string.Empty;
    public string BankName { get; set; } = string.Empty;
    public string AccountHolderName { get; set; } = string.Empty;

    public PaymentMethod PaymentMethod { get; set; } = null!;
}
