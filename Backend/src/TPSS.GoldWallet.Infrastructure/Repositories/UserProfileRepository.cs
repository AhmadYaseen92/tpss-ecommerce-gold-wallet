using Microsoft.EntityFrameworkCore;
using TPSS.GoldWallet.Application.Abstractions;
using TPSS.GoldWallet.Domain.Entities;
using TPSS.GoldWallet.Infrastructure.Persistence;

namespace TPSS.GoldWallet.Infrastructure.Repositories;

public sealed class UserProfileRepository(AppDbContext dbContext) : IUserProfileRepository
{
    public Task<UserProfile?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default)
        => dbContext.UserProfiles.FirstOrDefaultAsync(x => x.Id == id, cancellationToken);

    public Task AddAsync(UserProfile profile, CancellationToken cancellationToken = default)
        => dbContext.UserProfiles.AddAsync(profile, cancellationToken).AsTask();

    public void Update(UserProfile profile)
        => dbContext.UserProfiles.Update(profile);
}
