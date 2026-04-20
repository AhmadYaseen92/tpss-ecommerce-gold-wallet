using GoldWalletSystem.Application.DTOs.Common;
using GoldWalletSystem.Application.DTOs.Otp;
using GoldWalletSystem.Application.Interfaces.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace GoldWalletSystem.API.Controllers;

[ApiController]
[Authorize]
[Route("api/otp")]
public class OtpController(IOtpService otpService) : ControllerBase
{
    [HttpPost("request")]
    public async Task<IActionResult> Request([FromBody] RequestOtpRequestDto request, CancellationToken cancellationToken = default)
    {
        var data = await otpService.RequestAsync(request, cancellationToken);
        return Ok(ApiResponse<OtpDispatchResponseDto>.Ok(data, "OTP sent"));
    }

    [HttpPost("resend")]
    public async Task<IActionResult> Resend([FromBody] ResendOtpRequestDto request, CancellationToken cancellationToken = default)
    {
        var data = await otpService.ResendAsync(request, cancellationToken);
        return Ok(ApiResponse<OtpDispatchResponseDto>.Ok(data, "OTP resent"));
    }

    [HttpPost("verify")]
    public async Task<IActionResult> Verify([FromBody] VerifyOtpRequestDto request, CancellationToken cancellationToken = default)
    {
        var data = await otpService.VerifyAsync(request, cancellationToken);
        return Ok(ApiResponse<VerifyOtpResponseDto>.Ok(data, "OTP verified"));
    }
}

