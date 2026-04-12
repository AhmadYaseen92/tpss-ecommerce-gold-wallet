using GoldWalletSystem.Application.DTOs.Common;
using GoldWalletSystem.Application.DTOs.Profile;
using GoldWalletSystem.Application.Interfaces.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace GoldWalletSystem.API.Controllers;

[ApiController]
[Authorize]
[Route("api/profile")]
public class ProfileController(IProfileService profileService, ICurrentUserService currentUser) : SecuredControllerBase(currentUser)
{
    [HttpPost("by-user")]
    public async Task<IActionResult> GetByUser([FromBody] UserRequestDto request, CancellationToken cancellationToken = default)
    {
        if (!HasUserAccess(request.UserId)) return ForbidApiResponse();

        var data = await profileService.GetByUserIdAsync(request.UserId, cancellationToken);
        if (data is null)
            return NotFound(ApiResponse<ProfileDto>.Fail("Profile not found", StatusCodes.Status404NotFound));

        return Ok(ApiResponse<ProfileDto>.Ok(data));
    }

    [HttpPut("personal")]
    public async Task<IActionResult> UpdatePersonal([FromBody] UpdateProfilePersonalInfoRequestDto request, CancellationToken cancellationToken = default)
    {
        if (!HasUserAccess(request.UserId)) return ForbidApiResponse();
        var data = await profileService.UpdatePersonalInfoAsync(request, cancellationToken);
        return Ok(ApiResponse<ProfileDto>.Ok(data, "Profile personal information updated"));
    }

    [HttpPut("settings")]
    public async Task<IActionResult> UpdateSettings([FromBody] UpdateProfileSettingsRequestDto request, CancellationToken cancellationToken = default)
    {
        if (!HasUserAccess(request.UserId)) return ForbidApiResponse();
        var data = await profileService.UpdateSettingsAsync(request, cancellationToken);
        return Ok(ApiResponse<ProfileDto>.Ok(data, "Profile settings updated"));
    }

    [HttpPut("password")]
    public async Task<IActionResult> UpdatePassword([FromBody] UpdatePasswordRequestDto request, CancellationToken cancellationToken = default)
    {
        if (!HasUserAccess(request.UserId)) return ForbidApiResponse();
        await profileService.ChangePasswordAsync(request, cancellationToken);
        return Ok(ApiResponse<object>.Ok(new { request.UserId }, "Password updated"));
    }

    [HttpPost("payment-methods")]
    public async Task<IActionResult> UpsertPaymentMethod([FromBody] UpsertPaymentMethodRequestDto request, CancellationToken cancellationToken = default)
    {
        if (!HasUserAccess(request.UserId)) return ForbidApiResponse();
        var data = await profileService.UpsertPaymentMethodAsync(request, cancellationToken);
        return Ok(ApiResponse<ProfileDto>.Ok(data, "Payment method saved"));
    }

    [HttpPost("linked-bank-accounts")]
    public async Task<IActionResult> UpsertLinkedBank([FromBody] UpsertLinkedBankAccountRequestDto request, CancellationToken cancellationToken = default)
    {
        if (!HasUserAccess(request.UserId)) return ForbidApiResponse();
        var data = await profileService.UpsertLinkedBankAccountAsync(request, cancellationToken);
        return Ok(ApiResponse<ProfileDto>.Ok(data, "Linked bank account saved"));
    }
}
