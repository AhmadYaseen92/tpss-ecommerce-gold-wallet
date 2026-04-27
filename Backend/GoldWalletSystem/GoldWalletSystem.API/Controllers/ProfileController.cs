using GoldWalletSystem.Application.DTOs.Common;
using GoldWalletSystem.Application.DTOs.Profile;
using GoldWalletSystem.Application.Constants;
using GoldWalletSystem.Application.Interfaces.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace GoldWalletSystem.API.Controllers;

[ApiController]
[Authorize]
[Route("api/profile")]
public class ProfileController(IProfileService profileService, IOtpService otpService, ICurrentUserService currentUser) : SecuredControllerBase(currentUser)
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
        var current = await profileService.GetByUserIdAsync(request.UserId, cancellationToken)
            ?? throw new InvalidOperationException("Profile not found.");

        var emailChanged = !string.Equals(
            current.Email?.Trim(),
            request.Email?.Trim(),
            StringComparison.OrdinalIgnoreCase);
        var mobileChanged = !string.Equals(
            current.PhoneNumber?.Trim(),
            request.PhoneNumber?.Trim(),
            StringComparison.Ordinal);

        if (emailChanged || mobileChanged)
        {
            var otpAction = emailChanged
                ? OtpActionTypes.ChangeEmail
                : OtpActionTypes.ChangeMobileNumber;

            await ConsumeOtpIfRequiredAsync(
                request.UserId,
                otpAction,
                request.OtpActionReferenceId,
                request.OtpVerificationToken,
                cancellationToken);
        }

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
        await ConsumeOtpIfRequiredAsync(
            request.UserId,
            OtpActionTypes.ChangePassword,
            request.OtpActionReferenceId,
            request.OtpVerificationToken,
            cancellationToken);
        await profileService.ChangePasswordAsync(request, cancellationToken);
        return Ok(ApiResponse<object>.Ok(new { request.UserId }, "Password updated"));
    }

    [HttpPost("payment-methods")]
    public async Task<IActionResult> UpsertPaymentMethod([FromBody] UpsertPaymentMethodRequestDto request, CancellationToken cancellationToken = default)
    {
        if (!HasUserAccess(request.UserId)) return ForbidApiResponse();
        await ConsumeOtpIfRequiredAsync(
            request.UserId,
            request.PaymentMethodId.HasValue ? OtpActionTypes.EditPaymentMethod : OtpActionTypes.AddPaymentMethod,
            request.OtpActionReferenceId,
            request.OtpVerificationToken,
            cancellationToken);
        var data = await profileService.UpsertPaymentMethodAsync(request, cancellationToken);
        return Ok(ApiResponse<ProfileDto>.Ok(data, "Payment method saved"));
    }

    [HttpPost("linked-bank-accounts")]
    public async Task<IActionResult> UpsertLinkedBank([FromBody] UpsertLinkedBankAccountRequestDto request, CancellationToken cancellationToken = default)
    {
        if (!HasUserAccess(request.UserId)) return ForbidApiResponse();
        await ConsumeOtpIfRequiredAsync(
            request.UserId,
            request.LinkedBankAccountId.HasValue ? OtpActionTypes.EditBankAccount : OtpActionTypes.AddBankAccount,
            request.OtpActionReferenceId,
            request.OtpVerificationToken,
            cancellationToken);
        var data = await profileService.UpsertLinkedBankAccountAsync(request, cancellationToken);
        return Ok(ApiResponse<ProfileDto>.Ok(data, "Linked bank account saved"));
    }

    [HttpDelete("payment-methods")]
    public async Task<IActionResult> RemovePaymentMethod([FromBody] RemovePaymentMethodRequestDto request, CancellationToken cancellationToken = default)
    {
        if (!HasUserAccess(request.UserId)) return ForbidApiResponse();
        await ConsumeOtpIfRequiredAsync(
            request.UserId,
            OtpActionTypes.RemovePaymentMethod,
            request.OtpActionReferenceId,
            request.OtpVerificationToken,
            cancellationToken);
        var data = await profileService.RemovePaymentMethodAsync(request, cancellationToken);
        return Ok(ApiResponse<ProfileDto>.Ok(data, "Payment method removed"));
    }

    [HttpDelete("linked-bank-accounts")]
    public async Task<IActionResult> RemoveLinkedBank([FromBody] RemoveLinkedBankAccountRequestDto request, CancellationToken cancellationToken = default)
    {
        if (!HasUserAccess(request.UserId)) return ForbidApiResponse();
        await ConsumeOtpIfRequiredAsync(
            request.UserId,
            OtpActionTypes.RemoveBankAccount,
            request.OtpActionReferenceId,
            request.OtpVerificationToken,
            cancellationToken);
        var data = await profileService.RemoveLinkedBankAccountAsync(request, cancellationToken);
        return Ok(ApiResponse<ProfileDto>.Ok(data, "Linked bank account removed"));
    }

    private async Task ConsumeOtpIfRequiredAsync(
        int userId,
        string actionType,
        string actionReferenceId,
        string verificationToken,
        CancellationToken cancellationToken)
    {
        var isOtpRequired = await otpService.IsActionProtectedAsync(actionType, cancellationToken);
        if (!isOtpRequired) return;

        await otpService.ConsumeVerificationGrantAsync(
            userId,
            actionType,
            actionReferenceId,
            verificationToken,
            cancellationToken);
    }
}
