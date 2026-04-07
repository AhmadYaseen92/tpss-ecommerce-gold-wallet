using Microsoft.EntityFrameworkCore;
using TPSS.GoldWallet.Application.Abstractions;
using TPSS.GoldWallet.Domain.Entities;
using TPSS.GoldWallet.Infrastructure.Persistence;

namespace TPSS.GoldWallet.Infrastructure.Repositories;

public sealed class CartRepository(AppDbContext dbContext) : ICartRepository
{
    public Task<Cart?> GetByCustomerIdAsync(Guid customerId, CancellationToken cancellationToken = default)
    {
        return dbContext.Carts
            .Include(x => x.Items)
            .FirstOrDefaultAsync(x => x.CustomerId == customerId, cancellationToken);
    }

    public Task AddAsync(Cart cart, CancellationToken cancellationToken = default)
    {
        return dbContext.Carts.AddAsync(cart, cancellationToken).AsTask();
    }

    public void Update(Cart cart)
    {
        dbContext.Carts.Update(cart);
    }
}
