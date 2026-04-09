using GoldWalletSystem.Application.DTOs.Auth;
using GoldWalletSystem.Application.Interfaces.Repositories;
using GoldWalletSystem.Application.Interfaces.Services;

namespace GoldWalletSystem.Application.Services;

public class AuthService(IUserAuthRepository userAuthRepository, IPasswordHasher passwordHasher, ITokenService tokenService) : IAuthService
{
    public async Task<LoginResponseDto> LoginAsync(LoginRequestDto request, CancellationToken cancellationToken = default)
    {
        if (string.IsNullOrWhiteSpace(request.Email) || string.IsNullOrWhiteSpace(request.Password))
            throw new UnauthorizedAccessException("Invalid credentials.");

        var user = await userAuthRepository.GetByEmailAsync(request.Email, cancellationToken)
            ?? throw new UnauthorizedAccessException("Invalid credentials.");

        if (!user.IsActive || !passwordHasher.Verify(request.Password, user.PasswordHash))
            throw new UnauthorizedAccessException("Invalid credentials.");

        var role = string.IsNullOrWhiteSpace(user.Role) ? GoldWalletSystem.Domain.Constants.SystemRoles.Investor : user.Role;
        var token = tokenService.GenerateAccessToken(user.Id, user.Email, role);

        return new LoginResponseDto
        {
            AccessToken = token.Token,
            ExpiresAtUtc = token.ExpiresAtUtc,
            Role = role,
            UserId = user.Id
        };
    }
}
