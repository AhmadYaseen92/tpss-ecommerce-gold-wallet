using GoldWalletSystem.Application.DTOs.Otp;

namespace GoldWalletSystem.Application.Interfaces.Services;

public interface ICheckoutOtpOrchestrator
{
    string BuildActionReference(int userId, IReadOnlyCollection<int>? productIds, int? productId, int? quantity);
    Task EnsureOtpVerifiedAsync(int userId, IReadOnlyCollection<int>? productIds, int? productId, int? quantity, string otpVerificationToken, string otpActionReferenceId, string otpRequestId, string otpCode, CancellationToken cancellationToken = default);
    Task<OtpDispatchResponseDto> RequestAsync(int userId, IReadOnlyCollection<int>? productIds, int? productId, int? quantity, bool forceEmailFallback, CancellationToken cancellationToken = default);
}
