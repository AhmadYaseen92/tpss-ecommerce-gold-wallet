using GoldWalletSystem.Application.Interfaces.Repositories;
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
}
