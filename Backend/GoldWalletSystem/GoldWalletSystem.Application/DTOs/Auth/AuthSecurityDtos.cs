namespace GoldWalletSystem.Application.DTOs.Auth;

public class VerifyRegistrationOtpRequestDto
{
    public int UserId { get; set; }
    public string OtpRequestId { get; set; } = string.Empty;
    public string OtpCode { get; set; } = string.Empty;
}

public class RequestPasswordResetOtpRequestDto
{
    public string Email { get; set; } = string.Empty;
}

public class ConfirmPasswordResetRequestDto
{
    public string Email { get; set; } = string.Empty;
    public string OtpRequestId { get; set; } = string.Empty;
    public string OtpCode { get; set; } = string.Empty;
    public string NewPassword { get; set; } = string.Empty;
}

