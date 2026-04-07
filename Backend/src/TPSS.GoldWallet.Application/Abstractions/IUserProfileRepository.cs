using TPSS.GoldWallet.Domain.Entities;

namespace TPSS.GoldWallet.Application.Abstractions;

public interface IUserProfileRepository
{
    Task<UserProfile?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default);
    Task AddAsync(UserProfile profile, CancellationToken cancellationToken = default);
    void Update(UserProfile profile);
}
