namespace GoldWalletSystem.Domain.Entities;

public class User : BaseEntity
{
    public string FullName { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string PasswordHash { get; set; } = string.Empty;
    public string Role { get; set; } = GoldWalletSystem.Domain.Constants.SystemRoles.Investor;
    public string? PhoneNumber { get; set; }
    public bool IsActive { get; set; } = true;

    public Wallet? Wallet { get; set; }
    public Cart? Cart { get; set; }
}
