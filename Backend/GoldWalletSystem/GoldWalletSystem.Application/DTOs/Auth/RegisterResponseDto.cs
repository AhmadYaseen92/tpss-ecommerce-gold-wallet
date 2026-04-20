namespace GoldWalletSystem.Application.DTOs.Auth;

public class RegisterResponseDto
{
    public int UserId { get; init; }
    public required string Email { get; init; }
    public required string FullName { get; init; }
    public required string Role { get; init; }
    public int? SellerId { get; init; }
    public bool RequiresOtpVerification { get; init; } = true;
    public string? OtpRequestId { get; init; }
}
