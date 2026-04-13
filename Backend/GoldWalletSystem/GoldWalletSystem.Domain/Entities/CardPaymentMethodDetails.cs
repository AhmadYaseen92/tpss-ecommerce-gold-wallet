namespace GoldWalletSystem.Domain.Entities;

public class CardPaymentMethodDetails : BaseEntity
{
    public int PaymentMethodId { get; set; }
    public string CardNumber { get; set; } = string.Empty;
    public string CardHolderName { get; set; } = string.Empty;
    public string Expiry { get; set; } = string.Empty;

    public PaymentMethod PaymentMethod { get; set; } = null!;
}
