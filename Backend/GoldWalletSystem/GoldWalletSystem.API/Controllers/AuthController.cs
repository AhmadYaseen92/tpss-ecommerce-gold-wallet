using GoldWalletSystem.Application.DTOs.Auth;
using GoldWalletSystem.Application.DTOs.Common;
using GoldWalletSystem.Application.DTOs.Otp;
using GoldWalletSystem.Application.Interfaces.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace GoldWalletSystem.API.Controllers;

[ApiController]
[Route("api/auth")]
public class AuthController(IAuthService authService, ISellerAuthService sellerAuthService) : ControllerBase
{
    [HttpGet("ping")]
    [ProducesResponseType(typeof(ApiResponse<string>), StatusCodes.Status200OK)]
    public IActionResult Ping()
    {
        return Ok(ApiResponse<string>.Ok("Auth API reachable", "Connection successful"));
    }

    [HttpPost("register")]
    [ProducesResponseType(typeof(ApiResponse<RegisterResponseDto>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> Register([FromBody] RegisterRequestDto request, CancellationToken cancellationToken = default)
    {
        var result = await authService.RegisterAsync(request, cancellationToken);
        return Ok(ApiResponse<RegisterResponseDto>.Ok(result, "Register successful"));
    }

    [HttpPost("login")]
    [ProducesResponseType(typeof(ApiResponse<LoginResponseDto>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> Login([FromBody] LoginRequestDto request, CancellationToken cancellationToken = default)
    {
        var result = await authService.LoginAsync(request, cancellationToken);
        return Ok(ApiResponse<LoginResponseDto>.Ok(result, "Login successful"));
    }

    [HttpPost("register/verify-otp")]
    [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status200OK)]
    public async Task<IActionResult> VerifyRegistrationOtp([FromBody] VerifyRegistrationOtpRequestDto request, CancellationToken cancellationToken = default)
    {
        await authService.VerifyRegistrationOtpAsync(request, cancellationToken);
        return Ok(ApiResponse<object>.Ok(new { request.UserId }, "Registration verified successfully"));
    }

    [HttpPost("password/reset/request-otp")]
    [HttpPost("forgot-password/request-otp")]
    [ProducesResponseType(typeof(ApiResponse<OtpDispatchResponseDto>), StatusCodes.Status200OK)]
    public async Task<IActionResult> RequestPasswordResetOtp([FromBody] RequestPasswordResetOtpRequestDto request, CancellationToken cancellationToken = default)
    {
        var data = await authService.RequestPasswordResetOtpAsync(request, cancellationToken);
        return Ok(ApiResponse<OtpDispatchResponseDto>.Ok(data, "Password reset OTP sent"));
    }

    [HttpPost("password/reset/confirm")]
    [HttpPost("forgot-password/confirm")]
    [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status200OK)]
    public async Task<IActionResult> ConfirmPasswordReset([FromBody] ConfirmPasswordResetRequestDto request, CancellationToken cancellationToken = default)
    {
        await authService.ConfirmPasswordResetAsync(request, cancellationToken);
        return Ok(ApiResponse<object>.Ok(new { request.Email }, "Password reset successful"));
    }



    [HttpPost("seller-login")]
    [ProducesResponseType(typeof(ApiResponse<LoginResponseDto>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> SellerLogin([FromBody] LoginRequestDto request, CancellationToken cancellationToken = default)
    {
        var result = await sellerAuthService.SellerLoginAsync(request, cancellationToken);
        return Ok(ApiResponse<LoginResponseDto>.Ok(result, "Seller login successful"));
    }

    [Authorize]
    [HttpPost("logout")]
    [ProducesResponseType(typeof(ApiResponse<string>), StatusCodes.Status200OK)]
    public IActionResult Logout()
    {
        return Ok(ApiResponse<string>.Ok("Logged out", "Logout successful"));
    }
}
