namespace GoldWalletSystem.Application.DTOs.Auth;

public class LoginRequestDto
{
    public string Email { get; set; } = string.Empty;
    public string EmailOrPhone { get; set; } = string.Empty;
    public string PhoneNumber { get; set; } = string.Empty;
    public string Password { get; set; } = string.Empty;

    public string ResolveLoginIdentifier()
    {
        if (!string.IsNullOrWhiteSpace(EmailOrPhone)) return EmailOrPhone.Trim();
        if (!string.IsNullOrWhiteSpace(PhoneNumber)) return PhoneNumber.Trim();
        return Email.Trim();
    }
}
