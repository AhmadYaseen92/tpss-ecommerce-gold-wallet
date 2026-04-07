namespace TPSS.GoldWallet.Application.Abstractions;

public interface IIdentityService
{
    Task<(bool Succeeded, Guid UserId, string Email, string Role)> ValidateCredentialsAsync(string email, string password, CancellationToken cancellationToken = default);
    Task EnsureRolesSeededAsync(CancellationToken cancellationToken = default);
}
