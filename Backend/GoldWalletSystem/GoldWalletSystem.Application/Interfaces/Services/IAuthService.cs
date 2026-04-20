using GoldWalletSystem.Application.DTOs.Auth;

namespace GoldWalletSystem.Application.Interfaces.Services;

public interface IAuthService
{
    Task<LoginResponseDto> LoginAsync(LoginRequestDto request, CancellationToken cancellationToken = default);
    Task<SendLoginOtpResponseDto> SendLoginOtpAsync(SendLoginOtpRequestDto request, CancellationToken cancellationToken = default);
    Task<LoginResponseDto> VerifyLoginOtpAsync(VerifyLoginOtpRequestDto request, CancellationToken cancellationToken = default);
    Task<RegisterResponseDto> RegisterAsync(RegisterRequestDto request, CancellationToken cancellationToken = default);
}
