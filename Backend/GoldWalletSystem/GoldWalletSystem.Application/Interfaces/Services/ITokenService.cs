namespace GoldWalletSystem.Application.Interfaces.Services;

public interface ITokenService
{
    (string Token, DateTime ExpiresAtUtc) GenerateAccessToken(int userId, string email, string role);
}
