using GoldWalletSystem.Application.Interfaces.Repositories;
using GoldWalletSystem.Domain.Entities;
using GoldWalletSystem.Infrastructure.Database.Context;
using Microsoft.EntityFrameworkCore;

namespace GoldWalletSystem.Infrastructure.Repositories;

public class UserAuthRepository(AppDbContext dbContext) : IUserAuthRepository
{
    public Task<User?> GetByEmailAsync(string email, CancellationToken cancellationToken = default)
        => dbContext.Users.AsNoTracking().FirstOrDefaultAsync(x => x.Email == email, cancellationToken);

    public async Task<User> AddAsync(User user, UserProfile? profile = null, CancellationToken cancellationToken = default)
    {
        dbContext.Users.Add(user);
        await dbContext.SaveChangesAsync(cancellationToken);

        if (profile is not null)
        {
            profile.UserId = user.Id;
            dbContext.UserProfiles.Add(profile);
            await dbContext.SaveChangesAsync(cancellationToken);
        }

        return user;
    }
}
