using GoldWalletSystem.Application.DTOs.Checkout;
using GoldWalletSystem.Application.DTOs.Otp;

namespace GoldWalletSystem.Application.Interfaces.Services;

public interface ICheckoutService
{
    Task<OtpDispatchResponseDto> RequestOtpAsync(CheckoutOtpRequestDto request, CancellationToken cancellationToken = default);
    Task<OtpDispatchResponseDto> ResendOtpAsync(ResendCheckoutOtpRequestDto request, CancellationToken cancellationToken = default);
    Task<VerifyOtpResponseDto> VerifyOtpAsync(VerifyCheckoutOtpRequestDto request, CancellationToken cancellationToken = default);
    Task<CheckoutConfirmResponseDto> ConfirmAsync(CheckoutConfirmRequestDto request, CancellationToken cancellationToken = default);
}
