namespace GoldWalletSystem.Domain.Entities;

public class Wallet : BaseEntity
{
    public int UserId { get; set; }
    public decimal CashBalance { get; set; }
    public string CurrencyCode { get; set; } = "JOD";

    public User User { get; set; } = null!;
    public ICollection<WalletAsset> Assets { get; set; } = new List<WalletAsset>();
}