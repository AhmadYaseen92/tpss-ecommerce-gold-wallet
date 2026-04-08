namespace GoldWalletSystem.Domain.Entities;

public class TransactionHistory : BaseEntity
{
    public int UserId { get; set; }
    public string TransactionType { get; set; } = string.Empty;
    public decimal Amount { get; set; }
    public string Currency { get; set; } = "USD";
    public string Reference { get; set; } = string.Empty;
}
