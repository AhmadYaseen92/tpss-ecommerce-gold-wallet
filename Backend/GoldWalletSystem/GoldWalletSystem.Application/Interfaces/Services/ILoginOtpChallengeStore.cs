using GoldWalletSystem.Application.Models.Auth;

namespace GoldWalletSystem.Application.Interfaces.Services;

public interface ILoginOtpChallengeStore
{
    Task UpsertAsync(LoginOtpChallengeModel challenge, CancellationToken cancellationToken = default);
    Task<LoginOtpChallengeModel?> GetActiveAsync(int userId, DateTime utcNow, CancellationToken cancellationToken = default);
    Task RemoveAsync(int userId, CancellationToken cancellationToken = default);
}

