namespace GoldWalletSystem.Application.DTOs.Auth;

public class LoginResponseDto
{
    public required string AccessToken { get; init; }
    public required DateTime ExpiresAtUtc { get; init; }
    public required string Role { get; init; }
    public int? UserId { get; init; }
    public int? SellerId { get; init; }
    public string? DisplayName { get; init; }
}
