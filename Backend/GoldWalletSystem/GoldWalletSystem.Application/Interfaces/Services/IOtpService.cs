using GoldWalletSystem.Application.DTOs.Otp;

namespace GoldWalletSystem.Application.Interfaces.Services;

public interface IOtpService
{
    Task<OtpDispatchResponseDto> RequestAsync(RequestOtpRequestDto request, CancellationToken cancellationToken = default);
    Task<OtpDispatchResponseDto> ResendAsync(ResendOtpRequestDto request, CancellationToken cancellationToken = default);
    Task<VerifyOtpResponseDto> VerifyAsync(VerifyOtpRequestDto request, CancellationToken cancellationToken = default);
    Task ConsumeVerificationGrantAsync(int userId, string actionType, string actionReferenceId, string verificationToken, CancellationToken cancellationToken = default);
    Task<bool> IsActionProtectedAsync(string actionType, CancellationToken cancellationToken = default);
}
