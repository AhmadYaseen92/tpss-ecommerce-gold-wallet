using GoldWalletSystem.Application.DTOs.Auth;
using GoldWalletSystem.Application.DTOs.Common;
using GoldWalletSystem.Application.DTOs.Otp;
using GoldWalletSystem.Application.Interfaces.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using System.Text.RegularExpressions;

namespace GoldWalletSystem.API.Controllers;

[ApiController]
[Route("api/auth")]
public partial class AuthController(IAuthService authService, IWebHostEnvironment environment) : ControllerBase
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
        await PersistInlineDocumentsAsync(request, cancellationToken);
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


    [HttpPost("refresh-token")]
    [ProducesResponseType(typeof(ApiResponse<LoginResponseDto>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> RefreshToken([FromBody] RefreshTokenRequestDto request, CancellationToken cancellationToken = default)
    {
        var result = await authService.RefreshTokenAsync(request, cancellationToken);
        return Ok(ApiResponse<LoginResponseDto>.Ok(result, "Token refreshed"));
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

    [Authorize]
    [HttpPost("logout")]
    [ProducesResponseType(typeof(ApiResponse<string>), StatusCodes.Status200OK)]
    public async Task<IActionResult> Logout([FromBody] LogoutRequestDto? request, CancellationToken cancellationToken = default)
    {
        var userIdClaim = User.FindFirstValue(ClaimTypes.NameIdentifier) ?? User.FindFirstValue("sub");
        if (!int.TryParse(userIdClaim, out var userId))
            return Unauthorized(ApiResponse<object>.Fail("Unauthorized", 401));

        await authService.LogoutAsync(userId, request?.RefreshToken, cancellationToken);
        return Ok(ApiResponse<string>.Ok("Logged out", "Logout successful"));
    }

    private async Task PersistInlineDocumentsAsync(RegisterRequestDto request, CancellationToken cancellationToken)
    {
        if (!string.Equals(request.Role, GoldWalletSystem.Domain.Constants.SystemRoles.Seller, StringComparison.OrdinalIgnoreCase))
            return;

        var segment = BuildStorageSegment(request);
        var webRoot = string.IsNullOrWhiteSpace(environment.WebRootPath)
            ? Path.Combine(environment.ContentRootPath, "wwwroot")
            : environment.WebRootPath;
        var baseDir = Path.Combine(webRoot, "kyc", segment);
        Directory.CreateDirectory(baseDir);

        foreach (var doc in request.Documents)
        {
            if (string.IsNullOrWhiteSpace(doc.FilePath) || !doc.FilePath.StartsWith("data:", StringComparison.OrdinalIgnoreCase))
                continue;

            var commaIndex = doc.FilePath.IndexOf(',');
            if (commaIndex <= 0) continue;

            var meta = doc.FilePath[..commaIndex];
            var base64 = doc.FilePath[(commaIndex + 1)..];
            if (!meta.Contains(";base64", StringComparison.OrdinalIgnoreCase)) continue;

            byte[] bytes;
            try
            {
                bytes = Convert.FromBase64String(base64);
            }
            catch
            {
                continue;
            }

            var safeFileName = SanitizeFileName(doc.FileName);
            if (string.IsNullOrWhiteSpace(safeFileName))
                safeFileName = $"{doc.DocumentType}_{DateTime.UtcNow:yyyyMMddHHmmssfff}.bin";

            var physicalPath = Path.Combine(baseDir, safeFileName);
            await System.IO.File.WriteAllBytesAsync(physicalPath, bytes, cancellationToken);

            var relativePath = $"/kyc/{segment}/{safeFileName}".Replace("\\", "/");
            doc.FilePath = relativePath;

            if (string.IsNullOrWhiteSpace(doc.ContentType) || doc.ContentType == "application/octet-stream")
            {
                var contentTypeMatch = Regex.Match(meta, @"^data:(?<type>[^;]+);base64$", RegexOptions.IgnoreCase);
                if (contentTypeMatch.Success)
                    doc.ContentType = contentTypeMatch.Groups["type"].Value;
            }
        }
    }

    private static string BuildStorageSegment(RegisterRequestDto request)
    {
        var raw = !string.IsNullOrWhiteSpace(request.CompanyInfo.CompanyCode)
            ? request.CompanyInfo.CompanyCode
            : request.CompanyInfo.CompanyName;

        if (string.IsNullOrWhiteSpace(raw))
            raw = "seller";

        var cleaned = Regex.Replace(raw.ToLowerInvariant(), @"[^a-z0-9\-]+", "-").Trim('-');
        return string.IsNullOrWhiteSpace(cleaned) ? "seller" : cleaned;
    }

    private static string SanitizeFileName(string? name)
    {
        if (string.IsNullOrWhiteSpace(name)) return string.Empty;
        var fileName = Path.GetFileName(name);
        foreach (var c in Path.GetInvalidFileNameChars())
            fileName = fileName.Replace(c, '_');
        return fileName;
    }
}
