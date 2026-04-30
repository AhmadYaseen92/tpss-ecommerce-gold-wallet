using GoldWalletSystem.Application.Interfaces.Repositories;
using GoldWalletSystem.Domain.Entities;
using GoldWalletSystem.Infrastructure.Database.Context;
using Microsoft.EntityFrameworkCore;

namespace GoldWalletSystem.Infrastructure.Repositories;

public class UserAuthRepository(AppDbContext dbContext) : IUserAuthRepository
{
    public Task<User?> GetByEmailAsync(string email, CancellationToken cancellationToken = default)
        => dbContext.Users.AsNoTracking().FirstOrDefaultAsync(x => x.Email == email, cancellationToken);

    public Task<User?> GetByPhoneAsync(string phoneNumber, CancellationToken cancellationToken = default)
        => dbContext.Users.AsNoTracking().FirstOrDefaultAsync(x => x.PhoneNumber == phoneNumber, cancellationToken);

    public Task<User?> GetByIdAsync(int userId, CancellationToken cancellationToken = default)
        => dbContext.Users.AsNoTracking().FirstOrDefaultAsync(x => x.Id == userId, cancellationToken);

    public Task<Seller?> GetSellerByUserIdAsync(int userId, CancellationToken cancellationToken = default)
        => dbContext.Sellers.AsNoTracking().FirstOrDefaultAsync(x => x.UserId == userId, cancellationToken);

    public Task<Seller?> GetSellerByIdAsync(int sellerId, CancellationToken cancellationToken = default)
        => dbContext.Sellers.AsNoTracking().FirstOrDefaultAsync(x => x.Id == sellerId, cancellationToken);

    public async Task<string> GenerateNextCompanyCodeAsync(CancellationToken cancellationToken = default)
    {
        var codes = await dbContext.Sellers.AsNoTracking()
            .Select(x => x.CompanyCode)
            .Where(x => x != null && x != string.Empty)
            .ToListAsync(cancellationToken);

        var max = 99;
        foreach (var code in codes)
        {
            if (int.TryParse(code?.Trim(), out var parsed) && parsed > max)
                max = parsed;
        }

        return (max + 1).ToString();
    }

    public async Task<Seller> AddSellerProfileAsync(Seller seller, CancellationToken cancellationToken = default)
    {
        dbContext.Sellers.Add(seller);
        await dbContext.SaveChangesAsync(cancellationToken);
        return seller;
    }


    public async Task<(User User, Seller? Seller)> AddWithOptionalSellerAsync(User user, UserProfile? profile, Seller? seller, CancellationToken cancellationToken = default)
    {
        await using var transaction = await dbContext.Database.BeginTransactionAsync(cancellationToken);

        dbContext.Users.Add(user);
        await dbContext.SaveChangesAsync(cancellationToken);

        if (profile is not null)
        {
            profile.UserId = user.Id;
            dbContext.UserProfiles.Add(profile);
        }

        if (seller is not null)
        {
            seller.UserId = user.Id;
            dbContext.Sellers.Add(seller);
        }

        await dbContext.SaveChangesAsync(cancellationToken);
        await transaction.CommitAsync(cancellationToken);
        return (user, seller);
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

    public async Task ActivateUserAsync(int userId, CancellationToken cancellationToken = default)
    {
        var user = await dbContext.Users.FirstOrDefaultAsync(x => x.Id == userId, cancellationToken)
            ?? throw new InvalidOperationException("User not found.");
        user.IsActive = true;
        user.UpdatedAtUtc = DateTime.UtcNow;
        await dbContext.SaveChangesAsync(cancellationToken);
    }

    public async Task UpdatePasswordAsync(int userId, string passwordHash, CancellationToken cancellationToken = default)
    {
        var user = await dbContext.Users.FirstOrDefaultAsync(x => x.Id == userId, cancellationToken)
            ?? throw new InvalidOperationException("User not found.");
        user.PasswordHash = passwordHash;
        user.UpdatedAtUtc = DateTime.UtcNow;
        await dbContext.SaveChangesAsync(cancellationToken);
    }

    public async Task AddRefreshTokenAsync(RefreshToken refreshToken, CancellationToken cancellationToken = default)
    {
        dbContext.Add(refreshToken);
        await dbContext.SaveChangesAsync(cancellationToken);
    }

    public Task<RefreshToken?> GetActiveRefreshTokenAsync(int userId, string tokenHash, CancellationToken cancellationToken = default)
        => dbContext.Set<RefreshToken>()
            .FirstOrDefaultAsync(x =>
                x.UserId == userId &&
                x.TokenHash == tokenHash &&
                x.RevokedAtUtc == null &&
                x.ExpiresAtUtc > DateTime.UtcNow,
                cancellationToken);

    public async Task RevokeRefreshTokenAsync(int refreshTokenId, CancellationToken cancellationToken = default)
    {
        var entity = await dbContext.Set<RefreshToken>().FirstOrDefaultAsync(x => x.Id == refreshTokenId, cancellationToken);
        if (entity is null || entity.RevokedAtUtc.HasValue) return;
        entity.RevokedAtUtc = DateTime.UtcNow;
        entity.UpdatedAtUtc = DateTime.UtcNow;
        await dbContext.SaveChangesAsync(cancellationToken);
    }

    public async Task RevokeAllRefreshTokensAsync(int userId, CancellationToken cancellationToken = default)
    {
        var tokens = await dbContext.Set<RefreshToken>()
            .Where(x => x.UserId == userId && x.RevokedAtUtc == null)
            .ToListAsync(cancellationToken);

        if (tokens.Count == 0) return;

        var now = DateTime.UtcNow;
        foreach (var token in tokens)
        {
            token.RevokedAtUtc = now;
            token.UpdatedAtUtc = now;
        }

        await dbContext.SaveChangesAsync(cancellationToken);
    }

}
