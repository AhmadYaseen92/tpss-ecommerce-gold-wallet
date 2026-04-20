using GoldWalletSystem.Application.Interfaces.Services;
using GoldWalletSystem.Application.Models.Auth;
using Microsoft.Extensions.Caching.Memory;

namespace GoldWalletSystem.Infrastructure.Services;

public class LoginOtpChallengeMemoryStore(IMemoryCache cache) : ILoginOtpChallengeStore
{
    private static string BuildCacheKey(int userId) => $"login-otp:{userId}";

    public Task UpsertAsync(LoginOtpChallengeModel challenge, CancellationToken cancellationToken = default)
    {
        cache.Set(BuildCacheKey(challenge.UserId), challenge, challenge.ExpiresAtUtc);
        return Task.CompletedTask;
    }

    public Task<LoginOtpChallengeModel?> GetActiveAsync(int userId, DateTime utcNow, CancellationToken cancellationToken = default)
    {
        var exists = cache.TryGetValue<LoginOtpChallengeModel>(BuildCacheKey(userId), out var challenge);
        if (!exists || challenge is null || challenge.ExpiresAtUtc <= utcNow)
            return Task.FromResult<LoginOtpChallengeModel?>(null);

        return Task.FromResult<LoginOtpChallengeModel?>(challenge);
    }

    public Task RemoveAsync(int userId, CancellationToken cancellationToken = default)
    {
        cache.Remove(BuildCacheKey(userId));
        return Task.CompletedTask;
    }
}

