using GoldWalletSystem.Application.DTOs.Auth;
using GoldWalletSystem.Application.DTOs.Otp;

namespace GoldWalletSystem.Application.Interfaces.Services;

public interface IAuthService
{
    Task<LoginResponseDto> LoginAsync(LoginRequestDto request, CancellationToken cancellationToken = default);
    Task<RegisterResponseDto> RegisterAsync(RegisterRequestDto request, CancellationToken cancellationToken = default);
    Task VerifyRegistrationOtpAsync(VerifyRegistrationOtpRequestDto request, CancellationToken cancellationToken = default);
    Task<OtpDispatchResponseDto> RequestPasswordResetOtpAsync(RequestPasswordResetOtpRequestDto request, CancellationToken cancellationToken = default);
    Task ConfirmPasswordResetAsync(ConfirmPasswordResetRequestDto request, CancellationToken cancellationToken = default);
}
