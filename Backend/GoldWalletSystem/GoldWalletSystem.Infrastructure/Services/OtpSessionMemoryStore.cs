using GoldWalletSystem.Application.Interfaces.Services;
using GoldWalletSystem.Application.Models.Otp;
using Microsoft.Extensions.Caching.Memory;

namespace GoldWalletSystem.Infrastructure.Services;

public class OtpSessionMemoryStore(IMemoryCache cache) : IOtpSessionStore
{
    private static string SessionKey(string otpRequestId) => $"otp:session:{otpRequestId}";
    private static string GrantKey(string verificationToken) => $"otp:grant:{verificationToken}";

    public Task UpsertSessionAsync(OtpSessionModel session, CancellationToken cancellationToken = default)
    {
        cache.Set(SessionKey(session.OtpRequestId), session, session.ExpiresAtUtc);
        return Task.CompletedTask;
    }

    public Task<OtpSessionModel?> GetSessionAsync(string otpRequestId, CancellationToken cancellationToken = default)
    {
        cache.TryGetValue<OtpSessionModel>(SessionKey(otpRequestId), out var session);
        return Task.FromResult(session);
    }

    public Task RemoveSessionAsync(string otpRequestId, CancellationToken cancellationToken = default)
    {
        cache.Remove(SessionKey(otpRequestId));
        return Task.CompletedTask;
    }

    public Task UpsertGrantAsync(OtpVerificationGrantModel grant, CancellationToken cancellationToken = default)
    {
        cache.Set(GrantKey(grant.VerificationToken), grant, grant.ExpiresAtUtc);
        return Task.CompletedTask;
    }

    public Task<OtpVerificationGrantModel?> GetGrantAsync(string verificationToken, CancellationToken cancellationToken = default)
    {
        cache.TryGetValue<OtpVerificationGrantModel>(GrantKey(verificationToken), out var grant);
        return Task.FromResult(grant);
    }

    public Task RemoveGrantAsync(string verificationToken, CancellationToken cancellationToken = default)
    {
        cache.Remove(GrantKey(verificationToken));
        return Task.CompletedTask;
    }
}

