namespace GoldWalletSystem.Application.DTOs.Auth;

public class LoginResponseDto
{
    public required string AccessToken { get; init; }
    public required DateTime ExpiresAtUtc { get; init; }
    public required string RefreshToken { get; init; }
    public required DateTime RefreshTokenExpiresAtUtc { get; init; }
    public required int UserId { get; init; }
    public required string FullName { get; init; }
    public required string Role { get; init; }
    public int? SellerId { get; init; }
    public string? SellerName { get; init; }
}
