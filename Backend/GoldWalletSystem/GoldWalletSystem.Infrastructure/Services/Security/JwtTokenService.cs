using GoldWalletSystem.Application.Interfaces.Services;
using Microsoft.Extensions.Configuration;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;

namespace GoldWalletSystem.Infrastructure.Services.Security;

public class JwtTokenService(IConfiguration configuration) : ITokenService
{
    public (string Token, DateTime ExpiresAtUtc) GenerateAccessToken(int userId, string email, string role, int? sellerId)
    {
        var key = configuration["Jwt:Key"] ?? throw new InvalidOperationException("Jwt key is missing");
        var issuer = configuration["Jwt:Issuer"] ?? "GoldWallet";
        var audience = configuration["Jwt:Audience"] ?? "GoldWalletClient";
        var expiresMinutes = int.TryParse(configuration["Jwt:AccessTokenMinutes"], out var min) ? min : 60;

        var expiresAt = DateTime.UtcNow.AddMinutes(expiresMinutes);
        var claims = new List<Claim>
        {
            new(JwtRegisteredClaimNames.Sub, userId.ToString()),
            new(JwtRegisteredClaimNames.Email, email),
            new("role", role),
            new(ClaimTypes.NameIdentifier, userId.ToString())
        };

        if (sellerId.HasValue)
        {
            claims.Add(new Claim("seller_id", sellerId.Value.ToString()));
        }

        var credentials = new SigningCredentials(new SymmetricSecurityKey(Encoding.UTF8.GetBytes(key)), SecurityAlgorithms.HmacSha256);
        var token = new JwtSecurityToken(issuer, audience, claims, expires: expiresAt, signingCredentials: credentials);
        var serialized = new JwtSecurityTokenHandler().WriteToken(token);

        return (serialized, expiresAt);
    }
}
