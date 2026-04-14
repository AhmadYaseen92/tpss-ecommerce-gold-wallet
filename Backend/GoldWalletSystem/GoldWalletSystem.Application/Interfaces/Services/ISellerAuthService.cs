using GoldWalletSystem.Application.DTOs.Auth;

namespace GoldWalletSystem.Application.Interfaces.Services;

public interface ISellerAuthService
{
    Task<LoginResponseDto> SellerLoginAsync(LoginRequestDto request, CancellationToken cancellationToken = default);
}
