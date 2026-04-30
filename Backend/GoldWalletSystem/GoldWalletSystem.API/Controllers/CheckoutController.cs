using GoldWalletSystem.Application.DTOs.Checkout;
using GoldWalletSystem.Application.DTOs.Common;
using GoldWalletSystem.Application.DTOs.Otp;
using GoldWalletSystem.Application.Interfaces.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace GoldWalletSystem.API.Controllers;

[ApiController]
[Authorize]
[Route("api/checkout")]
public class CheckoutController(ICheckoutService checkoutService, ICurrentUserService currentUser) : SecuredControllerBase(currentUser)
{
    [HttpPost("otp/request")]
    public async Task<IActionResult> RequestCheckoutOtp([FromBody] CheckoutOtpRequestDto request, CancellationToken cancellationToken = default)
    {
        var data = await checkoutService.RequestOtpAsync(request, cancellationToken);
        return Ok(ApiResponse<OtpDispatchResponseDto>.Ok(data, "Checkout OTP sent"));
    }

    [HttpPost("otp/resend")]
    public async Task<IActionResult> ResendCheckoutOtp([FromBody] ResendCheckoutOtpRequestDto request, CancellationToken cancellationToken = default)
    {
        var data = await checkoutService.ResendOtpAsync(request, cancellationToken);
        return Ok(ApiResponse<OtpDispatchResponseDto>.Ok(data, "Checkout OTP resent"));
    }

    [HttpPost("otp/verify")]
    public async Task<IActionResult> VerifyCheckoutOtp([FromBody] VerifyCheckoutOtpRequestDto request, CancellationToken cancellationToken = default)
    {
        var data = await checkoutService.VerifyOtpAsync(request, cancellationToken);
        return Ok(ApiResponse<VerifyOtpResponseDto>.Ok(data, "Checkout OTP verified"));
    }

    [HttpPost("confirm")]
    public async Task<IActionResult> Confirm([FromBody] CheckoutConfirmRequestDto request, CancellationToken cancellationToken = default)
    {
        var data = await checkoutService.ConfirmAsync(request, cancellationToken);
        return Ok(ApiResponse<CheckoutConfirmResponseDto>.Ok(data, "Checkout completed"));
    }
}
