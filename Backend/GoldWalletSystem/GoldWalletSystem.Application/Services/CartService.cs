using GoldWalletSystem.Application.DTOs.Cart;
using GoldWalletSystem.Application.Interfaces.Repositories;
using GoldWalletSystem.Application.Interfaces.Services;
using GoldWalletSystem.Domain.Entities;

namespace GoldWalletSystem.Application.Services;

public class CartService(ICartRepository cartRepository, IProductRepository productRepository, ICurrentUserService currentUserService) : ICartService
{
    public async Task<CartDto> GetCartByUserIdAsync(int userId, CancellationToken cancellationToken = default)
    {
        var cart = await cartRepository.GetOrCreateByUserIdAsync(userId, cancellationToken);
        return Map(cart);
    }

    public async Task<CartDto> AddItemAsync(int userId, int productId, int quantity, CancellationToken cancellationToken = default)
    {
        if (quantity <= 0)
            throw new InvalidOperationException("Quantity should be greater than 0.");

        var cart = await cartRepository.GetOrCreateByUserIdAsync(userId, cancellationToken);
        var product = await productRepository.GetByIdAsync(productId, cancellationToken)
            ?? throw new InvalidOperationException($"Product id {productId} does not exist.");

        EnsureSellerScope(product.SellerId);

        var existingItem = cart.Items.FirstOrDefault(x => x.ProductId == productId);

        if (existingItem is null)
        {
            cart.Items.Add(new CartItem
            {
                ProductId = productId,
                Quantity = quantity,
                UnitPrice = product.Price,
                LineTotal = product.Price * quantity,
            });
        }
        else
        {
            existingItem.Quantity += quantity;
            existingItem.LineTotal = existingItem.Quantity * existingItem.UnitPrice;
            existingItem.UpdatedAtUtc = DateTime.UtcNow;
        }

        await cartRepository.SaveChangesAsync(cancellationToken);
        return Map(cart);
    }

    public async Task<CartDto> UpdateItemQuantityAsync(int userId, int productId, int quantity, CancellationToken cancellationToken = default)
    {
        if (quantity < 0)
            throw new InvalidOperationException("Quantity should not be negative.");

        var cart = await cartRepository.GetOrCreateByUserIdAsync(userId, cancellationToken);
        var existingItem = cart.Items.FirstOrDefault(x => x.ProductId == productId)
            ?? throw new InvalidOperationException($"Product id {productId} is not in cart.");

        if (quantity == 0)
        {
            cart.Items.Remove(existingItem);
        }
        else
        {
            existingItem.Quantity = quantity;
            existingItem.LineTotal = quantity * existingItem.UnitPrice;
            existingItem.UpdatedAtUtc = DateTime.UtcNow;
        }

        await cartRepository.SaveChangesAsync(cancellationToken);
        return Map(cart);
    }

    public async Task<CartDto> RemoveItemAsync(int userId, int productId, CancellationToken cancellationToken = default)
    {
        var cart = await cartRepository.GetOrCreateByUserIdAsync(userId, cancellationToken);
        var existingItem = cart.Items.FirstOrDefault(x => x.ProductId == productId);

        if (existingItem is not null)
        {
            cart.Items.Remove(existingItem);
            await cartRepository.SaveChangesAsync(cancellationToken);
        }

        return Map(cart);
    }

    private void EnsureSellerScope(int productSellerId)
    {
        if (currentUserService.SellerId is int sellerId && productSellerId != sellerId)
            throw new InvalidOperationException("Product does not belong to your seller.");
    }

    private static CartDto Map(Cart cart)
    {
        var items = cart.Items.Select(i => new CartItemDto(i.Id, i.ProductId, i.Product.Name, i.UnitPrice, i.Quantity, i.LineTotal)).ToList();
        return new CartDto(cart.Id, cart.UserId, items, items.Sum(x => x.LineTotal));
    }
}
