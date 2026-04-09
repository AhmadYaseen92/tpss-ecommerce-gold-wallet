namespace GoldWalletSystem.Domain.Entities;

public class UserProfile : BaseEntity
{
    public int UserId { get; set; }
    public DateOnly? DateOfBirth { get; set; }
    public string Nationality { get; set; } = string.Empty;
    public string PreferredLanguage { get; set; } = "en";
    public string PreferredTheme { get; set; } = "light";

    public User User { get; set; } = null!;
    public ICollection<PaymentMethod> PaymentMethods { get; set; } = new List<PaymentMethod>();
    public ICollection<LinkedBankAccount> LinkedBankAccounts { get; set; } = new List<LinkedBankAccount>();
}
