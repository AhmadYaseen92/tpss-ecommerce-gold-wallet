namespace GoldWalletSystem.Domain.Entities;

public class LinkedBankAccount : BaseEntity
{
    public int UserProfileId { get; set; }
    public string BankName { get; set; } = string.Empty;
    public string IbanMasked { get; set; } = string.Empty;
    public bool IsVerified { get; set; }

    public UserProfile UserProfile { get; set; } = null!;
}
