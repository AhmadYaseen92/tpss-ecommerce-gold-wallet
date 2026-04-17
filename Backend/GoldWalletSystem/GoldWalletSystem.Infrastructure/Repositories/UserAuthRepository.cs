using GoldWalletSystem.Application.Interfaces.Repositories;
using GoldWalletSystem.Domain.Entities;
using GoldWalletSystem.Infrastructure.Database.Context;
using Microsoft.EntityFrameworkCore;

namespace GoldWalletSystem.Infrastructure.Repositories;

public class UserAuthRepository(AppDbContext dbContext) : IUserAuthRepository
{
    public Task<User?> GetByEmailAsync(string email, CancellationToken cancellationToken = default)
        => dbContext.Users.AsNoTracking().FirstOrDefaultAsync(x => x.Email == email, cancellationToken);

    public Task<User?> GetByIdAsync(int userId, CancellationToken cancellationToken = default)
        => dbContext.Users.AsNoTracking().FirstOrDefaultAsync(x => x.Id == userId, cancellationToken);

    public Task<Seller?> GetSellerByIdAsync(int sellerId, CancellationToken cancellationToken = default)
        => dbContext.Sellers.AsNoTracking().FirstOrDefaultAsync(x => x.Id == sellerId, cancellationToken);

    public async Task<Seller> AddSellerAsync(Seller seller, CancellationToken cancellationToken = default)
    {
        dbContext.Sellers.Add(seller);
        await dbContext.SaveChangesAsync(cancellationToken);
        return seller;
    }

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
