using GoldWalletSystem.Application.Constants;
using GoldWalletSystem.Application.DTOs.Configuration;
using GoldWalletSystem.Application.DTOs.Otp;
using GoldWalletSystem.Application.Interfaces.Repositories;
using GoldWalletSystem.Application.Interfaces.Services;
using GoldWalletSystem.Application.Models.Otp;
using GoldWalletSystem.Domain.Entities;
using GoldWalletSystem.Domain.Enums;
using System.Security.Cryptography;

namespace GoldWalletSystem.Application.Services;

public class OtpService(
    IUserAuthRepository userAuthRepository,
    IPasswordHasher passwordHasher,
    IMobileAppConfigurationRepository mobileAppConfigurationRepository,
    IOtpDeliveryService otpDeliveryService,
    IOtpSessionStore otpSessionStore,
    IAuditLogRepository auditLogRepository) : IOtpService
{
    private sealed class OtpSettings
    {
        public bool EnableWhatsapp { get; init; } = true;
        public bool EnableEmail { get; init; } = true;
        public int ExpirySeconds { get; init; } = 600;
        public int ResendCooldownSeconds { get; init; } = 60;
        public int MaxResendCount { get; init; } = 3;
        public int MaxVerificationAttempts { get; init; } = 5;
        public IReadOnlyCollection<string> RequiredActions { get; init; } = [];
        public IReadOnlyCollection<string> ChannelPriority { get; init; } = ["whatsapp", "email"];
    }

    public async Task<OtpDispatchResponseDto> RequestAsync(RequestOtpRequestDto request, CancellationToken cancellationToken = default)
    {
        var user = await ResolveUserAsync(request.UserId, cancellationToken);
        var actionType = NormalizeActionType(request.ActionType);
        var actionReferenceId = NormalizeReference(request.ActionReferenceId);
        var settings = await GetSettingsAsync(cancellationToken);
        ValidateActionIsProtected(actionType, settings);

        var channel = ResolveChannel(settings, request.ForceEmailFallback);
        var otpCode = GenerateOtpCode();
        var now = DateTime.UtcNow;

        var session = new OtpSessionModel
        {
            OtpRequestId = Guid.NewGuid().ToString("N"),
            UserId = user.Id,
            ActionType = actionType,
            ActionReferenceId = actionReferenceId,
            OtpHash = passwordHasher.Hash(otpCode),
            ExpiresAtUtc = now.AddSeconds(settings.ExpirySeconds),
            NextResendAtUtc = now.AddSeconds(settings.ResendCooldownSeconds),
            LastDestinationChannel = channel.ToString(),
            LastMaskedDestination = ResolveMaskedDestination(user, channel),
            Status = "Pending",
        };

        await otpSessionStore.UpsertSessionAsync(session, cancellationToken);
        //await otpDeliveryService.SendOtpAsync(user, otpCode, [channel], CancellationToken.None);
        await LogAsync(user.Id, "OtpRequested", $"action={actionType};ref={actionReferenceId};channel={channel};requestId={session.OtpRequestId}", cancellationToken);

        return ToDispatchResponse(session, settings);
    }

    public async Task<OtpDispatchResponseDto> ResendAsync(ResendOtpRequestDto request, CancellationToken cancellationToken = default)
    {
        var session = await otpSessionStore.GetSessionAsync(request.OtpRequestId, cancellationToken)
            ?? throw new InvalidOperationException("OTP session not found.");

        if (session.UserId != request.UserId)
            throw new UnauthorizedAccessException("OTP session does not belong to this user.");

        var settings = await GetSettingsAsync(cancellationToken);
        var now = DateTime.UtcNow;
        if (session.ExpiresAtUtc <= now || session.Status != "Pending")
            throw new InvalidOperationException("OTP session expired. Request a new OTP.");
        if (session.ResendCount >= settings.MaxResendCount)
            throw new InvalidOperationException("Resend attempts exceeded.");
        if (session.NextResendAtUtc > now)
            throw new InvalidOperationException("Resend is on cooldown.");

        var user = await ResolveUserAsync(request.UserId, cancellationToken);
        var channel = ResolveChannel(settings, request.ForceEmailFallback);
        var code = GenerateOtpCode();

        session.ResendCount += 1;
        session.OtpHash = passwordHasher.Hash(code);
        session.NextResendAtUtc = now.AddSeconds(settings.ResendCooldownSeconds);
        session.LastDestinationChannel = channel.ToString();
        session.LastMaskedDestination = ResolveMaskedDestination(user, channel);
        session.Status = "Pending";
        await otpSessionStore.UpsertSessionAsync(session, cancellationToken);

        await otpDeliveryService.SendOtpAsync(user, code, [channel], CancellationToken.None);
        await LogAsync(user.Id, "OtpResent", $"action={session.ActionType};ref={session.ActionReferenceId};channel={channel};requestId={session.OtpRequestId};resend={session.ResendCount}", cancellationToken);
        return ToDispatchResponse(session, settings);
    }

    public async Task<VerifyOtpResponseDto> VerifyAsync(VerifyOtpRequestDto request, CancellationToken cancellationToken = default)
    {
        var session = await otpSessionStore.GetSessionAsync(request.OtpRequestId, cancellationToken)
            ?? throw new InvalidOperationException("OTP session not found.");

        if (session.UserId != request.UserId)
            throw new UnauthorizedAccessException("OTP session does not belong to this user.");

        var settings = await GetSettingsAsync(cancellationToken);
        var now = DateTime.UtcNow;
        if (session.Status != "Pending" || session.ExpiresAtUtc <= now)
            throw new InvalidOperationException("OTP expired. Request a new OTP.");

        session.VerifyAttempts += 1;
        if (!passwordHasher.Verify(request.OtpCode.Trim(), session.OtpHash))
        {
            if (session.VerifyAttempts >= settings.MaxVerificationAttempts)
            {
                session.Status = "Invalidated";
                await otpSessionStore.RemoveSessionAsync(session.OtpRequestId, cancellationToken);
                await LogAsync(session.UserId, "OtpVerifyFailed", $"action={session.ActionType};ref={session.ActionReferenceId};requestId={session.OtpRequestId};status=max_attempts", cancellationToken);
                throw new InvalidOperationException("Maximum OTP attempts reached. Request a new OTP.");
            }

            await otpSessionStore.UpsertSessionAsync(session, cancellationToken);
            await LogAsync(session.UserId, "OtpVerifyFailed", $"action={session.ActionType};ref={session.ActionReferenceId};requestId={session.OtpRequestId};attempts={session.VerifyAttempts}", cancellationToken);
            throw new InvalidOperationException("OTP is invalid.");
        }

        session.Status = "Verified";
        await otpSessionStore.RemoveSessionAsync(session.OtpRequestId, cancellationToken);

        var grant = new OtpVerificationGrantModel
        {
            VerificationToken = Guid.NewGuid().ToString("N"),
            UserId = session.UserId,
            ActionType = session.ActionType,
            ActionReferenceId = session.ActionReferenceId,
            ExpiresAtUtc = now.AddSeconds(600)
        };
        await otpSessionStore.UpsertGrantAsync(grant, cancellationToken);
        await LogAsync(session.UserId, "OtpVerified", $"action={session.ActionType};ref={session.ActionReferenceId};requestId={session.OtpRequestId}", cancellationToken);

        return new VerifyOtpResponseDto
        {
            VerificationToken = grant.VerificationToken,
            ActionType = session.ActionType,
            ActionReferenceId = session.ActionReferenceId,
            VerifiedAtUtc = now
        };
    }

    public async Task ConsumeVerificationGrantAsync(int userId, string actionType, string actionReferenceId, string verificationToken, CancellationToken cancellationToken = default)
    {
        if (string.IsNullOrWhiteSpace(verificationToken))
            throw new InvalidOperationException("OTP verification token is required.");

        var grant = await otpSessionStore.GetGrantAsync(verificationToken, cancellationToken)
            ?? throw new UnauthorizedAccessException("Invalid OTP verification token.");
        if (grant.ExpiresAtUtc <= DateTime.UtcNow)
            throw new UnauthorizedAccessException("OTP verification token expired.");
        if (grant.UserId != userId)
            throw new UnauthorizedAccessException("OTP verification token user mismatch.");
        if (!string.Equals(grant.ActionType, NormalizeActionType(actionType), StringComparison.OrdinalIgnoreCase))
            throw new UnauthorizedAccessException("OTP action mismatch.");
        if (!string.Equals(grant.ActionReferenceId, NormalizeReference(actionReferenceId), StringComparison.Ordinal))
            throw new UnauthorizedAccessException("OTP action reference mismatch.");

        await otpSessionStore.RemoveGrantAsync(verificationToken, cancellationToken);
        await LogAsync(userId, "OtpGrantConsumed", $"action={actionType};ref={actionReferenceId};token={verificationToken}", cancellationToken);
    }

    private async Task<User> ResolveUserAsync(int userId, CancellationToken cancellationToken)
        => await userAuthRepository.GetByIdAsync(userId, cancellationToken)
           ?? throw new InvalidOperationException("User not found.");

    private async Task<OtpSettings> GetSettingsAsync(CancellationToken cancellationToken)
    {
        var defaults = DefaultSettings();
        var allConfigs = await mobileAppConfigurationRepository.GetAllAsync(cancellationToken);
        var lookup = allConfigs.ToDictionary(x => x.ConfigKey, StringComparer.OrdinalIgnoreCase);

        bool ReadBool(string key, bool fallback)
            => lookup.TryGetValue(key, out var config) && config.ValueBool.HasValue ? config.ValueBool.Value : fallback;

        int ReadInt(string key, int fallback)
            => lookup.TryGetValue(key, out var config) && config.ValueInt.HasValue ? config.ValueInt.Value : fallback;

        IReadOnlyCollection<string> ReadList(string key, IReadOnlyCollection<string> fallback)
        {
            if (!lookup.TryGetValue(key, out var config) || string.IsNullOrWhiteSpace(config.ValueString))
                return fallback;

            return config.ValueString
                .Split(',', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries)
                .Select(x => x.Trim().ToLowerInvariant())
                .Where(x => !string.IsNullOrWhiteSpace(x))
                .Distinct()
                .ToArray();
        }

        return new OtpSettings
        {
            EnableWhatsapp = ReadBool(MobileAppConfigurationKeys.OtpEnableWhatsapp, defaults.EnableWhatsapp),
            EnableEmail = ReadBool(MobileAppConfigurationKeys.OtpEnableEmail, defaults.EnableEmail),
            ExpirySeconds = Math.Clamp(ReadInt(MobileAppConfigurationKeys.OtpExpirySeconds, defaults.ExpirySeconds), 60, 1800),
            ResendCooldownSeconds = Math.Clamp(ReadInt(MobileAppConfigurationKeys.OtpResendCooldownSeconds, defaults.ResendCooldownSeconds), 10, 300),
            MaxResendCount = Math.Clamp(ReadInt(MobileAppConfigurationKeys.OtpMaxResendCount, defaults.MaxResendCount), 0, 10),
            MaxVerificationAttempts = Math.Clamp(ReadInt(MobileAppConfigurationKeys.OtpMaxVerificationAttempts, defaults.MaxVerificationAttempts), 1, 10),
            RequiredActions = ReadList(MobileAppConfigurationKeys.OtpRequiredActions, defaults.RequiredActions),
            ChannelPriority = ReadList(MobileAppConfigurationKeys.OtpChannelPriority, defaults.ChannelPriority)
        };
    }

    private static OtpSettings DefaultSettings()
        => new()
        {
            RequiredActions =
            [
                OtpActionTypes.Registration,
                OtpActionTypes.ResetPassword,
                OtpActionTypes.Checkout,
                OtpActionTypes.Buy,
                OtpActionTypes.Sell,
                OtpActionTypes.Transfer,
                OtpActionTypes.Gift,
                OtpActionTypes.Pickup,
                OtpActionTypes.AddBankAccount,
                OtpActionTypes.EditBankAccount,
                OtpActionTypes.RemoveBankAccount,
                OtpActionTypes.AddPaymentMethod,
                OtpActionTypes.EditPaymentMethod,
                OtpActionTypes.RemovePaymentMethod,
                OtpActionTypes.ChangeEmail,
                OtpActionTypes.ChangePassword,
                OtpActionTypes.ChangeMobileNumber
            ]
        };

    private static void ValidateActionIsProtected(string actionType, OtpSettings settings)
    {
        if (!settings.RequiredActions.Any(x => string.Equals(x, actionType, StringComparison.OrdinalIgnoreCase)))
            throw new InvalidOperationException($"Action '{actionType}' is not configured for OTP.");
    }

    private static OtpDeliveryChannel ResolveChannel(OtpSettings settings, bool forceEmailFallback)
    {
        if (forceEmailFallback)
        {
            if (!settings.EnableEmail) throw new InvalidOperationException("Email channel is disabled.");
            return OtpDeliveryChannel.Email;
        }

        foreach (var channelName in settings.ChannelPriority)
        {
            if (string.Equals(channelName, "whatsapp", StringComparison.OrdinalIgnoreCase) && settings.EnableWhatsapp)
                return OtpDeliveryChannel.WhatsApp;
            if (string.Equals(channelName, "email", StringComparison.OrdinalIgnoreCase) && settings.EnableEmail)
                return OtpDeliveryChannel.Email;
        }

        if (settings.EnableWhatsapp) return OtpDeliveryChannel.WhatsApp;
        if (settings.EnableEmail) return OtpDeliveryChannel.Email;
        throw new InvalidOperationException("No OTP delivery channel is enabled.");
    }

    private static OtpDispatchResponseDto ToDispatchResponse(OtpSessionModel session, OtpSettings settings)
        => new()
        {
            OtpRequestId = session.OtpRequestId,
            ActionType = session.ActionType,
            ActionReferenceId = session.ActionReferenceId,
            DestinationChannel = session.LastDestinationChannel,
            MaskedDestination = session.LastMaskedDestination,
            ExpiresAtUtc = session.ExpiresAtUtc,
            NextResendAtUtc = session.NextResendAtUtc,
            RemainingResends = Math.Max(0, settings.MaxResendCount - session.ResendCount)
        };

    private async Task LogAsync(int userId, string action, string details, CancellationToken cancellationToken)
    {
        await auditLogRepository.AddAsync(new AuditLog
        {
            UserId = userId,
            Action = action,
            EntityName = "Otp",
            Details = details,
            CreatedAtUtc = DateTime.UtcNow
        }, cancellationToken);
    }

    private static string NormalizeActionType(string actionType)
        => string.IsNullOrWhiteSpace(actionType)
            ? throw new InvalidOperationException("ActionType is required.")
            : actionType.Trim().ToLowerInvariant();

    private static string NormalizeReference(string actionReference)
        => string.IsNullOrWhiteSpace(actionReference)
            ? throw new InvalidOperationException("ActionReferenceId is required.")
            : actionReference.Trim();

    private static string GenerateOtpCode()
        => RandomNumberGenerator.GetInt32(0, 1_000_000).ToString("D6");

    private static string ResolveMaskedDestination(User user, OtpDeliveryChannel channel)
    {
        var raw = channel switch
        {
            OtpDeliveryChannel.Email => user.Email,
            _ => user.PhoneNumber ?? user.Email
        };

        if (string.IsNullOrWhiteSpace(raw))
            return "***";

        if (raw.Contains('@'))
        {
            var parts = raw.Split('@', 2);
            var left = parts[0];
            var maskedLeft = left.Length <= 2 ? new string('*', left.Length) : $"{left[0]}***{left[^1]}";
            return $"{maskedLeft}@{parts[1]}";
        }

        var trimmed = raw.Trim();
        return trimmed.Length <= 4
            ? new string('*', trimmed.Length)
            : $"{new string('*', trimmed.Length - 4)}{trimmed[^4..]}";
    }
}
