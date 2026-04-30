using GoldWalletSystem.Application.Constants;
using GoldWalletSystem.Application.DTOs.Otp;
using GoldWalletSystem.Application.Interfaces.Services;

namespace GoldWalletSystem.Application.Services;

public class CheckoutOtpOrchestrator(IOtpService otpService) : ICheckoutOtpOrchestrator
{
    public string BuildActionReference(int userId, IReadOnlyCollection<int>? productIds, int? productId, int? quantity)
    {
        if (productId.HasValue && quantity.HasValue && quantity.Value > 0)
            return $"checkout:{userId}:product:{productId.Value}:qty:{quantity.Value}";

        if (productIds is { Count: > 0 })
        {
            var sorted = productIds.OrderBy(x => x).ToArray();
            return $"checkout:{userId}:cart:{string.Join('-', sorted)}";
        }

        return $"checkout:{userId}:cart:all";
    }

    public async Task<OtpDispatchResponseDto> RequestAsync(int userId, IReadOnlyCollection<int>? productIds, int? productId, int? quantity, bool forceEmailFallback, CancellationToken cancellationToken = default)
    {
        var actionReference = BuildActionReference(userId, productIds, productId, quantity);
        return await otpService.RequestAsync(new RequestOtpRequestDto
        {
            UserId = userId,
            ActionType = OtpActionTypes.Buy,
            ActionReferenceId = actionReference,
            ForceEmailFallback = forceEmailFallback
        }, cancellationToken);
    }

    public async Task EnsureOtpVerifiedAsync(int userId, IReadOnlyCollection<int>? productIds, int? productId, int? quantity, string otpVerificationToken, string otpActionReferenceId, string otpRequestId, string otpCode, CancellationToken cancellationToken = default)
    {
        var checkoutOtpRequired = await otpService.IsActionProtectedAsync(OtpActionTypes.Checkout, cancellationToken);
        var buyOtpRequired = await otpService.IsActionProtectedAsync(OtpActionTypes.Buy, cancellationToken);
        if (!checkoutOtpRequired && !buyOtpRequired) return;

        var actionReference = string.IsNullOrWhiteSpace(otpActionReferenceId)
            ? BuildActionReference(userId, productIds, productId, quantity)
            : otpActionReferenceId;

        if (!string.IsNullOrWhiteSpace(otpVerificationToken))
        {
            await ConsumeCheckoutOrBuyGrantAsync(userId, actionReference, otpVerificationToken, cancellationToken);
            return;
        }

        if (string.IsNullOrWhiteSpace(otpRequestId) || string.IsNullOrWhiteSpace(otpCode))
            throw new InvalidOperationException("Checkout OTP is required. Call /api/checkout/otp/request then verify with /api/checkout/otp/verify.");

        var verified = await otpService.VerifyAsync(new VerifyOtpRequestDto
        {
            UserId = userId,
            OtpRequestId = otpRequestId,
            OtpCode = otpCode
        }, cancellationToken);

        var verifiedAction = verified.ActionType.Trim().ToLowerInvariant();
        if (verifiedAction is not (OtpActionTypes.Checkout or OtpActionTypes.Buy))
            throw new InvalidOperationException("OTP action is invalid for checkout.");

        await otpService.ConsumeVerificationGrantAsync(
            userId,
            verified.ActionType,
            string.IsNullOrWhiteSpace(verified.ActionReferenceId) ? actionReference : verified.ActionReferenceId,
            verified.VerificationToken,
            cancellationToken);
    }

    private async Task ConsumeCheckoutOrBuyGrantAsync(int userId, string actionReference, string verificationToken, CancellationToken cancellationToken)
    {
        try
        {
            await otpService.ConsumeVerificationGrantAsync(userId, OtpActionTypes.Checkout, actionReference, verificationToken, cancellationToken);
            return;
        }
        catch (UnauthorizedAccessException) { }
        catch (InvalidOperationException) { }

        await otpService.ConsumeVerificationGrantAsync(userId, OtpActionTypes.Buy, actionReference, verificationToken, cancellationToken);
    }
}
