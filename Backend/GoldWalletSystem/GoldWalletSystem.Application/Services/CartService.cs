using GoldWalletSystem.Application.DTOs.Cart;
using GoldWalletSystem.Application.Interfaces.Repositories;
using GoldWalletSystem.Application.Interfaces.Services;
using GoldWalletSystem.Domain.Entities;

namespace GoldWalletSystem.Application.Services;

public class CartService(ICartRepository cartRepository, IProductRepository productRepository) : ICartService
{
    public async Task<CartDto> GetCartByUserIdAsync(int userId, CancellationToken cancellationToken = default)
    {
        var cart = await cartRepository.GetOrCreateByUserIdAsync(userId, cancellationToken);
        return Map(cart);
    }

    public async Task<CartDto> AddItemAsync(int userId, int productId, int quantity, CancellationToken cancellationToken = default)
    {
        if (quantity <= 0)
        {
            throw new ArgumentException("Quantity should be greater than 0.");
        }

        var cart = await cartRepository.GetOrCreateByUserIdAsync(userId, cancellationToken);
        var product = await productRepository.GetByIdAsync(productId, cancellationToken)
            ?? throw new InvalidOperationException($"Product id {productId} does not exist.");

        var existingItem = cart.Items.FirstOrDefault(x => x.ProductId == productId);

        if (existingItem is null)
        {
            cart.Items.Add(new CartItem
            {
                ProductId = productId,
                Quantity = quantity,
                UnitPrice = product.Price,
            });
        }
        else
        {
            existingItem.Quantity += quantity;
            existingItem.UpdatedAtUtc = DateTime.UtcNow;
        }

        await cartRepository.SaveChangesAsync(cancellationToken);
        return Map(cart);
    }

    private static CartDto Map(Cart cart)
    {
        var items = cart.Items.Select(i => new CartItemDto(i.Id, i.ProductId, i.Product.Name, i.UnitPrice, i.Quantity, i.UnitPrice * i.Quantity)).ToList();
        return new CartDto(cart.Id, cart.UserId, items, items.Sum(x => x.LineTotal));
    }
}
