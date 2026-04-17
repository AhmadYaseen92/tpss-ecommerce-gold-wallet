using GoldWalletSystem.Application.DTOs.Auth;
using GoldWalletSystem.Application.Interfaces.Repositories;
using GoldWalletSystem.Application.Interfaces.Services;
using GoldWalletSystem.Domain.Constants;
using GoldWalletSystem.Domain.Enums;

namespace GoldWalletSystem.Application.Services;

public class SellerAuthService(
    ISellerAuthRepository sellerAuthRepository,
    IPasswordHasher passwordHasher,
    ITokenService tokenService) : ISellerAuthService
{
    public async Task<LoginResponseDto> SellerLoginAsync(LoginRequestDto request, CancellationToken cancellationToken = default)
    {
        if (string.IsNullOrWhiteSpace(request.Email) || string.IsNullOrWhiteSpace(request.Password))
            throw new UnauthorizedAccessException("Invalid seller credentials.");

            var seller = await sellerAuthRepository.GetByEmailAsync(request.Email.Trim(), cancellationToken)
                ?? throw new UnauthorizedAccessException("Invalid seller credentials.");

        if (!passwordHasher.Verify(request.Password, seller.PasswordHash))
            throw new UnauthorizedAccessException("Invalid seller credentials.");

        if (!seller.IsActive || seller.KycStatus != KycStatus.Approved)
            throw new UnauthorizedAccessException("Seller account is awaiting admin approval.");

        var token = tokenService.GenerateAccessToken(null, seller.Email, SystemRoles.Seller, seller.Id);

        return new LoginResponseDto
        {
            AccessToken = token.Token,
            ExpiresAtUtc = token.ExpiresAtUtc,
            Role = SystemRoles.Seller,
            UserId = null,
            SellerId = seller.Id,
            DisplayName = seller.Name
        };
    }
}
