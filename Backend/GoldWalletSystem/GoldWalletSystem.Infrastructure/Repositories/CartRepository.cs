using GoldWalletSystem.Application.Interfaces.Repositories;
using GoldWalletSystem.Domain.Entities;
using GoldWalletSystem.Infrastructure.Database.Context;
using Microsoft.EntityFrameworkCore;

namespace GoldWalletSystem.Infrastructure.Repositories;

public class CartRepository(AppDbContext dbContext) : ICartRepository
{
    public async Task<Cart> GetOrCreateByUserIdAsync(int userId, CancellationToken cancellationToken = default)
    {
        var cart = await dbContext.Carts
            .Include(x => x.Items)
            .ThenInclude(x => x.Product)
            .FirstOrDefaultAsync(x => x.UserId == userId, cancellationToken);

        if (cart is not null)
        {
            return cart;
        }

        cart = new Cart { UserId = userId };
        dbContext.Carts.Add(cart);
        await dbContext.SaveChangesAsync(cancellationToken);
        return await dbContext.Carts.Include(x => x.Items).ThenInclude(x => x.Product).FirstAsync(x => x.Id == cart.Id, cancellationToken);
    }

    public Task SaveChangesAsync(CancellationToken cancellationToken = default)
        => dbContext.SaveChangesAsync(cancellationToken);
}
