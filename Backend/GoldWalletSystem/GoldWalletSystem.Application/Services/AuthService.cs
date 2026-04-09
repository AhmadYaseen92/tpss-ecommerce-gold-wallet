using GoldWalletSystem.Application.DTOs.Auth;
using GoldWalletSystem.Application.Interfaces.Repositories;
using GoldWalletSystem.Application.Interfaces.Services;
using GoldWalletSystem.Domain.Constants;
using GoldWalletSystem.Domain.Entities;

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

        var role = string.IsNullOrWhiteSpace(user.Role) ? SystemRoles.Investor : user.Role;
        var token = tokenService.GenerateAccessToken(user.Id, user.Email, role);

        return new LoginResponseDto
        {
            AccessToken = token.Token,
            ExpiresAtUtc = token.ExpiresAtUtc,
            Role = role,
            UserId = user.Id
        };
    }

    public async Task<RegisterResponseDto> RegisterAsync(RegisterRequestDto request, CancellationToken cancellationToken = default)
    {
        if (string.IsNullOrWhiteSpace(request.FirstName) ||
            string.IsNullOrWhiteSpace(request.LastName) ||
            string.IsNullOrWhiteSpace(request.Email) ||
            string.IsNullOrWhiteSpace(request.Password))
        {
            throw new InvalidOperationException("First name, last name, email and password are required.");
        }

        var existing = await userAuthRepository.GetByEmailAsync(request.Email.Trim(), cancellationToken);
        if (existing is not null)
        {
            throw new InvalidOperationException("Email is already registered.");
        }

        var role = string.IsNullOrWhiteSpace(request.Role) ? SystemRoles.Investor : request.Role.Trim();

        var user = new User
        {
            FullName = $"{request.FirstName.Trim()} {request.LastName.Trim()}".Trim(),
            Email = request.Email.Trim(),
            PasswordHash = passwordHasher.Hash(request.Password),
            PhoneNumber = request.PhoneNumber?.Trim(),
            Role = role,
            IsActive = true,
            CreatedAtUtc = DateTime.UtcNow,
            UpdatedAtUtc = DateTime.UtcNow,
        };

        var created = await userAuthRepository.AddAsync(user, cancellationToken);

        return new RegisterResponseDto
        {
            UserId = created.Id,
            Email = created.Email,
            FullName = created.FullName,
            Role = created.Role,
        };
    }
}
