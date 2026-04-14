using GoldWalletSystem.Application.Interfaces.Repositories;
using GoldWalletSystem.Domain.Constants;
using GoldWalletSystem.Domain.Entities;
using GoldWalletSystem.Infrastructure.Database.Context;
using Microsoft.EntityFrameworkCore;

namespace GoldWalletSystem.Infrastructure.Repositories;

public class SellerAuthRepository(AppDbContext dbContext) : ISellerAuthRepository
{
    public Task<Seller?> GetByEmailAsync(string email, CancellationToken cancellationToken = default)
        => dbContext.Sellers
            .AsNoTracking()
            .FirstOrDefaultAsync(x => x.Email == email || x.ContactEmail == email, cancellationToken);

    public Task<User?> GetUserBySellerIdAsync(int sellerId, CancellationToken cancellationToken = default)
        => dbContext.Users
            .AsNoTracking()
            .FirstOrDefaultAsync(
                x => x.SellerId == sellerId &&
                     x.IsActive &&
                     x.Role == SystemRoles.Seller,
                cancellationToken);
}
