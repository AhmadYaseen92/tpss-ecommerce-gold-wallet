namespace GoldWalletSystem.Domain.Entities;

public class LinkedBankAccount : BaseEntity
{
    public int UserProfileId { get; set; }
    public string BankName { get; set; } = string.Empty;
    public string IbanMasked { get; set; } = string.Empty;
    public bool IsVerified { get; set; }
    public bool IsDefault { get; set; }
    public string AccountHolderName { get; set; } = string.Empty;
    public string AccountNumber { get; set; } = string.Empty;
    public string SwiftCode { get; set; } = string.Empty;
    public string BranchName { get; set; } = string.Empty;
    public string BranchAddress { get; set; } = string.Empty;
    public string Country { get; set; } = string.Empty;
    public string City { get; set; } = string.Empty;
    public string Currency { get; set; } = string.Empty;

    public UserProfile UserProfile { get; set; } = null!;
}
