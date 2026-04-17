namespace GoldWalletSystem.Domain.Entities;

public class User : BaseEntity
{
    public string FullName { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string PasswordHash { get; set; } = string.Empty;
    public string Role { get; set; } = GoldWalletSystem.Domain.Constants.SystemRoles.Investor;
    public int? SellerId { get; set; }
    public string? PhoneNumber { get; set; }
    public bool IsActive { get; set; } = true;

    public Seller? Seller { get; set; }

    public Wallet? Wallet { get; set; }
    public Cart? Cart { get; set; }
}
