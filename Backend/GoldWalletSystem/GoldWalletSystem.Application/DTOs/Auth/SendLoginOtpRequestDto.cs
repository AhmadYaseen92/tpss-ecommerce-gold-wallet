namespace GoldWalletSystem.Application.DTOs.Auth;

public class SendLoginOtpRequestDto
{
    public string Email { get; set; } = string.Empty;
    public string Password { get; set; } = string.Empty;
}

public class SendLoginOtpResponseDto
{
    public required DateTime ExpiresAtUtc { get; init; }
    public required IReadOnlyList<string> DeliveryChannels { get; init; }
}

