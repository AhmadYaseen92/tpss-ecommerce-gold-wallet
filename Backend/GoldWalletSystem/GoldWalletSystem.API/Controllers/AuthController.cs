using GoldWalletSystem.Application.DTOs.Auth;
using GoldWalletSystem.Application.DTOs.Common;
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

    [HttpPost("login/send-otp")]
    [ProducesResponseType(typeof(ApiResponse<SendLoginOtpResponseDto>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> SendLoginOtp([FromBody] SendLoginOtpRequestDto request, CancellationToken cancellationToken = default)
    {
        var result = await authService.SendLoginOtpAsync(request, cancellationToken);
        return Ok(ApiResponse<SendLoginOtpResponseDto>.Ok(result, "OTP sent successfully"));
    }

    [HttpPost("login/verify-otp")]
    [ProducesResponseType(typeof(ApiResponse<LoginResponseDto>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> VerifyLoginOtp([FromBody] VerifyLoginOtpRequestDto request, CancellationToken cancellationToken = default)
    {
        var result = await authService.VerifyLoginOtpAsync(request, cancellationToken);
        return Ok(ApiResponse<LoginResponseDto>.Ok(result, "Login successful"));
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
