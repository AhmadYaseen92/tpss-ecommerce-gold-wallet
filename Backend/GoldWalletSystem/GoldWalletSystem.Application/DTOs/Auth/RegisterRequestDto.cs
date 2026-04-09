namespace GoldWalletSystem.Application.DTOs.Auth;

public class RegisterRequestDto
{
    public string FirstName { get; set; } = string.Empty;
    public string LastName { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string Password { get; set; } = string.Empty;
    public string? PhoneNumber { get; set; }
    public DateOnly? DateOfBirth { get; set; }
    public string Nationality { get; set; } = string.Empty;
    public string PreferredLanguage { get; set; } = "en";
    public string PreferredTheme { get; set; } = "light";
    public string Role { get; set; } = GoldWalletSystem.Domain.Constants.SystemRoles.Investor;
}
