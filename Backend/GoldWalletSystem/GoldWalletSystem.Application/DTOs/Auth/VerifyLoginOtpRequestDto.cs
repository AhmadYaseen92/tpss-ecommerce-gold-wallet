namespace GoldWalletSystem.Application.DTOs.Auth;

public class VerifyLoginOtpRequestDto
{
    public string Email { get; set; } = string.Empty;
    public string OtpCode { get; set; } = string.Empty;
}

